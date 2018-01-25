#SingleInstance,Force
#Persistent
#NoEnv
DetectHiddenWindows, On

#Include,r\TrayIcon.ahk

Menu,Tray,NoStandard

VersionLog =
(Comments
0.02	Cleanup code, add/polish features and add to github
0.01	Initial quick release for https://www.reddit.com/r/garlicoin/comments/7snhqg/garlium_notification_mario_coin_sound/
)

RegExMatch(VersionLog,"^(.+?)\s",version)

ProgramName := "Garlium Mario Coin Sound" version1

Menu,Tray,Add,Test Sound,PlaySound
Menu,Tray,Add,Test Garlium Tray Tip,GetTip
Menu,Tray,Add,About,About_diag
Menu,Tray,Add,
Menu,Tray,Add,Exit,ExitTray

Menu,Tray,Tip,% ProgramName

Menu,Tray,Icon,r\garlicoin_icon.ico

swing_val := 0 ;will only play sound if increase (or decrease) of this value

garlium_exe:= "Garlium.exe" ;the exe name of your garlium

coin_sound = smb_coin.wav	;which coin sound to play on increase

;test=1 ;just a test var to test if sound works

GoSub,WinCheck

SetTimer,WinCheck,2500 ;every 2.5 seconds

Return

About_diag:
	MsgBox,,About %ProgramName%,Created by adamrgolf`n`nVersion history:`n%VersionLog%
Return

GetTip:
	garliumt := TrayIcon(garlium_exe)
	fp := RegExMatch(garliumt,"m)Tooltip:\sBalance:\s(.+?)\sGRLC",grlc2)
	MsgBox,,Garlium Tray Tip,%garliumt%`n`n%grlc21%
Return

PlaySound:
	SoundPlay,%A_ScriptDir%\r\%coin_sound%,1
	Notify("test")
Return

WinCheck:
	garlium := TrayIcon(garlium_exe)
	fp := RegExMatch(garlium,"m)Tooltip:\sBalance:\s(.+?)\sGRLC",grlc)
	If fp > 0
		{
			If (grlc1 >= old_val + swing_val) OR (grlc1 <= old_val - swing_val) OR (old_val = NULL) OR (test=1)
				{
					If (old_val <> NULL) OR (test=1)
						{
							;initial balance
							If (grlc1 > old_val) OR (test=1)
								{
									;increase in balance
									GoSub,PlaySound
								}
							If (grlc1 < old_val)
								{
									;decrease in balance
								}
						}
					old_val := grlc1
				}
		}
Return

ExitTray:
	ExitApp
Return