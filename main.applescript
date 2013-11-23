on isOnline()
	try
		do shell script "curl -s -I --connect-timeout 10 http://sample.appspot.com/"
		return true
	on error errStr
		return false
	end try
end isOnline

on idle
	set status to do shell script "/usr/sbin/networksetup -getairportpower en0 | awk '{ print $4 }'"
	if status is not "On" then
		return 120
	end if
	set ssid to do shell script "/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID/ {print $2}'"
	if ssid is "" then
		return 120
	end if
	if isOnline() then
		return 30
	end if
	set listnetwork to do shell script "networksetup -listnetworkserviceorder |grep '^([0-9]'|sed -e 's/([0-9]*) //g'|grep '^VPN'|tr '
' '/'"
	set text item delimiters of AppleScript to "/"
	set serviceNames to rest of reverse of text items of listnetwork
	tell application "System Events"
		tell current location of network preferences
			repeat with serviceName in serviceNames
				set VPN to null
				try
					set VPN to service serviceName
				on error errStr
					log errStr
					set VPN to null
				end try
				if VPN is not null then
					set isConnected to false
					try
						set isConnected to (VPN is connected)
					on error errStr
						log serviceName & ": " & errStr
					end try
					if isConnected then
						return 30
					end if
				end if
			end repeat
			repeat with serviceName in serviceNames
				set VPN to null
				try
					set VPN to service serviceName
				on error errStr
					log serviceName & ": " & errStr
					set VPN to null
				end try
				if VPN is not null then
					connect VPN
					delay 30
					if isOnline() then
						return 30
					end if
				end if
			end repeat
		end tell
	end tell
end idle