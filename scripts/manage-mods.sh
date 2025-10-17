#!/bin/bash

# Minecraft Mods Management Script
# สคริปต์จัดการ Mods สำหรับ Minecraft Server

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Directories
MODS_DIR="mods"
CONFIG_DIR="config"  
BACKUP_DIR="backups"

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

print_mod() {
    echo -e "${PURPLE}[MOD]${NC} $1"
}

# Function to create directories if they don't exist
setup_directories() {
    mkdir -p "$MODS_DIR" "$CONFIG_DIR" "$BACKUP_DIR"
}

# Function to list installed mods
list_mods() {
    print_header "Installed Mods"
    
    if [ -d "$MODS_DIR" ] && [ "$(ls -A $MODS_DIR 2>/dev/null)" ]; then
        echo -e "${BLUE}Filename${NC}\t\t\t${BLUE}Size${NC}"
        echo "----------------------------------------"
        
        for mod in "$MODS_DIR"/*.jar; do
            if [ -f "$mod" ]; then
                filename=$(basename "$mod")
                size=$(ls -lh "$mod" | awk '{print $5}')
                echo -e "$filename\t$size"
            fi
        done
        
        echo ""
        mod_count=$(ls -1 "$MODS_DIR"/*.jar 2>/dev/null | wc -l)
        print_status "Total mods: $mod_count"
    else
        print_warning "No mods installed in $MODS_DIR/"
        print_status "Place .jar files in the $MODS_DIR/ directory"
    fi
}

# Function to analyze mod dependencies
analyze_dependencies() {
    print_header "Mod Dependency Analysis"
    
    if [ ! -d "$MODS_DIR" ] || [ ! "$(ls -A $MODS_DIR 2>/dev/null)" ]; then
        print_warning "No mods found to analyze"
        return
    fi
    
    print_status "Analyzing mod files..."
    
    for mod in "$MODS_DIR"/*.jar; do
        if [ -f "$mod" ]; then
            filename=$(basename "$mod")
            print_mod "Checking: $filename"
            
            # Extract mod info (basic check)
            unzip -q -c "$mod" META-INF/mods.toml 2>/dev/null | head -20 || \
            unzip -q -c "$mod" mcmod.info 2>/dev/null | head -10 || \
            unzip -q -c "$mod" fabric.mod.json 2>/dev/null | head -10 || \
            echo "  Could not read mod metadata"
            
            echo ""
        fi
    done
}

# Function to backup mods and configs
backup_mods() {
    print_header "Backing up Mods and Configs"
    
    setup_directories
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_name="mods_config_backup_$timestamp.tar.gz"
    local backup_path="$BACKUP_DIR/$backup_name"
    
    if [ -d "$MODS_DIR" ] && [ "$(ls -A $MODS_DIR 2>/dev/null)" ]; then
        print_status "Creating backup: $backup_name"
        tar -czf "$backup_path" "$MODS_DIR" "$CONFIG_DIR" 2>/dev/null || {
            print_error "Failed to create backup"
            return 1
        }
        
        local backup_size=$(ls -lh "$backup_path" | awk '{print $5}')
        print_status "Backup created successfully: $backup_path ($backup_size)"
        
        # List recent backups
        echo ""
        print_status "Recent backups:"
        ls -lt "$BACKUP_DIR"/mods_config_backup_*.tar.gz 2>/dev/null | head -5 | awk '{print "  " $9 " (" $5 ")"}'
    else
        print_warning "No mods found to backup"
    fi
}

# Function to restore from backup
restore_backup() {
    print_header "Restore Mods from Backup"
    
    if [ ! -d "$BACKUP_DIR" ] || [ ! "$(ls -A $BACKUP_DIR/mods_config_backup_*.tar.gz 2>/dev/null)" ]; then
        print_warning "No backup files found"
        return
    fi
    
    echo "Available backups:"
    ls -lt "$BACKUP_DIR"/mods_config_backup_*.tar.gz | awk '{print NR ". " $9 " (" $5 ", " $6 " " $7 " " $8 ")"}'
    
    echo ""
    read -p "Enter backup number to restore (or 'q' to quit): " choice
    
    if [ "$choice" = "q" ]; then
        print_status "Restore cancelled"
        return
    fi
    
    backup_file=$(ls -t "$BACKUP_DIR"/mods_config_backup_*.tar.gz | sed -n "${choice}p")
    
    if [ -z "$backup_file" ]; then
        print_error "Invalid choice"
        return
    fi
    
    print_status "Restoring from: $(basename "$backup_file")"
    
    # Backup current state first
    if [ -d "$MODS_DIR" ] && [ "$(ls -A $MODS_DIR 2>/dev/null)" ]; then
        print_status "Backing up current state before restore..."
        backup_mods
    fi
    
    # Remove current mods and config
    rm -rf "$MODS_DIR" "$CONFIG_DIR"
    
    # Restore from backup
    tar -xzf "$backup_file"
    
    print_status "Restore completed successfully"
    list_mods
}

# Function to remove a mod
remove_mod() {
    local mod_pattern="$1"
    
    if [ -z "$mod_pattern" ]; then
        print_error "Please provide mod name pattern"
        echo "Usage: $0 remove <mod_name_pattern>"
        return 1
    fi
    
    print_header "Remove Mod"
    
    # Find matching mods
    matching_mods=$(find "$MODS_DIR" -name "*$mod_pattern*" -type f 2>/dev/null || true)
    
    if [ -z "$matching_mods" ]; then
        print_warning "No mods found matching pattern: $mod_pattern"
        return
    fi
    
    echo "Found matching mods:"
    echo "$matching_mods" | nl
    
    echo ""
    read -p "Remove these mods? (y/N): " confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        echo "$matching_mods" | while read -r mod_file; do
            if [ -f "$mod_file" ]; then
                print_status "Removing: $(basename "$mod_file")"
                rm "$mod_file"
            fi
        done
        print_status "Mods removed successfully"
    else
        print_status "Operation cancelled"
    fi
}

# Function to clean up mod configs
clean_configs() {
    print_header "Clean Mod Configs"
    
    if [ ! -d "$CONFIG_DIR" ]; then
        print_warning "Config directory not found"
        return
    fi
    
    print_status "Backing up configs before cleaning..."
    backup_mods
    
    read -p "Remove all mod configurations? This will reset all mod settings (y/N): " confirm
    
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        rm -rf "$CONFIG_DIR"/*
        print_status "All mod configs removed"
        print_status "Configs will be regenerated on next server start"
    else
        print_status "Operation cancelled"
    fi
}

# Function to check server compatibility
check_compatibility() {
    print_header "Mod Compatibility Check"
    
    print_status "Checking Minecraft and Forge versions..."
    
    # Check if server is running
    if docker ps | grep -q minecraft.*forge.*server; then
        print_status "Server is running - checking versions from container..."
        docker exec minecraft-forge-server java -version 2>&1 | head -1
        
        # Try to get mod list from server
        print_status "Getting mod list from running server..."
        docker exec minecraft-forge-server ls -la /minecraft/mods/ 2>/dev/null || \
        print_warning "Could not access mods directory in container"
    else
        print_warning "Server is not running"
        print_status "Start server to check full compatibility"
    fi
    
    # Basic compatibility checks
    print_status "Performing basic compatibility checks..."
    
    for mod in "$MODS_DIR"/*.jar; do
        if [ -f "$mod" ]; then
            filename=$(basename "$mod")
            
            # Check for common version patterns
            if echo "$filename" | grep -qi "1\.20\.1"; then
                print_status "✓ $filename - Version looks compatible"
            elif echo "$filename" | grep -qi "1\.2[01]"; then
                print_warning "? $filename - May be compatible (check version)"
            else
                print_warning "⚠ $filename - Version unclear, check compatibility"
            fi
        fi
    done
}

# Function to show mod server status
server_status() {
    print_header "Forge Server Status"
    
    if docker ps | grep -q minecraft.*forge.*server; then
        print_status "Forge server is RUNNING ✅"
        
        # Get container stats
        print_status "Container Information:"
        docker ps | grep minecraft.*forge.*server
        
        echo ""
        print_status "Resource Usage:"
        docker stats minecraft-forge-server --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
        
        echo ""
        print_status "Recent Server Logs:"
        docker logs minecraft-forge-server --tail 10
    else
        print_warning "Forge server is STOPPED ❌"
        print_status "Use './scripts/manage-server.sh start' to start the server"
    fi
}

# Function to show help
show_help() {
    print_header "Mods Management Help"
    echo -e "Usage: $0 [COMMAND] [OPTIONS]"
    echo -e ""
    echo -e "Commands:"
    echo -e "  ${GREEN}list${NC}          List all installed mods"
    echo -e "  ${GREEN}analyze${NC}       Analyze mod dependencies and info"
    echo -e "  ${GREEN}backup${NC}        Backup mods and configurations"
    echo -e "  ${GREEN}restore${NC}       Restore mods from backup"
    echo -e "  ${GREEN}remove${NC} <name> Remove mod by name pattern"
    echo -e "  ${GREEN}clean${NC}         Clean all mod configurations"
    echo -e "  ${GREEN}check${NC}         Check mod compatibility"
    echo -e "  ${GREEN}status${NC}        Show forge server status"
    echo -e "  ${GREEN}help${NC}          Show this help message"
    echo -e ""
    echo -e "Examples:"
    echo -e "  $0 list"
    echo -e "  $0 backup"
    echo -e "  $0 remove jei"
    echo -e "  $0 check"
    echo -e ""
    echo -e "Mod Installation:"
    echo -e "  1. Download .jar files"
    echo -e "  2. Place in ${MODS_DIR}/ directory"
    echo -e "  3. Restart server: npm run restart"
}

# Main script logic
main() {
    # Setup directories
    setup_directories
    
    case "${1:-help}" in
        list)
            list_mods
            ;;
        analyze)
            analyze_dependencies
            ;;
        backup)
            backup_mods
            ;;
        restore)
            restore_backup
            ;;
        remove)
            remove_mod "$2"
            ;;
        clean)
            clean_configs
            ;;
        check)
            check_compatibility
            ;;
        status)
            server_status
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