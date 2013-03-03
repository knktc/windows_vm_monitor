;get_status.au3
;created on 2012-02-12
;author:knktc
;comment:a script to get system status

;get domain ip
Func _GetDomainIP()
	Return @IPAddress1
EndFunc

;get disk usage
Func _GetDiskUsage($func_diskpath)
	Local $disk_usage, $drive_path_test, $disk_total, $disk_free
	$drive_path_test = DriveStatus($func_diskpath)
	$disk_usage = 0
	If $drive_path_test <> "READY" Then
		MsgBox(0, "Error", "The disk drive does not exsit!", 60)
		Return $disk_usage
	Else
		$disk_total = DriveSpaceTotal($func_diskpath)
		$disk_free = DriveSpaceFree($func_diskpath)
		$disk_usage = ($disk_total - $disk_free) / $disk_total * 100
		$disk_usage = Int($disk_usage)
		;MsgBox(0, "disk usage", int($disk_usage))
		Return $disk_usage
	EndIf
EndFunc

;get mem usage
Func _GetMemUsage()
	$mem = MemGetStats()
	$mem_usage = $mem[0]
	;MsgBox(0, "mem usage", $mem_usage)
	Return $mem_usage
EndFunc
