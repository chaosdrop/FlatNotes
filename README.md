![Screenshot one](/ScreenShots/SS_01.png)

# FlatNotes
A flat file system note taking program made with AHKv1

## New
v3
- Automatic daily backup option
- New Statusbar and option to hide it
- Preview first search result automatically
- Rapid Note [default Win+Z]
	- Win+Z Once to get title
	- Win+Z A second time to get body and save.
	- Win+Shift+Z to Cancel after Title.
	- A toottip will appear showing you the title and first line of the body on each Win+Z.
- Column width settings
	- Set to 0 to hide 

## Feature list:
- Quick search: 
- Searches in all fields.
- Sortable list headers.
- Copy title to click board via Double Click or Enter
- Copy body text by right clicking or Ctrl+Enter
- Edit notes in the preview/Edit box [Enter to save Ctrl+Enter for new line]
- Create new notes using the search box by simply typing a new name and hitting Enter.
- If a note already exists it will be loaded into the the new note editor.
	- Created dates are preserved even when over writing.
- Notes are stored flat on your file system, meaning they are all induvial plain .txt files that you can easily edit with external programs, synced to where you would like, and manage like any other file.

## Hotkeys and Shortcuts:

### Global Hotkeys: (Can be changed in options)
Capslock: Brings up main window

Win+N: Opens the quick note dialog with th select text as the title.

### Interface shortcuts: (Can not be changed yet)

Move to Search box:
Ctrl+S
Alt+S
Ctrl+F
Alt+F

Move to results list:
Ctrl+L
Alt+L

Move to preview/edit box:
Ctrl+p
Alt+p 
Ctrl+f
Alt+f

Search Box:
As you type search.
Enter = Create a New Note from your search.

Results List:
Enter = Save title to clipboard
Ctrl+Enter = Save body to clipboard
Ctrl+Shift+Enter = Save only first line of body to clipboard
Del = Delete selected Item
Slow Click = Change Note & File Name

Preview/edit box:
Enter = Save
Ctrl+Enter = New Line


## Toubleshooting

### Notes will not save
When first started FlatNotes makes a folder called "MyNotes" if you delete this folder or move it you will have to restart FlatNotes or create it yourself. 

### Weird visual glitch 
Try deleting the settings.ini file (make a backup first)

## Themes
![Themes Set one](/ScreenShots/SS_02.png)

## Possible Road Map Ideas
- Import from CSV
- export to CSV
- Insert template layouts
- 

### Things to fix

