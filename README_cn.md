# Kuzco Docker 部署

## 前置需求
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

6. 在 **docker-compose.yml** 中将 **{YOUR KUZCO ACCOUNT EMAIL} {YOUR KUZCO ACCOUNT PASSWORD} {YOUR WORKER CODE}** 替换为第2和第3步中的你的 kuzco 账户邮箱、密码和worker code
   替换为你自己的日志路径和gpu device id

7. 运行
   
   ```
   $ docker compose build
   $ docker compose up
   ```

## 单张显卡运行多个worker
在 **docker-compose.yml** 中复制 **kuzco-worker** 并更改worker code，使用相同的gpu device id。可以通过在终端中运行 `nvidia-smi` 来检查你的gpu id和内存使用情况。

## 在多个gpu上运行worker
在 **docker-compose.yml** 中复制 **kuzco-worker** 并更改worker code，使用不同的gpu device id。

## Worker管理
你可以在 [Kuzco | LLM 推理网络](https://kuzco.xyz/dashboard/workers) 上管理你的worker。

如果你想更改worker code，你可以注销worker，然后将生成一个新的worker code。

## 预构建镜像
如果因为某些原因你无法构建镜像，可以通过运行 `docker pull simulacraliasing/kuzco-docker:latest` 从docker hub拉取预构建镜像。

## 潜在的模型切换
如果 kuzco 官方切换了模型，你应该运行一次 kuzco 以获取新模型，然后将新模型文件夹复制到此仓库并运行 `docker compose build` 以重新构建镜像