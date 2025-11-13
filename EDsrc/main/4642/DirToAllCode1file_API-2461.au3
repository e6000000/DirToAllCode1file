#include-once
#Region
; master:        DirToAllCode1file_API-2450.au3
#include <MsgBoxConstants.au3>
#include <StringConstants.au3>
#include <String.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#include <ButtonConstants.au3>
#include <GUIListBox.au3>
#include <EditConstants.au3>
#include <Debug.au3>
#include <Array.au3>
#include <Math.au3>
#include <File.au3>
; master: DirToAllCode1file_API-2460.au3; Slave inc func DirToAll_MarkerFiles  DirToAll_init  DirToAll_GetSetArr
#include "DirToAll_MarkerFiles-2460.au3"
#include "DirToAll_init-2460.au3"
#include "DirToAll_GetSetArr-2460.au3"


#cs ;;//   DirToAll_MarkerFiles[2440].au3
##########git#######
2050 gitpush bare  push giteweb and bare (first) push okok







** ToDo:
## marker erzeugung reparieren
## error eg.
////_marker_begin {"ver":"idxq_2443","timestamp":"2025-11-01T18:05:38Z","file":"D:\ws\autoit2020\4chat1file\1file\files_out_2443\files_out\D:\ws\autoit2020\4chat1file\files\5batINC.au3"}
## folder name ist doppelt drinn

## correct
////_marker_begin {"ver":"idxq_2443","timestamp":"2025-11-01T18:05:38Z","file":"D:\ws\autoit2020\4chat1file\files\5batINC.au3"}

## veraender den code nicht , nenne die stelle / stellen und den code der zu aendern ist , ;OLDCODE: , ;NEWCODE:
#####################
find explorer:  content:FileWriteMy  ext:au3
alle 2040 .bak in d ws autoit2020 .bak
#######################
bitte hilfe fuer wirkungsvolle promt formulierung


in mein gelieferten file steht ausdruecklich:   "set prj MUST in LINE 2"
"""
@ECHO OFF
set "prj=DirToAllCode1file_API"
:: set prj MUST in LINE 2 :: ws edit src prj-name-dir ::
"""

und dann bekomme ich von der KI / AI
trotzdem noch files wo das nicht beachtet wird , eg.

"""
@ECHO OFF
SETLOCAL

rem --- Projekt / Pfade (anpassen falls nötig) ---
set "prj=DirToAllCode1file_API"

"""


und antworten , die das auch ignorieren:


Praxisempfehlung: Setze SETLOCAL direkt nach @ECHO OFF, bevor du die wichtigsten Variablen (prj, REPO_DIR, KEY_PATH, FOLDERS, etc.) definierst.


## bitte gib mir formulierungen , sehr kurz in liste oder yaml oder kurz md , fuer den AI promt damit die AI  nicht unnoetig abschweift   und sich immer exact an den context und die anweisung befolgt

noch fragen?

## 2033 tag hinzu
## git push 2033 und 2040 v_xxxx to datim_xxxx
##tst new barePUSH-2041.bat-datime-.bat gpt5

--letzte tag leer:
* Auto-Commit 2025-11-02 23:11:12,09

* Tag Info:
object 1f8000cc89840afa523eedfa3fc0a305a28e2719
type commit
tag datim_001.018.922

--next mit msg=TAGGGINFOOO:
* Tag Info:
object 188bb9ead4a8cb1e8c9c9b65fc43a4550f16a16e
type commit
tag datim_001.019.007
tagger e6000000 <com24ed@gmail.com> 2025-11-02 23:14:07 Uhr

 next mit msg=TAGGGINFOOO  <--> aha msg steht drunter bei tortoise git

NO "" '''' !!!!  space ok    next mit msg=TAGGGINFOOO space
nu gitpush nach paar bare push

#ce
#EndRegion
;#########################################################################################################
; Globale Variablen (NUR Konfiguration, KEIN Zustand)
;#########################################################################################################
Global $dbgg = 1
Global $dbggArDispl = 0
;
; INI-Konfiguration für Einstellungen
; KORREKTUR: Global Const durch Global ersetzt, um Fehler in inkludierten Dateien zu vermeiden
Global $g_sIniFilePath = @ScriptDir & "\settings.ini" ; Pfad zur INI-Datei
Global $g_sIniSessionSection = "Session"               ; Speichert die letzte Sitzung
Global $g_sIniMetadataSection = "Metadata"             ; Speichert Metadaten wie den nächsten Preset-Index
;
; Index-Konfiguration
Global $g_sIndexFilePath = "c:\dat\idxq.txt"
Global $g_sVersionPrefix = "idxq_"
;
; Globale Deklaration der Pfad-Variablen
Global $gInParent = 'D:\ws\youtube-DUBBING-pos-div'
Global $gInSub = 'dubbing_testshort'
Global $gOutParent = 'D:\ws\youtube-DUBBING-pos-div'
Global $gOutSub = 'dubbing_testshort_out'
Global $gAllCodeFile = ''
;
; Filter-Konfiguration
Global $extFilter = '.au3.bat.css.h.html.htm.js.json.svg.txt.tpl.txt'
Global $g_aExtFilterComments[45] = [ _
		"au3", ";;//", "", _
		"bat", "::", "", _
		"css", "/*", "*/", _
		"h", "//", "", _
		"html", "", _
		"htm", "", _
		"mhtml", "", _
		"mht", "", _
		"js", "//", "", _
		"sql", "--", "", _
		"py", "#", "", _
		"svg", "", "", _
		"tpl", "", "", _
		"xml", "", "", _
		"default", ";;//", "" _
		]
Global $g_strExtFilterComments = ar2str($g_aExtFilterComments)
; INFO nu.  Original source files INFO
#cs
Global $sBat1_Orig = $sWorkingDir & "\bareFETCH-2033.bat"
Global $sBat2_Orig = $sWorkingDir & "\barePUSH-2033.bat"
Global $sBat3_Orig = $sWorkingDir & "\gitFETCH-2033.bat"
Global $sBat4_Orig = $sWorkingDir & "\gitPUSH-2033.bat"
Global $sBat5_Orig = $sWorkingDir & "\gitwebCREATE-2033.bat"
#ce
; Marker-Konfiguration (Marker-Text ist Global, Logik ist in Logic_Core)
Local $sLocalMarkerBegin = "////_marker_begin"
Local $sLocalMarkerEnd = "////_marker_end"
;
;
; GUI-Variablen (NUR IDs und Modus-Schalter)
Global $hGUI
Global $idInputInParent, $idInputInSub, $idInputOutParent, $idInputOutSub
Global $idInputAllCodeFile
Global $idInputExtFilter
Global $idBtnApplyExtFilter
Global $idBtnSettings
Global $idBtnLoadPreset, $idBtnSavePreset
Global $idLabelSavePresetNum
Global $idBtnMode0, $idBtnMode1, $idBtnStart
Global $idBtnSelInParent, $idBtnSelInSub, $idBtnSelOutParent, $idBtnSelOutSub
Global $idBtnSelAllCodeFile
Global $idLabelIndex
Global $idBtnIndexNext
Global $iMode = 0
;
;
; #########################################################################################################
; Kernlogik Wrapper
; #########################################################################################################

Func MainWorkflow(ByRef $aSettings)
	; Ruft die Setup-Funktionen aus dem GetSetArr-Modul auf
	$aSettings = _PreparePaths($aSettings)

	If Not IsArray($aSettings) Then Return $aSettings

	; Lokale Variablen werden aus dem Einstellungs-Array gelesen
	Global $extFilter = _GetSetting($aSettings, 'ExtFilter')
	Local $iMode = _GetSetting($aSettings, 'Mode')
	Local $sAllCodeFile = _GetSetting($aSettings, 'AllCodeFile')
	Local $arExtFilter = ArExtFilterFkt()
	Local $sResultList = ""

	If $iMode = 0 Then ; Modus 0: Combine files to 1file (INKLUSIVE MODE 1 RÜCKSCHREIBUNG)
		Local $sFolderIn = _GetSetting($aSettings, 'FolderIn')
		Local $arFil = arFolderFilesAllLists($sFolderIn)
		Local $arExtAll = GetExtensionsFromArray($arFil)
		Local $arExt = FilterExtensions($arExtAll, $arExtFilter)

		; Ruft die Kernlogik aus dem MarkerFiles-Modul auf
		If AppendFilesToAllCode1file_Txt($aSettings, $arFil, $arExt) Then
			ShellExecute($sAllCodeFile)

			; FIX: Führe Modus 1 sofort als Verifikation/Rückschreibung aus
			Local $sExtractionResult = All1file2Folder($aSettings)

			If StringLen($sExtractionResult) > 0 Then
				_SetSetting($aSettings, 'ResultList', $sAllCodeFile)
				MsgBox($MB_ICONINFORMATION, 'Erfolg', "Modus 0 (Combine) abgeschlossen UND Modus 1 (Extract) zur Verifikation erfolgreich ausgeführt. Sammeldatei erstellt: " & $sAllCodeFile)
			Else
				MsgBox($MB_ICONWARNING, 'FEHLER/Warnung', "Modus 0 (Combine) abgeschlossen, aber Modus 1 (Extract) Verifikation fehlgeschlagen || $extFilter ? list:" & $extFilter)
			EndIf

		Else
    	ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : Modus 0 fehlgeschlagen.  @ScriptLineNumber '   & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console

			MsgBox($MB_ICONERROR, 'FEHLER', "Modus 0 fehlgeschlagen. AppendFilesToAllCode1file_Txt()" & @ScriptLineNumber)
		EndIf

	ElseIf $iMode = 1 Then ; Modus 1: Extract files from 1file to Folder (STANDALONE)
		; Ruft die Kernlogik aus dem MarkerFiles-Modul auf
		$sResultList = All1file2Folder($aSettings)

		If StringLen($sResultList) > 0 Then
			_SetSetting($aSettings, 'ResultList', $sResultList)
			MsgBox($MB_ICONINFORMATION, 'Erfolg', "Modus 1 abgeschlossen." & @CRLF & "Dateien extrahiert. Output-Pfade wurden aus der Sammel-Datei abgeleitet.")
		Else
			MsgBox($MB_ICONWARNING, 'FEHLER/Warnung', @ScriptLineNumber & " Modus 1  FEHLER bei der Rückkonvertierung oder keine Marker gefunden. Überprüfen Sie: filename:" & $sAllCodeFile)
		EndIf
	EndIf

	Return $aSettings
EndFunc   ;==>MainWorkflow


; #########################################################################################################
; GUI Haupt-Loop
; #########################################################################################################

Func CreateGUI()
	; Initialisiere Array, lade Index von der Datei (Funktionen aus GetSetArr)
	Local $sInitialIDX = gIDXnum()
	Local $aSettings = _InitializeSettingsArray($sInitialIDX)

	$hGUI = GUICreate("DirToAllCode1file_API-2450.au3 (DirTo1File/1FileToDir)", 600, 630)
	GUISetFont(9, 400, 0, "Arial")

	Local $iLeft = 10, $iTop = 10, $iSpacing = 5
	Local $iWidthAll = 580
    Local $iWidthPresetBtn = 150 ; Breite für die gestapelten  Preset-Buttons
    Local $iHeightDesc = 100

    ; --- Spalte 1: Settings Buttons (Gestapelt und gleich breit) ---
    ; 1. Settings (Edit INI) - Funktion aus DirToAll_init
    Global $idBtnSettings = GUICtrlCreateButton("≡ INI Edit", $iLeft, $iTop, $iWidthPresetBtn, 25)

    ; 2. SAVE AS Button - Funktion aus DirToAll_init
    $iTop += 30
    Local $iNextPresetNum = _GetNextPresetNumber() ; Funktion aus DirToAll_init
    $idBtnSavePreset = GUICtrlCreateButton("SAVE AS [" & $iNextPresetNum & "]", $iLeft, $iTop, $iWidthPresetBtn, 25)

    ; 3. LOAD Preset Button - Funktion aus DirToAll_init
    $iTop += 30
    $idBtnLoadPreset = GUICtrlCreateButton("LOAD Preset", $iLeft, $iTop, $iWidthPresetBtn, 25)

    ; NEU: iTop für die nächste Reihe (Input-Felder) speichern
    Local $iInputAreaStartTop = $iTop + 30

    ; --- Spalte 2: Beschreibender Text ---
    $iTop = 10 ; Zurücksetzen für die Beschreibung
    Local $iDescX = $iLeft + $iWidthPresetBtn + $iSpacing
    Local $iDescW = $iWidthAll - $iWidthPresetBtn - $iSpacing

	Local $sDescription = " this app Do: read all /s SubTree path-in//subDir -- path-out//subDir ---out_To: path-out//subDir_idx_//subDir\\ {hier entpackte files} AND out_To: path-out//subDir_idx_// {AllCode1file.txt} "


	GUICtrlCreateLabel($sDescription, $iDescX, $iTop, $iDescW, $iHeightDesc) ; x-Position und Breite angepasst

    ; Setze iTop für die Eingabefelder
	$iTop = $iInputAreaStartTop

    ; Setze $iWidthInput und $iBtnX für die Eingabefelder (braucht die volle Breite)
    Local $iWidthBtn = 40 ; Breite für die "Dir"/"File" Buttons
    Local $iWidthInput = $iWidthAll - $iWidthBtn - $iSpacing
    Local $iBtnX = $iLeft + $iWidthInput + $iSpacing


	; --- MODIFIKATION: Extension Filter (HINZUGEFÜGT) ---
	; (Position an den Anfang verschoben und Button hinzugefügt, gemäß Bild)
	GUICtrlCreateLabel("Global $extFilter (Mode 0):", $iLeft, $iTop, 400, 20)
	$idInputExtFilter = GUICtrlCreateInput(_GetSetting($aSettings, 'ExtFilter'), $iLeft, $iTop + 20, $iWidthInput, 25)
	$idBtnApplyExtFilter = GUICtrlCreateButton("Set", $iBtnX, $iTop + 20, $iWidthBtn, 25)
	$iTop += 50 +23 ; MODIFIKATION: Abstand 50px (gemäß Bild #2#)

	; --- 1. Eingabefeld: Input Folder Parent ---
	GUICtrlCreateLabel("Input Folder Parent (Mode 0):", $iLeft, $iTop, 300, 20)
	$idInputInParent = GUICtrlCreateInput(_GetSetting($aSettings, 'InParent'), $iLeft, $iTop + 20, $iWidthInput, 25)
	$idBtnSelInParent = GUICtrlCreateButton("Dir", $iBtnX, $iTop + 20, $iWidthBtn, 25)
	$iTop += 50

	;
	; --- 2. Eingabefeld: Input Folder Sub ---
	GUICtrlCreateLabel("Input Folder Sub (Mode 0):", $iLeft, $iTop, 300, 20)
	$idInputInSub = GUICtrlCreateInput(_GetSetting($aSettings, 'InSub'), $iLeft, $iTop + 20, $iWidthInput, 25)
	$idBtnSelInSub = GUICtrlCreateButton("Dir", $iBtnX, $iTop + 20, $iWidthBtn, 25)
	$iTop += 50

	;
	; --- 3. Sammeldatei ($AllCode1file_Txt) ---
	GUICtrlCreateLabel("Sammel-Datei (Mode 1 Input):", $iLeft, $iTop, 400, 20)
	$idInputAllCodeFile = GUICtrlCreateInput(_GetSetting($aSettings, 'AllCodeFile'), $iLeft, $iTop + 20, $iWidthInput, 25)
	$idBtnSelAllCodeFile = GUICtrlCreateButton("File", $iBtnX, $iTop + 20, $iWidthBtn, 25)
	$iTop += 50

	;
	; --- 4. Eingabefeld: Output Folder Parent ---
	GUICtrlCreateLabel("Output Folder Parent (Mode 0):", $iLeft, $iTop, 300, 20)
	$idInputOutParent = GUICtrlCreateInput(_GetSetting($aSettings, 'OutParent'), $iLeft, $iTop + 20, $iWidthInput, 25)
	$idBtnSelOutParent = GUICtrlCreateButton("Dir", $iBtnX, $iTop + 20, $iWidthBtn, 25)
	$iTop += 50

	;
	; --- 5. Eingabefeld: Output Folder Sub ---
	GUICtrlCreateLabel("Output Folder Sub (Mode 0):", $iLeft, $iTop, 300, 20)
	$idInputOutSub = GUICtrlCreateInput(_GetSetting($aSettings, 'OutSub'), $iLeft, $iTop + 20, $iWidthInput, 25)
	$idBtnSelOutSub = GUICtrlCreateButton("Dir", $iBtnX, $iTop + 20, $iWidthBtn, 25)


	$iTop += 50 + 7
	;
	; --- Modus-Auswahl-Buttons ---
	Local $iBtnWMode = 285
	$idBtnMode0 = GUICtrlCreateButton("MODE 0: Combine Files (Dir to 1File)", $iLeft, $iTop, $iBtnWMode, 40)
	$idBtnMode1 = GUICtrlCreateButton("MODE 1: Extract Files (1File to Dir)", $iLeft + $iBtnWMode + $iSpacing, $iTop, $iBtnWMode, 40)

	;
	; Initialer Modus und Farben (Orange = 0xFFA500)
	GUICtrlSetBkColor($idBtnMode0, 0xFFA500)
	GUICtrlSetBkColor($idBtnMode1, 0xD0D0D0)

	$iTop += 50

	;
	; --- Index Label und Start Button Area ---
	Local $iBtnPlus1W = 50
	Local $iStartBtnH = 50
	Local $iIndexW = 115
	Local $iTotalIndexAreaW = $iBtnPlus1W + $iIndexW + $iSpacing
	Local $iStartW = $iWidthAll - $iTotalIndexAreaW - $iSpacing
	Local $iStartBtnX = $iLeft + $iTotalIndexAreaW + $iSpacing

	;
	; +1 Button (Orange und Höhe 50) - Funktion aus DirToAll_GetSetArr
	$idBtnIndexNext = GUICtrlCreateButton("+1", $iLeft, $iTop, $iBtnPlus1W, $iStartBtnH)
	GUICtrlSetBkColor($idBtnIndexNext, 0xFFA500)

	;
	; Index-Anzeige - Funktion aus DirToAll_GetSetArr
	$idLabelIndex = GUICtrlCreateLabel("Index: " & _GetSetting($aSettings, 'Index'), $iLeft + $iBtnPlus1W + $iSpacing, $iTop + 15, $iIndexW, 30)
	GUICtrlSetFont($idLabelIndex, 10, 800)

   Local	 $startBtnTxtLeft = "START EXECUTION"
	$startBtnTxtLeft = "START "

	$idBtnStart = GUICtrlCreateButton( $startBtnTxtLeft &" (Mode: 0)", $iStartBtnX, $iTop, $iStartW, $iStartBtnH)
	GUICtrlSetFont($idBtnStart, 12, 800)
	GUICtrlSetBkColor($idBtnStart, 0xFFA500)

	GUISetState(@SW_SHOW)

	;
	; --- Event Loop ---
	While 1
		Local $iMsg = GUIGetMsg()
		Switch $iMsg
			Case $GUI_EVENT_CLOSE
				; Vor dem Beenden die letzte Sitzung speichern (Funktionen aus DirToAll_GetSetArr und DirToAll_init)
                _ApplyGUIToArray($aSettings)
                _WriteIniSectionSettings($aSettings, $g_sIniSessionSection)
				Exit
			Case $idBtnMode0
				$iMode = 0
				GUICtrlSetBkColor($idBtnMode0, 0xFFA500)
				GUICtrlSetBkColor($idBtnMode1, 0xD0D0D0)
				GUICtrlSetData($idBtnStart, $startBtnTxtLeft &" (Mode: 0)")
			Case $idBtnMode1
				$iMode = 1
				GUICtrlSetBkColor($idBtnMode1, 0xFFA500)
				GUICtrlSetBkColor($idBtnMode0, 0xD0D0D0)
				GUICtrlSetData($idBtnStart, $startBtnTxtLeft &" (Mode: 1)")

			Case $idBtnIndexNext
				; Funktionen aus DirToAll_GetSetArr
				Local $sNewIDX = gIDXnumNEXT()
				_SetSetting($aSettings, 'Index', $sNewIDX)
				GUICtrlSetData($idLabelIndex, "Index: " & $sNewIDX)

            ; INI/Preset Management Handler (Funktionen aus DirToAll_init)
            Case $idBtnSettings ; 1. Button: Edit INI
                _OpenSettingsIni()

            Case $idBtnLoadPreset ; 2. Button: LOAD Preset
                $aSettings = _LoadPresetSelect($aSettings)

            Case $idBtnSavePreset ; 3. Button: SAVE AS Preset
                $aSettings = _SavePresetAsNew($aSettings)


			Case $idBtnStart
                ; Funktionen aus DirToAll_GetSetArr und DirToAll_init
                $aSettings = _ApplyGUIToArray($aSettings)
                _WriteIniSectionSettings($aSettings, $g_sIniSessionSection)

                ; 3. Workflow starten
				$aSettings = MainWorkflow($aSettings)

				Local $sResultPath = _GetSetting($aSettings, 'ResultList')
				Local $sCurrentIDX = _GetSetting($aSettings, 'Index')

				If $iMode = 0 And StringLen($sResultPath) > 0 Then
					GUICtrlSetData($idInputAllCodeFile, $sResultPath)
				EndIf
				GUICtrlSetData($idLabelIndex, "Index: " & $sCurrentIDX)


			Case $idBtnApplyExtFilter
				; Funktionen aus DirToAll_GetSetArr und DirToAll_init
				Global $extFilter = GUICtrlRead($idInputExtFilter)
				_SetSetting($aSettings, 'ExtFilter', $extFilter)
				ToolTip("Global $extFilter wurde aktualisiert.", 0, 0)
                _WriteIniSectionSettings($aSettings, $g_sIniSessionSection)

			Case $idBtnSelInParent, $idBtnSelOutParent, $idBtnSelInSub, $idBtnSelOutSub
				Local $sCurrentPath = GUICtrlRead($iMsg - 1)
				Local $sDir = FileSelectFolder("Wählen Sie den Ordner", $sCurrentPath)
				If $sDir <> "" Then
					If $iMsg = $idBtnSelInParent Or $iMsg = $idBtnSelOutParent Then
						GUICtrlSetData($iMsg - 1, $sDir)
					Else
						GUICtrlSetData($iMsg - 1, StringRegExpReplace($sDir, ".*\\", ""))
					EndIf
				EndIf

			Case $idBtnSelAllCodeFile
				Local $sCurrentFile = GUICtrlRead($idInputAllCodeFile)
				Local $sInitialDir = @ScriptDir
				If StringLen($sCurrentFile) > 0 Then $sInitialDir = StringLeft($sCurrentFile, StringInStr($sCurrentFile, "\", 0, -1) - 1)

				Local $sFileOpen = FileOpenDialog("Wählen Sie die Sammel-Datei (AllCode1file.txt)", $sInitialDir, "Text Files (*.txt)|All Files (*.*)", 1)
				If @error = 0 Then
					GUICtrlSetData($idInputAllCodeFile, $sFileOpen)
				EndIf

		EndSwitch
	WEnd
EndFunc   ;==>CreateGUI

;
; #########################################################################################################
; Skript-Start
; #########################################################################################################

; Initialisiert read from file den Index, bevor die GUI erstellt wird.
gIDXnum()

CreateGUI()

