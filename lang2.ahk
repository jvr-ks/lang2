/*
lang() by bichlepa
https://github.com/bichlepa/lang

converted to AHK2 by JVR
not a 1:1 translation!

license: GPL v3

Please take a look at (https://github.com/jvr-ks/lang2/raw/main/license.txt)  

Directory-structure:

YourAHK.ahk
     |
  language
     |_____ language.ahk and other *.ahk files, en-US.ini, de-DE.ini, etc.
     
     
   *.ini-files must be UTF-16 LE-BOM encoded!
*/

; The purpose of this file is to hold the version-info only!

#Requires AutoHotkey v2

appName := "lang2"
appVersion := "0.07"

msg := "Use language\language.ahk as a library (#Include `"language\language.ahk`")`n`n"
msg .= "Or run the demo `"demo miminum2.ahk`" or demo `"preselect2.ahk`""
msgbox msg

