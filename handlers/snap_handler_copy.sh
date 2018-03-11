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

prog=$0
usage="Usage: $prog {src_path} {dst_path} {dst_name} [prepare | create ref | remove ref | list]"

assert () {
    condition=$1
    msg=$2
    if [ $condition -eq 0 ]; then
        echo $msg
        exit 1
    fi
}

if [ "$#" -lt 3 ]; then
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

ref=$1
dst=$dstPath/$dstName@$ref

case $action in
    "prepare")
        mkdir -p $dstPath
        [ -d $dstPath ] || exit 1
        ;;

    "create")
        assert $(expr $# == 1) "expecting single argument (reference name)"
        if [ -e $dst ]; then
            echo "$dst exists"
            exit 1
        fi
        cp -a $srcPath $dst
        ;;

    "remove")
        assert $(expr $# == 1) "expecting single argument (reference name)"
        ref=$1
        rm -r $dst
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

