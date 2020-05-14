SetUserHotKeys() {
	IniRead, savedHK1, %iniPath%, Hotkeys, 1, #o
	IniRead, savedHK2, %iniPath%, Hotkeys, 2, #n
	if (savedHK1="")
		savedHK1=#o
		IniWrite,#o,%iniPath%,Hotkeys, 2
	if (savedHK2="")
		savedHK2=#n
		IniWrite,#n,%iniPath%,Hotkeys, 2
	Hotkey,%savedHK1%, Label1
	Hotkey,%savedHK2%, Label2
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

BuildGUI1(){
	
	if WinExist("FlatNotes - Library") {
		Gui, 1:destroy
		return
	}
	firstDown = 1
	MouseGetPos, xPos, yPos	
	xPos /= 1.5
	yPos /= 1.5
	Gui, 1:New,, FlatNotes - Library
	Gui, 1:Margin , 0, 0
	Gui, 1:Font, s%FontSize%, %FontFamily%, %U_SFC%
	Gui, 1:Color,%U_SBG%, %U_MBG%
	Gui, 1:Add,Edit, c%U_FBCA% w%LibW% y8 x6 vSearchTerm gSearch -E0x200
	Gui, 1:Add, text, c%U_SFC% w%NameColW% center gSortName vSortName, Name
	Gui, 1:Add, text, c%U_SFC% xp+%NameColW% yp+1 w%BodyColW% center gSortBody vSortBody, Body
	Gui, 1:Add, text, yp+1 xp+%BodyColW% w75 center c%U_MSFC% gSortAdded vSortAdded, Added
	Gui, 1:Add, ListView, -E0x200 -hdr LV0x10000 -ReadOnly grid r%ReR% w%libWAdjust% x0 C%U_MFC% vLV hwndHLV gNoteListView +altsubmit -Multi, Title|Body|Created|FileName
	Gui, 1:Add,Edit, r0 h0  vFake,
	GuiControl, Hide, Fake
	Gui, 1:Add,Text, r1 w%LibW% Center C%U_SFC% vNoteDetailPreviewBox gNoteDetailPreviewBoxClick,
	Gui, 1:Add,Edit,  -E0x200 r%PreR% w%LibW% yp+18 x0 C%U_MFC% vPreviewBox,
	
	MakeFileList()
	CLV := New LV_Colors(HLV)
	CLV.SelectionColors(rowSelectColor,rowSelectTextColor)
	
	;ListBox used as background color for search area padding
	Gui, 1:Add, ListBox, h44 w%LibW% x0 y0 -E0x200 Disabled -0x100 
	
	Gui, 1:SHOW, w%SubW%  x%xPos% y%yPos%
	isFristRun = 0
	return
}

BuildGUI2(){
FileSafeClipBoard := RegExReplace(clipboard, "\*|\?|\||/|""|:|<|>"yyyy , Replacement := "_")
CheckForOldNote = %U_NotePath%%FileSafeClipBoard%.txt
FileRead, OldNoteData, %CheckForOldNote%
MouseGetPos, xPos, yPos
xPos /= 1.5
yPos /= 1.15
Gui, 2:New,, FlatNote - QuickNote
Gui, 2:Margin , 0, 0
Gui, 2:Font, s10, Verdana, white
Gui, 2:Color,%U_SBG%, %U_MBG%
Gui, 2:Add,Edit, C%U_MFC% w250 vQuickNoteName gQuickSafeNameUpdate
Gui, 2:Add,Edit, -WantReturn C%U_MFC% r7 w500 vQuickNoteBody
Gui, 2:Add,Text, C%U_SFC% x255 y3 w245 vFileSafeName,
Gui, 2:Add, Button,x-1000 default gSaveButton y-1000, &Save
Gui, 2:SHOW, w500 h145 x%xPos% y%yPos%
return
}

MakeFileList(){
	FileList := ""
	MyNotesArray := {}
	Loop, Files, %U_NotePath%*.txt
		FileList .= A_LoopFileName "`n"
;trim off the extra starting newline
	FileList := RTrim(Filelist, "`n")
	Loop Parse, FileList, `n
	{
		NoteField := ""
		OldNoteField = NoteField
		FileReadLine, NoteDetails, %U_NotePath%%A_LoopField%, 1
		FileReadLine, NoteField, %U_NotePath%%A_LoopField%, 2
		
		DetailsSplitArray := StrSplit(NoteDetails ,"||")
		NameField := DetailsSplitArray[1]
		NameField := StrReplace(NameField, A_space,,, Limit := 1)
		AddedField := DetailsSplitArray[2]
		AddedField := LTrim(AddedField, " C:")
		AddedField := RTrim(AddedField, " ")
		ModifiedField := DetailsSplitArray[2]
		ModifiedField := LTrim(ModifiedField, " M:")
		
		
		LV_Add("", NameField, NoteField, AddedField,A_LoopField)
		if (isFristRun != 0){
			MyNotesArray.Push({1:NameField,2:NoteField,3:AddedField,4:A_LoopField})
		}
	} ; File loop end
	LV_ModifyCol(1, NameColW) ; 145
	LV_ModifyCol(1, "Logical")
	LV_ModifyCol(2, BodyColW) ; 275
	LV_ModifyCol(2, "Logical")
	LV_ModifyCol(3, 75)
	LV_ModifyCol(3, "Logical")
	LV_ModifyCol(3, "SortDesc")
	LV_ModifyCol(3, "Center")
	LV_ModifyCol(4, 0)
	return
}

MakeFileListNoRefresh(){
FileList := ""
MyNotesArray := {}
Loop, Files, %U_NotePath%*.txt
    FileList .= A_LoopFileName "`n"
;trim off the extra starting newline
	FileList := RTrim(Filelist, "`n")
Loop Parse, FileList, `n
	{
		NoteField := ""
		FileReadLine, NoteDetails, %U_NotePath%%A_LoopField%, 1
		FileReadLine, NoteField, %U_NotePath%%A_LoopField%, 2
		DetailsSplitArray := StrSplit(NoteDetails ,"||")
		NameField := DetailsSplitArray[1]
		NameField := RTrim(NameField, " ")
		AddedField := DetailsSplitArray[2]
		AddedField := LTrim(AddedField, " C:")
		AddedField := RTrim(AddedField, " ")
		ModifiedField := DetailsSplitArray[2]
		ModifiedField := LTrim(ModifiedField, " M:")
		if (isFristRun != 0){
			MyNotesArray.Push({1:NameField,2:NoteField,3:AddedField,4:A_LoopField})
			}
	} ; File loop end
LV_ModifyCol(1, "145 Logical")
LV_ModifyCol(2, "275")
LV_ModifyCol(3, "75")
LV_ModifyCol(4, "0")
return
}

ReFreshLV(){
global SearchTerm
GuiControlGet, SearchTerm
GuiControl, -Redraw, LV
LV_Delete()
For Each, Note In MyNotesArray
{
		If (InStr(Note.1, SearchTerm) != 0){
         LV_Add("", Note.1, Note.2,Note.3,Note.4)
        }Else if (InStr(Note.2, SearchTerm) != 0)
	   {LV_Add("", Note.1, Note.2,Note.3,Note.4)
	   }Else if (InStr(Note.3, SearchTerm) != 0)
	   {LV_Add("", Note.1, Note.2,Note.3,Note.4)
	   }Else if (InStr(Note.4, SearchTerm) != 0)
	   {LV_Add("", Note.1, Note.2,Note.3,Note.4)
	   }Else
	   
      LV_Add("", Note.1,Note.2,Note.3,Note.4)
	  GuiControl, +Redraw, LV
}
return
}

SaveFile(QuickNoteName,FileSafeName,QuickNoteBody) {
	FormatTime, CurrentTimeStamp, %A_Now%, yy/MM/dd

	SaveFileName = %U_NotePath%%FileSafeName%.txt
	FileReadLine, OldDetails, %SaveFileName%, 1
	 RegExMatch(OldDetails, "\d\d/\d\d/\d\d" , CreatedDate)
	 QuickNoteBody := SubStr(QuickNoteBody, InStr(QuickNoteBody, "`n") + 1)
	if (CreatedDate =="")
	{
	CreatedDate = %CurrentTimeStamp%
	}
	FileRecycle, %SaveFileName%
	FileLineOne = %QuickNoteName% || C:%CreatedDate% || M:%CurrentTimeStamp%`n
	FileAppend , %FileLineOne%%QuickNoteBody%, %SaveFileName%, UTF-8
return
}
Add(x, y)
{
	return x + y
}