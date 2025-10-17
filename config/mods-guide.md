# Minecraft Server Mods Setup Guide
# คู่มือการติดตั้ง Mods สำหรับ Minecraft Server

## 📋 ภาพรวม Mod Support

Minecraft Server สามารถรัน mods ได้ผ่าน:

1. **Forge Server** - รองรับ Forge mods (นิยมมากที่สุด)
2. **Fabric Server** - รองรับ Fabric mods (เร็วและเบา)
3. **Quilt Server** - รองรับ Fabric mods + เพิ่มเติม
4. **NeoForge** - Fork จาก Forge (ใหม่)

## 🔧 การตั้งค่า Forge Server

### 1. ดาวน์โหลด Forge Server

เพิ่มใน `Dockerfile`:

```dockerfile
# Download Forge Server instead of vanilla
ARG FORGE_VERSION=47.3.0
ARG MC_VERSION=1.20.1

RUN wget -O forge-installer.jar https://maven.minecraftforge.net/net/minecraftforge/forge/${MC_VERSION}-${FORGE_VERSION}/forge-${MC_VERSION}-${FORGE_VERSION}-installer.jar

# Install Forge
RUN java -jar forge-installer.jar --installServer --debug

# Set server jar to forge
ENV SERVER_JAR=forge-${MC_VERSION}-${FORGE_VERSION}.jar
```

### 2. สร้าง Dockerfile สำหรับ Forge

```dockerfile
FROM openjdk:21-jre-slim

WORKDIR /minecraft

# Install necessary packages
RUN apt-get update && \
    apt-get install -y wget curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Minecraft and Forge versions
ARG MC_VERSION=1.20.1
ARG FORGE_VERSION=47.3.0
ENV SERVER_JAR=forge-${MC_VERSION}-${FORGE_VERSION}.jar

# Download and install Forge
RUN wget -O forge-installer.jar \
    https://maven.minecraftforge.net/net/minecraftforge/forge/${MC_VERSION}-${FORGE_VERSION}/forge-${MC_VERSION}-${FORGE_VERSION}-installer.jar && \
    java -jar forge-installer.jar --installServer && \
    rm forge-installer.jar

# Create minecraft user
RUN groupadd -r minecraft && useradd -r -g minecraft minecraft

# Create directories
RUN mkdir -p /minecraft/mods /minecraft/config /minecraft/data /minecraft/logs

# Copy configuration files
COPY server.properties /minecraft/
COPY eula.txt /minecraft/

# Set ownership
RUN chown -R minecraft:minecraft /minecraft

USER minecraft

EXPOSE 25565

# Memory settings
ENV MEMORY_SIZE=4G

CMD ["sh", "-c", "java -Xmx${MEMORY_SIZE} -Xms${MEMORY_SIZE} -jar ${SERVER_JAR} --nogui"]
```

## 🧩 การติดตั้ง Mods

### 1. โครงสร้างโฟลเดอร์

```
minecraft-server/
├── mods/              # วาง mod files (.jar)
├── config/           # การตั้งค่า mods
├── scripts/          # Management scripts
└── docker-compose.yml
```

### 2. เพิ่ม Mods ใน docker-compose.yml

```yaml
version: '3.8'

services:
  minecraft-server:
    build: .
    container_name: minecraft-forge-server
    ports:
      - "25565:25565"
    environment:
      - MEMORY_SIZE=4G
      - MC_VERSION=1.20.1
      - FORGE_VERSION=47.3.0
    volumes:
      - ./data:/minecraft/data
      - ./logs:/minecraft/logs
      - ./mods:/minecraft/mods           # Mount mods folder
      - ./config:/minecraft/config       # Mount config folder
      - ./server.properties:/minecraft/server.properties
      - ./whitelist.json:/minecraft/whitelist.json
      - ./ops.json:/minecraft/ops.json
    restart: unless-stopped
    stdin_open: true
    tty: true
```

### 3. การวาง Mod Files

```bash
# สร้างโฟลเดอร์ mods
mkdir -p mods config

# ดาวน์โหลด mods (.jar files) และวางใน mods/
# ตัวอย่าง:
# mods/
# ├── JEI-1.20.1-forge-15.2.0.27.jar
# ├── OptiFine_1.20.1_HD_U_I6.jar
# └── journeymap-1.20.1-5.9.18-forge.jar
```

## 📦 Mods ที่แนะนำสำหรับ Server

### Server-Side Mods (รันบน server เท่านั้น)

```bash
# Performance & Management Mods
- Spark (performance profiler)
- ServerCore (server optimization)
- AI Improvements (AI optimization)
- Chunk Pregenerator (world generation)
- FTB Chunks (chunk protection)

# Admin & Utility Mods  
- WorldEdit (world editing)
- LuckPerms (permissions)
- EssentialsX (server commands)
```

### Client + Server Mods (ต้องติดตั้งทั้งสองฝั่ง)

```bash
# Popular Mods
- JEI (Just Enough Items)
- JourneyMap (minimap)
- WAILA/HWYLA (block info)
- Iron Chests (better chests)
- Tinkers' Construct (tool crafting)
- Applied Energistics 2 (storage system)
- Thermal Expansion (machines)
- Buildcraft (automation)
- Forestry (farming/bees)
- IndustrialCraft 2 (industrial)
```

## 🛠️ Mod Management Scripts

### การสร้างสคริปต์จัดการ Mods

```bash
#!/bin/bash
# scripts/manage-mods.sh

MODS_DIR="mods"
CONFIG_DIR="config"

# Function to download mod from CurseForge
download_mod() {
    local mod_id=$1
    local file_id=$2
    local filename=$3
    
    print_status "Downloading $filename..."
    curl -L "https://www.curseforge.com/api/v1/mods/$mod_id/files/$file_id/download" \
         -o "$MODS_DIR/$filename"
}

# Function to list installed mods
list_mods() {
    print_header "Installed Mods"
    if [ -d "$MODS_DIR" ] && [ "$(ls -A $MODS_DIR)" ]; then
        ls -la $MODS_DIR/*.jar 2>/dev/null | awk '{print $9, $5}' | column -t
    else
        print_warning "No mods installed"
    fi
}

# Function to remove mod
remove_mod() {
    local mod_name=$1
    if [ -f "$MODS_DIR/$mod_name" ]; then
        rm "$MODS_DIR/$mod_name"
        print_status "Removed $mod_name"
    else
        print_error "Mod $mod_name not found"
    fi
}

# Function to backup mods
backup_mods() {
    local backup_name="mods_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    tar -czf "backups/$backup_name" $MODS_DIR/ $CONFIG_DIR/
    print_status "Mods backed up to: backups/$backup_name"
}
```

## ⚡ Fabric Server Setup

หากต้องการใช้ Fabric แทน Forge:

```dockerfile
# Dockerfile.fabric
FROM openjdk:21-jre-slim

WORKDIR /minecraft

# Fabric versions
ARG MC_VERSION=1.20.1  
ARG FABRIC_VERSION=0.14.22

# Download Fabric server
RUN wget -O fabric-server-launcher.jar \
    https://meta.fabricmc.net/v2/versions/loader/${MC_VERSION}/${FABRIC_VERSION}/stable/server/jar

ENV SERVER_JAR=fabric-server-launcher.jar

# Rest same as Forge...
```

## 🔄 การ Update Mods

### 1. สร้างไฟล์ mod list

```json
// mods-list.json
{
  "mods": [
    {
      "name": "JEI",
      "version": "15.2.0.27",
      "url": "https://...",
      "required": true
    },
    {
      "name": "JourneyMap", 
      "version": "5.9.18",
      "url": "https://...",
      "required": false
    }
  ]
}
```

### 2. สคริปต์ Update อัตโนมัติ

```bash
#!/bin/bash
# scripts/update-mods.sh

update_all_mods() {
    print_header "Updating All Mods"
    
    # Backup current mods
    backup_mods
    
    # Read mod list and update
    # Implementation depends on mod source (CurseForge API, etc.)
}
```

## 🧪 การทดสอบ Mods

### 1. Test Environment

```yaml
# docker-compose.test.yml
version: '3.8'
services:
  minecraft-test:
    build: .
    environment:
      - MEMORY_SIZE=2G
    volumes:
      - ./mods-test:/minecraft/mods
    ports:
      - "25566:25565"  # Different port for testing
```

### 2. Mod Compatibility Check

```bash
# scripts/test-mods.sh
test_mod_compatibility() {
    print_header "Testing Mod Compatibility"
    
    # Start test server
    docker-compose -f docker-compose.test.yml up -d
    
    # Wait and check logs for errors
    sleep 30
    docker-compose -f docker-compose.test.yml logs | grep -i error
    
    # Cleanup
    docker-compose -f docker-compose.test.yml down
}
```

## ⚠️ การแก้ไขปัญหา Mods

### ปัญหาที่พบบ่อย:

1. **Mod Version Mismatch**
   ```bash
   # ตรวจสอบ version ใน logs
   docker logs minecraft-server | grep -i "version"
   ```

2. **Missing Dependencies**
   ```bash
   # ตรวจสอบ dependency requirements
   # อ่าน mod description สำหรับ required mods
   ```

3. **Memory Issues**
   ```bash
   # เพิ่ม memory allocation
   # แก้ไข MEMORY_SIZE=6G หรือมากกว่า
   ```

4. **Config Conflicts**
   ```bash
   # ลบ config files และให้ generate ใหม่
   rm -rf config/
   mkdir config/
   ```

## 📋 Mod Installation Checklist

- [ ] เลือก Server Type (Forge/Fabric)
- [ ] ตรวจสอบ Minecraft Version compatibility
- [ ] ดาวน์โหลด mods ที่เข้ากันได้
- [ ] วาง mods ในโฟลเดอร์ `mods/`
- [ ] เพิ่ม memory allocation (แนะนำ 4GB+)
- [ ] ทดสอบ server startup
- [ ] ตรวจสอบ mod loading ใน logs
- [ ] ทดสอบเชื่อมต่อจาก client
- [ ] สำรองข้อมูล mods และ config

## 🎯 Modpack Recommendations

### Light Modpacks (2-4GB RAM):
- **Simply Optimized** - Performance focused
- **Fabulously Optimized** - Client optimization
- **Better Minecraft** - Vanilla enhanced

### Medium Modpacks (4-6GB RAM):
- **All the Mods 9** - Kitchen sink
- **FTB Academy** - Learning focused
- **Enigmatica 6** - Expert progression

### Heavy Modpacks (6-8GB+ RAM):
- **ATM9: Sky** - Skyblock expert
- **GT: New Horizons** - Ultimate expert
- **FTB Infinity Evolved** - Classic expert

---

**หมายเหตุ**: การรัน mods จะใช้ RAM และ CPU มากขึ้น ควรปรับ memory allocation และตรวจสอบประสิทธิภาพเป็นประจำ!