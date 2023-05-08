# Realtek RTL8125 NIC driver 9.011.00-10 for ESXi 6.7 U3
* Major rewrite by IRON Software GmbH / ksh@ironsoftware.de

This source code is based on realtek official source, VMware-ESXI-67U3-ODP and VMware-TOOLS-10.2.0-ODP.
- Log in with root, make a folder name 'build' on /, make folder toolchain and vsphere in /build.
- Copy and extract gcc-4.8.0, binutils-2.22, glibc-2.3.4-2.41 to /build/toolchain/src 
- Compile the toolchain, dest path is /build/toolchain/lin64
- Extract and copy vmkdrivers-gpl from 67U3-ODP to /build/vsphere
- Copy build-r8125.sh to /build/vsphere/vmkdrivers-gpl/
- Copy r8125 folder to /build/vsphere/vmkdrivers-gpl/vmkdrivers/src_9/drivers/net
- Run build-r8125.sh

Just do these steps for development:
- cd /tmp; vmkload_mod -u r8125; sha1sum r8125; \
- vmkload_mod ./r8125 enable_tso=1 enable_tx_csum=1 eee_enable=0 hwoptimize=1 tx_no_close_enable=1 enable_double_vlan=0 use_dac=0

Install bundle
- esxcli software vib install -f -v $PWD/net-r8125-9.011.00-10.vib

