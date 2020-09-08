
src=/data/imagenet/
dst=/media/Windows-F/training-data/data/imagenet
folders=`ls $src/train`

split='train'
if [ "$2" != "" ]
then
  split=$2
fi
mkdir $src/$split-back -p
mkdir $dst/$split -p

count=10
if [ "$1" != "" ]
then
  count=$1
fi

index=0
for file in $folders
do
  echo "folder index $index"
  if [ $index -ge $count ]
  then
    break
  fi

  if [[ -L "$file" && -d "$file" ]]
  then
    index=`expr $index + 1`
    continue
  else
    echo "copying $src/$split/$file to $dst/$split/"
    cp -r $src/$split/$file $dst/$plsit/
    if [ -d $src/$split-back/$file ]
    then
      cp -r $src/$split/$file $src/$split-back/
    else
      mv $src/$split/$file $src/$split-back/
    fi

    echo "linking to $src/$split/$file from $dst/$split/"
    cd $src/$split && ln -s $dst/$split/$file . && cd -
    index=`expr $index + 1`
    continue
  fi
done

train=`find $src/train/ -name "*.JPEG" | wc -l`
val=`find $src/val/ -name "*.JPEG" | wc -l`
echo "get $train, expected 1281167. get $val, expected 50000"

#src=/home/xxx/dataset/imagenet
#if [ "$1" != "" ]; then src=$1; fi
#
#if [ ! -d /dev/shm/data/imagenet ]; then
#  mkdir -p /dev/shm/data/imagenet;
#  cp -rv $src/train /dev/shm/data/imagenet/
#  cp -rv $src/val /dev/shm/data/imagenet/
#fi
#
##lines = fp.readlines()
##fp.close()
##
##lines = [line.strip() for line in lines]
###for i, line in enumerate(lines):
###    if i > 800:
###        break
###    if i < 2:
###        continue
###    print(line)
###    shutil.copytree(src + line, 'train/' + line)
##
##      end = 0
##      for i, line in enumerate(lines):
##        if line == 'n03787032':
##        end = i
##        print(i)
##        if end > 0:
##          os.symlink(src + line, 'train/' + line)
#
#train=`find $dst/train/ -name "*.JPEG" | wc -l`
#val=`find $dst/val/ -name "*.JPEG" | wc -l`
#echo "get $train, expected 1281167. get $val, expected 50000"
