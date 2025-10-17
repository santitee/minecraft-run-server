#!/bin/bash

# Minecraft Server Management Script
# สคริปต์จัดการ Minecraft Server

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE} $1 ${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Function to check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed. Please install Docker first."
        print_status "Visit: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    # Check for Docker Compose (either v1 or v2)
    if ! docker compose version &> /dev/null && ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed. Please install Docker Compose first."
        exit 1
    fi
    
    # Set compose command based on available version
    if docker compose version &> /dev/null; then
        DOCKER_COMPOSE="docker compose"
    else
        DOCKER_COMPOSE="docker-compose"
    fi
}

# Function to build the server
build_server() {
    print_header "Building Minecraft Server"
    print_status "Building Docker image..."
    $DOCKER_COMPOSE build --no-cache
    print_status "Build completed successfully!"
}

# Function to start the server
start_server() {
    print_header "Starting Minecraft Server"
    
    # Check if server is already running
    if $DOCKER_COMPOSE ps | grep -q "minecraft-server.*Up"; then
        print_warning "Server is already running!"
        return 0
    fi
    
    print_status "Starting server in detached mode..."
    $DOCKER_COMPOSE up -d
    
    print_status "Waiting for server to start..."
    sleep 10
    
    # Check if server started successfully
    if $DOCKER_COMPOSE ps | grep -q "minecraft-server.*Up"; then
        print_status "Server started successfully!"
        print_status "Server is running on port 25565"
        print_status "Use 'npm run logs' to view server logs"
    else
        print_error "Failed to start server. Check logs for details."
        $DOCKER_COMPOSE logs minecraft-server
    fi
}

# Function to stop the server
stop_server() {
    print_header "Stopping Minecraft Server"
    
    if ! $DOCKER_COMPOSE ps | grep -q "minecraft-server.*Up"; then
        print_warning "Server is not running!"
        return 0
    fi
    
    print_status "Stopping server..."
    $DOCKER_COMPOSE down
    print_status "Server stopped successfully!"
}

# Function to restart the server
restart_server() {
    print_header "Restarting Minecraft Server"
    stop_server
    sleep 3
    start_server
}

# Function to show server logs
show_logs() {
    print_header "Minecraft Server Logs"
    print_status "Showing server logs (Press Ctrl+C to exit)..."
    $DOCKER_COMPOSE logs -f minecraft-server
}

# Function to show server status
show_status() {
    print_header "Minecraft Server Status"
    
    if $DOCKER_COMPOSE ps | grep -q "minecraft-server.*Up"; then
        print_status "Server Status: RUNNING ✅"
        print_status "Container Info:"
        $DOCKER_COMPOSE ps minecraft-server
        
        # Get server IP
        SERVER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' minecraft-server 2>/dev/null || echo "N/A")
        print_status "Server IP: $SERVER_IP"
        print_status "External Port: 25565"
        
        # Show resource usage
        print_status "Resource Usage:"
        docker stats minecraft-server --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
    else
        print_warning "Server Status: STOPPED ❌"
    fi
}

# Function to connect to server console
connect_console() {
    print_header "Connecting to Server Console"
    print_status "Connecting to Minecraft server console..."
    print_warning "Type 'exit' or press Ctrl+D to disconnect from console"
    $DOCKER_COMPOSE exec minecraft-server /bin/bash
}

# Function to backup the server
backup_server() {
    print_header "Backing up Minecraft Server"
    
    BACKUP_DIR="backups"
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="minecraft_backup_$TIMESTAMP.tar.gz"
    
    mkdir -p $BACKUP_DIR
    
    print_status "Creating backup: $BACKUP_FILE"
    tar -czf "$BACKUP_DIR/$BACKUP_FILE" data/ logs/ server.properties whitelist.json ops.json 2>/dev/null || true
    
    print_status "Backup created successfully: $BACKUP_DIR/$BACKUP_FILE"
}

# Function to show help
show_help() {
    print_header "Minecraft Server Management"
    echo -e "Usage: $0 [COMMAND]"
    echo -e ""
    echo -e "Commands:"
    echo -e "  ${GREEN}build${NC}      Build the Docker image"
    echo -e "  ${GREEN}start${NC}      Start the Minecraft server"
    echo -e "  ${GREEN}stop${NC}       Stop the Minecraft server"  
    echo -e "  ${GREEN}restart${NC}    Restart the Minecraft server"
    echo -e "  ${GREEN}status${NC}     Show server status and info"
    echo -e "  ${GREEN}logs${NC}       Show server logs"
    echo -e "  ${GREEN}console${NC}    Connect to server console"
    echo -e "  ${GREEN}backup${NC}     Create a backup of server data"
    echo -e "  ${GREEN}help${NC}       Show this help message"
    echo -e ""
    echo -e "Examples:"
    echo -e "  $0 build"
    echo -e "  $0 start"
    echo -e "  $0 status"
}

# Main script logic
main() {
    # Check if Docker is installed
    check_docker
    
    case "${1:-help}" in
        build)
            build_server
            ;;
        start)
            start_server
            ;;
        stop)
            stop_server
            ;;
        restart)
            restart_server
            ;;
        status)
            show_status
            ;;
        logs)
            show_logs
            ;;
        console)
            connect_console
            ;;
        backup)
            backup_server
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"