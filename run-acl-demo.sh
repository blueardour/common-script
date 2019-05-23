
remote=/data/local/tmp/acl
target=neoncl_convolution

if [ "$1" == "push" ]; then
  cd /workspace/git/ComputeLibrary/build/examples/
  adb shell mkdir -p $remote
  adb push $target $remote
  adb shell chmod 777 -R $remote/
  cd -
elif [ "$1" == "run" ]; then
  adb shell $remote/$target
  adb shell ls -lh $remote
  adb shell /data/local/tmp/ai-benchmark/diff $remote/cpu.txt $remote/gpu.txt
  adb pull $remote
else
  echo "$0 push | run"
fi
