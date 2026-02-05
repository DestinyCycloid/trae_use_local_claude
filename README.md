# Nginx OpenAI 反向代理配置

## 配置步骤

### 1. 生成 SSL 证书

在 WSL 中执行（git bash应该也可以，自行测试）：

```bash
bash -c "openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout cert/api.openai.com.key -out cert/api.openai.com.crt -subj '/CN=api.openai.com'"
```

会在 `cert/` 目录生成两个文件：
- `api.openai.com.crt`（证书）
- `api.openai.com.key`（私钥）

### 2. 安装证书（必须）

双击 `cert\api.openai.com.crt`，按以下步骤安装：

1. 点击"安装证书"
2. 选择"本地计算机"（需要管理员权限）
3. 选择"将所有的证书都放入下列存储"
4. 浏览 → 选择"受信任的根证书颁发机构"
5. 完成安装

### 3. 启动代理

右键 `start_proxy.bat` → 以管理员身份运行

脚本会自动：
- 修改 hosts 文件（127.0.0.1 → api.openai.com）
- 刷新 DNS 缓存
- 启动 Nginx（监听 443 端口）

### 4. 使用

确保你的本地服务运行在 `http://127.0.0.1:8080`

所有访问 `https://api.openai.com` 的请求会自动转发到本地服务

### 5. 停止

在脚本窗口按任意键，会自动：
- 停止 Nginx
- 恢复 hosts 文件
- 刷新 DNS 缓存

## 验证

```cmd
# 验证域名解析
ping api.openai.com
# 应显示：正在 Ping api.openai.com [127.0.0.1]

# 测试 API 转发
curl https://api.openai.com/v1/models

# 验证 Nginx 运行
netstat -ano | findstr :443
# 应看到 443 端口被监听
```

## 配置说明

- **证书位置**: `cert/api.openai.com.crt` 和 `.key`
- **Nginx 配置**: `conf/nginx.conf`
- **转发目标**: `http://127.0.0.1:8080`（可在 nginx.conf 中修改 proxy_pass）
- **证书有效期**: 365 天

## 手动操作（可选）

如果不使用自动脚本：

```cmd
# 启动
nginx.exe

# 停止
nginx.exe -s quit

# 测试配置
nginx.exe -t
```

手动修改 hosts 文件（需管理员权限）：
```
C:\Windows\System32\drivers\etc\hosts
添加：127.0.0.1 api.openai.com
```

## 注意事项

- 必须以管理员权限运行
- 确保 443 端口未被占用
- 本地服务需在 Nginx 启动前运行
- 仅用于本地开发，不要用于生产环境
