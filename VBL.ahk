#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All, Off

; ==============================================================================
; ROBLOX ULTIMATE MACRO v7.7 (Refined Ping Logic)
; ==============================================================================

; --- Global Variables ---
global settingsFile := A_ScriptDir "\settings.ini"
global macroRunning := false
global actionDelay := 2000 
global debugMode := IniRead(settingsFile, "Settings", "DebugMode", "0")
global schedulerActive := false
global schedulerLatch := "" 

; Default to 1080p Standard
global defaultErrX := 852, defaultErrY := 481
global defaultSafeX := 1577, defaultSafeY := 295

CoordMode "ToolTip", "Screen"
CoordMode "Pixel", "Screen"
CoordMode "Mouse", "Screen"

; --- GUI Setup ---
MyGui := Gui("-Resize +MinimizeBox +SysMenu", "Roblox Macro v7.7")
MyGui.BackColor := "282c34"
MyGui.SetFont("s9 cWhite", "Segoe UI")

Tab := MyGui.Add("Tab3", "x0 y0 w460 h550", ["Main", "Webhook", "Bloxstrap", "Advanced"])

; =========================
; TAB 1: MAIN
; =========================
Tab.UseTab("Main")

; -- Connection --
MyGui.AddGroupBox("x10 y40 w440 h70 cWhite", "Connection")
MyGui.AddText("x20 y60", "Private Server Link:")
gLinkEdit := MyGui.AddEdit("x20 y80 w420 h20", IniRead(settingsFile, "Settings", "PrivateServerLink", ""))
gLinkEdit.SetFont("cBlack")
gLinkEdit.OnEvent("Change", TriggerAutoSave)

; -- Timers --
MyGui.AddGroupBox("x10 y120 w440 h60 cWhite", "Timers")

; Load Saved Values
savedClick := IniRead(settingsFile, "Settings", "ClickInterval", "300")
savedShot  := IniRead(settingsFile, "Settings", "ScreenshotInterval", "120")

MyGui.AddText("x20 y145", "Click Interval (s):")
gIntervalEdit := MyGui.AddEdit("x130 y142 w60 h20 Number", savedClick)
gIntervalEdit.SetFont("cBlack")
gIntervalEdit.OnEvent("Change", TriggerAutoSave)
MyGui.AddUpDown("Range1-99999", savedClick)

MyGui.AddText("x220 y145", "Screenshot Loop (s):")
gScreenshotInterval := MyGui.AddEdit("x340 y142 w60 h20 Number", savedShot)
gScreenshotInterval.SetFont("cBlack")
gScreenshotInterval.OnEvent("Change", TriggerAutoSave)
MyGui.AddUpDown("Range10-99999", savedShot)

; -- Scheduler --
MyGui.AddGroupBox("x10 y190 w440 h100 cWhite", "Scheduler")
gScheduleCheck := MyGui.AddCheckbox("x20 y210 w150 h20", "Enable Scheduler")
gScheduleCheck.Value := IniRead(settingsFile, "Scheduler", "Enabled", "0")
gScheduleCheck.OnEvent("Click", ToggleScheduler)

MyGui.AddText("x200 y210", "Start Time:")
gHourEdit := MyGui.AddEdit("x260 y207 w30 h20 Number Center", IniRead(settingsFile, "Scheduler", "Hour", "12"))
gHourEdit.SetFont("cBlack")
gMinEdit := MyGui.AddEdit("x300 y207 w30 h20 Number Center", IniRead(settingsFile, "Scheduler", "Min", "00"))
gMinEdit.SetFont("cBlack")
gAmPmDD := MyGui.AddDropDownList("x340 y207 w50 Choose1", ["AM", "PM"])
gAmPmDD.Text := IniRead(settingsFile, "Scheduler", "AmPm", "AM")
gAmPmDD.SetFont("cBlack")

gDayDD := MyGui.AddDropDownList("x20 y240 w100 Choose1", ["Every Day", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"])
gDayDD.Text := IniRead(settingsFile, "Scheduler", "Day", "Every Day")
gDayDD.SetFont("cBlack")

gCloseAppsCheck := MyGui.AddCheckbox("x140 y240 w300 h20", "Force Close ALL Apps when Started")
gCloseAppsCheck.Value := IniRead(settingsFile, "Scheduler", "CloseAppsOnSched", "0")
gCloseAppsCheck.SetFont("cRed")

; -- MAIN CONTROLS --
MyGui.AddGroupBox("x10 y300 w440 h140 cWhite", "Controls")

gStartButton := MyGui.AddButton("x30 y340 w190 h40", "Start Macro (F5)")
gStartButton.OnEvent("Click", (*) => StartMacro("manual"))

gStopButton  := MyGui.AddButton("x240 y340 w190 h40", "Stop Macro (F7)")
gStopButton.OnEvent("Click", StopMacro)

gSaveButton  := MyGui.AddButton("x30 y400 w400 h30", "💾 SAVE SETTINGS 💾")
gSaveButton.OnEvent("Click", ManualSave)

; =========================
; TAB 2: WEBHOOK
; =========================
Tab.UseTab("Webhook")
MyGui.AddText("x20 y40 w400", "1. Discord Webhook URL:")
gWebhookEdit := MyGui.AddEdit("x20 y60 w400 h20", IniRead(settingsFile, "Discord", "WebhookURL", ""))
gWebhookEdit.SetFont("cBlack")
gWebhookEdit.OnEvent("Change", TriggerAutoSave)

MyGui.AddText("x20 y100 w400", "2. Discord User ID (Optional - For Pings):")
gUserIDEdit := MyGui.AddEdit("x20 y120 w400 h20 Number", IniRead(settingsFile, "Discord", "UserID", ""))
gUserIDEdit.SetFont("cBlack")
gUserIDEdit.OnEvent("Change", TriggerAutoSave)

gRemoteCheck := MyGui.AddCheckbox("x20 y160 w400 h20", "Enable Screenshots & Notifications")
gRemoteCheck.Value := IniRead(settingsFile, "Discord", "RemoteEnabled", "0")

; =========================
; TAB 3: BLOXSTRAP
; =========================
Tab.UseTab("Bloxstrap")
defaultPath := EnvGet("LocalAppData") . "\Bloxstrap\Settings.json"
defaultNormal := '"ConfirmLaunches": true'
defaultMacro := '"ConfirmLaunches": false'

gEnableFileEdit := MyGui.AddCheckbox("x20 y40 w400 h20", "Enable File Editing (Bloxstrap)")
gEnableFileEdit.Value := IniRead(settingsFile, "FileEditor", "Enabled", "0")

MyGui.AddText("x20 y70 w400", "File Path:")
gExternalFile := MyGui.AddEdit("x20 y90 w400 h20", IniRead(settingsFile, "FileEditor", "FilePath", defaultPath))
gExternalFile.SetFont("cBlack")

MyGui.AddText("x20 y120 w180", "Value when STOPPED:")
gNormalText := MyGui.AddEdit("x20 y140 w180 h20", IniRead(settingsFile, "FileEditor", "NormalText", defaultNormal))
gNormalText.SetFont("cBlack")

MyGui.AddText("x230 y120 w180", "Value when RUNNING:")
gMacroText := MyGui.AddEdit("x230 y140 w180 h20", IniRead(settingsFile, "FileEditor", "MacroText", defaultMacro))
gMacroText.SetFont("cBlack")

; =========================
; TAB 4: ADVANCED
; =========================
Tab.UseTab("Advanced")

; -- Group: Pixel / Auto-Rejoin --
MyGui.AddGroupBox("x10 y40 w440 h175 cWhite", "Crash Detection and Resolution")

gAutoRejoinCheck := MyGui.AddCheckbox("x30 y70 w300 h20", "Enable Auto-Rejoin (Pixel Check)")
gAutoRejoinCheck.Value := IniRead(settingsFile, "Coordinates", "AutoRejoin", "1")

gRecalcBtn := MyGui.AddButton("x30 y100 w200 h30", "Recalculate Pixels Now")
gRecalcBtn.OnEvent("Click", CalculateResolution)

MyGui.AddText("x30 y150", "Current Config (Read-Only):")
MyGui.AddText("x200 y150", "Error Pixel:")
gErrX := MyGui.AddEdit("x265 y147 w40 h20 ReadOnly", IniRead(settingsFile, "Coordinates", "ErrX", defaultErrX))
gErrX.SetFont("cGray")
gErrY := MyGui.AddEdit("x310 y147 w40 h20 ReadOnly", IniRead(settingsFile, "Coordinates", "ErrY", defaultErrY))
gErrY.SetFont("cGray")

MyGui.AddText("x200 y175", "Safe Pixel:")
gSafeX := MyGui.AddEdit("x265 y172 w40 h20 ReadOnly", IniRead(settingsFile, "Coordinates", "SafeX", defaultSafeX))
gSafeX.SetFont("cGray")
gSafeY := MyGui.AddEdit("x310 y172 w40 h20 ReadOnly", IniRead(settingsFile, "Coordinates", "SafeY", defaultSafeY))
gSafeY.SetFont("cGray")

; -- Group: Tools --
MyGui.AddGroupBox("x10 y220 w440 h180 cWhite", "Diagnostics & Tools")

gDebugButton := MyGui.AddButton("x30 y240 w380 h30", "Toggle Debug Mode (Show Tooltips)")
gDebugButton.OnEvent("Click", ToggleDebug)

gTestShotBtn := MyGui.AddButton("x30 y280 w380 h30", "Test Screenshot Webhook")
gTestShotBtn.OnEvent("Click", TestScreenshot)

gKillAllButton := MyGui.AddButton("x30 y340 w380 h30 cRed", "⚠ Force Close Other Apps (Manual) ⚠")
gKillAllButton.OnEvent("Click", (*) => KillAllOthers(true))

Tab.UseTab() ; End Tabs

; --- EVENTS & INIT ---
MyGui.OnEvent("Close", (*) => ExitApp())
MyGui.Show("w460 h550")

if (gScheduleCheck.Value) {
    ToggleScheduler(gScheduleCheck)
}

; =========================
; FUNCTIONS
; =========================

CalculateResolution(*) {
    global gErrX, gErrY, gSafeX, gSafeY
    w := A_ScreenWidth
    h := A_ScreenHeight
    baseW := 1920
    baseH := 1080
    ratioX := w / baseW
    ratioY := h / baseH
    
    newErrX := Floor(defaultErrX * ratioX)
    newErrY := Floor(defaultErrY * ratioY)
    newSafeX := Floor(defaultSafeX * ratioX)
    newSafeY := Floor(defaultSafeY * ratioY)
    
    gErrX.Value := newErrX
    gErrY.Value := newErrY
    gSafeX.Value := newSafeX
    gSafeY.Value := newSafeY
    
    MsgBox("Pixels calculated for " w "x" h " resolution.", "Success", "Iconi")
    SaveSettings(false)
}

TriggerAutoSave(*) {
    SetTimer(AutoSaveTimer, -2000) 
}

AutoSaveTimer() {
    SaveSettings(false)
}

ManualSave(*) {
    SaveSettings(true)
}

SaveSettings(showPopup := false) {
    global settingsFile, debugMode
    MyGui.Submit(false)
    
    try {
        IniWrite(gLinkEdit.Value, settingsFile, "Settings", "PrivateServerLink")
        IniWrite(gIntervalEdit.Value, settingsFile, "Settings", "ClickInterval")
        IniWrite(gScreenshotInterval.Value, settingsFile, "Settings", "ScreenshotInterval")
        IniWrite(debugMode, settingsFile, "Settings", "DebugMode")
        
        IniWrite(gScheduleCheck.Value, settingsFile, "Scheduler", "Enabled")
        IniWrite(gDayDD.Text, settingsFile, "Scheduler", "Day")
        IniWrite(gHourEdit.Value, settingsFile, "Scheduler", "Hour")
        IniWrite(gMinEdit.Value, settingsFile, "Scheduler", "Min")
        IniWrite(gAmPmDD.Text, settingsFile, "Scheduler", "AmPm")
        IniWrite(gCloseAppsCheck.Value, settingsFile, "Scheduler", "CloseAppsOnSched")

        IniWrite(gWebhookEdit.Value, settingsFile, "Discord", "WebhookURL")
        IniWrite(gUserIDEdit.Value, settingsFile, "Discord", "UserID")
        IniWrite(gRemoteCheck.Value, settingsFile, "Discord", "RemoteEnabled")
        
        IniWrite(gAutoRejoinCheck.Value, settingsFile, "Coordinates", "AutoRejoin")
        IniWrite(gErrX.Value, settingsFile, "Coordinates", "ErrX")
        IniWrite(gErrY.Value, settingsFile, "Coordinates", "ErrY")
        IniWrite(gSafeX.Value, settingsFile, "Coordinates", "SafeX")
        IniWrite(gSafeY.Value, settingsFile, "Coordinates", "SafeY")

        IniWrite(gEnableFileEdit.Value, settingsFile, "FileEditor", "Enabled")
        IniWrite(gExternalFile.Value, settingsFile, "FileEditor", "FilePath")
        IniWrite(gNormalText.Value, settingsFile, "FileEditor", "NormalText")
        IniWrite(gMacroText.Value, settingsFile, "FileEditor", "MacroText")
        
        if (showPopup) {
            MsgBox("All Settings Saved Successfully!", "Settings Saved", "Iconi")
        }

    } catch as err {
        if (showPopup) {
            MsgBox("Error Saving Settings: " err.Message, "Error", "Iconx")
        }
    }
}

ToggleScheduler(ctrl, *) {
    global schedulerActive
    SaveSettings(false)
    if (ctrl.Value) {
        schedulerActive := true
        SetTimer(CheckSchedule, 10000) 
        LogDebug("Scheduler ON")
    } else {
        schedulerActive := false
        SetTimer(CheckSchedule, 0)
        LogDebug("Scheduler OFF")
    }
}

CheckSchedule() {
    global macroRunning, schedulerLatch
    if (macroRunning)
        return 

    currentDay := A_WDay 
    currentHour := FormatTime(, "HH") 
    currentMin := FormatTime(, "mm")
    currentTimeStr := currentHour . ":" . currentMin

    if (schedulerLatch == currentTimeStr)
        return

    MyGui.Submit(false) 
    targetDayStr := gDayDD.Text
    targetHourVal := Integer(gHourEdit.Value)
    targetMinVal := Integer(gMinEdit.Value)
    targetAmPm := gAmPmDD.Text

    targetHour24 := targetHourVal
    if (targetAmPm == "PM" && targetHour24 < 12) {
        targetHour24 += 12
    } else if (targetAmPm == "AM" && targetHour24 == 12) {
        targetHour24 := 0
    }

    dayMatch := false
    if (targetDayStr == "Every Day") {
        dayMatch := true
    } else {
        dayMap := Map("Sunday",1, "Monday",2, "Tuesday",3, "Wednesday",4, "Thursday",5, "Friday",6, "Saturday",7)
        if (dayMap.Has(targetDayStr) && dayMap[targetDayStr] == currentDay) {
            dayMatch := true
        }
    }

    if (dayMatch && Integer(currentHour) == targetHour24 && Integer(currentMin) == targetMinVal) {
        schedulerLatch := currentTimeStr 
        LogDebug("Schedule Hit!")
        SetTimer(() => StartMacro("scheduler"), -10)
    }
}

KillAllOthers(reqConfirm := true) {
    if (reqConfirm) {
        confirm := MsgBox("WARNING: This will force close ALL windows except:`n- Roblox`n- This Macro`n- Desktop/Windows Manager`n`nUnsaved work in other apps will be lost.`nContinue?", "Force Close Apps", "YesNo Icon!")
        if (confirm == "No")
            return
    }

    count := 0
    ids := WinGetList()
    for this_id in ids {
        try {
            title := WinGetTitle(this_id)
            if (title == "")
                continue
            if (title = "Program Manager") || (title = "Start") || (title = "Windows Task Manager") || (title = "Program Manager")
                continue
            if (InStr(title, "Roblox"))
                continue

            WinKill(this_id)
            count++
        }
    }

    browsers := ["chrome.exe", "msedge.exe", "firefox.exe", "opera.exe", "discord.exe"]
    for app in browsers {
        try {
            if ProcessExist(app) {
                RunWait("taskkill /F /IM " app, , "Hide")
            }
        }
    }
    
    if (reqConfirm) {
        MsgBox("Closed " count " background windows and terminated browsers.", "Done", "Iconi")
    } else {
        ; NO PING HERE - Just Log
        SendWebhook(":wastebasket: **Scheduler:** Closed " count " background apps.", false)
    }
}

TestScreenshot(*) {
    global gWebhookEdit
    if (gWebhookEdit.Value == "") {
        MsgBox("Please enter a Webhook URL in the Webhook tab first.", "Error", "Iconx")
        return
    }
    MsgBox("Sending Test Screenshot...`n(This may take a few seconds)", "Sending", "Iconi")
    TakeScreenshot("Manual Test", true, false) ; No ping for manual test
}

ScreenshotRoutine() {
    TakeScreenshot("Loop Screenshot", false, false) ; No ping for periodic
}

TakeScreenshot(reason, force := false, pingUser := false) {
    global gWebhookEdit, gRemoteCheck, gUserIDEdit, macroRunning
    
    if (!force && (!macroRunning || gRemoteCheck.Value == 0))
        return
        
    url := gWebhookEdit.Value
    if (url == "")
        return

    ; Conditional Ping Logic
    if (pingUser) {
        userID := gUserIDEdit.Value
        if (userID != "") {
            reason := "<@" . userID . "> " . reason
        }
    }

    tempFile := A_ScriptDir "\screen_temp.png"
    
    if FileExist(tempFile) {
        try {
            FileDelete(tempFile)
        } catch {
            LogDebug("FileDelete Locked, skipping frame")
            return 
        }
    }

    try {
        ps := "Add-Type -AssemblyName System.Windows.Forms;[System.Windows.Forms.SendKeys]::SendWait('%{PRTSC}');Start-Sleep -m 500;$img = [System.Windows.Forms.Clipboard]::GetImage();if($img -ne $null){$img.Save('" tempFile "', [System.Drawing.Imaging.ImageFormat]::Png)}"
        RunWait("powershell -Command " ps,, "Hide")
    } catch {
        return
    }

    if !FileExist(tempFile)
        return

    try {
        RunWait('curl -F "file=@' tempFile '" -F "content=' reason '" "' url '"',, "Hide")
    } catch {
        LogDebug("Curl Upload Failed")
    }
    
    if FileExist(tempFile) {
        try {
            FileDelete(tempFile)
        }
    }
}

StartMacro(source, *) {
    global macroRunning, gCloseAppsCheck, gAutoRejoinCheck
    if (macroRunning)
        return
    
    SaveSettings(false)
    
    if (source == "scheduler" && gCloseAppsCheck.Value == 1) {
        KillAllOthers(false) 
    }
    
    ModifyExternalFile("start")
    
    macroRunning := true
    ; PING ON START
    SendWebhook(":white_check_mark: **Macro Started** (Source: " source ")", true)
    
    MinimizeOthers()

    if (gAutoRejoinCheck.Value == 1) {
        if (WinExist("ahk_exe RobloxPlayerBeta.exe")) {
            if (ShouldRejoin()) {
                ; PING ON FAIL
                SendWebhook(":warning: **Initial Check Failed.** Triggering Rejoin...", true)
                if (DoRejoinSequence()) {
                    TimerLoop()
                }
            } else {
                TimerLoop()
            }
        } else {
            ; NO PING (Informational)
            SendWebhook(":information_source: **Roblox not open.** Launching...", false)
            if (DoRejoinSequence()) {
                TimerLoop()
            }
        }
    } else {
        ; PING ON START (Clicker Mode)
        SendWebhook(":mouse: **Macro Started (Clicker Only mode).**", true)
        TimerLoop()
    }
}

StopMacro(*) {
    global macroRunning
    if (!macroRunning)
        return
    
    macroRunning := false
    SetTimer(ScreenshotRoutine, 0)
    ModifyExternalFile("stop")
    ; PING ON STOP
    SendWebhook(":octagonal_sign: **Macro Stopped**.", true)
    ToolTip("Macro Stopped.")
    SetTimer(HideTooltip, -2000)
}

TimerLoop() {
    global macroRunning, gIntervalEdit, gScreenshotInterval, gRemoteCheck, gAutoRejoinCheck
    
    clickTime := Floor(Number(gIntervalEdit.Value))
    if (clickTime < 1) 
        clickTime := 1
        
    if (macroRunning && gRemoteCheck.Value == 1) {
        shotTime := Floor(Number(gScreenshotInterval.Value))
        if (shotTime < 30)
            shotTime := 30
        SetTimer(ScreenshotRoutine, shotTime * 1000)
    } else {
        SetTimer(ScreenshotRoutine, 0)
    }

    while (macroRunning) {
        if (clickTime > 0) {
            if (!macroRunning) 
                return
            ToolTip("Next click in " clickTime "s")
            Sleep(1000)
            clickTime--
        } else {
            if (!macroRunning)
                return
            
            MinimizeOthers()
            
            if (gAutoRejoinCheck.Value == 1 && ShouldRejoin()) {
                ; PING ON CRASH
                SendWebhook(":warning: **Crash Detected.** Rejoining...", true)
                TakeScreenshot("Pre-Rejoin Crash State", true, true) ; Force=True, Ping=True
                
                if (!DoRejoinSequence()) {
                    StopMacro()
                    return
                }
            } else {
                if (WinExist("ahk_exe RobloxPlayerBeta.exe")) {
                    WinActivate("ahk_exe RobloxPlayerBeta.exe")
                    WinMaximize("ahk_exe RobloxPlayerBeta.exe")
                    Sleep(500)
                    WinGetPos(&winX, &winY, &winW, &winH, "ahk_exe RobloxPlayerBeta.exe")
                    if (winW > 0) {
                        SmoothClick(winX + (winW / 2), winY + (winH / 2))
                    }
                } else {
                    if (gAutoRejoinCheck.Value == 1) {
                         ; PING ON WINDOW LOST
                         SendWebhook(":warning: **Roblox Window Gone.** Rejoining...", true)
                         if (!DoRejoinSequence()) {
                             StopMacro()
                             return
                         }
                    } else {
                        ToolTip("Waiting for Roblox (Auto-Rejoin Disabled)...")
                    }
                }
            }
            clickTime := Floor(Number(gIntervalEdit.Value))
        }
    }
}

DoRejoinSequence() {
    global macroRunning, gLinkEdit, actionDelay
    
    if (!macroRunning) 
        return false

    link := gLinkEdit.Value
    if (!InStr(link, "roblox.com/")) {
        ; PING ON ERROR
        SendWebhook(":x: **Error:** Invalid Private Server Link.", true)
        StopMacro()
        return false
    }

    ; NO PING
    SendWebhook(":arrows_counterclockwise: **Initiating Rejoin Sequence...**", false)
    
    if (WinExist("ahk_exe RobloxPlayerBeta.exe")) {
        WinClose("ahk_exe RobloxPlayerBeta.exe")
        WinWaitClose("ahk_exe RobloxPlayerBeta.exe",, 10)
    }
    Sleep(actionDelay)
    MinimizeOthers()

    loop {
        if (!macroRunning) 
            return false
        
        ToolTip("Launching Roblox (Attempt " A_Index ")...")
        
        if WinExist("A") {
            try {
                proc := WinGetProcessName("A")
                if (proc = "chrome.exe" || proc = "msedge.exe" || proc = "firefox.exe") {
                    Send("^w")
                    Sleep(500)
                }
            }
        }

        try {
            Run(link)
        }

        startTime := A_TickCount
        found := false
        while (A_TickCount - startTime < 60000) {
            if (!macroRunning) 
                return false
            if WinExist("ahk_exe RobloxPlayerBeta.exe") {
                found := true
                break
            }
            Sleep(1000)
            ToolTip("Waiting for Roblox... " Floor((60000 - (A_TickCount - startTime))/1000))
        }

        if (found)
            break
        else
            ; NO PING (Will retry)
            SendWebhook(":x: **Launch Timeout.** Retrying...", false)
    }
    
    WinActivate("ahk_exe RobloxPlayerBeta.exe")
    ToolTip("Loading Game (20s)...")
    Sleep(20000)

    if (!macroRunning)
        return false
    
    Send("{w down}")
    Sleep(actionDelay)
    Send("{w up}")
    Sleep(actionDelay)
    SmoothClick(500, 900)
    Sleep(actionDelay)
    Send("{WheelDown 10}")
    Sleep(actionDelay)
    SmoothClick(1300, 800)
    Sleep(actionDelay)
    
    ; NO PING (Success is implied)
    SendWebhook(":white_check_mark: **Rejoin Successful.**", false)
    return true
}

ShouldRejoin() {
    global gErrX, gErrY, gSafeX, gSafeY, gAutoRejoinCheck
    
    if (gAutoRejoinCheck.Value == 0)
        return false
    
    eX := Number(gErrX.Value)
    eY := Number(gErrY.Value)
    sX := Number(gSafeX.Value)
    sY := Number(gSafeY.Value)

    try {
        if PixelSearch(&fx, &fy, eX, eY, eX, eY, 0x393B3D, 5) {
            LogDebug("Error Pixel Found")
            return true 
        }
    }

    try {
        if !PixelSearch(&fx, &fy, sX, sY, sX, sY, 0x0C0B0A, 5) {
            LogDebug("Safe Pixel Missing")
            return true
        }
    }
    
    return false
}

SendWebhook(msg, pingUser := false) {
    global gWebhookEdit, gRemoteCheck, gUserIDEdit
    if (gRemoteCheck.Value == 0)
        return
        
    url := gWebhookEdit.Value
    if (url == "")
        return

    ; Conditional Ping Logic
    if (pingUser) {
        userID := gUserIDEdit.Value
        if (userID != "") {
            msg := "<@" . userID . "> " . msg
        }
    }
        
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("POST", url, true)
        whr.SetRequestHeader("Content-Type", "application/json")
        whr.Send('{"content": "' msg '"}')
        whr.WaitForResponse()
    } catch {
        LogDebug("Webhook Failed")
    }
}

MinimizeOthers() {
    if (!WinExist("ahk_exe RobloxPlayerBeta.exe"))
        return
    if (!WinActive("ahk_exe RobloxPlayerBeta.exe")) {
        Send("#m") 
        Sleep(200)
        WinActivate("ahk_exe RobloxPlayerBeta.exe")
        WinMaximize("ahk_exe RobloxPlayerBeta.exe")
    }
}

SmoothClick(x, y) {
    CoordMode("Mouse", "Screen")
    MouseGetPos(&startX, &startY)
    ; 75 steps * 20ms = 1500ms (1.5 seconds)
    loop 75 {
        MouseMove(startX + ((x-startX)*A_Index/75), startY + ((y-startY)*A_Index/75), 0)
        Sleep(20)
    }
    Click(x, y)
}

ModifyExternalFile(mode) {
    global gExternalFile, gNormalText, gMacroText, gEnableFileEdit
    if (gEnableFileEdit.Value == 0) 
        return 

    filePath := gExternalFile.Value
    if (!FileExist(filePath)) 
        return

    try {
        FileCopy(filePath, filePath ".bak", 1)
        fileContent := FileRead(filePath)
        newContent := ""
        didChange := false

        if (mode == "start" && InStr(fileContent, gNormalText.Value)) {
            newContent := StrReplace(fileContent, gNormalText.Value, gMacroText.Value)
            didChange := true
        } else if (mode == "stop" && InStr(fileContent, gMacroText.Value)) {
            newContent := StrReplace(fileContent, gMacroText.Value, gNormalText.Value)
            didChange := true
        }
        
        if (didChange) {
            FileDelete(filePath)
            FileAppend(newContent, filePath)
        }
    }
}

ToggleDebug(*) {
    global debugMode
    debugMode := (debugMode == "1") ? "0" : "1"
    SaveSettings(false)
    MsgBox(debugMode ? "Debug Mode Enabled" : "Debug Mode Disabled", "Debug", "Iconi")
}

LogDebug(msg) {
    if (debugMode == "1")
        ToolTip("DEBUG: " msg, 0, 0)
}

HideTooltip(*) {
    ToolTip()
}

F5::StartMacro("manual")
F7::StopMacro
