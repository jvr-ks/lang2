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

