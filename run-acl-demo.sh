
remote=/data/local/tmp/acl
target=neoncl_convolution
if [ "$devices" != "" ]; then device="-s $devices"; fi
#echo "adb $device shell mkdir -p $remote"

if [ "$1" == "push" ]; then
  cd /workspace/git/ComputeLibrary/build/examples/
  adb $device shell mkdir -p $remote
  adb $device push $target $remote
  adb $device shell chmod 777 -R $remote/
  cd -
elif [ "$1" == "run" ]; then
  adb $device shell $remote/$target
  #adb shell ls -lh $remote
  #adb shell /data/local/tmp/ai-benchmark/diff $remote/cpu.txt $remote/gpu.txt
  #adb pull $remote
elif [ "$1" == "parse" ]; then
  grep 'time cost for execution gpu kernel' $2 | awk -F' ' '{ print $7 }'
else
  echo "$0 push | run"
fi
