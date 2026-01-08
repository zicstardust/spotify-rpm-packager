#!/usr/bin/env bash

package_dir=$1

set -e
: "${KEEP_RPM:=0}"

if [ "${KEEP_RPM}" ==  "0" ]; then
    exit 0
fi

list_RPMs=($(ls ${package_dir}/))

if [ ${#list_RPMs[@]} -gt $KEEP_RPM ]; then
    delete_files_length=$((${#list_RPMs[@]}-$KEEP_RPM))

    i=0
    for file in "${list_RPMs[@]}"; do
        rm -f ${package_dir}/${file}
        echo "Deleted old RPM: $file"
        i=$(($i+1))
        if [ $i -eq $delete_files_length ]; then
            break
        fi
    done

fi
