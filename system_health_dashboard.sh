#!/bin/bash

# System Monitoring and Health Dashboard with Authentication and Advanced Features

# Configuration
LOG_FILE="$HOME/system_monitor.log"
LOG_INTERVAL=60  # Log every 60 seconds
EMAIL_RECIPIENT="siddharthosen09@gmail.com"  # Replace with actual email
CPU_THRESHOLD=85  # CPU usage threshold (%)
DISK_THRESHOLD=90  # Disk usage threshold (%)
SUSTAINED_CHECKS=3  # Number of checks for sustained threshold breach
CHECK_INTERVAL=10  # Interval for threshold checks (seconds)
USERS_FILE="$HOME/users.txt"  # File to store user credentials

# Initialize threshold breach counters
cpu_breach_count=0
disk_breach_count=0
LOGGED_IN=false
CURRENT_USER=""

# Function to hash password
hash_password() {
    local password="$1"
    echo -n "$password" | sha256sum | awk '{print $1}'
}

# Function to check if user exists
user_exists() {
    local username="$1"
    grep -q "^$username:" "$USERS_FILE" 2>/dev/null
}

# Function to sign up
signup() {
    clear
    echo "Sign Up"
    echo "-------"
    echo -n "Enter username: "
    read new_username
    if user_exists "$new_username"; then
        echo "Age theika ache Name!"
        echo "continue korte Enter chapo..."
        read
        return
    fi
    echo -n "password dao: "
    read -s new_password
    echo ""
    echo -n "Buke hat rekhe password dao: "
    read -s confirm_password
    echo ""
    if [ "$new_password" != "$confirm_password" ]; then
        echo "Password Mele Nai! Ei brain diya software engineering porbi heh!"
        echo "agaite chaile Enter chap..."
        read
        return
    fi
    echo "$new_username:$(hash_password "$new_password")" >> "$USERS_FILE"
    echo "parcho tahole oboseshe"
    echo "Enter chepe agaiya jao..."
    read
}

# Function to reset user data
reset() {
    clear
    echo "Reset User Data"
    echo "--------------"
    echo "This will delete all user accounts and reset the system."
    echo -n "sure? Vejal nai tw? (y/n): "
    read confirm
    if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
        if [ -f "$USERS_FILE" ]; then
            rm "$USERS_FILE" 2>/dev/null
            echo "successfully muicha disi shob"
        else
            echo "No user data to reset."
        fi
        echo "Press Enter to continue..."
        read
    else
        echo "Reset cancelled. Hehe jantam."
        echo "Press Enter to continue..."
        read
    fi
}

# Function to log in
login() {
    clear
    echo "Log In"
    echo "------"
    echo -n "Enter username: "
    read username
    if ! user_exists "$username"; then
        echo "painai khatay nam!"
        echo "Press Enter to continue..."
        read
        return
    fi
    echo -n "password dao: "
    read -s password
    echo ""
    stored_hash=$(grep "^$username:" "$USERS_FILE" | cut -d: -f2)
    if [ "$(hash_password "$password")" = "$stored_hash" ]; then
        LOGGED_IN=true
        CURRENT_USER="$username"
        echo "System e Dhuika Porsi Monu! Welcome, $username!"
        echo "Enter chaipa agaiya jao..."
        read
    else
        echo "Abar vul password!"
        echo "Press Enter to continue..."
        read
    fi
}

# Function to log stats to file
log_stats() {
    {
        echo "===== $(date '+%Y-%m-%d %H:%M:%S') - User: $CURRENT_USER ====="
        cpu_usage >> "$LOG_FILE"
        echo "" >> "$LOG_FILE"
        memory_usage >> "$LOG_FILE"
        echo "" >> "$LOG_FILE"
        disk_usage >> "$LOG_FILE"
        echo "" >> "$LOG_FILE"
        top_processes >> "$LOG_FILE"
        echo "" >> "$LOG_FILE"
        network_stats >> "$LOG_FILE"
        echo "" >> "$LOG_FILE"
        users_info >> "$LOG_FILE"
        echo "" >> "$LOG_FILE"
    } >> "$LOG_FILE" 2>/dev/null
}

# Function to send notifications (email or desktop)
send_notification() {
    local message="$1"
    message_escaped=$(printf "%q" "$message")
    if command -v notify-send >/dev/null 2>&1; then
        notify-send "System Monitor Alert - $CURRENT_USER" "$message_escaped" 2>/dev/null
    fi
    if command -v mail >/dev/null 2>&1; then
        echo "$message" | mail -s "System Monitor Alert - $CURRENT_USER" "$EMAIL_RECIPIENT" 2>/dev/null
    fi
}

# Function to check thresholds and send notifications
check_thresholds() {
    local cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
    if [ "$cpu_usage" -gt "$CPU_THRESHOLD" ]; then
        ((cpu_breach_count++))
        if [ "$cpu_breach_count" -ge "$SUSTAINED_CHECKS" ]; then
            send_notification "CPU usage exceeded $CPU_THRESHOLD% for $((CHECK_INTERVAL * SUSTAINED_CHECKS)) seconds ($cpu_usage%)"
            cpu_breach_count=0
        fi
    else
        cpu_breach_count=0
    fi
    local disk_usage=$(df -h | grep -vE '^tmpfs|devtmpfs|overlay' | awk '$NF=="/"{print $5}' | cut -d% -f1)
    if [ "$disk_usage" -gt "$DISK_THRESHOLD" ]; then
        ((disk_breach_count++))
        if [ "$disk_breach_count" -ge "$SUSTAINED_CHECKS" ]; then
            send_notification "Disk usage on / exceeded $DISK_THRESHOLD% for $((CHECK_INTERVAL * SUSTAINED_CHECKS)) seconds ($disk_usage%)"
            disk_breach_count=0
        fi
    else
        disk_breach_count=0
    fi
}

# Function to generate simple text-based graph
text_graph() {
    local value=$1
    local max=$2
    local label=$3
    local width=50
    local filled=$((value * width / max))
    local empty=$((width - filled))
    local graph=""
    for ((i=0; i<filled; i++)); do graph+="#"; done
    for ((i=0; i<empty; i++)); do graph+="-"; done
    printf "%s: [%s] %d%%\n" "$label" "$graph" "$value"
}

# Function to display CPU usage (overall and per core)
cpu_usage() {
    echo "CPU Usage (User: $CURRENT_USER):"
    local overall=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d. -f1)
    echo "  Overall: $overall% user, $(top -bn1 | grep "Cpu(s)" | awk '{print $4}')% system, $(top -bn1 | grep "Cpu(s)" | awk '{print $8}')% idle"
    text_graph "$overall" 100 "Overall CPU"
    mpstat -P ALL 1 1 | awk '/Average:/ && $2 ~ /[0-9]+/ {print "  Core " $2 ": " $3 "% user, " $5 "% system, " $12 "% idle"; printf "  Core " $2 " Graph: "; system("echo " $3 " | awk \"{v=int($1); for(i=0;i<v/2;i++) printf \\\"#\\\"; for(i=v/2;i<50;i++) printf \\\"-\\\"; printf \" \" v \"%%\\n\"")}'
}

# Function to display memory usage
memory_usage() {
    echo "Memory Usage (User: $CURRENT_USER):"
    local total_mem=$(free -m | awk '/Mem:/ {print $2}')
    local used_mem=$(free -m | awk '/Mem:/ {print $3}')
    local used_swap=$(free -m | awk '/Swap:/ {print $3}')
    free -h | awk '/Mem:/ {print "  RAM: Total: " $2 ", Used: " $3 ", Free: " $4}'
    free -h | awk '/Swap:/ {print "  Swap: Total: " $2 ", Used: " $3 ", Free: " $4}'
    text_graph "$((used_mem * 100 / total_mem))" 100 "RAM Usage"
    text_graph "$((used_swap * 100 / total_mem))" 100 "Swap Usage"
}

# Function to display disk space for all mounted filesystems
disk_usage() {
    echo "Disk Space Usage (User: $CURRENT_USER):"
    df -h | grep -vE '^tmpfs|devtmpfs|overlay' | awk 'NR>1 {print "  " $6 ": Total: " $2 ", Used: " $3 ", Free: " $4 ", Use%: " $5; system("echo " $5 " | cut -d% -f1 | awk \"{v=int($1); for(i=0;i<v/2;i++) printf \\\"#\\\"; for(i=v/2;i<50;i++) printf \\\"-\\\"; printf \" \" v \"%%\\n\"")}'
}

# Function to display top 5 processes by CPU and memory
top_processes() {
    echo "Top 5 Processes by CPU (User: $CURRENT_USER):"
    ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6 | tail -n 5 | awk '{print "  PID: " $1 ", Command: " $2 ", CPU: " $3 "%"}'
    echo ""
    echo "Top 5 Processes by Memory (User: $CURRENT_USER):"
    ps -eo pid,comm,%mem --sort=-%mem | head -n 6 | tail -n 5 | awk '{print "  PID: " $1 ", Command: " $2 ", Memory: " $3 "%"}'
}

# Function to display network statistics
network_stats() {
    echo "Network Statistics (User: $CURRENT_USER):"
    ip addr show | grep "inet " | grep -v "127.0.0.1" | awk '{print "  IP: " $2}'
    interfaces=$(ip link | awk -F: '$0 !~ "lo|docker|br-|veth|virbr" {print $2}' | awk '{$1=$1};1')
    for iface in $interfaces; do
        if [ -n "$iface" ]; then
            stats=$(cat /proc/net/dev | grep "$iface" | awk '{print "  " $1 " RX: " $2 " bytes, TX: " $10 " bytes"}')
            [ -n "$stats" ] && echo "$stats"
        fi
    done
}

# Function to display logged-in users and their activities
users_info() {
    echo "Logged-in Users and Activities (User: $CURRENT_USER):"
    who | awk '{print "  User: " $1 ", Terminal: " $2 ", Login Time: " $3 " " $4}'
    echo "  User Activities (Running Processes):"
    for user in $(who | awk '{print $1}' | sort -u); do
        echo "  Processes for $user:"
        ps -u "$user" -o pid,comm,%cpu,%mem | awk 'NR>1 {print "    PID: " $1 ", Command: " $2 ", CPU: " $3 "%, Memory: " $4 "%"}'
    done
}

# Function to display the pre-login menu
show_prelogin_menu() {
    clear
    echo "System Health Dashboard - Authentication"
    echo "---------------------------------------"
    echo "0. Sign Up"
    echo "1. Log In"
    echo "2. Reset User Data"
    echo "3. Exit"
    echo ""
    echo -n "Enter your choice [0-3]: "
}

# Function to display the post-login menu
show_dashboard_menu() {
    clear
    echo "System Health Dashboard - Welcome, $CURRENT_USER"
    echo "---------------------------------------"
    echo "1. Display CPU Usage"
    echo "2. Display Memory Usage"
    echo "3. Display Disk Space Usage"
    echo "4. Display Top Processes"
    echo "5. Display Network Statistics"
    echo "6. Display Logged-in Users and Activities"
    echo "7. Log Out"
    echo ""
    echo -n "Enter your choice [1-7]: "
}

# Background process for logging and threshold checks
background_tasks() {
    while $LOGGED_IN; do
        log_stats
        check_thresholds
        sleep "$CHECK_INTERVAL"
    done
}

# Start background tasks
background_tasks &

# Main loop for pre-login interface
while ! $LOGGED_IN; do
    show_prelogin_menu
    read choice
    case $choice in
        0)
            signup
            ;;
        1)
            login
            if $LOGGED_IN; then
                background_tasks &  # Restart background tasks after login
            fi
            ;;
        2)
            reset
            ;;
        3)
            clear
            echo "Exiting System Health Dashboard"
            kill %1 2>/dev/null
            exit 0
            ;;
        *)
            clear
            echo "Invalid choice! Please select a number between 0 and 3."
            echo "Press Enter to continue..."
            read
            ;;
    esac
done

# Main loop for dashboard interface after login
while $LOGGED_IN; do
    show_dashboard_menu
    read choice
    case $choice in
        1)
            clear
            cpu_usage
            echo ""
            echo "Press Enter to return to menu..."
            read
            ;;
        2)
            clear
            memory_usage
            echo ""
            echo "Press Enter to return to menu..."
            read
            ;;
        3)
            clear
            disk_usage
            echo ""
            echo "Press Enter to return to menu..."
            read
            ;;
        4)
            clear
            top_processes
            echo ""
            echo "Press Enter to return to menu..."
            read
            ;;
        5)
            clear
            network_stats
            echo ""
            echo "Press Enter to return to menu..."
            read
            ;;
        6)
            clear
            users_info
            echo ""
            echo "Press Enter to return to menu..."
            read
            ;;
        7)
            clear
            echo "Chole gelum, Tata, $CURRENT_USER. Goodbye!"
            LOGGED_IN=false
            kill %1 2>/dev/null
            echo "Press Enter to continue..."
            read
            ;;
        *)
            clear
            echo "Ontoto eikhane vul koiren na Vai! 1 ar 7 er moddhe jekono ekta number den."
            echo "Press Enter to continue..."
            read
            ;;
    esac
done
