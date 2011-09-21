property targetfolder : "" as Unicode text

try
	set targetfolder to choose folder with prompt "Choose a folder or volume:" as Unicode text
on error
	beep
	display dialog "Invalid path" buttons "Exit"
	return
end try

tell application "Address Book"
	set personcount to count of every person
	repeat with i from 1 to personcount
		set p to person i
		set firstname to first name of p
		set lastname to last name of p
		set middlename to middle name of p
		set orgname to organization of p

		tell application "System Events"
			try
				set result to display dialog "Exporting entry " & i & " of " & personcount ¬
					buttons {"Stop"} ¬
					default button 1 ¬
					giving up after 1 ¬
					with title "Exporting..." with icon note

				if button returned of result = "Stop" then return
			end try
		end tell

		if firstname is not equal to "" and firstname is not missing value and lastname is not equal to "" and lastname is not missing value then
			if middlename is equal to "" or middlename is missing value then
				set middlename to "" as Unicode text
			else
				set middlename to middlename & " " as Unicode text
			end if

			set filename to (firstname & " " & middlename & lastname & ".vcf") as Unicode text
		else if orgname is not equal to "" and orgname is not missing value then
			set filename to (orgname & ".vcf") as Unicode text
		else
			set filename to "No Name.vcf" as Unicode text
		end if

		set filepath to (targetfolder as Unicode text) & (filename as Unicode text)
		set card to (get vcard of p) as Unicode text

		try
			set output to open for access file filepath with write permission
			set eof output to 0
			write card to output
			close access output
		on error
			try
				close access file filepath
			end try
		end try
	end repeat
end tell