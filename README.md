# 4GVPN
My setup for remote 4G VPN on Raspberry Pi using Sim7600e.


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

### wwan0 to eth0
* https://serverfault.com/questions/152363/bridging-wlan0-to-eth0
* https://raspberrypi.stackexchange.com/questions/103572/pi-as-dhcp-server-but-getting-unknown-interface-eth0-with-dnsmasq
* https://raspberrypi.stackexchange.com/questions/88214/setting-up-a-raspberry-pi-as-an-access-point-the-easy-way/88234#88234
* https://raspberrypi.stackexchange.com/questions/108592/use-systemd-networkd-for-general-networking/108593#108593
* https://community.sixfab.com/t/qmi-how-to-share-wwan0-with-eth0/830
* https://eco-sensors.ch/router-wifi-4g-hotspot/#eth0
* https://newjerseystyle.github.io/en/2020/Raspberry-Pi-as-4G-LTE-Router/
