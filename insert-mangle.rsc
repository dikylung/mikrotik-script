# listLanIF, mangleComment and dstNetAddr should be passed from the calling script/funtion

:local mangleCount [/ip firewall mangle print count-only]
:local mangleComment "ether1-WAN"
:local listLanIF "LANS"
:local dstNetAddr "192.168.8.0/24"

# Check how many mangle rules in ip/firewall, if zero, put the rule immediately.
:if ( $mangleCount = 0 ) do={
  /ip firewall mangle add chain=prerouting dst-address=$dstNetAddr action=accept in-interface-list=$listLanIF comment=$mangleComment
} else={
  # put the rule on the top if there's multiple mangle rule already in place,
  # but check for the same existing rule comment first.
  :local dstNetCount [/ip firewall mangle print count-only where comment=$mangleComment]
  :if ( $dstNetCount = 0 ) do={
    /ip firewall mangle add chain=prerouting dst-address=$dstNetAddr action=accept in-interface-list=$listLanIF comment=$mangleComment place-before=0
  } else={
    :if ( $dstNetCount = 1 ) do={
      :local test [/ip firewall mangle find where comment=$mangleComment]
      /ip firewall mangle set $test dst-address=$dstNetAddr
    } else={
      :error "Multiple prerouting mangle found, check manually"
    }
  }
}
