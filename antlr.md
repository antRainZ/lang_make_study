# 简介
ANTLR v4是一款强大的语法分析器生成器，可以用来读取、处理、执行和转换结构化文本或二进制文件。通过称为文法的形式化语言描述，ANTLR可以为该语言自动生成词法分析器。生成的语法分析器可以自动构建语法分析树，它是表示文法如何匹配输入的数据结构。ANTLR还可以自动生成树遍历器，用来访问树节点以执行特定的代码。

ANTLR v4的语法分析器使用一种新的称为Adaptive LL(*)或ALL(*)的语法分析技术，它可以在生成的语法分析器执行前在运行时动态地而不是静态地执行语法分析。

```sh
curl https://www.antlr.org/download/antlr-4.13.1-complete.jar -o /usr/local/lib/antlr-complete.jar
# 设置class
export CLASSPATH=".:/usr/local/lib/antlr-complete.jar:$CLASSPATH" 
# 1) 起别名
alias antlr4='java -jar /usr/local/lib/antlr-complete.jar'
# 2) 通过脚本
cat > /usr/local/bin/antlr4.sh <<EOF
#!/bin/sh
java -cp .:./antlr-complete.jar:$CLASSPATH org.antlr.v4.Tool $*
EOF
```

## 入门
识别像hello xxx 那样短语的简单语法:
```java
// Hello.g4
grammar Hello;               // 定义语法的名字
s  : 'hello' ID ;            // 匹配关键字hello，后面跟着一个标志符
ID : [a-z]+ ;                // 匹配小写字母标志符
WS : [ \t\r\n]+ -> skip ;    // 跳过空格、制表符、回车符和换行符
```

编译:
```sh
# 该命令会在相同目录下生成后缀名为tokens和java的六个文件：
antlr4 Hello.g4
# 编译
javac *.java

# TestRig使用Java反射调用编译后的识别器
alias grun= 'java org.antlr.v4.gui.TestRig'
grun Hello s -tokens
# -tokens 打印出记号流。
# -tree 以LISP风格的文本形式打印出语法分析树。
# -gui 在对话框中可视化地显示语法分析树。
# -ps file.ps 在PostScript中生成一个可视化的语法分析树表示，并把它存储在file.ps文件中。
# -encoding encodingname 指定输入文件的编码。
# -trace 在进入/退出规则前打印规则名字和当前的记号。
# -diagnostics 分析时打开诊断消息。此生成消息仅用于异常情况，如二义性输入短语。
# -SLL 使用更快但稍弱的分析策略。
```

## 基本概念
一门语言由有效的句子组成，一个句子由短语组成，一个短语由子短语和词汇符号组成。
识别语言的程序被称为语法分析器。语法指代控制语言成员的规则，每条规则都表示一个短语的结构。
把字符组成单词或符号（记号）的过程被称为词法分析或简单标记化。词法分析器能把相关的记号组成记号类型，记号至少包含两块信息：记号类型（确定词法结构）和匹配记号的文本。
语法分析树的内部节点是分组和确认它们子节点的短语名字。根节点是最抽象的短语名字, 语法分析树的叶子节点永远是输入记号

## 实现语法分析器
ANTLR工具根据语法规则，生成递归下降语法分析器
```java
// assign : ID '=' expr ;
void assign() {    // 根据规则assign生成的方法
    match(ID);     // 比较ID和当前输入符号然后消费
    match('=');
    expr();        // 通过调用expr()匹配表达式
}
```

## 语法分析树

ANTLR类分别是CharStream、Lexer、Token、Parser和ParseTree。连接词法分析器和语法分析器的管道被称为TokenStream
ParseTree的子类RuleNode和TerminalNode以及它们所对应的子树根节点和叶子节点
每个上下文对象知道被识别短语的开始和结束记号以及提供对所有短语的元素的访问

## 监听器和访问者
默认情况下，ANTLR生成一个语法分析树Listener接口，在其中定义了回调方法，用于响应被内建的树遍历器触发的事件。
在Listener和Visitor机制之间最大的不同是：Listener方法被ANTLR提供的遍历器对象调用；
而Visitor方法必须显式的调用visit方法遍历它们的子节点，在一个节点的子节点上如果忘记调用visit方法就意味着那些子树没有得到访问。

## 词法分析特性
+ 孤岛语法: 处理相同文件中的不同格式
+ 重写输入流: 源代码插桩或者重构
+ 将词法符号送入不同通道

# 语法
四种抽象的计算机语言模式
+ 序列, 即一列元素
+ 选择
+ 词法符号依赖: 一个词法符号需要和某处的另外一个词法符号配对
+ 嵌套结构: 一种自相似的语言结构, 如嵌套算术表达式或者嵌套语句块

antlr 提供可选方案,词法符号引用和规则引用(BNF), 划分成子规则(用括号包围的内)

语法由一个为该语法命名的头部定义和一系列可以相互引用的语言规则组成:
```java
/* Optional javadoc style comment*/
// 文件命名必须和grammar命名相同,如 grammar T,文件名必须命名为T.g4.
grammer Name; 
options {…}; 
import …; 
tokens {…}; 
channels {…}; 
@actionName** {…}; 
rule1: <<stuff>> //parser and lexer rules 
… 
ruleN 
```

options,imports,token,action的声明顺序没有要求,但一个文件中options,imports,token最多只能声明一次.
grammar是必须声明的,同时必须至少声明一条规则(rule),其余的部分都是可选的.

## 关键字

```sh
import, fragment, lexer, parser, grammar, returns, locals, 
throws, catch, finally, mode, options, tokens
```

引入(imports): 会从引入的文件继承所有的规则,词法单元,动作.然后主文件中的元素会”覆盖”引入文件中的重名元素.

## 注释(Comments)
支持单行注释,多行注释,和javadoc风格的注释

## 标识符(Identifiers)
词法单元和词法规则通常以大写字母命名
解析规则(parser rule) 以小写字母开头命名(驼峰命名法)

## 文字(Literals)
ANTLR不区分字符和字符串.所有的字符串都是由单引号引用起来的字符,但是像这样的字符串中不包括正则表达式.支持unicode和转义符号

## 动作(Actions)
动作是用目标语言书写的代码块.嵌入的代码可以出现在:
+ @header @members这样的命名动作中
  + `@header` 在生成的目标代码中的类定义之前注入代码
  + `@members` 在生成的目标代码中的类定义里注入代码(例如类的属性和方法)
+ 解析规则和词法规则中
+ 异常捕获中
+ 解析规则的属性部分(返回值,参数等)
+ 一些规则可选元素中

## 规则(rules)

```sh
ruleName : alternative1 | ... | alternativeN ;
# 定义类型
type : 'int' | 'unsigned' | 'long'
```

### 子规则
规则中包含的可选块称为子规则(被封闭在括号中).子规则也可以看做规则(rule),但是没有显式的命名.子规则不能定义局部变量,也没有返回值.如果子规则只有一个元素,括号可以省略.

```sh
(x|y|z) 只匹配一个选项
(x|y|z)? 匹配一个或者不匹配
(x|y|z)* 匹配零次或多次
(x|y|z)+ 匹配一次或多次
```

## 词法单元

```sh
tokens {Token1 ... TokenN}
```

## 处理优先级, 左递归和结合性
+ 隐式指定优先级: 通过选择位置靠前的备选分支来解决歧义问题
+ 结合性: 默认是左结合, 通过 assoc 指定
+ 左递归: 在某个备选分支的最左侧以直接或者间接方式调用了自身

```sh
expr: <assoc=right> expr '^' expr 
    | INT
    ;
```

# 解析器规则(Parser Rules)
解析器由一组解析器规则组成.java应用通过调用生成的规则函数(每个规则会生成一个函数)来启动解析.

```sh
stat : restat | 'break' ';' | 'continue' ';' ;
```

## 可选标签(Alternative Labels)
可以在规则中添加标签,ANTLR会根据标签生成与规则相关的解析树的事件监听函数,可以更加精准的控制解析过程.用 `#`` 操作符定义一个标签
```sh
grammar T;
stat: 'return' e ';' # Return
    | 'break' ';' # Break
```

ANTLR会为每个标签生成一个rule-context类: 
```java
public interface AListener extends ParseTreeListener {
 	void enterReturn(AParser.ReturnContext ctx);
 	void exitReturn(AParser.ReturnContext ctx);
 	void enterBreak(AParser.BreakContext ctx);
 	void exitBreak(AParser.BreakContext ctx);
}
```

## 规则上下文对象(Rule Context Objects)
ANTLR为每个规则生成一个上下文对象,通过这个对象可以访问规则定义中的其他规则的引用
根据规则定义中的其他规则的引用数量不同,生成对象中包含的方法也不同

## 规则元素标签(Rule Element Labels)
可以用 `=` 操作符为规则中的元素添加标签,这样会在规则的上下文对象中添加元素的字段.
`+=` 操作符可以很方便的记录大量的token或者规则的引用


## 规则元素(Rule ELements)
规则元素指定了解析器在具体时刻应该执行什么任务.元素可以是规则(rule), 词法单元(token), 字符串文字(string literal)等
+ T token
+ ‘literal’ 字符串文字
+ r 规则
+ r[args] 向规则函数中传递参数,参数的书写规则是目标语言,用逗号分隔
+ . 通配符
+ {action} 动作,在元素的间隔中执行
+ {p} 谓词
+ 支持逻辑非操作符:~

## 捕获异常(Catching Exception)
当规则中出现语法错误,ANTLR可以捕获异常,报告错误和尝试恢复(possibly by consuming more tokens),然后从规则中返回.
ANLTR通过策略模式来处理所有的异常,也可以为某个规则通过指定特定的异常处理:在规则末尾添加catch语句.

```java
r : ...
 	; 
 	catch[RecognitionException e] { throw e; }
```

## 规则属性定义(Rule Attribute Definition)
可以像编程语言中的函数那样,在规则中定义参数,返回值,局部变量,定义的这些属性会保存在规则上下文对象中(rule context object).

```java
rulename [args] returns [retvals] locals [localvars]: ...;
//[..]中定义的变量可以在定义之后使用
add [int x] returns [int result] : '+=' INT {$result = $x + $INT.int;};
```

和语法层面的动作(action)一样,可以定义规则层面的动作.合法的动作名是:init,after.像这些动作的命名一样,
解析器会在匹配相应的规则之前执行init动作,在规则匹配完成之后执行after动作.

```java
/** Derived from rule "row : field (',' field)* '\r'? '\n' ;" */
row[String[] columns] returns [Map<String,String> values]
locals [int col=0]
@init {
a$values = new HashMap<String,String>();
}
@after {
    if ($values!=null && $values.size()>0) {
        System.out.println("values = "+$values);
    }
}
```

# 参考
+ ANTLR4权威指南
+ [ANTLR 4简明教程](https://www.bookstack.cn/books/antlr4-short-course)
+ [Antlr4系列（二）：实现一个计算器](https://zhuanlan.zhihu.com/p/546679086)