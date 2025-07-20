#!/bin/bash
set -e

# --- CONFIGURATION ---
SERIAL_PORT="COM8"
BAUD_RATE="57600"
COMMANDS="M502;M500" # Commands separated by a semicolon

# --- STEP 1: UPLOAD FIRMWARE ---
echo ">>> Step 1: Uploading firmware..."
platformio run -t upload

# Check if upload failed
if [ $? -ne 0 ]; then
    echo "XXX UPLOAD FAILED. Aborting."
    exit 1
fi

echo ">>> Upload Succeeded."

# --- STEP 2: WAIT FOR REBOOT ---
echo ">>> Step 2: Waiting 7 seconds for printer to reboot..."
sleep 7

# --- STEP 3: SEND COMMANDS ---
echo ">>> Step 3: Sending initialization commands..."

# This single line of Python is the most reliable way to send serial data
# It avoids all the stty/bash issues on Windows.
python -c "
import serial, time, sys
port = '${SERIAL_PORT}'
baud = ${BAUD_RATE}
commands = '${COMMANDS}'.split(';')
try:
    ser = serial.Serial(port, baud, timeout=1)
    time.sleep(2) # Wait for connection to establish
    for cmd in commands:
        if not cmd: continue
        print(f'  > Sending: {cmd}')
        ser.write(f'{cmd}\\n'.encode())
        time.sleep(2) # Wait for command to be processed
    ser.close()
    print('>>> Commands sent successfully.')
except Exception as e:
    print(f'XXX ERROR: Could not send commands. {e}')
    sys.exit(1)
"

if [ $? -eq 0 ]; then
    echo ">>> All done."
else
    echo "XXX Script failed during command sending."
fi
