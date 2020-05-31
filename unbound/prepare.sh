#!/bin/bash

reserved=12582912
availableMemory=$((1024 * $( (grep MemAvailable /proc/meminfo || grep MemTotal /proc/meminfo) | sed 's/[^0-9]//g' ) ))
if [ $availableMemory -le $(($reserved * 2)) ]; then
    echo "Not enough memory" >&2
    exit 1
fi
availableMemory=$(($availableMemory - $reserved))
rr_cache_size=$(($availableMemory / 3))
# Use roughly twice as much rrset cache memory as msg cache memory
msg_cache_size=$(($rr_cache_size / 2))
nproc=$(nproc)
export nproc
if [ "$nproc" -gt 1 ]; then
    threads=$((nproc))
    slabs=$((nproc ** 2))
else
    threads=1
    slabs=4
fi

if [ -f /etc/unbound/unbound.conf ]; then
    sed -i \
        -e "s/@MSG_CACHE_SIZE@/${msg_cache_size}/g" \
        -e "s/@RR_CACHE_SIZE@/${rr_cache_size}/g" \
        -e "s/@THREADS@/${threads}/g" \
        -e "s/@SLABS@/${slabs}/g" \
        /etc/unbound/unbound.conf
fi

/usr/sbin/unbound-anchor -a /opt/unbound/root.key
chown unbound:unbound /opt/unbound/root.key