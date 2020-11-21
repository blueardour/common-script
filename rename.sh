
folder=config
src='strach'
src='stratch'
dst='scratch'

if [ "$1" != "" ]
then
  folder=$1
fi
if [ "$2" != "" ]
then
  src=$2
fi

lists=`ls $folder`

for i in $lists
do
  i=$folder/$i
  echo $i
  j="${i/$src/$dst}"
  if [ "$i" != "$j" ]
  then
    echo "Moving $i to $j"
    mv $i $j
  fi

  if [ "${i##*.}" == "tar" ] || [ "${i##*.}" == "pth" ]
  then
    continue
  fi
  grep $src $i
  if [ "$?" == "0" ]
  then
    echo "Seding $i"
    sed -i "s/$src/$dst/" $i
  fi
done

