#!/usr/bin/env bash

# zfs handler for snaps

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
usage="Usage: $prog {dataset} [prepare | create ref ... | remove ref | list]"

assert () {
    condition=$1
    msg=$2
    if [ $condition -eq 0 ]; then
        echo $msg
        exit 1
    fi
}

if [ "$#" -lt 2 ]; then
    echo "Too few arguments!"
    echo $usage
    exit 1
fi

dataset=$1
action=$2
shift
shift

case $action in
    "prepare")
        assert $(expr $# == 0) "unexpected arguments $@"
        ;;

    "create")
        assert $(expr $# ">=" 1) "expecting {target ref} [{ref...}]"

        ref=$1
        zfs snapshot $dataset@cyclic-$ref
        ;;

    "remove")
        assert $(expr $# == 1) "expecting single argument (reference name)"
        ref=$1
        zfs destroy $dataset@cyclic-$ref
        ;;

    "list")
        assert $(expr $# == 0) "unexpected arguments $@"
        zfs list -t snapshot -o name | grep "$dataset@cyclic-" | sed 's/.*@cyclic-//'
        ;;

    *)
        echo $usage
        exit 1
        ;;
esac

