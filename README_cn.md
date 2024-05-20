# Kuzco Docker 部署

## 先决条件
- Docker
- docker-compose

## 如何运行
1. 在 [Kuzco | LLM 推理网络](https://kuzco.xyz/register) 上创建一个 kuzco 账户
2. 登录并在 [Kuzco | LLM 推理网络](https://kuzco.xyz/dashboard/workers) 上创建一个worker
3. 在worker概览页面记录worker code

    像这样：

    `$ kuzco worker register --code <your_worker_code>`

4. 克隆此仓库并进入该目录

5. 如果你已经运行过 kuzco，从 ~/.kuzco/models 复制模型文件夹；如果没有，请按照官方教程运行一次

6. 在 **docker-compose.yml** 中将 **{YOUR KUZCO ACCOUNT EMAIL} {YOUR KUZCO ACCOUNT PASSWORD} {YOUR WORKER CODE}** 替换为第3步中的你的 kuzco 账户邮箱、密码和worker code

7. 运行
   
   ```
   $ docker compose build
   $ docker compose up
   ```