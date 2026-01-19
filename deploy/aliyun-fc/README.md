## Claudable 部署到阿里云函数计算（FC）- Demo 预览

这套部署方式把仓库拆成两个 FC 函数（**容器运行时**）：

- **API**：`apps/api`（FastAPI + WebSocket）
- **Web**：`apps/web`（Next.js）

> 注意：本仓库部分“本地运行/预览”能力（例如 API 内部启动项目预览服务、调用本机 CLI 工具链）在 FC 的无状态/受限运行环境中可能无法完整工作。作为 demo 预览，建议先聚焦 UI、项目创建、设置页、基础 API/WS 连通性；需要真实 AI 能力时再补齐相应凭证与依赖。

### 前置条件

- **阿里云函数计算 FC** 已开通
- **容器镜像仓库（ACR）** 已开通（例如 `registry.cn-hangzhou.aliyuncs.com/<namespace>/...`）
- 本地有 `docker`（用于构建镜像）

---

## 方式 A（推荐）：用 FC 控制台部署两个“自定义容器函数”

### 1) 构建并推送 API 镜像

在仓库根目录执行（将占位符替换为你的 ACR 地址）：

```bash
docker build -f apps/api/Dockerfile -t registry.cn-hangzhou.aliyuncs.com/<namespace>/claudable-api:latest .
docker push registry.cn-hangzhou.aliyuncs.com/<namespace>/claudable-api:latest
```

### 2) 构建并推送 Web 镜像

```bash
docker build -f apps/web/Dockerfile -t registry.cn-hangzhou.aliyuncs.com/<namespace>/claudable-web:latest .
docker push registry.cn-hangzhou.aliyuncs.com/<namespace>/claudable-web:latest
```

### 3) 创建 API 函数（容器运行时）

在 FC 控制台新建函数：

- **运行时**：自定义容器（Custom Container）
- **镜像**：选择 `claudable-api:latest`
- **容器监听端口**：`9000`
- **HTTP 触发器**：创建一个匿名触发器（Anonymous），勾选方法：`GET/POST/PUT/PATCH/DELETE/OPTIONS`
- （可选）**环境变量**：
  - `PORT=9000`
  - `API_PORT=9000`
  - `DATABASE_URL=sqlite:////workspace/data/cc.db`（默认即可，不填也行）

部署完成后记下 **触发器 URL**（例如 `https://xxxxxx.cn-hangzhou.fcapp.run`）。

### 4) 创建 Web 函数（容器运行时）

同样新建函数：

- **运行时**：自定义容器（Custom Container）
- **镜像**：选择 `claudable-web:latest`
- **容器监听端口**：`9000`
- **HTTP 触发器**：匿名触发器（至少 `GET/OPTIONS`）
- **环境变量**（把 `<API_URL>` 替换为上一步 API 的触发器 URL）：
  - `PORT=9000`
  - `NODE_ENV=production`
  - `NEXT_PUBLIC_API_BASE=<API_URL>`
  - `API_BASE=<API_URL>`（用于 Next.js 服务器侧 rewrite）
  - `NEXT_PUBLIC_WS_BASE=<WSS_URL>`

> `NEXT_PUBLIC_WS_BASE` 建议使用 `wss://...`。如果 API 触发器是 `https://...`，通常对应 `wss://...`（同域名）。

部署完成后打开 Web 的触发器 URL，即可作为 demo 访问。

---

## 方式 B（可选）：Serverless Devs 一键部署

仓库提供了 `deploy/aliyun-fc/s.yaml.example` 作为模板，你可以：

1. 复制为 `deploy/aliyun-fc/s.yaml`
2. 替换其中的 ACR 镜像地址、Region、Service/Function 名称
3. 使用 `s deploy` 部署

> Serverless Devs / FC3 的 YAML 字段在不同版本可能略有差异；如果遇到字段报错，以控制台方式为准。

---

## 方式 C（推荐给我代部署）：GitHub Actions 一键部署（无需本地 Docker）

仓库包含工作流：`.github/workflows/deploy-aliyun-fc.yml`，默认目标：

- Region：`cn-beijing`
- ACR：`registry.cn-beijing.aliyuncs.com/github-demo`
- 镜像：
  - `claudable-api:latest`
  - `claudable-web:latest`
- FC Service：`claudable-demo`（函数名：`api` / `web`）
- HTTP 触发器：匿名（Anonymous）

你只需要在 GitHub 仓库里配置 2 个 Secrets：

- `ALIBABA_CLOUD_ACCESS_KEY_ID`
- `ALIBABA_CLOUD_ACCESS_KEY_SECRET`

然后到 GitHub 的 Actions 页面手动触发 **Deploy to Aliyun FC (cn-beijing)** 即可完成：

1. 构建并 push 两个镜像到 ACR
2. 部署 API 到 FC，并自动解析 API 触发器 URL
3. 部署 Web 到 FC，并自动设置 `NEXT_PUBLIC_API_BASE / API_BASE / NEXT_PUBLIC_WS_BASE`

