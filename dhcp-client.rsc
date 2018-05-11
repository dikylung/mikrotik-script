# DHCP Client Mikrotik script for PCC
# Author: Diky Muljana <dqsolution_AT_gmail.com>
# Description: This script is to be installed with Mikrotik ROS version 6.3 and above 
# What the script does:
#   1. Setup ip mangle preroute for dhcpclient direct attached network to avoid route loops
#   2. Setup default gw for unmarked route
#   3. Setup default gw for marked route
# Installation:
#   1. Change gwdistance, gwmarkdistance, listLanIF,  to suit your network
#   2. Copy and Paste this script to IP->Dhcp-client->Advance->Script
#   3. Click "Release" button to trigger the execution
# Note:
#   1. $interface, $bound, $gateway-address is populated by Mikrotik ROS when DHCP-Client
#      is getting new IP Address.

#==========================================#
# Basic Vars (modify to suit your network) #
#==========================================#
:local gwdistance "9";
:local gwmarkdistance "1";
# Put your LAN interface in an interface list (ex. LANS contains ether5)
:local listLanIF "LANS";

#===================================================#
# Advance Vars (Only if you know what you're doing) #
#===================================================#
:local dhclientIF $interface;
:local rmark ( "to_" . $dhclientIF );
:local defgwComment ( $dhclientIF . "_defROUTE" );
:local defgwmarkComment ( $dhclientIF . "_markedROUTE");
:local mangleComment $dhclientIF;
:local dhclientIP [ /ip address get [find interface=$dhclientIF ] address];
:local dhclientNETLEN [:pick $dhclientIP ([:find $dhclientIP "/"]+1) [:len $dhclientIP]];
:local dhclientNETWORK [/ip address get [find interface=$dhclientIF] network];
:local dhclientNETADDR ("$dhclientNETWORK" . "/" . "$dhclientNETLEN");
:local dhclientGW $"gateway-address";

#
# Setup ip firewall mangle
#=========================
:if ( bound = 1 ) do={
	:local mangleCount [/ip firewall mangle print count-only];
	:if ( $mangleCount = 0 ) do={
	  /ip firewall mangle add chain=prerouting dst-address=$dhclientNETADDR action=accept in-interface-list=$listLanIF comment=$mangleComment;
	} else={
	  :local dstNetCount [/ip firewall mangle print count-only where comment=$mangleComment];
	  :if ( $dstNetCount = 0 ) do={
		# place-before cannot work without the script knowing the list or rules, so insert this dummy "find" statement to populate the list.
		:local test [/ip firewall mangle find];
		# now the line below will work
		/ip firewall mangle add chain=prerouting dst-address=$dhclientNETADDR action=accept in-interface-list=$listLanIF comment=$mangleComment place-before=0;
	  } else={
		:if ( $dstNetCount = 1 ) do={
		  :local test [/ip firewall mangle find where comment=$mangleComment];
		  /ip firewall mangle set $test dst-address=$dhclientNETADDR;
		} else={
		  :error "Multiple prerouting mangle found, check manually";
		}
	  }
	}
} else={
	/ip firewall mangle remove [find comment=$manggleComment];
}

#
# Setup default unmarked route
#=============================
:if ( $bound = 1 ) do={
    :local routeCount [/ip route print count-only where comment=$defgwComment];
    :if ( $routeCount = 0 ) do={
      /ip route add gateway=$"gateway-address" distance=$gwdistance check-gateway=ping comment=$defgwComment;
    } else={
        :if ( $routeCount = 1 ) do={
            :local test [/ip route find where comment=$defgwComment];
            :if ([/ip route get $test gateway] != $"gateway-address") do={
                /ip route set $test gateway=$"gateway-address";
            }
        } else={
            :error "Multiple routes found";
        }
    }
} else={
    /ip route remove [find comment=$defgwComment];
}

#
# Setup default marked route
#===========================
:if ($bound = 1) do={
    :local routeCount [/ip route print count-only where comment=$defgwmarkComment];
    :if ($routeCount = 0) do={
        /ip route add gateway=$"gateway-address" routing-mark=$rmark distance=$gwmarkdistance check-gateway=ping comment=$defgwmarkComment;
    } else={
        :if ($routeCount = 1) do={
            :local test [/ip route find where comment=$defgwmarkComment];
            :if ([/ip route get $test gateway] != $"gateway-address") do={
                /ip route set $test gateway=$"gateway-address";
            }
        } else={
            :error "Multiple routes found";
        }
    }
} else={
    /ip route remove [find comment=$defgwmarkComment];
}
