#!/bin/bash
export DISPLAY=:0

xset s off
xset s noblank

novnc_pid=""

function cleanup {
    vncserver -kill :0 >/dev/null 2>&1 || true
    if [ ! -z "$novnc_pid" ]; then
        kill "$novnc_pid" >/dev/null 2>&1 || true
    fi
}

trap cleanup EXIT
trap 'cleanup; exit 0' INT TERM

while true; do
    if ! nc -z localhost 5900 >/dev/null 2>&1; then
        /usr/bin/vncserver -SecurityTypes=None -UseBlacklist=false -xstartup /usr/bin/startxfce4 :0 2>&1 &
    fi
    if ! nc -z localhost 3000 >/dev/null 2>&1; then
        /opt/noVNC/utils/novnc_proxy --listen 3000 --vnc localhost:5900 2>&1 &
        novnc_pid=$!
    fi
    sleep 2
done