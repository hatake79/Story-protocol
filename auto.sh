#!/bin/bash

# Đảm bảo rằng script đang chạy với quyền root
if [ "$(id -u)" -ne "0" ]; then
  echo "Vui lòng chạy script với quyền root." 1>&2
  exit 1
fi

echo "Bắt đầu cài đặt và cấu hình node Story Protocol..."

# Nhập moniker từ người dùng
read -p "Nhập tên moniker của bạn: " MONIKER_NAME

# Cập nhật và cài đặt các công cụ cần thiết
echo "Cài đặt các công cụ cơ bản..."
apt update && apt-get update
apt install -y curl git make jq build-essential gcc unzip wget lz4 aria2

# Tạo thư mục $HOME/go/bin nếu chưa tồn tại và thêm vào PATH
echo "Cấu hình PATH..."
[ ! -d "$HOME/go/bin" ] && mkdir -p $HOME/go/bin
if ! grep -q "$HOME/go/bin" $HOME/.bashrc; then
  echo 'export PATH=$PATH:$HOME/go/bin' >> $HOME/.bashrc
  source $HOME/.bashrc
fi

# Tải xuống và cài đặt story-geth
echo "Tải xuống và cài đặt story-geth..."
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/geth-public/geth-linux-amd64-0.9.2-ea9f0d2.tar.gz
tar -xzvf geth-linux-amd64-0.9.2-ea9f0d2.tar.gz
cp geth-linux-amd64-0.9.2-ea9f0d2/geth $HOME/go/bin/story-geth
story-geth version

# Tải xuống và cài đặt story
echo "Tải xuống và cài đặt story..."
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.9.11-2a25df1.tar.gz
tar -xzvf story-linux-amd64-0.9.11-2a25df1.tar.gz
cp story-linux-amd64-0.9.11-2a25df1/story $HOME/go/bin/story
story version

# Khởi tạo Story
echo "Khởi tạo Story với moniker: $MONIKER_NAME"
story init --network iliad --moniker "$MONIKER_NAME"

# Cấu hình dịch vụ story-geth
echo "Cấu hình dịch vụ story-geth..."
cat <<EOF | tee /etc/systemd/system/story-geth.service > /dev/null
[Unit]
Description=Story Geth Client
After=network.target

[Service]
User=$(whoami)
ExecStart=$HOME/go/bin/story-geth --iliad --syncmode full
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Cấu hình dịch vụ story
echo "Cấu hình dịch vụ story..."
cat <<EOF | tee /etc/systemd/system/story.service > /dev/null
[Unit]
Description=Story Consensus Client
After=network.target

[Service]
User=$(whoami)
ExecStart=$HOME/go/bin/story run
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Quản lý dịch vụ
echo "Khởi động và kích hoạt các dịch vụ..."
systemctl daemon-reload
systemctl start story-geth.service
systemctl start story.service
systemctl enable story-geth.service
systemctl enable story.service

echo "Cài đặt và cấu hình hoàn tất!"

echo "Nếu gặp lỗi, kiểm tra logs dịch vụ bằng lệnh:"
echo "journalctl -u story-geth.service"
echo "journalctl -u story.service"

echo "Thông tin liên hệ:"
echo "Kênh youtube: youtube.com/@dockhachhanh"
echo "Discord: https://discord.gg/44B8pt4tSM"
echo "GitHub: mở issue nếu cần thêm hỗ trợ"
