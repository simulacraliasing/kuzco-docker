#!/bin/bash

# 进入根目录
cd /root

# 检查kuzco worker的验证状态
verify_output=$(kuzco worker verify)

# 检查输出是否为"Worker is valid!"
if [[ "$verify_output" == "Worker is valid!" ]]; then
    # 如果验证通过，则直接启动worker
    echo "Worker is valid, starting worker..."
    kuzco worker start > /root/log/kuzco.log 2>&1
else
    # 如果验证不通过，先登录再启动worker
    echo "Worker is not valid, logging in..."
    ./script/kuzco_start.sh
    kuzco worker start > /root/log/kuzco.log 2>&1
fi