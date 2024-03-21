; demo miminum2.ahk
; Using the operating-system-language 

#Requires AutoHotkey v2

#Warn

#Include "language\language.ahk"

lang_init() ; initialization routine

myGui := Gui()
ogctext1 := myGui.add("text", "ym xm vtext1 w300", lang("Hello world"))
ogctext2 := myGui.add("text", "xm Y+10 vtext2 w300", lang("You can make your application multilingual!"))

myGui.Title := lang("Lang() demonstration")
myGui.show("w400")
return

guiclose:
ExitApp()