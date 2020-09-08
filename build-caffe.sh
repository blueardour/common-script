
download_caffe() {
  cd /workspace/git
  if [ ! -d caffe ]; then git clone https://github.com/BVLC/caffe; fi
  cd -
}

install_glog_gflags() {
  # gflags
  cd /workspace/downloads/
  if [ ! -e master.zip ]; then wget https://github.com/schuhschuh/gflags/archive/master.zip; fi
  if [ ! -d gflags-master ]; then unzip master.zip; fi
  cd gflags-master
  mkdir build && cd build
  export CXXFLAGS="-fPIC"
  cmake .. -DBUILD_SHARED_LIBS=ON -DBUILD_STATIC_LIBS=ON -DBUILD_gflags_LIB=ON
  make VERBOSE=1 -j8
  sudo make install
  cd -

  # glog
  cd /workspace/downloads/
  if [ ! -e v0.3.3.tar.gz ]; then wget https://github.com/google/glog/archive/v0.3.3.tar.gz; fi
  if [ ! -d glog-0.3.3 ]; then tar zxvf v0.3.3.tar.gz; fi
  cd glog-0.3.3
  export LD_LIBRARY_PATH='/usr/local/lib'
  ./configure
  make -j8
  sudo make install

  # scripts
  cd /workspace/git/scripts/
}

install_lmdb() {
  # lmdb
  cd /workspace/git
  git clone https://github.com/LMDB/lmdb
  cd lmdb/libraries/liblmdb
  make
  sudo make install
  cd -
}

install_protobuf () {
  cd /workspace/git
  if [ ! -d protobuf ]; then git clone https://github.com/protocolbuffers/protobuf; fi
  cd protobuf
  if [ ! -f configure ]; then
    git checkout master
    git submodule update --init --recursive
    ./autogen.sh
  fi
  git checkout v2.6.1
  mkdir -p /workspace/soft
  ./configure --prefix /workspace/soft
  make -j8
  make install
  cd -
}

install_boost()
{
  cd /workspace/soft
  if [ ! -f boost_1_58_0.tar.gz ]; then wget http://sourceforge.net/projects/boost/files/boost/1.58.0/boost_1_58_0.tar.gz; fi
  if [ ! -d boost_1_58_0 ]; then tar xvf boost_1_58_0.tar.gz; fi
  if [ ! -f boost_1_67_0.tar.gz ]; then wget https://dl.bintray.com/boostorg/release/1.67.0/source/boost_1_67_0.tar.gz; fi
  if [ ! -d boost_1_67_0 ]; then tar xvf boost_1_67_0.tar.gz; fi
  cd -
}

config_caffe() {
  cd /workspace/git/caffe
  #rm -rf build
  mkdir -p build
  cd build
  export PATH=/workspace/soft/bin:$PATH
  export LD_LIBRARY_PATH=/workspace/soft/lib:/usr/local/lib:$LD_LIBRARY_PATH
  cmake .. -DBUILD_SHARED_LIBS=ON -DUSE_LEVELDB=OFF \
    -DUSE_LEVELDB=OFF -DUSE_HDF5=ON -DUSE_LMDB=OFF \
    -DBLAS=open \
    -DPROTOBUF_INCLUDE_DIR=/workspace/soft/include -DPROTOBUF_LIBRARY=/workspace/soft/lib/libprotobuf.so \
    #-DBUILD_gflags_LIB=ON \
    #-DBOOST_ROOT=/workspace/soft/boost_1_58_0 \
    # note: not require the last three lines anymore
  cd /workspace/git/scripts
}

build_caffe() {
  cd /workspace/git/caffe/build
  make -j8
  cd -
}

caffe_prepare_code_and_dependence() {
  os=`awk -F= '/^NAME/{print $2}' /etc/os-release`
  if [ "$os" == "Ubuntu" ]; then sudo apt-get install autoconf gcc g++ cmake libboost-all-dev libhdf5-serial-dev libopencv-dev libopenblas-dev; fi
  if [ "$os" == "Centos" ]; then sudo yum install atlas-devel protobuf-devel leveldb-devel snappy-devel opencv-devel boost-devel hdf5-devel; fi

  download_caffe
  # consider add: add_compile_options(-std=c++11)
  install_glog_gflags

  # can not link correctly on current machine, use system installed one (3.0.0)
  # the reason may be the std=c++11 in new version gcc
  #install_protobuf

  #install_boost  # not reuqire on current machine
  config_caffe
}

#caffe_prepare_code_and_dependence

