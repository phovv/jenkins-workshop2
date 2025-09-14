#!/usr/bin/env bash

# Script quick start cho Workshop 2

echo "🚀 Workshop 2 - Quick Start"
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Chọn môi trường chạy:${NC}"
echo "1. GitHub + Jenkins local (Khuyến nghị)"
echo "2. GitHub + Jenkins thật"
echo "3. Docker (dễ setup nhưng cần nhiều tài nguyên)"
echo ""

read -p "Nhập lựa chọn (1, 2 hoặc 3, Enter = 1): " choice

case ${choice:-1} in
    1)
        echo -e "${GREEN}🚀 Setup GitHub + Jenkins local...${NC}"
        ./scripts/setup_jenkins_local.sh
        ./scripts/setup_git.sh
        
        echo ""
        echo -e "${YELLOW}📋 Bước tiếp theo:${NC}"
        echo "1. Truy cập Jenkins: http://localhost:8080"
        echo "2. Tạo repository trên GitHub: https://github.com/phovv/phovv-workshop2"
        echo "3. Cấu hình Jenkins credentials"
        echo "4. Tạo pipeline job"
        echo "5. Xem hướng dẫn: JENKINS_SETUP.md"
        ;;
    2)
        echo -e "${GREEN}🌐 Setup GitHub + Jenkins thật...${NC}"
        ./scripts/setup_git.sh
        
        echo ""
        echo -e "${YELLOW}📋 Bước tiếp theo:${NC}"
        echo "1. Tạo repository trên GitHub: https://github.com/phovv/phovv-workshop2"
        echo "2. Cấu hình Jenkins credentials"
        echo "3. Tạo pipeline job"
        echo "4. Xem hướng dẫn: JENKINS_SETUP.md"
        ;;
    3)
        echo -e "${GREEN}🐳 Khởi động môi trường Docker...${NC}"
        ./scripts/docker_setup.sh
        
        echo ""
        echo -e "${YELLOW}📋 Bước tiếp theo:${NC}"
        echo "1. Truy cập Jenkins: http://localhost:8080"
        echo "2. Truy cập GitLab: http://localhost:8090"
        echo "3. Xem hướng dẫn chi tiết: DOCKER_GUIDE.md"
        ;;
    *)
        echo "❌ Lựa chọn không hợp lệ"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}✅ Hoàn thành!${NC}"
echo "📚 Xem các file hướng dẫn:"
echo "   - README.md - Tổng quan"
echo "   - DOCKER_GUIDE.md - Hướng dẫn Docker"
echo "   - JENKINS_SETUP.md - Cấu hình Jenkins"
echo "   - DEPLOYMENT_GUIDE.md - Hướng dẫn deploy"
echo "   - CHECKLIST.md - Checklist nộp bài"
