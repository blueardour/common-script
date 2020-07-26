
if [ -f env.sh ]; then . env.sh; fi
export PATH
export LD_LIBRARY_PATH
user=`whoami`

wait_time() {
  echo "call sleep to wait $2"
  #sleep 1
  sleep $1
}

task_queue() {
  expect=$3
  loop=$2
  task=$1
  if [ "$expect" -le "$loop" ]; then exit 0; fi
  if [ ! -f $task ]; then exit 1; fi
  echo "call queue task"
  date
  sbatch $task
  wait_time 1m
}


task_loop() {
  if [ "$1" == "" ]; then return; fi
  echo "Run script $1"
  task_name=$1
  task_prefix=`echo $task_name | cut -c1-8`
  task_id='xxxxx'

  expect=$2
  loop=0

  while true
  do
    task_list=`squeue -u $user -h -r -n $task_name | grep $task_prefix`
    if [ $? -eq 0 ]
    then
      task_id=`echo $task_list | cut -d' ' -f1` 
      echo "tracking task with id: ${task_id}. Executing $loop in $expect"
      wait_time 1m
      continue
    else
      echo "$task_list not in volta queue"
    fi

    task_list=`squeue -u $user -M volta -h -r -n $task_name | grep $task_prefix`
    if [ $? -eq 0 ]
    then
      task_id=`echo $task_list | cut -d' ' -f1` 
      echo "tracking task with id: ${task_id}. Executing $loop in $expect"
      wait_time 1m
      continue
    else
      echo "$task_list not in M queue"
    fi

    if [ ! -f slurm-${task_id}.out ]; then wait_time 1m "slurm file not exist"; continue; fi
    grep 'DUE TO TIME LIMIT' slurm-${task_id}.out
    result=$?
    if [ $result -eq 0 ]; then task_queue $task_name $loop $expect; loop=`expr $loop + 1`; task_id='xxxxx'; fi
    if [ $result -eq 2 ]; then task_queue $task_name $loop $expect; loop=`expr $loop + 1`; task_id='xxxxx'; fi
    if [ $result -eq 1 ]; then echo "the script probably meet error"; exit 2;  fi
    wait_time 5 "${task_id} for reason $result"
  done
}

if [ "$1" != "" ]; then script=$1; else script=''; fi
if [ "$2" != "" ]; then expect=$2; else expect=3; fi
if [ "$LD_LIBRARY_PATH" == "" ]; then echo "[warning]: Seems the LD_LIBRARY_PATH is not set"; wait_time 5; fi
task_loop $script $expect


