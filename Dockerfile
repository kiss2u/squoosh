# 构建阶段
FROM node:18-alpine AS builder

WORKDIR /app

# 复制依赖定义文件（利用 Docker 缓存）
COPY package*.json ./
# 复制所有子包的 package.json（monorepo 结构）
COPY packages/*/package.json ./packages/

# 安装依赖
RUN npm ci

# 复制源代码
COPY . .

# 构建应用（生成静态文件到 packages/app/dist）
RUN npm run build

# 运行阶段
FROM nginx:alpine

# 将构建好的静态文件复制到 Nginx 的默认发布目录
COPY --from=builder /app/packages/app/dist /usr/share/nginx/html

# 可选：自定义 Nginx 配置（如需支持 SPA 路由，可取消注释并准备 nginx.conf）
# COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
