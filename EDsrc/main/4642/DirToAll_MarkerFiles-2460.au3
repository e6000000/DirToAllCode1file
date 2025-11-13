#include-once
#include <Array.au3>
#include <String.au3>
#include <File.au3>
#include <StringConstants.au3>
#include <String.au3>
#include <Debug.au3>

; Globale Variablen, die von der Main-Datei benötigt werden:
Global $dbgg, $extFilter
Global $g_sVersionPrefix
Global $sLocalMarkerBegin, $sLocalMarkerEnd

; KORREKTUR: Funktions-Listen entfernt oder korrekt auskommentiert
; Funktionen, die von DirToAll_GetSetArr[2440].au3 benötigt werden:
; Func _GetSetting(ByRef $aArray, $sKey);
; Func ArExtFilterFkt();
; Func ArraySearchMy(ByRef $a, $val);
; Func DelPoint(ByRef $e);
; Func Change0ApendLine(ByRef $aRetArray, $ChangeElement0, $ApendLine);
; Func FilterExtensions(ByRef $arExtAll, ByRef $arExtFilter);
; Func FileWriteMy(ByRef $PathFileExt, ByRef $String);
; Func ifDelFile(ByRef $ifil);


; #########################################################################################################
; Marker-Funktionen
; #########################################################################################################

Func MarkerBegin($sFullPathFileName, $sTimestamp, $sIDXnum)
	Local $sMarkerString = "//" & "//" & "_mar" & "ker_begin {" & '"ver":"' & $g_sVersionPrefix & $sIDXnum & '",' & '"timestamp":"' & $sTimestamp & '",' & '"file":"' & $sFullPathFileName & '"' & "}"
	Return $sMarkerString
EndFunc   ;==>MarkerBegin
Func MarkerEnd($sFullPathFileName, $sTimestamp, $sIDXnum)
	Local $sMarkerString = "//" & "//" & "_mar" & "ker_end {" & '"ver":"' & $g_sVersionPrefix & $sIDXnum & '",' & '"timestamp":"' & $sTimestamp & '",' & '"file":"' & $sFullPathFileName & '"' & "}"
	Return $sMarkerString
EndFunc   ;==>MarkerEnd


; #########################################################################################################
; Kernlogik (Modus 0 & 1)
; #########################################################################################################

Func AppendFilesToAllCode1file_Txt(ByRef $aSettings, ByRef $arFil, ByRef $arExt)
	; Modus 0: Kombiniert alle Dateien
	Local $sFolderIn = _GetSetting($aSettings, 'FolderIn')
	Local $sFolderOutExtract = _GetSetting($aSettings, 'FolderOutExtract')
	Local $sAllCodeFileTxt = _GetSetting($aSettings, 'AllCodeFile')
	Local $sIDXnum = _GetSetting($aSettings, 'Index')
	Local $sTimestamp = _GetSetting($aSettings, 'Timestamp')

	ifDelFile($sAllCodeFileTxt)
	Local $hFile = FileOpen($sAllCodeFileTxt, 2)
	If $hFile = -1 Then Return False

	For $i = 1 To UBound($arFil) - 1
		Local $sFullPathFile = $arFil[$i]
		Local $sExt = DelPoint(StringRight($sFullPathFile, StringLen($sFullPathFile) - StringInStr($sFullPathFile, ".", 0, -1)))

		If ArraySearchMy($arExt, $sExt) <> -1 Then
			ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : **qq66yy_filter_my_extensionFilter** $sExt = ' & $sExt & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
			Local $aRetArray
			If _FileReadToArray($sFullPathFile, $aRetArray) Then
				; WICHTIG: Entfernt den Input-Ordnerpfad, um den relativen Pfad zu erhalten
        ; Der Zusatz , 1, 1 ist der entscheidende Fix. Er stellt sicher, dass der Basispfad ($sFolderIn) nur einmal und nur am Anfang entfernt wird, wodurch nur der relative Pfad (z.B. subfolder\file.txt) übrig bleibt.
				Local $sFileNameForMarker = StringReplace($sFullPathFile, $sFolderIn, '', 1, 1)
				ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $sFileNameForMarker = ' & $sFileNameForMarker & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console

				Local $sFullTargetPath = $sFolderOutExtract & $sFileNameForMarker
				ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : $sFullTargetPath = ' & $sFullTargetPath & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
				Local $sMarkerBegin = MarkerBegin($sFullTargetPath, $sTimestamp, $sIDXnum)
				Local $sMarkerEnd = MarkerEnd($sFullTargetPath, $sTimestamp, $sIDXnum)
				$aRetArray = Change0ApendLine($aRetArray, $sMarkerBegin, $sMarkerEnd)
				_FileWriteFromArray($hFile, $aRetArray, 0)  ;;// 0 start arr index 0
			EndIf
		EndIf
	Next
	FileClose($hFile)
	Return True
EndFunc   ;==>AppendFilesToAllCode1file_Txt

func a2f($sFullPathFile, ByRef $aRetArray)
  	return _FileWriteFromArray($sFullPathFile, ByRef $aRetArray, 0)  ;;// 0 start arr index 0
EndFunc
func f2a($sFullPathFile, ByRef $aRetArray)
     return _FileReadToArray($sFullPathFile, ByRef $aRetArray)
EndFunc
func arr2fil($sFullPathFile, ByRef $aRetArray)
  	return _FileWriteFromArray($sFullPathFile, ByRef $aRetArray, 0)  ;;// 0 start arr index 0
EndFunc
func fil2arr($sFullPathFile, ByRef $aRetArray)
     return _FileReadToArray($sFullPathFile, ByRef $aRetArray)
EndFunc
Func All1file2Folder(ByRef $aSettings)
	; Modus 1: Extrahiert alle Dateien
	Local $sAllCodeFileTxt = _GetSetting($aSettings, 'AllCodeFile')
	Local $sFileContent = FileRead($sAllCodeFileTxt)

	If @error Then Return ""

	Local $sRegex = '.{0,6}?' & $sLocalMarkerBegin & '.*?"file":"([^"]+)".*?' & @CRLF & '([\s\S]*?)' & @CRLF & $sLocalMarkerEnd & '.*'
	Local $aMatches = StringRegExp($sFileContent, $sRegex, 3)

	Local $sMarkerList = ""

	If IsArray($aMatches) Then
		Local $iCount = UBound($aMatches) / 2
		For $i = 0 To $iCount - 1
			Local $sFilePath = $aMatches[$i * 2]
			Local $sContent = $aMatches[$i * 2 + 1]

			If StringLen($sMarkerList) > 0 Then $sMarkerList &= "|"
			$sMarkerList &= $sFilePath

			Local $iLastBackslash = StringInStr(StringReverse($sFilePath), "\") - 1
			Local $sDir = StringTrimRight($sFilePath, $iLastBackslash)

			If Not DirCreate($sDir) And Not FileExists($sDir) Then ContinueLoop

			Local $hFile = FileOpen($sFilePath, 2)
			If $hFile <> -1 Then
				FileWrite($hFile, $sContent)
				FileClose($hFile)
			EndIf
		Next
		Return $sMarkerList
	EndIf
	Return ""
EndFunc   ;==>All1file2Folder