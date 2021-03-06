;-------------------------------------------------
;Inialize FlateNotes AHK v1
;-------------------------------------------------
#SingleInstance Force
FileEncoding ,UTF-8
CoordMode, mouse, Screen
DetectHiddenWindows, On

;-------------------------------------------------
;Setup Tray Menu
;-------------------------------------------------
Menu, Tray, NoStandard
Menu, Tray, Add 
Menu, Tray, Add, Library
Menu, Tray, Add, Note Template Maker,NoteTemplateMaker
Menu, Tray, Add, About
Menu, Tray, Add, Options
Menu, Tray, Add, Exit
Menu, Tray, Default, Library


;-------------------------------------------------
;Set up script global variables
;-------------------------------------------------
;hwnd
global HSterm ; Lib Searchbox 
global HQNB ; QuickNoteBox
global HLV ;Lib listview
global HPB ;
global HSF ;
global HQNUSL1
global HQNUSl2
global HQNUSl3
global HSEB
global HSFB2
global HstarBox1
global HstarBox2
global HstarBox3
global HstarBox4
global HTSLB ;Template Selection List Box
global HTSGUI ;Template Select GUI
global HTRowsOver ; Total Rows edit box for Template maker

global TRowsOver
global OpenInQuickNote
global NewTemplateRows
global NewExternalEditor
global CheckForOldNote 
global OldStarData
global FileList = ""
global FileSafeClipBoard
global FileSafeName
global LV
global LV@sel_col
global tNeedsSubmit
global sNeedsSubmit
global MyNotesArray := {}
global OldNoteData
global QuickNoteBody
global QuickNoteName
global U_MBG
global U_MFC
global U_SBG
global U_SFC
global U_MSFC
global U_FBCA
global UseCapslock
global U_Capslock
global fake
global fake2
global iniPath
global themePath
global sendCtrlC
global SortBody
global SortStar
global SortName
global SortAdded
global SortModded
global NextSortAdded
global NextSortBody
global NextSortName
global NextSortStar
global rowSelectColor
global rowSelectTextColor
global QuickNoteWidth
global LB1
global LB2
global isfake
global PB_Name
global PB_Add
global PB_Mod
global StarPercent
global NamePercent
global BodyPercent
global AddedPercent
global ModdedPercent
global oStarPercent
global oNamePercent
global oBodyPercent
global oAddedPercent
global oModdedPercent
global ShowStatusBar
global StatusBarM
global StatusBarA
global Fake
global SaveMod
global TitelBar
global StatusBarCount
global LastRowSelected
global StatusBar
global C_SortCol
global C_SortDir
global RawDeafultSort
global DeafultSort
global DeafultSortDir
global UserTimeFormat
global Star1
global Star2
global Star3
global Star4
global Selected_NoteTemplate
global TemplateLVSelectedROW
global OOKStars
global UniqueStarList
global UniqueStarList2
global tOldFile
global LastBackupTime
global ListTitleToChange
global ListStarToChange
global NewTitle
global NewStar
global NewTitleFileName
global TitleBar
global UsedStars
global QuickStar
global SearchDates
global ztitleEncoded
global RapidStar
global RapidStarNow
global LVSelectedROW
global StarOldFile
global TitleOldFile
global ShowStarHelper
global CtrlEnter
global templatePath
;Pre-set globals
global savedHK1
global savedHK2
global savedHK3
global savedHK4
global savedHK5
global savedHK6
global savedSK1
global savedSK2
global savedSK3
global savedSK4
global LibW
global PreviewRows
global ResultRows
global QuickNoteRows
global FontFamily 
global FontSize
global ResultFontFamily
global ResultFontSize
global PreviewFontFamily
global PreviewFontSize
global StickyFontFamily
global StickyFontSize
global SearchFontFamily
global SearchFontSize
global FontRendering
global detailsPath
global HideScrollbars
global backupsToKeep
global g1Open
global g1ID
global isStarting
global TotalNotes
global unsaveddataEdit3
global StickyW ;250
global StickyRows ;8
;Var with starting values
global istitle = yes
global savetimerrunning = 0
global RapidNTAppend = 0
global TitleBarFontSize = 10
if (A_ScreenDPI > 120)
	TitleBarFontSize = 8

;tmp maybe
global TemplateSymbol
global ColBase = ,6,7,8,9
global ColOrder = 1,2,3,4,5
global SearchWholeNote



FileCreateDir, NoteDetails
detailsPath := A_WorkingDir "\NoteDetails\"
iniPath = %A_WorkingDir%\settings.ini
systemINI = %A_WorkingDir%\sys\system.ini
themePath = %A_WorkingDir%\sys\Themes
templatePath = %A_WorkingDir%\NoteTemplates\
IniRead, U_NotePath, %iniPath%, General, MyNotePath,%A_WorkingDir%\MyNotes\

if InStr(FileExist(U_NotePath), "D") {
	if (U_NotePath = "") {
	U_NotePath = %A_WorkingDir%\MyNotes\
	FileCreateDir, MyNotes
	}
	if (U_NotePath ="\"){
	U_NotePath = %A_WorkingDir%\MyNotes\
	FileCreateDir, MyNotes
	}
}else {
		msgbox Notes folder: %U_NotePath% could not be found. %A_WorkingDir%\MyNotes\ will be used instead.
		FileCreateDir, MyNotes
		IniWrite, %A_WorkingDir%\MyNotes\, %iniPath%, General, MyNotePath
		U_NotePath = %A_WorkingDir%\MyNotes\
		}
global U_NotePath
;-------------------------------------------------
;Write settings.ini from system.ini
;-------------------------------------------------
IniRead, isFristRun, %iniPath%, General, isFristRun,1
if (isFristRun = "1") {
	IniWrite, 0, %iniPath%, General, isFristRun
	IniWrite, 5,%iniPath%, General,StarPercent
	IniWrite, 30,%iniPath%, General,NamePercent
	IniWrite, 45,%iniPath%, General,BodyPercent
	IniWrite, 20,%iniPath%, General,AddedPercent
	IniWrite, 0,%iniPath%, General,ModdedPercent
	IniWrite, yy/MM/dd,%iniPath%, General,UserTimeFormat
	IniWrite, 0, %iniPath%, General, isFristRun
	IniWrite, 0, %iniPath%, General, isFristRun
	IniWrite, 0, %iniPath%, General, isFristRun
	iniread, Star_1,%systemINI%,Start, Star1
	IniWrite, %Star_1%, %iniPath%, General, Star1
	iniread, Star_2,%systemINI%,Start,Star2
	IniWrite, %Star_2%, %iniPath%, General, Star2
	iniread, Star_3,%systemINI%,Start, Star3
	IniWrite, %Star_3%, %iniPath%, General, Star3
	iniread, Star_4,%systemINI%,Start,Star4
	IniWrite, %Star_4%, %iniPath%, General, Star4
	IniWrite, 1, %iniPath%, General, OpenInQuickNote
	IniRead, OpenInQuickNote, %iniPath%, General, OpenInQuickNote,1
}
	IniRead, Star1, %iniPath%, General, Star1
	IniRead, Star2, %iniPath%, General, Star2
	IniRead, Star3, %iniPath%, General, Star3
	IniRead, Star4, %iniPath%, General, Star4
	iniread, TemplateAboveSymbol,%systemINI%,SYS,TemplateAboveSymbol,+
	iniread, TemplateBelowSymbol,%systemINI%,SYS,TemplateBelowSymbol,-
	iniread, TemplateSymbol,%systemINI%,SYS,TemplateSymbol,+
;-------------------------------------------------
; Read from theme .ini 
;-------------------------------------------------
IniRead,LastBackupTime,%iniPath%,General,LastBackupTime,10000000000
IniRead, StartingTheme, %iniPath%, Theme, Name, Black
StartingTheme = %A_WorkingDir%\sys\Themes\%StartingTheme%.ini


IniRead, U_Theme, %StartingTheme%, Theme, UserSetting , Black
IniRead, U_MBG, %StartingTheme%, Colors, MainBackgroundColor , 000000 ;Everything else
IniRead, U_SBG, %StartingTheme%, Colors, SubBackgroundColor , ffffff ;Details background
IniRead, U_MFC, %StartingTheme%, Colors, MainFontColor , ffffff ;Result and preview
IniRead, U_SFC, %StartingTheme%, Colors, SubFontColor , 000000 ; Details font
IniRead, U_MSFC, %StartingTheme%, Colors, MainSortFontColor , 777700 ;Main Sort Font
IniRead, U_FBCA, %StartingTheme%, Colors, SearchBoxFontColor , ffffff ;search box font
IniRead, rowSelectColor, %StartingTheme%, Colors, RowSelectColor , 0x444444 ;Row Select color
IniRead, rowSelectTextColor, %StartingTheme%, Colors, RowSelectTextColor , 0xffffff ;Row Select Text color

;-------------------------------------------------
; Read and from settings.ini
;-------------------------------------------------
IniRead, savedHK1, %iniPath%, Hotkeys, 1,#o
IniRead, savedHK2, %iniPath%, Hotkeys, 2,#n
IniRead, savedHK3, %iniPath%, Hotkeys, 3,#z
IniRead, savedHK4, %iniPath%, Hotkeys, 4,#+z
IniRead, savedHK5, %iniPath%, Hotkeys, 5,#a
IniRead, savedHK6, %iniPath%, Hotkeys, 6,+#a
IniRead, savedSK1, %iniPath%, Shortcuts, 1,!s
IniRead, savedSK2, %iniPath%, Shortcuts, 2,!r
IniRead, savedSK3, %iniPath%, Shortcuts, 3,!e
IniRead, savedSK4, %iniPath%, Shortcuts, 4,!t


IniRead, NewTemplateRows,%iniPath%, General, NewTemplateRows, 8
if (NewTemplateRows>30)
	NewTemplateRows = 30
IniRead, ExternalEditor, %iniPath%, General, ExternalEditor,NONE
IniRead, OpenInQuickNote, %iniPath%, General, OpenInQuickNote,1
IniRead, CtrlEnter,%iniPath%,General,CtrlEnter,0
IniRead, ShowStarHelper,%iniPath%,General,ShowStarHelper,0

IniRead, RapidStar,%iniPath%,General,RapidStar,1

Iniread, SearchWholeNote,%iniPath%,General,SearchWholeNote,1

Iniread, UniqueStarList,%iniPath%,General,UniqueStarList,1|2|3|4|5|6|7|8|9|0
Iniread, UniqueStarList2,%iniPath%,General,UniqueStarList2,%a_space%
Iniread, USSLR,%iniPath%,General,USSLR,10

Iniread, SearchDates,%iniPath%,General,SearchDates,0

Iniread, ShowMainWindowOnStartUp,%iniPath%, General,ShowMainWindowOnStartUp,1
IniRead, QuickNoteWidth,%iniPath%, General,QuickNoteWidth,350
IniRead, ShowStatusBar,%iniPath%, General,ShowStatusBar,1
IniRead, FontRendering,%iniPath%, General,FontRendering,5
IniRead, FontFamily, %iniPath%, General, FontFamily ,Verdana
IniRead, FontSize, %iniPath%, General, FontSize ,10

IniRead, SearchFontFamily, %iniPath%, General, SearchFontFamily ,Verdana
IniRead, SearchFontSize, %iniPath%, General, SearchFontSize ,10 

IniRead, ResultFontFamily, %iniPath%, General, ResultFontFamily ,Verdana
IniRead, ResultFontSize, %iniPath%, General, ResultFontSize ,10

IniRead, PreviewFontFamily, %iniPath%, General, PreviewFontFamily ,Verdana
IniRead, PreviewFontSize, %iniPath%, General, PreviewFontSize ,10

IniRead, StickyFontFamily, %iniPath%, General, StickyFontFamily ,Verdana
IniRead, StickyFontSize, %iniPath%, General, StickyFontSize ,10

IniRead, PreviewRows, %iniPath%, General, PreviewRows ,8
IniRead, ResultRows, %iniPath%, General, ResultRows ,8
IniRead, QuickNoteRows, %iniPath%, General, QuickNoteRows ,7
IniRead, StickyRows, %iniPath%, General, StickyRows ,8

IniRead, StickyW, %iniPath%, General, StickyW ,250
IniRead, LibW, %iniPath%, General, WindowWidth ,530
IniRead, U_Capslock, %iniPath%, General, UseCapsLock , 1
IniRead, sendCtrlC, %iniPath%, General, sendCtrlC, 1


IniRead, oStarPercent,%iniPath%, General,StarPercent,5
IniRead, oNamePercent,%iniPath%, General,NamePercent,30
IniRead, oBodyPercent,%iniPath%, General,BodyPercent,45
IniRead, oAddedPercent,%iniPath%, General,AddedPercent,20
IniRead, oModdedPercent,%iniPath%, General,ModdedPercent,0

if oStarPercent between 0 and 9
	oStarPercent = 0%oStarPercent%
if oNamePercent between 0 and 9
	oNamePercent = 0%oNamePercent%
if oBodyPercent between 0 and 9
	oBodyPercent = 0%oBodyPercent%
if oModdedPercent between 0 and 9
	oModdedPercent = 0%oModdedPercent%

StarPercent = 0.%oStarPercent%
NamePercent = 0.%oNamePercent%
BodyPercent = 0.%oBodyPercent%
AddedPercent = 0.%oAddedPercent%
ModdedPercent = 0.%oModdedPercent%

IniRead, HideScrollbars,%iniPath%,General,HideScrollbars,1
IniRead, backupsToKeep,%iniPath%,General,backupsToKeep,3

IniRead, DeafultSort,%iniPath%,General,DeafultSort,4
IniRead, DeafultSortDir,%iniPath%,General,DeafultSortDir,2

;Sort value for select options
RawDeafultSort := DeafultSort

StartSort = %DeafultSort%
if (DeafultSortDir = 2)
	StartSort := DeafultSort*10
if StartSort between 1 and 9
	C_SortDir = Sort
if StartSort between 10 and 99
	C_SortDir = SortDesc
if (DeafultSort=4)
	DeafultSort=6
if (DeafultSort=5) 
	DeafultSort=7

C_SortCol = %DeafultSort%

Iniread, UserTimeFormat,%iniPath%,General,UserTimeFormat,yy/MM/dd

;-------------------------------------------------
;Set Globals that need values from the ini
;-------------------------------------------------
global HelpIconx := LibW-15
global SearchW := LibW-50
global StickyTW := StickyW-80
global StickyMaxH
global VSBW
SysGet, VSBW, 2 ;Width of Vscroll Bar
global libWColAdjust :=LibW ;-(VSBW+1) ;Prevent H-scroll bar.
global libWAdjust := LibW+3
if (HideScrollbars = 1)
	libWAdjust := LibW+3+VSBW

;global ColAdjust := LibW-95
global StarColW := Round(libWColAdjust*StarPercent)
global NameColW := Round(libWColAdjust*NamePercent)
global BodyColW := Round(libWColAdjust*BodyPercent)
global AddColW := Round(libWColAdjust*AddedPercent)
global ModColW := Round(libWColAdjust*ModdedPercent)
;-------------------------------------------------
;Acitvate User Hotkeys if any & make INI for new files
;-------------------------------------------------
isStarting = 1
Progress, 0, Setting Hotkeys
SetUserHotKeys()
Progress, 5,  Adding new notes
MakeAnyMissingINI()
Progress, 10, Removing data for deleted notes
RemoveINIsOfMissingTXT()
Progress, 15, Backing up your notes
BackupNotes()
Progress, 20, Building note index
BuildGUI1()
gosub MakeOOKStarList
gosub SortNow
LVM_FIRST               := 0x1000
LVM_REDRAWITEMS         := 21
LVM_SETCOLUMNORDERARRAY := 58
LVM_GETCOLUMNORDERARRAY := 59
Progress, 100, Done!
Progress, Off
isStarting = 0
if (ShowMainWindowOnStartUp = 1 and ColOrder = "1,2,3,4,5") {
	WinShow, ahk_id %g1ID%
	g1Open=1
}
if (ShowMainWindowOnStartUp = 0 and ColOrder = "1,2,3,4,5") {
	WinHide, ahk_id %g1ID%
}
if (ShowMainWindowOnStartUp = 1 and ColOrder != "1,2,3,4,5"){
	LV_Set_Column_Order(9,ColOrder ColBase)
	WinHide, ahk_id %g1ID%
	WinShow, ahk_id %g1ID%
	g1Open=1
}
if (ShowMainWindowOnStartUp = 0 and ColOrder != "1,2,3,4,5"){
	LV_Set_Column_Order(9,ColOrder ColBase)
	WinHide, ahk_id %g1ID%
}

;-------------------------------------------------
;-------------------------------------------------
;goto Options
;BuildGUI2()
;-------------------------------------------------
;Use Capslock if users has not changed the main window hotkey
;-------------------------------------------------
!w::
{
return
}
vk14::
{
if (U_Capslock = "0"){
	vk14::vk14
	return
}
if (g1Open=1) {
	WinHide, FlatNotes - Library
	g1Open=0
	GUI, star:destroy
	GUI, t:destroy
	return
}
if (g1Open=0) {
	MouseGetPos, xPos, yPos	
	xPos /= 1.5
	yPos /= 1.5
	GuiControl,,%HSterm%, 
	WinMove, ahk_id %g1ID%, , %xPos%, %yPos%
	WinShow, ahk_id %g1ID%
	WinRestore, ahk_id %g1ID%
	WinActivate, ahk_id %g1ID%
	g1Open=1
	ControlFocus,Edit1,FlatNotes - Library
	sendinput {left}{right}
	gosub search
	gosub SortNow
	return
}
return
}
;-------------------------------------------------
;playground 
;-------------------------------------------------


;-------------------------------------------------
;Include external ahk  
;-------------------------------------------------
#Include inc\functions.ahk
#Include inc\StickyGui.ahk
#Include inc\shortcuts.ahk
#Include inc\Class_LV_Colors.ahk
;-!- Return after fucntions so lables don't get exacuted
return
#Include inc\DummyGui.ahk
#Include inc\lables.ahk
#Include inc\tmLables.ahk
return


