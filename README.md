# Raspberry-PI-Zero-2W-and-Pimoroni-Clipper-LTE-hat

Open an SSH connection to the PI Zero with Putty.

## Open serial interface in PI Zero

```sudo raspi-config```

Move to serial port config with arrows and enter key.

ONLY enable serial for hardware - NOT for shell commands.

```sudo apt update```

```sudo apt install minicom```

```sudo usermod -a -G dialout toor```

## Check where the Clipper hat is connected

```ls -l /dev/tty*```

On the PI Zero 2W it connected on /dev/ttyS0 - but it can often be on either /dev/ttyAMA0 or /dev/ttyS0.

## Run minicom just to check you can interact with the Clipper hat

```minicom -b 115200 -D /dev/ttyS0```

If minicom console doesnt open, try adding ```sudo```

## In minicom console check serial interface

type ```ctrl+a e``` (will double echo output to minicom so you can see what you type)

type ```at```+```[enter]```

Check that you get an 'OK' back.

## Check if SIM card needs a pin code:

In minicom console run ```AT+CPIN?```
   
   Possible responses:

   
   CPIN: READY - SIM is unlocked, no PIN needed
   
   CPIN: SIM PIN - SIM needs PIN
   
   CPIN: SIM PUK - SIM is locked, needs PUK code
   

If you need to enter a PIN:

```AT+CPIN="0000"``` (pin for KPN SIM card is 0000)

Now serial is running and SIM card is unlocked with pin.

Close minicom console with ```ctrl+a x```

## Setup PPP connection

Copy a Clipper config to a new file: ```sudo cp /etc/ppp/peers/provider /etc/ppp/peers/clipper```

```
# example configuration for a dialup connection authenticated with PAP or CHAP
#
# This is the default configuration used by pon(1) and poff(1).
# See the manual page pppd(8) for information on all the options.

# MUST CHANGE: replace myusername@realm with the PPP login name given to
# your by your provider.
# There should be a matching entry with the password in /etc/ppp/pap-secrets
# and/or /etc/ppp/chap-secrets.

# user "myusername@realm" <------------------------------------------------------------------ comment out

# MUST CHANGE: replace ******** with the phone number of your provider.
# The /etc/chatscripts/pap chat script may be modified to change the
# modem initialization string.
connect "/usr/sbin/chat -v -f /etc/chatscripts/gprs -T internet" <--------------------------- set gprs and internet

# Serial device to which the modem is connected.
/dev/ttyS0 <----------------------------------------------------------------------------------set the actual interface

# Speed of the serial line.
115200

# Assumes that your IP address is allocated dynamically by the ISP.
noipdefault

# Try to get the name server addresses from the ISP.
usepeerdns

# Use this connection as the default route.
defaultroute

# Makes pppd "dial again" when the connection is lost.
persist

# Do not ask the remote to authenticate.
noauth

# disable hardware flow control (RTS, and CTS)
nocrtscts <--------------------------------------------------------------------------------add this

# disable modem control lines (CD, and DTR)
local <------------------------------------------------------------------------------------add this

```

## Launch Clipper

```sudo pon clipper```

Check PPP connection ```ifconfig```

Check connection with PPP ```ping -I ppp0 1.1.1.1```
