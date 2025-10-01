#! /bin/bash
# 在git仓库根目录运行
# 该脚本用于初始化项目的依赖环境
# 不要进错了目录
echo "如果你想终止脚本, 请按 Ctrl+C"
echo "请在git仓库根目录运行!!!!!!!!!!"
echo "----------------------"
if command -v pnpm >/dev/null 2>&1; then
    echo "pnpm 已经安装，跳过安装"
else
    echo "pnpm 未安装，开始安装..."
    npm install -g pnpm
    echo "安装完成"
fi
echo "-------------------"
pnpm install
echo "依赖安装完成"
echo "----------------------"
