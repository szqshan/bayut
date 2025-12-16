#!/bin/bash

###############################################################################
# Bayut Platform - 云服务器自动化部署脚本
# 用途：在干净的Linux服务器上自动安装Docker、部署代码和启动服务
###############################################################################

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

###############################################################################
# 1. 系统信息检测
###############################################################################
print_info "=== 检测系统信息 ==="
print_info "操作系统: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
print_info "内核版本: $(uname -r)"
print_info "CPU架构: $(uname -m)"

###############################################################################
# 2. 更新系统
###############################################################################
print_info "=== 更新系统包 ==="
apt-get update
apt-get upgrade -y

###############################################################################
# 3. 安装基础工具
###############################################################################
print_info "=== 安装基础工具 ==="
apt-get install -y \
    curl \
    wget \
    git \
    vim \
    htop \
    net-tools \
    ca-certificates \
    gnupg \
    lsb-release

###############################################################################
# 4. 安装Docker
###############################################################################
print_info "=== 检查Docker安装状态 ==="
if command -v docker &> /dev/null; then
    print_warn "Docker已安装，版本: $(docker --version)"
else
    print_info "安装Docker..."

    # 添加Docker官方GPG密钥
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    # 设置Docker仓库
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    # 安装Docker Engine
    apt-get update
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # 启动Docker服务
    systemctl start docker
    systemctl enable docker

    print_info "Docker安装完成: $(docker --version)"
fi

###############################################################################
# 5. 安装Python 3.11
###############################################################################
print_info "=== 安装Python 3.11 ==="
if command -v python3.11 &> /dev/null; then
    print_warn "Python 3.11已安装"
else
    add-apt-repository ppa:deadsnakes/ppa -y
    apt-get update
    apt-get install -y python3.11 python3.11-venv python3.11-dev python3-pip
fi

python3.11 --version

###############################################################################
# 6. 创建项目目录
###############################################################################
print_info "=== 创建项目目录 ==="
PROJECT_DIR="/opt/bayut"
mkdir -p $PROJECT_DIR
cd $PROJECT_DIR

###############################################################################
# 7. 克隆代码（如果还没有）
###############################################################################
print_info "=== 克隆项目代码 ==="
if [ -d "$PROJECT_DIR/.git" ]; then
    print_warn "代码已存在，执行git pull更新..."
    cd $PROJECT_DIR
    git pull
else
    print_info "从GitHub克隆代码..."
    # 如果当前目录不为空，先备份
    if [ "$(ls -A $PROJECT_DIR)" ]; then
        print_warn "目录不为空，先清空..."
        rm -rf $PROJECT_DIR/*
    fi
    git clone https://github.com/szqshan/bayut.git $PROJECT_DIR
fi

cd $PROJECT_DIR

###############################################################################
# 8. 配置环境变量
###############################################################################
print_info "=== 配置环境变量 ==="
if [ ! -f "backend/.env" ]; then
    cp backend/.env.example backend/.env
    print_warn "已创建backend/.env文件，请编辑填入你的API密钥"
    print_warn "使用命令: nano backend/.env"
else
    print_info "backend/.env已存在"
fi

###############################################################################
# 9. 启动Docker服务
###############################################################################
print_info "=== 启动Docker容器 ==="
docker compose down 2>/dev/null || true
docker compose up -d postgres redis

# 等待数据库启动
print_info "等待PostgreSQL启动..."
sleep 10

# 检查容器状态
docker compose ps

###############################################################################
# 10. 设置Python虚拟环境
###############################################################################
print_info "=== 设置Python虚拟环境 ==="
cd backend

if [ -d "venv" ]; then
    print_warn "虚拟环境已存在，删除重建..."
    rm -rf venv
fi

python3.11 -m venv venv
source venv/bin/activate

# 升级pip
pip install --upgrade pip

# 安装依赖
print_info "安装Python依赖..."
pip install -r requirements.txt

###############################################################################
# 11. 数据库迁移
###############################################################################
print_info "=== 执行数据库迁移 ==="

# 检查是否有迁移文件
if [ ! -f "alembic/versions/*.py" ] || [ -z "$(ls -A alembic/versions 2>/dev/null)" ]; then
    print_info "创建初始迁移..."
    alembic revision --autogenerate -m "Initial database schema"
fi

print_info "执行迁移..."
alembic upgrade head

###############################################################################
# 12. 创建systemd服务（开机自启）
###############################################################################
print_info "=== 创建systemd服务 ==="

cat > /etc/systemd/system/bayut-api.service <<EOF
[Unit]
Description=Bayut Property Platform API
After=network.target docker.service
Requires=docker.service

[Service]
Type=simple
User=root
WorkingDirectory=/opt/bayut/backend
Environment="PATH=/opt/bayut/backend/venv/bin"
ExecStart=/opt/bayut/backend/venv/bin/uvicorn src.main:app --host 0.0.0.0 --port 8000
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# 重载systemd
systemctl daemon-reload

# 启动服务
systemctl start bayut-api
systemctl enable bayut-api

###############################################################################
# 13. 配置防火墙
###############################################################################
print_info "=== 配置防火墙 ==="
if command -v ufw &> /dev/null; then
    ufw allow 22/tcp     # SSH
    ufw allow 8000/tcp   # API
    ufw allow 80/tcp     # HTTP
    ufw allow 443/tcp    # HTTPS
    ufw --force enable
    print_info "防火墙配置完成"
else
    print_warn "ufw未安装，跳过防火墙配置"
fi

###############################################################################
# 14. 安装Nginx（可选，用于反向代理）
###############################################################################
print_info "=== 安装Nginx反向代理 ==="
apt-get install -y nginx

# 创建Nginx配置
cat > /etc/nginx/sites-available/bayut <<EOF
server {
    listen 80;
    server_name 47.115.213.95;

    location / {
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# 启用站点
ln -sf /etc/nginx/sites-available/bayut /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default

# 测试Nginx配置
nginx -t

# 重启Nginx
systemctl restart nginx
systemctl enable nginx

###############################################################################
# 15. 完成检查
###############################################################################
print_info "=== 部署完成检查 ==="

echo ""
echo "=========================================="
print_info "Docker容器状态:"
docker compose ps

echo ""
print_info "Bayut API服务状态:"
systemctl status bayut-api --no-pager

echo ""
print_info "Nginx状态:"
systemctl status nginx --no-pager

echo ""
echo "=========================================="
print_info "✅ 部署完成！"
echo ""
print_info "API访问地址:"
print_info "  - http://47.115.213.95        (通过Nginx)"
print_info "  - http://47.115.213.95:8000   (直接访问API)"
print_info "  - http://47.115.213.95:8000/docs (API文档)"
echo ""
print_info "查看日志:"
print_info "  - API日志: journalctl -u bayut-api -f"
print_info "  - Nginx日志: tail -f /var/log/nginx/access.log"
print_info "  - Docker日志: docker compose logs -f"
echo ""
print_warn "⚠️  重要提醒："
print_warn "1. 修改服务器root密码: passwd"
print_warn "2. 编辑环境变量: nano /opt/bayut/backend/.env"
print_warn "3. 确保BAYUT_API_KEY已正确配置"
print_warn "4. 重启服务: systemctl restart bayut-api"
echo ""
print_info "测试API:"
print_info "  curl http://47.115.213.95/health"
echo "=========================================="
