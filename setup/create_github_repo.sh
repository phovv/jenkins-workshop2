#!/usr/bin/env bash

# Script để tạo GitHub repository

echo "=== Tạo GitHub Repository ==="
echo ""

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Hướng dẫn tạo GitHub repository:${NC}"
echo ""
echo "1. Truy cập: https://github.com/phovv"
echo "2. Click 'New repository' (nút xanh lá)"
echo "3. Repository name: phovv-workshop2"
echo "4. Description: Workshop 2 - CI/CD với Jenkins"
echo "5. Chọn 'Private'"
echo "6. KHÔNG check 'Add a README file'"
echo "7. KHÔNG check 'Add .gitignore'"
echo "8. KHÔNG check 'Choose a license'"
echo "9. Click 'Create repository'"
echo ""

read -p "Đã tạo repository chưa? (y/n): " created

if [[ "$created" =~ ^[Yy]$ ]]; then
    echo -e "${GREEN}✅ Tuyệt vời!${NC}"
    echo ""
    echo -e "${YELLOW}Bước tiếp theo:${NC}"
    echo "1. Chạy: ./scripts/setup_git.sh"
    echo "2. Push code lên GitHub"
    echo "3. Cấu hình Jenkins"
    echo ""
else
    echo -e "${YELLOW}⚠️  Vui lòng tạo repository trước khi tiếp tục${NC}"
    echo ""
    echo "Sau khi tạo xong, chạy lại script này:"
    echo "./scripts/create_github_repo.sh"
fi
