# SSH 部署（Docker Compose）

本仓库包含 `apps/api`（FastAPI）与 `apps/web`（Next.js）。推荐用 Docker Compose 在服务器上部署：

- Web: `:3000`
- API: `:8080`
- API Docs: `:8080/docs`

> 注意：我不建议在自动化脚本里硬编码密码；下面提供 **SSH Key（推荐）** 与 **密码（可选）** 两种方式，密码通过本机环境变量传入，避免写进脚本/仓库。

## 1) 准备服务器（开放端口）

确保服务器安全组/防火墙放行：

- `3000/tcp`（Web）
- `8080/tcp`（API/WS）

## 2) 推荐：使用 SSH Key 登录

在你的电脑上：

```bash
ssh-keygen -t ed25519 -C "claudable-deploy"
ssh-copy-id root@47.245.120.53
```

然后执行部署脚本：

```bash
REPO_URL="https://github.com/imszy/Claudable.git" \
BRANCH="main" \
./deploy/ssh/deploy.sh root@47.245.120.53
```

## 3) 可选：使用密码登录（sshpass）

在你的电脑上安装 `sshpass`（Ubuntu/Debian）：

```bash
sudo apt-get update && sudo apt-get install -y sshpass
```

运行（密码通过环境变量传入；不要把密码写进命令历史）：

```bash
export SSHPASS='(你的服务器密码)'
REPO_URL="https://github.com/imszy/Claudable.git" \
BRANCH="main" \
./deploy/ssh/deploy.sh root@47.245.120.53 --password
unset SSHPASS
```

## 4) 部署后配置（必须）

首次部署会在服务器的应用目录下生成 `.env`（来自 `.env.production.example`）。你需要编辑它，至少填写：

- `ANTHROPIC_API_KEY`
- `ENCRYPTION_KEY`（建议设置，32+ 随机字符）

示例（在服务器上）：

```bash
cd /opt/claudable/app
cp -n .env.production.example .env
nano .env
docker compose up -d --build
```

## 5) 常用运维命令（服务器上）

```bash
cd /opt/claudable/app
docker compose ps
docker compose logs -f --tail=200 api
docker compose logs -f --tail=200 web
docker compose restart
docker compose pull --ignore-pull-failures || true
docker compose up -d --build
```

