

bash /workspace/git/scripts/build-ncnn.sh
./fcos /workspace/git/uofa-AdelaiDet/output/test/input.jpg net.param net.bin 800 1088

cd /workspace/git/uofa-AdelaiDet
python demo/demo.py --config-file configs/FCOS-Detection/R_50_1x.yaml --input output/test/input.jpg --output output/test/output.jpg --opts MODEL.WEIGHTS /data/pretrained/pytorch/fcos/FCOS_R_50_1x_bn_head.pth MODEL.FCOS.NORM "BN" MODEL.DEVICE cpu



