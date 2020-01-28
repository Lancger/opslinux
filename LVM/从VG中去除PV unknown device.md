```bash
[root@db-c-79 /data0]# pvdisplay
  WARNING: Device for PV i8vW0P-kbHo-the0-b9OC-gFCO-xMMi-t0lnOV not found or rejected by a filter.
  Couldn't find device with uuid i8vW0P-kbHo-the0-b9OC-gFCO-xMMi-t0lnOV.
  --- Physical volume ---
  PV Name               /dev/vdb1
  VG Name               vg_group
  PV Size               <200.00 GiB / not usable 3.00 MiB
  Allocatable           yes (but full)
  PE Size               4.00 MiB
  Total PE              51199
  Free PE               0
  Allocated PE          51199
  PV UUID               7nHbNb-N1sQ-o7Bv-Aobz-NOZ9-RoQN-th7iam

  --- Physical volume ---
  PV Name               /dev/vdb2
  VG Name               vg_group
  PV Size               100.00 GiB / not usable 4.00 MiB
  Allocatable           yes
  PE Size               4.00 MiB
  Total PE              25599
  Free PE               255
  Allocated PE          25344
  PV UUID               yFE87K-vf8H-itHp-QpAT-y16c-0hJn-H4LLQC

  --- Physical volume ---
  PV Name               [unknown]
  VG Name               vg_group
  PV Size               <100.00 GiB / not usable 3.00 MiB
  Allocatable           yes
  PE Size               4.00 MiB
  Total PE              25599
  Free PE               25599
  Allocated PE          0
  PV UUID               i8vW0P-kbHo-the0-b9OC-gFCO-xMMi-t0lnOV
```

```bash
#去除未知或已丢失的VG
vgreduce --removemissing /dev/vg_group

vgextend vg_group /dev/vdc1

lvextend -l +100%FREE /dev/vg_group/vg_data

xfs_growfs /dev/vg_group/vg_data 
```
参考资料：

http://www.bubuko.com/infodetail-1980717.html  从VG中去除PV unknown device
