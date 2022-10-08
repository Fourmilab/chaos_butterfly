set echo off

#  Main

menu begin Main "Choose command family menu"
menu button Model "menu show Model"
menu button Texture "menu show Texture"
menu button Run "menu show Run"
menu button Settings "menu show Settings"
menu button Exit
menu button "*Timeout*" "echo Menu timed out."
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

#   Settings

script set rate 5

menu begin Settings "Model and simulation settings"
menu button "Case on" "set case on" "menu show Settings"
menu button "Case off" "set case off" "menu show Settings"
menu button "Gravity -" "set gravity 0.05" "menu show Settings"
menu button "Gravity 1" "set gravity 0.1" "menu show Settings"
menu button "Gravity +" "set gravity 0.5" "menu show Settings"
menu button Reset "rotate reset" "Menu show Settings "
menu button "Run" "run async" "menu show Settings"
menu button "Stop" "run off" "menu show Settings"
menu button Main "Menu show Main"
menu button "*Timeout*" "echo Menu timed out."
menu end

#   Model

menu begin Model "Set model parameters"
menu button "Standard" "reset" "menu show Model"
menu button "Heavy bob 1" "set mass 1 200" "set mass 2 50" "menu show Model"
menu button "Heavy bob 2" "set mass 1 50" "set mass 2 200" "menu show Model"
menu button "Long rod 1" "set length 1 300" "set length 2 100" "menu show Model"
menu button "Long rod 2" "set length 1 100" "set length 2 300" "menu show Model"
menu button "Elevated" "set angle 1 1" "set angle 2 -1" "menu show Model"
menu button "Lowered" "set angle 1 135" "set angle 2 -135" "menu show Model"
menu button "Run" "run async" "menu show Model"
menu button "Stop" "run off" "menu show Model"
menu button Main "Menu show Main"
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

set echo on

menu show Main

script set *

@echo Exiting Commander
