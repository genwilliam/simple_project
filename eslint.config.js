// eslint.config.js
import { defineConfig } from "eslint/config";
import eslint from "@eslint/js";
import tseslint from "typescript-eslint";
import vuePlugin from "eslint-plugin-vue";
import prettierPlugin from "eslint-plugin-prettier";
import eslintConfigPrettier from "eslint-config-prettier";
import globals from "globals";

/** @type {import('eslint').Linter.Config[]} */
export default defineConfig([
    // 通用配置
    {
        ignores: [
            "**/dist/**",
            "**/node_modules/**",
            "scripts/**",
            "**/*.d.ts",
        ],
        extends: [
            eslint.configs.recommended,
            ...tseslint.configs.recommended,
            eslintConfigPrettier,
        ],
        plugins: {
            prettier: prettierPlugin,
        },
        languageOptions: {
            ecmaVersion: "latest",
            sourceType: "module",
            parser: tseslint.parser,
        },
        rules: {
            "prettier/prettier": "error", // 让 prettier 报错而不是警告
        },
    },

    // 前端配置
    {
        files: [
            "apps/frontend/**/*.{js,ts,tsx,vue}",
            "packages/components/**/*.{js,ts,tsx,vue}",
        ],
        extends: [
            ...vuePlugin.configs["flat/recommended"],
            eslintConfigPrettier,
        ],
        languageOptions: {
            globals: {
                ...globals.browser,
            },
        },
    },

    // 后端配置
    {
        files: [
            "apps/backend/**/*.{js,ts,tsx}",
            "packages/utils/**/*.{js,ts,tsx}",
        ],
        languageOptions: {
            globals: {
                ...globals.node,
            },
        },
    },
]);