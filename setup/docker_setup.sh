#!/usr/bin/env bash

# Script để setup và chạy Workshop 2 với Docker

set -euo pipefail

echo "=== Workshop 2 - Docker Setup Script ==="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Check if Docker is installed
check_docker() {
    print_status "Kiểm tra Docker installation..."
    if ! command -v docker &> /dev/null; then
        print_error "Docker chưa được cài đặt. Vui lòng cài đặt Docker trước."
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose chưa được cài đặt. Vui lòng cài đặt Docker Compose trước."
        exit 1
    fi
    
    print_success "Docker và Docker Compose đã sẵn sàng"
}

# Start Docker services
start_services() {
    print_status "Khởi động Docker services..."
    
    # Di chuyển vào thư mục chính
    cd /Users/phovv/jenkins_data
    
    # Khởi động services
    docker-compose up -d
    
    print_success "Docker services đã được khởi động"
}

# Wait for services to be ready
wait_for_services() {
    print_status "Chờ các services khởi động..."
    
    # Wait for Jenkins
    print_status "Chờ Jenkins khởi động..."
    timeout=300
    while [ $timeout -gt 0 ]; do
        if curl -s http://localhost:8080 > /dev/null 2>&1; then
            print_success "Jenkins đã sẵn sàng"
            break
        fi
        sleep 5
        timeout=$((timeout - 5))
    done
    
    if [ $timeout -le 0 ]; then
        print_warning "Jenkins chưa sẵn sàng sau 5 phút"
    fi
    
    # Wait for GitLab
    print_status "Chờ GitLab khởi động..."
    timeout=600
    while [ $timeout -gt 0 ]; do
        if curl -s http://localhost:8090 > /dev/null 2>&1; then
            print_success "GitLab đã sẵn sàng"
            break
        fi
        sleep 10
        timeout=$((timeout - 10))
    done
    
    if [ $timeout -le 0 ]; then
        print_warning "GitLab chưa sẵn sàng sau 10 phút"
    fi
}

# Get Jenkins initial password
get_jenkins_password() {
    print_status "Lấy Jenkins initial password..."
    
    # Wait a bit for Jenkins to fully start
    sleep 10
    
    password=$(docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null || echo "Password not available yet")
    
    if [ "$password" != "Password not available yet" ]; then
        print_success "Jenkins initial password: $password"
        echo ""
        echo "🔑 Jenkins Setup:"
        echo "   URL: http://localhost:8080"
        echo "   Password: $password"
        echo ""
    else
        print_warning "Jenkins password chưa sẵn sàng. Vui lòng thử lại sau."
    fi
}

# Get GitLab initial password
get_gitlab_password() {
    print_status "Lấy GitLab initial password..."
    
    # Wait for GitLab to be ready
    sleep 30
    
    password=$(docker exec git-server cat /etc/gitlab/initial_root_password 2>/dev/null | grep "Password:" | cut -d' ' -f2 || echo "Password not available yet")
    
    if [ "$password" != "Password not available yet" ]; then
        print_success "GitLab initial password: $password"
        echo ""
        echo "🔑 GitLab Setup:"
        echo "   URL: http://localhost:8090"
        echo "   Username: root"
        echo "   Password: $password"
        echo ""
    else
        print_warning "GitLab password chưa sẵn sàng. Vui lòng thử lại sau."
    fi
}

# Show service status
show_status() {
    print_status "Trạng thái các services:"
    echo ""
    
    # Docker containers status
    docker-compose ps
    
    echo ""
    print_status "URLs để truy cập:"
    echo "   Jenkins: http://localhost:8080"
    echo "   GitLab:  http://localhost:8090"
    echo "   Web:     http://localhost"
    echo ""
}

# Setup Git repository
setup_git_repo() {
    print_status "Setup Git repository..."
    
    cd /Users/phovv/jenkins_data/workshop2-project
    
    # Initialize git if not already done
    if [ ! -d ".git" ]; then
        git init
        git remote add origin http://localhost:8090/root/phovv-workshop2.git
    fi
    
    # Add and commit files
    git add .
    git commit -m "Initial commit - Workshop 2 Docker setup" || true
    
    print_success "Git repository đã được setup"
}

# Main function
main() {
    echo "🚀 Bắt đầu setup Workshop 2 với Docker..."
    echo ""
    
    # Check prerequisites
    check_docker
    
    # Start services
    start_services
    
    # Wait for services
    wait_for_services
    
    # Get passwords
    get_jenkins_password
    get_gitlab_password
    
    # Show status
    show_status
    
    # Setup git repo
    setup_git_repo
    
    echo ""
    print_success "🎉 Setup hoàn thành!"
    echo ""
    echo "📋 Bước tiếp theo:"
    echo "1. Truy cập Jenkins: http://localhost:8080"
    echo "2. Truy cập GitLab: http://localhost:8090"
    echo "3. Cấu hình Jenkins credentials (xem DOCKER_GUIDE.md)"
    echo "4. Tạo pipeline job"
    echo "5. Test pipeline"
    echo ""
    echo "📚 Xem hướng dẫn chi tiết: DOCKER_GUIDE.md"
}

# Handle script arguments
case "${1:-}" in
    "start")
        start_services
        wait_for_services
        show_status
        ;;
    "stop")
        print_status "Dừng Docker services..."
        cd /Users/phovv/jenkins_data
        docker-compose down
        print_success "Docker services đã được dừng"
        ;;
    "restart")
        print_status "Restart Docker services..."
        cd /Users/phovv/jenkins_data
        docker-compose restart
        print_success "Docker services đã được restart"
        ;;
    "status")
        show_status
        ;;
    "logs")
        cd /Users/phovv/jenkins_data
        docker-compose logs -f
        ;;
    *)
        main
        ;;
esac
