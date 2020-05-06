
# refer: https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1699004
sudo nvme get-feature -f 0x0c -H /dev/nvme0

sudo nvme set-feature -f 0x0c -v=0 /dev/nvme0
