# TODO: Add If statement to find duplicates
# Add this to scheduler every 5 mins or so

:local currentEth "pppoe-CNET";
:local currentAddress [/ip address get [find interface=$currentEth] address];
:local fwMangle [/ip firewall mangle find where comment=$currentEth];
/ip firewall mangle set $fwMangle dst-address=$currentAddress;
