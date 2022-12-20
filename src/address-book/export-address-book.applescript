property targetfolder : "" as Unicode text

try
	set targetfolder to choose folder with prompt "Choose a folder or volume:" as Unicode text
on error
	beep
	display dialog "Invalid path" buttons "Exit"
	return
end try

tell application "Address Book"
	set groupnames to name of every group
	copy "All" to the beginning of groupnames
	set selectedgroups to choose from list groupnames ¬
		with title "Groups" with prompt "Choose group(s) to export" with multiple selections allowed

	if selectedgroups is equal to false then return

	if selectedgroups contains "All" then
		set contacts to every person
	else
		set contacts to {}
		repeat with selectedgroup in selectedgroups
			copy every person in group selectedgroup to contacts
		end repeat
	end if

	repeat with contact in contacts
		set firstname to first name of contact
		set lastname to last name of contact
		set middlename to middle name of contact
		set orgname to organization of contact

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
		set card to (get vcard of contact) as Unicode text

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

	display dialog "Finished exporting " & (count of contacts) & " contacts!"
end tell