# Hướng dẫn cấu hình Jenkins cho Workshop 2

## 🚀 Môi trường GitHub + Jenkins local (Khuyến nghị)

### 1. Setup Jenkins local
```bash
cd /Users/phovv/jenkins_data/workshop2-project
./scripts/setup_jenkins_local.sh
```

### 2. Tạo GitHub repository
1. Vào https://github.com/phovv
2. **New repository** → **phovv-workshop2**
3. **Private** repository
4. **Create repository**

### 3. Setup local repository
```bash
./scripts/setup_git.sh
```

### 4. Cấu hình Jenkins
- Truy cập: http://localhost:8080
- Nhập initial password (hiển thị trong terminal)
- Cài đặt suggested plugins
- Tạo admin user
- Tạo credentials theo hướng dẫn bên dưới

---

## 🌐 Môi trường GitHub + Jenkins thật

---

## 🐳 Môi trường Docker (Optional)

### 1. Khởi động môi trường
```bash
cd /Users/phovv/jenkins_data/workshop2-project
./scripts/docker_setup.sh
```

### 2. Truy cập Jenkins
- URL: http://localhost:8080
- Lấy password: `docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword`

### 3. Cấu hình GitLab
- URL: http://localhost:8090
- Username: `root`
- Password: `docker exec git-server cat /etc/gitlab/initial_root_password`

---

## 1. Tạo Credentials trong Jenkins

Vào **Manage Jenkins → Credentials → System → Global credentials (unrestricted) → Add Credentials**

### 1.1. Git SSH Key
- **Kind**: SSH Username with private key
- **ID**: `git-ssh-key`
- **Username**: `git`
- **Private Key**: Paste private key để checkout repo từ GitHub

### 1.2. Firebase Token
- **Kind**: Secret text
- **ID**: `firebase-token`
- **Secret**: Firebase token để deploy (lấy từ `firebase login:ci`)

### 1.3. Firebase ADC (Optional)
- **Kind**: Secret file
- **ID**: `firebase-adc`
- **File**: Upload file JSON ADC từ Firebase Console

### 1.4. SSH Deploy Key
- **Kind**: SSH Username with private key
- **ID**: `ssh-deploy-key`
- **Username**: `newbie`
- **Private Key**: Private key để SSH vào remote server

### 1.5. Slack Token
- **Kind**: Secret text
- **ID**: `slack-token-ventura`
- **Secret**: ``

## 2. Tạo Pipeline Job

1. **New Item** → **Pipeline**
2. **Pipeline name**: `workshop2-pipeline`
3. **Pipeline** → **Definition**: Pipeline script from SCM
4. **SCM**: Git
5. **Repository URL**: `git@github.com:phovv/phovv-workshop2.git`
6. **Credentials**: Chọn `git-ssh-key`
7. **Branch**: `*/main`
8. **Script Path**: `Jenkinsfile`

## 3. Cấu hình Webhook (Optional)

1. Vào GitHub repo → **Settings** → **Webhooks**
2. **Add webhook**
3. **Payload URL**: `https://your-jenkins-url/github-webhook/`
4. **Content type**: `application/json`
5. **Events**: Chọn "Just the push event"

## 4. Test Pipeline

### 4.1. Test thành công
- Push commit bình thường lên nhánh `main`
- Pipeline sẽ chạy và deploy thành công

### 4.2. Test lint failure
- Uncomment đoạn heavy operation trong `js/products.js`
- Push commit → Pipeline sẽ fail ở stage "Lint & Test"

### 4.3. Test test failure
- Sửa `let vat = 20` thành `let vat = 200` trong `js/main.js`
- Push commit → Pipeline sẽ fail ở stage "Lint & Test"

## 5. Kiểm tra kết quả

### 5.1. Firebase Hosting
- Vào Firebase Console → Hosting
- Kiểm tra URL hosting

### 5.2. Remote Server
- Truy cập: `http://118.69.34.46/jenkins/phovv2/template2/current/index.html`
- Kiểm tra cấu trúc thư mục deploy

### 5.3. Slack Notifications
- Kiểm tra channel `#lnd-2025-workshop`
- Xem notification success/failure

## 6. Troubleshooting

### 6.1. SSH Connection Failed
- Kiểm tra private key
- Kiểm tra remote server IP và port
- Kiểm tra user permissions

### 6.2. Firebase Deploy Failed
- Kiểm tra Firebase token
- Kiểm tra project name
- Kiểm tra Firebase CLI version

### 6.3. Slack Notification Failed
- Kiểm tra Slack token
- Kiểm tra channel name
- Kiểm tra bot permissions
