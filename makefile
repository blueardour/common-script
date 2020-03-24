
acl_remote=/data/local/tmp/acl
acl_target=neoncl_convolution

acl-build:
	bash build-acl.sh

acl-push:
	adb shell mkdir -p $(acl_remote)
	cd /workspace/git/ComputeLibrary/build/examples/; \
	adb push $(acl_target) $(acl_remote); \
	cd -
	adb shell chmod 777 -R $(acl_remote)/$(acl_target)

acl-run:
	adb shell $(acl_remote)/$(acl_target)

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


