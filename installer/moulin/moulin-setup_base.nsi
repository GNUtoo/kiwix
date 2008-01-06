
!define CSIDL_APPDATA '0x1A' ;Application Data path
!define CSIDL_LOCALAPPDATA '0x1C' ;Local Application Data path

!define PRODUCT_NAME "moulin"
!define PRODUCT_VERSION "1.0"
!define PRODUCT_PUBLISHER "Kunnafoni Foundation"
!define PRODUCT_WEB_SITE "http://www.moulinwiki.org"

!define PRODUCT_UNINST_KEY "Software\Microsoft\Windows\CurrentVersion\Uninstall\${PRODUCT_NAME}"
!define PRODUCT_UNINST_ROOT_KEY "HKLM"

!include "MUI.nsh"
!include "WinMessages.nsh"
!include "LogicLib.nsh"

SetCompressor lzma ; Zlib supports "SetCompress off"
Name "${PRODUCT_NAME} ${PRODUCT_VERSION}"
OutFile "moulin-setup.exe"
ShowInstDetails show
ShowUnInstDetails show
InstallDir "$PROGRAMFILES\moulin"

!define MUI_FINISHPAGE_RUN "moulin.exe"

; Global variables
Var PAGETOKEEP

; Useful macro
!macro SendDlgItemMessage DLG ITEM MSG WPARAM LPARAM
  Push $R0
  GetDlgItem $R0 ${DLG} ${ITEM}
  SendMessage $R0 ${MSG} ${WPARAM} ${LPARAM}
  Pop $R0
!macroend

; Pages
Page custom PageCreate PageLeave

!define MUI_PAGE_CUSTOMFUNCTION_PRE LicensePage_Pre
!define MUI_PAGE_CUSTOMFUNCTION_SHOW CommonPage_Show
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE CommonPage_Leave
!insertmacro MUI_PAGE_LICENSE "../moulin/COPYING"

!define MUI_PAGE_CUSTOMFUNCTION_PRE DirectoryPage_Pre
!define MUI_PAGE_CUSTOMFUNCTION_SHOW CommonPage_Show
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE CommonPage_Leave
!insertmacro MUI_PAGE_DIRECTORY

!define MUI_PAGE_CUSTOMFUNCTION_PRE ComponentsPage_Pre
!define MUI_PAGE_CUSTOMFUNCTION_SHOW CommonPage_Show
!define MUI_PAGE_CUSTOMFUNCTION_LEAVE CommonPage_Leave
!insertmacro MUI_PAGE_COMPONENTS

!insertmacro MUI_PAGE_INSTFILES

!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

Function .onInit
  !insertmacro MUI_INSTALLOPTIONS_EXTRACT "moulin-setup.ini"
FunctionEnd

LangString READYPAGE_TITLE ${LANG_ENGLISH} "Ready to install"
LangString READYPAGE_SUBTITLE ${LANG_ENGLISH} "The installation wizard is ready to install."

Function PageCreate
  !insertmacro MUI_HEADER_TEXT "$(READYPAGE_TITLE)" "$(READYPAGE_SUBTITLE)"
  !insertmacro MUI_INSTALLOPTIONS_DISPLAY "moulin-setup.ini"
FunctionEnd

Function PageLeave
  !insertmacro MUI_INSTALLOPTIONS_READ $R0 "moulin-setup.ini" "Settings" "State"
  ${Select} $R0
    ${Case} 0
      StrCpy $PAGETOKEEP "none"
    ${Case} 1
      StrCpy $PAGETOKEEP "license"
    ${Case} 3
      StrCpy $PAGETOKEEP "directory"
      SendMessage $HWNDPARENT 0x408 2 0
    ${Case} 5
      StrCpy $PAGETOKEEP "components"
      SendMessage $HWNDPARENT 0x408 3 0
    ${Default}
      Abort
  ${EndSelect}
FunctionEnd

;  FindWindow $R0 "#32770" "" $HWNDPARENT 0 ; Get inner dialog

Function CommonPage_Show
  ${If} $PAGETOKEEP != "license"
    GetDlgItem $R0 $HWNDPARENT 1
    SendMessage $R0 ${WM_SETTEXT} 0 "STR:OK"
  ${EndIf}
FunctionEnd

Function CommonPage_Leave
  SendMessage $HWNDPARENT ${WM_COMMAND} 3 0
  Abort
FunctionEnd

Function LicensePage_Pre
  Push "license"
  Call ShouldSkipPage
  Pop $R0
  ${If} $R0 == 1
    Abort
  ${EndIf}
FunctionEnd

Function DirectoryPage_Pre
  Push "directory"
  Call ShouldSkipPage
  Pop $R0
  ${If} $R0 == 1
    Abort
  ${EndIf}
FunctionEnd

Function ComponentsPage_Pre
  Push "components"
  Call ShouldSkipPage
  Pop $R0
  ${If} $R0 == 1
    Abort
  ${EndIf}
FunctionEnd


; Push textual page id and it returns 1 if the page should be skipped
Function ShouldSkipPage
  Exch $R0
  ${If} $PAGETOKEEP == $R0
    StrCpy $R0 0
  ${Else}
    StrCpy $R0 1
  ${EndIf}
  Exch $R0
FunctionEnd

Section
  CreateDirectory `$INSTDIR`
; copy here the list of files to install (everything inside moulin/ directory.
; you can use the ruby script file-list.rb to generate this list.
; /!\ You also need to include this files list into the uninstall section.
;  CopyFiles `..\moulin\sample` `$INSTDIR`

	
	CopyFiles `..\moulin\defaults\installed` `$INSTDIR`
	AddSize 512000 ; 500MB
SectionEnd

Section /o "Uncompress Datas"
; 	nsexec::exectolog `"$EXEDIR\bunzip2.exe" "$INSTDIR\datas\fr\encyclopedia\0.bz2"`
;	Copy here the list of format files to copy.
	
	AddSize 1048576 ; 1GB
SectionEnd

Section -AdditionalIcons
	SetOutPath $INSTDIR
	WriteIniStr "$INSTDIR\${PRODUCT_NAME}.url" "InternetShortcut" "URL" "${PRODUCT_WEB_SITE}"
	CreateDirectory "$SMPROGRAMS\moulin"
	CreateShortCut "$SMPROGRAMS\moulin\moulin.lnk" "$INSTDIR\moulin.exe"
	CreateShortCut "$SMPROGRAMS\moulin\moulin Website.lnk" "$INSTDIR\${PRODUCT_NAME}.url"
	CreateShortCut "$SMPROGRAMS\moulin\Uninstall.lnk" "$INSTDIR\uninst.exe"
SectionEnd

Section -Post
	WriteUninstaller "$INSTDIR\uninst.exe"
	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayName" "$(^Name)"
	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "UninstallString" "$INSTDIR\uninst.exe"
	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "DisplayVersion" "${PRODUCT_VERSION}"
	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "URLInfoAbout" "${PRODUCT_WEB_SITE}"
	WriteRegStr ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}" "Publisher" "${PRODUCT_PUBLISHER}"
SectionEnd

Function un.onUninstSuccess
	HideWindow
	MessageBox MB_ICONINFORMATION|MB_OK "$(^Name) was successfully removed from your computer."
FunctionEnd

Section Uninstall
; You don' t need to specify file to remove since we remove the whole
; $INSTDIR folder recursivly.

	Delete "$INSTDIR\${PRODUCT_NAME}.url"
	Delete "$INSTDIR\uninst.exe"
	Delete "$SMPROGRAMS\moulin\Uninstall.lnk"
	Delete "$SMPROGRAMS\moulin\moulin.lnk"
	Delete "$SMPROGRAMS\moulin\moulin Website.lnk"

	RMDir /R "$SMPROGRAMS\moulin"
	RMDir /R "$INSTDIR"
	DeleteRegKey ${PRODUCT_UNINST_ROOT_KEY} "${PRODUCT_UNINST_KEY}"

	MessageBox MB_ICONQUESTION|MB_YESNO|MB_DEFBUTTON2 "Do you want to KEEP your personnal datas (bookmarks, notes) ?" IDYES +2
	Call un.full

	SetAutoClose true
SectionEnd

Function un.full
	System::Call 'shell32::SHGetSpecialFolderPathA(i $HWNDPARENT, t .r1, i ${CSIDL_APPDATA}, b 'false') i r0'
    RMDir /r "$1\Kunnafoni"
    System::Call 'shell32::SHGetSpecialFolderPathA(i $HWNDPARENT, t .r1, i ${CSIDL_LOCALAPPDATA}, b 'false') i r0'
    RMDir /r "$1\Kunnafoni"
FunctionEnd
