
update=$1
caffe_repo=/data/pretrained/caffe/popcount-net
onnx_repo=/data/pretrained/onnx/popcount-net
pytorch_repo=/data/pretrained/pytorch/popcount-net
ncnn_repo=/data/pretrained/ncnn/popcount-net
case=pytorch-resnet18-convert_onnx

if [ ! -e $onnx_repo/$case.onnx ] || [ "$update" != "" ];
then
  cd /workspace/git/popcount-net
  pwd
  bash convert_onnx.sh config.dorefa.eval.dali.fp.pytorch-r18
fi

if [ ! -e $onnx_repo/$case-update.onnx ] || [ "$update" != "" ];
then
  # advise version 1.3.0
  cd /workspace/git/onnx-simplifier  # folder of project: https://github.com/daquexian/onnx-simplifier
  pwd
  python -m onnxsim $onnx_repo/$case.onnx $onnx_repo/$case-update.onnx
fi

# ncnn
if [ ! -e $ncnn_repo/$case-opt.bin ] || [ "$update" != "" ]
then
  cd /workspace/git/ncnn # folder of project: https://github.com/Tencent/ncnn
  pwd
  mkdir -p $ncnn_repo
  ./build-host-gcc-linux/tools/onnx/onnx2ncnn $onnx_repo/$case-update.onnx $ncnn_repo/$case-update.param $ncnn_repo/$case-update.bin
  if [ $? -eq 0 ]; then
    echo "Optimizing"
    ./build-host-gcc-linux/tools/ncnnoptimize $ncnn_repo/$case-update.param $ncnn_repo/$case-update.bin \
      $ncnn_repo/$case-update-opt.param $ncnn_repo/$case-update-opt.bin \
      0 #data 640 512 3
  else
    echo "Convert failed"
  fi
fi

