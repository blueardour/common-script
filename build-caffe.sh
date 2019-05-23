
download_caffe() {
  cd /workspace/git
  git clone https://github.com/BVLC/caffe
  cd -
}

install_glog_gflags() {
  # glog
  cd /workspace/downloads/
  if [ ! -e v0.3.3.tar.gz ]; then wget https://github.com/google/glog/archive/v0.3.3.tar.gz; fi
  tar zxvf v0.3.3.tar.gz
  cd glog-0.3.3
  ./configure --prefix /workspace/soft
  make
  make install

  # gflags
  cd /workspace/downloads/
  if [ ! -e master.zip ]; then wget https://github.com/schuhschuh/gflags/archive/master.zip; fi
  unzip master.zip
  cd gflags-master
  mkdir build && cd build
  export CXXFLAGS="-fPIC" && cmake .. && make VERBOSE=1
  make --prefix /workspace/soft
  make install
  cd -
}

install_lmdb() {
  # lmdb
  cd /workspace/git
  git clone https://github.com/LMDB/lmdb
  cd lmdb/libraries/liblmdb
  make
  make install
  cd -
}

install_protobuf () {
  cd /workspace/git
  git clone https://github.com/protocolbuffers/protobuf
  cd protobuf
  git checkout v2.6.1
  ./configure --prefix /workspace/soft
  make -j8
  make install
  cd -
}

config_caffe() {
  cd /workspace/git/caffe
  rm -rf build
  mkdir -p build
  cd build
  export PATH=/workspace/soft/bin:$PATH
  export LD_LIBRARY_PATH=/workspace/soft/lib:/usr/local/lib:$LD_LIBRARY_PATH
  cmake .. -DBUILD_SHARED_LIBS=ON -DBUILD_gflags_LIB=ON -DUSE_LEVELDB=OFF \
    -DPROTOBUF_INCLUDE_DIR=/workspace/soft/include -DPROTOBUF_LIBRARY=/workspace/soft/lib/libprotobuf.so
}

build_caffe() {
  cd /workspace/git/caffe/build
  make -j8
  cd -
}


