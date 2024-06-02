# lang2  
Make your AutoHotkey v2 scripts multilingual!  
Simple translations, not a fancy "i18n" library.  
  
From [bichlepa / lang](https://github.com/bichlepa/lang)  
Converted to AHK2 by JVR  
Not a 1:1 conversion!  

Variable substitution (%1% ,%2% ...) is not implemented!  
(Divide the string into parts instead).  

Easy to use. It can be integrated very easy. To use translated strings, call lang("the string to be translated").  
Examples:  
* `lang("Hello world")`  
  
## Howto include with your project  
Just add to the AHK sourcecode:  
```  
#Include "language\language.ahk"

checkLanguageFiles() ; checks if the language files exists (at least "en-US.ini"), create them if missing
                     ; example is shown below, "en-US.ini" is used as a prototyp to create files for "new" languages
                     
lang_init() ; language initialization function with system language (language used during the Windows installation)
            ; if no approbiate language file is found, a copy of "en-US.ini" is created and the user is asked to enter the translations ...

; create a gui window and then:

lang_init() ; call init again to switch to the selected language, 
            ; only necessary if another language was selected during Windows runtime 

``` 
  
The subdirectory "language" must contain the language-files (i.e. "en-US.ini" etc.).  
They are standard AutoHotkey configuration-files (UTF-16 LE BOM encoded).  
The section "[translations]" contains pairs of text and (=) the translation.  
  
Replace the text in the AHK sourcecode with a function-call to lang("text"). 
   
The language is automatically selected or can be selected by the function "langSetLanguage(paramCode)".  
"paramCode" is the language-code, like "en-US".  
If the currently used language has no "language translations definition file",  
a definition file like "ab-XY.ini" is created using "en-US.ini" as a prototyp.  
At least a hardcoded "en-US.ini" file definition must be created by the builtin function:   
**checkLanguageFiles()**  
  
Hint:  
Use [https://github.com/jvr-ks/simpletools#TranslateViaGoogle2](https://github.com/jvr-ks/simpletools#TranslateViaGoogle2)   
to translate the text.  
  
Please see the introduction in the demonstration files:  
* demo miminum2.ahk  
* demo preselect2.ahk  
    
  
"settings.ini" is not used, "lang crawler" and the "Translation tool" are not converted yet.  
  
```
;---------------------------- checkLanguageFiles Example----------------------------
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
```
  
TODO:  
* 
* A way to escape the "="-character  
  
#### Latest changes:  
Version (&gt;=)| Change  
------------ | -------------  
0.06 | Creating an "en-US.ini" file, if the file is missing.  
0.04 | Creating an "\*.ini" file using "en-US.ini" as a prototype, if the current used language is unknown.  
0.03 | Using current selected language, not the system default language!  
0.02 | language: using an object literal instead of a Map  
  







