#!/bin/bash
set -e

# clean start
rm -rf BLD/build/vmkdriver-r8125

VERSION="9.011.00"


# Use gcc version 4.4.3-2
# Below is the internal VMWare location.  Please change as required for your
# installed location.
CC=/build/toolchain/lin64/gcc-4.8.0/bin/x86_64-linux-gcc
# Use ld from binutils-2.20.1-1
# Below is the internal VMWare location.  Please change as required for your
# installed location.
LD=/build/toolchain/lin64/binutils-2.22/bin/x86_64-linux-ld

# ENABLE_USE_FIRMWARE_FILE
CONFIG_FLAGS="-DENABLE_TX_NO_CLOSE -DCONFIG_R8125_VLAN  \
    -DDISABLE_PM_SUPPORT -DRTL8125_DEBUG -DCONFIG_SOC_LAN -DENABLE_S0_MAGIC_PACKET -DENABLE_S5WOL \
    -DCONFIG_NET_POLL_CONTROLLER -DDENABLE_RSS_SUPPORT \
    " # -DCONFIG_R8125_NAPI -DENABLE_PAUSE -DENABLE_PTP_SUPPORT "  # -DCONFIG_SOC_LAN -DCONFIG_ESD -DENABLE_PAGE_REUSE -DENABLE_RX_PACKET_FRAGMENT 
# -DENABLE_DASH_SUPPORT -DENABLE_PTP_SUPPORT -DCONFIG_HW_HACK -DRTL_USE_NEW_INTR_API
 
# PR# 976913 requested that OSS binaries be stripped of debug
LD_OPTS=--strip-debug
SYS_ROOT=/nowhere

COMP_FLAGS="--sysroot=$SYS_ROOT -fwrapv -pipe -fno-strict-aliasing -Wno-unused-but-set-variable -fno-working-directory \
    -g -ggdb3 -O3 -mcmodel=smallhigh -Wall -Werror -Wstrict-prototypes -fno-strict-aliasing -freg-struct-return -falign-jumps=1 \
    -falign-functions=4 -falign-loops=1 -m64 -mno-red-zone -mpreferred-stack-boundary=4 -minline-all-stringops -mno-mmx -mno-3dnow \
    -mno-sse -mno-sse2 -mcld -finline-limit=2000 -fno-common -ffreestanding -nostdinc -fomit-frame-pointer -nostdlib \
    --sysroot=$SYS_ROOT -Wno-error -Wdeclaration-after-statement -Wno-pointer-sign -Wno-strict-prototypes -Wno-enum-compare \
    -Wno-switch -Wno-declaration-after-statement -Wno-declaration-after-statement -Wno-declaration-after-statement"

I_SYSTEM=/build/toolchain/lin64/gcc-4.8.0/lib/gcc/x86_64-linux/4.8.0/include
INCLUDES="-isystem $I_SYSTEM -Ivmkdrivers/src_9/drivers/net/r8125 -IBLD/build/HEADERS/vmkdrivers-vmkernel/vmkernel64/release \
    -IBLD/build/version -Ivmkdrivers/src_92/include -Ivmkdrivers/src_92/include/vmklinux_92 \
    -IBLD/build/HEADERS/92-vmkdrivers-asm-x64/vmkernel64/release -Ivmkdrivers/src_92/drivers/net \
    -IBLD/build/HEADERS/vmkapi-v2_3_0_0-all-public-bincomp/generic/release \
    -IBLD/build/HEADERS/vmkapi-current-all-public-bincomp/generic/release -include vmkdrivers/src_92/include/linux/autoconf.h"

DFLAGS="-DLINUX -D__KERNEL__ -DMODULE -DMODVERSIONS -DEXPORT_SYMTAB \
    -D_LINUX -D__VMWARE__ -D__VMKERNEL_MODULE__ -D__VMKERNEL__ -D__VMKLNX__ -D__VMK_GCC_BUG_ALIGNMENT_PADDING__ \
    -DCONFIG_COMPAT -DCONFIG_DCB -DCONFIG_FCOE -DCONFIG_INET_LRO -DCONFIG_NETDEVICES_MULTIQUEUE -DCONFIG_PCI_IOV \
    -DCONFIG_PCI_MSI -DCONFIG_PROC_FS -DCPU=x86-64 -DESX3_NETWORKING_NOT_DONE_YET -DGPLED_CODE -DHAVE_DCBNL_OPS_GETAPP \
    -DHAVE_IPLINK_VF_CONFIG  -DKBUILD_MODNAME=\"r8125\" -DLINUX_MODULE_AUX_HEAP_NAME=vmklnx_r8125 -DLINUX_MODULE_HEAP_INITIAL=1024*100 \
    -DLINUX_MODULE_HEAP_MAX=64*1024*1024 -DLINUX_MODULE_HEAP_NAME=vmklnx_r8125 -DLINUX_MODULE_SKB_HEAP \
    -DLINUX_MODULE_SKB_HEAP_INITIAL=512*1024 -DLINUX_MODULE_SKB_HEAP_MAX=128*1024*1024 -DLINUX_MODULE_VERSION=\"${VERSION}\" \
    -DMODULE -DNET_DRIVER -DNO_FLOATING_POINT -DVMKERNEL -DVMKERNEL_MODULE -DVMKLINUX_MODULE_HEAP_ANY_MEM \
    -DVMK_DEVKIT_HAS_API_VMKAPI_BASE -DVMK_DEVKIT_HAS_API_VMKAPI_DEVICE -DVMK_DEVKIT_HAS_API_VMKAPI_ISCSI \
    -DVMK_DEVKIT_HAS_API_VMKAPI_NET -DVMK_DEVKIT_HAS_API_VMKAPI_RDMA -DVMK_DEVKIT_HAS_API_VMKAPI_SCSI \
    -DVMK_DEVKIT_HAS_API_VMKAPI_SOCKETS -DVMK_DEVKIT_IS_DDK -DVMK_DEVKIT_USES_BINARY_COMPATIBLE_APIS \
    -DVMK_DEVKIT_USES_PUBLIC_APIS -DVMNIX -DVMX86_RELEASE -DVMX86_SERVER"


# Use GNU grep 2.5.1
GREP=grep
# Use GNU sed 4.5.1
SED=sed
# Use GNU xargs 4.2.27
XARGS=xargs
# Use mkdir from GNU coreutils 5.97
MKDIR=mkdir

# Create output directories
$GREP -v -e "SED" build-r8125.sh \
| $GREP -o -e "-o [^ ]*\."            \
| $SED -e 's?-o \(.*\)/[^/]*\.?\1?'   \
| $GREP -v -e "\*"                    \
| $XARGS $MKDIR -p


# copy from src
/build/r8125/r8125-${VERSION}/src/copy_to_vmkdriver.sh

echo "[i] Building"
# Compiler flags assume being compiled natively on a x86-64 machine
$CC $CONFIG_FLAGS $COMP_FLAGS $DFLAGS $INCLUDES -c \
    -o BLD/build/vmkdriver-r8125/release/vmkernel64/SUBDIRS/vmkdrivers/src_9/drivers/net/r8125/r8125_n.o \
    vmkdrivers/src_9/drivers/net/r8125/r8125_n.c

$CC $CONFIG_FLAGS $COMP_FLAGS $DFLAGS $INCLUDES -c \
    -o BLD/build/vmkdriver-r8125/release/vmkernel64/SUBDIRS/vmkdrivers/src_9/drivers/net/r8125/rtl_eeprom.o \
    vmkdrivers/src_9/drivers/net/r8125/rtl_eeprom.c

$CC $CONFIG_FLAGS $COMP_FLAGS $DFLAGS $INCLUDES -c \
    -o BLD/build/vmkdriver-r8125/release/vmkernel64/SUBDIRS/vmkdrivers/src_9/drivers/net/r8125/rtltool.o \
    vmkdrivers/src_9/drivers/net/r8125/rtltool.c

$CC $CONFIG_FLAGS $COMP_FLAGS $DFLAGS $INCLUDES -c \
    -o BLD/build/vmkdriver-r8125/release/vmkernel64/SUBDIRS/vmkdrivers/src_9/drivers/net/r8125/kcompat.o \
    vmkdrivers/src_9/drivers/net/r8125/kcompat.c

$CC $CONFIG_FLAGS $COMP_FLAGS $DFLAGS $INCLUDES -c \
    -o BLD/build/vmkdriver-r8125/release/vmkernel64/SUBDIRS/vmkdrivers/src_92/common/vmklinux_module.o \
    vmkdrivers/src_92/common/vmklinux_module.c

$LD $LD_OPTS -r -o BLD/build/vmkdriver-r8125/release/vmkernel64/r8125 \
    --whole-archive BLD/build/vmkdriver-r8125/release/vmkernel64/SUBDIRS/vmkdrivers/src_9/drivers/net/r8125/r8125_n.o \
    BLD/build/vmkdriver-r8125/release/vmkernel64/SUBDIRS/vmkdrivers/src_9/drivers/net/r8125/rtl_eeprom.o \
    BLD/build/vmkdriver-r8125/release/vmkernel64/SUBDIRS/vmkdrivers/src_9/drivers/net/r8125/rtltool.o \
    BLD/build/vmkdriver-r8125/release/vmkernel64/SUBDIRS/vmkdrivers/src_9/drivers/net/r8125/kcompat.o \
    BLD/build/vmkdriver-r8125/release/vmkernel64/SUBDIRS/vmkdrivers/src_92/common/vmklinux_module.o

echo "[i] Build finished"

# copy asset
cp /build/vmkdrivers-gpl/BLD/build/vmkdriver-r8125/release/vmkernel64/r8125 .
cp r8125 /build/compile-vib-tutorial/vib-r8125-${VERSION}/payloads/net-8125/usr/lib/vmware/vmkmod/
sha1sum r8125

echo "esxcli system module set -e true -m r8125;"
echo "cd /tmp; vmkload_mod -u r8125; sha1sum r8125; \
vmkload_mod ./r8125 enable_tso=1 enable_tx_csum=1 eee_enable=0 hwoptimize=1 tx_no_close_enable=1 enable_double_vlan=0 use_dac=0"

