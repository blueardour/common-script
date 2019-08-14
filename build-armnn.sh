 
export MY_TOOLCHAINS=$PWD/cross-compile

ln -s android-ndk-r18b android-ndk
echo $NDK
echo $MY_TOOLCHAINS
mkdir cross-compile
$NDK/build/tools/make_standalone_toolchain.py --arch arm64 --install-dir $MY_TOOLCHAINS/aarch64-linux-android-ndk-r17b --stl libc++ --api 21
$NDK/build/tools/make_standalone_toolchain.py --arch arm64 --install-dir $MY_TOOLCHAINS/aarch64-linux-android-ndk --stl libc++ --api 21
$NDK/build/tools/make_standalone_toolchain.py --arch arm --install-dir $MY_TOOLCHAINS/arm-linux-android-ndk --stl libc++ --api 21

export PATH=$PATH:$MY_TOOLCHAINS/aarch64-linux-android-ndk/bin:$MY_TOOLCHAINS/arm-linux-android-ndk/bin
echo $PATH

#########
root=/workspace/soft
cd $root
mkdir armnn-devenv
cd armnn-devenv/
sudo apt-get install git wget curl autoconf autogen automake libtool scons make cmake gcc g++ unzip bzip2

NPROC=`grep -c ^processor /proc/cpuinfo`
MEM=`awk '/MemTotal/ {print $2}' /proc/meminfo`
OpenCL=1
PREFIX=aarch64-linux-android-
echo $MEM
echo $NPROC

#########
mkdir pkg
cd pkg/
mkdir boost
cd boost/
wget https://dl.bintray.com/boostorg/release/1.64.0/source/boost_1_64_0.tar.bz2
tar xvf boost_1_64_0.tar.bz2 
cd boost_1_64_0/
./bootstrap.sh --prefix=$root/armnn-devenv/pkg/boost/install
cp tools/build/example/user-config.jam project-config.jam
sed -i "/# using gcc ;/c using gcc : arm : $PREFIX\g++ ;" project-config.jam
#vimdiff tools/build/example/user-config.jam project-config.jam 
Toolset="toolset=clang"
./b2 install link=static cxxflags=-fPIC $Toolset --with-filesystem --with-test --with-log --with-program_options --prefix=$root/armnn-devenv/pkg/boost/install

#########
cd /workspace/git/ComputeLibrary/
CXX=clang++ CC=clang scons Werror=1 debug=0 asserts=1 neon=1 opencl=1 embed_kernels=1 os=android arch=arm64-v8a extra_cxx_flags="-fPIC" -j $NPROC

#########
cd $root/armnn-devenv/
cd pkg/
git clone --branch 3.5.x https://github.com/protocolbuffers/protobuf.git
cd protobuf/
./autogen.sh 
mkdir host-build
cd host-build/
make -j $NPROC
make install
make clean
cd ..
mkdir build ; cd build
../configure --prefix /workspace/soft/armnn-devenv/pkg/install --host=arm-linux CC=$PREFIX\gcc CXX=$PREFIX\g++ --with-protoc=$root/armnn-devenv/pkg/host/bin/protoc
make -j $NPROC
#export LDFLAGS="-llog"
#make -j $NPROC
#cd /workspace/soft/armnn-devenv/pkg/protobuf/build/src
#aarch64-linux-android-g++ -DHAVE_PTHREAD=1 -DHAVE_ZLIB=1 -Wall -Wno-sign-compare -O2 -g -DNDEBUG -o .libs/protoc google/protobuf/compiler/main.o  ./.libs/libprotobuf.so ./.libs/libprotoc.so -lz -Wl,-rpath -Wl,/workspace/soft/armnn-devenv/pkg/install/lib
#aarch64-linux-android-g++ -DHAVE_PTHREAD=1 -DHAVE_ZLIB=1 -Wall -Wno-sign-compare -O2 -g -DNDEBUG -o .libs/protoc google/protobuf/compiler/main.o  ./.libs/libprotobuf.so ./.libs/libprotoc.so -lz -Wl,-rpath -Wl,/workspace/soft/armnn-devenv/pkg/install/lib -llog
#cd -
#make -j $NPROC
#LDFLAGS="-llog"
#make -j $NPROC
#../configure --prefix /workspace/soft/armnn-devenv/pkg/install --host=arm-linux CC=$PREFIX\gcc CXX=$PREFIX\g++ --with-protoc=/workspace/soft/armnn-devenv/pkg/host/bin/protoc
#make -j $NPROC
make install

export LD_LIBRARY_PATH=$root/armnn-devenv/pkg/install/lib:$LD_LIBRARY_PATH

#########
cd /workspace/git/
export ONNX_ML=1
git clone --recursive https://github.com/onnx/onnx.git
unset ONNX_ML
cd onnx
mkdir $root/armnn-devenv/pkg/onnx/
$root/armnn-devenv/pkg/host/bin/protoc onnx/onnx.proto --proto_path=. --proto_path=$root/armnn-devenv/pkg/host/include --cpp_out $root/armnn-devenv/pkg/onnx


#########
cd /workspace/git/
git clone https://github.com/ARM-software/armnn.git
git clone https://github.com/tensorflow/tensorflow.git
cd tensorflow/
bash /workspace/git/armnn/scripts/generate_tensorflow_protobuf.sh $root/armnn-devenv/pkg/tensorflow-protobuf $root/armnn-devenv/pkg/host


#########
cd /workspace/git/
cd caffe/src
mkdir -p $root/armnn-devenv/pkg/caffe
$root/armnn-devenv/pkg/host/bin/protoc caffe/proto/caffe.proto --proto_path=. --proto_path=$root/armnn-devenv/pkg/host/include --cpp_out $root/armnn-devenv/pkg/caffe


#########
cd /workspace/git/armnn
mkdir build ; cd build
CrossOptions="-DCMAKE_LINKER=aarch64-linux-android-ld -DCMAKE_C_COMPILER=aarch64-linux-android-gcc -DCMAKE_CXX_COMPILER=aarch64-linux-android-g++"

cmake ..  $CrossOptions \
  -DCMAKE_C_COMPILER_FLAGS=-fPIC \
  -DARMCOMPUTE_ROOT=/workspace/git/ComputeLibrary/ -DARMCOMPUTE_BUILD_DIR=/workspace/git/ComputeLibrary/build \
  -DBOOST_ROOT=$root/armnn-devenv/pkg/boost/install/ \
  -DBUILD_TF_PARSER=1 \
  -DBUILD_ONNX_PARSER=1 \
  -DBUILD_CAFFE_PARSER=1 \
  -DTF_GENERATED_SOURCES=$root/armnn-devenv/pkg/tensorflow-protobuf/ \
  -DONNX_GENERATED_SOURCES=$root/armnn-devenv/pkg/onnx \
  -DCAFFE_GENERATED_SOURCES=$root/armnn-devenv/pkg/caffe \
  -DPROTOBUF_ROOT=$root/armnn-devenv/pkg/install  \
  -DPROTOBUF_INCLUDE_DIRS=$root/armnn-devenv/pkg/install/include \
  -DPROFILING_BACKEND_STREAMLINE=0 \
  -DARMCOMPUTENEON=1 \
  -DARMCOMPUTECL=1 \
  -DPROTOBUF_LIBRARY_DEBUG=$root/armnn-devenv/pkg/install/lib/libprotobuf.so \
  -DPROTOBUF_LIBRARY_RELEASE=$root/armnn-devenv/pkg/install/lib/libprotobuf.so \
  -DCMAKE_CXX_FLAGS="-Wno-error=sign-conversion" \
  -DCMAKE_BUILD_TYPE=Debug

make -j $NPROC

