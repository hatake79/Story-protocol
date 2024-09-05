#!/bin/bash

# Kiểm tra quyền người dùng (không phải root)
if [ "$EUID" -eq 0 ]; then
  echo "Vui lòng chạy script này với quyền người dùng không phải root."
  exit 1
fi

# Xác định người dùng hiện tại
USER=$(whoami)

# Cài đặt các công cụ cơ bản
echo "Cài đặt các công cụ cơ bản..."
sudo apt update
sudo apt-get update
sudo apt install curl git make jq build-essential gcc unzip wget lz4 aria2 -y

# Xóa phiên bản Go cũ (nếu có)
echo "Xóa thư mục Go cũ (nếu có)..."
if [ -d "$HOME/go" ]; then
  echo "Xóa thư mục Go cũ..."
  rm -rf $HOME/go
fi

# Cài đặt Go mới
GO_VERSION="1.22.5"
GO_TAR="go$GO_VERSION.linux-amd64.tar.gz"
GO_INSTALL_DIR="$HOME/go"

# Tạo thư mục cài đặt Go
mkdir -p $GO_INSTALL_DIR

# Tải xuống Go
echo "Tải xuống Go $GO_VERSION..."
wget https://golang.org/dl/$GO_TAR -O /tmp/$GO_TAR

# Giải nén Go vào thư mục người dùng
echo "Giải nén Go vào thư mục người dùng..."
tar -C $HOME -xzf /tmp/$GO_TAR

# Thêm Go vào PATH
echo "Cập nhật PATH với Go..."
echo "export PATH=\$PATH:$HOME/go/bin" >> $HOME/.bashrc
source $HOME/.bashrc

# Tải xuống và cài đặt story-geth
echo "Tải xuống và cài đặt story-geth..."
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/geth-public/geth-linux-amd64-0.9.2-ea9f0d2.tar.gz -O /tmp/story-geth.tar.gz
tar -xzvf /tmp/story-geth.tar.gz -C $GO_INSTALL_DIR
mv $GO_INSTALL_DIR/geth-linux-amd64-0.9.2-ea9f0d2/geth $GO_INSTALL_DIR/bin/story-geth

# Kiểm tra phiên bản story-geth
$GO_INSTALL_DIR/bin/story-geth version

# Tải xuống và cài đặt story
echo "Tải xuống và cài đặt story..."
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.9.11-2a25df1.tar.gz -O /tmp/story.tar.gz
tar -xzvf /tmp/story.tar.gz -C $GO_INSTALL_DIR
mv $GO_INSTALL_DIR/story-linux-amd64-0.9.11-2a25df1/story $GO_INSTALL_DIR/bin/story

# Kiểm tra phiên bản story
$GO_INSTALL_DIR/bin/story version

# Khởi tạo Story
echo "Khởi tạo Story với moniker:"
read -p "Nhập moniker của bạn: " MONIKER
$GO_INSTALL_DIR/bin/story init --network iliad --moniker "$MONIKER"

# Cấu hình dịch vụ story-geth
echo "Cấu hình dịch vụ story-geth..."
cat <<EOF > $HOME/story-geth.service
[Unit]
Description=Story Geth Client
After=network.target

[Service]
User=$USER
Group=$USER
ExecStart=$GO_INSTALL_DIR/bin/story-geth --iliad --syncmode full
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Cấu hình dịch vụ story
echo "Cấu hình dịch vụ story..."
cat <<EOF > $HOME/story.service
[Unit]
Description=Story Consensus Client
After=network.target

[Service]
User=$USER
Group=$USER
WorkingDirectory=$HOME
ExecStart=$GO_INSTALL_DIR/bin/story run
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

# Di chuyển các file cấu hình dịch vụ vào thư mục systemd
sudo mv $HOME/story-geth.service /etc/systemd/system/
sudo mv $HOME/story.service /etc/systemd/system/

# Khởi động dịch vụ
echo "Khởi động dịch vụ..."
sudo systemctl daemon-reload
sudo systemctl start story-geth.service
sudo systemctl start story.service

# Kích hoạt dịch vụ tự động khởi động cùng hệ thống
sudo systemctl enable story-geth.service
sudo systemctl enable story.service

echo "Cài đặt hoàn tất! Kiểm tra trạng thái dịch vụ bằng lệnh:"
echo "sudo systemctl status story-geth.service"
echo "sudo systemctl status story.service"


echo "Thông tin liên hệ:"
echo "Kênh youtube: youtube.com/@dockhachhanh"
echo "Discord: https://discord.gg/44B8pt4tSM"
echo "GitHub: mở issue nếu cần thêm hỗ trợ"
