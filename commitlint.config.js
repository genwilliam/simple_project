// commitlint 配置文件
// 用于约束 Git 提交规范，确保提交记录清晰统一

export default {
    // 继承自官方推荐规则
    extends: ["@commitlint/config-conventional"],

    // 自定义规则
    rules: {
        // @see: https://commitlint.js.org/#/reference-rules
        "body-leading-blank": [2, "always"], // body 前必须有空行
        "footer-leading-blank": [2, "always"], // footer 前必须有空行
        "header-max-length": [2, "always", 108], // header 最大长度 108 字符
        "subject-case": [0], // subject 大小写不做校验
        "subject-empty": [2, "never"], // subject 不能为空
        "type-empty": [2, "never"], // type 不能为空
        "type-enum": [
            2,
            "always",
            [
                "build", // 构建相关的更改，例如：webpack、npm 等配置文件修改
                "chore", // 杂务类任务，不涉及 src 或测试文件的修改
                "ci", // 持续集成相关更改，例如 GitHub Actions、Jenkins 配置
                "docs", // 仅文档更改
                "feat", // 新功能、新特性
                "fix", // 修复 bug
                "perf", // 性能优化
                "refactor", // 代码重构（非新功能、非修复 bug）
                "revert", // 回滚某个提交
                "style", // 仅样式更改（空格、格式化、分号等），不影响逻辑
                "test", // 添加或修改测试用例
            ],
        ],
    },

    // 交互式提交（配合 commitizen / cz-customizable）
    prompt: {
        alias: {
            fd: "docs: fix typos", // 快捷命令，例如 `git cz fd`
        },
        messages: {
            type: "Select the type of change that you are committing:", // 选择更改类型
            scope: "Select a scope (optional):", // 选择影响范围（可选）--> empty:不影响，custom:自定义
            customScope: "Enter custom scope (optional):", // 自定义影响范围（可选）
            subject: "Write a short description of the change:\n", // 简要描述提交
            body: "Provide a longer description of the change (optional). Use '|' for new line:\n", // 详细描述
            footer:
                "List any BREAKING CHANGES or issues closed by this change (optional). E.g.: #31, #34:\n", // 重大变更/关闭的 issue
            confirmCommit: "Are you sure you want to proceed with the commit?", // 确认提交
        },
        types: [
            { value: "feat", name: "feat:     A new feature" }, // 新功能
            { value: "fix", name: "fix:      A bug fix" }, // 修复 bug
            { value: "docs", name: "docs:     Documentation only changes" }, // 文档变更
            {
                value: "style",
                name: "style:    Code style changes (formatting, missing semi colons, etc)",
            }, // 样式修改
            { value: "perf", name: "perf:     A code change that improves performance" }, // 性能优化
            {
                value: "refactor",
                name: "refactor: Code change that neither fixes a bug nor adds a feature",
            }, // 重构
            { value: "revert", name: "revert:   Reverts a previous commit" }, // 回滚
            { value: "test", name: "test:     Adding or modifying tests" }, // 测试
            { value: "build", name: "build:    Changes that affect the build system" }, // 构建
            { value: "ci", name: "ci:       Changes to CI configuration files and scripts" }, // CI
            { value: "chore", name: "chore:    Other changes that don't modify src or test files" }, // 杂务
        ],
    },
};