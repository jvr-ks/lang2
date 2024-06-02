; demo preselect2.ahk
; This is an example implementation of language selection

#Warn

#Requires AutoHotkey v2

#Include "language\language.ahk"

checkLanguageFiles() ; check if the language files exist (at least "en-US.ini"), create them if missing
lang_init() ; language initialization function

choseLanguage()

return

;------------------------------- choseLanguage -------------------------------
choseLanguage(*){
  global _language, choseLanguageGui
  local languageChanged, buttonOK
  
  langnames := []
  for key, value in _language.allLangEnNames {
    langnames.push(value)
  }
  choseLanguageGui := Gui(, lang("Demo lang() function"))
  choseLanguageGui.add("text", "xm ym w300", lang("Choose a language"))
  languageChanged := choseLanguageGui.add("DropDownList", "xm Y+10 w200 vlanguageChanged AltSubmit Choose1", langnames)
  buttonOK := choseLanguageGui.add("Button", "X+10 yp w50", "OK")
  buttonOK.OnEvent("Click", showDemoText.Bind(languageChanged))

  choseLanguageGui.show()
  choseLanguageGui.OnEvent("Close", choseLanguageGui_Close)
}
;------------------------------ languageChosen ------------------------------
showDemoText(languageChanged, *) {
  global _language, choseLanguageGui, demoGui
  local theCode

  theCode := languageNameToCode.Get(languageChanged.Text)
  langSetLanguage(theCode)
  _language.codeSelected := theCode
  
  choseLanguageGui.Destroy()
  demoGui := Gui(, lang("Demo lang() function"))
  
  ogctext1 := demoGui.add("text", "ym xm vtext1 w300", lang("Hello world"))
  ogctext2 := demoGui.add("text", "xm Y+10 vtext2 w300", lang("You can make your application multilingual!"))
  ogctext3 := demoGui.add("text", "xm Y+10 vtext3 w200", lang("Please, change the language") " ...")

  demoGui.Title := lang("Lang() demonstration")
  demoGui.show("w400")
  demoGui.OnEvent("Close", choseLanguage)
}
;-------------------------- choseLanguageGui_Close --------------------------
choseLanguageGui_Close(*){
  global 
  
  voiceIsEnabled := 1
  voiceIsSpeaker := 1
  voiceIsSpeed := 1 ; -10 .. +10
  sp := "<speak version='1.0' xmlns='http://www.w3.org/2001/10/synthesis' xml:lang='" _language.codeSelected "'>"
  sp .= lang("Thank you for using this short demonstration")
  sp .= "</speak>"
  speak(sp)
  
  cleanMemory()
  
  sleep 500
  
  ExitApp
}
;----------------------------------- speak -----------------------------------
speak(text){
  global

  if (voiceIsEnabled){
    voice := ComObject("SAPI.SpVoice")
    voice.Voice := voice.GetVoices().Item(voiceIsSpeaker)
    voice.Rate := voiceIsSpeed
    voice.Speak(text)
  }
  
  return
}
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


