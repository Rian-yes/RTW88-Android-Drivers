#!/system/bin/sh
MODDIR=${0%/*}

# Wait for boot completion
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 2
done

# Ensure kernel wireless stack prerequisites are loaded
modprobe mac80211 2>/dev/null || insmod /vendor/lib/modules/mac80211.ko 2>/dev/null || insmod /system/lib/modules/mac80211.ko 2>/dev/null
modprobe cfg80211 2>/dev/null || insmod /vendor/lib/modules/cfg80211.ko 2>/dev/null || insmod /system/lib/modules/cfg80211.ko 2>/dev/null

# Load RTW88 driver modules in strict dependency order
insmod "$MODDIR/modules/rtw_core.ko"
insmod "$MODDIR/modules/rtw_usb.ko"
insmod "$MODDIR/modules/rtw_8723x.ko"
insmod "$MODDIR/modules/rtw_8723d.ko"
insmod "$MODDIR/modules/rtw_8723du.ko"
