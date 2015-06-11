#!/usr/bin/env bash

cd /sys/devices/platform/coretemp.0

host=${COLLECTD_HOSTNAME:=`hostname -f`}

while
    true
do
    LIST=$(ls | grep temp | cut -d"_" -f1 | sort | uniq)

    for f in ${LIST}
    do
        timestamp=$(date +%s)
        label="$(cat ${f}_label)"

        if
            ! (echo ${label} | grep -q "Core")
        then
            continue
        fi

        cpunum="$(echo ${label} | sed "s/Core //")"
        value="$(cat ${f}_input)"

        echo "PUTVAL \"${host}/core-temp/gauge-core_${cpunum}\" ${timestamp}:${value}"
    done

    sleep ${COLLECTD_INTERVAL:-10} || true
done
