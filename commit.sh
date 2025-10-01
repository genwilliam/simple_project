#!/bin/sh
echo "如果你想终止脚本, 请按 Ctrl+C"
echo "请在git仓库根目录运行!!!!!!!!!!"
echo "----------------------"

# $$ 是当前 shell 进程的 PID
# ps -p <PID> 是查看某个进程的信息
# -o comm= 表示只输出进程名，不带表头
GET_SHELL=$(ps -p $$  -o comm=)
FALLBACK_SHELL=$SHELL

echo "当前脚本解释器: $GET_SHELL"
echo "登录默认 shell : $FALLBACK_SHELL"
echo "----------------------"

# 获取简短状态
status=$(git status --porcelain)

# 定义文件列表，按状态分类
M_FILES=""
A_FILES=""
D_FILES=""
U_FILES=""

# 遍历每一行 git status 输出
while read -r line; do
    FUCK_SO_EASY_CODE=$(echo "$line" | awk '{print $1}')
    FUCK_SO_EASY_FILE=$(echo "$line" | awk '{print $2}')

    # echo "处理文件: $FUCK_SO_EASY_FILE"
    # echo "状态码: $FUCK_SO_EASY_CODE"

    if [ "$FUCK_SO_EASY_CODE" = "M" ]; then
        echo "修改了文件: $FUCK_SO_EASY_FILE"
        M_FILES="$M_FILES \"$FUCK_SO_EASY_FILE\""
    elif [ "$FUCK_SO_EASY_CODE" = "A" ]; then
        echo "新增了文件: $FUCK_SO_EASY_FILE"
        A_FILES="$A_FILES \"$FUCK_SO_EASY_FILE\""
    elif [ "$FUCK_SO_EASY_CODE" = "D" ]; then
        echo "删除了文件: $FUCK_SO_EASY_FILE"
        D_FILES="$D_FILES \"$FUCK_SO_EASY_FILE\""
    elif [ "$FUCK_SO_EASY_CODE" = "??" ]; then
        echo "未跟踪的文件: $FUCK_SO_EASY_FILE"
        U_FILES="$U_FILES \"$FUCK_SO_EASY_FILE\""
    else
        echo "其他状态 ($FUCK_SO_EASY_CODE) 的文件: $FUCK_SO_EASY_FILE"
    fi
done <<< "$status"

# 批量提交每类文件
if [ -n "$M_FILES" ]; then
    eval git add $M_FILES
    git commit -m "fix: update modified files"
fi

if [ -n "$A_FILES" ]; then
    eval git add $A_FILES
    git commit -m "feat: add new files"
fi

if [ -n "$D_FILES" ]; then
    eval git add $D_FILES
    git commit -m "chore: remove deleted files"
fi

if [ -n "$U_FILES" ]; then
    eval git add $U_FILES
    git commit -m "chore: add untracked files"
fi

echo "----------------------"
echo "所有更改已提交!"

# 获取当前分支
branch=$(git rev-parse --abbrev-ref HEAD)
echo "正在推送到远程仓库分支: $branch ..."
git push origin "$branch"
echo "推送完成!"
echo "----------------------"
echo "现在的状态"
git status