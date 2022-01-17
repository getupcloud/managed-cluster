#!/bin/bash

source /etc/profile

pathmunge () {
    case ":${PATH}:" in
        *:"$1":*)
            ;;
        *)
            if [ "$2" = "after" ] ; then
                PATH=$PATH:$1
            else
                PATH=$1:$PATH
            fi
    esac
}

pathmunge ~/.local/bin
${DEVEL:-false} && pathmunge /repo/root/usr/local/bin || true
_kube_ps1_init || true
