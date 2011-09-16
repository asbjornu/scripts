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
		set firstname to (first name of p as Unicode text)
		set lastname to (last name of p as Unicode text)
		set middlename to (middle name of p as Unicode text)
		set orgname to (organization of p as Unicode text)

		tell application "System Events"
			display dialog "Processing message " & i & " of " & personcount giving up after 1 with icon note
		end tell

		if firstname ≠ "" and firstname ≠ "missing value" and lastname ≠ "" and lastname ≠ "missing value" then
			if middlename = "" or middlename = "missing value" then
				set middlename to "" as Unicode text
			else
				set middlename to middlename & " " as Unicode text
			end if

			set filename to (firstname & " " & middlename & lastname & ".vcf") as Unicode text
		else if orgname ≠ "" and orgname ≠ "missing value" then
			set filename to (orgname & ".vcf") as Unicode text
		else
			set filename to "No Name.vcf" as Unicode text
		end if

		set filepath to (targetfolder as Unicode text) & (filename as Unicode text)
		set card to (get vcard of p) as Unicode text

		try
			set ff to open for access file filepath with write permission
			set eof ff to 0
			write card to ff
			close access ff
		on error
			try
				close access file filepath
			end try
		end try
	end repeat
end tell