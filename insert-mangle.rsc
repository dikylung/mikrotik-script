:local mangleCount [/ip firewall mangle print count-only]
:local mangleComment "ether1-WAN"
:local listLanIF "LANS"
:local dstNetAddr "192.168.8.0/24"

:if ( $mangleCount = 0 ) do={
  /ip firewall mangle add chain=prerouting dst-address=$dstNetAddr action=accept in-interface-list=$listLanIF comment=$mangleComment
} else={
  :local dstNetCount [/ip firewall mangle print count-only where comment=$mangleComment]
  :if ( $dstNetCount = 0 ) do={
    # place-before cannot work without the script knowing the list or rules, so insert this dummy "find" statement to populate the list.
    :local test [/ip firewall mangle find]
    # now the line below will work
    /ip firewall mangle add chain=prerouting dst-address=$dstNetAddr action=accept in-interface-list=$listLanIF \
       comment=$mangleComment place-before=0
  } else={
    :if ( $dstNetCount = 1 ) do={
      :local test [/ip firewall mangle find where comment=$mangleComment]
      /ip firewall mangle set $test dst-address=$dstNetAddr
    } else={
      :error "Multiple prerouting mangle found, check manually"
    }
  }
}
