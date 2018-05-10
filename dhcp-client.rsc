# Description: DHCP Client Mikrotik script to update route mark automatically (for PCC)
#   This script add 2 default routes with different distance. 1 with marked route, and 1 without.
# Author: Diky Muljana (dqsolution_AT_gmail.com)
# 
# Change dhclientIF, gwdistance, and gwmarkdistance as necessary
# $interface, $bound, $gateway-address is populated when the DHCP-Client script executed

:local dhclientIF $interface
:local gwdistance 9
:local gwmarkdistance 1

# Advance Vars
:local rmark ( "to_" . $dhclientIF )
:local defgwComment ( $dhclientIF . "_defROUTE" )
:local defgwmarkComment ( $dhclientIF . "_markedROUTE")
:local dhclientIP
:local dhclientNETMASK
:local dhclientNETADDR
:local dhclientNETLEN
:local dhclientGW
:local dhclientDNS

#setup default unmarked route

:if ($bound = 1) do={
    :local routeCount [/ip route print count-only where comment=$defgwComment]
    :if ($routeCount = 0) do={
		/ip route add gateway=$"gateway-address" distance=$gwdistance check-gateway=ping comment=$defgwComment
    } else={
        :if ($count = 1) do={
            :local test [/ip route find where comment=$defgwComment]
            :if ([/ip route get $test gateway] != $"gateway-address") do={
                /ip route set $test gateway=$"gateway-address"
            }
        } else={
            :error "Multiple routes found"
        }
    }
} else={
    /ip route remove [find comment=$defgwComment]
}

#setup marked route
:if ($bound = 1) do={
    :local routeCount [/ip route print count-only where comment=$defgwmarkComment]
    :if ($routeCount = 0) do={
        /ip route add gateway=$"gateway-address" routing-mark=$rmark distance=$gwmarkdistance check-gateway=ping comment=$defgwmarkComment
    } else={
        :if ($count = 1) do={
            :local test [/ip route find where comment=$defgwmarkComment]
            :if ([/ip route get $test gateway] != $"gateway-address") do={
                /ip route set $test gateway=$"gateway-address"
            }
        } else={
            :error "Multiple routes found"
        }
    }
} else={
    /ip route remove [find comment=$defgwmarkComment]
}
