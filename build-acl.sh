

#TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64
TOOLCHAIN=/workspace/soft/cross-compile/aarch64-linux-android-ndk
export PATH=$TOOLCHAIN/bin:$PATH
echo $PATH

cd /workspace/git/ComputeLibrary
CXX=clang++ CC=clang scons Werror=1 -j8 debug=0 asserts=1 neon=1 opencl=1 embed_kernels=1 os=android arch=arm64-v8a
cd -

