
## 1. 总结一下这个仓库有哪些后端api接口
---
## 基于对代码库的分析，Claudable仓库的后端API接口可以分为以下几个主要类别：

### 项目管理相关API
#### 项目CRUD操作
- GET /api/projects/ - 获取所有项目列表
- GET /api/projects/{project_id} - 获取特定项目详情
- POST /api/projects/ - 创建新项目
- PUT /api/projects/{project_id} - 更新项目信息
- DELETE /api/projects/{project_id} - 删除项目
#### 项目预览相关
- POST /api/projects/{project_id}/preview/start - 启动项目预览
- POST /api/projects/{project_id}/preview/stop - 停止项目预览
- GET /api/projects/{project_id}/preview/status - 获取预览状态
- GET /api/projects/{project_id}/preview/logs - 获取预览日志
- POST /api/projects/{project_id}/preview/restart - 重启预览
- GET /api/projects/{project_id}/error-logs - 获取错误日志
- POST /api/projects/{project_id}/install-dependencies - 安装项目依赖

#### 系统提示词相关
- GET /api/projects/{project_id}/system-prompt - 获取系统提示词
- PUT /api/projects/{project_id}/system-prompt - 更新系统提示词
- POST /api/projects/{project_id}/system-prompt/reset - 重置系统提示词

### 聊天相关API
#### 消息管理
- GET /api/chat/{project_id}/messages - 获取项目的消息列表
- POST /api/chat/{project_id}/messages - 发送新消息
- DELETE /api/chat/{project_id}/messages - 删除消息
- GET /api/chat/{project_id}/active-session - 获取活动会话
- GET /api/chat/{project_id}/sessions/{session_id}/status - 获取会话状态
- GET /api/chat/{project_id}/requests/active - 获取活动请求
#### AI交互
- POST /api/chat/{project_id}/act - 执行AI代码操作模式
- POST /api/chat/{project_id}/chat - 执行AI聊天模式
#### CLI偏好设置
- GET /api/chat/{project_id}/cli/available - 获取可用的CLI列表
- GET /api/chat/{project_id}/cli-preference - 获取CLI偏好设置
- POST /api/chat/{project_id}/cli-preference - 更新CLI偏好设置
- POST /api/chat/{project_id}/model-preference - 更新模型偏好设置
- GET /api/chat/{project_id}/cli-status/{cli_type} - 获取特定CLI状态
- GET /api/chat/{project_id}/cli-status - 获取所有CLI状态
#### WebSocket
- WebSocket /api/chat/{project_id} - 实时通信端点

### 资源管理相关API
#### 资源上传和访问
- POST /api/assets/{project_id}/logo - 上传项目logo
- GET /api/assets/{project_id}/{filename} - 获取项目资源文件
- POST /api/assets/{project_id}/upload - 上传项目资源

### 其他API
#### 根据main.py中的路由注册，系统还包含以下API模块：
- /api/repo - 代码仓库相关操作
- /api/commits - 代码提交相关操作
- /api/env - 环境变量相关操作
- /api/tokens - 服务令牌相关操作
- /api/settings - 设置相关操作
- /api/project_services - 项目服务相关操作
- /api/github - GitHub集成相关操作
- /api/vercel - Vercel集成相关操作

这些API共同构成了Claudable的后端服务体系，支持项目管理、AI聊天交互、资源管理以及与第三方服务的集成等功能。系统采用了模块化的设计，将不同功能的API分组到不同的路由器中，便于维护和扩展。
