
remote=/data/local/tmp/acl
target=neoncl_convolution

-include ../ai-benchmark/script/dvfs.mk

acl-build:
	bash build-acl-example.sh

acl-push:
	bash run-acl-demo.sh push

acl-run:
	bash run-acl-demo.sh run

diff:
	adb pull $(remote)/gpu.txt .
	adb pull $(remote)/cpu.txt .
	vimdiff gpu.txt cpu.txt

ncnn_remote=/data/local/tmp/ncnn
ncnn-push:
	cd /workspace/git/ncnn; \
	adb shell mkdir -p $(ncnn_remote); \
	adb shell mkdir -p $(ncnn_remote)/build-android-aarch64; \
	adb push benchmark $(ncnn_remote)/; \
	adb push build-android-aarch64/benchmark $(ncnn_remote)/build-android-aarch64/; \
	cd -

ncnn-run:
	make -f ../ai-benchmark/makefile fix-cpu fix-ddr
	make -f ../ai-benchmark/makefile dump-freq
	adb shell chmod 777 $(ncnn_remote)/build-android-aarch64/benchmark/benchncnn
	adb shell "cd $(ncnn_remote)/benchmark/ && ./../build-android-aarch64/benchmark/benchncnn"


