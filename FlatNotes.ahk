;-------------------------------------------------
;Inialize FlatBase AHK v1
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
Menu, Tray, Click, 1
Menu, Tray, Add, Note Template Maker,NoteTemplateMaker
Menu, Tray, Add, About
Menu, Tray, Add, Options
Menu, Tray, Add, Exit
Menu, Tray, Default, Library
;-------------------------------------------------
;Set up script global variables
;-------------------------------------------------
global TemplateDisplayMode

global TreeLibW = 500
global TreeLibH = 300
global TreeBorder = 2
Global ScrollbarW = 0 

global ColEditName
global GetFile
global ColList = ["Star", "Title", "Body", "Added", "Modified", "RawAdded", "RawModded", "FileName", "RawStar", "Tags","Cat","Parent", "Checked", "Marked", "Extra"]


global TreeCol1W := 125 + ScrollbarW
global TreeCol1WSBH := TreeCol1W - ScrollbarW
global TreeCol1X := 0 - ScrollbarW
global TreeCol1H := TreeLibH
global TreeCol2W := TreeLibW - TreeCol1W - TreeBorder + ScrollbarW + ScrollbarW
global TreeCol2X := TreeCol1W + TreeBorder - ScrollbarW
global TreeNameH = 20
global TreePreviewH := TreeLibH - TreeNameH - TreeBorder
global TreePreviewY := TreeNameH + TreeBorder + TreeBorder + TreeBorder + TreeBorder






;hwnd
global HSterm ; Lib Searchbox 
global HQNB ; QuickNoteBox
global HLV ;Lib listview
global HPB ;
global HSF ; SearchFilter edit ID
global HCF ; CatFilter edit ID
global HNP ; Note Parent edit ID
global HTV ; Tree:gui Treeview ID
global HTVN ; TV Note Name ID
global HTVB ; Tree:gui Edit Preview / Body ID
global HTF ; Listview tag Filter search box
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
global TVBuilt
global TVNoteName
global TVNoteBody
global TVNoteTags
global TVNoteCat
global TVNoteStar
global TVNoteTree
global StaticX
global StaticY


global TagBox
global CatBox
global CatFilter
global TagsFilter
global LastCatFilter

global CatBoxContents
global TagsFilterContents
global NoteParent

global ceEdit
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
global QuickNoteTags
global QuickNoteParent
global QuickNoteCat
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
global SortTags
global SortCat
global SortParent
global SortScript
global SortClip
global SortBookmark
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
global TagsPercent
global ParentPercent
global CatPercent
global CheckedPercent
global MarkedPercent
global ExtraPercent
global ScriptPercent
global ClipPercent
global BookmarkPercent
global oStarPercent
global oNamePercent
global oBodyPercent
global oAddedPercent
global oModdedPercent
global oTagsPercent
global oCatPercent
global oParentPercent
global oCheckedPercent
global oMarkedPercent
global oExtraPercent
global oScriptPercent
global oClipPercent
global oBookmarkPercent
global ShowStatusBar
global StatusBarM
global StatusBarA
global Fake
global SaveMod
global TitelBar
global StatusBarCount
global LastRowSelected, 1
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
global ShowCatFilterBoxHelper
global ShowTagFilterBoxHelper
global ShowTagEditBoxHelper
global ShowParentEditBoxHelper
global ShowQuickTagEditBoxHelper
global ShowQuickParentEditBoxHelper
global ShowQuickCatEditBoxHelper
global ShowPreviewEditBoxHelper
global ShowExtraInputInTemplatesHelper
global templatePath
;Pre-set globals
global savedHK1
global savedHK2
global savedHK3
global savedHK4
global savedHK5
global savedHK6
global savedHK7
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
global scriptPath
global bookmarkPath
global clipPath
global HideScrollbars
global backupsToKeep
global g1Open
global g1ID
global isStarting
global TotalNotes
global unsaveddataEdit3
global StickyW ;250
global StickyRows ;8
global UseStarsAsParents
;Var with starting values
global istitle = yes
global savetimerrunning = 0
global RapidNTAppend = 0
global TitleBarFontSize = 10
if (A_ScreenDPI > 120)
	TitleBarFontSize = 8
;tmp maybe
global RC16
global RC17
global RC18
global TypeBUpdate,1
global ScriptFilterActive
global ClipFilterActive
global BookmarkFilterActive
global SelectedRows
global TemplateSymbol
global RunSymbol
global WebSymbol
global WorldSymbol
global LinkSymbol
global TreeSymbol
global DiskSymbol
global SaveSymbol
global LoadSymbol
global TypeAIcon
global TypeBIcon
global RunIcon
global StickyIcon
global MakeSticky
global BookmarkSymbol
global StoreBookmark
global StoreRun
global AddTemplateText
global ChangeRunType
global RestoreClipboard
global StoreClipboard
global ColBase = ,6,7,8,9
global ColOrder = 1,2,3,4,5
global SearchWholeNote
global TreeFristRun = 1
global SearchClip = 0
global TVReDraw
global LoopCheck
global UseCheckBoxesTrue
global UseCheckBoxes = false
if (UseCheckBoxes == true)
	UseCheckBoxesTrue := "Checked"

;Reuseable Data Holders
global CurrentCol = ["C_Star","C_Name","C_File","C_Add","C_Mod","C_RawAdd","C_RawMod","C_FileName","C_RawStar","C_Tags","C_Cat","C_Parent","C_Marked","C_Extra"]


global C_File
global C_Name
global C_SafeName
global C_Add
global C_Mod
global C_Star
global C_Tags
global C_Cat
global C_Parent
global NoteNameToEdit

LVSelectedROW = 1

FileCreateDir, NoteDetails
detailsPath := A_WorkingDir "\NoteDetails\"
clipPath := A_WorkingDir "\MyClipboards\"
bookmarkPath := A_WorkingDir "\MyBookmarks\"
scriptpath := A_WorkingDir "\MyScripts\"
iniPath = %A_WorkingDir%\settings.ini
systemINI = %A_WorkingDir%\sys\system.ini
themePath = %A_WorkingDir%\sys\Themes
templatePath = %A_WorkingDir%\NoteTemplates\
IniRead, U_NotePath, %iniPath%, General, MyNotePath,%A_WorkingDir%\MyNotes\

;set tray icon
if A_IsCompiled
	Menu, Tray, Icon, %A_ScriptFullPath%, -159
else 
	Menu, Tray, Icon, %A_WorkingDir%\- Assets\FlatNotes.ico

; check for note path, then reset to default and warn user if the path can't be found.
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
	IniWrite, 0,%iniPath%, General,TagsPercent
	IniWrite, 0,%iniPath%, General,CatPercent
	IniWrite, 0,%iniPath%, General,ParentPercent
	IniWrite, 0,%iniPath%, General,CheckedPercent
	IniWrite, 0,%iniPath%, General,MarkedPercent
	IniWrite, 0,%iniPath%, General,ExtraPercent
	IniWrite, 0,%iniPath%, General,ScriptPercent
	IniWrite, 0,%iniPath%, General,ClipPercent
	IniWrite, 0,%iniPath%, General,BookmarkPercent

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
	iniread, TreeSymbol,%systemINI%,SYS,TreeSymbol,🌳
	iniread, SaveSymbol,%systemINI%,SYS,SaveSymbol,📦
	iniread, LoadSymbol,%systemINI%,SYS,LoadSymbol,📋
	iniread, DiskSymbol,%systemINI%,SYS,DiskSymbol,💾
	iniread, WorldSymbol,%systemINI%,SYS,WorldSymbol🌐
	iniread, LinkSymbol,%systemINI%,SYS,LinkSymbol,🔗
	iniread, WebSymbol,%systemINI%,SYS,WebSymbol,🕸️
	iniread, BookmarkSymbol,%systemINI%,SYS,BookmarkSymbol,🔖
	iniread, RunIcon, %systemINI%,SYS,RunIcon,👟
	iniread, TypeAIcon, %systemINI%,SYS,TypeAIcon,🅰️
	iniread, TypeBIcon, %systemINI%,SYS,TypeBIcon,🅱️
	iniread, StickyIcon, %systemINI%,SYS,StickyIcon,📌
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
IniRead, CatBoxContents, %iniPath%,General,CatBoxContents,White|Black|Calico|Tabby

IniRead, savedHK1, %iniPath%, Hotkeys, 1,#o
IniRead, savedHK2, %iniPath%, Hotkeys, 2,#n
IniRead, savedHK3, %iniPath%, Hotkeys, 2,#m
IniRead, savedHK4, %iniPath%, Hotkeys, 3,#z
IniRead, savedHK5, %iniPath%, Hotkeys, 4,#+z
IniRead, savedHK6, %iniPath%, Hotkeys, 5,#a
IniRead, savedHK7, %iniPath%, Hotkeys, 6,+#a
IniRead, savedSK1, %iniPath%, Shortcuts, 1,!s
IniRead, savedSK2, %iniPath%, Shortcuts, 2,!r
IniRead, savedSK3, %iniPath%, Shortcuts, 3,!e
IniRead, savedSK4, %iniPath%, Shortcuts, 4,!t


IniRead, NewTemplateRows,%iniPath%, General, NewTemplateRows, 8
if (NewTemplateRows>30)
	NewTemplateRows = 30
IniRead, ExternalEditor, %iniPath%, General, ExternalEditor,NONE
IniRead, OpenInQuickNote, %iniPath%, General, OpenInQuickNote,1
IniRead, ShowStarHelper,%iniPath%,General,ShowStarHelper,1
IniRead, ShowCatFilterBoxHelper,%iniPath%,General,ShowCatFilterBoxHelper,1
IniRead, ShowTagFilterBoxHelper,%iniPath%,General,ShowTagFilterBoxHelper,1
IniRead, ShowTagEditBoxHelper,%iniPath%,General,ShowTagEditBoxHelper,1
IniRead, ShowParentEditBoxHelper,%iniPath%,General,ShowParentEditBoxHelper,1
IniRead, ShowPreviewEditBoxHelper,%iniPath%,General,ShowPreviewEditBoxHelper,1

IniRead, ShowQuickCatEditBoxHelper,%iniPath%,General,ShowQuickCatEditBoxHelper,1
IniRead, ShowQuickParentEditBoxHelper,%iniPath%,General,ShowQuickParentEditBoxHelper,1
IniRead, ShowQuickTagEditBoxHelper,%iniPath%,General,ShowQuickTagEditBoxHelper,1

IniRead, ExtraInputInTemplatesHelper,%iniPath%,General,ExtraInputInTemplatesHelper,1

IniRead, RapidStar,%iniPath%,General,RapidStar,1
IniRead, UseStarsAsParents,%iniPath%,General,UseStarsAsParents,0

Iniread, SearchWholeNote,%iniPath%,General,SearchWholeNote,1

Iniread, UniqueStarList,%iniPath%,General,UniqueStarList,1|2|3|4|5|6|7|8|9|0
Iniread, UniqueStarList2,%iniPath%,General,UniqueStarList2,%a_space%
Iniread, USSLR,%iniPath%,General,USSLR,10
Iniread, StaticX,%iniPath%,General,StaticX,
Iniread, StaticY,%iniPath%,General,StaticY,

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
IniRead, oTagsPercent,%iniPath%, General,TagsPercent,0
IniRead, oCatPercent,%iniPath%, General,CatPercent,0
IniRead, oParentPercent,%iniPath%, General,ParentPercent,0
IniRead, oCheckedPercent,%iniPath%, General,CheckedPercent,0
IniRead, oMarkedPercent,%iniPath%, General,MarkedPercent,0
IniRead, oExtraPercent,%iniPath%, General,ExtraPercent,0
IniRead, oScriptPercent,%iniPath%, General,ScriptPercent,0
IniRead, oClipPercent,%iniPath%, General,ClipPercent,0
IniRead, oBookmarkPercent,%iniPath%, General,BookmarkPercent,0

if oStarPercent between 0 and 9
	oStarPercent = 0%oStarPercent%
if oNamePercent between 0 and 9
	oNamePercent = 0%oNamePercent%
if oBodyPercent between 0 and 9
	oBodyPercent = 0%oBodyPercent%
if oModdedPercent between 0 and 9
	oModdedPercent = 0%oModdedPercent%
if oTagsPercent between 0 and 9
	oTagsPercent = 0%oTagsPercent%
if oCatPercent between 0 and 9
	oCatPercent = 0%oCatPercent%
if oParentPercent between 0 and 9
	oParentPercent = 0%oParentPercent%
if oCheckedPercent between 0 and 9
	oCheckedPercent = 0%oCheckedPercent%
if oMarkedPercent between 0 and 9
	oMarkedPercent = 0%oMarkedPercent%
if oExtraPercent between 0 and 9
	oExtraPercent = 0%oExtraPercent%
if oScriptPercent between 0 and 9
	oScriptPercent = 0%oScriptPercent%
if oClipPercent between 0 and 9
	oClipPercent = 0%oClipPercent%
if oBookMarkPercent between 0 and 9
	oBookMarkPercent = 0%oBookmarkPercent%
	
StarPercent = 0.%oStarPercent%
NamePercent = 0.%oNamePercent%
BodyPercent = 0.%oBodyPercent%
AddedPercent = 0.%oAddedPercent%
ModdedPercent = 0.%oModdedPercent%
TagsPercent = 0.%oTagsPercent%
CatPercent = 0.%oCatPercent%
ParentPercent = 0.%oParentPercent%
CheckedPercent = 0.%oCheckedPercent%
MarkedPercent = 0.%oMarkedrcent%
ExtraPercent = 0.%oExtraPercent%
ScriptPercent = 0.%oScriptPercent%
ClipPercent = 0.%oClipPercent%
BookmarkPercent = 0.%oBookmarkPercent%



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
global HelpIconx := LibW-18
global SearchW := LibW * 0.75 - 50
global CatX := SearchW
global CatW := LibW * 0.1
global TagsFilterX := CatW + 2
global TagsFilterW := LibW * 0.15

global TagLibW := Libw *0.8
global ParentLibW := Libw *0.2 - 2
global ParenetLibX := TagLibW + 1

if (ShowParentEditBoxHelper == 0)
	TagLibW := Libw
if (ShowTagEditBoxHelper == 0) {
	ParentLibW := Libw	
	ParenetLibX := 0
	}
if (ShowTagFilterBoxHelper == 0)
	CatX := CatX + TagsFilterW
if (ShowCatFilterBoxHelper == 0)
	TagsFilterX := CatX + TagsFilterW


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
global TagColW := Round(libWColAdjust*TagsPercent)
global CatColW := Round(libWColAdjust*CatPercent)
global ParentColW := Round(libWColAdjust*ParentPercent)
global CheckedColW := Round(libWColAdjust*CheckedPercent)
global MarkedColW := Round(libWColAdjust*MarkedPercent)
global ExtraColW := Round(libWColAdjust*ExtraPercent)
global ScriptColW := Round(libWColAdjust*ScriptPercent)
global ClipColW := Round(libWColAdjust*ClipPercent)
global BookmarkColW := Round(libWColAdjust*BookmarkPercent)

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

;------------------------------------------------- Dev Startup options
;-------------------------------------------------
;goto Options
;BuildGUI2()
;gosub BuildTreeUI
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
SelectedRows :=
if (g1Open=1) {
	WinHide, FlatNotes - Library
	g1Open=0 
	GUI, star:destroy
	GUI, t:destroy
	gosub Edit3SaveTimer
	return
}
if (g1Open=0) {
	if(SearchClip == 1){
	RestoreClip := clipboardall
	clipboard =
	send {Ctrl Down}{c}{Ctrl up}
	if (clipboard){
		AutoSearch = true
		AutoSearchTerm := clipboard
		clipboard := RestoreClip 
	}else {
		GuiControlGet, LastSearch,,%HSterm%
		AutoSearchTerm := LastSearch
		clipboard := RestoreClip
	}
	}else{
	GuiControlGet, LastSearch,,%HSterm%
	AutoSearchTerm := LastSearch
	}
	SearchClip = 0
	MouseGetPos, xPos, yPos	
	xPos /= 1.5
	yPos /= 1.5
	
	if(StaticX != "" or StatricY != ""){
	xPos := StaticX
	yPos := StaticY
	}
	GuiControl,,%HSterm%,
	GuiControl,,%HSterm%,%AutoSearchTerm%
	WinMove, ahk_id %g1ID%, , %xPos%, %yPos%
	WinShow, ahk_id %g1ID%
	WinRestore, ahk_id %g1ID%
	WinActivate, ahk_id %g1ID%
	g1Open=1	
	ControlFocus,Edit1,FlatNotes - Library
	;sendinput {left}{right}
	sendinput {home}{shift down}{end}{shift up}
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
#Include inc\Class_CtlColors.ahk
#Include inc\Class_OD_Colors.ahk
#include inc\Object sort.ahk
#include inc\string-object-file.ahk
#include inc\Class_ImageButton.ahk
;-!- Return after fucntions so lables don't get exacuted
return
#Include inc\DummyGui.ahk
#Include inc\lables.ahk
#include inc\TemplateSystem.ahk
#include inc\FunLables.ahk
#Include inc\tmLables.ahk
return


