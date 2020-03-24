#TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/linux-x86_64
TOOLCHAIN=/workspace/soft/cross-compile/aarch64-linux-android-ndk
export PATH=$TOOLCHAIN/bin:$PATH
echo $PATH

target=neoncl_gemm
cd /workspace/git/ComputeLibrary

aarch64-linux-android-clang++ -o build/examples/$target.o -c -Wno-deprecated-declarations -Wall -DARCH_ARM -Wextra -Wno-unused-parameter -pedantic -Wdisabled-optimization -Wformat=2 -Winit-self -Wstrict-overflow=2 -Wswitch-default -fpermissive -std=gnu++11 -Wno-vla -Woverloaded-virtual -Wctor-dtor-privacy -Wsign-promo -Weffc++ -Wno-format-nonliteral -Wno-overlength-strings -Wno-strict-overflow -Wno-format-nonliteral -Wno-deprecated-increment-bool -Wno-vla-extension -Wno-mismatched-tags -march=armv8-a -no-integrated-as -Werror -O3 -fstack-protector-strong -DARM_COMPUTE_CL -Iinclude -I. -I. examples/$target.cpp

aarch64-linux-android-clang++ -o build/examples/$target -pie -static-libstdc++ build/examples/$target.o build/utils/Utils.o -Lbuild -L. build/libarm_compute-static.a build/libarm_compute_core-static.a

cd -

