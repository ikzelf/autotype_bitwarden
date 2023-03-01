# autotype_bitwarden
script to present a list of names from bitwarden to choose from and type the password in the top window

first install the tools:
brew install bitwarden-cli jq

add "source ~/.config/.bw_session" to your ~/.bash_profile

bw login user@email
to start the bw agent. In the standard output comes something like:
export BW_SESSION="the session key"

copy the text 'export BW_SESSION="the session key"' to ~/.config/.bw_session
because the applescript prefixes the bw command with "source ~/.bash_profile;"

What the script tries to do is
1) check the unlocked state of the bw session
2) read the name of the top window
3) read the application name that belongs to the topwindow
4) find a folder in the bw vault that has then name of the top window
5) list the names of the items in the folder in a selection list
6) find the password of the selected item name
7) type the found password into the application that belongs to the topwindow.

