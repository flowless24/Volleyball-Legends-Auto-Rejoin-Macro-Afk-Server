Requirement: AutoHotkey v2.0, Windows 10/11

Link to AutoHotkey Download.

https://www.autohotkey.com/

🏠 Tab 1: Main

Private Server Link

Paste your Roblox VIP/Private Server URL here. The macro uses this specific link to launch the game if a crash is detected.

Click Interval (s)

Sets how often (in seconds) the macro will move the mouse and click to prevent you from being kicked for idleness. (Recommended: 10 seconds).

Screenshot Loop (s)

Sets how often (in seconds) the macro sends a screenshot of your game to Discord while running. (Recommended: 120 seconds).

Scheduler

Enable Scheduler: Turns the auto-start timer on/off.

Start Time: Set the specific Hour, Minute, and AM/PM for the macro to start automatically.

Day: Choose "Every Day" or a specific day of the week.

Force Close ALL Apps: If checked, the macro will close all other open windows (Chrome, Spotify, etc.) when the schedule triggers to free up RAM.

Controls

Start Macro (F5): Begins the automation.

Stop Macro (F7): Stops all automation.

Save Settings: Manually saves your current configuration (though the script also auto-saves as you type).

👾 Tab 2: Webhook

Discord Webhook URL

Paste the Webhook URL created in your Discord Server Settings (Integrations > Webhooks). This is where logs and images will be sent.

Discord User ID (Optional)

Paste your numerical Discord ID here (e.g., 266398...).

Effect: The bot will @mention (ping) you only when the macro starts, stops, or detects a crash. It will remain silent for regular status updates.

Enable Screenshots & Notifications

Master switch. Uncheck this to disable all Discord integrations and run the macro locally only.

🚀 Tab 3: Bloxstrap

Enable File Editing

Check this only if you use the Bloxstrap bootstrapper. It automates editing the Bloxstrap settings file to prevent launch confirmation popups.

File Path

The location of your Bloxstrap Settings.json file.

Value when STOPPED

The text the macro should write to the file when you Stop the macro (usually enables launch confirmation for normal play).

Value when RUNNING

The text the macro should write when you Start the macro (usually disables launch confirmation so the macro can auto-rejoin without human input).

⚙️ Tab 4: Advanced

Enable Auto-Rejoin (Pixel Check)

Checked: The macro monitors the screen for crashes (error messages) or closed windows. If detected, it triggers the Rejoin Sequence.

Unchecked: The macro acts as a simple auto-clicker. It will not check for errors and will not try to rejoin.

Recalculate Pixels Now

Click this button if you change your monitor resolution or scaling settings. It recalculates the screen positions used for crash detection.

Don't change the pixel location, it is already set up to check if you are in the AFK server and if you are still connected to the game.

Toggle Debug Mode

Enables/Disables a small tooltip in the top-left corner that shows exactly what the macro is doing in real-time (e.g., "Waiting for timer", "Searching for pixels").

Test Screenshot Webhook

Immediately takes a screenshot and sends it to your Discord Webhook to verify your link is working.

Force Close Other Apps (Manual)

A manual button that instantly closes all open windows and kills browser processes (Chrome, Edge, Firefox, Discord) to free up system resources. Use with caution.



This code is generated using AI. If you have any issues with the script, let me know. I will try my best to fix it!
