# lang2  
Make your AutoHotkey v2 scripts multilingual!  
  
From [bichlepa / lang](https://github.com/bichlepa/lang)  
Converted to AHK2 by JVR  
Not a 1:1 conversion!  

Easy to use. It can be integrated very easy. To use translated strings, call lang(). Examples: 
* `lang("Hello world")`


## howto  
Just add to the AHK sourcecode:  
```  
#Include "language\language.ahk"

lang_init() ; initialization routine
``` 
  
The subdirectory "language" must contain the language-files (i.e. "en-US.ini" etc.),  
They are standard AutoHotkey configuration-files (UTF-16 BOM encoded).  
The section "[translations]" contains pairs of text and (=) the translation.  
  
Replace the text in the AHK sourcecode with a function-call to lang("text"). 
   
The language is automatically selected or can be selected by the function "langSetLanguage(paramCode)".  
"paramCode" is the language-code, like "en-US".  
  
There are some builtin functions to convert between  
the language-code (hex) or the (english) language-name to the language-code,  
take a look at the file "demo preselect2.ahk".  
("_languageHexToCode ", "_languageNameToCode")
  
Please see the introduction in the demonstration files:  
* demo miminum2.ahk  
* demo preselect2.ahk  
  
  
"settings.ini" is not used, "lang crawler" and the "Translation tool" are not converted yet.  
  
TODO: A way to escape the "="-character ...  
  
#### Latest changes:  
  
Version (&gt;=)| Change  
------------ | -------------  
0.002 | _language: using an object literal instead of a Map  
  







