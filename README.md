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

6. Replace **{YOUR KUZCO ACCOUNT EMAIL} {YOUR KUZCO ACCOUNT PASSWORD} {YOUR WORKER CODE}** in **docker-compose.yml** with your kuzco account email, password and worker code from step 3

7. Run
   
   ```
   $ docker compose build
   $ docker compose up
   ```