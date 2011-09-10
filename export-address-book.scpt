property targetfolder : "" as Unicode text

try
	set targetfolder to choose folder with prompt "Choose a folder or volume:"
on error
	beep
	display dialog "Invalid path" buttons "Exit"
	return
end try

tell application "Address Book"
	activate
	set visible of item -1 of windows to true

	repeat with p in (every person)
		set selection to p

		tell application "System Events"
			tell process "Address Book"
				tell menu bar 1
					click menu item "Export vCard…" of menu "Export…" of menu item "Export…" of menu "File"
					delay 1
					keystroke return
				end tell
			end tell
		end tell
	end repeat
end tell