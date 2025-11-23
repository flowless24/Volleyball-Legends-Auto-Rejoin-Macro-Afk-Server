#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All, Off

; --- Global Variables ---
global settingsFile := A_ScriptDir "\settings.ini"
global macroRunning := false
global lastProcessedID := "FirstRun" 
global screenshotTimerActive := false
global actionDelay := 2000 
global debugMode := IniRead(settingsFile, "Settings", "DebugMode", "0")
global schedulerActive := false
global schedulerLatch := "" 

CoordMode "ToolTip", "Screen"
CoordMode "Pixel", "Screen"
CoordMode "Mouse", "Screen"

; --- GUI Setup ---
MyGui := Gui("-Resize +MinimizeBox +SysMenu", "Roblox Ultimate Macro v3.9")
MyGui.BackColor := "282c34"
MyGui.SetFont("s9 cWhite", "Segoe UI")

Tab := MyGui.Add("Tab3", "x0 y0 w460 h600", ["Main Settings", "Discord", "Bloxstrap"])

; === TAB 1: MAIN SETTINGS & SCHEDULER ===
Tab.UseTab("Main Settings")

; -- Section: Connection --
MyGui.AddGroupBox("x10 y40 w440 h80 cWhite", "Connection")
MyGui.AddText("x20 y60", "Private Server Link:")
gLinkEdit := MyGui.AddEdit("x20 y80 w420 h20", IniRead(settingsFile, "Settings", "PrivateServerLink", ""))
gLinkEdit.SetFont("cBlack")

; -- Section: Behavior --
MyGui.AddGroupBox("x10 y130 w440 h85 cWhite", "Behavior")

; Click Loop
MyGui.AddText("x20 y155", "Click Loop Interval (s):")
gIntervalEdit := MyGui.AddEdit("x150 y152 w60 h20 Number", IniRead(settingsFile, "Settings", "ClickInterval", "300"))
gIntervalEdit.SetFont("cBlack")
MyGui.AddUpDown("Range1-99999", 1)

; Screenshot Loop
MyGui.AddText("x220 y155", "Screenshot Loop (s):")
gScreenshotInterval := MyGui.AddEdit("x340 y152 w60 h20 Number", IniRead(settingsFile, "Settings", "ScreenshotInterval", "120"))
gScreenshotInterval.SetFont("cBlack")
MyGui.AddUpDown("Range10-99999", 1)

; -- Section: Scheduler --
MyGui.AddGroupBox("x10 y225 w440 h120 cWhite", "Auto-Start Scheduler")
gScheduleCheck := MyGui.AddCheckbox("x20 y225 w150 h20", "Enable Scheduler")
gScheduleCheck.Value := IniRead(settingsFile, "Scheduler", "Enabled", "0")

MyGui.AddText("x20 y255", "Day:")
days := ["Every Day", "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
gDayDD := MyGui.AddDropDownList("x50 y252 w100 Choose1", days)
gDayDD.Text := IniRead(settingsFile, "Scheduler", "Day", "Every Day")
gDayDD.SetFont("cBlack")

; Time Controls with Up/Down
MyGui.AddText("x160 y255", "Time:")

; Hour (1-12)
gHourEdit := MyGui.AddEdit("x200 y252 w40 h20 Number Center", IniRead(settingsFile, "Scheduler", "Hour", "12"))
gHourEdit.SetFont("cBlack")
MyGui.AddUpDown("Range1-12", 1)

MyGui.AddText("x245 y255", ":")

; Minute (0-59)
gMinEdit := MyGui.AddEdit("x255 y252 w40 h20 Number Center", IniRead(settingsFile, "Scheduler", "Min", "00"))
gMinEdit.SetFont("cBlack")
MyGui.AddUpDown("Range0-59", 1)

; AM/PM
gAmPmDD := MyGui.AddDropDownList("x305 y252 w50 Choose1", ["AM", "PM"])
gAmPmDD.Text := IniRead(settingsFile, "Scheduler", "AmPm", "AM")
gAmPmDD.SetFont("cBlack")

gCloseAppsCheck := MyGui.AddCheckbox("x20 y295 w400 h20", "Close ALL Apps when Scheduler Starts")
gCloseAppsCheck.Value := IniRead(settingsFile, "Scheduler", "CloseAppsOnSched", "0")
gCloseAppsCheck.SetFont("cRed")

; -- Controls --
gStartButton := MyGui.AddButton("x20 y355 w200 h40", "Start Macro (F5)")
gStopButton  := MyGui.AddButton("x240 y355 w200 h40", "Stop Macro (F7)")

gKillAllButton := MyGui.AddButton("x20 y410 w420 h30 cRed", "⚠ Force Close All Other Apps (Manual) ⚠")

debugText := (debugMode == "1") ? "Debug Mode: ON" : "Debug Mode: OFF"
gDebugButton := MyGui.AddButton("x20 y450 w420 h30", debugText)

; === TAB 2: DISCORD ===
Tab.UseTab("Discord")
MyGui.AddText("x20 y40 w400", "1. Bot Token:")
gTokenEdit := MyGui.AddEdit("x20 y60 w400 h20 Password", IniRead(settingsFile, "Discord", "BotToken", ""))
gTokenEdit.SetFont("cBlack")

MyGui.AddText("x20 y90 w400", "2. Channel ID:")
gChannelIDEdit := MyGui.AddEdit("x20 y110 w400 h20", IniRead(settingsFile, "Discord", "ChannelID", ""))
gChannelIDEdit.SetFont("cBlack")

MyGui.AddText("x20 y140 w400", "3. Webhook URL:")
gWebhookEdit := MyGui.AddEdit("x20 y160 w400 h20", IniRead(settingsFile, "Discord", "WebhookURL", ""))
gWebhookEdit.SetFont("cBlack")

gRemoteCheck := MyGui.AddCheckbox("x20 y200 w400 h20", "Enable Remote Control & Screenshots")
gRemoteCheck.Value := IniRead(settingsFile, "Discord", "RemoteEnabled", "0")

; === TAB 3: BLOXSTRAP ===
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

Tab.UseTab() ; End Tabs

; --- AUTO-SAVE EVENTS ---
gLinkEdit.OnEvent("Change", TriggerAutoSave)
gIntervalEdit.OnEvent("Change", TriggerAutoSave)
gScreenshotInterval.OnEvent("Change", TriggerAutoSave)
gTokenEdit.OnEvent("Change", TriggerAutoSave)
gChannelIDEdit.OnEvent("Change", TriggerAutoSave)
gWebhookEdit.OnEvent("Change", TriggerAutoSave)
gExternalFile.OnEvent("Change", TriggerAutoSave)
gNormalText.OnEvent("Change", TriggerAutoSave)
gMacroText.OnEvent("Change", TriggerAutoSave)

gCloseAppsCheck.OnEvent("Click", InstantSave)
gScheduleCheck.OnEvent("Click", ToggleScheduler) 
gRemoteCheck.OnEvent("Click", ToggleRemoteControl)
gEnableFileEdit.OnEvent("Click", InstantSave)
gDayDD.OnEvent("Change", InstantSave)
gHourEdit.OnEvent("Change", InstantSave)
gMinEdit.OnEvent("Change", InstantSave)
gAmPmDD.OnEvent("Change", InstantSave)

; Button Events
gStartButton.OnEvent("Click", (*) => StartMacro("manual"))
gStopButton.OnEvent("Click", StopMacro)
gKillAllButton.OnEvent("Click", KillAllOthers)
gDebugButton.OnEvent("Click", ToggleDebug)
MyGui.OnEvent("Close", (*) => ExitApp())

MyGui.Show("w460 h540")

; --- INITIALIZATION ---
if (gRemoteCheck.Value) {
    ToggleRemoteControl(gRemoteCheck)
}
if (gScheduleCheck.Value) {
    ToggleScheduler(gScheduleCheck)
}
if (debugMode == "1") {
    ToolTip("Debug Mode Enabled")
    SetTimer(HideTooltip, -2000)
}

; --- AUTO-SAVE LOGIC ---
TriggerAutoSave(*) {
    SetTimer(PerformSave, -1000)
}

InstantSave(*) {
    PerformSave()
}

PerformSave() {
    global gLinkEdit, gIntervalEdit, gScreenshotInterval, gCloseAppsCheck, gTokenEdit, gChannelIDEdit, gWebhookEdit, gRemoteCheck, gEnableFileEdit, gExternalFile, gNormalText, gMacroText, gScheduleCheck, gDayDD, gHourEdit, gMinEdit, gAmPmDD, settingsFile, debugMode
    
    try {
        IniWrite(gLinkEdit.Value, settingsFile, "Settings", "PrivateServerLink")
        IniWrite(gIntervalEdit.Value, settingsFile, "Settings", "ClickInterval")
        IniWrite(gScreenshotInterval.Value, settingsFile, "Settings", "ScreenshotInterval")
        IniWrite(debugMode, settingsFile, "Settings", "DebugMode")
        
        IniWrite(gCloseAppsCheck.Value, settingsFile, "Scheduler", "CloseAppsOnSched")
        IniWrite(gScheduleCheck.Value, settingsFile, "Scheduler", "Enabled")
        IniWrite(gDayDD.Text, settingsFile, "Scheduler", "Day")
        IniWrite(gHourEdit.Value, settingsFile, "Scheduler", "Hour")
        IniWrite(gMinEdit.Value, settingsFile, "Scheduler", "Min")
        IniWrite(gAmPmDD.Text, settingsFile, "Scheduler", "AmPm")

        IniWrite(gTokenEdit.Value, settingsFile, "Discord", "BotToken")
        IniWrite(gChannelIDEdit.Value, settingsFile, "Discord", "ChannelID")
        IniWrite(gWebhookEdit.Value, settingsFile, "Discord", "WebhookURL")
        IniWrite(gRemoteCheck.Value, settingsFile, "Discord", "RemoteEnabled")

        IniWrite(gEnableFileEdit.Value, settingsFile, "FileEditor", "Enabled")
        IniWrite(gExternalFile.Value, settingsFile, "FileEditor", "FilePath")
        IniWrite(gNormalText.Value, settingsFile, "FileEditor", "NormalText")
        IniWrite(gMacroText.Value, settingsFile, "FileEditor", "MacroText")
        
        if (debugMode == "1") {
            ToolTip("Settings Saved (Auto)")
            SetTimer(HideTooltip, -500)
        }
    } catch {
    }
}

; --- SCHEDULER LOGIC ---
ToggleScheduler(ctrl, *) {
    global schedulerActive
    InstantSave() 
    if (ctrl.Value) {
        schedulerActive := true
        SetTimer(CheckSchedule, 10000) 
        LogDebug("Scheduler Activated")
    } else {
        schedulerActive := false
        SetTimer(CheckSchedule, 0)
        LogDebug("Scheduler Deactivated")
    }
}

CheckSchedule() {
    global gDayDD, gHourEdit, gMinEdit, gAmPmDD, macroRunning, schedulerLatch
    
    if (macroRunning) {
        return 
    }

    currentDay := A_WDay 
    currentHour := FormatTime(, "HH") 
    currentMin := FormatTime(, "mm")
    
    ; Pad min with 0 if needed for string comparison
    cMinStr := currentMin
    
    currentTimeStr := currentHour . ":" . cMinStr

    if (schedulerLatch == currentTimeStr) {
        return
    }

    targetDayStr := gDayDD.Text
    targetHourVal := Integer(gHourEdit.Value)
    targetMinVal := Integer(gMinEdit.Value)
    targetAmPm := gAmPmDD.Text

    ; Convert Target to 24h
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
        LogDebug("Schedule Matched! Starting...")
        SetTimer(() => StartMacro("scheduler"), -10)
    }
}

; --- CLOSE APPS LOGIC (Whitelist Method) ---
KillAllOthers(*) {
    LogDebug("Closing Windows...")
    
    ; Get all window IDs
    ids := WinGetList()
    count := 0
    
    for this_id in ids {
        try {
            title := WinGetTitle(this_id)
            
            ; 1. Skip windows without a title
            if (title == "")
                continue
            
            ; 2. WHITELIST - KEEP THESE
            if (title = "Program Manager") ; Desktop
                continue
            if (title = "Start") ; Start Menu
                continue
            if (title = "Windows Task Manager")
                continue
            if (InStr(title, "Roblox Ultimate Macro")) ; KEEP THIS SCRIPT OPEN
                continue
            if (InStr(title, "Roblox")) ; KEEP GAME OPEN
                continue

            ; 3. Close the window
            LogDebug("Closing: " title)
            WinClose(this_id)
            count++
        }
    }
    LogDebug("Closed " count " windows.")
}

; --- DEBUG ---
ToggleDebug(*) {
    global debugMode, gDebugButton
    debugMode := (debugMode == "1") ? "0" : "1"
    PerformSave() 
    if (debugMode == "1") {
        gDebugButton.Text := "Debug Mode: ON"
        ToolTip("Debug Mode Enabled")
        SetTimer(HideTooltip, -2000)
    } else {
        gDebugButton.Text := "Debug Mode: OFF"
        ToolTip()
    }
}

LogDebug(msg) {
    global debugMode
    if (debugMode == "1") {
        ToolTip("DEBUG: " msg, 0, 0) 
    }
}

; --- FILE EDIT ---
ModifyExternalFile(mode) {
    global gExternalFile, gNormalText, gMacroText, gEnableFileEdit
    
    if (gEnableFileEdit.Value == 0) {
        return 
    }

    filePath := gExternalFile.Value
    normalTxt := gNormalText.Value
    macroTxt := gMacroText.Value

    if (filePath == "" || normalTxt == "" || macroTxt == "") {
        return 
    }

    if (!FileExist(filePath)) {
        LogDebug("Error: Settings file not found!")
        return
    }

    try {
        fileContent := FileRead(filePath)
        newContent := ""
        didChange := false

        if (mode == "start") {
            if InStr(fileContent, normalTxt) {
                newContent := StrReplace(fileContent, normalTxt, macroTxt)
                didChange := true
            }
        } 
        else if (mode == "stop") {
            if InStr(fileContent, macroTxt) {
                newContent := StrReplace(fileContent, macroTxt, normalTxt)
                didChange := true
            }
        }
        
        if (didChange) {
            FileDelete(filePath)
            FileAppend(newContent, filePath)
            Sleep(500) 
        }
    }
}

; --- REMOTE CONTROL ---
ToggleRemoteControl(ctrl, *) {
    global lastProcessedID
    InstantSave()
    if (ctrl.Value) {
        lastProcessedID := "FirstRun"
        SetTimer(CheckDiscordCommands, 5000)
        LogDebug("Remote Control Enabled")
    } else {
        SetTimer(CheckDiscordCommands, 0)
        SetTimer(ScreenshotRoutine, 0) 
        LogDebug("Remote Disabled")
    }
}

SendDiscordLog(msg) {
    global gWebhookEdit
    url := gWebhookEdit.Value
    if (url == "") {
        return
    }
    body := '{"content": "' msg '"}'
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("POST", url, true)
        whr.SetRequestHeader("Content-Type", "application/json")
        whr.Send(body)
        whr.WaitForResponse()
    }
}

ScreenshotRoutine() {
    global gWebhookEdit, macroRunning
    if (!macroRunning) {
        return
    }

    webhook := gWebhookEdit.Value
    if (webhook == "") {
        return
    }

    tempFile := A_ScriptDir "\screen_temp.png"
    if FileExist(tempFile) {
        FileDelete(tempFile)
    }

    psScript := "Add-Type -AssemblyName System.Windows.Forms;[System.Windows.Forms.SendKeys]::SendWait('%{PRTSC}');Start-Sleep -m 500;$img = [System.Windows.Forms.Clipboard]::GetImage();if($img -ne $null){$img.Save('" tempFile "', [System.Drawing.Imaging.ImageFormat]::Png)}"
    RunWait("powershell -Command " psScript,, "Hide")

    if !FileExist(tempFile) {
        return
    }

    runStr := 'curl -F "file=@' tempFile '" "' webhook '"'
    RunWait(runStr,, "Hide")

    if FileExist(tempFile) {
        FileDelete(tempFile)
    }
}

CheckDiscordCommands() {
    global gTokenEdit, gChannelIDEdit, macroRunning, lastProcessedID

    token := gTokenEdit.Value
    channelID := gChannelIDEdit.Value
    if (token == "" || channelID == "") {
        return
    }

    url := "https://discord.com/api/v9/channels/" channelID "/messages?limit=1"
    
    try {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", url, true)
        whr.SetRequestHeader("User-Agent", "DiscordBot (https://github.com/AutoHotkey, 2.0)")
        whr.SetRequestHeader("Authorization", "Bot " token)
        whr.SetRequestHeader("Content-Type", "application/json")
        whr.Send()
        whr.WaitForResponse()
        
        response := whr.ResponseText
        
        if RegExMatch(response, '"id":\s*"(\d+)"', &idMatch) {
            msgID := idMatch[1]
            if RegExMatch(response, '"content":\s*"(.*?)"', &contentMatch) {
                msgContent := contentMatch[1]
            } else {
                msgContent := ""
            }

            if (msgID != "" && msgID != lastProcessedID) {
                if (lastProcessedID == "FirstRun") {
                    lastProcessedID := msgID
                    LogDebug("Connected to Discord.")
                    return
                }
                lastProcessedID := msgID
                
                LogDebug("Command: " msgContent)
                if (msgContent == "!start") {
                    if (!macroRunning) {
                        SetTimer(() => StartMacro("manual"), -10)
                    }
                } 
                else if (msgContent == "!stop") {
                    if (macroRunning) {
                        SetTimer(StopMacro, -10)
                    }
                }
            }
        }
    }
}

; --- MACRO LOGIC ---
StartMacro(source, *) {
    global macroRunning, gCloseAppsCheck
    if (macroRunning) {
        return
    }
    
    LogDebug("Starting Macro (Source: " source ")")
    
    ; Check if source is scheduler AND checkbox is checked
    if (source == "scheduler" && gCloseAppsCheck.Value == 1) {
        KillAllOthers()
    }
    
    ModifyExternalFile("start")
    
    macroRunning := true
    SendDiscordLog(":white_check_mark: **Macro Started (" source ")**")
    
    MinimizeOthers()

    if (WinExist("ahk_exe RobloxPlayerBeta.exe")) {
        LogDebug("Checking Status...")
        
        if (ShouldRejoin()) {
            LogDebug("Pixel Check Failed. Rejoining.")
            if (DoRejoinSequence()) {
                TimerLoop()
            }
        } else {
            LogDebug("Status OK. Starting Loop.")
            TimerLoop()
        }
    } else {
        LogDebug("Roblox not found. Rejoining.")
        if (DoRejoinSequence()) {
            TimerLoop()
        }
    }
}

StopMacro(*) {
    global macroRunning
    if (!macroRunning) {
        return
    }
    macroRunning := false
    
    ; Stop Screenshot Timer
    SetTimer(ScreenshotRoutine, 0) 
    
    ModifyExternalFile("stop")
    
    SendDiscordLog(":octagonal_sign: **Macro Stopped**.")
    ToolTip("Macro Stopped.")
    SetTimer(HideTooltip, -2000)
}

TimerLoop() {
    global macroRunning, gIntervalEdit, gScreenshotInterval, gRemoteCheck
    
    local countdown := Floor(Number(gIntervalEdit.Value))
    if (countdown < 1) {
        countdown := 1
    }

    ; --- SCREENSHOT TIMER SETUP ---
    ; Ensure we read the new "Screenshot Loop" value
    if (macroRunning && gRemoteCheck.Value == 1) {
        screenInterval := Floor(Number(gScreenshotInterval.Value))
        if (screenInterval < 10) {
            screenInterval := 10 ; Minimum safety
        }
        
        LogDebug("Screenshots enabled every " screenInterval "s")
        
        ; Start the timer
        SetTimer(ScreenshotRoutine, screenInterval * 1000) 
        ; Take one immediately to verify
        SetTimer(ScreenshotRoutine, -1000)
    } else {
        ; Ensure it is off if unchecked
        SetTimer(ScreenshotRoutine, 0)
    }

    while (macroRunning) {
        if (countdown > 0) {
            if (!macroRunning) {
                return
            }
            ToolTip("Next click in " countdown "s")
            loop 10 {
                if (!macroRunning) {
                    return
                }
                Sleep(100)
            }
            countdown--
        } else {
            if (!macroRunning) {
                return
            }
            
            MinimizeOthers()
            
            ; SAFETY CHECK: 
            if (ShouldRejoin()) {
                LogDebug("Pixel Condition Met! Rejoining...")
                SendDiscordLog(":warning: **Check Failed.** Rejoining...")
                if (!DoRejoinSequence()) {
                    StopMacro()
                    return
                }
            } else {
                ; Pixels are correct -> Click
                LogDebug("Status OK. Clicking...")
                if (WinExist("ahk_exe RobloxPlayerBeta.exe")) {
                    WinActivate("ahk_exe RobloxPlayerBeta.exe")
                    WinMaximize("ahk_exe RobloxPlayerBeta.exe")
                    Sleep(500)
                    
                    WinGetPos(&winX, &winY, &winW, &winH, "ahk_exe RobloxPlayerBeta.exe")
                    if (winW > 0) {
                        SmoothClick(winX + (winW / 2), winY + (winH / 2))
                    }
                } else {
                    SendDiscordLog(":warning: **Roblox Closed.** Rejoining...")
                    if (!DoRejoinSequence()) {
                        StopMacro()
                        return
                    }
                }
            }
            
            countdown := Floor(Number(gIntervalEdit.Value))
        }
    }
}

DoRejoinSequence() {
    global macroRunning, gLinkEdit, actionDelay
    if (!macroRunning) {
        return false
    }

    link := gLinkEdit.Value
    if (!InStr(link, "roblox.com/")) {
        StopMacro()
        return false
    }

    SendDiscordLog(":arrows_counterclockwise: **Rejoining Server...**")
    LogDebug("Rejoin Sequence Started")
    
    if (WinExist("ahk_exe RobloxPlayerBeta.exe")) {
        WinClose("ahk_exe RobloxPlayerBeta.exe")
        WinWaitClose("ahk_exe RobloxPlayerBeta.exe",, 10)
    }
    Sleep(actionDelay)

    MinimizeOthers()

    ; INFINITE REJOIN LOOP
    loop {
        if (!macroRunning) {
            return false
        }
        
        ToolTip("Launching Roblox (Attempt " A_Index ")...")
        
        activeProcess := ""
        try {
            if WinExist("A") {
                activeProcess := WinGetProcessName("A")
            }
        }
        if (A_Index > 1 && (activeProcess = "chrome.exe" || activeProcess = "msedge.exe" || activeProcess = "firefox.exe")) {
            Send("^w") 
            Sleep(500)
        }

        try {
            Run(link)
        }
        
        startTime := A_TickCount
        found := false
        
        while (A_TickCount - startTime < 60000) {
            if (!macroRunning) {
                return false
            }
            if WinExist("ahk_exe RobloxPlayerBeta.exe") {
                found := true
                break
            }
            Sleep(1000)
            ToolTip("Waiting... (" Floor((60000 - (A_TickCount - startTime))/1000) "s)")
        }

        if (found) {
            break 
        } else {
            SendDiscordLog(":x: **Launch Failed.** Retrying...")
            LogDebug("Launch Timeout. Retrying...")
        }
    }
    
    WinActivate("ahk_exe RobloxPlayerBeta.exe")
    ToolTip("Loading Game (20s)...")
    Sleep(20000) 

    if (!macroRunning) {
        return false
    }
    
    LogDebug("Performing Setup Actions...")
    Sleep(actionDelay)
    
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
    
    SendDiscordLog(":white_check_mark: **Rejoin Successful.**")
    LogDebug("Rejoin Complete.")
    return true
}

MinimizeOthers() {
    if (!WinExist("ahk_exe RobloxPlayerBeta.exe")) {
        return
    }
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
    steps := 5
    loop steps {
        MouseMove(startX + ((x-startX)*A_Index/steps), startY + ((y-startY)*A_Index/steps), 0)
        Sleep(10)
    }
    Click(x, y)
}

HideTooltip(*) {
    ToolTip()
}

ShouldRejoin() {
    ; Returns TRUE if we should rejoin.
    ; Returns FALSE if everything looks safe.
    
    if (!WinActive("ahk_exe RobloxPlayerBeta.exe")) {
        return false 
    }

    ; Check 1 (Error Pixel): 852, 481 | 0x393B3D
    ; If this color IS found, we must Rejoin.
    try {
        if PixelSearch(&fx, &fy, 852, 481, 852, 481, 0x393B3D, 3) {
            return true ; FOUND = ERROR -> Rejoin
        }
    }

    ; Check 2 (Safety Pixel): 1577, 295 | 0x0C0B0A
    ; If this color is NOT found, we must Rejoin.
    try {
        if !PixelSearch(&fx, &fy, 1577, 295, 1577, 295, 0x0C0B0A, 3) {
            return true ; NOT FOUND = ERROR -> Rejoin
        }
    }
    
    return false ; Safe
}

F5::StartMacro("manual")
F7::StopMacro