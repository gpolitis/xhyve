#!/bin/sh

PATH="build/Release:build:$PATH"

XHYVE_HOME=${XHYVE_HOME:-"$HOME/Virtual Machines"}
XHYVE_ENV="$1"

if [ ! -f "$XHYVE_ENV" ]; then
    # Try to find the environment file in the XHYVE_HOME directory.
    XHYVE_ENV="$XHYVE_HOME/$XHYVE_ENV"

    if [ ! -f "$XHYVE_ENV" ]; then

        XHYVE_ENV="$XHYVE_ENV.env"

        if [ ! -f "$XHYVE_ENV" ]; then
            echo "Usage: $0 env-file" 1>&2
            exit 1
        fi
    fi
fi

source "$XHYVE_ENV"

case "$XHYVE_VMLINUZ" in
    /*)
        break
        ;;
    *)
        XHYVE_VMLINUZ=`dirname "$XHYVE_ENV"`/$XHYVE_VMLINUZ
        ;;
esac

case "$XHYVE_INITRD" in
    /*)
        break
        ;;
    *)
        XHYVE_INITRD=`dirname "$XHYVE_ENV"`/$XHYVE_INITRD
        ;;
esac

case "$XHYVE_DISK" in
    /*)
        break
        ;;
    *)
        XHYVE_DISK=`dirname "$XHYVE_ENV"`/$XHYVE_DISK
        ;;
esac


exec xhyve \
    -A \
    -c $XHYVE_CPU \
    -m $XHYVE_MEM \
    -s 0:0,hostbridge \
    -s 2,virtio-net \
    -s 4,virtio-blk,"$XHYVE_DISK" \
    -s 31,lpc \
    -l com1,stdio \
    -f "kexec,$XHYVE_VMLINUZ,$XHYVE_INITRD,earlyprintk=serial console=ttyS0 root=/dev/vda1 ro ds=nocloud-net;s=$XHYVE_URL"
