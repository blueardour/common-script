

cd /workspace/git/ncnn
adb shell mkdir -p $remote
adb shell mkdir -p $remote/build-android-aarch64
adb push benchmark $remote/
adb push build-android-aarch64/benchmark $remote/build-android-aarch64/
cd -

