;get_program_status.au3
;created on 2012-02-15
;author:knktc
;comment: this script is used to return program running status,
;should be various in different condition

#include <WinAPI.au3>

Func _GetProgramStatus()
	Return 1
EndFunc

Func _JudgeTitleExist($func_title)
	Local $windows, $i, $window_count, $current_title, $check_result
	$prog_count = 0
	$windows = _WinAPI_EnumWindowsTop()
	$window_count = $windows[0][0]

	For $i = 1 To $window_count
		$current_title = WinGetTitle($windows[$i][0])
		$split_title = StringSplit($current_title, " ")
		If $split_title[1] == $func_title Then
			$prog_count = $prog_count + 1
		EndIf
	Next
	
	Return $prog_count
EndFunc
