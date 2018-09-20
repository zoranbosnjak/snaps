#!/usr/bin/env bash

# 'copy' handler for snaps

# Copyright 2018 Zoran Bošnjak

# Author: Zoran Bošnjak <zoran.bosnjak@via.si>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

assert () {
    condition=$1
    msg=$2
    if [ $condition -eq 0 ]; then
        echo $msg
        exit 1
    fi
}

set -e
set -u

use_links="yes";

usage="Usage: $(basename $0) [-c] [-e rsync exclude ...] {src_path} {dst_path} {dst_name} [prepare | create ref [ref-1 ...] | remove ref | list]"

excludes=()
# handle -e {exclude} ... options
while getopts 'ce:' OPTION; do
    case "$OPTION" in
        c)
            use_links="no";
            ;;
        e)
            excludes+=("$OPTARG")
            ;;
        ?)
            echo $usage >&2
            exit 1
            ;;
    esac
done
shift "$(($OPTIND -1))"

exclude=""
for val in "${excludes[@]}"; do
    exclude="$exclude --exclude $val";
done

if [ "$#" -lt 4 ]; then
    echo "Too few arguments!"
    echo $usage
    exit 1
fi

srcPath=$1
dstPath=$2
dstName=$3
action=$4
shift
shift
shift
shift

case $action in
    "prepare")
        assert $(expr $# == 0) "unexpected arguments $@"
        mkdir -p $dstPath
        [ -d $dstPath ] || exit 1
        ;;

    "create")
        assert $(expr $# ">=" 1) "expecting {target ref} [{ref...}]"
        ref=$1
        shift
        dst=$dstPath/$dstName@$ref
        if [ -e $dst ]; then
            echo "$dst exists"
            exit 1
        fi

        cmd="rsync -a $exclude"
        # no history
        if [[ $use_links = "no" || $# -eq 0 ]]; then
            $cmd $srcPath $dst
        # history exists, use it to save space
        else
            prev=""
            for i in $*; do
                prev="$prev --link-dest=../$dstName@$i"
            done
            $cmd $prev $srcPath $dst
        fi
        ;;

    "remove")
        assert $(expr $# == 1) "expecting single argument (reference name)"
        ref=$1
        dst=$dstPath/$dstName@$ref
        rm -rf $dst
        ;;

    "list")
        assert $(expr $# == 0) "unexpected arguments $@"
        ls $dstPath | grep "$dstName@" | sed 's/.*@//'
        ;;

    *)
        echo $usage
        exit 1
        ;;
esac

