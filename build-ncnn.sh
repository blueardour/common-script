
cd /workspace/git/ncnn
#bash build.sh 2>&1 | tee /workspace/git/scripts/build-ncnn.log
mkdir -p build-host-gcc-linux
pushd build-host-gcc-linux
cmake -DCMAKE_TOOLCHAIN_FILE=../toolchains/host.gcc.toolchain.cmake ..
make
make install
popd
cd -
