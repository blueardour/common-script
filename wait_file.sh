
if [ -f env.sh ]; then . env.sh; fi
export PATH
export LD_LIBRARY_PATH
user=`whoami`

wait_time() {
  echo "call sleep to wait $2"
  #sleep 1
  sleep $1
}

wait_file() {
  file=$1
  task=$2
  while true
  do
    if [ -f $file ];
    then
      echo "file exist";
      sbatch $task
      sleep 10
      bash task-loop.sh $task 4
      exit 2;
    fi
    wait_time 1m "${file} for task $task"
  done
}


wait_file  '../git/AdelaiDet/output/fcos/R_50_1x-Full-SyncBN-FixFPN-Shared/model_final.pth' m4-r50-fcos.sh

