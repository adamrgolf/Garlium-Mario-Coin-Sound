#SingleInstance,Force
#Persistent
#NoEnv
DetectHiddenWindows, On	;needed for TrayIcon to be able to get tooltip of garlium system tray icon

;PLEASE READ: Change the following 3 values to suit your needs/preferences

swing_val := 0.0 ;will only play sound if increase (or decrease) of this value

garlium_exe := "Garlium.exe" ;the exe name of your garlium

coin_sound = smb_coin.wav	;which coin sound (located in the r folder) to play on increase by default if no value saved in settings ini

;PLEASE READ: Change the above 3 values to suit your needs/preferences

settings_file = %A_ScriptDir%\settings.ini

IniRead, coin_sound,%settings_file%,Sounds,Increase_Sound,%coin_sound%
IniRead, garlium_exe,%settings_file%,Garlium,EXE_File,%garlium_exe%

wav_dir = %A_ScriptDir%\r\wavs

;#Include,%A_ScriptDir%\r\TrayIcon.ahk

Menu,Tray,NoStandard

VersionLog =
(Comments
0.10	bug-fix for wincheck routine
0.09	Included ability to read Garlium system tray icon tooltip even if the icon is hidden in the ^ notification area.
0.08	Fixed a minor bug where sound would only start playing after 2nd increase in balance. Sound now plays on program startup indicating it can properly read the garlium.exe tray tip.
0.07	Included ability to set garlium executable in the settings.ini file if yours is differnt than "Garlium.exe"
0.06	Chosen sound is now saved in settings.ini file
0.05	Updated tray menu`; added ability to choose/select sound - to add custom sounds just add a .wav to the \r\wavs dir and re-open the program
0.04	Quick fix regarding TrayIcon.ahk
0.03	Cleaned up comments, readme & code a bit
0.02	Cleanup code, add/polish features and add to github
0.01	Initial quick release for https://www.reddit.com/r/garlicoin/comments/7snhqg/garlium_notification_mario_coin_sound/
)

RegExMatch(VersionLog,"^(.+?)\s",version)

ProgramName := "Garlium Mario Coin Sound v" version1

Menu,TestSubMenu,Add,Play Sound,PlaySound
Menu,TestSubMenu,Add,Read Garlium Tray Tip,GetTip

Menu,SoundSubMenu,Add

Menu,Tray,Add,Test, :TestSubMenu
Menu,Tray,Add,Sound, :SoundSubMenu
Menu,Tray,Add,About,About_diag
Menu,Tray,Add,
Menu,Tray,Add,Exit,ExitTray

Menu,Tray,Tip,% ProgramName

Menu,Tray,Icon,r\garlicoin_icon.ico

Menu,Tray,Default,About

GoSub,GetSounds

startup=1

GoSub,GetTip

old_val=0

GoSub,WinCheck

SetTimer,WinCheck,2500 ;every 2.5 seconds

Return

SoundMenuHandler:
	SoundPlay,%wav_dir%\%A_ThisMenuItem%
	coin_sound := A_ThisMenuItem
	IniWrite,%A_ThisMenuItem%,%settings_file%,Sounds,Increase_Sound
	GoSub,GetSounds
return

GetSounds:
	Menu,SoundSubMenu,DeleteAll
	Loop,Files,%wav_dir%\*.wav
		{
			Menu,SoundSubMenu,Add,%A_LoopFileName%,SoundMenuHandler
			If (A_LoopFileName = coin_sound)
				Menu,SoundSubMenu,Check,%A_LoopFileName%
		}
Return

About_diag:
	GoSub,PlaySound
	MsgBox,,About %ProgramName%,Created by adamrgolf`n`nVersion history:`n%VersionLog%
Return

GetTip:
	garliumt := TrayIcon(garlium_exe)
	garliumt_h := TrayIconHidden(garlium_exe)
	garliumtb := garliumt A_Space garliumt_h
	fp := RegExMatch(garliumtb,"m)Tooltip:\sBalance:\s(.+?)\sGRLC",grlc)
	If (fp > 0)
		{
			If (startup<>1)
				{
					GoSub,PlaySound
					MsgBox,,Garlium Tray Tip,%garliumtb%`n`nBalance: %grlc1%`n`nAble to read Garlium tray tip!
				}
		}
	Else
		MsgBox,,Doh!,%ProgramName%`n`nUnable to find/read Garlium Tray Tip, no "%garlium_exe%" process running. Ensure Garlium is running or if your garlium exe is different than %garlium_exe%, please specify it in the settings.ini file and reload this program.
	startup=0
Return

PlaySound:
	SoundPlay,%wav_dir%\%coin_sound%
Return

WinCheck:
	garliumt := TrayIcon(garlium_exe)
	garliumt_h := TrayIconHidden(garlium_exe)
	garliumtb := garliumt A_Space garliumt_h
	fp := RegExMatch(garliumtb,"m)Tooltip:\sBalance:\s(.+?)\sGRLC",grlc)
	If fp > 0
		{
			;tooltip % grlc1
			If (grlc1 >= old_val + swing_val) OR (grlc1 <= old_val - swing_val) OR (old_val = NULL)
				{
					If (old_val <> NULL)
						{
							;initial balance
							If (grlc1 > old_val)
								{
									;increase in balance
						   		GoSub,PlaySound
								}
							If (grlc1 < old_val)
								{
									;decrease in balance, does nothing right now
								}
						}
					old_val := grlc1
				}
		}
Return

ExitTray:
	ExitApp
Return

;TrayIcon.ahk included below which is used to get the tray tip text from the garlium.exe system tray icon

;?add 2010 Modified by Tuncay to work with the stdlib mechanism.
;?add The function names are changed, mostly a prefix Tray_ is 
;?add added and names changed: TrayIcons() becomes to TrayIcon()
;?add and HideTrayIcon() becomes to TrayIcon_Hide().
;?add All changed or added lines are commented with ;? comments.
;?add http://www.autohotkey.com/forum/viewtopic.php?t=17314 by Sean

;?out-begin
/*
#NoTrayIcon
DetectHiddenWindows, On

MsgBox % TrayIcons()
Return
*/
;?out-end

/*
WM_MOUSEMOVE	= 0x0200
WM_LBUTTONDOWN	= 0x0201
WM_LBUTTONUP	= 0x0202
WM_LBUTTONDBLCLK= 0x0203
WM_RBUTTONDOWN	= 0x0204
WM_RBUTTONUP	= 0x0205
WM_RBUTTONDBLCLK= 0x0206
WM_MBUTTONDOWN	= 0x0207
WM_MBUTTONUP	= 0x0208
WM_MBUTTONDBLCLK= 0x0209

PostMessage, nMsg, uID, WM_RBUTTONDOWN, , ahk_id %hWnd%
PostMessage, nMsg, uID, WM_RBUTTONUP  , , ahk_id %hWnd%
*/


;?out TrayIcons(sExeName = "")
TrayIcon(sExeName = "")
{
	WinGet,	pidTaskbar, PID, ahk_class Shell_TrayWnd
	hProc:=	DllCall("OpenProcess", "Uint", 0x38, "int", 0, "Uint", pidTaskbar)
	pProc:=	DllCall("VirtualAllocEx", "Uint", hProc, "Uint", 0, "Uint", 32, "Uint", 0x1000, "Uint", 0x4)
	idxTB:=	TrayIcon_GetTrayBar()
		SendMessage, 0x418, 0, 0, ToolbarWindow32%idxTB%, ahk_class Shell_TrayWnd   ; TB_BUTTONCOUNT
	Loop,	%ErrorLevel%
	{
		SendMessage, 0x417, A_Index-1, pProc, ToolbarWindow32%idxTB%, ahk_class Shell_TrayWnd   ; TB_GETBUTTON
		VarSetCapacity(btn,32,0), VarSetCapacity(nfo,32,0)
		DllCall("ReadProcessMemory", "Uint", hProc, "Uint", pProc, "Uint", &btn, "Uint", 32, "Uint", 0)
			iBitmap	:= NumGet(btn, 0)
			idn	:= NumGet(btn, 4)
			Statyle := NumGet(btn, 8)
		If	dwData	:= NumGet(btn,12)
			iString	:= NumGet(btn,16)
		Else	dwData	:= NumGet(btn,16,"int64"), iString:=NumGet(btn,24,"int64")
		DllCall("ReadProcessMemory", "Uint", hProc, "Uint", dwData, "Uint", &nfo, "Uint", 32, "Uint", 0)
		If	NumGet(btn,12)
			hWnd	:= NumGet(nfo, 0)
		,	uID	:= NumGet(nfo, 4)
		,	nMsg	:= NumGet(nfo, 8)
		,	hIcon	:= NumGet(nfo,20)
		Else	hWnd	:= NumGet(nfo, 0,"int64"), uID:=NumGet(nfo, 8), nMsg:=NumGet(nfo,12)
		WinGet, pid, PID,              ahk_id %hWnd%
		WinGet, sProcess, ProcessName, ahk_id %hWnd%
		WinGetClass, sClass,           ahk_id %hWnd%
		If !sExeName || (sExeName = sProcess) || (sExeName = pid)
			VarSetCapacity(sTooltip,128), VarSetCapacity(wTooltip,128*2)
		,	DllCall("ReadProcessMemory", "Uint", hProc, "Uint", iString, "Uint", &wTooltip, "Uint", 128*2, "Uint", 0)
		,	DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "str", wTooltip, "int", -1, "str", sTooltip, "int", 128, "Uint", 0, "Uint", 0)
		,	sTrayIcons .= "idx: " . A_Index-1 . " | idn: " . idn . " | Pid: " . pid . " | uID: " . uID . " | MessageID: " . nMsg . " | hWnd: " . hWnd . " | Class: " . sClass . " | Process: " . sProcess . "`n" . "   | Tooltip: " . sTooltip . "`n"
	}
	DllCall("VirtualFreeEx", "Uint", hProc, "Uint", pProc, "Uint", 0, "Uint", 0x8000)
	DllCall("CloseHandle", "Uint", hProc)
	Return	sTrayIcons
}

TrayIconHidden(sExeName = "")
{
	WinGet,	pidTaskbar, PID, ahk_class NotifyIconOverflowWindow
	hProc:=	DllCall("OpenProcess", "Uint", 0x38, "int", 0, "Uint", pidTaskbar)
	pProc:=	DllCall("VirtualAllocEx", "Uint", hProc, "Uint", 0, "Uint", 32, "Uint", 0x1000, "Uint", 0x4)
	idxTB:=	TrayIcon_GetTrayBar()
		SendMessage, 0x418, 0, 0, ToolbarWindow321, ahk_class NotifyIconOverflowWindow   ; TB_BUTTONCOUNT
	Loop,	%ErrorLevel%
	{
		SendMessage, 0x417, A_Index-1, pProc, ToolbarWindow321, ahk_class NotifyIconOverflowWindow   ; TB_GETBUTTON
		VarSetCapacity(btn,32,0), VarSetCapacity(nfo,32,0)
		DllCall("ReadProcessMemory", "Uint", hProc, "Uint", pProc, "Uint", &btn, "Uint", 32, "Uint", 0)
			iBitmap	:= NumGet(btn, 0)
			idn	:= NumGet(btn, 4)
			Statyle := NumGet(btn, 8)
		If	dwData	:= NumGet(btn,12)
			iString	:= NumGet(btn,16)
		Else	dwData	:= NumGet(btn,16,"int64"), iString:=NumGet(btn,24,"int64")
		DllCall("ReadProcessMemory", "Uint", hProc, "Uint", dwData, "Uint", &nfo, "Uint", 32, "Uint", 0)
		If	NumGet(btn,12)
			hWnd	:= NumGet(nfo, 0)
		,	uID	:= NumGet(nfo, 4)
		,	nMsg	:= NumGet(nfo, 8)
		,	hIcon	:= NumGet(nfo,20)
		Else	hWnd	:= NumGet(nfo, 0,"int64"), uID:=NumGet(nfo, 8), nMsg:=NumGet(nfo,12)
		WinGet, pid, PID,              ahk_id %hWnd%
		WinGet, sProcess, ProcessName, ahk_id %hWnd%
		WinGetClass, sClass,           ahk_id %hWnd%
		If !sExeName || (sExeName = sProcess) || (sExeName = pid)
			VarSetCapacity(sTooltip,128), VarSetCapacity(wTooltip,128*2)
		,	DllCall("ReadProcessMemory", "Uint", hProc, "Uint", iString, "Uint", &wTooltip, "Uint", 128*2, "Uint", 0)
		,	DllCall("WideCharToMultiByte", "Uint", 0, "Uint", 0, "str", wTooltip, "int", -1, "str", sTooltip, "int", 128, "Uint", 0, "Uint", 0)
		,	sTrayIcons .= "idx: " . A_Index-1 . " | idn: " . idn . " | Pid: " . pid . " | uID: " . uID . " | MessageID: " . nMsg . " | hWnd: " . hWnd . " | Class: " . sClass . " | Process: " . sProcess . "`n" . "   | Tooltip: " . sTooltip . "`n"
	}
	DllCall("VirtualFreeEx", "Uint", hProc, "Uint", pProc, "Uint", 0, "Uint", 0x8000)
	DllCall("CloseHandle", "Uint", hProc)
	Return	sTrayIcons
}

;?out RemoveTrayIcon(hWnd, uID, nMsg = 0, hIcon = 0, nRemove = 2)
TrayIcon_Remove(hWnd, uID, nMsg = 0, hIcon = 0, nRemove = 2)
{
	NumPut(VarSetCapacity(ni,444,0), ni)
	NumPut(hWnd , ni, 4)
	NumPut(uID  , ni, 8)
	NumPut(1|2|4, ni,12)
	NumPut(nMsg , ni,16)
	NumPut(hIcon, ni,20)
	Return	DllCall("shell32\Shell_NotifyIconA", "Uint", nRemove, "Uint", &ni)
}

;?out HideTrayIcon(idn, bHide = True)
TrayIcon_Hide(idn, bHide = True)
{
	idxTB := TrayIcon_GetTrayBar()
	SendMessage, 0x404, idn, bHide, ToolbarWindow32%idxTB%, ahk_class Shell_TrayWnd   ; TB_HIDEBUTTON
	SendMessage, 0x1A, 0, 0, , ahk_class Shell_TrayWnd
}

;?out DeleteTrayIcon(idx)
TrayIcon_Delete(idx)
{
	idxTB := TrayIcon_GetTrayBar()
	SendMessage, 0x416, idx - 1, 0, ToolbarWindow32%idxTB%, ahk_class Shell_TrayWnd   ; TB_DELETEBUTTON
	SendMessage, 0x1A, 0, 0, , ahk_class Shell_TrayWnd
}

;?out MoveTrayIcon(idxOld, idxNew)
TrayIcon_Move(idxOld, idxNew)
{
	idxTB := TrayIcon_GetTrayBar()
	SendMessage, 0x452, idxOld - 1, idxNew - 1, ToolbarWindow32%idxTB%, ahk_class Shell_TrayWnd ; TB_MOVEBUTTON
}

;?out GetTrayBar()
TrayIcon_GetTrayBar()
{
	ControlGet, hParent, hWnd,, TrayNotifyWnd1  , ahk_class Shell_TrayWnd
	ControlGet, hChild , hWnd,, ToolbarWindow321, ahk_id %hParent%
	Loop
	{
		ControlGet, hWnd, hWnd,, ToolbarWindow32%A_Index%, ahk_class Shell_TrayWnd
		If  Not	hWnd
			Break
		Else If	hWnd = %hChild%
		{
			idxTB := A_Index
			Break
		}
	}
	Return	idxTB
}
