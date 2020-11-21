
rsync -avP --numeric-ids --exclude='/dev/*' --exclude='/proc/*' --exclude='/sys/*' --exclude='/run/*' --exclude='/snap/*' \
  --exclude='/mnt' \
  --exclude='/etc/fstab' \
  --exclude='/boot'  --exclude='/boot/efi' \
  --exclude='/workspace'  --exclude='/data' --exclude='/backup' \
  / /mnt 2>&1 | tee /tmp/rsync.log

#  --ignore-errors\
