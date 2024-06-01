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

checkLanguageFiles() ; check if the language files exist (at least "en-US.ini"), create them if missing
lang_init() ; language initialization function
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
  
TODO:  
* 
* A way to escape the "="-character  
  
#### Latest changes:  
Version (&gt;=)| Change  
------------ | -------------  
0.06 | Creating an "en-US.ini" file, if the file is missing.  
0.004 | Creating an "\*.ini" file using "en-US.ini" as a prototype, if the current used language is unknown.  
0.003 | Using current selected language, not the system default language!  
0.002 | language: using an object literal instead of a Map  
  







