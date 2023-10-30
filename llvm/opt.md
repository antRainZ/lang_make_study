# opt
opt命令是LLVM模块化的优化器和分析器。它将LLVM源文件作为输入，对其运行指定的优化或分析，然后输出优化文件或分析结果

```sh
opt -passes=dot-cfg main.ll -o main.dot
dot main.dot -Tpng -o main.png
```