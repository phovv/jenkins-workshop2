#!/usr/bin/env bash

# Script để setup git repository và push lên GitHub

echo "=== Workshop 2 - Git Setup Script ==="
echo ""

# Kiểm tra xem đã có git repo chưa
if [ -d ".git" ]; then
    echo "Git repository đã tồn tại."
    echo "Bạn có muốn tiếp tục? (y/n)"
    read -r response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Hủy bỏ."
        exit 1
    fi
else
    echo "Khởi tạo git repository..."
    git init
fi

# Thêm remote origin
echo "Thêm remote origin..."
echo "Chọn remote repository:"
echo "1. GitHub (git@github.com:phovv/phovv-workshop2.git) - Mặc định"
echo "2. GitLab Docker (http://localhost:8090/root/phovv-workshop2.git)"
read -p "Nhập lựa chọn (1 hoặc 2, Enter = 1): " choice

case ${choice:-1} in
    1)
        git remote add origin git@github.com:phovv/phovv-workshop2.git
        echo "✅ Đã thêm GitHub remote"
        ;;
    2)
        git remote add origin http://localhost:8090/root/phovv-workshop2.git
        echo "✅ Đã thêm GitLab Docker remote"
        ;;
    *)
        echo "❌ Lựa chọn không hợp lệ"
        exit 1
        ;;
esac

# Thêm tất cả files
echo "Thêm files vào git..."
git add .

# Commit đầu tiên
echo "Tạo commit đầu tiên..."
git commit -m "Initial commit - Workshop 2 CI/CD setup"

# Push lên main branch
echo "Push lên GitHub..."
git branch -M main
git push -u origin main

echo ""
echo "✅ Hoàn thành! Repository đã được push lên GitHub."
echo "URL: https://github.com/phovv/phovv-workshop2"
echo ""
echo "Bước tiếp theo:"
echo "1. Cấu hình Jenkins credentials (xem JENKINS_SETUP.md)"
echo "2. Tạo pipeline job trong Jenkins"
echo "3. Test pipeline với các script trong scripts/"
