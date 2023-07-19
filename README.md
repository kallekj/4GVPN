# 4GVPN
My setup for remote 4G VPN on Raspberry Pi using Sim7600e.

## Setup

### ECM mode

This is based on the following article: https://www.jeffgeerling.com/blog/2022/using-4g-lte-wireless-modems-on-raspberry-pi (read 2023-07-19)

For easiest configuration of the SIM7600x board, set to operate in ECM mode instead of QMI. In ECM mode, it will be detected as an USB modem (interface usb0) instead of wwan0 and you dont have to reset the board each time it boots.

1. To set the boad in ECM mode, connect to the SIM7600x via serial interface with your favorite serial interface software (I use screen). Most probably it will be exposed on `/dev/ttyUSB2`.
  
```bash
screen /dev/ttyUSB2 115200
```

2. Test connection by sending `AT`, it should respond with `OK`.

```bash
AT
OK
```

3. Next, test if it's in USB mode with `AT+QCFG="usbnet"`.
  
```bash
AT+QCFG="usbnet"
+QCFG: "usbnet",0
```
It might respond with `ERROR`, if this is the case go to step x.

4. Set it in ECM mode with `AT+QCFG="usbnet",1` and the modem will reboot, if not you can force a reboot with `AT+CFUN=1,1`.
6. Exit screen session with `ctrl-a ctrl-d`.
7. After a reboot you should now see `usb0` listed as an interface from the comman `ifconfig`.
8. If the output in step 3 was `ERROR`, try instead with sending `AT+CUSBPIDSWITCH=9011,1,1`. The modem should now restart, jump to step 5. (source https://www.waveshare.com/wiki/Raspberry_Pi_RNDIS_dial-up_Internet_access 2023-07-19)
9. When the modem is in ECM mode, you can't access it via `/dev/ttyUSB2`, instead `/dev/ttyS0` will be available.

### Forward usb0 to eth0

This is based on the following article: https://newjerseystyle.github.io/en/2020/Raspberry-Pi-as-4G-LTE-Router/ (read 2023-07-19)

1. Update your system:
```bash
$ sudo apt update
$ sudo apt upgrade
```

2. Install dnsmasq:
```bash
$ sudo apt install dnsmasq
```

3. Configure dnsmasq
Create a file `eth0` in the dnsmasq config directory.
```bash
$ sudo vim /etc/dnsmasq.d/eth0
```
With the following content:
```bash
interface=eth0                 # Use interface eth0  
listen-address=192.168.2.1     # listen on  
server=1.1.1.1                 # Forward DNS requests to Cloudflare DNS 
domain-needed                  # Don't forward short names  
bogus-priv                     # Never forward addresses in the non-routed address spaces.
# Assign IP addresses between 192.168.2.2 and 192.168.2.100 with a
# 12 hour lease time
dhcp-range=192.168.2.2,192.168.2.100,12h
```

4. Configure interfaces
Create a file `090-eht0` in the interfaces config directory.
```bash
$ sudo vim /etc/network/interfaces.d/090-eth0
```
With the following content:
```bash
allow-hotplug eth0  
iface eth0 inet static  
    address 192.168.2.1
    netmask 255.255.255.0
    network 192.168.2.0
    broadcast 192.168.2.255
```

5. Configure forwarding by editing `/etc/sysctl.conf`, find the line `#net.ipv4.ip_forwarding=1` and uncomment the line by removing `#` in the beginning.
6. Reboot system
```bash
$ sudo reboot
```

7. Configure NAT
```bash
$ sudo iptables -t nat -A POSTROUTING -o usb0 -j MASQUERADE  
$ sudo iptables -A FORWARD -i usb0 -o eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT  
$ sudo iptables -A FORWARD -i eth0 -o usb0 -j ACCEPT
```
8. Test if the configuration works before we make the NAT persistent. Connect a system via ethernet and ping 8.8.8.8 and google.com on the connected system to test if forwarding and DNS works, if it does then continue. If it doesn't work, you most probably have another default route enabled (like wlan0). This was my case so I had to disable the onboard WiFi, go to step x.
```bash
$ ping 8.8.8.8
PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
64 bytes from 8.8.8.8: icmp_seq=2 ttl=51 time=99.2 ms
64 bytes from 8.8.8.8: icmp_seq=1 ttl=51 time=22.9 ms
64 bytes from 8.8.8.8: icmp_seq=3 ttl=51 time=69.7 ms
```
10. If the configuration works, the we can save the NAT config.
```bash
$ sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"
```
Edit `/etc/rc.local` and add the following just above `exit 0`
```bash
iptables-restore < /etc/iptables.ipv4.nat
```
10. Disable onboard WiFi.
```bash
sudo vim /boot/config.txt
```
Scroll to the bottom and you should find a section `[all]`. Under this section, add the folloing.
```bash
dtoverlay=disable-wifi
```

### Forward usb0 to wlan0

Use RaspAP, https://github.com/RaspAP/raspap-webgui
But from my testing is that it's quite slow, even on an RPi4. Maybe it performs better with a dedicated wifi-dongle.

## Links
These are the sources i've been researching in order to setup everything.

### Cloudflared DNS over HTTPS and Tunnel
* https://github.com/cloudflare/cloudflared
* https://docs.pi-hole.net/guides/dns/cloudflared/
* https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/run-tunnel/run-as-service
* https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/configuration/ingress
* https://gist.github.com/sbooth/640cb1c5f7a4910782087fbe0dad42ea
`mv /lib/systemd/system/dnscrypt-proxy.socket .`

### SIM7600e
* https://www.raspberrypi.org/forums/viewtopic.php?f=36&t=224355&p=1450784#p1450784
* https://www.raspberrypi.org/forums/viewtopic.php?t=206761#p1368015
* https://embeddedpi.com/documentation/3g-4g-modems/raspberry-pi-sierra-wireless-mc7304-modem-qmi-interface-setup
* https://embeddedpi.com/documentation/3g-4g-modems/raspberry-pi-sierra-wireless-mc7455-modem-raw-ip-qmi-interface-setup
* https://www.jeffgeerling.com/blog/2022/using-4g-lte-wireless-modems-on-raspberry-pi

### wwan0/usb0 to eth0
* https://serverfault.com/questions/152363/bridging-wlan0-to-eth0
* https://raspberrypi.stackexchange.com/questions/103572/pi-as-dhcp-server-but-getting-unknown-interface-eth0-with-dnsmasq
* https://raspberrypi.stackexchange.com/questions/88214/setting-up-a-raspberry-pi-as-an-access-point-the-easy-way/88234#88234
* https://raspberrypi.stackexchange.com/questions/108592/use-systemd-networkd-for-general-networking/108593#108593
* https://community.sixfab.com/t/qmi-how-to-share-wwan0-with-eth0/830
* https://newjerseystyle.github.io/en/2020/Raspberry-Pi-as-4G-LTE-Router/
* https://eco-sensors.ch/router-wifi-4g-hotspot/#eth0
* https://newjerseystyle.github.io/en/2020/Raspberry-Pi-as-4G-LTE-Router/
