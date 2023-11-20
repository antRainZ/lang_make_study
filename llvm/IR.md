# 简介
对于编译器IR的选择是非常重要的决定。它决定了优化器能够得到多少信息用以优化代码使之运行得更快
+ 非常高层的IR让优化器能够轻松地提炼出原始源代码的意图
+ 低层的IR让编译器能够更容易地生成为特定硬件优化的代码

LLVM设计的核心正是它的IR。它使用静态单赋值形式（SSA），具有两个重要特征：
+ 代码组织为三地址指令序列
+ 寄存器数量无限制

LLVM在编译的不同阶段采用不同的IR数据结构：
+ 在C或C++程序翻译为LLVM IR时，Clang用抽象语法树（AST）结构（TranslationUnitDecl class）表示驻留内存的程序。
+ 在LLVM IR翻译为一种机器特定的汇编语言时，LLVM首先将程序变换为有向无环图（DAG）形式，让指令选择（SelectionDAG class）变得容易，然后将它变换回三地址指令表示，让指令调度（MachineFunction class）顺利进行。
+ 为了实现汇编器和链接器，LLVM用第4种中间数据结构表示目标文件上下文中的程序。

LLVM IR作为一种编译器IR，它的两个基本原则指导着核心库的开发：
+ SSA 表示，代码组织为三地址指令序列和无限寄存器让优化能够快速执行
+ 整个程序的IR存储到磁盘让链接时优化易于实现

## SSA
当程序中的每个变量都有且只有一个赋值语句时，称一个程序是 SSA 形式的。LLVM IR 中，每个变量都在使用前都必须先定义，且每个变量只能被赋值一次。
每个值只有单一赋值定义了它。每次使用一个值，可以立刻向后追溯到给出其定义的唯一的指令。极大简化优化，因为SSA形式建立了平凡的use-def链，也就是一个值到达使用之处的定义的列表

## 表现形式
+ 磁盘上的人类可读文本表示, 类似于汇编代码，`.ll`
+ 磁盘上的以空间高效方式编码的位表示, 称为bitcode(位码), `.bc`
+ 驻留内存的表示（指令类等）

```sh
# 让Clang生成bitcode
clang main.c -emit-llvm -c -o main.bc
# 生成汇编表示
clang main.c -emit-llvm -S -c -o main.ll
# 汇编LLVM IR汇编文本
llvm-as main.ll -o main.bc
# 将bitcode变换为IR汇编
llvm-dis main.bc -o main.ll
# llvm-extract工具能提取IR函数、全局变量，还能从IR模块中删除全局变量
llvm-extract -func=sum main.bc -o main-fn.bc
```

# LLVM IR基本语法
+ LLVM IR 是类似于精简指令集（RISC）的底层虚拟指令集；
+ 和真实精简指令集一样，支持简单指令的线性序列，例如添加、相减、比较和分支；
+ 指令都是三地址形式，它们接受一定数量的输入然后在不同的寄存器中存储计算结果；
+ 与大多数精简指令集不同，LLVM 使用强类型的简单类型系统，并剥离了机器差异；
+ LLVM IR 不使用固定的命名寄存器，它使用以 ％ 字符命名的临时寄存器；

# IR 内存模型
LLVM IR 文件的基本单位称为 module
一个 module 中可以拥有多个顶层实体，比如 function 和 global variavle
一个 function define 中至少有一个 basicblock
每个 basicblock 中有若干 instruction，并且都以 terminator instruction 结尾

## Module
Module类聚合了整个翻译单元用到的所有数据，`它声明了Module::iterator typedef`，作为遍历这个模块中的函数的简便方法。可以用begin()和end()方法获取这些迭代器。

## Function
Function类包含有关函数定义和声明的所有对象。对于声明来说（用isDeclaration()检查它是否为声明），它仅包含函数原型。无论定义或者声明，它都包含函数参数的列表，可通过getArgumentList()方法或者arg_begin()和arg_end()这对方法访问它。可以通过`Function::arg_iterator typedef` 遍历

```cpp
// 如果Function对象代表函数定, 遍历它的基本块
for (Function::iterator i = function.begin(), e = function.end(); i != e; ++i) ;
```

## BasicBlock
BasicBlock类封装了LLVM指令序列，可通过begin()/end()访问它们。利用getTerminator()方法直接访问它的最后一条指令，还可以用一些辅助函数遍历CFG，例如通过getSinglePredecessor()访问前驱基本块，当一个基本块有单一前驱时。然而，如果它有多个前驱基本块，就需要自己遍历前驱列表，这也不难，你只要逐个遍历基本块，查看它们的终结指令的目标基本块。

## Instruction
Instruction类表示LLVM IR的运算原子，一个单一的指令。利用一些方法可获得高层级的断言，例如isAssociative()，isCommutative()，isIdempotent()，和isTerminator()，但是它的精确的功能可通过getOpcode()获知，它返回llvm::Instruction枚举的一个成员，代表了LLVM IR opcode。可通过op_begin()和op_end()这对方法访问它的操作数，它从User超类继承得到。

# 参考
+ [LLVM Language Reference Manual](https://llvm.org/docs/LangRef.html)
