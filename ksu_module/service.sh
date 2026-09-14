#!/system/bin/sh
MODDIR=${0%/*}
LOG="$MODDIR/loader.log"
exec > "$LOG" 2>&1

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting RTW88 driver loader..."

# Wait for boot completion
while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 2
done

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Boot completed, checking wireless stack..."

# 1. Load cfg80211 if not built into kernel
if [ -f "$MODDIR/modules/cfg80211.ko" ] && ! lsmod | grep -q "^cfg80211 "; then
    echo "Loading bundled cfg80211.ko..."
    insmod "$MODDIR/modules/cfg80211.ko" 2>&1 || true
fi

# 2. Load mac80211 (required for rtw_core)
if [ -f "$MODDIR/modules/mac80211.ko" ] && ! lsmod | grep -q "^mac80211 "; then
    echo "Loading bundled mac80211.ko..."
    insmod "$MODDIR/modules/mac80211.ko" 2>&1
fi
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Loading RTW88 modules..."
for mod in rtw_core rtw_usb rtw_8723x rtw_8723d rtw_8723du; do
    echo "Loading $mod.ko..."
    insmod "$MODDIR/modules/$mod.ko" 2>&1
done

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Driver loader finished."
lsmod | grep rtw
