#include-once
#include <Array.au3>
#include <File.au3>
#include <String.au3>
#include <Debug.au3>
#include <Math.au3>
#include <WindowsConstants.au3>

; FIX: Globale Variablen, die in der Main-Datei initialisiert werden, nur hier nur als Global deklarieren
Global $g_sIniSessionSection
Global $g_sIniFilePath

; Globale Variablen, die von der Main-Datei benötigt werden:
Global $dbgg, $extFilter
Global $gInParent, $gInSub, $gOutParent, $gOutSub, $gAllCodeFile
Global $g_sIndexFilePath
Global $idInputInParent, $idInputInSub, $idInputOutParent, $idInputOutSub, $idInputAllCodeFile, $idInputExtFilter
Global $iMode

; KORREKTUR: Funktions-Listen entfernt oder korrekt auskommentiert
; Funktionen, die von DirToAll_init[2440].au3 benötigt werden:
; Func _ReadIniSectionSettings(ByRef $aSettings, $sSectionName);

; Funktionen, die von DirToAll_MarkerFiles[2440].au3 benötigt werden:
; Func AppendFilesToAllCode1file_Txt(ByRef $aSettings, ByRef $arFil, ByRef $arExt);
; Func All1file2Folder(ByRef $aSettings);
#cs
Funktion,Code-Stelle(n),Zweck & Logik
_PathCleanBackslashes,Zeile 1039,Entfernt alle doppelten Backslashes (\\) im gesamten Pfad.
_PathEnsureTrailingBackslash,Zeile 1040,"Stellt sicher, dass der Pfad mit einem einzelnen Backslash (\) endet."
_PreparePaths,Zeilen 1061-1062,"Input-Ordner ($sFolderIn): Der finale Eingabeordner wird korrekt als $sInParent + $sInSub generiert. Die Funktion stellt sicher, dass es keine doppelten Schrägstriche gibt und der Pfad korrekt endet."
_PreparePaths,Zeile 1064,"Output-Struktur: Definiert den Pfad zum Extraktionsziel ($sFolderOutExtract) konsistent mit dem erwarteten Layout: \OutParent\OutSub_IDX\OutSub\ (Der Ordner $sOutSub wird innerhalb des Index-Ordners dupliziert, was die aktuelle Soll-Logik ist)."

 Funktion,Code-Stelle(n),Zweck & Logik
AppendFilesToAllCode1file_Txt,Zeile 77,"Relative Pfad-Erzeugung (FIX): Local $sFileNameForMarker = StringReplace($sFullPathFile, $sFolderIn, '', 1, 1)  Der Zusatz , 1, 1 ist der entscheidende Fix. Er stellt sicher, dass der Basispfad ($sFolderIn) nur einmal und nur am Anfang entfernt wird, wodurch nur der relative Pfad (z.B. subfolder\file.txt) übrig bleibt."
AppendFilesToAllCode1file_Txt,Zeile 77,Marker-Zielpfad: Local $sFullTargetPath = $sFolderOutExtract & $sFileNameForMarker  Der finale Pfad für den Marker wird aus dem definierten Zielordner ($sFolderOutExtract) und dem korrekt relativen Pfad ($sFileNameForMarker) zusammengesetzt.
All1file2Folder,Zeile 78,"Regex-Verbesserung: Local $sRegex = '.{0,6}?' & $sLocalMarkerBegin & '.*?""file"":""([^""]+)"".*?'  Die Toleranz für Zeichen vor dem Marker ist auf 6 (.{0,6}?) erhöht worden, was die Robustheit beim Extrahieren verbessert."

#ce
; #########################################################################################################
; 2D Array Helfer-Funktionen (Key-Value-Struktur)
; #########################################################################################################

Func _GetSetting(ByRef $aArray, $sKey)
	; Array Struktur: $aArray[i][0] = KeyName, $aArray[i][1] = Value
	For $i = 0 To UBound($aArray) - 1
		If $aArray[$i][0] = $sKey Then
			Return $aArray[$i][1]
		EndIf
	Next
	Return "" ; Key nicht gefunden
EndFunc   ;==>_GetSetting

Func _SetSetting(ByRef $aArray, $sKey, $vValue)
	; Array Struktur: $aArray[i][0] = KeyName, $aArray[i][1] = Value
	For $i = 0 To UBound($aArray) - 1
		If $aArray[$i][0] = $sKey Then
			$aArray[$i][1] = $vValue
			Return True
		EndIf
	Next
	; Key nicht gefunden, neues Element hinzufügen
	Local $iUBound = UBound($aArray)
	ReDim $aArray[$iUBound + 1][2]
	$aArray[$iUBound][0] = $sKey
	$aArray[$iUBound][1] = $vValue
	Return True
EndFunc   ;==>_SetSetting

; ... (Array-Helper-Funktionen)
Func s2a($s)
	Return _ArrayFromString($s)
EndFunc   ;==>s2a
Func str2ar($s)
	Return _ArrayFromString($s)
EndFunc   ;==>str2ar
Func str2arr($s)
	Return _ArrayFromString($s)
EndFunc   ;==>str2arr
Func a2s($a)
	Return _ArrayToString($a)
EndFunc   ;==>a2s
Func ar2str($a)
	Return _ArrayToString($a)
EndFunc   ;==>ar2str
Func arr2str($a)
	Return _ArrayToString($a)
EndFunc   ;==>arr2str


; #########################################################################################################
; Index, Zeit und Path Normalization Helfer-Funktionen
; #########################################################################################################

Func _PathCleanBackslashes($sPath)
    ; Entfernt alle doppelten Backslashes (\\)
    Local $sCleaned = $sPath
    While StringInStr($sCleaned, '\\')
        $sCleaned = StringReplace($sCleaned, '\\', '\')
    WEnd
    Return $sCleaned
EndFunc ;==>_PathCleanBackslashes

Func _PathEnsureTrailingBackslash($sPath)
    ; Stellt sicher, dass ein Pfad einen abschließenden Backslash hat
    Local $sCleaned = _PathCleanBackslashes($sPath)
    If StringRight($sCleaned, 1) <> '\' Then
        $sCleaned &= '\'
    EndIf
    Return $sCleaned
EndFunc ;==>_PathEnsureTrailingBackslash

Func gIDXnum()
	Local $sIDXnum = StringStripWS(FileRead($g_sIndexFilePath), 3)
	If @error Then $sIDXnum = "1000"
	Return $sIDXnum
EndFunc   ;==>gIDXnum
Func gIDXnumNEXT()
	Local $sIDXnum = gIDXnum()
	If 1000 > Int($sIDXnum) Then $sIDXnum = "1000"
	$sIDXnum = String(1 + Int($sIDXnum))
	FileWriteMy($g_sIndexFilePath, $sIDXnum)
	Return $sIDXnum
EndFunc   ;==>gIDXnumNEXT
Func _GetISO8601Timestamp()
	Local $sTime = StringFormat("%02d", @HOUR) & ":" & StringFormat("%02d", @MIN) & ":" & StringFormat("%02d", @SEC)
	Local $sDate = @YEAR & "-" & StringFormat("%02d", @MON) & "-" & StringFormat("%02d", @MDAY)
	Return $sDate & "T" & $sTime & "Z"
EndFunc   ;==>_GetISO8601Timestamp

Func FileWriteMy($PathFileExt, $String)
	If FileExists($PathFileExt) Then FileDelete($PathFileExt)
	Return FileWrite($PathFileExt, $String)
EndFunc   ;==>FileWriteMy
Func ifDelFile($ifil)
	If FileExists($ifil) Then FileDelete($ifil)
EndFunc

; #########################################################################################################
; Array, Filter und File-Listen Helfer-Funktionen
; #########################################################################################################

Func ArraySearchMy(ByRef $a, $val)
	For $i = 0 To UBound($a) - 1
		If $a[$i] = $val Then Return $i
	Next
	Return -1
EndFunc   ;==>ArraySearchMy
Func DelPoint($e)
	Return StringReplace($e, '.', '')
EndFunc   ;==>DelPoint
Func ArExtFilterFkt()
	Local $arExtFilterTemp = StringSplit(StringStripCR($extFilter), '.')
	$arExtFilterTemp[0] = ''
	Return $arExtFilterTemp
EndFunc   ;==>ArExtFilterFkt
Func Change0ApendLine(ByRef $aRetArray, $ChangeElement0, $ApendLine)
	$aRetArray[0] = $ChangeElement0
	_ArrayAdd($aRetArray, $ApendLine)
	Return $aRetArray
EndFunc   ;==>Change0ApendLine
Func FilterExtensions(ByRef $arExtAll, ByRef $arExtFilter)
	Local $arExt[0]
	For $i = 0 To UBound($arExtAll) - 1
		Local $ext = StringStripWS($arExtAll[$i], 3)
		If $ext <> "" Then
			$ext = DelPoint($ext)
			If ArraySearchMy($arExtFilter, $ext) <> -1 Then _ArrayAdd($arExt, $ext)
		EndIf
	Next
	Return $arExt
EndFunc   ;==>FilterExtensions
Func arFolderFilesAllLists($folder)
  ;;//  ToDo:  no subfolders test and implement
	Local $iReadSubFolders = 1
	If $iReadSubFolders Then
		RunWait(@ComSpec & " /c dir " & $folder & " /a-d /s /b | clip", "", @SW_HIDE)
	Else
		RunWait(@ComSpec & " /c dir " & $folder & " /a-d /b | clip", "", @SW_HIDE)
	EndIf

	Local $sclip = ClipGet()
	Local $arClip = StringSplit($sclip, @LF)
	Local $ar[0], $j = 0
	For $i = 0 To UBound($arClip) - 1
		Local $p = StringStripCR($arClip[$i])
		If '' <> $p Then
			ReDim $ar[$j + 2]
			$ar[$j + 1] = $p
			$j = $j + 1
		EndIf
	Next
	Return $ar
EndFunc   ;==>arFolderFilesAllLists
Func GetExtensionsFromArray($arr)
	Local $exts[0]
	For $i = 1 To UBound($arr) - 1
		If $arr[$i] = "" Then ContinueLoop
		Local $ext = StringRegExpReplace($arr[$i], ".*\.([A-Za-z0-9]+)$", ".$1")
		If $ext <> $arr[$i] Then
			$ext = StringLower($ext)
			If ArraySearchMy($exts, $ext) = -1 Then
				ReDim $exts[UBound($exts) + 1]
				$ext = DelPoint($ext)
				$exts[UBound($exts) - 1] = $ext
			EndIf
		EndIf
	Next
	Return $exts
EndFunc   ;==>GetExtensionsFromArray

; #########################################################################################################
; GUI Kommunikations- und Setup-Funktionen
; #########################################################################################################

Func _InitializeSettingsArray($sCurrentIDX)
	; Initialisiert das Settings-Array mit Standardwerten und lädt die letzte Sitzung
	Local $aSettings[0][2]

	; 1. Input-Felder (Standardwerte)
	_SetSetting($aSettings, 'InParent', $gInParent)
	_SetSetting($aSettings, 'InSub', $gInSub)
	_SetSetting($aSettings, 'OutParent', $gOutParent)
	_SetSetting($aSettings, 'OutSub', $gOutSub)
	_SetSetting($aSettings, 'AllCodeFile', $gAllCodeFile)
	_SetSetting($aSettings, 'ExtFilter', $extFilter)

    ; Lade Letzte Sitzung aus INI (Funktion aus DirToAll_init)
    $aSettings = _ReadIniSectionSettings($aSettings, $g_sIniSessionSection)

	; 2. Zustandswerte
	_SetSetting($aSettings, 'Index', $sCurrentIDX)
	_SetSetting($aSettings, 'Timestamp', '')
	_SetSetting($aSettings, 'ResultList', '')
	_SetSetting($aSettings, 'Mode', 0)

	; 3. Berechnete Pfade (Zuerst leer)
	_SetSetting($aSettings, 'FolderIn', '')
	_SetSetting($aSettings, 'FolderOutAllCode', '')
	_SetSetting($aSettings, 'FolderOutExtract', '')

	Return $aSettings
EndFunc   ;==>_InitializeSettingsArray

Func _ApplyGUIToArray(ByRef $aSettings)
    ; Überträgt aktuelle GUI-Werte in das Array und aktualisiert $extFilter
	_SetSetting($aSettings, 'InParent', GUICtrlRead($idInputInParent))
	_SetSetting($aSettings, 'InSub', GUICtrlRead($idInputInSub))
	_SetSetting($aSettings, 'OutParent', GUICtrlRead($idInputOutParent))
	_SetSetting($aSettings, 'OutSub', GUICtrlRead($idInputOutSub))
	_SetSetting($aSettings, 'AllCodeFile', GUICtrlRead($idInputAllCodeFile))
	Local $sCurrentExtFilter = GUICtrlRead($idInputExtFilter)
    _SetSetting($aSettings, 'ExtFilter', $sCurrentExtFilter)

    ; Aktualisiere auch die globale Variable $extFilter
    Global $extFilter = $sCurrentExtFilter

	_SetSetting($aSettings, 'Mode', $iMode)

	Return $aSettings
EndFunc   ;==>_ApplyGUIToArray

Func _PreparePathsOLDOLD(ByRef $aSettings)
	; Berechnet die finalen In- und Output-Pfade
	Local $iMode = _GetSetting($aSettings, 'Mode')
	Local $sIDXnum = _GetSetting($aSettings, 'Index')

	_SetSetting($aSettings, 'Timestamp', _GetISO8601Timestamp())

	If $iMode = 0 Then ; MODUS 0: Combine
		Local $sInParent = _GetSetting($aSettings, 'InParent')
		Local $sInSub = _GetSetting($aSettings, 'InSub')
		Local $sOutParent = _GetSetting($aSettings, 'OutParent')
		Local $sOutSub = _GetSetting($aSettings, 'OutSub')

        ; FIX: Path Normalization
        $sInParent = _PathCleanBackslashes($sInParent)
        $sOutParent = _PathCleanBackslashes($sOutParent)

        ; Erstellt den Ordnerpfad robust
		Local $sFolderIn = _PathEnsureTrailingBackslash($sInParent) & _PathEnsureTrailingBackslash($sInSub)
		Local $sFolderOutAllCode = _PathEnsureTrailingBackslash($sOutParent) & $sOutSub & '_' & $sIDXnum & '\'
		Local $sAllCodeFile = $sFolderOutAllCode & 'AllCode1file.txt'
		Local $sFolderOutExtract = $sFolderOutAllCode & $sOutSub & '\'

		If 1 <> DirCreate($sFolderOutExtract) Then
			MsgBox($MB_ICONERROR, 'FEHLER', 'Ausgabeordner konnte nicht erstellt werden: ' & $sFolderOutExtract)
			Return 0 ; Fehler
		EndIf

		_SetSetting($aSettings, 'FolderIn', $sFolderIn)
		_SetSetting($aSettings, 'FolderOutAllCode', $sFolderOutAllCode)
		_SetSetting($aSettings, 'AllCodeFile', $sAllCodeFile)
		_SetSetting($aSettings, 'FolderOutExtract', $sFolderOutExtract)

	ElseIf $iMode = 1 Then ; MODUS 1: Extract
		Local $sAllCodeFile = _GetSetting($aSettings, 'AllCodeFile')

		If StringStripWS($sAllCodeFile, 3) = "" Then
			MsgBox($MB_ICONERROR, 'FEHLER', 'Für Modus 1 muss die Sammel-Datei im Feld ausgewählt oder eingetragen sein.')
			Return 0 ; Fehler
		EndIf
	EndIf

	Return $aSettings
EndFunc   ;==>_PreparePaths

; =========================================================================================================
; Datei: DirToAll_GetSetArr[2440].au3
; Funktion: _PreparePaths
; =========================================================================================================

Func _PreparePaths(ByRef $aSettings)
	; Berechnet die finalen In- und Output-Pfade
	Local $iMode = _GetSetting($aSettings, 'Mode')
	Local $sIDXnum = _GetSetting($aSettings, 'Index')

	_SetSetting($aSettings, 'Timestamp', _GetISO8601Timestamp())

	If $iMode = 0 Then ; MODUS 0: Combine
		Local $sInParent = _GetSetting($aSettings, 'InParent')
		Local $sInSub = _GetSetting($aSettings, 'InSub')
		Local $sOutParent = _GetSetting($aSettings, 'OutParent')
		Local $sOutSub = _GetSetting($aSettings, 'OutSub')

        ; FIX: Path Normalization
        $sInParent = _PathCleanBackslashes($sInParent)
        $sOutParent = _PathCleanBackslashes($sOutParent)

        ; Erstellt den Ordnerpfad robust (KORRIGIERTE LOGIK)
		Local $sFolderIn = _PathEnsureTrailingBackslash($sInParent)
		Local $sInSubClean = StringStripWS($sInSub, 3)

		If $sInSubClean <> "" Then
			$sFolderIn &= $sInSubClean
			$sFolderIn = _PathEnsureTrailingBackslash($sFolderIn)
		EndIf ; <--- HIER IST DAS FEHLENDE ENDIF

		Local $sFolderOutAllCode = _PathEnsureTrailingBackslash($sOutParent) & $sOutSub & '_' & $sIDXnum & '\'
		Local $sAllCodeFile = $sFolderOutAllCode & 'AllCode1file.txt'
		Local $sFolderOutExtract = $sFolderOutAllCode & $sOutSub & '\'

		If 1 <> DirCreate($sFolderOutExtract) Then
			MsgBox($MB_ICONERROR, 'FEHLER', 'Ausgabeordner konnte nicht erstellt werden: ' & $sFolderOutExtract)
			Return 0 ; Fehler
		EndIf

		_SetSetting($aSettings, 'FolderIn', $sFolderIn)
		_SetSetting($aSettings, 'FolderOutAllCode', $sFolderOutAllCode)
		_SetSetting($aSettings, 'AllCodeFile', $sAllCodeFile)
		_SetSetting($aSettings, 'FolderOutExtract', $sFolderOutExtract)

	ElseIf $iMode = 1 Then ; MODUS 1: Extract
		Local $sAllCodeFile = _GetSetting($aSettings, 'AllCodeFile')

		If StringStripWS($sAllCodeFile, 3) = "" Then
			MsgBox($MB_ICONERROR, 'FEHLER', 'Für Modus 1 muss die Sammel-Datei im Feld ausgewählt oder eingetragen sein.')
			Return 0 ; Fehler
		EndIf
	EndIf

	Return $aSettings
EndFunc   ;==>_PreparePaths
; was missing lines missing endif
