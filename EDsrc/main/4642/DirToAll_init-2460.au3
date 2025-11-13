#include-once
#include <Array.au3>
#include <File.au3>
#include <MsgBoxConstants.au3>
#include <String.au3>
#include <Math.au3>
#include <EditConstants.au3>
#include <WindowsConstants.au3>
#include <GUIConstantsEx.au3>

; FIX: Globale Variablen, die in der Main-Datei initialisiert werden, nur hier nur als Global deklarieren
Global $g_sIniFilePath
Global $g_sIniSessionSection
Global $g_sIniMetadataSection
Global $dbgg ; Debug-Flag
Global $idInputInParent, $idInputInSub, $idInputOutParent, $idInputOutSub, $idInputAllCodeFile, $idInputExtFilter
Global $idBtnSavePreset

; KORREKTUR: Funktions-Listen entfernt oder korrekt auskommentiert
; Funktionen, die aus DirToAll_GetSetArr[2440].au3 benötigt werden:
; Func _InitializeSettingsArray(ByRef $sCurrentIDX);
; Func _ApplyGUIToArray(ByRef $aSettings);
; Func _GetSetting(ByRef $aArray, $sKey);
; Func _ArraySearch(ByRef $aArray, $vValue);
; Func _PathEnsureTrailingBackslash(ByRef $sPath);
; Func _PathCleanBackslashes(ByRef $sPath);
; Func _Max(ByRef $vA, ByRef $vB);


; #########################################################################################################
; INI-Speicher-Funktionen (Sitzung und Presets)
; #########################################################################################################

Func _ReadIniSectionSettings(ByRef $aSettings, $sSectionName)
    ; Liest gespeicherte Einstellungen aus der INI-Datei und überschreibt die Standardwerte im Array
    If Not FileExists($g_sIniFilePath) Then Return $aSettings

    Local $sValue

    $sValue = IniRead($g_sIniFilePath, $sSectionName, "InParent", "")
    If $sValue <> "" Then _SetSetting($aSettings, 'InParent', $sValue)

    $sValue = IniRead($g_sIniFilePath, $sSectionName, "InSub", "")
    If $sValue <> "" Then _SetSetting($aSettings, 'InSub', $sValue)

    $sValue = IniRead($g_sIniFilePath, $sSectionName, "OutParent", "")
    If $sValue <> "" Then _SetSetting($aSettings, 'OutParent', $sValue)

    $sValue = IniRead($g_sIniFilePath, $sSectionName, "OutSub", "")
    If $sValue <> "" Then _SetSetting($aSettings, 'OutSub', $sValue)

    $sValue = IniRead($g_sIniFilePath, $sSectionName, "AllCodeFile", "")
    If $sValue <> "" Then _SetSetting($aSettings, 'AllCodeFile', $sValue)

    $sValue = IniRead($g_sIniFilePath, $sSectionName, "ExtFilter", "")
    If $sValue <> "" Then _SetSetting($aSettings, 'ExtFilter', $sValue)

    If $dbgg Then ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : Einstellungen aus Sektion [' & $sSectionName & '] geladen.' & @CRLF)

    Return $aSettings
EndFunc ;==>_ReadIniSectionSettings

Func _WriteIniSectionSettings(ByRef $aSettings, $sSectionName)
    ; Speichert aktuelle Einstellungen aus dem Array in die INI-Sektion
    Local $sInParent = _GetSetting($aSettings, 'InParent')
    Local $sInSub = _GetSetting($aSettings, 'InSub')
    Local $sOutParent = _GetSetting($aSettings, 'OutParent')
    Local $sOutSub = _GetSetting($aSettings, 'OutSub')
    Local $sAllCodeFile = _GetSetting($aSettings, 'AllCodeFile')
    Local $sExtFilter = _GetSetting($aSettings, 'ExtFilter')

    IniWrite($g_sIniFilePath, $sSectionName, "InParent", $sInParent)
    IniWrite($g_sIniFilePath, $sSectionName, "InSub", $sInSub)
    IniWrite($g_sIniFilePath, $sSectionName, "OutParent", $sOutParent)
    IniWrite($g_sIniFilePath, $sSectionName, "OutSub", $sOutSub)
    IniWrite($g_sIniFilePath, $sSectionName, "AllCodeFile", $sAllCodeFile)
    IniWrite($g_sIniFilePath, $sSectionName, "ExtFilter", $sExtFilter)

    If $dbgg Then ConsoleWrite('@@ Debug(' & @ScriptLineNumber & ') : Einstellungen in Sektion [' & $sSectionName & '] gespeichert.' & @CRLF)

    Return True
EndFunc ;==>_WriteIniSectionSettings

Func _OpenSettingsIni()
    ; Öffnet die INI-Datei zur Bearbeitung in Notepad++ oder dem Standardprogramm
    If Not FileExists($g_sIniFilePath) Then
        ; Beim ersten Öffnen die aktuelle Sitzung speichern, um die Datei zu erstellen
        Local $aDummySettings = _InitializeSettingsArray(0)
        _ApplyGUIToArray($aDummySettings)
        _WriteIniSectionSettings($aDummySettings, $g_sIniSessionSection)
        _SetNextPresetNumber(1) ; Metadata initialisieren
    EndIf

    ; Versucht, die Datei mit Notepad++ zu öffnen, ansonsten mit dem Standardprogramm
    If FileExists("C:\Program Files\Notepad++\notepad++.exe") Then
        ShellExecute("C:\Program Files\Notepad++\notepad++.exe", '"' & $g_sIniFilePath & '"')
    ElseIf FileExists("C:\Program Files (x86)\Notepad++\notepad++.exe") Then
        ShellExecute("C:\Program Files (x86)\Notepad++\notepad++.exe", '"' & $g_sIniFilePath & '"')
    Else
        ShellExecute($g_sIniFilePath) ; Standardprogramm verwenden (z.B. Notepad)
    EndIf

    Return True
EndFunc ;==>_OpenSettingsIni


; #########################################################################################################
; Preset-Metadaten Funktionen (Laden/Speichern)
; #########################################################################################################

Func _GetNextPresetNumber()
    ; Liest die Nummer für das nächste Preset aus der Metadata Sektion
    Local $iNextNum = IniRead($g_sIniFilePath, $g_sIniMetadataSection, "NextPresetNumber", 1)
    Return _Max(1, Int($iNextNum))
EndFunc ;==>_GetNextPresetNumber

Func _SetNextPresetNumber($iNum)
    ; Schreibt die Nummer für das nächste Preset in die Metadata Sektion
    IniWrite($g_sIniFilePath, $g_sIniMetadataSection, "NextPresetNumber", $iNum)
EndFunc ;==>_SetNextPresetNumber

Func _GetPresetNumbers()
    ; Gibt ein Array aller existierenden Preset-Nummern zurück
    Local $aSections = IniReadSectionNames($g_sIniFilePath)
    Local $aPresetNums[0]

    If @error Or Not IsArray($aSections) Then Return $aPresetNums

    For $i = 1 To UBound($aSections) - 1
        Local $sSection = $aSections[$i]
        ; Prüfen, ob der Sektionsname eine Ganzzahl ist (ein Preset)
        If StringIsDigit($sSection) Then
            _ArrayAdd($aPresetNums, Int($sSection))
        EndIf
    Next

    _ArraySort($aPresetNums)
    Return $aPresetNums
EndFunc ;==>_GetPresetNumbers

Func _LoadPresetSelect(ByRef $aSettings)
    ; Liest die zu ladende Preset-Nummer per Eingabefeld ein
    Local $aPresetNums = _GetPresetNumbers()

    If UBound($aPresetNums) = 0 Then
        MsgBox($MB_ICONINFORMATION, "Laden", "Es wurden noch keine Presets gespeichert.")
        Return $aSettings
    EndIf

    ; Erstelle eine Liste der verfügbaren Nummern für die Info-Anzeige
    Local $sAvailableNums = ""
    For $i = 0 To UBound($aPresetNums) - 1
        $sAvailableNums &= $aPresetNums[$i] & " "
    Next

    ;Local $sSelectedNum = _InputPresetNumber("Preset laden", "Verfügbare Nummern: " & StringStripRight($sAvailableNums, 1), "")  ;; exist func: Local $sIDXnum = StringStripWS(FileRead($g_sIndexFilePath), 3)

		Local $sSelectedNum = _InputPresetNumber("Preset laden", "Verfügbare Nummern: " & StringStripWS($sAvailableNums, 3), "")  ;; exist func: Local $sIDXnum = StringStripWS(FileRead($g_sIndexFilePath), 3)

    ; Prüfe, ob die Eingabe gültig ist
    If StringIsDigit($sSelectedNum) Then
        Local $sSection = String($sSelectedNum)

        Local $iExists = _ArraySearch($aPresetNums, Int($sSelectedNum))
        If $iExists <> -1 Then
            ; Lade das ausgewählte Preset in das Einstellungs-Array
            $aSettings = _ReadIniSectionSettings($aSettings, $sSection)
            ; Aktualisiere die GUI-Elemente
            GUICtrlSetData($idInputInParent, _GetSetting($aSettings, 'InParent'))
            GUICtrlSetData($idInputInSub, _GetSetting($aSettings, 'InSub'))
            GUICtrlSetData($idInputOutParent, _GetSetting($aSettings, 'OutParent'))
            GUICtrlSetData($idInputOutSub, _GetSetting($aSettings, 'OutSub'))
            GUICtrlSetData($idInputAllCodeFile, _GetSetting($aSettings, 'AllCodeFile'))
            GUICtrlSetData($idInputExtFilter, _GetSetting($aSettings, 'ExtFilter'))

            MsgBox($MB_ICONINFORMATION, "Erfolg", "Preset [" & $sSection & "] erfolgreich geladen.")
        Else
             MsgBox($MB_ICONERROR, "Fehler", "Preset-Nummer [" & $sSection & "] nicht gefunden.")
        EndIf
    ElseIf $sSelectedNum <> "" Then
        MsgBox($MB_ICONERROR, "Fehler", "Ungültige Eingabe. Bitte nur Zahlen eingeben.")
    EndIf

    Return $aSettings
EndFunc ;==>_LoadPresetSelect

Func _SavePresetAsNew(ByRef $aSettings)
    ; Speichert die aktuelle GUI-Konfiguration als neues nummeriertes Preset

    ; 1. Zuerst aktuelle GUI-Werte abrufen und in $aSettings speichern
    _ApplyGUIToArray($aSettings)

    ; 2. Nächste Nummer ermitteln
    Local $iNewNum = _GetNextPresetNumber()
    Local $sNewSection = String($iNewNum)

    ; 3. Speichern der Einstellungen unter der neuen Sektion [iNewNum]
    _WriteIniSectionSettings($aSettings, $sNewSection)

    ; 4. Zähler erhöhen und speichern
    _SetNextPresetNumber($iNewNum + 1)

    ; 5. GUI-Button-Label aktualisieren
    GUICtrlSetData($idBtnSavePreset, "SAVE AS [" & ($iNewNum + 1) & "]")

    MsgBox($MB_ICONINFORMATION, "Speichern", "Aktuelle Einstellungen erfolgreich als Preset [" & $iNewNum & "] gespeichert.")

    Return $aSettings
EndFunc ;==>_SavePresetAsNew

Func _InputPresetNumber($sTitle, $sText, $sDefault)
    ; Hilfsfunktion, um eine Preset-Nummer per Input-Feld einzugeben
    Local $hInputGui = GUICreate($sTitle, 300, 150, -1, -1)
    GUICtrlCreateLabel($sText, 10, 10, 280, 20)
    Local $idInput = GUICtrlCreateInput($sDefault, 10, 40, 280, 25, $ES_NUMBER) ; $ES_NUMBER für reine Zahleneingabe
    Local $idOK = GUICtrlCreateButton("Laden", 50, 80, 80, 25)
    Local $idCancel = GUICtrlCreateButton("Abbrechen", 170, 80, 80, 25)

    GUISetState(@SW_SHOW)

    Local $sReturn = ""
    While 1
        Local $iMsg = GUIGetMsg()
        Switch $iMsg
            Case $GUI_EVENT_CLOSE, $idCancel
                ExitLoop
            Case $idOK
                $sReturn = GUICtrlRead($idInput)
                ExitLoop
        EndSwitch
    WEnd

    GUIDelete($hInputGui)
    Return $sReturn
EndFunc ;==>_InputPresetNumber