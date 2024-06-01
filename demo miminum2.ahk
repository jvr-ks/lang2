; demo miminum2.ahk
; Using the operating-system-language 

#Warn

#Requires AutoHotkey v2

#Include "language\language.ahk"

checkLanguageFiles() ; check if the language files exist (at least "en-US.ini"), create them if missing
lang_init() ; language initialization function

myGui := Gui()
ogctext1 := myGui.add("text", "ym xm vtext1 w300", lang("Hello world"))
ogctext2 := myGui.add("text", "xm Y+10 vtext2 w300", lang("You can make your application multilingual!"))
ogctext3 := myGui.add("text", "xm Y+10 vtext3 w300", lang("The current language is ") lang("language") "!")

myGui.Title := lang("Lang() demonstration")
myGui.show("w400")
return

guiclose:
cleanMemory()
ExitApp