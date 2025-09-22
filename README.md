# System Health Dashboard

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Platform](https://img.shields.io/badge/Platform-Unix%2FLinux-blue.svg)](https://www.unix.org/)

A comprehensive command-line system monitoring tool designed for Unix/Linux environments. This interactive dashboard provides real-time system metrics, automated logging, threshold-based alerting, and secure user authentication - all in a single, portable Bash script.

## ✨ Features

### 🔐 Authentication System
- **Secure User Management**: SHA-256 password hashing with user registration and login
- **Session Management**: Secure login/logout functionality with session isolation
- **Administrative Controls**: User data reset capabilities for system administrators

### 📊 Real-time Monitoring
- **CPU Usage**: Overall and per-core statistics with visual graphs
- **Memory Tracking**: RAM and swap usage with detailed breakdowns
- **Disk Space**: Monitoring across all mounted filesystems
- **Process Analysis**: Top consumers by CPU and memory usage
- **Network Statistics**: Interface information and IP address display
- **User Activity**: Logged-in users and their running processes

### 🚨 Intelligent Alerting
- **Configurable Thresholds**: CPU (85%) and disk usage (90%) monitoring
- **Sustained Breach Detection**: Prevents false alarms with consecutive violation checks
- **Multi-channel Notifications**: Desktop alerts and email notifications
- **Background Monitoring**: Continuous monitoring every 10 seconds during active sessions

### 📈 Visual Representation
- **Text-based Graphs**: ASCII bar charts for resource usage visualization
- **Color-coded Output**: Clear status indicators and formatted displays
- **Menu-driven Interface**: Intuitive navigation for all system functions

## 🚀 Quick Start

### Prerequisites

Ensure you have the following standard Unix utilities installed:
```bash
# Check required utilities
which top free df ps mpstat who ip sha256sum
```

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/yourusername/system-health-dashboard.git
   cd system-health-dashboard
   ```

2. **Make the script executable**:
   ```bash
   chmod +x p.sh
   ```

3. **Optional: Setup email notifications**:
   ```bash
   sudo apt update
   sudo apt install mailutils postfix
   sudo dpkg-reconfigure postfix
   ```

4. **Optional: Setup desktop notifications**:
   ```bash
   sudo apt install libnotify-bin
   ```

### Running the Application

```bash
./p.sh
```

## 📖 Usage

### First Time Setup
1. Run the script and select **"0. Sign Up"**
2. Enter a unique username and secure password
3. Confirm password to create your account
4. Login with your new credentials

### Daily Monitoring
1. **Login** with existing credentials
2. **Navigate** through dashboard options 1-6 to view system information:
   - `1` - Display CPU Usage (overall and per-core)
   - `2` - Display Memory Usage (RAM and swap)
   - `3` - Display Disk Space Usage (all filesystems)
   - `4` - Display Top Processes (CPU and memory consumers)
   - `5` - Display Network Statistics (interfaces and IPs)
   - `6` - Display User Activities (logged-in users and processes)
   - `7` - Log Out
3. **Background logging** and alerting runs automatically
4. **Logout** using option 7 when finished

### Sample Output

```
CPU Usage (User: john):
 Overall: 23% user, 5% system, 72% idle
Overall CPU: [###########-----------------------------------------] 23%
 Core 0: 25% user, 7% system, 68% idle
 Core 1: 21% user, 3% system, 76% idle
```

## ⚙️ Configuration

The system uses configurable parameters that can be modified in the script:

```bash
# Monitoring Configuration
LOG_INTERVAL=60          # Background logging interval (seconds)
CPU_THRESHOLD=85         # CPU usage alert threshold (percentage)
DISK_THRESHOLD=90        # Disk usage alert threshold (percentage)
SUSTAINED_CHECKS=3       # Consecutive threshold breaches required
CHECK_INTERVAL=10        # Interval between threshold checks (seconds)
EMAIL_RECIPIENT="your@email.com"  # Administrator email address

# File Locations
LOG_FILE="$HOME/system_monitor.log"  # System monitoring log file
USERS_FILE="$HOME/users.txt"         # User credentials storage file
```

## 📁 File Structure

```
system-health-dashboard/
├── p.sh                    # Main application script
├── README.md              # This file
├── system_monitor.log     # Generated log file (created at runtime)
└── users.txt             # User credentials file (created at runtime)
```

## 🔒 Security Features

- **Password Protection**: SHA-256 hashing ensures passwords are never stored in plain text
- **Session Management**: User authentication prevents unauthorized access
- **File Permissions**: Credential and log files are created with restricted permissions
- **No Root Required**: Operates with standard user privileges
- **Local Operation**: No network listening or remote access capabilities

## 📊 Performance Characteristics

- **Resource Usage**: Minimal CPU overhead, 1-2 MB memory footprint
- **Response Times**: Instantaneous menu navigation, 1-3 seconds for metric collection
- **Scalability**: Suitable for 1-16 CPU cores, up to 64 GB RAM monitoring
- **Log Growth**: Approximately 1 KB per monitoring cycle

## 🛠️ System Requirements

- **Operating System**: Unix/Linux (tested on Ubuntu, CentOS, Debian)
- **Shell**: Bash 4.0 or later
- **Memory**: Minimum 10 MB free RAM
- **Disk Space**: 50 MB for logs and operation
- **Utilities**: Standard Unix utilities (top, free, df, ps, etc.)

## 📝 Administrative Tasks

### View Historical Data
```bash
# Check system monitoring logs
cat $HOME/system_monitor.log
```

### Reset User Data
Use the built-in reset function (option 2 in pre-login menu) to clear all user accounts.

### Monitor Email Alerts
Configure your email client to receive threshold breach notifications at the specified email address.

## 🐛 Troubleshooting

### Common Issues

**Script won't execute**:
```bash
chmod +x p.sh
```

**Missing utilities error**:
```bash
# Install missing packages (Ubuntu/Debian)
sudo apt install sysstat procps coreutils
```

**Email notifications not working**:
```bash
# Test mail configuration
echo "Test message" | mail -s "Test Subject" your@email.com
```

**Permission denied for log files**:
```bash
# Check file permissions
ls -la $HOME/system_monitor.log
ls -la $HOME/users.txt
```

## 🚧 Known Limitations

- **Single User Sessions**: No concurrent multi-user access
- **Command-line Only**: No graphical user interface
- **Local Monitoring**: No remote system monitoring capabilities
- **Basic Analytics**: No predictive analysis or machine learning
- **No Database**: Local file-based storage only

## 🔮 Future Enhancements

- **Configuration Management**: External configuration files for settings
- **Enhanced Monitoring**: Network traffic, temperature, and service monitoring
- **Multi-user Support**: Concurrent access with role-based permissions
- **Advanced Analytics**: Historical trend analysis and predictive capabilities
- **Reporting**: Export data in multiple formats (CSV, JSON, XML)
- **Web Interface**: Browser-based dashboard option

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built using standard Unix utilities and Bash scripting
- Inspired by traditional system monitoring tools like `top`, `htop`, and `ps`
- Thanks to the open-source community for continuous inspiration

## 📞 Support

If you encounter any issues or have questions:
- Open an issue on GitHub
- Check the troubleshooting section above
- Review the system requirements and dependencies

---

**Author**: Siddhartho Sen  
**Course**: SE233 - Operating System & System Programming Lab  
**Institution**: DIU  
**Year**: 2025
