#!/bin/bash

SERIAL="/dev/ttyS0"
BAUD=115200
LOG_TAG="[SMS-FORWARDER]"

log() {
    echo "$LOG_TAG $1"
}

send_at() {
    echo -e "$1\r" > "$SERIAL"
    sleep 0.5
    cat /tmp/sms_response 2>/dev/null
}

# Open serial port and redirect output to a temp file
exec 3<>"$SERIAL"
stty -F "$SERIAL" "$BAUD" cs8 -cstopb -parenb raw -echo

log "SMS forwarder started, listening on $SERIAL"

# Set modem to text mode and enable new SMS notifications
echo -e "AT+CMGF=1\r" >&3
sleep 0.5
echo -e "AT+CNMI=2,2,0,0,0\r" >&3
sleep 0.5

log "Modem set to SMS text mode with unsolicited delivery"

# Read loop
while true; do
    if read -r -t 5 line <&3; then
        # Strip carriage returns
        line="${line//$'\r'/}"

        # Detect incoming SMS header: +CMT: "sender","","timestamp"
        if [[ "$line" == +CMT:* ]]; then
            sender=$(echo "$line" | grep -oP '"\K[^"]+(?=")')
            read -r -t 5 message <&3
            message="${message//$'\r'/}"
            log "New SMS from [$sender]: $message"
            # TODO: forward to API endpoint here
        fi
    fi
done
