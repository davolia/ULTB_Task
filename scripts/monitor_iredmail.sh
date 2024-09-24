#!/bin/bash

# Telegram bot API token and chat ID for sending notifications
TELEGRAM_TOKEN="8155906710:AAF9mCPciOo2Zk7OQBYsNnUKjcAeKHdrTbI"
TELEGRAM_CHAT_ID="377592187"

# Threshold values
DISK_USAGE_THRESHOLD=90  # Disk usage percentage threshold
MAIL_QUEUE_THRESHOLD=100  # Number of mails in queue threshold

# iRedMail Docker container name
CONTAINER_NAME="iredmail-container"

# Directories to monitor disk usage
CRITICAL_DIRS=("/var/mail" "/var/log")

# Function to send a notification to Telegram
send_telegram_alert() {
    local message=$1
    curl -s -X POST "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
        -d chat_id="${TELEGRAM_CHAT_ID}" \
        -d text="${message}" >/dev/null
}

# Function to check disk usage of critical directories
check_disk_usage() {
    for dir in "${CRITICAL_DIRS[@]}"; do
        usage=$(docker exec $CONTAINER_NAME df -h "$dir" | awk 'NR==2 {print $5}' | sed 's/%//')
        if [ "$usage" -gt "$DISK_USAGE_THRESHOLD" ]; then
            send_telegram_alert "Alert: Disk usage in $dir is at ${usage}% on container ${CONTAINER_NAME}!"
        fi
    done
}

# Function to check the size of the mail queue
check_mail_queue() {
    mail_queue_size=$(docker exec $CONTAINER_NAME postqueue -p | grep -c "^[A-F0-9]")
    if [ "$mail_queue_size" -gt "$MAIL_QUEUE_THRESHOLD" ]; then
        send_telegram_alert "Alert: Mail queue size is ${mail_queue_size} on container ${CONTAINER_NAME}, exceeding the threshold of ${MAIL_QUEUE_THRESHOLD}!"
    fi
}

# Function to check if mail services are running
check_services() {
    services=("postfix" "dovecot")
    for service in "${services[@]}"; do
        status=$(docker exec $CONTAINER_NAME ps aux | grep "active (running)")
        if [ -z "$status" ]; then
            send_telegram_alert "Alert: ${service} is not running on container ${CONTAINER_NAME}!"
        fi
    done
}

# Main monitoring function
monitor_mail_server() {
    check_disk_usage
    check_mail_queue
    check_services
}

# Run the monitor function
monitor_mail_server
