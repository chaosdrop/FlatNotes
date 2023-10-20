SetUserHotKeys() {
	Hotkey,%savedHK1%, Label1
	Hotkey,%savedHK2%, Label2
	Hotkey,%savedHK3%, Label3
	Hotkey,%savedHK4%, Label4
	Hotkey,%savedHK5%, Label5
	Hotkey,%savedHK6%, Label6

;-------------------------------------------------
; Shortcuts
;-------------------------------------------------
	Hotkey,%savedSK1%, LabelS1
	Hotkey,%savedSK2%, LabelS2
	Hotkey,%savedSK3%, LabelS3
	Hotkey,%savedSK4%, LabelS4

return
}

setHK(num,INI,GUI) {
	 If INI
	  Hotkey, %INI%, Label%num%, Off
	 If GUI
	  Hotkey, %GUI%, Label%num%, On
	 IniWrite,% GUI ? GUI:null, settings.ini, Hotkeys, %num%
	 savedHK%num%  := HK%num%
	 TrayTip, Label%num%,% !INI ? GUI " ON":!GUI ? INI " OFF":GUI " ON`n" INI " OFF"
	 return
}
setSK(num,INI,GUI) {
	 If INI
	  Hotkey, %INI%, LabelS%num%, Off
	 If GUI
	  Hotkey, %GUI%, LabelS%num%, On
	 IniWrite,% GUI ? GUI:null, settings.ini, Shortcuts, %num%
	 savedHK%num%  := SK%num%
	 TrayTip, LabelS%num%,% !INI ? GUI " ON":!GUI ? INI " OFF":GUI " ON`n" INI " OFF"
	 return
}
BuildGUI1(){
	if WinExist("FlatNotes - Library") {
		Gui, 1:destroy
		return
	}
	firstDown = 1
	Gui, 1:New,+0x800000, FlatNotes - Library
	Gui, 1:Margin , 0, 0 
	Gui, 1:Font, s%SearchFontSize% Q%FontRendering%, %SearchFontFamily%, %U_MFC%
	Gui, 1:Color,%U_SBG%, %U_MBG%

	searchX = 6
	if (ShowStarHelper = 1) {
		searchX = 27
		CatX := CatX + 27
	}
	
	Gui, 1:Add,Edit, c%U_FBCA% w%SearchW% y%FontSize% x%searchX% y8 vSearchTerm gSearch -E0x200 HwndHSterm 
	Gui, 1:Add, ListBox, vLB1 +0x100 h8 w%LibW% x0 y0 -E0x200 Disabled -Tabstop
	Gui, 1:Add, ListBox, vlB2 +0x100 h15 w%LibW% x0 ys0 -E0x200 Disabled -Tabstop
	;ListBox used as background color for search area padding

	OD_Colors.SetItemHeight(SearchFontSize, CatFontFamily)
	
	CatBoxContents := "|" CatBoxContents
	
	if (ShowCatFilterBoxHelper == 1) {
		Gui, 1:Add, DDL, x%CatX% y7 -E0x200 +0x0210 r6 w%CatW% -vCatFilter gSearch HwndHCF, %CatBoxContents%
	}
	
	if (ShowTagFilterBoxHelper == 1) {
		Gui, 1:Add, combobox, c%U_FBCA% xp%TagsFilterX% y7 -E0x200 +0x0210 r6 w%TagsFilterW% vTagsFilter gSearch HwndHTF , %TagsFilterContents%
	}
	Gui, 1:Font, s%ResultFontSize% Q%FontRendering%, %ResultFontFamily%, %U_SFC%
	Gui, 1:Add, text, x-3 c%U_SFC% w%StarColW% center gSortStar vSortStar, %Star1%
	Gui, 1:Add, text, c%U_SFC% xp+%StarColW% w%NameColW% center gSortName vSortName, Name
	Gui, 1:Add, text, c%U_SFC% xp+%NameColW% yp+1 w%BodyColW% center gSortBody vSortBody, Body
	Gui, 1:Add, text, yp0 xp+%BodyColW% w%AddColW% center c%U_SFC% gSortAdded vSortAdded, Added
	Gui, 1:Add, text, yp0 xp+%AddColW% w%ModColW% center c%U_SFC% gSortModded vSortModded, Modified
	Gui, 1:Add, text, yp0 xp+%ModColW% w%TagColW% center c%U_SFC% vSortTags, Tags
	Gui, 1:Add, text, yp0 xp+%TagColW% w%CatColW% center c%U_SFC% vSortCat, Cat
	Gui, 1:Add, text, yp0 xp+%CatColW% w%ParentColW% center c%U_SFC% vSortParent, Parent
	Gui, 1:Add, text, yp0 xp+%ParentColW% w%ScriptColW% center c%U_SFC% gFilterScript vSortScript, %RunIcon%
	Gui, 1:Add, text, yp0 xp+%ScriptColW% w%ClipColW% center c%U_SFC% gFilterClip vSortClip, %DiskSymbol%
	Gui, 1:Add, text, yp0 xp+%ClipColW% w%BookmarkColW% center c%U_SFC% gFilterBookmark vSortBookmark,%LinkSymbol%
	
	Gui, 1:Add, ListView,section -E0x200 -hdr NoSort NoSortHdr LV0x10000 grid r%ResultRows% w%libWAdjust% x-3 C%U_MFC% vLV hwndHLV gNoteListView +altsubmit Report, Star|Title|Body|Added|Modified|RawAdded|RawModded|FileName|RawStar|Tags|Cat|Parent|checked|Marked|Extra|Script|Clip|Bookmark


	;Gui, 1:Add,edit, readonly h6 -E0x200
	title_h := PreviewFontSize*1.8
	TitleWAdjust := round(LibW*0.75)
	
	if (ShowPreviewEditBoxHelper) {
	
	;gLibTemplateAdd
	Gui, 1:Add,text, center xs c%U_SFC% -E0x200 w25 h%title_h% gLibTemplateAdd vAddTemplateText, %TemplateSymbol%
		
	
	Gui, 1:Add,edit, readonly center x+15 -E0x200 vTitleBar C%U_SFC% w%TitleWAdjust% h%title_h% backgroundTrans -Tabstop,
	
	
	;Good font for symbols
	
	SymbolFontSize := PreviewFontSize - 1
	Gui, 1:Font, s%SymbolFontSize% Q%FontRendering%, Segoe UI Emoji, %U_SFC%
	
	; Disable Tree  Because it's too error prone.
	;TreeIconX := LibW - 25
	;Gui, 1:Add,text, center yp0 x%TreeIconX% c%U_SFC% -E0x200 w25 h%title_h% gBuildTreeUI, %TreeSymbol%
	
	; Replaced Tree with clipboard copy
	
	StickyIconX := LibW - 100
	RunIconX := LibW - 75
	ClipIconX := LibW - 50
	BookmarkIconX := LibW - 25
	
		Gui, 1:Add,text, center yp0 x%StickyIconX% vMakeSticky c%U_SFC% -E0x200 w25 h%title_h% gMakeSticky, %StickyIcon%

	
	Gui, 1:Add,text, center yp0 x%RunIconX% vStoreRun c%U_SFC% -E0x200 w25 h%title_h% gRunStoredCommand, %RunIcon%
	
	Gui, 1:Add,text, center yp0 x%ClipIconX% vStoreClipboard c%U_SFC% -E0x200 w25 h%title_h% gRestoreClipboard, %SaveSymbol%
	
	Gui, 1:Add,text, center yp0 x%BookmarkIconX% vStoreBookmark c%U_SFC% -E0x200 w25 h%title_h% gGotoBookmark, %LinkSymbol%
	
	
	
	
	;Allow User set prevent/edit font
	Gui, 1:Font, s%PreviewFontSize% Q%FontRendering%, %PreviewFontFamily%, %U_SFC%
	
	Gui, 1:Add,Edit, section x0 hwndHPB -E0x200  r%PreviewRows% w%LibW% C%U_MFC% gPreviewBox vPreviewBox,
	}
	
	; The two listboxes act as centering backgrounds for the tags and parent edits.
	if (ShowTagEditBoxHelper OR ShowParentEditBoxHelper) {
		Gui, 1:Add, ListBox, +0x100 r1 w%TagLibW% x0 y+1 -E0x200 Disabled -Tabstop
		Gui, 1:Add, ListBox, +0x100 r1 w%ParentLibW% xp%ParenetLibX% -E0x200 Disabled -Tabstop
	}
	
	if (ShowTagEditBoxHelper) {	
		Gui, 1:Add,Edit, section x0 yp+6 -E0x200 hwndHPT  r1 w%TagLibW% C%U_MFC% vTagBox center,	
	}
	
	if (ShowParentEditBoxHelper) {
		Gui, 1:Add, Edit,xp%ParenetLibX%  -E0x200 r1 center C%U_MFC% w%ParentLibW% vNoteParent HwndHNP,
	}
	
	MakeFileList(1)
	CLV := New LV_Colors(HLV)
	CLV.SelectionColors(rowSelectColor,rowSelectTextColor)
	
	
	
	;statusbar
	if (ShowStatusBar=1) {
		Gui, 1:Font, s8 Q%FontRendering%
		StatusWidth := LibW//3
		Gui, 1:add,text, x0 left vStatusBarCount w%StatusWidth% C%U_SFC%, %TotalNotes% of %TotalNotes%
		Gui, 1:add,text, x+0 center vStatusBarM w%StatusWidth% C%U_SFC%,M: 00/00/00
		Gui, 1:add,text, x+0 right vStatusBarA w%StatusWidth% C%U_SFC%,A: 00/00/00
		Gui, 1:Font, s2
		Gui, 1:add,text, xs
	}

	Gui, Font, s%ResultFontSize% Q%FontRendering% c%U_MSFC%, %ResultFontFamily%, %U_SFC%
	if (DeafultSort=1)
		GuiControl, Font, SortStar
	if (DeafultSort=2)
		GuiControl, Font, SortName
	if (DeafultSort=3)
		GuiControl, Font, SortBody
	if (DeafultSort=6)
		GuiControl, Font, SortAdded
	if (DeafultSort=7)
		GuiControl, Font, SortModded
	
	
	;These are needed to get the clicked COL
	WM_LBUTTONDOWN = 0x0201
	OnMessage( WM_LBUTTONDOWN, "HandleMessage" )

	WM_RBUTTONDOWN = 0x0204
	OnMessage( WM_RBUTTONDOWN, "HandleMessage" )


	gui, 1:Add, Button, Default w15 y-2500 x-2500 -Tabstop gNewFromSearch, HK
	Gui, 1:Add,Edit, w35 y-2000 x-2000 vSearchFilter HwndHSF -Tabstop,
	;Gui, 1:Add,Edit, w35 y-2200 x-2200 vCatFilter HwndHCF -Tabstop,
	
	if (ShowStarHelper = 1) {
			Gui, 1:Font, s8 Q%FontRendering%, Segoe UI Emoji
, %U_MFC%

			Gui, 1:add, text, center backgroundTrans w15 h15 x2 y8 -E0x200 c%U_FBCA% gStarFilterBox, %star1%
		}
	
	Gui, 1:add, text, center backgroundTrans w15 h15 x%HelpIconx% y6 -E0x200 c%U_FBCA% gHelpWindow, [?]
	
	

	if (HideScrollbars = 1) {
		LVM_ShowScrollBar(HPB,1,False)
		GuiControl,+Vscroll,%HPB%
	}
	
	;Listbox color
	DDLbgColor := strreplace(U_SBG,"0x")
	DDLbgColorb2 := strreplace(U_MBG,"0x")
	DDLfontColorb2 := strreplace(U_MFC,"0x")
	if (ShowCatFilterBoxHelper == 1) {
		CtlColors.Attach(HCF, DDLbgColor)
		OD_Colors.Attach(HCF, {T: U_SFC})
	}
	if (ShowTagFilterBoxHelper = 1) {
		CtlColors.Attach(HTF, DDLbgColorb2,DDLfontColorb2)
		OD_Colors.Attach(HTF, {T: U_MFC})
	}
	Gui, 1:SHOW, Hide w%LibW% 
	WinGet, g1ID,, FlatNotes - Library
	g1Open=0
	;Gui, 1:%A_Gui% +LastFound
	;WinSet, TransColor, 000000
    ;WinSet, ReDraw
	gosub search
	return
}
BuildGUI2(){
	QuickSubWidth := QuickNoteWidth-70
	QuickNoteEditW := QuickNoteWidth-5
	QuickNoteXOffset := 3
	FileSafeClipBoard := NameEncode(clipboard)
	CheckForOldNote = %U_NotePath%%FileSafeClipBoard%.txt
	FileRead, OldNoteData, %CheckForOldNote%
	MouseGetPos, xPos, yPos
	xPos /= 1.5
	yPos /= 1.15
	if (isfake = 1){
		xPos = x50
		fakeY := round((A_ScreenHeight/3))
		yPos := y%fakeY%
	}else{
		xPos = x%xPos%
		yPos = y%yPos%
	}
	OD_LB  := "+0x0050" 
	Gui, 2:New,-Caption, FlatNote - QuickNote
	Gui, 2:Margin , 2, 2 
	Gui, 2:Font, s%TitleBarFontSize% Q%FontRendering%, Verdana, %U_MFC%	
	Gui, 2:Color,%U_SBG%, %U_MBG%
	QNtW := QuickNoteWidth - 50
	QNxX := QuickNoteWidth - 25
	Gui, 2:add,listbox, center hwndQNLBG r2 x0 y-5%OD_LB% disabled w%QuickNoteWidth% -E0x200,%a_space%|%a_space%
	Gui, 2:Add,Text, y3 c%U_MFC% x2 h25 w25 center backgroundTrans hwndQNpinBar gPinsticky, =
	Gui, 2:Add,Text, y3 c%U_MFC% x%QNxX% h25 w25 center backgroundTrans g2GuiClose hwndQNxBar, X
	Gui, 2:add,Text, center c%U_SFC% GuiMove x2 y3 h25 hwndQNTitleBar w%QNtW% backgroundTrans, - Quick Note -
	Gui, 2:Font, s%FontSize% Q%FontRendering%, %FontFamily%, %U_SFC%	
	
	gui, 2:add,listbox, w%QuickSubWidth% r1 y+-3 x2 -E0x200 disabled
	Gui, 2:Add,Edit, C%U_MFC% w%QuickSubWidth% r1 yp+5 xp+0 vQuickNoteName gQuickSafeNameUpdate -E0x200 hwndHQNNE
	
	gui, 2:add,listbox, w35 r1 x+2  yp-5 -E0x200 disabled
	Gui, 2:Add,Edit, xp+0 yp+5 w35 r1 C%U_MFC% -E0x200 center hwndHQNQS vQuickStar,

	Gui, 2:Font, s%FontSize%, Segoe UI Emoji
	GUI, 2:Add,text, x+2 yp0 w25 r1 C%U_SFC% center gStarQN, %Star1%
	Gui, 2:Font, s%FontSize% Q%FontRendering%, %FontFamily%, %U_SFC%	
	Gui, 2:Add,Edit, disabled hidden x+1 r1 w0
	
	Gui, 2:Add,Edit, xs section y+2 x%QuickNoteXOffset% -E0x200 C%U_MFC% r%QuickNoteRows% w%QuickNoteEditW% vQuickNoteBody hwndHQNB
	
	HalfQuickNoteEditW := QuickNoteEditW * 0.5	
	; Tag Box
	if (ShowQuickTagEditBoxHelper == 1) {
	Gui, 2:Add, ListBox, y+2 +0x100 h15 w%QuickNoteEditW%  -E0x200 Disabled -Tabstop

	Gui, 2:Add,Edit,  yp+5 x%QuickNoteXOffset% -E0x200 -WantReturn C%U_MFC% r1 w%QuickNoteEditW% vQuickNoteTags hwndHQNT center	
	Gui, 2:Add, ListBox, y+2 +0x100 h15 w%HalfQuickNoteEditW%  -E0x200 Disabled -Tabstop
	}
	
	if (ShowQuickParentEditBoxHelper == 1) {
	Gui, 2:Add,Edit,  yp+5 x%QuickNoteXOffset% -E0x200 -WantReturn C%U_MFC% r1 w%HalfQuickNoteEditW% vQuickNoteParent hwndHQPT center
	}
	
	OD_Colors.SetItemHeight(SearchFontSize, CatFontFamily)
	Gui, 2:Font, s%SearchFontSize% Q%FontRendering%, %SearchFontFamily%, %U_MFC%
	Gui, 2:Color,%U_SBG%, %U_MBG%
	
	if (ShowQuickCatEditBoxHelper == 1) {
	Gui, 2:Add, DDL, Sort xp%HalfQuickNoteEditW% yp0 -E0x200 +0x0210 r5 w%HalfQuickNoteEditW% vQuickNoteCat hwndHQNC,%CatBoxContents%
	}
	
	DDLbgColor := strreplace(U_SBG,"0x")
	DDLbgColorb2 := strreplace(U_MBG,"0x")
	DDLfontColorb2 := strreplace(U_MFC,"0x")
	CtlColors.Attach(HQNC, DDLbgColor)
	OD_Colors.Attach(HQNC, {T: U_SFC})
	
	if (HideScrollbars = 1) {
		LVM_ShowScrollBar(HQNB,1,False)
		GuiControl,+Vscroll,%HQNB%
	}
	QNTextButtonW := round(QuickNoteEditW*0.5)
	QNTextButtonSaveX := QuickNoteXOffset+QNTextButtonW
	gui, 2:Add, text, xs section center c%U_SFC% x%QuickNoteXOffset% w%QNTextButtonW%  gNoteTemplateSelectUI, [ Template ] 
	gui, 2:Add, text, x+1 center c%U_SFC% x%QNTextButtonSaveX% w%QNTextButtonW%  gSaveButton, [ Save ] 
	Gui, 2:Add, Button,x-1000 default gSaveButton y-1000, &Save
	Gui, 2:Add,Text,x-1000 y-1000 vFileSafeName hwndHQNFSN,	
	Gui, 2:SHOW, w%QuickNoteWidth% %xPos% %yPos% 
	;OD_Colors.Attach(QNLBG, {1: {T: 0xFFFFFF, B: 0x800080}, 2: {T: 0xFFFFFF, B: 0x800080}})
	GuiControl, MoveDraw, %QNTitleBar%
	GuiControl, MoveDraw, %QNxBar%
	GuiControl, MoveDraw, %QNpinBar%
	return  
}


MakeFileList(ReFreshMyNoteArray){
	TVReDraw = 1
	FileList := ""
	MyNotesArray := {}
	Loop, Files, %U_NotePath%*.txt
		FileList .= A_LoopFileName "`n"
;trim off the extra starting newline
	FileList := RTrim(Filelist, "`n")
	if (isStarting = 1)
		Progress, 25, Building the search index
	Loop Parse, FileList, `n
	{
		NoteField := ""
		OldNoteField = NoteField
		
		if (SearchWholeNote = 0)
			FileReadLine, NoteField, %U_NotePath%%A_LoopField%, 1
		if (SearchWholeNote = 1)
			FileRead, NoteField, %U_NotePath%%A_LoopField%

		NoteIniName := RegExReplace(A_LoopField, "\.txt(?:^|$|\r\n|\r|\n)", Replacement := ".ini")
		NoteBackupName := NoteBackupName := := RegExReplace(A_LoopField, "\.txt(?:^|$|\r\n|\r|\n)")
		NoteIni = %detailsPath%%NoteIniName%
		IniRead, StarField, %NoteIni%, INFO, Star,S
		IniRead, NameField, %NoteIni%, INFO, Name
		NameField := strreplace(NameField,"$#$")
		IniRead, AddedField, %NoteIni%, INFO, Add
		IniRead, ModdedField, %NoteIni%, INFO, Mod
		IniRead, TagsField, %NoteIni%, INFO, Tags,
		IniRead, CatField, %NoteIni%, INFO, Cat,
		IniRead, ParentField, %NoteIni%, INFO, Parent,
		IniRead, CheckedField, %NoteIni%, INFO, Checked,
		IniRead, MarkedField, %NoteIni%, INFO, Marked,
		IniRead, ExtraField, %NoteIni%, INFO, Extra,
		IniRead, ScriptField, %NoteIni%, INFO, RunType
		IniRead, ClipField, %NoteIni%, INFO, Clip
		IniRead, BookmarkField, %NoteIni%, INFO, Bookmark
		
		if	(ClipField == 1){
			ClipField := SaveSymbol
		}else{
			ClipField := A_space
		}
		if (BookmarkField == 1){
			BookmarkField := BookmarkSymbol
		}else{
			BookmarkField := A_space
		}
		if (ScriptField == "AHK") {
			ScriptField := TypeAIcon	
		}else if (ScriptField == "BAT"){
			ScriptField := TypeBIcon
		} else{
			ScriptField := A_space
		}
		
		FormatTime, UserTimeFormatA, %AddedField%, %UserTimeFormat%
		FormatTime, UserTimeFormatM, %ModdedField%,%UserTimeFormat%

		if (StarField=10001)
			StarFieldArray:=Star1
		if (StarField=10002)
			StarFieldArray:=Star2
		if (StarField=10003)
			StarFieldArray:=Star3
		if (StarField=10004)
			StarFieldArray:=Star4
		if (StarField != A_space and StarField !=10001 and StarField !=10002 and StarField !=10003 and StarField !=10004)
			StarFieldArray:=StarField
		if (StarField=10000)
			StarFieldArray:= A_sapce
		
		if (ReFreshMyNoteArray = 1){
			LV_Add("",StarFieldArray ,NameField, NoteField, UserTimeFormatA,UserTimeFormatM,AddedField,ModdedField,A_LoopField,StarField,TagsField,CatField,ParentField,CheckedField,MarkedField,ExtraField,ScriptField,ClipFeild,BookmarkField)
			}

		UsedStars .= StarFieldArray "|"
		MyNotesArray.Push({1:StarFieldArray,2:NameField,3:NoteField,4:UserTimeFormatA,5:UserTimeFormatM,6:AddedField,7:ModdedField,8:A_LoopField,9:StarField,10:TagsField,11:CatField,12:ParentField,13:CheckedField,14:MarkedField,15:ExtraField,16:ScriptField,17:ClipField,18:BookmarkField})
	} ; File loop end
	UsedStars := RemoveDups(UsedStars,"|")
	UsedStars := StrReplace(UsedStars,"||","|")
	LV_ModifyCol(1, StarColW) 
	LV_ModifyCol(1, "Center")
	LV_ModifyCol(2, NameColW)
	LV_ModifyCol(2, "Logical")
	LV_ModifyCol(3, BodyColW) ; 275
	LV_ModifyCol(3, "Logical")
	LV_ModifyCol(4, AddColW)
	LV_ModifyCol(4, "Center")
	LV_ModifyCol(5, ModColW)
	LV_ModifyCol(5, "Center")
	LV_ModifyCol(6, 0)
	LV_ModifyCol(6, "Logical")
	LV_ModifyCol(7, 0)
	LV_ModifyCol(7, "Logical")
	LV_ModifyCol(8, 0)
	LV_ModifyCol(9, 0)
	LV_ModifyCol(10, TagColW)
	LV_ModifyCol(10, "Logical")
	LV_ModifyCol(11, CatColW)
	LV_ModifyCol(11, "Logical")
	LV_ModifyCol(12, ParentColW)
	LV_ModifyCol(12, "Logical")
	LV_ModifyCol(13, CheckedColW)
	LV_ModifyCol(13, "Logical")
	LV_ModifyCol(14, MarkedColW)
	LV_ModifyCol(14, "Logical")
	LV_ModifyCol(15, ExtraColW)
	LV_ModifyCol(15, "Logical")
	LV_ModifyCol(16, ScriptColW)
	LV_ModifyCol(16, "Center")
	LV_ModifyCol(17, ClipColW)
	LV_ModifyCol(17, "Center")
	LV_ModifyCol(18, BookmarkColW)
	LV_ModifyCol(18, "Center")
	
	if (DeafultSort = 1)
			LV_ModifyCol(2, "Sort")
	if (DeafultSort = 10)
			LV_ModifyCol(2, "SortDesc")
	if (DeafultSort = 2)
			LV_ModifyCol(3, "Sort")
	if (DeafultSort = 20)
			LV_ModifyCol(3, "SortDesc")
	if (DeafultSort = 3)
			LV_ModifyCol(6, "Sort")
	if (DeafultSort = 30)
			LV_ModifyCol(6, "SortDesc")
	if (DeafultSort = 4)
			LV_ModifyCol(7, "Sort")
	if (DeafultSort = 40)
			LV_ModifyCol(7, "SortDesc")
	TotalNotes := MyNotesArray.MaxIndex()
	gosub MakeOOKStarList
	gosub TagFilterUpdate
	return
}

TagFilterUpdate:
TagsFilterContents := 
for k, note in MyNotesArray 
{
	TmpTags := StrSplit(Note.10,[A_Tab, A_Space,","])
	for k, v in TmpTags
	{
		v := trim(v)
		strreplace(v,"\","\\")
		if (!instr(TagsFilterContents,v))
		{
			TagsFilterContents .= "|" v 
		}
	}
}
GuiControl,,TagsFilter, %TagsFilterContents%
return

ReFreshLV(){
TVReDraw = 1
GuiControl, 1:-Redraw, LV
LV_Delete()
For Each, Note In MyNotesArray
{
	 LV_Add("", Note.1, Note.2,Note.3,Note.4,Note.5,Note.6,Note.7,Note.8,Note.9,Note.10,Note.11,Note.12,Note.13,Note.14,Note.15,Note.16,Note.17,Note.18)
}
gosub SortNow
TotalNotes := MyNotesArray.MaxIndex() 
GuiControl, 1:+Redraw, LV
return
}
 
SaveFile(QuickNoteName,FileSafeName,QuickNoteBody,Modified,QuickNoteTags,QuickNoteCat,QuickNoteParent) {
	TVReDraw = 1
	FileNameTxt := FileSafeName ".txt"
	
	SaveFileName = %U_NotePath%%FileSafeName%.txt
	if (SaveFileName =".txt" or Strlen(SaveFileName)<1) {
		msgbox Name error #01
		return
		}
	if (SaveFileName =".txt.txt") {
		msgbox Name error #02
		return
		}
	if (QuickNoteBody != false)
	{
		FileRecycle, %SaveFileName%
		FileAppend , %QuickNoteBody%, %SaveFileName%, UTF-8
	} else {
		FileRead, QuickNoteBody,%U_NotePath%%FileSafeName%.txt
	}
	
	tmpFullPath = %U_NotePath%%FileSafeName%.txt

	if !FileExist(tmpFullPath)
	{
		ProbablyTooLong := StrLen(tmpFullPath)
		msgbox :!:NOTE SAVE FAILED:!: `n`nThis is normally due to your title being too long. Your file path length with the provided title was %ProbablyTooLong% and windows max file path size is 255 characters which you should aim to be well below in case you want to move your files someday. P/s The Note body text was copied to your clipboard if it wasn't blank.
		
		if (QuickNoteBody)
			Clipboard := QuickNoteBody
	return
	}
	
		
	iniRead,CreatedDate,%detailsPath%%FileSafeName%.ini,INFO,Add,%A_Now%
	iniRead,NoteStar,%detailsPath%%FileSafeName%.ini,INFO,Star,10000
	FormatTime, UserTimeFormatA, %CreatedDate%, %UserTimeFormat%
	FormatTime, UserTimeFormatM, %A_Now%, %UserTimeFormat%
	
		if (NoteStar=10001)
			StarFieldArray:=Star1
		if (NoteStar=10002)
			StarFieldArray:=Star2
		if (NoteStar=10003)
			StarFieldArray:=Star3
		if (NoteStar=10004) 
			StarFieldArray:=Star4
		if (NoteStar !=10001 and NoteStar !=10002 and NoteStar !=10003 and NoteStar !=10004 and NoteStar !=A_Space)
			StarFieldArray:=NoteStar
		if (NoteStar=10000)
			StarFieldArray:= A_sapce
			
	if (Modified=1){
		for Each, Note in MyNotesArray{
			If (Note.2 = QuickNoteName){
				MyNotesArray.RemoveAt(Each)
			}
		}
	}	
	
	Iniread, Script, %detailsPath%%FileSafeName%.ini,INFO,RunType,%a_space%
	Iniread, Clip, %detailsPath%%FileSafeName%.ini,INFO,Clip,%a_space%
	Iniread, Bookmark, %detailsPath%%FileSafeName%.ini,INFO,Bookmark,%a_space%
	Iniread, Checked, %detailsPath%%FileSafeName%.ini,INFO,Bookmark,%a_space%
	Iniread, Marked, %detailsPath%%FileSafeName%.ini,INFO,Bookmark,%a_space%
	Iniread, Extra, %detailsPath%%FileSafeName%.ini,INFO,Bookmark,%a_space%
	
		if	(Clip == 1){
		Clip := SaveSymbol
		}else{
			Clip := A_space
		}
		if (Bookmark == 1){
			Bookmark := BookmarkSymbol
		}else{
			Bookmark := A_space
		}
		if (Script == "AHK") {
			Script := TypeAIcon	
		}else if (ScriptField == "BAT"){
			Script := TypeBIcon
		} else{
			Script := A_space
		}
	
	
	MyNotesArray.Push({1:StarFieldArray, 2:QuickNoteName,3:QuickNoteBody,4:UserTimeFormatA,5:UserTimeFormatM,6:CreatedDate,7:A_Now,8:FileNameTxt,9:NoteStar,10:QuickNoteTags,11:QuickNoteCat,12:QuickNoteParent,13:Checked,14:Marked,15:Extra,16:Script,17:Clip,18:Bookmark})
	

	iniWrite,%CreatedDate%,%detailsPath%%FileSafeName%.ini,INFO,Add
	iniWrite,$#$%QuickNoteName%$#$,%detailsPath%%FileSafeName%.ini,INFO,Name
	iniWrite,%A_Now%,%detailsPath%%FileSafeName%.ini,INFO,Mod
	iniWrite,%NoteStar%,%detailsPath%%FileSafeName%.ini,INFO,Star
	iniWrite,%QuickNoteTags%,%detailsPath%%FileSafeName%.ini,INFO,Tags
	iniWrite,%QuickNoteCat%,%detailsPath%%FileSafeName%.ini,INFO,Cat
	iniWrite,%QuickNoteParent%,%detailsPath%%FileSafeName%.ini,INFO,Parent
	
gosub TagFilterUpdate
return
}
MakeAnyMissingINI(){
	FileList := ""
	MyNotesArray := {}
	Loop, Files, %U_NotePath%*.txt
		FileList .= A_LoopFileName "`n"
	FileList := RTrim(Filelist, "`n")
	Loop Parse, FileList, `n
	{
		NoteIniName := ""
		DecodedNoteName := ""
		NoteIniName := RegExReplace(A_LoopField, "\.txt(?:^|$|\r\n|\r|\n)", Replacement := ".ini")
		IfNotExist, %detailsPath%%NoteIniName% 
		{
				DecodedNoteName := RegExReplace(A_LoopField, "\.txt(?:^|$|\r\n|\r|\n)")
				DecodedNoteName := NameDecode(DecodedNoteName)
				NoteName := RegExReplace(A_LoopField, "\.txt(?:^|$|\r\n|\r|\n)")
				
				iniWrite,$#$%DecodedNoteName%$#$,%detailsPath%%NoteName%.ini,INFO,Name
				iniWrite,%A_Now%,%detailsPath%%NoteName%.ini,INFO,Mod
				iniWrite,%A_Now%,%detailsPath%%NoteName%.ini,INFO,Add
				iniWrite,10000,%detailsPath%%NoteName%.ini,INFO,Star
				iniWrite,"",%detailsPath%%NoteName%.ini,INFO,Tags
				iniWrite,"",%detailsPath%%NoteName%.ini,INFO,Cat
				iniWrite,"",%detailsPath%%NoteName%.ini,INFO,Parent
	}   } 
return
}
RemoveINIsOfMissingTXT(){
	FileList := ""
	MyNotesArray := {}
	Loop, Files, %detailsPath%*.ini
		FileList .= A_LoopFileName "`n"
	FileList := RTrim(Filelist, "`n")
	Loop Parse, FileList, `n
	{
		NoteName := ""
		NoteName := RegExReplace(A_LoopField, "\.ini(?:^|$|\r\n|\r|\n)", Replacement := ".txt")
		IfNotExist, %U_NotePath%%NoteName%
			FileRecycle %detailsPath%%A_LoopField%
	} 
return
}
BackupNotes(){
	settimer, CheckBackupLaterTimer, 7200000
	if (A_Now - LastBackupTime < 86400) ;1day in seconds
		return	
	FormatTime, CurrentTimeStamp, %A_Now%, yy-MM-dd@tHH
	7z_exe:="sys\7za.exe"
	z = 0
	BackupFileList := ""  ; Initialize to be blank.
	Loop, %A_WorkingDir%\Backups\*.*
		BackupFileList .= A_LoopFileName "`n"
	Sort, BackupFileList
	Sort, BackupFileList, R  
	Loop, parse, BackupFileList, `n
	{
		if (A_LoopField = "")
			continue
		z +=1
		if (z>=backupsToKeep)
		 FileRecycle %A_WorkingDir%\Backups\%A_LoopField%
	}
	LastBackupTime := A_Now
	iniwrite,%LastBackupTime%,%iniPath%,General,LastBackupTime
	Run, %7z_exe% a -t7z "%A_WorkingDir%\Backups\%CurrentTimeStamp%.7z" "%detailsPath%" "%U_NotePath%",,Hide UseErrorLevel
return
}

LV_Set_Column_Order( _Num_Of_Columns, _New_Column_Order, _lvID="1", Delim="," )
{
    local colOrder, pos
    VarSetCapacity( colOrder, _Num_Of_Columns * 4, 0 )
    
    Loop, Parse, _New_Column_Order, %Delim%
    {
        pos := A_Index - 1
        NumPut( A_LoopField - 1, colOrder, pos * 4, "UInt" )
    }
    
    SendMessage, LVM_FIRST + LVM_SETCOLUMNORDERARRAY
               , _Num_Of_Columns, &colOrder, SysListView32%_lvId%, A   ; LVM_SETCOLUMNORDERARRAY
    
    SendMessage, LVM_FIRST + LVM_REDRAWITEMS        
               , 0, _Num_Of_Columns - 1, SysListView32%_lvId%, A   ; LVM_REDRAWITEMS
    
    VarSetCapacity( colOrder, 0 ) ; Clean up.
}


LV_Get_Column_Order( _Num_Of_Columns, _lvID="1", Delim="," )
{
    local colOrder, pos
    Output := ""
    VarSetCapacity( colOrder, _Num_Of_Columns * 4, 0 )
    
    SendMessage, LVM_FIRST + LVM_GETCOLUMNORDERARRAY
               , _Num_Of_Columns, &colOrder, SysListView32%_lvID%, A   ; LVM_GETCOLUMNORDERARRAY

    Loop, % _Num_Of_Columns
    {
        pos := A_Index - 1
        Col := NumGet( colOrder, pos * 4, "UInt"  ) + 1 ; Array is zero-based so we add one.
        Output .= Col . Delim
    }
    StringTrimRight, Output, Output, 1 ; Trim trailing delimiter.
    VarSetCapacity( colOrder, 0 ) ; Clean up.
    Return, Output
}

NameEncode(Name){
; RegExReplace(RowText, "\*|\?|\\|\||/|""|:|<|>"
Name := strreplace(Name,"\","$1bslash%")
Name := strreplace(Name,"?","$2qm%")
Name := strreplace(Name,"*","$3as%")
Name := strreplace(Name,"|","$4pi%")
Name := strreplace(Name,"""","$5dq%")
Name := strreplace(Name,":","$6col%")
Name := strreplace(Name,"<","$7less%")
Name := strreplace(Name,">","$8great%")
Name := strreplace(Name,"/","$9fslash%")
return Name
}
NameEncodeSticky(Name){
; RegExReplace(RowText, "\*|\?|\\|\||/|""|:|<|>|;|,|$|[|]|(|)|{|}|&"
Name := strreplace(Name,"\","_bs_")
Name := strreplace(Name,"?","_qm_")
Name := strreplace(Name,"@","_at_")
Name := strreplace(Name,"!","_e_")
Name := strreplace(Name,"-","_dash_")
Name := strreplace(Name,"+","_ps_")
Name := strreplace(Name,"=","_eq_")
Name := strreplace(Name,"—","_emdash_")
Name := strreplace(Name,"%","_per_")
Name := strreplace(Name,"^","_sup_")
Name := strreplace(Name,"*","_ast_")
Name := strreplace(Name,"|","_pi_")
Name := strreplace(Name,"""","_q_")
Name := strreplace(Name,":","_d_")
Name := strreplace(Name,"$","_ds_")
Name := strreplace(Name,"&","_amp_")
Name := strreplace(Name,"#","_pd_")
Name := strreplace(Name,"<","_g_")
Name := strreplace(Name,">","_l_")
Name := strreplace(Name,"(","_rbl_")
Name := strreplace(Name,")","_rbr_")
Name := strreplace(Name,"[","_sbl_")
Name := strreplace(Name,"]","_sbr_")
Name := strreplace(Name,"{","_cbl_")
Name := strreplace(Name,"}","_cbr_")
Name := strreplace(Name,"/","_fs_")
Name := strreplace(Name,".","_p_")
Name := strreplace(Name,",","_c_")
Name := strreplace(Name,";","_sc_")
Name := strreplace(Name,"1","_none_")
Name := strreplace(Name,"2","_ntwo_")
Name := strreplace(Name,"3","_nthree_")
Name := strreplace(Name,"4","_nfour_")
Name := strreplace(Name,"5","_nfive_")
Name := strreplace(Name,"6","_nsix_")
Name := strreplace(Name,"7","_nseven_")
Name := strreplace(Name,"8","_neight_")
Name := strreplace(Name,"9","_nnine_")
Name := strreplace(Name,"0","_nzero_")
Name := strreplace(Name," ","_")
return Name
}
NameDecode(Name){
Name := strreplace(Name,"$1bslash%","\")
Name := strreplace(Name,"$2qm%","?")
Name := strreplace(Name,"$3as%","*")
Name := strreplace(Name,"$4pi%","|")
Name := strreplace(Name,"$5dq%","""")
Name := strreplace(Name,"$6col%",":")
Name := strreplace(Name,"$7less%","<")
Name := strreplace(Name,"$8great%",">")
Name := strreplace(Name,"$9fslash%","/"	)
return Name
}
RemoveDups( List="", delimiter="`n" ) {
Loop, Parse, List, %delimiter%
	List := (A_Index=1 ? A_LoopField : List . (InStr(delimiter List delimiter
	, delimiter A_LoopField delimiter) ? "" : delimiter A_LoopField ) )
return list
}

LVM_ShowScrollBar(hLV,wBar,p_Show=True)
    {
    Static Dummy6622

          ;-- Scroll bar flags
          ,SB_HORZ:=0
            ;-- Shows or hides a window's standard horizontal scroll bars.

          ,SB_VERT:=1
            ;-- Shows or hides a window's standard vertical scroll bar.

          ,SB_CTL:=2
            ;-- Shows or hides a scroll bar control. The hLV parameter must be
            ;   the handle to the scroll bar control.

          ,SB_BOTH:=3
            ;-- Shows or hides a window's standard horizontal and vertical
            ;   scroll bars.

    RC:=DllCall("ShowScrollBar"
        ,(A_PtrSize=8) ? "Ptr":"UInt",hLV               ;-- hWnd
        ,"UInt",wBar                                    ;-- wbar
        ,"UInt",p_Show)                                 ;-- bShow

    Return RC ? True:False
    }
	
OnMsgBox() {
	MouseGetPos, xPos, yPos
	xPos /= 1.5
	yPos /= 1.15
	DetectHiddenWindows, On
    Process, Exist
    If (WinExist("ahk_class #32770 ahk_pid " . ErrorLevel)) {
        WinMove %xPos%, %yPos%
    }
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
}

JEE_ObjCount(oObj)
{
	return NumGet(&oObj + 4*A_PtrSize)
}

ConvertStar(C_Star)
{
if (C_Star == 10001)
	C_Star = %Star1%
if (C_Star == 10002)
	C_Star = %Star2%
if (C_Star == 10003)
	C_Star = %Star3%
if (C_Star == 10004)
	C_Star = %Star4%
	return C_Star
}

EncodeStar(C_Star)
{
	if (C_Star == Star1)
		C_Star = 10001
	if (C_Star == Star2)
		C_Star = 10002
	if (C_Star == Star3)
		C_Star = 10003
	if (C_Star == Star4)
		C_Star = 10004
	return C_Star
}

Deref(String)
{
    spo := 1
    out := ""
    while (fpo:=RegexMatch(String, "(%(.*?)%)|``(.)", m, spo))
    {
        out .= SubStr(String, spo, fpo-spo)
        spo := fpo + StrLen(m)
        if (m1)
            out .= %m2%
        else switch (m3)
        {
            case "a": out .= "`a"
            case "b": out .= "`b"
            case "f": out .= "`f"
            case "n": out .= "`n"
            case "r": out .= "`r"
            case "t": out .= "`t"
            case "v": out .= "`v"
            default: out .= m3
        }
    }
    return out SubStr(String, spo)
}

UseGDIP(Params*) { ; Loads and initializes the Gdiplus.dll at load-time
   ; GET_MODULE_HANDLE_EX_FLAG_PIN = 0x00000001
   Static GdipObject := ""
        , GdipModule := ""
        , GdipToken  := ""
   Static OnLoad := UseGDIP()
   If (GdipModule = "") {
      If !DllCall("LoadLibrary", "Str", "Gdiplus.dll", "UPtr")
         UseGDIP_Error("The Gdiplus.dll could not be loaded!`n`nThe program will exit!")
      If !DllCall("GetModuleHandleEx", "UInt", 0x00000001, "Str", "Gdiplus.dll", "PtrP", GdipModule, "UInt")
         UseGDIP_Error("The Gdiplus.dll could not be loaded!`n`nThe program will exit!")
      VarSetCapacity(SI, 24, 0), NumPut(1, SI, 0, "UInt") ; size of 64-bit structure
      If DllCall("Gdiplus.dll\GdiplusStartup", "PtrP", GdipToken, "Ptr", &SI, "Ptr", 0)
         UseGDIP_Error("GDI+ could not be startet!`n`nThe program will exit!")
      GdipObject := {Base: {__Delete: Func("UseGDIP").Bind(GdipModule, GdipToken)}}
   }
   Else If (Params[1] = GdipModule) && (Params[2] = GdipToken)
      DllCall("Gdiplus.dll\GdiplusShutdown", "Ptr", GdipToken)
}
UseGDIP_Error(ErrorMsg) {
   MsgBox, 262160, UseGDIP, %ErrorMsg%
   ExitApp
}
