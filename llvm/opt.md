# opt
opt命令是LLVM模块化的优化器和分析器。它将LLVM源文件作为输入，对其运行指定的优化或分析，然后输出优化文件或分析结果

```sh
opt -passes=dot-cfg main.ll -o main.dot
dot main.dot -Tpng -o main.png

opt -print-passes > opt.txt
```

## 自定义pass
[A collection of out-of-tree LLVM passes for teaching and learning](https://github.com/banach-space/llvm-tutor)

```sh
sudo apt install libedit-dev libzstd-dev 
rm -rf build && mkdir -p build && cd build
cmake -DLT_LLVM_INSTALL_DIR=/usr/lib/llvm-17
make
clang-17 -O1 -S -emit-llvm ../inputs/input_for_hello.c -o input_for_hello.ll
opt-17 -load-pass-plugin ./lib/libHelloWorld.so -passes=hello-world -disable-output input_for_hello.ll
opt-17 -load-pass-plugin ./lib/libOpcodeCounter.so --passes="print<opcode-counter>" -disable-output input_for_hello.ll


opt-17 -load-pass-plugin ./DFG/libDFGPass.so -passes=DFGPass -disable-output /home/wxg/test/llvm/SLang/test.bc


opt-17 -load ./DFG/libDFGPass.so --print-passes > opt.txt
```