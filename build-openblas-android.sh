
export NDK_ROOT=/workspace/soft/android-ndk
export PATH=${NDK_ROOT}/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/bin/:${NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/bin:$PATH

# Setup LDFLAGS so that loader can find libgcc and pass -lm for sqrt
export LDFLAGS="-L${NDK_ROOT}/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/lib/gcc/aarch64-linux-android/4.9.x -lm"

# Setup the clang cross compile options
export CLANG_FLAGS="-target aarch64-linux-android --sysroot ${NDK_ROOT}/platforms/android-27/arch-arm64 -gcc-toolchain ${NDK_ROOT}/toolchains/aarch64-linux-android-4.9/prebuilt/linux-x86_64/"

-MMD -MP -MF 
-target aarch64-none-linux-android27
-fdata-sections -ffunction-sections -fstack-protector-strong -funwind-tables -no-canonical-prefixes  
--sysroot ${NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/sysroot

-g -Wno-invalid-command-line-argument -Wno-unused-command-line-argument  -fno-addrsig -fno-exceptions -fno-rtti -fpic -O2 -DNDEBUG  -I/workspace/git/opencl-cellphone/jni -I/workspace/git/OpenCL-Headers -I/workspace/soft/android-ndk-r19c/sources/cxx-stl/llvm-libc++/include -I/workspace/soft/android-ndk-r19c/sources/cxx-stl/llvm-libc++abi/include 

-std=c++11 -DANDROID  -nostdinc++ -Wa,--noexecstack -Wformat -Werror=format-security

# Compile
cd /workspace/git/OpenBLAS
make TARGET=ARMV8 ONLY_CBLAS=1 AR=ar CC="clang ${CLANG_FLAGS}" HOSTCC=gcc -j4  2>&1 | tee /workspace/git/script/log-build-openblas-android.txt
cd -

:
