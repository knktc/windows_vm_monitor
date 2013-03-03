;kvm monitor client
;created on 2012-02-12
;author knktc
;comment:
;this is a simple script which used to collect local windows pc system status and 
;form a python dict, finally send it by socket

#include "get_status.au3"
#include "get_program_status.au3"

;config file path
$config_file_path = @WorkingDir & "\config.ini"

;MsgBox time out(in seconds)
$msgbox_timeout = 20

;initial value
$program_namestring = ""

Func _FormSubmitContent($func_first_run, $func_domain_name, $func_domain_ip, $func_program_alive, $func_disk_usage, $func_mem_usage)
	$func_submitcontent = "{'first_run':" & string($func_first_run) & ", 'domain_name':'" & string($func_domain_name) & "', 'domain_ip':'" & string($func_domain_ip)& "', 'program_info':" & string($func_program_alive) & ", 'disk_usage':" & string($func_disk_usage) & ", 'mem_usage':" & string($func_mem_usage) & "}"
	Return $func_submitcontent
EndFunc

Func _SendStatus($func_server_ip, $func_server_port, $func_buffer_size, $func_content)
	;start socket connection
	TCPStartup()
	$ConnectedSocket = -1
	$ConnectedSocket = TCPConnect($func_server_ip, $func_server_port)
	If @error Then
		MsgBox(0, "Error", "Server connection failed!!", $msgbox_timeout)
	Else
		TCPSend($ConnectedSocket, $func_content)
	EndIf
EndFunc

;get config info
If FileExists($config_file_path) = 0 Then
	MsgBox(0, "Error", "Config file lost!!")
	Exit
Else
	;check if it is the first time 
	$first_run = IniRead($config_file_path, "client", "first_run", 0)
	;get domain_name
	$domain_name = IniRead($config_file_path, "client", "domain_name", "")
	;get disk path
	$diskpath_string = IniRead($config_file_path, "client", "disk_path", "c:")
	;get server connection info
	$server_ip = IniRead($config_file_path , "client", "server_ip", "")
	$server_port = IniRead($config_file_path, "client", "server_port", "")
	$buffer_size = IniRead($config_file_path, "client", "buffer_size", "")
	;get program names which need to be checked
	$program_namestring = IniRead($config_file_path, "client", "program_name", "")
EndIf

;get system IP
$domain_ip = _GetDomainIP()
;get system ram memory usage
$mem_usage = _GetMemUsage()

;get disk usage
If $diskpath_string = "" Then
	$disk_usage = ""
Else
	$disk_usage = ""
	$diskpath_array = StringSplit($diskpath_string, '|', 0)

	For $i = 1 To $diskpath_array[0]
		$single_diskpath = $diskpath_array[$i]
		$single_disk_usage = _GetDiskUsage($single_diskpath)
		$disk_usage = $disk_usage & """" & $single_diskpath & """" & ":" & $single_disk_usage & ","
	Next
	
	$disk_usage = """""""{" & $disk_usage & "}"""""""
EndIf

;get program running info
If $program_namestring = "" Then
	$program_info = ""
Else
	$program_info = ""
	$program_array = StringSplit($program_namestring, '|', 0)

	For $i = 1 To $program_array[0]
		$single_program_name = $program_array[$i]
		$single_program_count = _JudgeTitleExist($single_program_name)
		$program_info = $program_info & """" & $single_program_name & """" & ":" & $single_program_count & ","
	Next
	
	$program_info = """""""{" & $program_info & "}"""""""
EndIf

;form a submit string
$submitcontent = _FormSubmitContent($first_run, $domain_name, $domain_ip, $program_info, $disk_usage, $mem_usage)
;MsgBox(0, "", $submitcontent)

;send client status info
_SendStatus($server_ip, $server_port, $buffer_size, $submitcontent)

;modify the first_run value in ini file
If $first_run = 1 Then
	IniWrite($config_file_path, "client", "first_run", 0)
EndIf
