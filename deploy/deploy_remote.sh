#!/usr/bin/env bash
set -euo pipefail

# Arguments
REMOTE_USER="$1"    # newbie
REMOTE_HOST="$2"    # ip or hostname
REMOTE_PORT="$3"    # 3334
REMOTE_BASE="$4"    # /usr/share/nginx/html/jenkins/yourname2/template2
LOCAL_BUILD_DIR="$5" # path to build files (from workspace)
# Optional display host for access URLs (defaults to REMOTE_HOST)
DISPLAY_HOST="${6:-$REMOTE_HOST}"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
RELEASE_DIR="deploy/${TIMESTAMP}"
SSH_OPTS="-o StrictHostKeyChecking=no -p ${REMOTE_PORT} -i ~/.ssh/id_rsa"

echo "\n🚀 Bắt đầu deploy"
ssh ${SSH_OPTS} ${REMOTE_USER}@${REMOTE_HOST} "mkdir -p '${REMOTE_BASE}/${RELEASE_DIR}'"
echo "📦 Tạo release: ${RELEASE_DIR}"

# Prefer rsync if available on remote, otherwise fallback to scp
if ssh ${SSH_OPTS} ${REMOTE_USER}@${REMOTE_HOST} "command -v rsync >/dev/null 2>&1"; then
  echo "🚚 Chuyển file bằng rsync"
  rsync -avz -e "ssh ${SSH_OPTS}" \
    --include='index.html' --include='404.html' \
    --include='css/***' --include='js/***' --include='images/***' \
    --exclude='*' \
    "${LOCAL_BUILD_DIR}/" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_BASE}/${RELEASE_DIR}/"
else
  # Fallback: copy only required files via scp if they exist
  echo "🚚 Chuyển file bằng scp (fallback)"
  for item in index.html 404.html css js images; do
    if [ -e "${LOCAL_BUILD_DIR}/${item}" ]; then
      scp -r -P "${REMOTE_PORT}" -i ~/.ssh/id_rsa -o StrictHostKeyChecking=no \
        "${LOCAL_BUILD_DIR}/${item}" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_BASE}/${RELEASE_DIR}/"
    fi
  done
fi

# Update symlink và xoá bản cũ (giữ 5) trong deploy/
ssh ${SSH_OPTS} ${REMOTE_USER}@${REMOTE_HOST} \
  "set -e; cd '${REMOTE_BASE}/deploy'; ln -sfn '${TIMESTAMP}' current; ls -1tr | grep -v '^current$' | head -n -5 | xargs -r rm -rf"
echo "🔗 Cập nhật symlink: deploy/current -> ${TIMESTAMP}"

echo "✅ Deploy xong: ${REMOTE_BASE}/${RELEASE_DIR}"

# Đồng bộ thư mục baseline giống release mới nhất (current)
ssh ${SSH_OPTS} ${REMOTE_USER}@${REMOTE_HOST} \
  "set -e; mkdir -p '${REMOTE_BASE}/web-performance-project1-initial'; rm -rf '${REMOTE_BASE}/web-performance-project1-initial/'*; cp -a '${REMOTE_BASE}/${RELEASE_DIR}/.' '${REMOTE_BASE}/web-performance-project1-initial/'"
echo "🗂️ Baseline web-performance-project1-initial đã đồng bộ từ release mới nhất"

# Print access URLs (assuming nginx docroot at /usr/share/nginx/html)
URL_PATH="${REMOTE_BASE#/usr/share/nginx/html}"
CURRENT_URL="http://${DISPLAY_HOST}${URL_PATH}/deploy/current/"
RELEASE_URL="http://${DISPLAY_HOST}${URL_PATH}/${RELEASE_DIR}/"
echo "\n🌐 Links truy cập:"
echo " - Current: ${CURRENT_URL}"
echo " - Release: ${RELEASE_URL}\n"
