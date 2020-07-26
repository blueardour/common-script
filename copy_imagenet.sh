
src=/data/imagenet/
dst=/media/Windows-C/training-data/data/imagenet
folders=`ls $src/train`

mkdir $src/train-back -p
mkdir $dst/train -p

count=10
if [ "$1" != "" ]
then
  count=$1
fi

index=0
for file in $folders
do
  echo "folder index $index"
  if [ $index -gt $count ]
  then
    break
  fi

  if [[ -L "$file" && -d "$file" ]]
  then
    index=`expr $index + 1`
    continue
  else
    echo "copying $src/train/$file to $dst/train/"
    cp -r $src/train/$file $dst/train/
    if [ -d $src/train-back/$file ]
    then
      cp -r $src/train/$file $src/train-back/
    else
      mv $src/train/$file $src/train-back/
    fi

    echo "linking to $src/train/$file from $dst/train/"
    cd $src/train && ln -s $dst/train/$file . && cd -
    index=`expr $index + 1`
    continue
  fi
done
