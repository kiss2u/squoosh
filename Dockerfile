# 构建阶段
FROM node:18-alpine AS builder

WORKDIR /app

# 复制根目录的 package 文件
COPY package*.json ./

# 复制所有子包的 package.json 及源代码（整个 packages 目录）
COPY packages/ ./packages/

# 安装依赖
RUN npm ci

# 构建应用（生成静态文件到 packages/app/dist）
RUN npm run build

# 运行阶段
FROM nginx:alpine

COPY --from=builder /app/packages/app/dist /usr/share/nginx/html

# 可选：自定义 Nginx 配置（如需支持 SPA 路由）
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
