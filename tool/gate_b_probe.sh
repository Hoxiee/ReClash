#!/usr/bin/env bash
# TODO: gate-b-probe removal — Slice 0 on-device GATE B check, not shipped.
set -u
D=192.168.31.149:5555
adb -s "$D" shell am force-stop com.reclash.dev
sleep 2
adb -s "$D" logcat -c
adb -s "$D" shell monkey -p com.reclash.dev -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1
for i in $(seq 1 30); do
  if adb -s "$D" logcat -d | grep -q "companion gate probe handler registered"; then
    echo "probe registered (poll $i)"
    break
  fi
  sleep 1
done
adb -s "$D" shell am start-foreground-service -n com.reclash.dev/com.reclash.companion.CompanionService >/dev/null 2>&1
sleep 2
PID_A=$(adb -s "$D" shell pidof com.reclash.dev | tr -d '\r')
echo "pid after FGS: $PID_A"
adb -s "$D" shell input keyevent KEYCODE_HOME
sleep 4
PID_B=$(adb -s "$D" shell pidof com.reclash.dev | tr -d '\r')
echo "pid after Home: $PID_B"
adb -s "$D" logcat -c
adb -s "$D" shell am start-foreground-service -n com.reclash.dev/com.reclash.companion.CompanionService -a com.reclash.companion.PROBE_ENGINE >/dev/null 2>&1
sleep 5
echo "=== PROBE RESULT ==="
adb -s "$D" logcat -d | grep -i "CompanionProbe" | tail -2
