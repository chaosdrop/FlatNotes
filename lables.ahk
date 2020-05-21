Label1:
{
	if (U_Capslock = "1"){
		return
	}
	if (g1Open=1) {
		WinHide, FlatNotes - Library
		g1Open=0
		return
	}
	if (g1Open=0) {
		MouseGetPos, xPos, yPos	
		xPos /= 1.5
		yPos /= 1.5
		WinMove, ahk_id %g1ID%, , %xPos%, %yPos%
		WinShow, ahk_id %g1ID%
		WinRestore, ahk_id %g1ID%
		WinActivate, ahk_id %g1ID%
		g1Open=1
		return
	}
}
Label2:
{
	IniRead,sendCtrlC,%iniPath%,General,sendCtrlC, 1
	if (sendCtrlC="1")
		send {Ctrl Down}{c}{Ctrl up}
		clipboard := clipboard

BuildGUI2()

GuiControl,, QuickNoteName,%clipboard%
GuiControl,, FileSafeName,%FileSafeClipBoard%
GuiControl, +Redraw, FileSafeName
GuiControl, +Redraw, QuickNoteName
ControlFocus, Edit2, FlatNote - QuickNote 
if (OldNoteData !="")
{
	FilePath = %U_NotePath%%FileSafeClipBoard%.txt
	FileRead, MyFile, %FilePath%
	GuiControl,, QuickNoteBody,%MyNewFile%
	GuiControl, +Redraw, QuickNoteBody
}
return
}
Label3:
{
	if(istitle != "no") {
		send {Ctrl Down}{c}{Ctrl up}
		ztitle := clipboard
		;only first line for title to prevent fail
		Loop, parse, clipboard, `n, `r
			{
				%A_Index%ztitle = %A_LoopField%
				if (A_Index = 2)
					break
			}
		;trim space and tab
		ztitle := Trim(1ztitle," 	")
		IfExist, %U_NotePath%%ztitle%.txt 
			msgbox A note with this title already exsits.
		IfExist, %U_NotePath%%ztitle%.txt
			return
		
		istitle = no
		tooltip T: %ztitle%
		settimer, KillToolTip, -500
		return
	}
	if(istitle = "no") {
		send {Ctrl Down}{c}{Ctrl up}
		zbody := clipboard 
		istitle = yes
		TmpFileSafeName := RegExReplace(ztitle, "\*|\?|\\|\||/|""|:|<|>" , Replacement := "_")
		FileReadLine, CheckExists, %U_NotePath%%TmpFileSafeName%.txt, 1
		SaveFile(ztitle,TmpFileSafeName,zbody,0)
		;MakeFileList(1)
		gosub search
		tooltip B: %zbody%
		settimer, KillToolTip, -500
	}
	return
}



Label4:
{
	istitle = yes
	tooltip cancled
	settimer,KillToolTip,-1000
	return 
}
SaveButton:
{
	GuiControlGet,FileSafeName,,FileSafeName
	if (QuickNoteName == ""){
		MsgBox Note Name Can Not Be Empty
	return
	}
	Gui, 2:Submit
	SaveMod = 0
	IfExist, %U_NotePath%%FileSafeName%.txt
		SaveMod = 1
	SaveFile(QuickNoteName,FileSafeName,QuickNoteBody,SaveMod)
	;horrible fix to LV to update
	GuiControlGet,SearchTerm
	GuiControl,1: , SearchTerm,
	GuiControl,1: , SearchTerm,
	if WinActive("FlatNotes - Library"){
		send {space}{backspace} ;update results
	}
	tooltip Saved
	settimer, KillToolTip, -500
	return
}

QuickSafeNameUpdate:
{
	GuiControlGet, QuickNoteName
	;Remove stray whitespace from front and back
	;QuickNoteName := Ltrim(QuickNoteName," ")
	;QuickNoteName := Rtrim(QuickNoteName," ")
	NewFileSafeName := RegExReplace(QuickNoteName, "\*|\?|\\|\||/|""|:|<|>" , Replacement := "_")
	GuiControl,, FileSafeName,%NewFileSafeName%
	return
}
Search:
{
	if (unsaveddataEdit3 = 1)
		gosub Edit3SaveTimer
	global SearchTerm
	GuiControlGet, SearchTerm
	GuiControl, -Redraw, LV
	LV_Delete()
	If (InStr(SearchTerm, "$$") != 0) {
		SearchTerm := StrReplace(SearchTerm, "$$" , "")
		For Each, Note In MyNotesArray
		{
		  If (SearchTerm != "")
		  {
			If (InStr(Note.2, SearchTerm) != 0){
			 LV_Add("", Note.1, Note.2,Note.3,Note.4,Note.5,Note.6,Note.7,Note.8,Note.9)
			   }
			}
			Else
			  LV_Add("", Note.1, Note.2,Note.3,Note.4,Note.5,Note.6,Note.7,Note.8,Note.9)
		}
	gosub UpdateStatusBar
	return
	}
	
	For Each, Note In MyNotesArray
	{
	   If (SearchTerm != "")
	   {
			If (InStr(Note.1, SearchTerm) != 0){
			 LV_Add("", Note.1, Note.2,Note.3,Note.4,Note.5,Note.6,Note.7,Note.8,Note.9)
			}Else if (InStr(Note.2, SearchTerm) != 0)
		   {LV_Add("", Note.1, Note.2,Note.3,Note.4,Note.5,Note.6,Note.7,Note.8,Note.9)
		   }Else if (InStr(Note.3, SearchTerm) != 0)
		   {LV_Add("", Note.1, Note.2,Note.3,Note.4,Note.5,Note.6,Note.7,Note.8,Note.9)
		   }Else if (InStr(Note.4, SearchTerm) != 0)
		   {LV_Add("", Note.1, Note.2,Note.3,Note.4,Note.5,Note.6,Note.7,Note.8,Note.9)
		   }Else if (InStr(Note.5, SearchTerm) != 0)
		   {LV_Add("", Note.1, Note.2,Note.3,Note.4,Note.5,Note.6,Note.7,Note.8,Note.9)
		   }
	   }
	   Else
		  LV_Add("", Note.1, Note.2,Note.3,Note.4,Note.5,Note.6,Note.7,Note.8,Note.9)
	}
	gosub UpdateStatusBar
	Return
}
UpdateStatusBar:
{
	Items := LV_GetCount()
	if (Items != 0) {
		LV_GetText(LastResultName, 1 , 2)
		LV_GetText(LastFileName, 1 , 8)
		LV_GetText(LastNoteAdded, 1 , 4)
		LV_GetText(LastNoteModded, 1 , 5)
		GuiControl,,TitleBar, %LastResultName%
		FileRead, LastResultBody,%U_NotePath%%LastFileName%
		LastNoteIni := StrReplace(LastFileName, ".txt",".ini") 

		GuiControl,,PreviewBox, %LastResultBody%
		GuiControl,, StatusbarM,M: %LastNoteModded%
		GuiControl,, StatusbarA,A: %LastNoteAdded%
		}else{
			GuiControl,,TitleBar, 
			GuiControl,,PreviewBox,
			GuiControl,,StatusBarM,M: 00\00\00 
			GuiControl,,StatusBarA,A: 00\00\00
		}
	;ReFreshLV()
	;gosub SortNow
	GuiControl,,StatusBarCount, %Items% of %TotalNotes%
	GuiControl, +Redraw, LV
	return
}
KillToolTip:
{
   ToolTip
Return
}

UnDoom:
{
	Doom = 0
return
}
HandleMessage( p_w, p_l, p_m, p_hw )
{
	if ( A_GuiControl = "LV" )
	{
		VarSetCapacity( htinfo, 20 )

		DllCall( "RtlFillMemory", "uint", &htinfo, "uint", 1, "uchar", p_l & 0xFF )
			DllCall( "RtlFillMemory", "uint", &htinfo+1, "uint", 1, "uchar", ( p_l >> 8 ) & 0xFF )
		DllCall( "RtlFillMemory", "uint", &htinfo+4, "uint", 1, "uchar", ( p_l >> 16 ) & 0xFF )
			DllCall( "RtlFillMemory", "uint", &htinfo+5, "uint", 1, "uchar", ( p_l >> 24 ) & 0xFF )
		
		; LVM_SUBITEMHITTEST
		SendMessage, 0x1000+57, 0, &htinfo,, ahk_id %p_hw%
		sel_item := ErrorLevel
		
		if ( sel_item = -1 )
			return
		
		; LVHT_NOWHERE
		if ( *( &htinfo+8 ) & 1 )
			%A_GuiControl%@sel_col = 0
		else
			%A_GuiControl%@sel_col := 1+*( &htinfo+16 )
	}
	
	ToolTip
}
NoteListView:
{
Critical
;z := A_GuiEvent errorlevel A_EventInfo
;tooltip % z
;tooltip % x
;settimer,KillToolTip,-1000
if (ListTitleToChange = 1){
			LV_Modify(LVSelectedROW,,, NewTitle,,,,,,NewTitleFileName)
			ListTitleToChange = 0
		}
if (unsaveddataEdit3 = 1)
	gosub Edit3SaveTimer
if (A_GuiEvent = "I")
	LastRowSelected := A_EventInfo
; make arrow down from search feel right by avoiding the header.
if (A_GuiEvent == "F" && firstDown == "1" && A_EventInfo == "0"){
	send {down}{up}
	firstDown = 0
	Doom = 1
	SetTimer, UnDoom, -50
}

TotalItems := LV_GetCount()
if (A_EventInfo = TotalItems && Doom = 1 && A_GuiEvent = "Normal"){
	send {down}
}
;Something for double click
if (A_GuiEvent = "DoubleClick")
{
	if (LV@sel_col=2) {
		LV_GetText(CopyText, A_EventInfo, 2)
		clipboard := CopyText
		Tooltip % CopyText " Copied"
	}
	if (LV@sel_col=3) {
		LV_GetText(FileTmp, A_EventInfo, 8)
		LV_GetText(ToolTipText, A_EventInfo, 3)
		fileread,CopyText,%U_NotePath%%FileTmp%
		clipboard := CopyText
		Tooltip % ToolTipText "... Copied"

	}
	if (LV@sel_col=4) {
		LV_GetText(CopyText, A_EventInfo, 4)
		clipboard := CopyText
		Tooltip % CopyText " Copied"
	}
	if (LV@sel_col=5) {
		LV_GetText(CopyText, A_EventInfo, 5)
		clipboard := CopyText
		Tooltip % CopyText " Copied"
	} 
	settimer,KillToolTip, -500
    return
}
;update the preview
if (A_GuiEvent = "I" && InStr(ErrorLevel, "S", true))
{
	global LVSelectedROW = A_EventInfo
    LV_GetText(RowText, A_EventInfo,8)
	LV_GetText(C_Added, A_EventInfo,4)
    LV_GetText(C_Modded, A_EventInfo,5)
	LV_GetText(C_Name, A_EventInfo,2)
    FileRead, NoteFile, %U_NotePath%%RowText%
	GuiControl,, PreviewBox, %NoteFile%
	GuiControl,, TitleBar, %C_Name%
	GuiControl,, StatusbarM,M: %C_Modded%
	GuiControl,, StatusbarA,A: %C_Added%
}
;1Star|2Title|3Body|4Added|5Modified|6RawAdded|7RawModded|8FileName|9RawStar

	if A_GuiEvent in Normal
	{
		if (LV@sel_col=1) {
			LV_GetText(CurrentStar, A_EventInfo, 9)
			LV_GetText(C_FileName, A_EventInfo, 8)
			LV_GetText(C_Name, A_EventInfo, 2)
			C_ini := StrReplace(C_FileName, ".txt" , ".ini")
			C_SafeName := StrReplace(C_FileName, ".txt" , "")
			fileread, C_Body, %U_NotePath%%C_FileName%
			If (CurrentStar = "")
				CurrentStar = 0
			NextStar := CurrentStar+1
			if (CurrentStar=4)
				NextStar=0
			if (NextStar=0)
				UpdateStar:=A_Space
			if (NextStar=1)
				UpdateStar:=Star1
			if (NextStar=2)
				UpdateStar:=Star2
			if (NextStar=3)
				UpdateStar:=Star3
			if (NextStar=4)
				UpdateStar:=Star4
				
			LV_Modify(A_EventInfo ,,UpdateStar,C_Name,,,,,,,NextStar)
			IniWrite, %NextStar%, %detailsPath%%C_ini%, INFO, Star
			SaveFile(C_Name,C_SafeName,C_Body,1)	
		}
	}
	; change star on space
	if (A_GuiEvent = "K" and A_EventInfo = "32") {
		LV_GetText(CurrentStar, LastRowSelected, 9)
		LV_GetText(C_FileName, LastRowSelected, 8)
		LV_GetText(C_Name, LastRowSelected, 2)
		C_ini := StrReplace(C_FileName, ".txt" , ".ini")
		C_SafeName := StrReplace(C_FileName, ".txt" , "")
		fileread, C_Body, %U_NotePath%%C_FileName%
		If (CurrentStar = "")
			CurrentStar = 0
		NextStar := CurrentStar+1
		if (CurrentStar=4)
			NextStar=0
		if (NextStar=0)
			UpdateStar:=A_Space
		if (NextStar=1)
			UpdateStar:=Star1
		if (NextStar=2)
			UpdateStar:=Star2
		if (NextStar=3)
			UpdateStar:=Star3
		if (NextStar=4)
			UpdateStar:=Star4
			
		LV_Modify(LastRowSelected ,,UpdateStar,C_Name,,,,,,,NextStar)
		IniWrite, %NextStar%, %detailsPath%%C_ini%, INFO, Star
		SaveFile(C_Name,C_SafeName,C_Body,1)	
		return		
	}
	if (A_GuiEvent = "K") {
		if (A_EventInfo = "113") {
				LV_GetText(tOldFile, LVSelectedROW,8)
				EnterKey := A_EventInfo
				 WinGetPos mwx, mwy, mww, mwh, FlatNotes - Library
				ControlGetPos, s6x, s6y, s6w, s6h, static6,FlatNotes - Library
				xPos :=mwx+StarColW
				yPos :=mwy+(s6y/2)
				gosub build_tEdit
		}
	}
	if A_GuiEvent in RightClick
	{
		LV_GetText(tOldFile, LVSelectedROW,8)
		if (LV@sel_col=2) {
			MouseGetPos, xPos, yPos
			xPos := xPos+25
			gosub build_tEdit
			return
		}
	}
	if A_GuiEvent in LeftClick
	{

	}
return
}
build_tEdit:
{
	GUI, t:new, ,TMPedit000
	Gui, t:Margin , 5, 5 
	Gui, t:Font, s%SearchFontSize% Q%FontRendering%, %SearchFontFamily%, %U_MFC%
	Gui, t:Color,%U_SBG%, %U_MBG%	

	gui, t:add,text,w100 -E0x200 center c%U_SFC%,New Name
	Gui, t:add,edit,w100 -E0x200 c%U_SFC% vtEdit
	gui, t:add,button, default gTitleSaveChange x-10000 y-10000
	WinSet, Style,  -0xC00000,TMPedit000
	GUI, t:Show, x%xPos% y%yPos%
	return
}
About:
{
Gui, 4:add,text,,FlatNotes Version 2.5.1 May 2020
Gui, 4:Add,Link,,<a href="https://github.com/chaosdrop/FlatNotes">GitHub Page</a>
Gui, 4:add,button,g4GuiEscape,Close
Gui, 4:Show
return
}

Library:
{
    WinGetPos,,, Width, Height, ahk_id %g1ID%
	WinMove, ahk_id %g1ID%,, (A_ScreenWidth/2)-(Width/2), (A_ScreenHeight/2)-(Height/2)
	g1Open=1
	WinShow, ahk_id %g1ID%
	WinRestore, ahk_id %g1ID%
	return
}
CtrlCToggle:
{
	GuiControlGet, SetCtrlC
	if (SetCtrlC = 1)
		IniWrite, 1, %iniPath%, General, sendCtrlC
	if (SetCtrlC = 0)
		IniWrite, 0, %iniPath%, General, sendCtrlC
	return
}
UseCapslockToggle:
{
	GuiControlGet, UseCapslock
	
	if (UseCapslock = 1)
		GuiControl, Disable, msctls_hotkey321
	if (UseCapslock = 0)
		GuiControl, Enable, msctls_hotkey321
	if (A_GuiEvent == "Normal"){
		IniWrite,%UseCapslock%, %iniPath%, General, UserSetKey
		return
	}
return
}

ColorPicked:
{
	if (A_GuiEvent == "Normal"){	
		GuiControlGet, ColorPicked,,ColorChoice
		pathToTheme = %A_WorkingDir%\Themes\%ColorPicked%.ini
		
		IniRead, U_MBG, %pathToTheme%, Colors, MainBackgroundColor
		IniRead, U_SBG, %pathToTheme%, Colors, SubBackgroundColor
		IniRead, U_MFC, %pathToTheme%, Colors, MainFontColor
		IniRead, U_SFC, %pathToTheme%, Colors, SubFontColor
		IniRead, U_MSFC, %pathToTheme%, Colors, MainSortFontColor
		IniRead, U_FBCA, %pathToTheme%, Colors, SearchBoxFontColor
		IniRead, rowSelectColor, %pathToTheme%, Colors, RowSelectColor
		IniRead, rowSelectTextColor, %pathToTheme%, Colors, RowSelectTextColor
		IniRead, themeNumber, %pathToTheme%, Theme, UserSetting
		
		
		;save theme number
		IniWrite, %themeNumber%, %iniPath%, Theme, UserSetting
		
		;save theme name
		IniWrite, %ColorPicked%, %iniPath%, Theme, Name
		
	}
	gosub DummyGUI1
}
SortStar:
	{
		if (NextSortStar ="1") {
			LV_ModifyCol(1, "SortDesc")
			NextSortStar = 0
			NextSortBody = 0
			NextSortAdded = 0
			C_SortCol = 1
			C_SortDir = SortDesc
		}else {
			LV_ModifyCol(1, "Sort")
			NextSortStar = 1
			NextSortBody = 0
			NextSortAdded = 0
			NextSortName = 0
			C_SortCol = 1
			C_SortDir = Sort
			Gui, Font, s%ResultFontSize% Q%FontRendering% c%U_MSFC%, %ResultFontFamily%, %U_SFC%
			GuiControl, Font, SortStar
			Gui, Font, s%ResultFontSize% Q%FontRendering% c%U_SFC%, %ResultFontFamily%, %U_SFC%
			GuiControl, Font, SortBody
			GuiControl, Font, SortName
			GuiControl, Font, SortAdded
			GuiControl, Font, SortModded
			
		}
		return
	}
SortName:
	{
		if (NextSortName ="1") {
			LV_ModifyCol(2, "SortDesc")
			NextSortName = 0
			NextSortBody = 0
			NextSortAdded = 0
			NextSortStar = 0
			C_SortCol = 2
			C_SortDir = SortDesc
		}else {
			LV_ModifyCol(2, "Sort")
			NextSortName = 1
			NextSortBody = 0
			NextSortAdded = 0
			NextSortStar = 0
			C_SortCol = 2
			C_SortDir = Sort
			Gui, Font, s%ResultFontSize% Q%FontRendering% c%U_MSFC%, %ResultFontFamily%, %U_SFC%
			GuiControl, Font, SortName
			Gui, Font, s%ResultFontSize% Q%FontRendering% c%U_SFC%, %ResultFontFamily%, %U_SFC%
			GuiControl, Font, SortBody
			GuiControl, Font, SortAdded
			GuiControl, Font, SortModded
			GuiControl, Font, SortStar
		}
		return
	}
SortBody:
{
		if (NextSortBody ="1") {
			LV_ModifyCol(3, "SortDesc")
			NextSortBody = 0
			NextSortName = 0
			NextSortAdded = 0
			NextSortStar = 0
			C_SortCol = 3
			C_SortDir = SortDesc
		}else {
			LV_ModifyCol(3, "Sort")
			NextSortBody = 1
			NextSortName = 0
			NextSortAdded = 0
			NextSortStar = 0
			C_SortCol = 3
			C_SortDir = Sort
			Gui, Font, s%ResultFontSize% Q%FontRendering% c%U_MSFC%, %ResultFontFamily%, %U_SFC%
			GuiControl, Font, SortBody
			Gui, Font, s%ResultFontSize% Q%FontRendering% c%U_SFC%, %ResultFontFamily%, %U_SFC%
			GuiControl, Font, SortName
			GuiControl, Font, SortAdded
			GuiControl, Font, SortModded
			GuiControl, Font, SortStar
		}
		return
	}
SortAdded:
{
		if (NextSortAdded ="1") {
			LV_ModifyCol(6, "SortDesc")
			NextSortAdded = 0
			NextSortName = 0
			NextSortBody = 0
			NextSortStar = 0
			C_SortCol = 6
			C_SortDir = SortDesc
		}else {
			LV_ModifyCol(6, "Sort")
			NextSortAdded = 1
			NextSortName = 0
			NextSortBody = 0
			NextSortStar = 0
			C_SortCol = 6
			C_SortDir = Sort
			Gui, Font, s%ResultFontSize% Q%FontRendering% c%U_MSFC%, %ResultFontFamily%, %U_SFC%
			GuiControl, Font, SortAdded
			Gui, Font, s%ResultFontSize% Q%FontRendering% c%U_SFC%, %ResultFontFamily%, %U_SFC%
			GuiControl, Font, SortBody
			GuiControl, Font, SortName
			GuiControl, Font, SortModded
			GuiControl, Font, SortStar
		}
		return
	}
SortModded:
{
		if (NextSortAdded ="1") {
			LV_ModifyCol(7, "SortDesc")
			NextSortAdded = 0
			NextSortName = 0
			NextSortStar = 0
			NextSortBody = 0
			C_SortCol = 7
			C_SortDir = SortDesc
		}else {
			LV_ModifyCol(7, "Sort")
			NextSortAdded = 1
			NextSortName = 0
			NextSortBody = 0
			NextSortStar = 0
			C_SortCol = 7
			C_SortDir = Sort
			Gui, Font, s%ResultFontSize% Q%FontRendering% c%U_MSFC%, %ResultFontFamily%, %U_SFC%
			GuiControl, Font, SortModded
			Gui, Font, s%ResultFontSize% Q%FontRendering% c%U_SFC%, %ResultFontFamily%, %U_SFC%
			GuiControl, Font, SortBody
			GuiControl, Font, SortName
			GuiControl, Font, SortAdded
			GuiControl, Font, SortStar
		}
		return
	}
FolderSelect:
{
		WinSet, AlwaysOnTop, Off, FlatNotes - Options
		FileSelectFolder, NewNotesFolder, , 123
		if NewNotesFolder =
			GuiControl,,NotesStorageFolder,%U_NotePath%
		else
			GuiControl,,NotesStorageFolder,%NewNotesFolder%\
		IniWrite, %NewNotesFolder%\, %iniPath%, General, MyNotePath
		WinSet, AlwaysOnTop, On, FlatNotes - Options
		return
	}
Options:
{

Fontlist := "fontlist.cfg"
FileRead, FontFile, % Fontlist
FontOptionsArray := []
loop, parse, FontFile, `n
	FontOptionsArray.push(A_LoopField)
For k, fonts in FontOptionsArray
	FontDropDownOptions .= fonts "|"


		Gui, 3:New,,FlatNotes - Options
		Gui, 3:Add, Tab3,, General|Hotkeys|Appearance|Window Size
		Gui, 3:Tab, General
		Gui, 3:Add,Text,section, Notes storage folder:
		Gui, 3:Add,Edit, disabled r1 w300 vNotesStorageFolder, %U_NotePath%
		Gui, 3:Add,Button, gFolderSelect, Select a folder.
		
		Gui, 3:Add,Text,xs section,How many daily backups to keep: (Default: 3)
		Gui, 3:Add,Edit, yp-5 x+5 w25
		Gui, 3:Add,UpDown,vbackupsToKeepSelect gSet_backupsToKeep range0-99, %backupsToKeep%
		Gui, 3:Add,CheckBox, xs vShowStatusBarSelect gSetShowStatusBar, Show Library Window Statusbar?
		GuiControl,,ShowStatusBarSelect,%ShowStatusBar%

		Gui, 3:Add,text,xs section,Time format Default(yy/MM/dd) [yyyyMMMMddddhhHHmmsstt]
		Gui, 3:Add,edit, w150 gSet_UserTimeFormat vSelect_UserTimeFormat,%UserTimeFormat%
		
		Gui, 3:add,DropDownList, xs section Choose%RawDeafultSort% AltSubmit vSelect_DeafultSort gSet_DeafultSort, Satr|Name|Body|Added|Modified
		Gui, 3:add,DropDownList, x+15 Choose%DeafultSortDir% AltSubmit vSelect_DeafultSortDir gSet_DeafultSortDir, Accending|Decending
		
		Gui, 3:add,text, xs section, Star 1 | Star 2 | Star 3 | Star 4 (Win+; brings up Emoji Keyboard)
		Gui, 3:add,edit, xs center w30 gSet_Star1 vSelect_Star1,%Star1%
		Gui, 3:add,edit, x+5 center w30 gSet_Star2 vSelect_Star2,%Star2%
		Gui, 3:add,edit, x+5 center w30 gSet_Star3 vSelect_Star3,%Star3%
		Gui, 3:add,edit, x+5 center w30 gSet_Star4 vSelect_Star4
		,%Star4%
		
		;Hotkeys Tab
		Gui, 3:Tab, Hotkeys
		Gui, 3:Add,CheckBox, vSetCtrlC gCtrlCToggle, Send Ctrl+C when using the quick note hotkey.
		Gui, 3:Add, CheckBox, vUseCapslock gUseCapslockToggle, Use Capslock for Library?
		GuiControl,,UseCapslock,%U_Capslock%
		GuiControl,,SetCtrlC,%sendCtrlC%
		Gui, 3:Add,text, h1 Disabled 			
 		
		HotkeyNames := ["Show Library Window","Quick New Note","Rapid Save","Cancel Rapid Save"]
		Loop,% 4 {
			HotkeyNameTmp := HotkeyNames[A_Index]
			Gui, 3:Add, Text, , Hotkey: %HotkeyNameTmp%
			IniRead, savedHK%A_Index%, settings.ini, Hotkeys, %A_Index%, %A_Space%
   
			StringReplace, noMods, savedHK%A_Index%, ~                  
			StringReplace, noMods, noMods, #,,UseErrorLevel              
			Gui, 3:Add, Hotkey, section vHK%A_Index% gLabel, %noMods%           
			Gui, 3:Add, CheckBox, x+5  vCB%A_Index% Checked%ErrorLevel%, Win
			Gui, 3:Add,text, h0 xs0 Disabled
		}                                                        
		if (U_Capslock = 1)
			GuiControl, Disable, msctls_hotkey321

		;Appearance Tab
		Gui, 3:Tab, Appearance
		Gui, 3:Add,Text,,Font Rendering: (5 = ClearType)
		Gui, Add, Edit 
		Gui, 3:Add,UpDown, vFontRenderingSelect gSetFontRendering Range0-5, %FontRendering%
		
		Gui, 3:Add, CheckBox, vHideScrollbarsSelect gSetHideScrollbars, Hide Scroolbars where possible.
		GuiControl,,HideScrollbarsSelect,%HideScrollbars%
		
		
		
		Gui, 3:Add,Text,,Theme Selection:
		Loop, Files, %themePath%\*.ini
		{
			themeFileList .= A_LoopFileName "|"
			IniWrite, %A_index%,%themePath%\%A_LoopFileName%,Theme,UserSetting
			themeList := StrReplace(themeFileList, ".ini" , "")
		}
		Gui, 3:Add,DropDownList, Choose%U_Theme% vColorChoice gColorPicked, %themeList%
		
		CurrentFont = 1
		C_PreviewFont = 1
		C_StickyFont = 1
		C_ResultFont = 1
		C_SearchFont = 1
		for k, v in FontOptionsArray
		{ 
			if (v = FontFamily) 
				CurrentFont := k
		} 
		for k, v in FontOptionsArray
		{ 
			if (v = PreviewFontFamily) 
				C_PreviewFont := k
		} 
		for k, v in FontOptionsArray
		{ 
			if (v = ResultFontFamily) 
				C_ResultFont := k
		} 
		for k, v in FontOptionsArray
		{ 
			if (v = SearchFontFamily) 
				C_SearchFont := k
		}
		for k, v in FontOptionsArray
		{ 
			if (v = StickyFontFamily) 
				C_StickyFont := k
		} 
		Gui, 3:Add,text,section, Quick Note Interface font settings:
		Gui, 3:add,DropDownList, Choose%CurrentFont% w100 vFontFamilySelect gSetFontFamily, %FontDropDownOptions%
		CurrentFontSize := FontSize*0.5
		Gui, 3:add,DropDownList, x+10 Choose%CurrentFontSize% vFontSizeSelect gSetFontSize, 2|4|6|8|10|12|14|16|18|20|22|24|26|28|30|32|34|36|38|40|42|44|46|48|50|52|54|56|58|60|62|64|66|68|70|72|74|76|78|80|82|84|86|88|90|92|94|96|98|100
		Gui, 3:Add,text,xs section, Search Box font settings:
		Gui, 3:add,DropDownList, Choose%C_SearchFont% w100 vSearchFontFamilySelect gSetSearchFontFamily,%FontDropDownOptions%
		CurrenSearchFontSize := SearchFontSize*0.5
		Gui, 3:add,DropDownList, x+10 Choose%CurrenSearchFontSize% vSearchFontSizeSelect gSetSearchFontSize, 2|4|6|8|10|12|14|16|18|20|22|24|26|28|30|32|34|36|38|40|42|44|46|48|50|52|54|56|58|60|62|64|66|68|70|72|74|76|78|80|82|84|86|88|90|92|94|96|98|100
		Gui, 3:Add,text,xs section, Result font settings:
		Gui, 3:add,DropDownList, Choose%C_ResultFont% w100 vResultFontFamilySelect gSetResultFontFamily, %FontDropDownOptions%
		CurrenResulttFontSize := ResultFontSize*0.5
		Gui, 3:add,DropDownList, x+10 Choose%CurrenResulttFontSize% vResultFontSizeSelect gSetResultFontSize, 2|4|6|8|10|12|14|16|18|20|22|24|26|28|30|32|34|36|38|40|42|44|46|48|50|52|54|56|58|60|62|64|66|68|70|72|74|76|78|80|82|84|86|88|90|92|94|96|98|100
		Gui, 3:Add,text,xs section, Note font settings:
		Gui, 3:add,DropDownList, Choose%C_PreviewFont% w100 vPreviewFontFamilySelect gSetPreviewFontFamily, %FontDropDownOptions%
		CurrentPreviewFontSize := PreviewFontSize*0.5
		Gui, 3:add,DropDownList, x+10 Choose%CurrentPreviewFontSize% vPreviewFontSizeSelect gSetPreviewFontSize, 2|4|6|8|10|12|14|16|18|20|22|24|26|28|30|32|34|36|38|40|42|44|46|48|50|52|54|56|58|60|62|64|66|68|70|72|74|76|78|80|82|84|86|88|90|92|94|96|98|100
		
		Gui, 3:Add,text,xs section, Sticky Note font settings:
		Gui, 3:add,DropDownList, Choose%C_StickyFont% w100 vStickyFontFamilySelect gSetStickyFontFamily, %FontDropDownOptions%
		CurrentStickyFontSize := StickyFontSize*0.5
		Gui, 3:add,DropDownList, x+10 Choose%CurrentStickyFontSize% vStickyFontSizeSelect gSetStickyFontSize, 2|4|6|8|10|12|14|16|18|20|22|24|26|28|30|32|34|36|38|40|42|44|46|48|50|52|54|56|58|60|62|64|66|68|70|72|74|76|78|80|82|84|86|88|90|92|94|96|98|100
		
		Gui, 3:Add,Text,xs,Column Width Percentage Star | Name | Body | Added | Modified 
		
		Gui, Add, Edit, w50
		Gui, 3:Add,UpDown, vStarPercentSelect gSet_StarPercent Range0-100, %oStarPercent%
		Gui, Add, Edit, w50 x+5
		Gui, 3:Add,UpDown, vNamePercentSelect gSet_NamePercent Range0-100, %oNamePercent%
		Gui, Add, Edit, w50 x+5
		Gui, 3:Add,UpDown,  vBodyPercentSelect gSet_BodyPercent Range0-100, %oBodyPercent%
		Gui, Add, Edit, w50 x+5
		Gui, 3:Add,UpDown,  vAddedPercentSelect gSet_AddedPercent Range0-100, %oAddedPercent%
		Gui, Add, Edit, w50 x+5
		Gui, 3:Add,UpDown,  vModdedPercentSelect gSet_ModdedPercent Range0-100, %oModdedPercent%
		
		;Window Size Options Tab
		Gui, 3:Tab, Window Size
		Gui, 3:Add,Text,section,Main Window Width: (Default: 530)
		Gui, 3:Add,Edit   
		Gui, 3:Add,UpDown,vMainWSelect gSetMainW range50-3000, %LibW%
		
		Gui, 3:Add,Text,xs,Result Rows: (Default: 8)
		Gui, 3:Add,Edit   
		Gui, 3:Add,UpDown,vResultRowsSelect gSetResultRows range1-99, %ResultRows%
		
		Gui, 3:Add,Text,xs,Note Preview/Edit Rows: (Default: 8)
		Gui, 3:Add,Edit   
		Gui, 3:Add,UpDown,vPreviewRowsSelect gSetPreviewRows range1-99, %PreviewRows%
		
		Gui, 3:Add,Text,xs,Quick Note Window Width: (Default: 500)

		Gui, 3:Add,Edit   
		Gui, 3:Add,UpDown,vQuickWSelect gSetQuickW range50-3000, %QuickNoteWidth%
		
		Gui, 3:Add,Text,xs,Quick Note Rows: (Default: 7)
		Gui, 3:Add,Edit   
		Gui, 3:Add,UpDown,vQuickNoteRowsSelect gSetQuickNoteRows range1-99, %QuickNoteRows%
		
		Gui, 3:Add,Text,xs,Sticky Note Width: (Default: 250)
		
		Gui, 3:Add,Edit   
		Gui, 3:Add,UpDown,vSelect_StickyW gSet_StickyW range50-3000, %StickyW%
		
		Gui, 3:Add,Text,xs,Sticky Note Rows: (Default: 8)
		Gui, 3:Add,Edit   
		Gui, 3:Add,UpDown,vSelect_StickyRows gSet_StickyRows range1-99, %StickyRows%
		
		Gui, 3:Tab 
		Gui, 3:Add, Button, Default gSaveAndReload, Save and Reload
		Gui, 3:SHOW 
		WinSet, AlwaysOnTop, On, FlatNotes - Options
		return
	}
  
SaveAndReload:
{ 
	GuiControlGet, U_QuickNoteWidth,,QuickWSelect	
	IniWrite, %U_QuickNoteWidth%,%iniPath%,General, QuickNoteWidth
	GuiControlGet, U_MainNoteWidth,,MainWSelect	
	IniWrite, %U_MainNoteWidth%,%iniPath%,General, WindowWidth	
	GuiControlGet, U_FontRendering,,FontRenderingSelect	
	IniWrite, %U_FontRendering%,%iniPath%,General, FontRendering
	GuiControlGet, U_SearchFontFamily,,SearchFontFamilySelect
	IniWrite, %U_SearchFontFamily%,%iniPath%,General, SearchFontFamily
	GuiControlGet, U_SearchSize,,SearchFontSizeSelect	
	IniWrite, %U_SearchSize%,%iniPath%,General, SearchFontSize
	GuiControlGet, U_ResultFontFamily,,ResultFontFamilySelect
	IniWrite, %U_ResultFontFamily%,%iniPath%,General, ResultFontFamily	
	GuiControlGet, U_ResultSize,,ResultFontSizeSelect	
	IniWrite, %U_ResultSize%,%iniPath%,General, ResultFontSize
	GuiControlGet, U_PreviewFontFamily,,PreviewFontFamilySelect
	IniWrite, %U_PreviewFontFamily%,%iniPath%,General, PreviewFontFamily	
	GuiControlGet, U_PreviewSize,,PreviewFontSizeSelect	
	IniWrite, %U_PreviewSize%,%iniPath%,General, PreviewFontSize
	GuiControlGet, U_FontFamily,,FontFamilySelect
	IniWrite, %U_FontFamily%,%iniPath%,General, FontFamily	
	GuiControlGet, U_FontSize,,FontSizeSelect	
	IniWrite, %U_FontSize%,%iniPath%,General, FontSize
	GuiControlGet, U_PreviewRows,,PreviewRowsSelect	
	IniWrite, %U_PreviewRows%,%iniPath%,General, PreviewRows	
	GuiControlGet, U_ResultRows,,ResultRowsSelect	
	IniWrite, %U_ResultRows%,%iniPath%,General, ResultRows	
	GuiControlGet, U_QuickNoteRows,,QuickNoteRowsSelect	
	IniWrite, %U_QuickNoteRows%,%iniPath%,General, QuickNoteRows
	GuiControlGet, U_QuickNoteWidth,,QuickWSelect	
	IniWrite, %U_QuickNoteWidth%,%iniPath%,General, QuickNoteWidth
	GuiControlGet, U_MainNoteWidth,,MainWSelect	
	IniWrite, %U_MainNoteWidth%,%iniPath%,General, WindowWidth	
	GuiControlGet, U_FontRendering,,FontRenderingSelect	
	IniWrite, %U_FontRendering%,%iniPath%,General, FontRendering
	GuiControlGet,HideScrollbarsSelect
	IniWrite,%HideScrollbarsSelect%, %iniPath%, General, HideScrollbars
	GuiControlGet,ShowStatusBarSelect
	IniWrite,%ShowStatusBarSelect%, %iniPath%, General, ShowStatusBar
	
	GuiControlGet, StarPercentSelect	
	GuiControlGet, NamePercentSelect	
	GuiControlGet, BodyPercentSelect	
	GuiControlGet, AddedPercentSelect
	GuiControlGet, ModdedPercentSelect	
		

	is100 := StarPercentSelect+NamePercentSelect+BodyPercentSelect+AddedPercentSelect+ModdedPercentSelect
	WinSet, AlwaysOnTop, Off, FlatNotes - Options
	if (is100 >= 110){
		msgbox Column total width above 110 please fix.
		return
	}
	IniWrite, %StarPercentSelect%,%iniPath%,General, StarPercent
	IniWrite, %NamePercentSelect%,%iniPath%,General, NamePercent		
	IniWrite, %BodyPercentSelect%,%iniPath%,General, BodyPercent		
	IniWrite, %AddedPercentSelect%,%iniPath%,General, AddedPercent
	IniWrite, %ModdedPercentSelect%,%iniPath%,General, ModdedPercent
	GuiControlGet,Select_UserTimeFormat
	IniWrite, %Select_UserTimeFormat%,%iniPath%,General, UserTimeFormat
	GuiControlGet,Select_DeafultSort
	IniWrite, %Select_DeafultSort%,%iniPath%,General, DeafultSort
	GuiControlGet,Select_DeafultSortDir
	IniWrite, %Select_DeafultSortDir%,%iniPath%,General, DeafultSortDir
	GuiControlGet,Select_StickyRows	
	IniWrite, %Select_StickyRows%,%iniPath%,General, StickyRows	
	GuiControlGet, Select_StickyW	
	IniWrite, %Select_StickyW%,%iniPath%,General, StickyW
reload
}
Set_Star1:
{
	GuiControlGet,Select_Star1
	IniWrite, %Select_Star1%,%iniPath%,General, Star1
	IniRead, Star1, %iniPath%, General, Star1
}
Set_Star2:
{
	GuiControlGet,Select_Star2
	IniWrite, %Select_Star2%,%iniPath%,General, Star2
	IniRead, Star2, %iniPath%, General, Star2
}
Set_Star3:
{
	GuiControlGet,Select_Star3
	IniWrite, %Select_Star3%,%iniPath%,General, Star3
	IniRead, Star3, %iniPath%, General, Star3
}
Set_Star4:
{
	GuiControlGet,Select_Star4
	IniWrite, %Select_Star4%,%iniPath%,General, Star4
	IniRead, Star4, %iniPath%, General, Star4
}
Set_DeafultSort:
{
	GuiControlGet,Select_DeafultSort
	IniWrite, %Select_DeafultSort%,%iniPath%,General, DeafultSort
	IniRead, DeafultSort, %iniPath%, General, DeafultSort
}
Set_DeafultSortDir:
{
	GuiControlGet,Select_DeafultSortDir
	IniWrite, %Select_DeafultSortDir%,%iniPath%,General, DeafultSortDir
	IniRead, DeafultSortDir, %iniPath%, General, DeafultSortDir
}
Set_UserTimeFormat:
{
	GuiControlGet,Select_UserTimeFormat
	IniWrite, %Select_UserTimeFormat%,%iniPath%,General, UserTimeFormat
	IniRead, UserTimeFormat, %iniPath%, General, UserTimeFormat
}
Set_backupsToKeep:
{
	GuiControlGet,U_backupsToKeep,, backupsToKeepSelect	
	IniWrite, %U_backupsToKeep%,%iniPath%,General, backupsToKeep
	IniRead, backupsToKeep, %iniPath%, General, backupsToKeep
}
SetHideScrollbars:
{
	GuiControlGet,HideScrollbarsSelect
	
	if (A_GuiEvent == "Normal"){
		IniWrite,%HideScrollbarsSelect%, %iniPath%, General, HideScrollbars
		IniRead,HideScrollbars,%iniPath%,General,HideScrollbars
		
	}
return
}
SetShowStatusBar:
{
	GuiControlGet,ShowStatusBarSelect
	
	if (A_GuiEvent == "Normal"){
		IniWrite,%ShowStatusBarSelect%, %iniPath%, General, ShowStatusBar
		IniRead,ShowStatusBar,%iniPath%,General,ShowStatusBar
		
	}
return
}
SetPreviewRows:
{
	GuiControlGet, U_PreviewRows,,PreviewRowsSelect	
	IniWrite, %U_PreviewRows%,%iniPath%,General, PreviewRows	
	IniRead, PreviewRows, %iniPath%, General, PreviewRows
	gosub DummyGUI1
	return
}
SetResultRows:
{
	GuiControlGet, U_ResultRows,,ResultRowsSelect	
	IniWrite, %U_ResultRows%,%iniPath%,General, ResultRows		
	IniRead, ResultRows, %iniPath%, General, ResultRows
	gosub DummyGUI1
	return 
}
SetQuickNoteRows:
{
	GuiControlGet, U_QuickNoteRows,,QuickNoteRowsSelect	
	IniWrite, %U_QuickNoteRows%,%iniPath%,General, QuickNoteRows	
	IniRead, QuickNoteRows, %iniPath%, General, QuickNoteRows
	Gui, 2:Destroy
	Gui, 5:Destroy
	isfake = 1
	BuildGUI2()
	isfake = 0
	WinMove,FlatNote - QuickNote, x25 y%fakeY%
	if WinExist("FlatNote - QuickNote")
		WinActivate ; use the window found above
	else
		WinActivate, FlatNotes
	return
}
SetQuickW:
{ 
	GuiControlGet, U_QuickNoteWidth,,QuickWSelect	
	IniWrite, %U_QuickNoteWidth%,%iniPath%,General, QuickNoteWidth	
	IniRead, QuickNoteWidth,%iniPath%, General,QuickNoteWidth
	Gui, 2:Destroy
	Gui, 5:Destroy
	isfake = 1
	BuildGUI2()
	isfake = 0
	if WinExist("FlatNote - QuickNote")
		WinActivate ; use the window found above
	else
		WinActivate, FlatNotes
	return
}
Set_StickyRows:
{
	GuiControlGet,Select_StickyRows	
	IniWrite, %Select_StickyRows%,%iniPath%,General, StickyRows	
	IniRead, StickyRows, %iniPath%, General, StickyRows
}
Set_StickyW:
{ 
	GuiControlGet, Select_StickyW	
	IniWrite, %Select_StickyW%,%iniPath%,General, StickyW	
	IniRead, StickyW,%iniPath%, General,StickyW
}
SetMainW:
{
	GuiControlGet, U_MainNoteWidth,,MainWSelect	
	IniWrite, %U_MainNoteWidth%,%iniPath%,General, WindowWidth	
	IniRead, LibW, %iniPath%, General, WindowWidth ,530
	SubW := LibW-10	
	libWAdjust := LibW+10
	ColAdjust := LibW-95
	NameColW := Round(ColAdjust*0.4)
	BodyColW := Round(ColAdjust*0.6)
	NameColAndBodyCOlW := NameColW+BodyColW
	gosub DummyGUI1
	return 
}
SetFontRendering:
{
	GuiControlGet, U_FontRendering,,FontRenderingSelect	
	IniWrite, %U_FontRendering%,%iniPath%,General, FontRendering		
	IniRead, FontRendering,%iniPath%, General,FontRendering
	gosub DummyGUI1
} 
SetSearchFontFamily:
{
	GuiControlGet, U_SearchFontFamily,,SearchFontFamilySelect
	IniWrite, %U_SearchFontFamily%,%iniPath%,General, SearchFontFamily	
	IniRead, SearchFontFamily, %iniPath%, General, SearchFontFamily
	gosub DummyGUI1
	return 
}
SetSearchFontSize:
{
	GuiControlGet, U_SearchSize,,SearchFontSizeSelect	
	IniWrite, %U_SearchSize%,%iniPath%,General, SearchFontSize
	IniRead, SearchFontSize, %iniPath%, General, SearchFontSize
	gosub DummyGUI1
	return 
}
SetResultFontFamily:
{
	GuiControlGet, U_ResultFontFamily,,ResultFontFamilySelect
	IniWrite, %U_ResultFontFamily%,%iniPath%,General, ResultFontFamily	
	IniRead, ResultFontFamily, %iniPath%, General, ResultFontFamily
	gosub DummyGUI1
	return 
}
SetResultFontSize:
{
	GuiControlGet, U_ResultSize,,ResultFontSizeSelect	
	IniWrite, %U_ResultSize%,%iniPath%,General, ResultFontSize
	IniRead, ResultFontSize, %iniPath%, General, ResultFontSize
	gosub DummyGUI1
	return 
}
SetPreviewFontFamily:
{
	GuiControlGet, U_PreviewFontFamily,,PreviewFontFamilySelect
	IniWrite, %U_PreviewFontFamily%,%iniPath%,General, PreviewFontFamily	
	IniRead, PreviewFontFamily, %iniPath%, General, PreviewFontFamily
	gosub DummyGUI1
	return
}
SetPreviewFontSize:
{
	GuiControlGet, U_PreviewSize,,PreviewFontSizeSelect	
	IniWrite, %U_PreviewSize%,%iniPath%,General, PreviewFontSize
	IniRead, PreviewFontSize, %iniPath%, General, PreviewFontSize
	gosub DummyGUI1
	return
}
SetStickyFontFamily:
{
	GuiControlGet, U_StickyFontFamily,,StickyFontFamilySelect
	IniWrite, %U_StickyFontFamily%,%iniPath%,General, StickyFontFamily	
	IniRead, StickyFontFamily, %iniPath%, General, StickyFontFamily
	return
}
SetStickyFontSize:
{
	GuiControlGet, U_StickySize,,StickyFontSizeSelect	
	IniWrite, %U_StickySize%,%iniPath%,General, StickyFontSize
	IniRead, StickyFontSize, %iniPath%, General, StickyFontSize
	return
}
SetFontFamily:
{ 
	GuiControlGet, U_FontFamily,,FontFamilySelect
	IniWrite, %U_FontFamily%,%iniPath%,General, FontFamily	
	IniRead, FontFamily, %iniPath%, General, FontFamily ,Verdana
	Gui, 2:Destroy
	Gui, 5:Destroy
	isfake = 1
	BuildGUI2()
	isfake = 0
	WinMove,FlatNote - QuickNote, x25 y%fakeY%
	if WinExist("FlatNote - QuickNote")
		WinActivate ; use the window found above
	else
		WinActivate, FlatNotes
	GuiControl,,QuickNoteName, Sample Text
	GuiControl,,QuickNoteBody, Sample Text
	return
}
SetFontSize:
{
	GuiControlGet, U_FontSize,,FontSizeSelect	
	IniWrite, %U_FontSize%,%iniPath%,General, FontSize
	IniRead, FontSize, %iniPath%, General, FontSize
	isfake = 1
	BuildGUI2()
	isfake = 0
	WinMove,FlatNote - QuickNote, x25 y%fakeY%
	if WinExist("FlatNote - QuickNote")
		WinActivate ; use the window found above
	else
		WinActivate, FlatNotes
	GuiControl,,QuickNoteName, Sample Text
	GuiControl,,QuickNoteBody, Sample Text
	return
}
Set_StarPercent:
{
	GuiControlGet, StarPercentSelect	
	IniWrite, %StarPercentSelect%,%iniPath%,General, StarPercent		
	IniRead, oNamePercent,%iniPath%, General,StarPercent
	StarPercent = 0.%oStarPercent%
	gosub DummyGUI1
	return
}
Set_NamePercent:
{
	GuiControlGet, NamePercentSelect	
	IniWrite, %NamePercentSelect%,%iniPath%,General, NamePercent		
	IniRead, oNamePercent,%iniPath%, General,NamePercent
	NamePercent = 0.%oNamePercent%
	gosub DummyGUI1
	return
}
Set_BodyPercent:
{
	GuiControlGet, BodyPercentSelect	
	IniWrite, %BodyPercentSelect%,%iniPath%,General, BodyPercent		
	IniRead, oBodyPercent,%iniPath%, General,BodyPercent
	BodyPercent = 0.%oBodyPercent%
	gosub DummyGUI1
	return
}
Set_AddedPercent:
{
	GuiControlGet, AddedPercentSelect	
	IniWrite, %AddedPercentSelect%,%iniPath%,General, AddedPercent		
	IniRead, oAddedPercent,%iniPath%, General,AddedPercent
	AddedPercent = 0.%oAddedPercent%
	gosub DummyGUI1
	return
}
Set_ModdedPercent:
{
	GuiControlGet, ModdedPercentSelect	
	IniWrite, %ModdedPercentSelect%,%iniPath%,General, ModdedPercent	
	IniRead, oModdedPercent,%iniPath%, General,ModdedPercent
	ModdedPercent = 0.%oModdedPercent%
	gosub DummyGUI1
	return
}

Label:
{
	If %A_GuiControl% in +,^,!,+^,+!,^!,+^!    ;If the hotkey contains only modifiers, return to wait for a key.
		return
	num := SubStr(A_GuiControl,3)              ;Get the index number of the hotkey control.
	If (HK%num% != "") {                       ;If the hotkey is not blank...
		Gui, Submit, NoHide
		If CB%num%                                ;  If the 'Win' box is checked, then add its modifier (#).
			HK%num% := "#" HK%num%
		If !RegExMatch(HK%num%,"[#!\^\+]")        ;  If the new hotkey has no modifiers, add the (~) modifier.
			HK%num% := "~" HK%num%                   ;    This prevents any key from being blocked.
		Loop,% #ctrls
			If (HK%num% = savedHK%A_Index%) {        ;  Check for duplicate hotkey...
				dup := A_Index
				Loop,6 {
					GuiControl,% "Disable" b:=!b, HK%dup%  ;    Flash the original hotkey to alert the user.
					Sleep,200
				}
				GuiControl,,HK%num%,% HK%num% :=""      ;    Delete the hotkey and clear the control.
				break
			}
	}
	If (savedHK%num% || HK%num%)
		setHK(num, savedHK%num%, HK%num%)
	return
}
tGuiEscape:
{
	Gui, t:Destroy
	return
}
6GuiEscape:
{
	Gui, 6:Destroy
	return
}
4GuiEscape:
{
	Gui, 4:Destroy
	return
}
3GuiEscape:
{
	Gui, 3:Destroy
	reload
	return
}
2GuiEscape:
{
	Gui, 2:Destroy 
	return
}
GuiEscape:
{
	;WinHide, ahk_id %g1ID%
	;g1Open=0
	return
}
GuiClose:
{
	WinHide, ahk_id %g1ID%
	g1Open=0
	return
}
Exit:
{
	ExitApp
}
CheckBackupLaterTimer:
{
 BackupNotes()
 return
}

SortNow:
{
LV_ModifyCol(C_SortCol,C_SortDir)
return
}
TitleSaveChange:
{
	GUI, t:Submit
	global LVSelectedROW
	NewTitle = %tEdit%
	FileSafeName := RegExReplace(NewTitle, "\*|\?|\\|\||/|""|:|<|>" , Replacement := "_")
	OldIniName := StrReplace(tOldFile,".txt",".ini")
	NewIniName = %FileSafeName%.ini
	NewTitleFileName = %FileSafeName%.txt
	FileRead, C_Body,%U_NotePath%%tOldFile%
	if (LVSelectedROW=""){
		msgbox Name Save Erro 1
		return
		}
	if (NewIniName=""){
		msgbox Name Save Error 2
		return
		}
	if (OldIniName=""){
		msgbox Name Save Error 3
		return
		}
	FileMove, %detailsPath%%OldIniName%, %detailsPath%%NewIniName%
	FileMove, %U_NotePath%%tOldFile%, %U_NotePath%%FileSafeName%.txt
	
	for Each, Note in MyNotesArray{
			If (Note.8 = tOldFile){
				MyNotesArray.RemoveAt(Each)
			}
		}
	
	;FileRecycle, %detailsPath%%C_ini%%tOldFile%
	SaveFile(NewTitle,FileSafeName,C_Body,1)
	ListTitleToChange = 1
	ControlFocus , Edit1, FlatNotes - Library
	return
}
Edit3SaveTimer:
{
	global LVSelectedROW
	if (LVSelectedROW="")
		LVSelectedROW=1
	LV_GetText(RowText, LVSelectedROW,2)
	FileSafeName := RegExReplace(RowText, "\*|\?|\\|\||/|""|:|<|>" , Replacement := "_")
	GuiControlGet, PreviewBox
	SaveFile(RowText,FileSafeName,PreviewBox,1)
	iniRead,OldAdd,%detailsPath%%FileSafeName%.ini,INFO,Add
	FileReadLine, NewBodyText, %U_NotePath%%FileSafeName%.txt,1
	LV_Modify(LVSelectedROW,,, RowText, NewBodyText)
	savetimerrunning = 0
	unsaveddataEdit3 = 0
	ControlSend, Edit1,{left},FlatNotes - Library
	return
}
PreviewBox:
{
	unsaveddataEdit3 = 1
if (savetimerrunning = 0) {
	savetimerrunning = 1
	settimer, Edit3SaveTimer, -10000
	}
return
}
uiMove:
{
PostMessage, 0xA1, 2,,, A 
Return
}
Xsticky:
{
	Gui +LastFound 
	gui destroy
	WinClose
 return
}
Usticky:
{
	Gui +LastFound 
	WinMove, , , ,  , , 22
	return
}
Hsticky:
{
	Gui +LastFound 
	WinMove, , , ,  , , %StickyMaxH%
	return
}