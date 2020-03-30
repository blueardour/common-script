
src=/home/LAB/chenpp/lcl/dataset/imagenet
if [ "$1" != "" ]; then src=$1; fi

if [ ! -d /dev/shm/data/imagenet ]; then
  mkdir -p /dev/shm/data/imagenet;
  cp -rv $src/train /dev/shm/data/imagenet/
  cp -rv $src/val /dev/shm/data/imagenet/
fi

#lines = fp.readlines()
#fp.close()
#
#lines = [line.strip() for line in lines]
##for i, line in enumerate(lines):
##    if i > 800:
##        break
##    if i < 2:
##        continue
##    print(line)
##    shutil.copytree(src + line, 'train/' + line)
#
#      end = 0
#      for i, line in enumerate(lines):
#        if line == 'n03787032':
#        end = i
#        print(i)
#        if end > 0:
#          os.symlink(src + line, 'train/' + line)

