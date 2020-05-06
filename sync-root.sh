
rsync -avP --numeric-ids --exclude='/dev/*' --exclude='/proc/*' --exclude='/sys/*' --exclude='/run/*' --exclude='/snap/*' \
  --exclude='/mnt' \
  --exclude='/etc/fstab' \
  --exclude='/var/*' --exclude='/home/chenp/.vim*' --exclude='/home/chenp/.config' \
  --exclude='/boot'  --exclude='/boot/efi' \
  --exclude='/workspace'  --exclude='/data' \
  --exclude='/var/lib/docker' \
  / /mnt 2>&1 | tee /tmp/rsync.log

#  --ignore-errors\
#  --exclude='/usr/include' --exclude='/usr/src' --exclude='/usr/local' --exclude='/usr/share' \
