
cd /workspace/git/hao-fcos
mkdir -p ../../data/maskrcnn-benchmark/datasets
ln -s ../../data/maskrcnn-benchmark/datasets .
mkdir -p datasets/coco datasets/voc
cd datasets/coco
ln -s ../../../../data/coco/annotations .
ln -s ../../../../data/coco/train2017 .
ln -s ../../../../data/coco/val2017 .
ln -s ../../../../data/coco/test2017 .
cd ../../
