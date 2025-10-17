# Minecraft Server Docker 🎮

เซิร์ฟเวอร์ Minecraft ที่รันใน Docker Container พร้อมระบบจัดการที่ง่ายและครบถ้วน

## 📋 ข้อมูลโปรเจ็กต์

- **Minecraft Version**: 1.21.1
- **Java Version**: OpenJDK 21
- **Default Memory**: 2GB
- **Default Port**: 25565
- **Container Technology**: Docker + Docker Compose

## 🚀 การติดตั้งและการใช้งาน

### ขั้นตอนที่ 1: ตรวจสอบ Requirements

```bash
# ตรวจสอบ Docker
docker --version
docker compose version

# หาก Docker ไม่ได้ติดตั้ง ให้ติดตั้งจาก:
# https://docs.docker.com/get-docker/
```

### ขั้นตอนที่ 2: เริ่มต้น Docker Desktop

เปิด Docker Desktop และรอจนกว่าจะ Ready

### ขั้นตอนที่ 3: Build Server

```bash
# วิธีที่ 1: ใช้ npm scripts
npm run build

# วิธีที่ 2: ใช้ management script
./scripts/manage-server.sh build

# วิธีที่ 3: ใช้ VS Code Tasks
# กด Ctrl+Shift+P แล้วพิมพ์ "Tasks: Run Task" 
# เลือก "Build Minecraft Server"
```

### ขั้นตอนที่ 4: เริ่มต้น Server

```bash
# เริ่มต้น server
npm run start

# หรือ
./scripts/manage-server.sh start
```

### ขั้นตอนที่ 5: ตรวจสอบสถานะ

```bash
# ดูสถานะ server
npm run status

# ดู logs
npm run logs
```

## 🎯 คำสั่งที่ใช้บ่อย

### NPM Scripts
```bash
npm run build    # Build Docker image
npm run start    # Start server
npm run stop     # Stop server
npm run restart  # Restart server
npm run status   # Show status
npm run logs     # View logs
npm run console  # Connect to console
npm run backup   # Backup server data
npm run help     # Show help
```

### Management Script
```bash
./scripts/manage-server.sh build
./scripts/manage-server.sh start
./scripts/manage-server.sh stop
./scripts/manage-server.sh restart
./scripts/manage-server.sh status
./scripts/manage-server.sh logs
./scripts/manage-server.sh console
./scripts/manage-server.sh backup
./scripts/manage-server.sh help
```

### VS Code Tasks
- **Ctrl+Shift+P** → "Tasks: Run Task"
- เลือก task ที่ต้องการ:
  - Build Minecraft Server
  - Start Minecraft Server
  - Stop Minecraft Server
  - Server Status
  - View Server Logs
  - Backup Server Data

## 🌐 การเชื่อมต่อจาก Minecraft Client

### 1. หา IP Address ของเซิร์ฟเวอร์

```bash
# Local IP (เครื่องในเครือข่ายเดียวกัน)
ifconfig | grep "inet " | grep -v 127.0.0.1

# Public IP (เชื่อมต่อจากอินเทอร์เน็ต)
curl ifconfig.me
```

### 2. การตั้งค่าใน Minecraft Client

1. เปิด Minecraft Launcher
2. เลือก version 1.21.1
3. เข้าเกม → Multiplayer → Add Server
4. ใส่ Server Address:

#### สำหรับเครื่องเดียวกัน:
```
localhost:25565
```

#### สำหรับเครื่องในเครือข่ายเดียวกัน:
```
192.168.1.xxx:25565
```

#### สำหรับเชื่อมต่อจากอินเทอร์เน็ต:
```
[YOUR_PUBLIC_IP]:25565
```

### 3. Port Forwarding (สำหรับการเชื่อมต่อจากอินเทอร์เน็ট)

1. เข้าหน้าเว็บ Router (192.168.1.1)
2. หา Port Forwarding settings
3. เพิ่ม rule ใหม่:
   - Internal IP: IP ของเครื่องคุณ
   - Internal Port: 25565
   - External Port: 25565
   - Protocol: TCP/UDP

## ⚙️ การปรับแต่งการตั้งค่า

### การแก้ไข server.properties

```bash
# แก้ไขไฟล์ server.properties
code server.properties

# ตั้งค่าที่สำคัญ:
# - max-players=20          # จำนวนผู้เล่นสูงสุด
# - difficulty=easy         # ความยาก
# - gamemode=survival       # โหมดเกม
# - white-list=false        # เปิด/ปิด whitelist
# - view-distance=10        # ระยะมองเห็น
```

### การจัดการ Memory

แก้ไขใน `.env` file:
```bash
MEMORY_SIZE=4G  # เปลี่ยนจาก 2G เป็น 4G
```

หรือแก้ไขใน `docker-compose.yml`:
```yaml
environment:
  - MEMORY_SIZE=4G
```

### การเพิ่มผู้เล่นใน Whitelist

แก้ไข `whitelist.json`:
```json
[
  {
    "uuid": "player-uuid-here",
    "name": "PlayerName"
  }
]
```

### การเพิ่ม Admin (Ops)

แก้ไข `ops.json`:
```json
[
  {
    "uuid": "admin-uuid-here",
    "name": "AdminName", 
    "level": 4,
    "bypassesPlayerLimit": true
  }
]
```

## 📁 โครงสร้างไฟล์

```
minecraft-run-server/
├── .env                    # Environment variables
├── .gitignore             # Git ignore rules
├── docker-compose.yml     # Docker Compose configuration
├── Dockerfile             # Docker image definition
├── eula.txt              # Minecraft EULA agreement
├── package.json          # NPM scripts
├── server.properties     # Minecraft server configuration
├── whitelist.json        # Player whitelist
├── ops.json             # Server operators
├── .github/
│   └── copilot-instructions.md
├── .vscode/
│   └── tasks.json        # VS Code tasks
├── config/
│   └── connection-guide.md
├── data/                 # Server world data (auto-generated)
├── logs/                 # Server logs (auto-generated)
└── scripts/
    └── manage-server.sh  # Management script
```

## 🔧 การแก้ไขปัญหา

### ปัญหาที่พบบ่อย

1. **Docker daemon not running**
   ```bash
   open -a "Docker Desktop"
   # รอจน Docker Desktop พร้อมใช้งาน
   ```

2. **Port already in use**
   ```bash
   # ตรวจสอบ process ที่ใช้ port 25565
   lsof -i :25565
   
   # หยุด process
   sudo kill -9 [PID]
   ```

3. **ไม่สามารถเชื่อมต่อได้**
   - ตรวจสอบ Server กำลังรันอยู่หรือไม่: `npm run status`
   - ตรวจสอบ Firewall settings
   - ตรวจสอบ Port Forwarding (ถ้าเชื่อมต่อจากภายนอก)

4. **Server crash หรือ out of memory**
   ```bash
   # เพิ่ม memory allocation
   # แก้ไข MEMORY_SIZE ใน .env หรือ docker-compose.yml
   ```

### ดู Logs เพื่อ Debug

```bash
# ดู real-time logs
npm run logs

# ดู container logs
docker logs minecraft-server

# ดู system resources
docker stats minecraft-server
```

## 🔐 Security Best Practices

### 1. เปิดใช้ Online Mode
```properties
# ใน server.properties
online-mode=true
```

### 2. ใช้ Whitelist
```properties
# ใน server.properties  
white-list=true
```

### 3. ตั้งค่า Firewall
```bash
# เปิดเฉพาะ port ที่จำเป็น
# หลีกเลี่ยงการเปิด port ทั้งหมด
```

### 4. สำรองข้อมูลเป็นประจำ
```bash
npm run backup
```

## 📚 เอกสารเพิ่มเติม

- [คู่มือการเชื่อมต่อแบบละเอียด](config/connection-guide.md)
- [Docker Documentation](https://docs.docker.com/)
- [Minecraft Server Properties](https://minecraft.fandom.com/wiki/Server.properties)

## 🤝 การสนับสนุน

หากพบปัญหาหรือต้องการความช่วยเหลือ:

1. ตรวจสอบ logs: `npm run logs`
2. ตรวจสอบสถานะ: `npm run status`  
3. อ่านคู่มือการแก้ไขปัญหาด้านบน
4. ตรวจสอบ Docker Desktop กำลังทำงานหรือไม่

---

🎮 **Happy Mining!** ขุดให้สนุก สร้างให้มันส์! ⛏️