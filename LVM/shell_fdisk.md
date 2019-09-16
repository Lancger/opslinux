```
cat > /tmp/disk.sh << \EOF
#!/bin/bash
echo "n
p
1


w
" | fdisk /dev/vdb && mkfs.ext4 /dev/vdb1
echo "/dev/vdb1 /data ext4 defaults 0 0" >> /etc/fstab
mkdir /data
mount /dev/vdb1 /data
df -h
EOF

chmod +x /tmp/disk.sh && sh /tmp/disk.sh

ln -s /data /data0
```

参考文档

https://jaminzhang.github.io/shell/Automated-Disk-Partion-Via-Shell-Script/  Shell 脚本自动化分区
