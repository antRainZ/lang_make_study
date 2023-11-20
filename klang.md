# 项目1
[K Programming Language](https://kdbohne.github.io/klang)

# 项目2
[A procedural programming language built on antlr4 and LLVM](https://github.com/lepoidev/klang)

```sh
# 网络不好, 直接修改 cmake/DownloadAntlr4Jar.cmake 为copy

```

针对 antlr clone 缓慢问题 可以先复制仓库到文本 (单独克隆没有问题, 但是make 中克隆也比较慢(可能网速慢,没有输出日志))

```sh
# 然后修改clone 本地
# cmake/ExternalAntlr4Cpp.cmake
set(ANTLR4_GIT_REPOSITORY /home/wxg/test/llvm/antlr4)

# 内部构建需要 clone utfcpp
# build/antlr4_runtime/src/antlr4_runtime/runtime/Cpp/runtime/cmake_install.cmake L:8
GIT_REPOSITORY        "/home/wxg/test/llvm/utfcpp"

# 构建 utfcpp 需要gtest
build/antlr4_runtime/src/antlr4_runtime/runtime/Cpp/runtime/thirdparty/utfcpp/.gitmodules
url = /home/wxg/test/llvm/googletest
```