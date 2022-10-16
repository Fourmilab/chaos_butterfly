set echo off

#  Main

menu begin Main "Choose command family menu"
menu button Run "menu show Run"
menu button Parameters "menu show Parameters"
menu button Texture "menu show Texture"
menu button Demonstration "script run Demonstration" "menu show Main"
menu button Exit
menu button "*Timeout*" "echo Menu timed out."
menu end

#   Run

menu begin Run "Run the simulation"
menu button "Run" "run asynchronous" "menu show Run"
menu button "Stop" "run off" "menu show Run"
menu button "Path trail" "set path on" "menu show Run"
menu button "Path lines" "set path lines" "menu show Run"
menu button "Path off" "set path off" "set path lines clear" "menu show Run"
menu button "Mark critical" "set critical" "menu show Run"
menu button Main "menu show Main"
menu button "*Timeout*" "echo Menu timed out."
menu end

#   Parameters

menu begin Parameters "Set model parameters, * = defaults"
menu button "Rho 16" "set rho 16" "menu show Parameters"
menu button "Rho 28 *" "set rho 28" "menu show Parameters"
menu button "Rho 36" "set rho 36" "menu show Parameters"
menu button "Sigma 5" "set sigma 5" "menu show Parameters"
menu button "Sigma 10 *" "set sigma 10" "menu show Parameters"
menu button "Sigma 20" "set sigma 20" "menu show Parameters"
menu button "Beta 5/3" "set beta 5/3" "menu show Parameters"
menu button "Beta 8/3 *" "set beta 8/3" "menu show Parameters"
menu button "Beta 11/3" "set beta 11/3" "menu show Parameters"
menu button "Run" "run async" "menu show Parameters"
menu button "Stop" "run off" "menu show Parameters"
menu button Main "Menu show Main"
menu end

#   Texture

menu begin Texture "Select butterfly texture"
menu button "1" "set texture butterfly1" "menu show Texture"
menu button "2" "set texture butterfly2" "menu show Texture"
menu button "3" "set texture butterfly3" "menu show Texture"
menu button "4" "set texture butterfly4" "menu show Texture"
menu button "5" "set texture butterfly5" "menu show Texture"
menu button "6" "set texture butterfly6" "menu show Texture"
menu button "7" "set texture butterfly7" "menu show Texture"
menu button "8" "set texture butterfly8" "menu show Texture"
menu button "9" "set texture butterfly9" "menu show Texture"
menu button "Blue morpho" "set texture butterfly10" "menu show Texture"
menu button "Mill. Falcon" "set texture falcon" "menu show Texture"
menu button Main "Menu show Main"
menu button "*Timeout*" "echo Menu timed out."
menu end
set echo on

menu show Main

script set *

@echo Exiting Commander
