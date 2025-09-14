#!/usr/bin/env bash

# Script để setup Jenkins local

set -euo pipefail

echo "=== Setup Jenkins Local ==="
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Java is installed
check_java() {
    print_status "Kiểm tra Java installation..."
    if ! command -v java &> /dev/null; then
        print_error "Java chưa được cài đặt. Vui lòng cài đặt Java 11 hoặc 17 trước."
        echo ""
        echo "Cài đặt Java trên macOS:"
        echo "brew install openjdk@17"
        echo ""
        echo "Cài đặt Java trên Ubuntu:"
        echo "sudo apt update && sudo apt install openjdk-17-jdk"
        exit 1
    fi
    
    java_version=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
    if [ "$java_version" -lt 11 ]; then
        print_warning "Java version $java_version quá cũ. Khuyến nghị Java 11 hoặc 17"
    fi
    
    print_success "Java đã sẵn sàng"
}

# Download and install Jenkins
install_jenkins() {
    print_status "Tải và cài đặt Jenkins..."
    
    # Create jenkins directory
    mkdir -p ~/jenkins
    cd ~/jenkins
    
    # Download Jenkins WAR file
    if [ ! -f "jenkins.war" ]; then
        print_status "Tải Jenkins WAR file..."
        curl -L -o jenkins.war "https://get.jenkins.io/war-stable/latest/jenkins.war"
        print_success "Jenkins WAR file đã được tải"
    else
        print_success "Jenkins WAR file đã tồn tại"
    fi
}

# Start Jenkins
start_jenkins() {
    print_status "Khởi động Jenkins..."
    
    cd ~/jenkins
    
    # Kill existing Jenkins process if any
    pkill -f jenkins.war || true
    
    # Start Jenkins in background
    nohup java -jar jenkins.war --httpPort=8080 > jenkins.log 2>&1 &
    
    print_success "Jenkins đang khởi động..."
    print_status "Chờ Jenkins sẵn sàng..."
    
    # Wait for Jenkins to be ready
    timeout=300
    while [ $timeout -gt 0 ]; do
        if curl -s http://localhost:8080 > /dev/null 2>&1; then
            print_success "Jenkins đã sẵn sàng!"
            break
        fi
        sleep 5
        timeout=$((timeout - 5))
    done
    
    if [ $timeout -le 0 ]; then
        print_error "Jenkins không khởi động được sau 5 phút"
        exit 1
    fi
}

# Get initial password
get_initial_password() {
    print_status "Lấy Jenkins initial password..."
    
    # Wait a bit for Jenkins to fully start
    sleep 10
    
    if [ -f ~/jenkins/secrets/initialAdminPassword ]; then
        password=$(cat ~/jenkins/secrets/initialAdminPassword)
        print_success "Jenkins initial password: $password"
        echo ""
        echo "🔑 Jenkins Setup:"
        echo "   URL: http://localhost:8080"
        echo "   Password: $password"
        echo ""
    else
        print_warning "Không tìm thấy initial password. Vui lòng kiểm tra Jenkins logs"
    fi
}

# Show status
show_status() {
    print_status "Trạng thái Jenkins:"
    echo ""
    
    if pgrep -f jenkins.war > /dev/null; then
        print_success "Jenkins đang chạy"
        echo "   PID: $(pgrep -f jenkins.war)"
        echo "   URL: http://localhost:8080"
    else
        print_warning "Jenkins không chạy"
    fi
    
    echo ""
    print_status "Logs: ~/jenkins/jenkins.log"
    print_status "Home: ~/jenkins"
}

# Stop Jenkins
stop_jenkins() {
    print_status "Dừng Jenkins..."
    pkill -f jenkins.war || true
    print_success "Jenkins đã được dừng"
}

# Main function
main() {
    echo "🚀 Bắt đầu setup Jenkins local..."
    echo ""
    
    # Check prerequisites
    check_java
    
    # Install Jenkins
    install_jenkins
    
    # Start Jenkins
    start_jenkins
    
    # Get initial password
    get_initial_password
    
    # Show status
    show_status
    
    echo ""
    print_success "🎉 Jenkins local setup hoàn thành!"
    echo ""
    echo "📋 Bước tiếp theo:"
    echo "1. Truy cập: http://localhost:8080"
    echo "2. Nhập initial password"
    echo "3. Cài đặt suggested plugins"
    echo "4. Tạo admin user"
    echo "5. Cấu hình credentials (xem JENKINS_SETUP.md)"
    echo "6. Tạo pipeline job"
    echo ""
    echo "📚 Xem hướng dẫn chi tiết: JENKINS_SETUP.md"
}

# Handle script arguments
case "${1:-}" in
    "start")
        start_jenkins
        get_initial_password
        show_status
        ;;
    "stop")
        stop_jenkins
        ;;
    "restart")
        stop_jenkins
        sleep 2
        start_jenkins
        get_initial_password
        show_status
        ;;
    "status")
        show_status
        ;;
    "logs")
        tail -f ~/jenkins/jenkins.log
        ;;
    *)
        main
        ;;
esac
