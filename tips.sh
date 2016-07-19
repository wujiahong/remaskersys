#!/bin/bash

# set -x

BRIDGE=xenbr0
FORWARD=eth1
CHECKPOINT=eth5

cp xend-config.sxp /etc/xen/

modprobe xen-evtchn
modprobe xen-gntdev
modprobe xen-gntalloc
modprobe sch_plug
/etc/init.d/xencommons start
/etc/init.d/xend start

# tip 1
rm -f /var/lib/xen/suspend_*

# tip 2
xm vcpu-pin 0 0 0
xm vcpu-pin 0 1 1
xm vcpu-pin 0 2 2
xm vcpu-pin 0 3 3

# tip 3
function bind_irq()
{
        #echo "$1"
        irq_list=($(grep "$1" /proc/interrupts| awk '{print $1}' | awk -F ':' '{print $1}'))
        irq_num=${#irq_list[@]}
        for ((i = 0; i < irq_num; i++)); do
                echo $2 >"/proc/irq/${irq_list[i]}/smp_affinity"
        done
}

# bind_irq 网卡 CPU
bind_irq $BRIDGE 2 # switch-client
bind_irq $FORWARD 4 # forward
bind_irq $CHECKPOINT 8 # checkpointt

# tip 4

# tip 5
function turn_off()
{
	ethtool -K $1 tso off
	ethtool -K $1 sg off
	ethtool -K $1 gso off
	ethtool -K $1 lro off
	ethtool -K $1 gro off
}
turn_off $BRIDGE
turn_off $FORWARD

# tip 6
# echo 1000000 >/proc/sys/net/core/rmem_max
# echo 1000000 >/proc/sys/net/core/wmem_max

# tip 7
echo "Please modify /site-packages/xen/xend/XendCheckpoint.py"

# tip 8 & 9
mkdir -p /root/yewei/source/pure/code

# tip 10
cp script/HA_fw_runtime.sh /root/yewei/source/pure/code/

# tip 11

# tip 12 & 13
echo "Please modify xend-config.sxp"

# tip 14
(cd script/; make install)

# tip 15

# tip 16
echo "Please modify HA_fw_runtim.sh"

