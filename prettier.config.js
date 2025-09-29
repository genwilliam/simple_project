// prettier.config.js
/**
 * @type {import("prettier").Config}
 * @see https://www.prettier.cn/docs/options.html
 * @see https://prettier.io/docs/en/options.html
 */

export default {
	// 指定最大换行长度
	printWidth: 120,
	// 缩进制表符宽度 ｜ 空格数
	tabWidth: 2,
	// 使用制表符而不是空格缩进
	useTabs: true,
	// 在语句末尾打印分号
	semi: true,

	// 使用单引号而不是双引号
	singleQuote: true,
	// 在对象字面量属性中仅在需要时使用引号
	quoteProps: 'as-needed',
	// 使用单引号而不是双引号 JSX
	jsxSingleQuote: false,

	// 在多行逗号分隔的语法结构中打印尾随逗号
	trailingComma: 'all',
	// 在对象文字中的括号之间打印空格
	bracketSpacing: false,
	// 在多行 JSX 元素的 > 和 /> 之前打印换行符
	jsxBracketSameLine: false,
	// 箭头函数参数周围的括号
	arrowParens: 'avoid',
	// 指定要使用的解析器，不需要写文件开头的 @prettier
	requirePragma: false,
	// 可以在文件顶部插入一个特殊的注释来控制格式化，指定该文件已使用 prettier 格式化
	insertPragma: false,
	// 用于控制文本是否应该被换行以及如何进行换行
	proseWrap: 'preserve',
	// 在html中空格是否敏感的"css" - 遵守css显示属性的默认值 "strict" - 空格被认为是敏感的 "ignore" - 空格被认为是不敏感的
	htmlWhitespaceSensitivity: 'css',
	// 换行符使用 lf \n crlf \r\n cr \r auto
	endOfLine: 'auto',

	// 控制在Vue但文件组件中<script>和<style>标签的缩进
	vueIndentScriptAndStyle: false,

	rangeStart: 0,
	rangeEnd: Infinity,
};
