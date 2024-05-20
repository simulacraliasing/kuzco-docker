# Kuzco docker deployment

English | [简体中文](README_cn.md)
## Pre-requisites
- Docker
- docker-compose

## How to run
1. Create a kuzco account on [Kuzco | LLM Inference Network](https://kuzco.xyz/register)
2. Login and create a worker on [Kuzco | LLM Inference Network](https://kuzco.xyz/dashboard/workers)
3. Record the worker code on woker overview page

    it looks like:

    `$ kuzco worker register --code <your_worker_code>`

4. Clone this repository and cd into it

5. Copy the models folder from ~/.kuzco/models if you have run kuzco once, if not run once following official tutorial

6. Replace **{YOUR KUZCO ACCOUNT EMAIL} {YOUR KUZCO ACCOUNT PASSWORD} {YOUR WORKER CODE}** in **docker-compose.yml** with your kuzco account email, password and worker code from step 2&3.
   Replace your own log path and gpu device id in

7. Run
   
   ```
   $ docker compose build
   $ docker compose up
   ```

## Run multiple workers on one gpu
Simply copy **kuzco-worker** in **docker-compose.yml** and change the worker code, use the same gpu device id. You can check your gpu id and memory usage by running `nvidia-smi` in terminal

## Run workers on multiple gpus
Simply copy **kuzco-worker** in **docker-compose.yml** and change the worker code, use different gpu device id

## Worker management
You can manage your workers on [Kuzco | LLM Inference Network](https://kuzco.xyz/dashboard/workers).
If you want to change the worker code, you can deregister the worker and a new worker code will be generated.

## Pre-built image
You can pull the pre-built image from docker hub by running `docker pull simulacraliasing/kuzco-docker:latest`

## Potential model switch
If kuzco official switch the model, you should run kuzco once to get the new model, then copy the new model folder to this repository and run `docker compose build` to rebuild the image
