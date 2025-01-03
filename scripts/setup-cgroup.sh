#!/bin/bash

. /etc/default/clash

function assert() {
    if ! "$@"; then
        echo "'$*' failed"
        exit 1
    fi
}

if [[ ! -d "/sys/fs/cgroup/net_cls_clash" ]];then
    assert mkdir -p /sys/fs/cgroup/net_cls_clash
    
    assert mount -t cgroup -o net_cls net_cls /sys/fs/cgroup/net_cls_clash
fi

assert mkdir -p /sys/fs/cgroup/net_cls_clash/bypass_proxy
echo "$BYPASS_CGROUP_CLASSID" | assert tee /sys/fs/cgroup/net_cls_clash/bypass_proxy/net_cls.classid
assert chmod 666 /sys/fs/cgroup/net_cls_clash/bypass_proxy/tasks
