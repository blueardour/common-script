
if [ "$1" == "update" ];
then
  update='update'
else
  update=
fi

if [ "$1" == "test" ];
then
  onnx_rt='test'
else
  onnx_rt=
fi

FASTDIR=~/workspace

# https://cloudstor.aarnet.edu.au/plus/s/hI15l4ChWFqWvHp/download
pytorch_model=$PWD/weights/RT_R_50_4x_bn-head_syncbn_shtw.pth
onnx_repo=$PWD/weights/

config=configs/BlendMask/RT_R_50_4x_bn-head_syncbn_shtw.yaml
case=blendmask-bn-head
height=640
width=480

if [ ! -e $onnx_repo/$case.onnx ] || [ "$update" != "" ];
then
  cd $FASTDIR/git/uofa-AdelaiDet/ # folder of project https://github.com/aim-uofa/AdelaiDet
  pwd
  python -V # ensure python3.x
  python onnx/export_model_to_onnx.py \
    --config-file $config \
    --output $onnx_repo/$case.onnx \
    --width $width --height $height \
    --opts MODEL.WEIGHTS $pytorch_model MODEL.DEVICE cpu
  if [ $? -ne 0 ]; then exit; fi
fi

exit

if [ ! -e $onnx_repo/$case-update.onnx ] || [ "$update" != "" ];
then
  # advise version 1.3.0
  cd $FASTDIR/git/onnx-simplifier  # folder of project: git clone https://github.com/daquexian/onnx-simplifier && cd onnx-simplifier && git checkout 0.1.3
  pwd
  python -V # ensure python3.x
  #python -c 'import onnsim; print("onnxsim version", __version__)'
  pip show onnx
  python -m onnxsim $onnx_repo/$case.onnx $onnx_repo/$case-update.onnx
  if [ $? -ne 0 ]; then exit; fi
fi

