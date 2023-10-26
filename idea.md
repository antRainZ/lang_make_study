# 简介
+ 安装插件 `ANTLR v4`
+ 创建一个 `.g4` 文件，用于定义词法分析器（lexer）和语法解析器(Parser)
+ 在IDEA中右键点击 `.g4` 文件，选择Generate ANTLR Recognizer，插件会自动在gen目录下生成一堆Java代码，需要移动到对应的package中。
  + 如果定义了`@header`，IDEA也会自动生成package信息