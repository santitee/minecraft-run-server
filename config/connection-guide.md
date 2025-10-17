# Minecraft Server Connection Guide
# คู่มือการเชื่อมต่อ Minecraft Server

## การหา IP Address ของเซิร์ฟเวอร์

### 1. การหา Local IP Address (สำหรับเครื่องในเครือข่ายเดียวกัน)

```bash
# บน macOS/Linux
ifconfig | grep "inet " | grep -v 127.0.0.1

# หรือใช้คำสั่ง
ip route get 1 | awk '{print $7}'

# ผลลัพธ์จะเป็นประมาณ: 192.168.1.100
```

### 2. การหา Public IP Address (สำหรับเครื่องจากอินเทอร์เน็ต)

```bash
# ตรวจสอบ Public IP
curl ifconfig.me
# หรือ
curl ipinfo.io/ip
```

## การตั้งค่า Port Forwarding (สำหรับการเชื่อมต่อจากอินเทอร์เน็ต)

### บน Router:
1. เข้าสู่หน้าเว็บของ Router (โดยปกติ 192.168.1.1 หรือ 192.168.0.1)
2. หา Port Forwarding หรือ Virtual Server Settings
3. เพิ่ม Rule ใหม่:
   - **Service Name**: Minecraft Server
   - **Internal IP**: IP ของเครื่องคุณ (เช่น 192.168.1.100)
   - **Internal Port**: 25565
   - **External Port**: 25565
   - **Protocol**: TCP/UDP หรือ Both

### ตรวจสอบ Port เปิดแล้วหรือไม่:
```bash
# ตรวจสอบ port ภายใน
netstat -an | grep 25565

# ตรวจสอบจากภายนอก (ใช้เว็บไซต์)
# ไปที่ https://www.yougetsignal.com/tools/open-ports/
# ใส่ Public IP และ Port 25565
```

## วิธีการเชื่อมต่อใน Minecraft Client

### 1. เปิด Minecraft Launcher
### 2. เลือก Version ที่ตรงกับ Server (1.21.1)
### 3. เข้าเกม และเลือก Multiplayer
### 4. คลิก "Add Server" หรือ "Direct Connect"

### การใส่ Server Address:

#### สำหรับเครื่องในเครือข่ายเดียวกัน:
```
192.168.1.100:25565
```

#### สำหรับเครื่องจากอินเทอร์เน็ต:
```
[YOUR_PUBLIC_IP]:25565
```

#### หากใช้ Default Port (25565) สามารถไม่ใส่ Port ก็ได้:
```
192.168.1.100
[YOUR_PUBLIC_IP]
```

## การตรวจสอบการเชื่อมต่อ

### 1. ตรวจสอบ Server Status:
```bash
npm run status
```

### 2. ดู Server Logs:
```bash
npm run logs
```

### 3. ตรวจสอบ Network Connection:
```bash
# ตรวจสอบ connection จาก client
telnet [SERVER_IP] 25565

# หรือใช้ nc (netcat)
nc -v [SERVER_IP] 25565
```

## การแก้ปัญหาการเชื่อมต่อ

### 1. ไม่สามารถเชื่อมต่อได้:
- ✅ ตรวจสอบว่า Server รันอยู่หรือไม่
- ✅ ตรวจสอบ Port Forwarding (ถ้าเชื่อมต่อจากภายนอก)
- ✅ ตรวจสอบ Firewall Settings
- ✅ ตรวจสอบ IP Address ถูกต้องหรือไม่

### 2. Connection Timeout:
- ✅ ตรวจสอบ Network Connection
- ✅ ตรวจสอบ Router Settings
- ✅ ลองใช้ Direct Connect แทน Add Server

### 3. "Can't resolve hostname":
- ✅ ใช้ IP Address แทน Domain Name
- ✅ ตรวจสอบ DNS Settings

## ตัวอย่าง IP Addresses ที่ใช้บ่อย

```bash
# Local Network (ภายในเครือข่าย)
192.168.1.xxx    # เครือข่ายบ้านทั่วไป
192.168.0.xxx    # เครือข่ายบ้าน (บาง Router)
10.0.0.xxx       # เครือข่ายองค์กร
172.16.xxx.xxx   # เครือข่ายองค์กร

# Localhost (เครื่องเดียวกัน)
127.0.0.1        # IPv4 localhost
localhost        # Domain localhost
```

## Security Notes

### 1. การใช้ Whitelist:
```bash
# เปิดใช้ whitelist ใน server.properties
white-list=true

# เพิ่มผู้เล่นใน whitelist.json
[
  {
    "uuid": "player-uuid-here",
    "name": "PlayerName"
  }
]
```

### 2. การตั้งค่า Ops (Admin):
```bash
# เพิ่ม admin ใน ops.json
[
  {
    "uuid": "admin-uuid-here", 
    "name": "AdminName",
    "level": 4,
    "bypassesPlayerLimit": true
  }
]
```