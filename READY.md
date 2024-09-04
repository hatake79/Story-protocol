# Hướng dẫn Cài đặt và Chạy Node cho Dự án Story

## 1. Yêu cầu hệ thống

Trước khi bắt đầu, hãy đảm bảo rằng bạn đã cài đặt các yêu cầu hệ thống sau:

- Hệ điều hành: Ubuntu 20.04 hoặc mới hơn
- Các công cụ cơ bản: `curl`, `git`, `make`, `jq`, `build-essential`, `gcc`, `unzip`, `wget`, `lz4`, `aria2`

## 2. Cài đặt

### 2.1. Cài đặt các công cụ cần thiết

```bash
sudo apt update
sudo apt-get update
sudo apt install curl git make jq build-essential gcc unzip wget lz4 aria2 -y
2.2. Tải xuống và cài đặt story-geth
# Tải xuống và giải nén tệp
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/geth-public/geth-linux-amd64-0.9.2-ea9f0d2.tar.gz
tar -xzvf geth-linux-amd64-0.9.2-ea9f0d2.tar.gz

# Sao chép tệp geth vào $HOME/go/bin với tên story-geth
sudo cp geth-linux-amd64-0.9.2-ea9f0d2/geth $HOME/go/bin/story-geth

# Kiểm tra phiên bản story-geth
story-geth version

2.3. Tải xuống và cài đặt story
# Tải xuống và giải nén tệp
wget https://story-geth-binaries.s3.us-west-1.amazonaws.com/story-public/story-linux-amd64-0.9.11-2a25df1.tar.gz
tar -xzvf story-linux-amd64-0.9.11-2a25df1.tar.gz

# Sao chép tệp story vào $HOME/go/bin với tên story
sudo cp story-linux-amd64-0.9.11-2a25df1/story $HOME/go/bin/story

# Kiểm tra phiên bản story
story version

Cập nhật .bashrc
# Tạo thư mục $HOME/go/bin nếu nó chưa tồn tại
[ ! -d "$HOME/go/bin" ] && mkdir -p $HOME/go/bin

# Thêm $HOME/go/bin vào PATH nếu nó chưa có trong .bashrc
if ! grep -q "$HOME/go/bin" $HOME/.bashrc; then
  echo 'export PATH=$PATH:$HOME/go/bin' >> $HOME/.bashrc
  source $HOME/.bashrc
fi

2.4. Khởi tạo Story
story init --network iliad --moniker "Your_moniker_name"
3. Cấu hình Dịch vụ
3.1. Cấu hình dịch vụ story-geth
sudo tee /etc/systemd/system/story-geth.service > /dev/null <<EOF
[Unit]
Description=Story Geth Client
After=network.target

[Service]
User=test
ExecStart=/home/test/go/bin/story-geth --iliad --syncmode full
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF
3.2. Cấu hình dịch vụ story
sudo tee /etc/systemd/system/story.service > /dev/null <<EOF
[Unit]
Description=Story Consensus Client
After=network.target

[Service]
User=test
ExecStart=/home/test/go/bin/story run
Restart=on-failure
RestartSec=3
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF
4. Quản lý Dịch vụ
4.1. Khởi động dịch vụ
sudo systemctl daemon-reload
sudo systemctl start story-geth.service
sudo systemctl start story.service
4.2. Dừng dịch vụ
sudo systemctl stop story-geth.service
sudo systemctl stop story.service
4.3. Kích hoạt dịch vụ tự động khởi động cùng hệ thống
sudo systemctl enable story-geth.service
sudo systemctl enable story.service
5. Khắc phục sự cố
Lỗi không tìm thấy lệnh story-geth hoặc story: Kiểm tra rằng biến môi trường PATH đã được thiết lập đúng cách và story-geth và story đã được sao chép vào thư mục $HOME/go/bin.
Lỗi khi khởi động dịch vụ: Kiểm tra logs dịch vụ bằng lệnh journalctl -u story-geth.service và journalctl -u story.service.
6. Thông tin liên hệ
Kênh youtube: youtube.com/@dockhachhanh
Nếu bạn gặp vấn đề hoặc cần thêm hỗ trợ, vui lòng liên hệ với nhóm phát triển qua discord:https://discord.gg/44B8pt4tSM hoặc mở một issue trên GitHub.
