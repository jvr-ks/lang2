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

;---------------------------- checkLanguageFiles ----------------------------
checkLanguageFiles(){
  global
  local l, d
  
  d := ".\language\"
  l := "en-US.ini"
  
  DirCreate(d)

  if (!FileExist(d l)){
    FileAppend "
    (
[language_info]
enname=English (United States)
name=English (United States)
[translations]
language=English (United States)
Hello world=Hello world
Lang() demonstration=Lang() demonstration
You can make your application multilingual!=You can make your application multilingual!
Please, change the language=Please, change the language
The current language is =The current language is 
Thank you for using this short demonstration=Thank you for using this short demonstration
Choose a language=Choose a language
Demo lang() function==Demo lang() function
    )", d l, "`n UTF-16"
  }

  l := "de-DE.ini"
  
  if (!FileExist(d l)){
    FileAppend "
    (
[language_info]
enname=German (Germany)
name=Deutsch
[translations]
language=Deutsch
Hello world=Hallo Welt
You can use any text=Du kannst beliebigen Text verwenden
Lang() demonstration=lang() Demonstration
You can make your application multilingual!=Du kannst deine Programme mehrsprachig machen!
Please, change the language=Bitte ändere die Sprache
The current language is =Die aktuelle Sprache ist 
Thank you for using this short demonstration=Vielen Dank für die Verwendung der kurzen Demonstration
Choose a language=Bitte eine Sprache wählen
Demo lang() function=Demo der "lang()"-Funktion
    )", d l, "`n UTF-16"
  }
  
  l := "fr-FR.ini"
  
  if (!FileExist(d l)){
    FileAppend "
    (
[language_info]
enname=French (France)
name=French
[translations]
language=French (France)
Hello world=Bonjour le monde
Lang() demonstration=Lang() démonstration
You can make your application multilingual!=Vous pouvez rendre votre candidature multilingue!
Please, change the language=S'il vous plaît, changez la langue
The current language is=La langue actuelle est
Thank you for using this short demonstration=Merci d'avoir utilisé cette courte démonstration
Choose a language=Choisissez une langue
Demo lang() function==Fonction de démonstration lang()
    )", d l, "`n UTF-16"
  }
  
  l := "ru-RU.ini"
  
  if (!FileExist(d l)){
    FileAppend "
    (
[language_info]
enname=Russian (Russia)
name=Русский
[translations]
language=Russian (Russia)
Hello world=Привет мир!
Lang() demonstration=lang() демонстрация
You can make your application multilingual!=Ты можешь свои программы сделать многоязычными! 
Please, change the language=Пожалуйста, измени язык
The current language is =Ты выбрал язык 
Thank you for using this short demonstration=Спасибо за использование этой короткой демонстрации
Choose a language=Выберите язык
Demo lang() function=Демонстрационная функция lang()
    )", d l, "`n UTF-16"
  }
}

