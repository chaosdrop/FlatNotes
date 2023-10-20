;Hotkey to open Library Window
Label1:
	if (U_Capslock = "1"){
		return
	}
	if (g1Open=1) {
		WinHide, FlatNotes - Library
		g1Open=0
		GUI, star:destroy
		GUI, t:destroy
		gosub Edit3SaveTimer
		return
	}
	if (g1Open=0) {
		MouseGetPos, xPos, yPos	
		xPos /= 1.5
		yPos /= 1.5
		if(StaticX != "" or StatricY != ""){
			xPos := StaticX
			yPos := StaticY
		}
		GuiControl,,%HSterm%, 
		WinMove, ahk_id %g1ID%, , %xPos%, %yPos%
		WinShow, ahk_id %g1ID%
		WinRestore, ahk_id %g1ID%
		WinActivate, ahk_id %g1ID%
		g1Open=1
		return
	}
return

;Hotkey to start a quicknote Win+N
Label2:
	MyOldClip := clipboard
	if (sendCtrlC="1")
		send {Ctrl Down}{c}{Ctrl up}
	MyClip := clipboard
	clipboard := MyOldClip
	MyClip := trim(MyClip)

	BuildGUI2()
	ControlFocus, Edit4, FlatNote - QuickNote

	GuiControl,, QuickNoteName,%MyClip%	
	
	FileSafeName := NameEncode(MyClip)
	IfExist, %U_NotePath%%FileSafeName%.txt
	{
		FileRead, MyFile, %U_NotePath%%FileSafeName%.txt
		IniRead, OldStarData, %detailsPath%%FileSafeName%.ini,INFO,Star
		OldStarData := ConvertStar(OldStarData)
		GuiControl,, QuickNoteBody,%MyFile%
		GuiControl,, QuickStar,%OldStarData%
		IniRead, OldCatData, %detailsPath%%FileSafeName%.ini,INFO,Cat
		GuiControl, ChooseString, QuickNoteCat, %OldCatData%
		
		IniRead, OldTagsData, %detailsPath%%FileSafeName%.ini,INFO,Tags
		GuiControl,, QuickNoteTags, %OldTagsData%
		IniRead, OldParentData, %detailsPath%%FileSafeName%.ini,INFO,Parent
		GuiControl,, QuickNoteParent, %OldParentData%
	}
return

;Hotkey to start a quicknote Win+M where the select is the body instead of the title / name.
Label3:
	MyOldClip := clipboard
	if (sendCtrlC="1")
		send {Ctrl Down}{c}{Ctrl up}
	MyClip := clipboard
	clipboard := MyOldClip
	MyClip := trim(MyClip)
	BuildGUI2()
	ControlFocus, Edit1, FlatNote - QuickNote
	GuiControl,, QuickNoteBody,%MyClip%	
return

;Hotkey to start a Rapid Note Win+z
Label4:
	MyOldClip := clipboard
	if(istitle != "no") {
		send {Ctrl Down}{c}{Ctrl up}
		ztitle := clipboard
		zbody := ""
		;only first line for title to prevent fail
		Loop, parse, clipboard, `n, `r
			{
				%A_Index%ztitle = %A_LoopField%
				if (A_Index = 2)
					break
			}
		;trim space and tab
		ztitle := Trim(1ztitle)
		IfExist, %U_NotePath%%ztitle%.txt
		{
			OnMessage(0x44, "OnMsgBox")
			MsgBox 0x40, Exits, A note with this name already exits.
			OnMessage(0x44, "")
			clipboard := MyOldClip
			return
		}
		
		istitle = no
		ztitleEncoded := NameEncode(ztitle)
		tooltip T: %ztitle%
		settimer, KillToolTip, -500
		clipboard := MyOldClip
		return
	}
	if(istitle = "no") {
		send {Ctrl Down}{c}{Ctrl up}
		zbody .= clipboard 
		istitle = yes
		FileReadLine, CheckExists, %U_NotePath%%TmpFileSafeName%.txt, 1
		SaveFile(ztitle,ztitleEncoded,zbody,0,"RapidNote",LastCatFilter,"")
		gosub search
		tooltip B: %zbody%
		settimer, KillToolTip, -500
		if (ShowStarOnRapidNoteSave != 1) {
			MouseGetPos, xPos, yPos
			xPos := xPos+25
			RapidStarNow = 1
			gosub build_StarEditBox
		}
	}
	clipboard := MyOldClip
return

;Hotkey to Cancel Rapid note taking.
Label5:
	istitle = yes
	tooltip canceled
	settimer,KillToolTip,-1000
return


;Hotkey to appened to a rapid note
Label6:
	MyOldClip := clipboard
	if(istitle = "no") {
		send {Ctrl Down}{c}{Ctrl up}
		zbody .= clipboard " " 
		tooltip B: %zbody%
		settimer, KillToolTip, -1000
	}
	clipboard := MyOldClip
return


;hotkey to append a template to a Rapid note.
Label7:
	RapidNTAppend = 1
	gosub NoteTemplateSelectUI
return

LabelS1:
	;Focus Search
	ControlFocus, Edit1, FlatNotes - Library
return

LabelS2:
	;Focus Results 
	ControlFocus, SysListView321, FlatNotes - Library
return

LabelS3:
	;Focus Edit
	ControlFocus, Edit3, FlatNotes - Library
return

LabelS4:
	gosub LibTemplateAdd
return

NewFromSearch:
	GuiControlGet,NewNoteFromSearch,,SearchTerm
	GuiControlget,CatFilter
	if (NewNoteFromSearch){
		TmpFileSafeName := NameEncode(NewNoteFromSearch)
		if FileExist(U_NotePath TmpFileSafeName ".txt") {
		
		Loop % LV_GetCount()
		{
			LV_GetText(RetrievedText, A_Index,2)
				if (RetrievedText==NewNoteFromSearch) {
					LV_Modify(A_Index, "Select Focus Vis")
				}
		}
			return
		}
		if (NewNoteFromSearch == ""){
		return
		}
		if (TmpFileSafeName == ""){
		return	
		}
		SaveFile(NewNoteFromSearch,TmpFileSafeName,"","","",CatFilter,"")
		
		
		NoteIniName := TmpFileSafeName ".ini"
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
		
		FormatTime, UserTimeFormatA, %C_Add%, %UserTimeFormat%
		FormatTime, UserTimeFormatM, %C_Mod%,%UserTimeFormat%
		
		LV_Insert(1,Focus Select,StarFieldArray ,NameField, NoteField, UserTimeFormatA,UserTimeFormatM,AddedField,ModdedField,A_LoopField,StarField,TagsField,CatField,ParentField,CheckedField,MarkedField,ExtraField)

		gosub, PreviewState

		GuiControl,,PreviewBox,
		GuiControl,,TagBox,
		GuiControl,,NoteParent,
		GuiControl,,TitleBar,%NewNoteFromSearch%
		GuiControl,,StatusbarM,M: %UserTimeFormatM%
		GuiControl,,StatusbarA,A: %UserTimeFormatA%
		
		
		GuiControl, Focus,PreviewBox
		
		LVSelectedROW = 1
	}
return

NewAndSaveHK:
ControlGetFocus, OutputVar, FlatNotes - Library
if (OutputVar = "Edit1" or OutputVar = "Edit2" or Outputvar = "ComboBox1"){
	GuiControlGet, SearchTerm
	
	GetCurrentNoteData(NameEncode(SearchTerm))

	BuildGUI2()
	
	;Fill in current data.
	GuiControl,, QuickNoteName,%SearchTerm%
	GuiControl,, FileSafeName,%C_SafeName%

	if FileExist(U_NotePath C_SafeName ".txt"){
		GuiControl,, QuickNoteBody,%C_File%
		GuiControl,, QuickStar,%C_Star%
		GuiControl,, QuickNoteTags,%C_Tags%
		GuiControl, ChooseString, QuickNoteCat, %C_Cat%
		GuiControl,, QuickNoteParent,%C_Parent%
	}else {
		GuiControl, ChooseString, QuickNoteCat, %LastCatFilter%

	}
		
	;Set UI focus:
	ControlFocus, Edit4, FlatNote - QuickNote 

	return
	}
if(OutputVar == "SysListView321"){
	/* OLD copy Name text by default
	global LVSelectedROW
	LV_GetText(RowText, LVSelectedROW,2)
	clipboard = %RowText%
	ToolTip Text: "%RowText%" Copied to clipboard
	*/
		LV_GetText(FileTmp, LVSelectedROW, 8)
		LV_GetText(ToolTipText, LVSelectedROW, 3)
		fileread,CopyText,%U_NotePath%%FileTmp%
		clipboard := CopyText
		Tooltip % ToolTipText "... Copied"
	
	SetTimer, KillToolTip, -500
	gosub GuiEscape
	return
}
if(OutputVar == "Edit6" or OutputVar == "Edit4" or OutputVar == "Edit5"){
	global LVSelectedROW
	if (LVSelectedROW="")
		LVSelectedROW=1
	LV_GetText(RowText, LVSelectedROW,2)
	LV_GetText(C_Cat, LVSelectedROW,11)
	FileSafeName := NameEncode(RowText)
	GuiControlGet, PreviewBox
	GuiControlGet, TagBox
	GuiControlGet, NoteParent
	SaveFile(RowText,FileSafeName,PreviewBox,1,TagBox,C_Cat,NoteParent)
	iniRead,OldAdd,%detailsPath%%FileSafeName%.ini,INFO,Add
	FileReadLine, NewBodyText, %U_NotePath%%FileSafeName%.txt,1
	LV_Modify(LVSelectedROW,,, RowText, NewBodyText,,,,,,,TagBox,,NoteParent)
	ToolTip Saved 
	SetTimer, KillToolTip, -500
	unsaveddataEdit3 = 0
	}
return

SaveButton:
	GuiControlGet,FileSafeName
	Gui, 2:Submit
	if (QuickNoteName == ""){
		;Old error message
		;MsgBox Note Name Can Not Be Empty
		;return
		
		;Use a timestamp if name is empty:
		AutoNameTimeFormat = yyyy-MM-dd hh:mm:sstt
		FormatTime, TimeString,, %AutoNameTimeFormat%
		FileSafeName := NameEncode(QuickNoteName)
		QuickNoteName := TimeString
		FileSafeName := NameEncode(QuickNoteName)
	}
	;QuickNoteName := trim(QuickNoteName)
	;FileSafeName := trim(FileSafeName)
	;convert used symbols to raw stars
	QuickStar := EncodeStar(QuickStar)

	Iniwrite, %QuickStar%, %detailsPath%%FileSafeName%.ini,INFO,Star
	SaveMod = 0
	IfExist, %U_NotePath%%FileSafeName%.txt
		SaveMod = 1
	SaveFile(QuickNoteName,FileSafeName,QuickNoteBody,SaveMod,QuickNoteTags,QuickNoteCat,QuickNoteParent)
	;horrible fix to LV to update

	GuiControlGet,OldST,,%HSterm%
	GuiControl,1: , SearchTerm,
	GuiControl,1: , SearchTerm,%OldST%
	tooltip Saved
	ControlSend, Edit1,{ctrl down} {a} {ctrl up}
	settimer, KillToolTip, -500
return

QuickSafeNameUpdate:
	GuiControlGet, QuickNoteName
	NewFileSafeName := NameEncode(QuickNoteName)
	GuiControl,, FileSafeName,%NewFileSafeName%
return

PreviewState:
	NoteCountCheck := LV_GetCount()
	if (NoteCountCheck == 0){
	GuiControl,+disabled ,PreviewBox
	GuiControl,+disabled ,MakeSticky
	GuiControl,+disabled ,StoreBookmark
	GuiControl,+disabled ,StoreClipboard
	GuiControl,+disabled ,StoreRun
	GuiControl,+disabled ,AddTemplateText
	}else{
	GuiControl,-disabled ,PreviewBox
	GuiControl,-disabled ,MakeSticky
	GuiControl,-disabled ,StoreBookmark
	GuiControl,-disabled ,StoreClipboard
	GuiControl,-disabled ,StoreRun
	GuiControl,-disabled ,AddTemplateText
	}
return

Search:
;event helper tools
;z := ":" A_GuiEvent ":" errorlevel ":"A_EventInfo "::" LV@sel_col "`n"
;tooltip % z
;settimer,KillToolTip,-1000

gosub, PreviewState

	SelectedRows :=
	if (unsaveddataEdit3 = 1)
		gosub Edit3SaveTimer
	global SearchTerm
	GuiControlGet, SearchTerm
	GuiControl, -Redraw, LV
	LV_Delete()
	If (SearchTerm == "")
		goto SkipToEndOfSearch
;Search a specific column by using a flag.		
	FlagSearch := RegExReplace(SearchTerm, "(.*?;;[a-zA-Z])","$1|",FlagCount)

	If (FlagCount != 0) {

		;msgbox % "f: " FlagSearch
		;FlagSearch looks like:: Kion;;n|Mirra;;n|
		FlagSearch := Trim(FlagSearch,"|")
		
		FlagBaseArray := StrSplit(FlagSearch, "|", "|")
		
		;msgbox % "base: "FlagBaseArray[1] " : " FlagBaseArray[2]
		;FlagBaseArray looks like ["Kion;;n,"Mirra;;n"]
		For x, FlagGroups in FlagBaseArray{
			FlagArray%x% := StrSplit(FlagGroups, ";;", ";;")
		}
		
		;msgbox % "FA:" FlagArray1[1] ":" FlagArray1[2]
		;Each FlagArray# looks like: [Kion,n]

		for x, FlagGroups in FlagBaseArray{
			if (FlagArray%x%[2] == "n")
				FlagArray%x%[2] := 2
			else if (FlagArray%x%[2] == "b")
				FlagArray%x%[2] := 3
			else if (FlagArray%x%[2] == "t")
				FlagArray%x%[2] := 10
			else if (FlagArray%x%[2] == "c")
				FlagArray%x%[2] := 11
			else if (FlagArray%x%[2] == "p")
				FlagArray%x%[2] := 12
			else
				FlagArray%x%[2] := 2
		}
		
		
		;msgbox % "test:" FlagArray1[2] FlagArray2[2]
		;FlagArray# now looks like: [Kion,3]


		;Flaggroup looks like: ["Kion;;n","Mirra Moon;;n"]
		;msgbox % FlagBaseArray[1]
		;msgbox % FlagArray1[1] " : " FlagArray2[1]
		;msgbox % FlagBaseArray.Length()
		
		;Do normal-ish search to populate the LV with the first search set:
		
		SearchTerm := RegExReplace(SearchTerm,";;.*")
		
		if (SubStr(SearchTerm,1,1) == ";")
			SearchArray := [SubStr(SearchTerm,2)]
		else
			SearchArray := StrSplit(SearchTerm , A_Space, A_Space)
	
		SearchTermsCount := SearchArray.Length()
		
		For Each, Note In MyNotesArray{
			SearchContent := Note[FlagArray1[2]]
			MatchedXTerms = 0
			
			For Each, Term in SearchArray{
				If (InStr(SearchContent, Term) != 0)
					MatchedXTerms++
				if (MatchedXTerms == SearchTermsCount) {
					gosub FoundSearchResult
					MatchedXTerms = 0
				}
			}
		}
		
		
		
		for x, FlagGroups in FlagBaseArray{
			FlagArray%x%[1] := trim(FlagArray%x%[1])
			SearchTermArray := StrSplit(FlagArray%x%[1],a_space,a_space)

			SearchTermsCount := SearchTermArray.Length()
			SearchCol := FlagArray%x%[2]

			
			;msgbox % SearchTermArray[1] " : " SearchTermArray[2] " : " SearchTermsCount " : " SearchCol
		
			Mloops := LV_GetCount()
			RemoveItem = false
			while (Mloops--)
			{
				LV_GetText(RowVar,Mloops+1,SearchCol)
				
				for k, v in SearchTermArray 
				{		
					if (!InStr(RowVar, v)){
						RemoveItem = true
						gosub SaveTimeDeletingLV
						break
					}
				}
				if (Mloops = 0)
					break
			}	
		}

	goto SkipToEndOfSearch
	}
	
	;if no flag than do a normal search which matches all search terms in any single column.
	if (SubStr(SearchTerm,1,1) == ";")
		SearchArray := [SubStr(SearchTerm,2)]
	else
		SearchArray := StrSplit(SearchTerm , A_Space, A_Space)
	
	
	SearchTermsCount := SearchArray.Length()
		
	For Each, Note In MyNotesArray{
		SearchContent := Note[2] " " Note[3] " " Note[10] " " Note[11]
		MatchedXTerms = 0
		
		For Each, Term in SearchArray{
			If (InStr(SearchContent, Term) != 0)
				MatchedXTerms++
			if (MatchedXTerms == SearchTermsCount) {
				gosub FoundSearchResult
				MatchedXTerms = 0
			}
		}
	}
	
SkipToEndOfSearch:
	If (SearchTerm == ""){
		For Each, Note In MyNotesArray
		{
			gosub FoundSearchResult
		}
	}	
	gosub SortNow
	gosub SearchFilter
	gosub CatFilter
	gosub TagsFilter
	gosub UpdateStatusBar
	if (ClipFilterActive == 1){
		gosub FilterClipSearch
	}
	if (BookmarkFilterActive == 1){
		gosub FilterBookmarkSearch
	}
	if (ScriptFilterActive == 1){
		gosub FilterScriptSearch
	}
	if (ScriptFilterActive == 2){
		TypeBUpdate = 0
		gosub FilterScriptSearch
	}
	gosub, PreviewState
Return

FoundSearchResult:
	LV_Add("", Note.1, Note.2,Note.3,Note.4,Note.5,Note.6,Note.7,Note.8,Note.9,Note.10,Note.11,Note.12,Note.13,Note.14,Note.15,Note.16,Note.17,Note.18)
Return


SearchFilter:
	global SearchFilter
	GuiControlGet, SearchFilter,, %HSF%
	if (SearchFilter != "")
	{
		Mloops := LV_GetCount()
		while (Mloops--)
		{
			LV_GetText(RowVar,Mloops+1,1)
			if (RowVar != SearchFilter)
				LV_Delete(Mloops+1)
			if (Mloops = 0)
				break
		}	
	}
return

CatFilter:
	GuiControlGet, CatFilter,, %HCF%
	GuiControlGet, LastCatFilter,, %HCF%
	
	if (CatFilter != "")
	{
		Mloops := LV_GetCount()
		while (Mloops--)
		{
			LV_GetText(RowVar,Mloops+1,11)
			if (RowVar != CatFilter)
				LV_Delete(Mloops+1)
			if (Mloops = 0)
				break
		}	
	}
return

TagsFilter:
	GuiControlGet, TagsFilter,, %HTF%
	GuiControlGet, LastTagsFilter,, %HTF%
	
	if (TagsFilter != "")
	{
		TagsSearched := StrSplit(TagsFilter," ")
		
		Mloops := LV_GetCount()
		RemoveItem = false
		while (Mloops--)
		{
			LV_GetText(RowVar,Mloops+1,10)
			for k, v in TagsSearched 
			{
				if (!RegExMatch(RowVar,"i)^" v "\s|\s" v "\s|" v "$"))
				{
					RemoveItem = true
					gosub SaveTimeDeletingLV
					break
				}
			}
			if (Mloops = 0)
				break
		}	
	}
return

SaveTimeDeletingLV:
	LV_Delete(Mloops+1)
	RemoveItem = false
return
UpdateStatusBar:
	Items := LV_GetCount()
	if (Items != 0) {
		LV_GetText(LastResultName, 1 , 2)
		LV_GetText(LastFileName, 1 , 8)
		LV_GetText(LastNoteAdded, 1 , 4)
		LV_GetText(LastNoteModded, 1 , 5)
		LV_GetText(LastNoteTags, 1 , 10)
		LV_GetText(LastNoteParent, 1 , 12)
		;LV_GetText(LastNoteCat, 1 , 11)
		GuiControl,,TitleBar, %LastResultName%
		IniName := RegExReplace(LastFileName, "\.txt(?:^|$|\r\n|\r|\n)", Replacement := ".ini")

		;update top status bar
		Iniread, HasBookmark,%detailsPath%%IniName%, INFO,Bookmark
		if (HasBookmark == 1){
			GuiControl,text,StoreBookmark, %BookmarkSymbol%
		} else {
			GuiControl,text,StoreBookmark, %LinkSymbol%
		}
		Iniread, HasClip,%detailsPath%%IniName%, INFO,Clip
		if (HasClip == 1){
			GuiControl,text,StoreClipboard, %SaveSymbol%
		}else {
			GuiControl,text,StoreClipboard, %DiskSymbol%
		}
		Iniread, RunType,%detailsPath%%IniName%,INFO,RunType
		if (RunType == "AHK"){
			GuiControl,text,StoreRun, %TypeAIcon%
		}else if (RunType == "BAT"){
			GuiControl,text,StoreRun, %TypeBIcon%
		}else {
			GuiControl,text,StoreRun, %RunIcon%
		}
		
		FileRead, LastResultBody,%U_NotePath%%LastFileName%
		LastNoteIni := RegExReplace(LastFileName, "\.txt(?:^|$|\r\n|\r|\n)", Replacement := ".ini")

		GuiControl,,PreviewBox, %LastResultBody%
		GuiControl,,TagBox, %LastNoteTags%
		GuiControl,,NoteParent, %LastNoteParent%
		;GuiControl, ChooseString, CatBox, %LastNoteCat%
		GuiControl,, StatusbarM,M: %LastNoteModded%
		GuiControl,, StatusbarA,A: %LastNoteAdded%
		}else{
			GuiControl,,TitleBar, 
			GuiControl,,PreviewBox,
			GuiControl,,TagBox,
			;GuiControl, ChooseString, CatBox,
			GuiControl,,NoteParent,
			GuiControl,,StatusBarM,M: 00\00\00 
			GuiControl,,StatusBarA,A: 00\00\00
		}
	GuiControl,,StatusBarCount, %Items%
	GuiControl, +Redraw, LV
return


KillToolTip:
   ToolTip
Return


UnDoom:
	Doom = 0
return



NoteListView:
Critical
;z := ":" A_GuiEvent ":" errorlevel ":";A_EventInfo ":" LV@sel_col "`n"
;tooltip % z
;tooltip % x
;settimer,KillToolTip,-1000

;tooltip % LV@sel_col
;Track Selected
if (InStr(ErrorLevel, "S", true))
{
	SelectedRows .= A_EventInfo " "
	;tooltip % SelectedRows
	settimer,KillToolTip,-1000
	
}

if (InStr(ErrorLevel, "s", true))
{
	SelectedRows := RegExReplace(SelectedRows,"\b" A_EventInfo " ","")
	;tooltip % SelectedRows
	settimer,KillToolTip,-1000
}

;tooltip % SelectedRows
;settimer,KillToolTip,-1000
if (WinActive(FlatNote - Library)) {
	if (tNeedsSubmit = 1) {
		tNeedsSubmit = 0
		gosub TitleSaveChange
	}
	if (sNeedsSubmit = 1) {
		sNeedsSubmit = 0
		gosub StarSaveChange
	}
	gui, sb:destroy
}
if (ListTitleToChange = 1){
		LV_Modify(LVSelectedROW,,, NewTitle,,,,,,NewTitleFileName)
		GuiControl,,TitleBar,%NewTitle%
		ListTitleToChange = 0
		TitleOldFile := ""
	}
if (ListStarToChange = 1){
		LV_Modify(LVSelectedROW,,NewStar,,,,,,,,NewStar)
		ListStarToChange = 0
	}
if (ListNeedsRefresh = 1){
		gosub search
		ListNeedsRefresh = 0
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
	if (LV@sel_col=2 or LV@sel_col=4 or LV@sel_col=5 or LV@sel_col=10 or LV@sel_col=11 or LV@sel_col=12) {
		LV_GetText(CopyText, A_EventInfo, LV@sel_col)
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
	if (LV@sel_col=16) {
		gosub RunStoredCommand
		Tooltip % ToolTipText "Running Script..."
	}
	if (LV@sel_col=17) {
		gosub RestoreClipboard
		Tooltip % ToolTipText "Clipboard Loaded"
	}
	if (LV@sel_col=18) {
		gosub GotoBookmark
		Tooltip % ToolTipText "Opening Link..."
	}

	settimer,KillToolTip, -500
    return
}
if (A_GuiEvent = "I")
{
	
}
;update the preview
if (A_GuiEvent = "I" && InStr(ErrorLevel, "S", true))
{
	LVSelectedROW := A_EventInfo
	SetTimer, UpdateLVSelected, -250
}
;1Star|2Title|3Body|4Added|5Modified|6RawAdded|7RawModded|8FileName|9RawStar|10Tags|11Cat|12Parent|12Checked|13Marked|14Extra

	if A_GuiEvent in Normal
	{
		LV_GetText(StarOldFile, LVSelectedROW,8)
		LV_GetText(TitleOldFile, LVSelectedROW,8)
		if (LV@sel_col=1) {
			LV_GetText(CurrentStar, A_EventInfo, 9)
			if (CurrentStar !=A_Space and CurrentStar !=10000 and CurrentStar !=10001 and CurrentStar !=10002 and CurrentStar !=10003 and CurrentStar !=10004 and CurrentStar !=""){
				clipboard := 
				MsgBox, 4,, Clear Unique Star? (press Yes or No)
					IfMsgBox Yes 
						CurrentStar = 10004
					else{
						LV@sel_col = "undoomCol1"
						return
					}						
			}
			LV_GetText(C_FileName, A_EventInfo, 8)
			LV_GetText(C_Name, A_EventInfo, 2)
			LV_GetText(C_Tags, A_EventInfo, 10)
			LV_GetText(C_Cat, A_EventInfo, 11)
			LV_GetText(C_Parent, A_EventInfo, 12)
			C_ini := RegExReplace(C_FileName, "\.txt(?:^|$|\r\n|\r|\n)", Replacement := ".ini")
			C_SafeName := RegExReplace(C_FileName, "\.txt(?:^|$|\r\n|\r|\n)")
			If CurrentStar not between 10000 and 10004
				CurrentStar = 10000
			if (NextStar = 10005)
				NextStar = 10000
			if (CurrentStar = 10005)
				CurrentStar = 10000
			NextStar := CurrentStar+1
			if (CurrentStar=10004)
				NextStar=10000
			if (NextStar=10001)
				UpdateStar:=Star1
			if (NextStar=10002)
				UpdateStar:=Star2
			if (NextStar=10003)
				UpdateStar:=Star3
			if (NextStar=10004)
				UpdateStar:=Star4
			if (NextStar=10000)
				UpdateStar:=A_Space
			
				
			LV_Modify(A_EventInfo ,,UpdateStar,,,,,,,,NextStar)
			IniWrite, %NextStar%, %detailsPath%%C_ini%, INFO, Star
			fileRead, C_Body, %U_NotePath%%C_FileName%
			SaveFile(C_Name,C_SafeName,C_Body,1,C_Tags,C_Cat,C_Parent)	
			LV@sel_col = "undoomCol1"
		}
	}
	; change star on space
	if (A_GuiEvent = "K" and A_EventInfo = "32") {
		LV_GetText(CurrentStar, LastRowSelected, 9)
		LV_GetText(C_FileName, LastRowSelected, 8)
		LV_GetText(C_Name, LastRowSelected, 2)
		LV_GetText(C_Tags, LastRowSelected, 2)
		LV_GetText(C_Cat, LastRowSelected, 2)
		LV_GetText(C_Parent, LastRowSelected, 2)

		if (CurrentStar !=A_Space and CurrentStar !=10000 and CurrentStar !=10001 and CurrentStar !=10002 and CurrentStar !=10003 and CurrentStar !=10004){
				MsgBox, 4,, Clear Unique Star? (press Yes or No)
					IfMsgBox Yes 
						CurrentStar = 10004
					else{
						LV@sel_col = "undoomCol1"
						return
					}	
			}
			C_ini := RegExReplace(C_FileName, "\.txt(?:^|$|\r\n|\r|\n)", Replacement := ".ini")
			C_SafeName := RegExReplace(C_FileName, "\.txt(?:^|$|\r\n|\r|\n)")
			If CurrentStar not between 10000 and 10004
				CurrentStar = 10000
			NextStar := CurrentStar+1
			if (NextStar = 10005)
				NextStar = 10000
			if (CurrentStar = 10005)
				CurrentStar = 10000
			if (CurrentStar=10004)
				NextStar=10000
			if (NextStar=10001)
				UpdateStar:=Star1
			if (NextStar=10002)
				UpdateStar:=Star2
			if (NextStar=10003)
				UpdateStar:=Star3
			if (NextStar=10004)
				UpdateStar:=Star4
			if (NextStar=10000)
				UpdateStar:=A_Space
			
			
		LV_Modify(LastRowSelected,,UpdateStar,,,,,,,,NextStar)
		IniWrite, %NextStar%, %detailsPath%%C_ini%, INFO, Star
		fileRead, C_Body, %U_NotePath%%C_FileName%
		SaveFile(C_Name,C_SafeName,C_Body,1,C_Tags,C_Cat,C_Parent)	
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
	
	;1Star|2Title|3Body|4Added|5Modified|6RawAdded|7RawModded|8FileName|9RawStar|10Tags|11Cat|12Parent|12Checked|13Marked|14Extra
	
	if (A_GuiEvent == "RightClick" OR TriggedFromSK == 1)
	{
		LVSelectedROW := A_EventInfo
		LV_GetText(NoteNameToEdit, LVSelectedROW,2)
		LV_GetText(StarOldFile, LVSelectedROW,8)
		LV_GetText(TitleOldFile, LVSelectedROW,8)
		if (LV@sel_col == 2) {
			MouseGetPos, xPos, yPos
			xPos := xPos+25
			gosub build_tEdit
			return
		}
		if (LV@sel_col == 1) {
			;SelectedRowsStarTmp := trim(SelectedRows)
			SelectedRowsArray := StrSplit(SelectedRows," "," ")
			;msgbox % SelectedRowsArray.Length() " :: "
			if (SelectedRowsArray.Length() <= 2){
				MouseGetPos, xPos, yPos
				xPos := xPos+25
				ColEditStar = 0
				gosub build_StarEditBox
				LV@sel_col = "undoomCol1"
				return
			}
		}
		if (LV@sel_col == 1 or LV@sel_col == 3 or LV@sel_col == 10 or LV@sel_col == 11 or LV@sel_col == 12)
		{
			MouseGetPos, xPos, yPos
			xPos := xPos+25
	
			ColEditName :=  ColList[LV@sel_col]
			gosub build_ColEdit
			return
		}
		if (LV@sel_col == 16) {
			RC16 = 1
			goto GuiContextMenu
		}
		if (LV@sel_col == 17) {
			RC17 = 1
			goto GuiContextMenu
		}
		if (LV@sel_col == 18) {
			RC18 = 1
			goto GuiContextMenu
		}
	}
return


UpdateLVSelected:

	LV_GetText(StarOldFile, LVSelectedROW,8)
	LV_GetText(TitleOldFile, LVSelectedROW,8)
	LV_GetText(tOldFile, LVSelectedROW,8)
    LV_GetText(RowText, LVSelectedROW,8)
	LV_GetText(C_Added, LVSelectedROW,4)
    LV_GetText(C_Modded, LVSelectedROW,5)
	LV_GetText(C_Name, LVSelectedROW,2)
	LV_GetText(C_Tags, LVSelectedROW,10)
	LV_GetText(C_Parent, LVSelectedROW,12)
	;LV_GetText(C_Cat, A_EventInfo,11)
    FileRead, NoteFile, %U_NotePath%%RowText%
	GuiControl,, PreviewBox, %NoteFile%
	GuiControl,, TagBox, %C_Tags%
	GuiControl,, NoteParent, %C_Parent%
	;GuiControl, ChooseString, CatBox, %C_Cat%
	GuiControl,, TitleBar, %C_Name%
	GuiControl,, StatusbarM,M: %C_Modded%
	GuiControl,, StatusbarA,A: %C_Added%
	
	;check to see if clipboard exist and change icon accordingly.
	FileSafeName := NameEncode(C_Name)
	HasBookmark := a_space
	Iniread,	 HasBookmark,%detailsPath%%FileSafeName%.ini, INFO,Bookmark
	if (HasBookmark == 1){
		GuiControl,text,StoreBookmark, %BookmarkSymbol%
	} else {
		GuiControl,text,StoreBookmark, %LinkSymbol%
	}
	Iniread, HasClip,%detailsPath%%FileSafeName%.ini, INFO,Clip
	if (HasCLip == 1){
		GuiControl,text,StoreClipboard, %SaveSymbol%
	}else {
		GuiControl,text,StoreClipboard, %DiskSymbol%
	}
	Iniread, RunType, %detailsPath%%FileSafeName%.ini,INFO,RunType
	if (RunType == "AHK"){
		GuiControl,text,StoreRun, %TypeAIcon%
	}else if (RunType == "BAT"){
		GuiControl,text,StoreRun, %TypeBIcon%
	}else {
		GuiControl,text,StoreRun, %RunIcon%
	}
	

return

;GUI for right click to edit name
build_tEdit:
	GUI, t:new, ,InlineNameEdit
	Gui, t:Margin , 5, 5 
	Gui, t:Font, s%SearchFontSize% Q%FontRendering%, %SearchFontFamily%, %U_MFC%
	Gui, t:Color,%U_SBG%, %U_MBG%	

	gui, t:add,text,w100 -E0x200 center c%U_SFC%,New Name
	Gui, t:add,edit,w100 -E0x200 c%U_FBCA% vtEdit
	gui, t:add,button, default gTitleSaveChange x-10000 y-10000
	WinSet, Style,  -0xC00000,InlineNameEdit
	GUI, t:Show, x%xPos% y%yPos%
	tNeedsSubmit = 1
return

;GUI for Shortcut key to edit name
build_SKNameEdit:
	GUI, skne:new, ,SKNameEditor
	Gui, skne:Margin , 5, 5 
	Gui, skne:Font, s%SearchFontSize% Q%FontRendering%, %SearchFontFamily%, %U_MFC%
	Gui, skne:Color,%U_SBG%, %U_MBG%	

	gui, skne:add,text,w100 -E0x200 center c%U_SFC%,New Name
	Gui, skne:add,edit,w100 -E0x200 c%U_FBCA% vSKNameEdit
	gui, skne:add,button, default gSKTitleSaveChange x-10000 y-10000
	WinSet, Style,  -0xC00000,SKNameEditor
	
	WinGetPos, xPos, yPos,clibW,clibH,FlatNotes - Library
	xPos := clibw / 3 + xPos
	yPos := clibH / 3 + yPos
	
	GUI, skne:Show, x%xPos% y%yPos%
	tNeedsSubmit = 1
	
	ControlFocus,Edit1,SKNameEditor

return

TitleSaveChange:
	GUI, t:Submit
	NewTitle = %tEdit%
	goto SaveNewName

SKTitleSaveChange:
	GUI, skne:Submit
	NewTitle = %SKNameEdit%
	goto SaveNewName
	
SaveNewName:
		tNeedsSubmit = 0
	if (NewTitle = ""){
		ListTitleToChange = 0
		TitleOldFile := ""
		return
	}
	FileSafeName :=NameEncode(NewTitle)
	OldIniName := RegExReplace(TitleOldFile, "\.txt(?:^|$|\r\n|\r|\n)", Replacement := ".ini")
	NewIniName = %FileSafeName%.ini
	NewTitleFileName = %FileSafeName%.txt
	FileRead, C_Body,%U_NotePath%%TitleOldFile%
	
	if FileExist(U_NotePath NewTitleFileName){
		MsgBox, A note with this name already exists.
		tNeedsSubmit = 0
		ListTitleToChange = 0
		TitleOldFile := ""
		return
	}
	if (LVSelectedROW=""){
		msgbox Name Save Error 1
		tNeedsSubmit = 0
		ListTitleToChange = 0
		TitleOldFile := ""
		return
		}
	if (NewIniName=""){
		msgbox Name Save Error 2
		tNeedsSubmit = 0
		ListTitleToChange = 0
		TitleOldFile := ""
		return
		}
	if (OldIniName=""){
		msgbox Name Save Error 3
		tNeedsSubmit = 0
		ListTitleToChange = 0
		TitleOldFile := ""
		return
		}
	FileMove, %detailsPath%%OldIniName%, %detailsPath%%NewIniName%
	FileMove, %U_NotePath%%TitleOldFile%, %U_NotePath%%FileSafeName%.txt
	
	for Each, Note in MyNotesArray{
			If (Note.8 = TitleOldFile){
				MyNotesArray.RemoveAt(Each)
			}
		}
	Iniread, TmpTags,%detailsPath%%NewIniName%, INFO,Tags
	Iniread, TmpCat,%detailsPath%%NewIniName%, INFO,Cat
	Iniread, TmpParent,%detailsPath%%NewIniName%, INFO,Parent
	
	;FileRecycle, %detailsPath%%C_ini%%tOldFile%
	SaveFile(NewTitle,FileSafeName,C_Body,1,TmpTags,TmpCat,TmpParent)
	ListTitleToChange = 1
	ControlFocus , Edit1, FlatNotes - Library
	TitleOldFile := ""
return

;GUI to edit note details via shortcut key from the main window.
build_SKColEdit:
	Opt1 := [0, U_SBG, ,U_SFC]
	GUI, skce:new, ,SKEditor
	Gui, skce:Margin , 5, 5 
	Gui, skce:Font, s%SearchFontSize% Q%FontRendering%, %SearchFontFamily%, %U_MFC%
	Gui, skce:Color,%U_SBG%, %U_MBG%
	if (LV@sel_col != 1)
		gui, skce:add,text,w200 -E0x200 center c%U_SFC%,Replace %ColEditName% with:
	
	if (LV@sel_col == 1){
		Gui, skce:add, button,w200 section gbuild_StarEditBox hwndHIB2, [ Star Selector ]
		ColEditStar = 1
		If !ImageButton.Create(HIB2, Opt1)
		MsgBox, 0, ImageButton Error IB1, % ImageButton.LastError
	}
	if (LV@sel_col == 3)
		ColEditRows = 5
	else
		ColEditRows = 1
	if (LV@sel_col == 11){
		Gui, skce:add,DDL,w200 -E0x200 c%U_FBCA% vskceEdit hwndSKceDDL r6, %CatBoxContents%
		
		;Listbox color
		DDLbgColorb2 := strreplace(U_MBG,"0x")
		DDLfontColorb2 := strreplace(U_MFC,"0x")
		CtlColors.Attach(SKceDDL, DDLbgColorb2,DDLfontColorb2)
		OD_Colors.Attach(SKceDDL, {T: U_MFC})
	}
	else 
		Gui, skce:add,edit,w200 -E0x200 c%U_FBCA% vskceEdit r%ColEditRows% hwndSKceEDIT
	
		
	gui, skce:add,button, default gSKColEditSaveChange w200 hwndSKIB1 vIB1, [ Apply ]
	
	If !ImageButton.Create(SKIB1, Opt1)
		MsgBox, 0, ImageButton Error IB1, % ImageButton.LastError
	
	
	WinSet, Style,  -0xC00000,SKEditor
	if (HideScrollbars = 1) {
		LVM_ShowScrollBar(SKceEDIT,1,False)
		GuiControl,+Vscroll,%SKceEDIT%
	}
	
	WinGetPos, xPos, yPos,clibW,clibH,FlatNotes - Library
	xPos := clibw / 3 + xPos
	yPos := clibH / 3 + yPos
	
	GUI, skce:Show, x%xPos% y%yPos%
	
	ControlFocus,Edit1,SKEditor
return


;Save function for Shortcut column editor.

SKColEditSaveChange:
if (LV@sel_col == 1){
		OnMessage(0x44, "OnMsgBox")
		MsgBox 0x40024, Change Stars?, WARNING - All stars will be replace by unique stars. Are you sure you want to continue?
		OnMessage(0x44, "")
		IfMsgBox Yes, {
			goto YesChangeStarsSk
		} Else IfMsgBox No, {
			return
		}
}
YesChangeStarsSk:
GuiControlGet, skceEdit ;get the new data
ColVarName := CurrentCol[LV@sel_col]
tmpColNum = Col%LV@sel_col%
Gui, 1:Default 
TmpSelectedRows := trim(SelectedRows)
SelectedRowsArray := StrSplit(TmpSelectedRows," "," ")
ChangeCount := SelectedRowsArray.Length()
SelectedRowsArray:=ObjectSort(SelectedRowsArray,,,false)
	;v = row numbers
	for RowKey, CRowNum in SelectedRowsArray{
		LV_GetText(tmpName,CRowNum,8)
		
		tmpName := strreplace(tmpName,".txt",".ini")
		Iniread, tmpName,%detailsPath%%tmpName%, INFO,Name
		tmpname := strreplace(tmpName,"$#$")
		C_SafeName := NameEncode(tmpName)
		if (CRowNum !=3)
			GetFile = false ;don't get the body
		GetCurrentNoteData(C_SafeName)
		;Error Check
		if !FileExist( U_NotePath C_SafeName ".txt"){
			Msgbox % "Error Code SKE#001: `n" U_NotePath C_SafeName ".txt Does Not Exist"
			
			break
		}
		;change what changed...
		%ColVarName% := skceEdit
		;save the new data
		if (LV@sel_col == 1)
		{
			IniWrite, %C_Star%, %detailsPath%%C_SafeName%.ini, INFO, Star
		}
		SaveFile(C_Name,C_SafeName,C_File,1,C_Tags,C_Cat,C_Parent)
		LV_Modify(CRowNum,tmpColNum,skceEdit)
		LV_Modify(CRowNum, "Select")
		tooltip, processing %RowKey% of %ChangeCount%


	}
		GuiControl,, PreviewBox, %C_File%
		GuiControl,, TagBox, %C_Tags%
		GuiControl,, NoteParent, %C_Parent%
		GuiControl,, TitleBar, %C_Name%
		GuiControl,, StatusbarM,M: %C_Mod%
		GuiControl,, StatusbarA,A: %C_Add%
		;SelectedRows :=
		;LV_Modify(CRowNum, "Select")
		settimer,KillToolTip,-1000

	gui, skce:destroy

return

;GUI for right click col 10-12 for now and doing bulk operations.
build_ColEdit:
	color1 = %U_SBG%
	color2 = %U_SFC%
	Opt1 := [0, color1, ,color2]
	GUI, ce:new, ,InlineNameEdit
	Gui, ce:Margin , 5, 5 
	Gui, ce:Font, s%SearchFontSize% Q%FontRendering%, %SearchFontFamily%, %U_MFC%
	Gui, ce:Color,%U_SBG%, %U_MBG%
	if (LV@sel_col != 1)
		gui, ce:add,text,w200 -E0x200 center c%U_SFC%,Replace %ColEditName% with:
	
	if (LV@sel_col == 1){
		Gui, ce:add, button,w200 section gbuild_StarEditBox hwndHIB2, [ Star Selector ]
		ColEditStar = 1
		If !ImageButton.Create(HIB2, Opt1)
		MsgBox, 0, ImageButton Error IB1, % ImageButton.LastError
	}
	if (LV@sel_col == 3)
		ColEditRows = 5
	else
		ColEditRows = 1
	if (LV@sel_col == 11){
		Gui, ce:add,DDL,w200 -E0x200 c%U_FBCA% vceEdit hwndHceDDL r6, %CatBoxContents%
		
		;Listbox color
		DDLbgColorb2 := strreplace(U_MBG,"0x")
		DDLfontColorb2 := strreplace(U_MFC,"0x")
		CtlColors.Attach(HceDDL, DDLbgColorb2,DDLfontColorb2)
		OD_Colors.Attach(HceDDL, {T: U_MFC})
	}
	else 
		Gui, ce:add,edit,w200 -E0x200 c%U_FBCA% vceEdit r%ColEditRows% hwndHceEDIT
	
	gui, ce:add,button, default gColEditSaveChange w200 hwndHIB1 vIB1, [ Apply ]
	
	If !ImageButton.Create(HIB1, Opt1)
		MsgBox, 0, ImageButton Error IB1, % ImageButton.LastError
	
	WinSet, Style,  -0xC00000,InlineNameEdit
	if (HideScrollbars = 1) {
		LVM_ShowScrollBar(HceEDIT,1,False)
		GuiControl,+Vscroll,%HceEDIT%
	}
	GUI, ce:Show, x%xPos% y%yPos%
	
	;figure out why I need this->
	;tNeedsSubmit = 1
return


ColEditSaveChange:
if (LV@sel_col == 1){
		OnMessage(0x44, "OnMsgBox")
		MsgBox 0x40024, Change Stars?, WARNING - All stars will be replace by unique stars. Are you sure you want to continue?
		OnMessage(0x44, "")
		IfMsgBox Yes, {
			goto YesChangeStars
		} Else IfMsgBox No, {
			return
		}
}
YesChangeStars:
GuiControlGet, ceEdit ;get the new data
ColVarName := CurrentCol[LV@sel_col]
tmpColNum = Col%LV@sel_col%

Gui, 1:Default 
TmpSelectedRows := trim(SelectedRows)
SelectedRowsArray := StrSplit(TmpSelectedRows," "," ")
ChangeCount := SelectedRowsArray.Length()
SelectedRowsArray:=ObjectSort(SelectedRowsArray,,,false)
	;v = row numbers
	for RowKey, CRowNum in SelectedRowsArray{
		LV_GetText(tmpName,CRowNum,2)
		C_SafeName := NameEncode(tmpName)		
		if (CRowNum !=3)
			GetFile = false ;don't get the body
		GetCurrentNoteData(C_SafeName)
		;Error Check
		if !FileExist( U_NotePath C_SafeName ".txt"){
			Msgbox % "Error Report Code FNF#001 Details: `n" U_NotePath C_SafeName ".txt" " SelectedRows:" SelectedRows " Name: " tmpName " RowNum:" CRowNum
			
			break
		}
		;change what changed...
		%ColVarName% := ceEdit
		;save the new data
		if (LV@sel_col == 1)
		{
			IniWrite, %C_Star%, %detailsPath%%C_SafeName%.ini, INFO, Star
		}
		SaveFile(C_Name,C_SafeName,C_File,1,C_Tags,C_Cat,C_Parent)
		LV_Modify(CRowNum,tmpColNum,ceEdit)
		LV_Modify(CRowNum, "Select")
		tooltip, processing %RowKey% of %ChangeCount%


	}
		GuiControl,, PreviewBox, %C_File%
		GuiControl,, TagBox, %C_Tags%
		GuiControl,, NoteParent, %C_Parent%
		GuiControl,, TitleBar, %C_Name%
		GuiControl,, StatusbarM,M: %C_Mod%
		GuiControl,, StatusbarA,A: %C_Add%
		;SelectedRows :=
		;LV_Modify(CRowNum, "Select")
		settimer,KillToolTip,-1000

	gui, ce:destroy

return

;Make a list of all used stars - all user set stars.
MakeOOKStarList:
	Loops := LV_GetCount()
	GuiControlGet,SearchFilterState,,%HSF%
	if (SearchFilterState ="") {
		OOKStars := ""
		loop % loops {
				LV_GetText(starz,A_index,1)
				OOKStars .= starz "|"
		}
		OOKStars := StrReplace(OOKStars,Star1,"")
		OOKStars := StrReplace(OOKStars,Star2,"")
		OOKStars := StrReplace(OOKStars,Star3,"")
		OOKStars := StrReplace(OOKStars,Star4,"")
		OOKStars := RemoveDups(OOKStars,"|")
		OOKArr := StrSplit(OOKStars,"|","|")
		NewOOKStars := ""
		AllMyStarsList := UniqueStarList "|" UniqueStarList2
		if (AllMyStarsList != "|") {
			for k, v in OOKArr
				if (InStr(AllMyStarsList,v) !=0)
					Continue
				else
					NewOOKStars .= v "|"
		}
		sort NewOOKStars, D|
		NewOOKStars :=  Trim(NewOOKStars,"|")
		OOKStars := StrReplace(NewOOKStars,"||","|")
	}
return


StarFilterBox:
	gosub MakeOOKStarList
	; var with all used stars = UsedStars
	GUI, sb:new,-Caption +ToolWindow +hWndHSEB2,StarPicker
	Gui, sb:Margin , 5, 5 
	Gui, sb:Font, s10 Q%FontRendering%, Verdana, %U_MFC%
	Gui, sb:Color,%U_SBG%, %U_MBG%
	
	if (OOKStars > 0) {
		Gui, sb:add,ListBox, hwndHStarBox1 c%U_FBCA% -E0x200 r%USSLR% w35 gDo_ApplyStarFilter vStarFilter,%OOKStars%
		Gui, sb:add,ListBox, hwndHStarBox2 c%U_FBCA% -E0x200 r%USSLR% x+5 w35 gDo_ApplyStarFilter vStarFilter2,|%Star1%|%Star2%|%Star3%|%Star4%
	}else
		Gui, sb:add,ListBox, hwndHStarBox2 c%U_FBCA% -E0x200 r%USSLR% w35 gDo_ApplyStarFilter vStarFilter2,|%Star1%|%Star2%|%Star3%|%Star4%
	if (UniqueStarList > 0)
		Gui, sb:add,ListBox, hwndHStarBox3 x+5 c%U_FBCA% -E0x200 r%USSLR% w35 gDo_ApplyStarFilter vStarFilter3, %UniqueStarList%
	if (UniqueStarList2 > 0)
		Gui, sb:add,ListBox, hwndHStarBox4 x+5 c%U_FBCA% -E0x200 r%USSLR% w35 gDo_ApplyStarFilter vStarFilter4, %UniqueStarList2%
	
	MouseGetPos, xPos, yPos
	xPos := xPos+25
	
	if (HideScrollbars = 1) {
		LVM_ShowScrollBar(HStarBox1,1,False)
		GuiControl,+Vscroll,%HStarBox1%
		LVM_ShowScrollBar(HStarBox2,1,False)
		GuiControl,+Vscroll,%HStarBox2%
		LVM_ShowScrollBar(HStarBox3,1,False)
		GuiControl,+Vscroll,%HStarBox3%
		LVM_ShowScrollBar(HStarBox4,1,False)
		GuiControl,+Vscroll,%HStarBox4%
	}
	Gui, sb:show, x%xPos% y%yPos%
	SetTimer, GuiTimerSB
return

Do_ApplyStarFilter:
	Gui sb:Submit
	if (StarFilter="")
		StarFilter:=StarFilter2
	if (StarFilter="")
		StarFilter:=StarFilter3
	if (StarFilter="")
		StarFilter:=StarFilter4
	GuiControl,,%HSF%,%StarFilter%
	GuiControlGet,Old_Sterm,,%HSterm%
	GuiControl,,%HSterm%
	GuiControl,,%HSterm%, %Old_Sterm%
	StarFilter := ""
	StarFilter2 := ""
	StarFilter3 := ""
	StarFilter4 := ""
return


build_StarEditBox:
	gosub MakeOOKStarList
	GUI, star:new, +hWndHSEB ,TMPedit001
	Gui, star:Margin , 5, 5 
	Gui, star:Font, s10 Q%FontRendering%, %ResultFontFamily%, %U_MFC%
	Gui, star:Color,%U_SBG%, %U_MBG%	
	;gui, star:add,text, w35 -E0x200 center c%U_SFC%,Star
	Gui, star:add,edit, x+1 y+6 c%U_FBCA% w35 -E0x200 vsEdit
	gui, star:add,text, x+2 w35 yp+3 -E0x200 center c%U_SFC% gStarSaveChange ,Apply
	Gui, star:add,ListBox, HwndHStarEditBox1 xs section c%U_FBCA% -E0x200 r%USSLR% w35 gStarSaveChange vStarSelectedBox, %UniqueStarList%
	if (UniqueStarList2 > 0)
		Gui, star:add,ListBox, HwndHStarEditBox2 x+5 c%U_FBCA% -E0x200 r%USSLR% w35 gStarSaveChange vStarSelectedBox3, %UniqueStarList2%
	Gui, star:add,ListBox, HwndHStarEditBox3 c%U_FBCA% -E0x200 r%USSLR% x+5 w35 gStarSaveChange vStarSelectedBox2,|%Star1%|%Star2%|%Star3%|%Star4%
	if (OOKStars > 0)
		Gui, star:add,ListBox, HwndHStarEditBox4 x+5 c%U_FBCA% -E0x200 r%USSLR% w35 gStarSaveChange vStarSelectedBox4, %OOKStars%
	gui, star:add,button, default gStarSaveChange x-10000 y-10000
	WinSet, Style,  E0x08000000,TMPedit001
	
	if (HideScrollbars = 1) {
		LVM_ShowScrollBar(HStarEditBox1,1,False)
		GuiControl,+Vscroll,%HStarEditBox1%
		LVM_ShowScrollBar(HStarEditBox2,1,False)
		GuiControl,+Vscroll,%HStarEditBox2%
		LVM_ShowScrollBar(HStarEditBox3,1,False)
		GuiControl,+Vscroll,%HStarEditBox3%
		LVM_ShowScrollBar(HStarEditBox4,1,False)
		GuiControl,+Vscroll,%HStarEditBox4%
	}
	
	GUI, star:Show, x%xPos% y%yPos%
	if (RapidStarNow = 0 and AddStar = 0)
		sNeedsSubmit = 1
	SetTimer, GuiTimerStar
return

StarSaveChange:
	Gui, star:Default
	GUI, star:Submit
	sNeedsSubmit = 0
	NewStar := a_space
	NewStar = %sEdit%
	;msgbox 	% RapidStar "|" TmpName "," TmpFileSafeName "," C_Body "," NewStar "," StarOldFile
	if (NewStar = "")
		NewStar = %StarSelectedBox%
	if (NewStar = "")
		NewStar = %StarSelectedBox2%
	if (NewStar = "")
		NewStar = %StarSelectedBox3%
	if (NewStar = "")
		NewStar = %StarSelectedBox4%
	if (RapidStarNow == 1)
	{
		StarOldFile := ztitleEncoded ".txt"
		RapidStarNow = 0
	}
	
		if (ColEditStar == 1){
		GuiControl,,%HceEDIT%,%NewStar%
		return
	}
	
	TmpFileINI := RegExReplace(StarOldFile, "\.txt(?:^|$|\r\n|\r|\n)", Replacement := ".ini")
	TmpFileSafeName := RegExReplace(StarOldFile, "\.txt(?:^|$|\r\n|\r|\n)")
	Iniread, OldStar,%detailsPath%%TmpFileINI%, INFO,Star

	;xthis
	if (NewStar == OldStar or OldStar == "ERROR"){
		msgbox Can't change to the same star. OldStar:%OldStar% NewStar:%NewStar%
		ListStarToChange = 0
		return
	}
	FileRead, C_Body,%U_NotePath%%StarOldFile%
	Iniread, TmpName,%detailsPath%%TmpFileINI%, INFO,Name
	TmpName := strreplace(TmpName,"$#$")
	Iniread, TmpTags,%detailsPath%%TmpFileINI%, INFO,Tags
	Iniread, TmpCat,%detailsPath%%TmpFileINI%, INFO,Cat
	Iniread, TmpParent,%detailsPath%%TmpFileINI%, INFO,Parent
	IniWrite, %NewStar%, %detailsPath%%TmpFileINI%, INFO, Star
	for Each, Note in MyNotesArray{
		If (Note.8 = StarOldFile){
			MyNotesArray.RemoveAt(Each)
		}
	}
	SaveFile(TmpName,TmpFileSafeName,C_Body,1,TmpTags,TmpCat,TmpParent)
	ListStarToChange = 1
	if (RapidStarNow = 1){
		ListStarToChange = 0
		ListNeedsRefresh = 1
		sNeedsSubmit = 0
		ControlFocus , SysListView321, FlatNotes - Library
	}
	RapidStar = 0
	ControlFocus , Edit1, FlatNotes - Library
	gosub search
	StarOldFile := ""
return

StarSelected:
	z := "::" A_GuiEvent ":" errorlevel ":" A_EventInfo ":" LV@sel_col ":" GuiControlEvent
	tooltip % z
	;tooltip % x
	settimer,KillToolTip,-1000
return

About:
	Gui, 4:add,text,,FlatNotes Version 3.0.0 June 2020
	Gui, 4:Add,Link,,<a href="https://github.com/chaosdrop/FlatNotes">GitHub Page</a>
	Gui, 4:add,button,g4GuiEscape,Close
	Gui, 4:Show
return

Library:
    WinGetPos,,, Width, Height, ahk_id %g1ID%
	WinMove, ahk_id %g1ID%,, (A_ScreenWidth/2)-(Width/2), (A_ScreenHeight/2)-(Height/2)
	g1Open=1
	WinShow, ahk_id %g1ID%
	WinRestore, ahk_id %g1ID%
return

CtrlCToggle:
	GuiControlGet, SetCtrlC
	if (SetCtrlC = 1)
		IniWrite, 1, %iniPath%, General, sendCtrlC
	if (SetCtrlC = 0)
		IniWrite, 0, %iniPath%, General, sendCtrlC
return

Set_RapidStar:
	GuiControlGet, Select_RapidStar
	IniWrite, %RapidStar%, %iniPath%, General, RapidStar
return

Set_UseStarsAsParents:
	GuiControlGet, Select_UseStarsAsParents
	IniWrite, %UseStarsAsParents%, %iniPath%, General, UseStarsAsParents
return

UseCapslockToggle:
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

ColorPicked:
	if (A_GuiEvent == "Normal"){	
		GuiControlGet, ColorPicked,,ColorChoice
		pathToTheme = %A_WorkingDir%\sys\Themes\%ColorPicked%.ini
		
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
return

SortStar:
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

SortName:
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

SortBody:
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

SortAdded:
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

SortModded:
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

FolderSelect:
	WinSet, AlwaysOnTop, Off, FlatNotes - Options
	FileSelectFolder, NewNotesFolder, , 123
	if NewNotesFolder = "")
		GuiControl,,NotesStorageFolder,%U_NotePath%
	else {
		GuiControl,,NotesStorageFolder,%NewNotesFolder%\
		IniWrite, %NewNotesFolder%\, %iniPath%, General, MyNotePath
	}
	WinSet, AlwaysOnTop, On, FlatNotes - Options
return

Set_ExternalEditor:
	WinSet, AlwaysOnTop, Off, FlatNotes - Options
	FileSelectFile, NewExternalEditor, 3, , Select a program, Programs (*.exe; *.jar;)
		if (NewExternalEditor = "")
			GuiControl,,Select_ExternalEditor,%ExternalEditor%
		else {
			GuiControl,,Select_ExternalEditor,%NewExternalEditor%
			IniWrite, %NewExternalEditor%, %iniPath%, General, ExternalEditor
		}
	WinSet, AlwaysOnTop, On, FlatNotes - Options
return

Options:
	Fontlist := "sys\fontlist.cfg"
	FileRead, FontFile, % Fontlist
	FontOptionsArray := []
	loop, parse, FontFile, `n
		FontOptionsArray.push(A_LoopField)
	For k, fonts in FontOptionsArray
		FontDropDownOptions .= fonts "|"


	Gui, 3:New,,FlatNotes - Options
	Gui, 3:Add, Tab3,, General|Hotkeys|Shortcuts|Appearance|Window Size|Quick/Rapid Save|Tree View
	Gui, 3:Tab, General
	
	Gui, 3:Add, CheckBox, section vSelect_ShowMainWindowOnStartUp gSet_ShowMainWindowOnStartUp, Show main window on startup?
	GuiControl,,Select_ShowMainWindowOnStartUp,%ShowMainWindowOnStartUp%
	
	Gui, 3:Add, CheckBox, section vSelect_SearchDates gSet_SearchDates, Include added & modified dates in search?
	GuiControl,,Select_SearchDates,%SearchDates%
	
	Gui, 3:Add, CheckBox, section vSelect_SearchWholeNote gSet_SearchWholeNote, Search whole note? (disable to search only the 1st line.)
	GuiControl,,Select_SearchWholeNote,%SearchWholeNote%
	
	Gui, 3:Add,Text,section xs, Notes storage folder:
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
	
	Gui, 3:add,text, xs section, Pipe "|" sperated list of quick unique stars. (Example: 1|a|2|b..etc)
	Gui, 3:add,edit, xs section w300 vSelect_UniqueStarList gSet_UniqueStarList, %UniqueStarList% 
	
	Gui, 3:add,text, xs section, Unique stars list #2
	Gui, 3:add,edit, xs section w300 vSelect_UniqueStarList2 gSet_UniqueStarList2, %UniqueStarList2% 
	
	Gui, 3:add,text, xs section, Pipe "|" separated list of Categories. (Example: Black|White|Calico|..etc)
	
	CatBoxLitter = %CatBoxContents%
	CatboxLitter := Trim(CatBoxLitter, "|")
	
	Gui, 3:add,edit, xs section w300 vSelect_CatBoxContents gSet_CatBoxContents, %CatboxLitter% 

	Gui, 3:Add,CheckBox, xs vSelect_OpenInQuickNote gSet_OpenInQuickNote, Use Quick Notes to edit on right click?
	GuiControl,,Select_OpenInQuickNote,%OpenInQuickNote%

	Gui, 3:Add,Text,section xs, External Editor: (leave blank for system default)
	Gui, 3:Add,Edit, r1 w300 vSelect_ExternalEditor, %ExternalEditor%
	Gui, 3:Add,Button, gSet_ExternalEditor, Select a program.


;-------------------------------------------------
;Hotkeys Tab
;-------------------------------------------------
	Gui, 3:Tab, Hotkeys
	Gui, 3:Add,CheckBox, vSetCtrlC gCtrlCToggle, Send Ctrl+C when using the quick note hotkey.
	Gui, 3:Add, CheckBox, vUseCapslock gUseCapslockToggle, Use Capslock for Library?
	GuiControl,,UseCapslock,%U_Capslock%
	GuiControl,,SetCtrlC,%sendCtrlC%
	Gui, 3:Add,text, section h1 Disabled 			
	
	HotkeyNames := ["Show Library Window","Quick New Note","Quick New Note Alt (Body)","Rapid Note","Cancel Rapid Note","Rapid Note Append","Append Template to Rapid Note"]
	Loop,% 7 {
		HotkeyNameTmp := HotkeyNames[A_Index]
		Gui, 3:Add, Text, , Hotkey: %HotkeyNameTmp%
		StringReplace, noMods, savedHK%A_Index%, ~                  
		StringReplace, noMods, noMods, #,,UseErrorLevel              
		Gui, 3:Add, Hotkey, section vHK%A_Index% gLabel, %noMods%           
		Gui, 3:Add, CheckBox, x+6  vCB%A_Index% Checked%ErrorLevel%, Win
		Gui, 3:Add,text, h0 xs0 Disabled
	}                                                        
;-------------------------------------------------
;Shortcuts Tab
;-------------------------------------------------
	Gui, 3:Tab, Shortcuts

	ShortcutNames := ["Focus Search","Focus Results","Focus Edit/Preview","Add Note From Tempalte"]
	Loop,% 4 {
		ShortCutNameTmp := ShortcutNames[A_Index]
		Gui, 3:Add, Text, , %ShortCutNameTmp%:
		StringReplace, noMods, savedSK%A_Index%, ~                  
		StringReplace, noMods, noMods, #,,UseErrorLevel              
		Gui, 3:Add, Hotkey, section vSK%A_Index% gLabelS, %noMods%           
		Gui, 3:Add, CheckBox, x+6  vSCB%A_Index% Checked%ErrorLevel%, Win
		Gui, 3:Add,text, h0 xs0 Disabled
	}      
;-------------------------------------------------
;Appearance Tab
;-------------------------------------------------
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
	
	Gui, 3:Add,Text, xs section

	gui, 3:add, text,,Star
	gui, 3:add, text, xp+55,Name
	gui, 3:add, text, xp+55,Body
	gui, 3:add, text, xp+55,Added
	gui, 3:add, text, xp+55,Modded
	gui, 3:add, text, xp+55,Tags
	gui, 3:add, text, xp+55,Cat
	gui, 3:add, text, xp+55,Parent
	gui, 3:add, text, xp+55,Run
	gui, 3:add, text, xp+55,Clip
	gui, 3:add, text, xp+55,Link

	gui, 3:add, text, xs section
	
	Gui, 3:Add, Edit, w50
	Gui, 3:Add,UpDown, vStarPercentSelect gSet_StarPercent Range0-100, %oStarPercent%
	Gui, 3:Add, Edit, w50 x+5
	Gui, 3:Add,UpDown, vNamePercentSelect gSet_NamePercent Range0-100, %oNamePercent%
	Gui, 3:Add, Edit, w50 x+5
	Gui, 3:Add,UpDown,  vBodyPercentSelect gSet_BodyPercent Range0-100, %oBodyPercent%
	Gui, 3:Add, Edit, w50 x+5
	Gui, 3:Add,UpDown,  vAddedPercentSelect gSet_AddedPercent Range0-100, %oAddedPercent%
	Gui, 3:Add, Edit, w50 x+5
	Gui, 3:Add,UpDown,  vModdedPercentSelect gSet_ModdedPercent Range0-100, %oModdedPercent%
	Gui, 3:Add, Edit, w50 x+5
	Gui, 3:Add,UpDown,  vTagsPercentSelect gSet_TagsPercent Range0-100, %oTagsPercent%
	Gui, 3:Add, Edit, w50 x+5
	Gui, 3:Add,UpDown,  vCatPercentSelect gSet_CatPercent Range0-100, %oCatPercent%
	Gui, 3:Add, Edit, w50 x+5
	Gui, 3:Add,UpDown,  vParentPercentSelect gSet_ParentPercent Range0-100, %oParentPercent%
	Gui, 3:Add, Edit, w50 x+5
	Gui, 3:Add,UpDown,  vScriptPercentSelect gSet_ScriptPercent Range0-100, %oScriptPercent%
	Gui, 3:Add, Edit, w50 x+5
	Gui, 3:Add,UpDown,  vClipPercentSelect gSet_ClipPercent Range0-100, %oClipPercent%
	Gui, 3:Add, Edit, w50 x+5
	Gui, 3:Add,UpDown,  vBookmarkPercentSelect gSet_BookmarkPercent Range0-100, %oBookmarkPercent%
	
	Gui, 3:Add,text,xs section, - Main Window -
	
	Gui, 3:Add,CheckBox, xs vSelect_ShowStarHelper gSet_ShowStarHelper, Show Star Filter Button?
	GuiControl,,Select_ShowStarHelper,%ShowStarHelper%
	
	Gui, 3:Add,CheckBox, xs vSelect_ShowCatFilterBoxHelper gSet_ShowCatFilterBoxHelper, Show Category Filter Box?
	GuiControl,,Select_ShowCatFilterBoxHelper,%ShowCatFilterBoxHelper%
	
	Gui, 3:Add,CheckBox, xs vSelect_ShowTagFilterBoxHelper gSet_ShowTagFilterBoxHelper, Show Tag Filter Box?
	GuiControl,,Select_ShowTagFilterBoxHelper,%ShowTagFilterBoxHelper%
	
	Gui, 3:Add,CheckBox, xs vSelect_ShowTagEditBoxHelper gSet_ShowTagEditBoxHelper, Show Tag Edit Box?
	GuiControl,,Select_ShowTagEditBoxHelper,%ShowTagEditBoxHelper%
	
	Gui, 3:Add,CheckBox, xs vSelect_ShowParentEditBoxHelper gSet_ShowParentEditBoxHelper, Show Parent Edit Box?
	GuiControl,,Select_ShowParentEditBoxHelper,%ShowParentEditBoxHelper%
	
	Gui, 3:Add,CheckBox, xs vSelect_ShowPreviewEditBoxHelper gSet_ShowPreviewEditBoxHelper, Show Preview Edit Box?
	GuiControl,,Select_ShowPreviewEditBoxHelper,%ShowPreviewEditBoxHelper%
	
	Gui, 3:Add,text,xs section, - Quick Note Window -

	Gui, 3:Add,CheckBox, xs vSelect_ExtraInputInTemplatesHelper gSet_ExtraInputInTemplatesHelper, Show Preview Edit Box?
	GuiControl,,Select_ExtraInputInTemplatesHelper,%ExtraInputInTemplatesHelper%
	
		Gui, 3:Add,CheckBox, xs vSelect_ShowQuickCatEditBoxHelper gSet_ShowQuickCatEditBoxHelper, Show Quick Category Edit Box?
	GuiControl,,Select_ShowQuickCatEditBoxHelper,%ShowQuickCatEditBoxHelper%
	
	
	Gui, 3:Add,CheckBox, xs vSelect_ShowQuickTagEditBoxHelper gSet_ShowQuickTagEditBoxHelper, Show Tag Edit Box?
	GuiControl,,Select_ShowQuickTagEditBoxHelper,%ShowQuickTagEditBoxHelper%
	
	Gui, 3:Add,CheckBox, xs vSelect_ShowQuickParentEditBoxHelper gSet_ShowQuickParentEditBoxHelper, Show Quick Parent Edit Box?
	GuiControl,,Select_ShowQuickParentEditBoxHelper,%ShowQuickParentEditBoxHelper%

	
	
	;—-------------------------
	;Window Size Options Tab
	;—--------------------------
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
	
	Gui, 3:Add,Text,xs,Quick Note Window Width: (Default: 350)

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
	
	Gui, 3:Add,Text,xs,Unique Star List Rows: (Default: 10)
	Gui, 3:Add,Edit   
	Gui, 3:Add,UpDown,vSelect_USSLR gSet_USSLR range1-99, %USSLR%

	Gui, 3:Add,Text,xs,Static X window location: (Default: Blank [which uses the mouse position.])
	Gui, 3:Add,Edit,vSelect_StaticX w100 gSet_StaticX, %StaticX%

	Gui, 3:Add,Text,xs,Static Y window location: (Default: Blank  [which uses the mouse position.])
	Gui, 3:Add,Edit,vSelect_StaticY w100 gSet_StaticY, %StaticX% 
	
	;Quick/Rapid Save Tab
	Gui, 3:Tab, Quick/Rapid Save
	Gui, 3:Add,CheckBox, vSelect_RapidStar gSet_RapidStar, Prompt for star at end of Rapid note?
	GuiControl,,Select_RapidStar,%RapidStar%
	
;—-------------------------
;Tree View Options Tab
;—--------------------------
	Gui, 3:Tab, Tree View
	Gui, 3:Add,CheckBox, vSelect_UseStarsAsParents gSet_UseStarsAsParents,Use stars for Tree View parents instead of user set parents.
	GuiControl,,Select_UseStarsAsParents,%UseStarsAsParents%	
	
	
	gui,3:Tab,
	Gui, 3:Add, Button, Default gSaveAndReload, Save and Reload
	
	if (U_Capslock = 1)
		GuiControl, Disable, msctls_hotkey321
	if (OpenInQuickNote = 1)
		GuiControl, Disable, Select_ExternalEditor
	Gui, 3:SHOW 
	WinSet, AlwaysOnTop, On, FlatNotes - Options
return
  
SaveAndReload:
	GuiControlGet,Select_UniqueStarList
	IniRead, UniqueStarList, %iniPath%, General, UniqueStarList
	GuiControlGet,Select_UniqueStarList2
	IniRead, UniqueStarList2, %iniPath%, General, UniqueStarList2
	GuiControlGet,Select_CatBoxContents
	IniRead, CatBoxContents, %iniPath%, General, CatBoxContents
	GuiControlGet,Select_ExternalEditor
	IniWrite, %Select_ExternalEditor%, %iniPath%, General, ExternalEditor
	GuiControlGet,Select_ShowStarHelper
	IniWrite,%Select_ShowStarHelper%, %iniPath%, General, ShowStarHelper
	GuiControlGet,Select_ShowCatFilterBoxHelper
	IniWrite,%Select_ShowCatFilterBoxHelper%, %iniPath%, General, ShowCatFilterBoxHelper
	
	GuiControlGet,Select_ShowQuickCatEditBoxHelper
	IniWrite,%Select_ShowQuickCatEditBoxHelper%, %iniPath%, General, ShowQuickCatEditBoxHelper
	GuiControlGet,Select_ShowQuickParentEditBoxHelper
	IniWrite,%Select_ShowQuickParentEditBoxHelper%, %iniPath%, General, ShowQuickParentEditBoxHelper
	GuiControlGet,Select_ShowQuickTagEditBoxHelper
	IniWrite,%Select_ShowQuickTagEditBoxHelper%, %iniPath%, General, ShowQuickTagEditBoxHelper
	
	GuiControlGet,Select_ShowTagFilterBoxHelper
	IniWrite,%Select_ShowTagFilterBoxHelper%, %iniPath%, General, ShowCatFilterTagHelper
	GuiControlGet,Select_ShowTagEditBoxHelper
	IniWrite,%Select_ShowTagEditBoxHelper%, %iniPath%, General, ShowCatEditTagHelper
	GuiControlGet,Select_ShowParentEditBoxHelper
	IniWrite,%Select_ShowParentEditBoxHelper%, %iniPath%, General, ShowCatEditParentHelper
	GuiControlGet,Select_ShowPreviewEditBoxHelper
	IniWrite,%Select_ShowPreviewEditBoxHelper%, %iniPath%, General, ShowCatEditPreviewHelper
	Iniread, StaticY,%iniPath%,General,StaticY,10
	GuiControlGet,Select_ExtraInputInTemplatesHelper
	IniWrite,%Select_ExtraInputInTemplatesHelper%, %iniPath%, General, ShowCatEditPreviewHelper
	GuiControlGet, Select_RapidStar
	IniWrite, %Select_RapidStar%, %iniPath%, General, RapidStar
	GuiControlGet, Select_UseStarsAsParents
	IniWrite, %Select_UseStarsAsParents%, %iniPath%, General, UseStarsAsParents
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
	GuiControlGet, TagsPercentSelect
	GuiControlGet, CatPercentSelect	
	GuiControlGet, ParentPercentSelect
	GuiControlGet, ScriptPercentSelect
	GuiControlGet, ClipPercentSelect
	GuiControlGet, BookmarkPercentSelect

	
		

	is100 := StarPercentSelect+NamePercentSelect+BodyPercentSelect+AddedPercentSelect+ModdedPercentSelect+TagsPercentSelect+CatPercentSelect+ParentPercentSelect+ScriptPercentSelect+ClipPercentSelect+BookmarkPercentSelect
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
	IniWrite, %TagsPercentSelect%,%iniPath%,General, TagsPercent
	IniWrite, %CatPercentSelect%,%iniPath%,General, CatPercent
	IniWrite, %ParentPercentSelect%,%iniPath%,General, ParentPercent
	IniWrite, %ScriptPercentSelect%,%iniPath%,General, ScriptPercent
	IniWrite, %ClipPercentSelect%,%iniPath%,General, ClipPercent
	IniWrite, %BookmarkPercentSelect%,%iniPath%,General, BookmarkPercent


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
	GuiControlGet,Select_ShowMainWindowOnStartUp
	IniWrite,%Select_ShowMainWindowOnStartUp%, %iniPath%, General, ShowMainWindowOnStartUp
	GuiControlGet,Select_UniqueStarList
	IniWrite, %Select_UniqueStarList%,%iniPath%,General, UniqueStarList
	GuiControlGet,Select_USSLR	
	IniWrite, %Select_USSLR%,%iniPath%,General, USSLR
	GuiControlGet,Select_StaticX	
	IniWrite, %Select_StaticX%,%iniPath%,General, StaticX
	GuiControlGet,Select_StaticY	
	IniWrite, %Select_StaticY%,%iniPath%,General, StaticY
	GuiControlGet,Select_SearchDates
	IniWrite,%Select_SearchDates%, %iniPath%, General, SearchDates
	GuiControlGet,Select_SearchWholeNote
	IniWrite,%Select_SearchWholeNote%, %iniPath%, General, SearchWholeNote
return

Set_Star1:
	GuiControlGet,Select_Star1
	IniWrite, %Select_Star1%,%iniPath%,General, Star1
	IniRead, Star1, %iniPath%, General, Star1
return

Set_Star2:
	GuiControlGet,Select_Star2
	IniWrite, %Select_Star2%,%iniPath%,General, Star2
	IniRead, Star2, %iniPath%, General, Star2
return

Set_Star3:
	GuiControlGet,Select_Star3
	IniWrite, %Select_Star3%,%iniPath%,General, Star3
	IniRead, Star3, %iniPath%, General, Star3
return

Set_Star4:
	GuiControlGet,Select_Star4
	IniWrite, %Select_Star4%,%iniPath%,General, Star4
	IniRead, Star4, %iniPath%, General, Star4
return

Set_UniqueStarList:
	GuiControlGet,Select_UniqueStarList
	IniWrite, %Select_UniqueStarList%,%iniPath%,General, UniqueStarList
	IniRead, UniqueStarList, %iniPath%, General, UniqueStarList
return

Set_UniqueStarList2:
	GuiControlGet,Select_UniqueStarList2
	IniWrite, %Select_UniqueStarList2%,%iniPath%,General, UniqueStarList2
	IniRead, UniqueStarList2, %iniPath%, General, UniqueStarList2
return

Set_CatBoxContents:
	GuiControlGet,Select_CatBoxContents
	IniWrite, %Select_CatBoxContents%,%iniPath%,General, CatBoxContents
	IniRead, CatBoxContents, %iniPath%, General, CatBoxContents
return

Set_DeafultSort:
	GuiControlGet,Select_DeafultSort
	IniWrite, %Select_DeafultSort%,%iniPath%,General, DeafultSort
	IniRead, DeafultSort, %iniPath%, General, DeafultSort
return

Set_DeafultSortDir:
	GuiControlGet,Select_DeafultSortDir
	IniWrite, %Select_DeafultSortDir%,%iniPath%,General, DeafultSortDir
	IniRead, DeafultSortDir, %iniPath%, General, DeafultSortDir
return

Set_UserTimeFormat:
	GuiControlGet,Select_UserTimeFormat
	IniWrite, %Select_UserTimeFormat%,%iniPath%,General, UserTimeFormat
	IniRead, UserTimeFormat, %iniPath%, General, UserTimeFormat
return

Set_backupsToKeep:
	GuiControlGet,U_backupsToKeep,, backupsToKeepSelect	
	IniWrite, %U_backupsToKeep%,%iniPath%,General, backupsToKeep
	IniRead, backupsToKeep, %iniPath%, General, backupsToKeep
return

Set_ShowMainWindowOnStartUp:
	GuiControlGet,Select_ShowMainWindowOnStartUp
	
	if (A_GuiEvent == "Normal"){
		IniWrite,%Select_ShowMainWindowOnStartUp%, %iniPath%, General, ShowMainWindowOnStartUp
		IniRead,ShowMainWindowOnStartUp,%iniPath%,General,ShowMainWindowOnStartUp
		
	}
return

Set_SearchDates:
	GuiControlGet,Select_SearchDates
	
	if (A_GuiEvent == "Normal"){
		IniWrite,%Select_SearchDates%, %iniPath%, General, SearchDates
		IniRead,SearchDates,%iniPath%,General,SearchDates
		
	}
return

Set_SearchWholeNote:
	GuiControlGet,Select_SearchWholeNote
	
	if (A_GuiEvent == "Normal"){
		IniWrite,%Select_SearchWholeNote%, %iniPath%, General, SearchWholeNote
		IniRead,SearchWholeNote,%iniPath%,General,SearchWholeNote
	}
return

SetHideScrollbars:
	GuiControlGet,HideScrollbarsSelect
	
	if (A_GuiEvent == "Normal"){
		IniWrite,%HideScrollbarsSelect%, %iniPath%, General, HideScrollbars
		IniRead,HideScrollbars,%iniPath%,General,HideScrollbars
		
	}
return

SetShowStatusBar:
	GuiControlGet,ShowStatusBarSelect
	
	if (A_GuiEvent == "Normal"){
		IniWrite,%ShowStatusBarSelect%, %iniPath%, General, ShowStatusBar
		IniRead,ShowStatusBar,%iniPath%,General,ShowStatusBar
		
	}
return

Set_ShowStarHelper:
	GuiControlGet,Select_ShowStarHelper
	
	if (A_GuiEvent == "Normal"){
		IniWrite,%Select_ShowStarHelper%, %iniPath%, General, ShowStarHelper
		IniRead,ShowStarHelper,%iniPath%,General,ShowStarHelper
	}
return

Set_ShowCatFilterBoxHelper:
	GuiControlGet,Select_ShowCatFilterBoxHelper
	
	if (A_GuiEvent == "Normal"){
		IniWrite,%Select_ShowCatFilterBoxHelper%, %iniPath%, General, ShowCatFilterBoxHelper
		IniRead,ShowCatFilterBoxHelper,%iniPath%,General,ShowCatFilterBoxHelper
	}
return

Set_ShowCatEditBoxHelper:
	GuiControlGet,Select_ShowCatEditBoxHelper
	
	if (A_GuiEvent == "Normal"){
		IniWrite,%Select_ShowCatEditBoxHelper%, %iniPath%, General, ShowCatEditBoxHelper
		IniRead,ShowCatEditBoxHelper,%iniPath%,General,ShowCatEditBoxHelper
	}
return

Set_ShowTagFilterBoxHelper:
	GuiControlGet,Select_ShowTagFilterBoxHelper
	
	if (A_GuiEvent == "Normal"){
		IniWrite,%Select_ShowTagFilterBoxHelper%, %iniPath%, General, ShowTagFilterBoxHelper
		IniRead,ShowTagFilterBoxHelper,%iniPath%,General,ShowTagFilterBoxHelper
	}
return

Set_ShowParentEditBoxHelper:
	GuiControlGet,Select_ShowParentEditBoxHelper
	
	if (A_GuiEvent == "Normal"){
		IniWrite,%Select_ShowParentEditBoxHelper%, %iniPath%, General, ShowParentEditBoxHelper
		IniRead,ShowParentEditBoxHelper,%iniPath%,General,ShowParentEditBoxHelper
	}
return

Set_ShowQuickParentEditBoxHelper:
	GuiControlGet,Select_ShowQuickParentEditBoxHelper
	
	if (A_GuiEvent == "Normal"){
		IniWrite,%Select_ShowQuickParentEditBoxHelper%, %iniPath%, General, ShowQuickParentEditBoxHelper
		IniRead,ShowQuickParentEditBoxHelper,%iniPath%,General,ShowQuickParentEditBoxHelper
	}
return

Set_ShowQuickTagEditBoxHelper:
	GuiControlGet,Select_ShowQuickTagEditBoxHelper
	
	if (A_GuiEvent == "Normal"){
		IniWrite,%Select_ShowQuickTagEditBoxHelper%, %iniPath%, General, ShowQuickTagEditBoxHelper
		IniRead,ShowQuickTagEditBoxHelper,%iniPath%,General,ShowQuickTagEditBoxHelper
	}
return

Set_ShowQuickCatEditBoxHelper:
	GuiControlGet,Select_ShowQuickCatEditBoxHelper
	
	if (A_GuiEvent == "Normal"){
		IniWrite,%Select_ShowQuickCatEditBoxHelper%, %iniPath%, General, ShowQuickCatEditBoxHelper
		IniRead,ShowQuickCatEditBoxHelper,%iniPath%,General,ShowQuickCatEditBoxHelper
	}
return

Set_ShowPreviewEditBoxHelper:
	GuiControlGet,Select_ShowPreviewEditBoxHelper
	
	if (A_GuiEvent == "Normal"){
		IniWrite,%Select_ShowPreviewEditBoxHelper%, %iniPath%, General, ShowPreviewEditBoxHelper
		IniRead,ShowPreviewEditBoxHelper,%iniPath%,General,ShowPreviewEditBoxHelper
	}
return

Set_ExtraInputInTemplatesHelper:
	GuiControlGet,Select_ExtraInputInTemplatesHelper
	
	if (A_GuiEvent == "Normal"){
		IniWrite,%Select_ExtraInputInTemplatesHelper%, %iniPath%, General, ExtraInputInTemplatesHelper
		IniRead,ExtraInputInTemplatesHelper,%iniPath%,General,ExtraInputInTemplatesHelper
	}
return

Set_ShowTagEditBoxHelper:
	GuiControlGet,Select_ShowTagEditBoxHelper
	
	if (A_GuiEvent == "Normal"){
		IniWrite,%Select_ShowTagEditBoxHelper%, %iniPath%, General, ShowTagEditBoxHelper
		IniRead,ShowTagEditBoxHelper,%iniPath%,General,ShowTagEditBoxHelper
	}
return

Set_OpenInQuickNote:

	GuiControlGet,Select_OpenInQuickNote
	if (OpenInQuickNote = 0)
		GuiControl, Disable, Select_ExternalEditor
	if (OpenInQuickNote = 1)
		GuiControl, Enable, Select_ExternalEditor
	if (A_GuiEvent == "Normal"){
		IniWrite,%Select_OpenInQuickNote%, %iniPath%, General, OpenInQuickNote
		IniRead,OpenInQuickNote,%iniPath%,General,OpenInQuickNote
	}
return

SetPreviewRows:
	GuiControlGet, U_PreviewRows,,PreviewRowsSelect	
	IniWrite, %U_PreviewRows%,%iniPath%,General, PreviewRows	
	IniRead, PreviewRows, %iniPath%, General, PreviewRows
	gosub DummyGUI1
return

SetResultRows:
	GuiControlGet, U_ResultRows,,ResultRowsSelect	
	IniWrite, %U_ResultRows%,%iniPath%,General, ResultRows		
	IniRead, ResultRows, %iniPath%, General, ResultRows
	gosub DummyGUI1
return 

SetQuickNoteRows:
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

SetQuickW:
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

Set_USSLR:
	GuiControlGet,Select_USSLR	
	IniWrite, %Select_USSLR%,%iniPath%,General, USSLR	
	IniRead, USSLR, %iniPath%, General, USSLR
return

Set_StaticX:
	GuiControlGet,Select_StaticX	
	IniWrite, %Select_StaticX%,%iniPath%,General, StaticX	
	IniRead, StaticX, %iniPath%, General, StaticX
return

Set_StaticY:
	GuiControlGet,Select_StaticY	
	IniWrite, %Select_StaticY%,%iniPath%,General, StaticY	
	IniRead, StaticY, %iniPath%, General, StaticY
return

Set_StickyRows:
	GuiControlGet,Select_StickyRows	
	IniWrite, %Select_StickyRows%,%iniPath%,General, StickyRows	
	IniRead, StickyRows, %iniPath%, General, StickyRows
return

Set_StickyW: 
	GuiControlGet, Select_StickyW	
	IniWrite, %Select_StickyW%,%iniPath%,General, StickyW	
	IniRead, StickyW,%iniPath%, General,StickyW
return

SetMainW:
	GuiControlGet, U_MainNoteWidth,,MainWSelect	
	IniWrite, %U_MainNoteWidth%,%iniPath%,General, WindowWidth	
	IniRead, LibW, %iniPath%, General, WindowWidth ,530	
	libWAdjust := LibW+10
	ColAdjust := LibW-95
	NameColW := Round(ColAdjust*0.4)
	BodyColW := Round(ColAdjust*0.6)
	gosub DummyGUI1
return 

SetFontRendering:
	GuiControlGet, U_FontRendering,,FontRenderingSelect	
	IniWrite, %U_FontRendering%,%iniPath%,General, FontRendering		
	IniRead, FontRendering,%iniPath%, General,FontRendering
	gosub DummyGUI1
return

SetSearchFontFamily:
	GuiControlGet, U_SearchFontFamily,,SearchFontFamilySelect
	IniWrite, %U_SearchFontFamily%,%iniPath%,General, SearchFontFamily	
	IniRead, SearchFontFamily, %iniPath%, General, SearchFontFamily
	gosub DummyGUI1
return 

SetSearchFontSize:
	GuiControlGet, U_SearchSize,,SearchFontSizeSelect	
	IniWrite, %U_SearchSize%,%iniPath%,General, SearchFontSize
	IniRead, SearchFontSize, %iniPath%, General, SearchFontSize
	gosub DummyGUI1
return 

SetResultFontFamily:
	GuiControlGet, U_ResultFontFamily,,ResultFontFamilySelect
	IniWrite, %U_ResultFontFamily%,%iniPath%,General, ResultFontFamily	
	IniRead, ResultFontFamily, %iniPath%, General, ResultFontFamily
	gosub DummyGUI1
return 

SetResultFontSize:
	GuiControlGet, U_ResultSize,,ResultFontSizeSelect	
	IniWrite, %U_ResultSize%,%iniPath%,General, ResultFontSize
	IniRead, ResultFontSize, %iniPath%, General, ResultFontSize
	gosub DummyGUI1
return 

SetPreviewFontFamily:
	GuiControlGet, U_PreviewFontFamily,,PreviewFontFamilySelect
	IniWrite, %U_PreviewFontFamily%,%iniPath%,General, PreviewFontFamily	
	IniRead, PreviewFontFamily, %iniPath%, General, PreviewFontFamily
	gosub DummyGUI1
return
SetPreviewFontSize:
	GuiControlGet, U_PreviewSize,,PreviewFontSizeSelect	
	IniWrite, %U_PreviewSize%,%iniPath%,General, PreviewFontSize
	IniRead, PreviewFontSize, %iniPath%, General, PreviewFontSize
	gosub DummyGUI1
return

SetStickyFontFamily:
	GuiControlGet, U_StickyFontFamily,,StickyFontFamilySelect
	IniWrite, %U_StickyFontFamily%,%iniPath%,General, StickyFontFamily	
	IniRead, StickyFontFamily, %iniPath%, General, StickyFontFamily
return

SetStickyFontSize:
	GuiControlGet, U_StickySize,,StickyFontSizeSelect	
	IniWrite, %U_StickySize%,%iniPath%,General, StickyFontSize
	IniRead, StickyFontSize, %iniPath%, General, StickyFontSize
return

SetFontFamily:
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
	GuiControl,,QuickNoteTags, Sample Text
	GuiControl,,QuickNoteCat, Sample Text
	GuiControl,,QuickNoteParent, Sample Text
return

SetFontSize:
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
	GuiControl,,QuickNoteTags, Sample Text
	GuiControl,,QuickNoteCat, Sample Text
	GuiControl,,QuickNoteParent, Sample Text
return

Set_StarPercent:
	GuiControlGet, StarPercentSelect	
	IniWrite, %StarPercentSelect%,%iniPath%,General, StarPercent		
	IniRead, oNamePercent,%iniPath%, General,StarPercent
	StarPercent = 0.%oStarPercent%
	gosub DummyGUI1
return

Set_NamePercent:
	GuiControlGet, NamePercentSelect	
	IniWrite, %NamePercentSelect%,%iniPath%,General, NamePercent		
	IniRead, oNamePercent,%iniPath%, General,NamePercent
	NamePercent = 0.%oNamePercent%
	gosub DummyGUI1
return

Set_BodyPercent:
	GuiControlGet, BodyPercentSelect	
	IniWrite, %BodyPercentSelect%,%iniPath%,General, BodyPercent		
	IniRead, oBodyPercent,%iniPath%, General,BodyPercent
	BodyPercent = 0.%oBodyPercent%
	gosub DummyGUI1
return

Set_AddedPercent:
	GuiControlGet, AddedPercentSelect	
	IniWrite, %AddedPercentSelect%,%iniPath%,General, AddedPercent		
	IniRead, oAddedPercent,%iniPath%, General,AddedPercent
	AddedPercent = 0.%oAddedPercent%
	gosub DummyGUI1
return

Set_ModdedPercent:
	GuiControlGet, ModdedPercentSelect	
	IniWrite, %ModdedPercentSelect%,%iniPath%,General, ModdedPercent	
	IniRead, oModdedPercent,%iniPath%, General,ModdedPercent
	ModdedPercent = 0.%oModdedPercent%
	gosub DummyGUI1
return

Set_TagsPercent:
	GuiControlGet, TagsPercentSelect	
	IniWrite, %TagsPercentSelect%,%iniPath%,General, TagsPercent	
	IniRead, oTagsPercent,%iniPath%, General,TagsPercent
	TagsPercent = 0.%oTagsPercent%
	gosub DummyGUI1
return

Set_CatPercent:
	GuiControlGet, CatPercentSelect	
	IniWrite, %CatPercentSelect%,%iniPath%,General, CatPercent	
	IniRead, oCatPercent,%iniPath%, General,CatPercent
	CatPercent = 0.%oCatPercent%
	gosub DummyGUI1
return

Set_ParentPercent:
	GuiControlGet, ParentPercentSelect	
	IniWrite, %ParentPercentSelect%,%iniPath%,General, ParentPercent	
	IniRead, oParentPercent,%iniPath%, General,ParentPercent
	ParentPercent = 0.%oParentPercent%
	gosub DummyGUI1
return

Set_ScriptPercent:
	GuiControlGet, ScriptPercentSelect	
	IniWrite, %ScriptPercentSelect%,%iniPath%,General, ScriptPercent	
	IniRead, oScriptPercent,%iniPath%, General,ScriptPercent
	ScriptPercent = 0.%oScriptPercent%
	gosub DummyGUI1
return

Set_ClipPercent:
	GuiControlGet, ClipPercentSelect	
	IniWrite, %ClipPercentSelect%,%iniPath%,General, ClipPercent	
	IniRead, oClipPercent,%iniPath%, General,ClipPercent
	ClipPercent = 0.%oClipPercent%
	gosub DummyGUI1
return

Set_BookmarkPercent:
	GuiControlGet, BookMarkPercentSelect	
	IniWrite, %BookmarkPercentSelect%,%iniPath%,General, BookmarkPercent	
	IniRead, oBookmarkPercent,%iniPath%, General,BookmarkPercent
	BookmarkPercent = 0.%oBookmarkPercent%
	gosub DummyGUI1
return

Label:
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

LabelS:
	If %A_GuiControl% in +,^,!,+^,+!,^!,+^!   
		return
	num := SubStr(A_GuiControl,3)              
	If (SK%num% != "") {                       
		Gui, Submit, NoHide
		If SCB%num%                                
			SK%num% := "#" SK%num%
		If !RegExMatch(SK%num%,"[#!\^\+]")       
			SK%num% := "~" SK%num%                  
		Loop,% #ctrls
			If (SK%num% = savedSK%A_Index%) {       
				dup := A_Index
				Loop,6 {
					GuiControl,% "Disable" b:=!b, SK%dup% 
					Sleep,200
				}
				GuiControl,,SK%num%,% SK%num% :=""      
				break
			}
	}
	If (savedSK%num% || SK%num%)
		setSK(num, savedSK%num%, SK%num%)
return


sbGuiEscape:
sbGuiClose:
	Gui, sb:Destroy
return

StarGuiEscape:
StarGuiClose:
	Gui, Star:Destroy
return

skceGuiClose:
skceGuiEscape:
	Gui, skce:Destroy
	ColEditStar = 0
return

skneGuiClose:
skneGuiEscape:
	Gui, skne:Destroy
	ColEditStar = 0
return

ceGuiClose:
ceGuiEscape:
	Gui, ce:Destroy
	ColEditStar = 0
return


6GuiEscape:
6GuiClose:
	Gui, 6:Destroy
return

4GuiEscape:
4GuiClose:
	Gui, 4:Destroy
return

3GuiEscape:
3GuiClose:
	Gui, 3:Destroy
	reload
return

2GuiEscape:
2GuiClose:
	GuiControlGet,working_QuickNote,,%HQNB%
	GuiControlGet,working_QuickNoteSafeName,,%HQNFSN%
	FileRead, CheckForOldNote, %U_NotePath%%working_QuickNoteSafeName%.txt
	working_QuickNote := strreplace(working_QuickNote,"`n","`r`n")
	if (working_QuickNote != "" && working_QuickNote != CheckForOldNote) {
		OnMessage(0x44, "OnMsgBox")
		MsgBox 0x40024, Close?, - Note data will be lost -`nCuntinue to close?
		OnMessage(0x44, "")
		IfMsgBox Yes, {
			Gui, 2:Destroy
		} Else IfMsgBox No, {
			return
		}
	}
	Gui, 2:Destroy 
return

GuiEscape:
	WinHide, ahk_id %g1ID%
	g1Open=0
	SelectedRows=
return

GuiClose:
	WinHide, ahk_id %g1ID%
	g1Open=0
	SelectedRows=
return

Exit:
	ExitApp

CheckBackupLaterTimer:
	BackupNotes()
return


SortNow:
	LV_ModifyCol(C_SortCol,C_SortDir)
return




Edit3SaveTimer:
	global LVSelectedROW
	if (LVSelectedROW=="")
		LVSelectedROW = 1
	GuiControlGet, PreviewBox
	if (!PreviewBox){
		;needed to ensure LV text is updated if the note is blanked.
		PreviewBox := a_space
	}
	GuiControlGet, TagBox
	GuiControlGet, NoteParent
	LV_GetText(LVexists,1,2)
	LV_GetText(RowText, LVSelectedROW,2)
	FileSafeName := NameEncode(RowText)
	iniRead,C_Cat,%detailsPath%%FileSafeName%.ini,INFO,Cat
	
	SaveFile(RowText,FileSafeName,PreviewBox,1,TagBox,C_Cat,NoteParent)
	iniRead,OldAdd,%detailsPath%%FileSafeName%.ini,INFO,Add

	FileReadLine, NewBodyText, %U_NotePath%%FileSafeName%.txt,1
	LV_Modify(LVSelectedROW,,,RowText, NewBodyText,,,,,,,TagBox,,NoteParent)
	savetimerrunning = 0
	unsaveddataEdit3 = 0
	ControlSend, Edit1,{left},FlatNotes - Library
return

PreviewBox:
	unsaveddataEdit3 = 1
if (savetimerrunning = 0) {
	savetimerrunning = 1
	settimer, Edit3SaveTimer, -10000
	}
return

uiMove:
	PostMessage, 0xA1, 2,,, A 
Return

Xsticky:
	Gui +LastFound 
	gui destroy
	WinClose
return

Usticky:
	Gui +LastFound 
	WinMove, , , ,  , , 26
return

Hsticky:
	Gui +LastFound 
	WinMove, , , ,  , , %StickyMaxH%
return

Pinsticky:
	Gui +LastFound 
	WinSet, AlwaysOnTop , Toggle
return

StarQN:
	GUI, sb:new,-Caption +ToolWindow +hWndHSEB2,StarPicker
	Gui, sb:Margin , 5, 5 
	Gui, sb:Font, s10 Q%FontRendering%, Verdana, %U_MFC%
	Gui, sb:Color,%U_SBG%, %U_MBG%
	if (StrLen(OOKStars) > 0) {
		Gui, sb:add,ListBox, hwndHStarBox1QN c%U_FBCA% -E0x200 r%USSLR% w35 gDo_ApplyStarQN vStarQN,%OOKStars%
		Gui, sb:add,ListBox, hwndHStarBox2QN c%U_FBCA% -E0x200 r%USSLR% x+5 w35 gDo_ApplyStarQN vStar2QN,|%Star1%|%Star2%|%Star3%|%Star4%
	}else
		Gui, sb:add,ListBox, hwndHStarBox2QN c%U_FBCA% -E0x200 r%USSLR% w35 gDo_ApplyStarQN vStar2QN,|%Star1%|%Star2%|%Star3%|%Star4%
	if (UniqueStarList > 0)
		Gui, sb:add,ListBox, hwndHStarBox3QN x+5 c%U_FBCA% -E0x200 r%USSLR% w35 gDo_ApplyStarQN vStar3QN, %UniqueStarList%
	if (UniqueStarList2 > 0)
		Gui, sb:add,ListBox, hwndHStarBox4QN x+5 c%U_FBCA% -E0x200 r%USSLR% w35 gDo_ApplyStarQN vStar4QN, %UniqueStarList2%
	
	MouseGetPos, xPos, yPos
	xPos := xPos-50
	
	if (HideScrollbars = 1) {
		LVM_ShowScrollBar(HStarBox1QN,1,False)
		GuiControl,+Vscroll,%HStarBox1QN%
		LVM_ShowScrollBar(HStarBox2QN,1,False)
		GuiControl,+Vscroll,%HStarBox2QN%
		LVM_ShowScrollBar(HStarBox3QN,1,False)
		GuiControl,+Vscroll,%HStarBox3QN%
		LVM_ShowScrollBar(HStarBox4QN,1,False)
		GuiControl,+Vscroll,%HStarBox4QN%
	}
	Gui, sb:show, x%xPos% y%yPos%
	SetTimer, GuiTimerSB
return
	
Do_ApplyStarQN:
	Gui sb:Submit
	if (StarQN="")
		StarQN:=Star2QN
	if (StarQN="")
		StarQN:=Star3QN
	if (StarQN="")
		StarQN:=Star4QN
	GuiControl,,%HQNQS%,%StarQN%
	StarQN := ""
	StarQN2 := ""
	StarQN3 := ""
	StarQN4 := ""
return

GuiTimerStar:
	IfWinNotActive, TMPedit001
	{	
		Gui, Star:destroy
		SetTimer, GuiTimerStar, Off
	}
Return

GuiTimerSB:
	IfWinNotActive, StarPicker
	{	
		Gui, sb:destroy
		SetTimer, GuiTimerSB, Off
	}
Return


HelpWindow:
msgbox % "Advanced search: `nn;;	term = Search names only.[Also works for b:: t:: and p:: for body, tags, and parent]`ntermA||termB = find a or b.`n`n[Legend: + = Shift, ^ = Ctrl, ! = Alt, # = Win]`n`nGLOBAL HOTKEYS:`nOpen Library (if Capslock not used): " savedHK1 "`nQuick Note: " savedHK2 "`nQuick Note Alt: " savedHK3 "`nRapid Note: " savedHK4 "`nCancel Rapid Note: " savedHK5 "`nAppend to Rapid Note: " savedHK6 "`nAppend Template to Rapid Note" savedHK7 "`n`nMAIN WINDOW SHORTCUTS:`nFocus Search: "savedSK1 "`nFocus Results: " savedSK2 "`nFocus Edit/Preview: " savedSK3 "`nAdd Note From Template: " savedSK4 "`n`nINFO:`nQuick Note:`nSelect text and press the Quick Note hotkey to bring that text up as the body of a new blank note.`n`nRapid Note:`nUse the Rapid Note hotkey to quick add notes. Press the Rapid Note Hotkey once to copy the title, then again to copy the body or use the append hotkey to add any number of selected texts to the body of the note. When you are done use the Rapid Note hotekey to finish the note and select a star."
return


RefreshTV:
Gui, tree:Default
TVcurrent := TV_GetCount()
TV_Delete()
TVcurrent = 0
lastloopcheck = -1
TVneeded := JEE_ObjCount(MyNotesArray)
;msgbox % TVcurrent
global TreeExpandByDeafultTrue = "Expand"
if (UseStarsAsParents)
{
	None := TV_Add("- None -",,  TreeExpandByDeafultTrue  )
	TVneeded++
	For Each, Note In MyNotesArray
	{
		if (Note.1)
		{
			StarName := NameEncodeSticky(Note.1)
			StarName := trim(StarName)
			
			TV_GetText(StarParentExists,%StarName%)

			if (!StarParentExists)
			{
				%StarName% := TV_Add(Note.1,,"Bold " .  TreeExpandByDeafultTrue)
				TVneeded++
			}
		}
	}
	For Each, Note In MyNotesArray
	{
		TreeNodeName := NameEncodeSticky(Note.2)
		TreeNodeName := trim(TreeNodeName)
		%TreeNodeName% := 0
		StarName := NameEncodeSticky(Note.1)
		StarName := trim(StarName)
		
		if (StarName)
			%TreeNodeName% := TV_Add(Note.2,%StarName%,"Expand" )
		if (!StarName)
			%TreeNodeName% := TV_Add(Note.2,None,"Expand")
	}
}else{
;Built The root Parents.
For Each, Note In MyNotesArray
{
	ParentFileName := NameEncodeSticky(Note.12)
	ParentFileName := trim(ParentFileName)
	TreeNodeName := NameEncodeSticky(Note.2)
	TreeNodeName := trim(TreeNodeName)
	%TreeNodeName% := 0
	
	if (not Note.12)
	{
		%TreeNodeName% := TV_Add(Note.2,,"Expand" )
	}
}
;TVcurrent := TV_GetCount()
;msgbox % TVcurrent "::" TVneeded

while TV_GetCount() != TVneeded
{
	LastCount := TV_GetCount()
	For Each, Note In MyNotesArray
	{
		if (Note.12)
		{
		
			RealParentFileName := NameEncode( Note.12)
			RealParentFileName := trim(RealParentFileName)
			ParentFileName := NameEncodeSticky( Note.12)
			ParentFileName := trim(ParentFileName)
			TreeNodeName := NameEncodeSticky(Note.2)
			TreeNodeName := trim(TreeNodeName)
			
			
			
			TV_GetText(SelfExists,%TreeNodeName%)
			;msgbox % SelfExists
			TV_GetText(ParentExists,%ParentFileName%)
			
			if (!SelfExists)
			{
				IfExist, %U_NotePath%%RealParentFileName%.txt
				{
				if (ParentExists)
					{
						%TreeNodeName% := TV_Add( Note.2,%ParentFileName%,"Expand")
					}
				}else
				{
					if (!ParentExists)
					{
						%ParentFileName% := TV_Add( Note.12,,"Bold Expand")
						TVneeded++
					}
				
					%TreeNodeName% := TV_Add( Note.2,%ParentFileName%,"Expand")
				}
			}
		}
	}
	;TVcurrent := TV_GetCount()
	;msgbox % TVcurrent "::" TVneeded
	if (TV_GetCount() == LastCount)
	{
		msgbox failed at %LastCount% of %TVneeded% 
		For Each, Note In MyNotesArray
		{
			if (Note.12)
			{
				ParentFileName := NameEncodeSticky(Note.12)
				ParentFileName := trim(ParentFileName)
				TreeNodeName := NameEncodeSticky(Note.2)
				TreeNodeName := trim(TreeNodeName)
				
				SelfExists := TV_Get(%TreeNodeName%,"Bold")
				ParentExists := TV_Get(%ParentFileName%,"Bold")
				if (ParentExists == 0)
				{
					msgbox Parent Failed: %TreeNodeName% Because: %ParentFileName%
				}
				if (SelfExists == 0)
				{
					msgbox Self Failed: %TreeNodeName% Because: %ParentFileName%
				}
			}
		}
		goto FailBreak
	}
}
} ;end of star parent else
return

GuiContextMenu:
	LV_GetText(RowText, LVSelectedROW,2)
	FileSafeName := NameEncode(RowText)
	if (A_GuiControl=="StoreBookmark" OR RC18 == 1 ) {
		RC18 = 0
		if GetKeyState("Shift"){
			MsgBox, 4404,Delete?,Delete Bookmark?
				IfMsgBox No
					return
				FileRecycle,%bookmarkPath%%FileSafeName%.lnk
				GuiControl,text,StoreBookmark, %LinkSymbol%
				LV_Modify(LVSelectedROW,,,,,,,,,,,,,,,,,,,A_Space)
				return
		}
	if (FileExist(bookmarkPath FileSafeName ".lnk")){
	MsgBox, 4404, , Bookmark for: "%FileSafeName%.lnk" already exists overwrite it?
	IfMsgBox No
		return
	FileRecycle,%bookmarkPath%%FileSafeName%.lnk
	}
	FileCreateShortcut, %clipboard%, %bookmarkPath%%FileSafeName%.lnk
	Iniwrite, 1, %detailsPath%%FileSafeName%.ini,INFO,Bookmark
	GuiControl,text,StoreBookmark, %BookmarkSymbol%
	LV_Modify(LVSelectedROW,,,,,,,,,,,,,,,,,,,BookmarkSymbol)
	GetCurrentNoteData(FileSafeName)
	SaveFile(C_Name,C_SafeName,C_File,1,C_Tags,C_Cat,C_Parent)
}
if (A_GuiControl=="StoreClipboard" OR RC17 == 1 ) {
	RC17 = 0
	if GetKeyState("Shift"){
		MsgBox, 4404,Delete?,Delete stored Clipboard?
			IfMsgBox No
				return
			FileRecycle,%clipPath%%FileSafeName%.clipboard
			Iniwrite, A_space, %detailsPath%%FileSafeName%.ini,INFO,Clip
			GuiControl,text,StoreClipboard, %DiskSymbol%
			LV_Modify(LVSelectedROW,,,,,,,,,,,,,,,,,,A_space)
			return
	}
	if (FileExist(clipPath FileSafeName ".clipboard")){
		MsgBox, 4404, , "%FileSafeName%.clipboard" already exists overwrite it?
		IfMsgBox No
			return
		FileRecycle,%clipPath%%FileSafeName%.clipboard
	}
	Fileappend,%ClipboardAll%,%clipPath%%FileSafeName%.clipboard
	Iniwrite, 1, %detailsPath%%FileSafeName%.ini,INFO,Clip
	GuiControl,text,StoreClipboard, %SaveSymbol%
	LV_Modify(LVSelectedROW,,,,,,,,,,,,,,,,,,SaveSymbol)
	GetCurrentNoteData(FileSafeName)
	SaveFile(C_Name,C_SafeName,C_File,1,C_Tags,C_Cat,C_Parent)
}
if (A_GuiControl=="StoreRun" OR RC16 == 1){
	RC16 = 0
	Iniread, ScriptExists, %detailsPath%%FileSafeName%.ini,INFO,RunType
	if GetKeyState("Shift"){
		MsgBox, 4404,Delete?,Delete stored Script?
			IfMsgBox No
				return
			FileRecycle,%ScriptPath%%FileSafeName%.%RunType%
			Iniwrite, A_Space, %detailsPath%%FileSafeName%.ini,INFO,RunType
			GuiControl,text,StoreRun, %RunIcon%
			LV_Modify(LVSelectedROW,,,,,,,,,,,,,,,,,A_Space)
			return
	}
	if (ScriptExists == "AHK"){
		ExistsWARNING = WARNING: An .AHK file exists for this note.
	} else if (ScriptExists == "BAT"){
		ExistsWARNING = WARNING: A .BAT file exists for this note.
	} else{
		ExistsWARNING :=
	}
	
	SetTimer, TypeMsgButtonNames, 50
	MsgBox, 4387,Script Type, Save Clipboard content as...`n%ExistsWARNING%
	IfMsgBox Yes
		SaveTypeAs = AHK
	IfMsgBox No 
		SaveTypeAs = BAT
	IfMsgBox Cancel
		return
	
	FileRecycle,%ScriptPath%%FileSafeName%.AHK
	FileRecycle,%ScriptPath%%FileSafeName%.BAT
	
	if (SaveTypeAs == "AHK"){
		GuiControl,text,StoreRun, %TypeAIcon%
		Iniwrite, AHK, %detailsPath%%FileSafeName%.ini,INFO,RunType
		Fileappend,%Clipboard%,%ScriptPath%%FileSafeName%.%SaveTypeAs%
		LV_Modify(LVSelectedROW,,,,,,,,,,,,,,,,,TypeAIcon)
	}else{
		GuiControl,text,StoreRun, %TypeBIcon%
		Iniwrite, BAT, %detailsPath%%FileSafeName%.ini,INFO,RunType
		Fileappend,%Clipboard%,%ScriptPath%%FileSafeName%.%SaveTypeAs%
		LV_Modify(LVSelectedROW,,,,,,,,,,,,,,,,,TypeBIcon)
		GetCurrentNoteData(FileSafeName)
		SaveFile(C_Name,C_SafeName,C_File,1,C_Tags,C_Cat,C_Parent)
	}
}

return

TypeMsgButtonNames:
IfWinNotExist, Script Type
	return  ; Keep waiting.
SetTimer, TypeMsgButtonNames, Off 
WinActivate 
ControlSetText, Button1, &AHK 
ControlSetText, Button2, &BAT 
return

RestoreClipboard:
	LV_GetText(RowText, LVSelectedROW,2)
	FileSafeName := NameEncode(RowText)
	if (FileExist(clipPath FileSafeName ".clipboard")){
		FileRead, clipboard, *c %clipPath%%FileSafeName%.clipboard
	}
return

FilterClip:
	ClipFilterActive++
	FilterClipSearch:
	if (ClipFilterActive==1){
		GuiControl,text,SortClip, %SaveSymbol%
		Mloops := LV_GetCount()
		while (Mloops--)
		{
			LV_GetText(RowVar,Mloops+1,17)
			if (RowVar == a_space)
				LV_Delete(Mloops+1)
			if (Mloops = 0)
				break
		}
		if (LV_GetCount()>0){
			LV_Modify(1, "Select Focus Vis")
		}
		Gui, Font, s%ResultFontSize% Q%FontRendering% c%U_MSFC%, %ResultFontFamily%, %U_SFC%
		GuiControl, Font, SortClip
	}else {
		GuiControl,text,SortClip, %DiskSymbol%
		ClipFilterActive = 0
		gosub Search
		Gui, Font, s%ResultFontSize% Q%FontRendering% c%U_SFC%, %ResultFontFamily%, %U_SFC%
		GuiControl, Font, SortClip
	}
return

GotoBookmark:
	LV_GetText(RowText, LVSelectedROW,2)
	FileSafeName := NameEncode(RowText)
	if (FileExist(bookmarkPath FileSafeName ".lnk")){
		Run % bookmarkPath FileSafeName ".lnk",,UseErrorLevel
		if (ErrorLevel=="ERROR"){
			msgbox,262160,ERROR, BAD .lnk
		}
	}
return

FilterBookmark:
	BookmarkFilterActive++
	FilterBookmarkSearch:
	if (BookmarkFilterActive==1){
		GuiControl,text,SortBookmark, %BookmarkSymbol%
		Mloops := LV_GetCount()
		while (Mloops--)
		{
			LV_GetText(RowVar,Mloops+1,18)
			if (RowVar == a_space)
				LV_Delete(Mloops+1)
			if (Mloops = 0)
				break
		}
		if (LV_GetCount()>0){
			LV_Modify(1, "Select Focus Vis")
		}
		Gui, Font, s%ResultFontSize% Q%FontRendering% c%U_MSFC%, %ResultFontFamily%, %U_SFC%
		GuiControl, Font, SortBookmark
	}else {
		GuiControl,text,SortBookmark, %LinkSymbol%
		BookmarkFilterActive = 0
		gosub Search
		Gui, Font, s%ResultFontSize% Q%FontRendering% c%U_SFC%, %ResultFontFamily%, %U_SFC%
		GuiControl, Font, SortBookmark
	}
return

RunStoredCommand:
	LV_GetText(RowText, LVSelectedROW,2)
	FileSafeName := NameEncode(RowText)
	iniRead,RunTypeAs,%detailsPath%%FileSafeName%.ini,INFO,RunType
	if (FileExist(scriptPath FileSafeName "." RunTypeAs)){
		Run % scriptPath FileSafeName "." RunTypeAs
	}
return

FilterScript:
	ScriptFilterActive++
	FilterScriptSearch:
	if (ScriptFilterActive==1){
		GuiControl,text,SortScript, %TypeAIcon%
		Mloops := LV_GetCount()
		while (Mloops--)
		{
			LV_GetText(RowVar,Mloops+1,16)
			if (RowVar != TYpeAIcon)
				LV_Delete(Mloops+1)
			if (Mloops = 0)
				break
		}		
		if (LV_GetCount()>0){
			LV_Modify(1, "Select Focus Vis")
		}
		Gui, Font, s%ResultFontSize% Q%FontRendering% c%U_MSFC%, %ResultFontFamily%, %U_SFC%
		GuiControl, Font, SortScript
	} else if (ScriptFilterActive==2){
		GuiControl,text,SortScript, %TypeBIcon%
		
		if (TypeBUpdate == 1) {
		gosub Search
		}
		TypeBUpdate = 1
		Mloops := LV_GetCount()
		while (Mloops--)
		{
			LV_GetText(RowVar,Mloops+1,16)
			if (RowVar != TypeBIcon)
				LV_Delete(Mloops+1)
			if (Mloops = 0)
				break
		}
		if (LV_GetCount()>0){
			LV_Modify(1, "Select Focus Vis")
		}
	} else {
		GuiControl,text,SortScript, %RunIcon%
		ScriptFilterActive = 0
		gosub Search
		Gui, Font, s%ResultFontSize% Q%FontRendering% c%U_SFC%, %ResultFontFamily%, %U_SFC%
		GuiControl, Font, SortScript
	}
return


MakeSticky:
	if !LastRowSelected
		LastRowSelected=1
	LV_GetText(StickyNoteName,LastRowSelected,2)
	LV_GetText(StickyNoteFile,LastRowSelected,8)
	Build_Stickynote_GUI(StickyNoteName,StickyNoteFile)
return

BuildTreeUI:

If (TreeFristRun == 1)
{
	Gui, tree:New,, FlatNote - Tree
	Gui, tree:+Resize
	Gui, tree:Margin , 2, 2 
	Gui, tree:Font, s%TitleBarFontSize% Q%FontRendering%, Verdana, %U_MFC%
	Gui, tree:Color,%U_SBG%, %U_MBG%

	Gui, tree:Add, TreeView, h%TreeCol1H% w%TreeCol1W% x%TreeCol1X% y0 hwndHTV -Hscroll AltSubmit +0x2 +0x1000 +E0x4000 -E0x200 %UseCheckBoxesTrue% gTreeViewInteraction  vTVNoteTree c%U_FBCA%
	
	;needed to center in color if name is ediable. Currently it is not, because I don't care if it is.
	;Gui, tree:Add, listbox, vTVBGLB1 +0x100 r1 w%TreeCol2W% x%TreeCol2X% y1 -E0x200 Disabled -Tabstop c000000
	
	
	Gui, tree:Add,Edit, center y7 x%TreeCol2X% h%TreeNameH% w%TreeCol2W% vTVNoteName hwndHTVN c%U_FBCA% -E0x200 readonly, 
	Gui, tree:Add, Edit, x%TreeCol2X% y%TreePreviewY% h%TreePreviewH% w%TreeCol2W% hwndHTVB vTVNotePreview -E0x200 c%U_FBCA%,
	
	gui, tree:add, button, default x-4000 y-4000 gTreeViewSave, &Save
	;Gui, tree:Add, Button, x%TreeW% y15 h%TreePreviewH% w111,test
	TreeFristRun = 0
}

if (TVReDraw == 1)
{
	TVReDraw = 0
	gosub RefreshTV
}
FailBreak:
TVBuilt = 1
gosub TreeViewInteraction
;LVM_ShowScrollBar(HTV,1,false)
Gui, tree:SHOW, h%TreeLibH% w%TreeLibW%
return

TreeViewInteraction:
;ttip := A_EventInfo "::" A_GuiEvent
;tooltip, %ttip%
;SetTimer, KillToolTip, -5000
if (A_GuiEvent = "Normal" or A_GuiEvent = "F" or A_GuiEvent = "K")
{
;LVM_ShowScrollBar(HTV,1,true)
}
if (A_GuiEvent = "f")
{
;LVM_ShowScrollBar(HTV,1,false)
}
if (TVBuilt == 1)
{
	TVBuilt = 0
	TopTV := TV_GetNext()
	TV_GetText(SelectedName, TopTV)
	FileSafeName := NameEncode(SelectedName)
	gosub TreeViewUpdate
}

if (A_GuiEvent = "S")
{
	;msgbox % A_EventInfo
	TV_GetText(SelectedName, A_EventInfo)
	FileSafeName := NameEncode(SelectedName)
	gosub TreeViewUpdate
}
return

TreeViewUpdate:
IfExist, %U_NotePath%%FileSafeName%.txt
	{
		FileRead, MyFile, %U_NotePath%%FileSafeName%.txt
		IniRead, OldStarData, %detailsPath%%FileSafeName%.ini,INFO,Star
		OldStarData := ConvertStar(OldStarData)
		IniRead, OldCatData, %detailsPath%%FileSafeName%.ini,INFO,Cat
		IniRead, OldTagsData, %detailsPath%%FileSafeName%.ini,INFO,Tags
		IniRead, OldParentData, %detailsPath%%FileSafeName%.ini,INFO,Parent
		;GuiControl,, QuickNoteParent, %OldParentData%
		;GuiControl,, QuickNoteTags, %OldTagsData%
		;GuiControl, ChooseString, QuickNoteCat, %OldCatData%
		;GuiControl,, QuickNoteBody,%MyFile%
		;GuiControl,, QuickStar,%OldStarData%
		GuiControl,,TVNoteName,%SelectedName%
		GuiControl,,TVNotePreview,%MyFile%
	}
return

TreeViewSave:
GuiControlGet, TVNoteName
T_safename := NameEncode(TVNoteName)
GetCurrentNoteData(T_safename)
GuiControlget, TVNotePreview

SaveFile(C_Name,C_SafeName,TVNotePreview,1,C_Tags,C_Cat,C_Parent)
return

treeGuiClose:
treeGuiEscape:
	Gui, tree:HIDE
return