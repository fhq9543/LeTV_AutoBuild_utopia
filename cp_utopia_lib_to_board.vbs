#$language = "VBScript"
#$interface = "1.0"

crt.Screen.Synchronous = True

' This automatically generated script may need to be
' edited in order to work correctly.

wait_str = ":/"
utopia_path_on_usb="out"
an_utopia_path_on_board="/system"
sn_utopia_path_on_board="/tvservice/mslib/utopia"
Sub Main
	crt.screen.sendkeys("^c")
	crt.Screen.WaitForString wait_str 
	crt.Screen.Send "su" & chr(13)
	crt.Screen.WaitForString wait_str 
	crt.Screen.Send "echo 0 0 0 0 > /proc/sys/kernel/printk" & chr(13)
	crt.Screen.WaitForString wait_str 
	crt.Screen.Send "mount -o remount,rw /tvservice; mount -o remount,rw /system" & chr(13)
	crt.Screen.WaitForString wait_str 
	crt.Screen.Send "usb_path=$(mount | grep usb | busybox awk '{print $2}')" & chr(13)
	crt.Screen.WaitForString wait_str 
	crt.Screen.Send "[[ $(echo $usb_path | wc -w) == 1 ]]" 
	crt.Screen.Send " && cp -rf $usb_path/out/an/lib* " & an_utopia_path_on_board
	crt.Screen.Send " && cp -rf $usb_path/out/sn/lib/* " & sn_utopia_path_on_board
	crt.Screen.Send " && reboot "
	crt.Screen.Send " || echo -e '\e[1;41m copy utopia lib error!!!!\n pls make sure there is only one U disk!!!! \e[m' " & chr(13)
	
End Sub
