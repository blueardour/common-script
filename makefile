
remote=/data/local/tmp/acl

build:
	bash build-acl-example.sh

push:
	adb shell mkdir -p $(remote)
	cd /workspace/git/ComputeLibrary/build/examples/; \
	adb push cl_ConvolutionLayer $(remote); \
	cd -
	adb shell chmod 777 -R $(remote)/

run: push
	adb shell $(remote)/cl_ConvolutionLayer
	adb shell ls -l $(remote)

diff:
	#adb shell diff $(remote)/cl_ConvolutionLayer.txt $(remote)/neon_ConvolutionLayer.txt
	adb pull $(remote)/gpu.txt .
	adb pull $(remote)/cpu.txt .
	vimdiff gpu.txt cpu.txt
