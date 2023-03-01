# activated with a citrix viewer window as front window using a keyboard shortcut
# finds the name of that window
# and searches for a group in the bitwarden vault that matches that window name
# the idea is that this prevents having to hard code group names in the script
#
# depends on bw that can/should be installed using brew install bitwarden-cli jq
# https://github.com/bitwarden/clients/tree/master/apps/cli#readme
# first run bw login your_bitwarden_account from the terminal and export the export BW_SESSION using the key presented.
# (C) Ronald Rood - 2023
# uses ~/.bash_profile to set PATH and BW_SESSION

on FileExists(theFile) -- (String) as Boolean
	tell application "System Events"
		if exists file theFile then
			return true
		else
			return false
		end if
	end tell
end FileExists

tell application "System Events"
	set frontAppProcess to first application process whose frontmost is true
	set frontAppName to name of frontAppProcess
	# display dialog frontAppName
	# get title of top citrix viewer window
	tell process frontAppName
		tell (1st window whose value of attribute "AXMain" is true)
			set windowTitle to value of attribute "AXTitle"
		end tell
	end tell
	# display dialog windowTitle
	
	set connected_name to (do shell script ". ~/.bash_profile;bw status|jq -r '.| [ .userEmail, .status ]|@tsv'")
	if (connected_name does not end with "unlocked") then
		display dialog connected_name & "
		first run: bw login your@email
		and echo 'export BW_SESSION=xxxxxxxxxx >~/.config/.bw_session (as output from bw login)
		and have ~/.bash_profile source ~/.config/.bw_session
	from the terminal" default button ("OK")
	else
		try
			
			set debugaction to "getGroupID"
			set GroupID to (do shell script ". ~/.bash_profile;bw list folders --search '" & windowTitle & "' |jq -r  '.[0].id'")
			
			set debugaction to "listsgroep " & GroupID
			# get the items from the group 
			set lijstje to (do shell script ". ~/.bash_profile;bw list items --folderid '" & GroupID & "'  |jq -r  '.[] |[ .name, .id] |@tsv'")
			
			display dialog connected_name & "
		" & windowTitle & "
		
		" & lijstje default button ("OK")
			
			set keuzelijstje to paragraphs of lijstje
			set debugaction to "choose pwd item"
			try
				set de_keuze to choose from list keuzelijstje with prompt "Select pwd item:"
			on error
				return
			end try
			# display dialog (de_keuze)
			set debugaction to "get ID uit " & de_keuze
			set gekozen_ID to do shell script "awk '{print substr($NF, 1, length($NF)-1)}'<<<" & quoted form of (item 1 of de_keuze)
			
			set debugaction to "get pwd van ID: " & gekozen_ID
			set pwd to do shell script ". ~/.bash_profile;bw get item  " & gekozen_ID & "|jq -r .login.password"
			
			# eventually preview and edit before typing instead of directly set texttosay to pwd:
			# display dialog "pwd to type:" default answer pwd
			# set texttosay to the text returned of the result
			set texttosay to pwd
			
			activate application frontAppName # "Citrix Viewer"
			try
				keystroke texttosay
			on error errMsg number errorNumber
				display dialog errMsg & " :  " & errorNumber as text
			end try
			
		on error errMsg number errorNumber
			display dialog debugaction & " : " & errMsg
		end try
	end if
	
end tell


