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

; #########################################################################################################
; Marker-Funktionen
; #########################################################################################################

Func MarkerBegin($sFullPathFileName, $sTimestamp, $sIDXnum)   ;// DirToAll_MarkerFiles-2460.au3
  ;// eg. ;//      ////_marker_begin {"ver":"idxq_2683","timestamp":"2025-11-20T09:19:24Z","file":"D:\ws\youtube-DUBBING-pos-div\DubbingShortTest_out_2683\DubbingShortTest_out\3.1.18_0\manifest.json"}
  ;// ToDo:  add comment 6 zeichen je nach ext
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
  	return _FileWriteFromArray($sFullPathFile,   $aRetArray, 0)  ;;// 0 start arr index 0
EndFunc
func f2a($sFullPathFile, ByRef $aRetArray)
     return _FileReadToArray($sFullPathFile, $aRetArray)
EndFunc
func arr2fil($sFullPathFile, ByRef $aRetArray)
  	return _FileWriteFromArray($sFullPathFile, $aRetArray, 0)  ;;// 0 start arr index 0
EndFunc
func fil2arr($sFullPathFile, ByRef $aRetArray)
     return _FileReadToArray($sFullPathFile,   $aRetArray)
EndFunc
Func All1file2Folder(ByRef $aSettings)
	; Modus 1: Extrahiert alle Dateien
	Local $sAllCodeFileTxt = _GetSetting($aSettings, 'AllCodeFile')
	Local $sFileContent = FileRead($sAllCodeFileTxt) 
            If @error Then
                ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : unc All1file2Folder(ByRef $aSettings) error.  @ScriptLineNumber '   & @CRLF & '>Error code: ' & @error & @CRLF) ;### Debug Console
            
               Return ""
              endif
    
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