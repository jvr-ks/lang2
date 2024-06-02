/*
lang() by bichlepa
https://github.com/bichlepa/lang

converted to AHK2 by JVR
not a 1:1 translation!

lang is read from system!

license: GPL v3

Please take a look at (https://github.com/jvr-ks/lang2/raw/main/license.txt)  

contents of _language:
  ;Settings:
  .lang      the two character language code of the desired language (eg. "en" or "de") (default: automatic then "en")
  (Changed) .fallbacklang  fallback language if a translation is not available in the desired language (default: "en")
  .dir      path to the translation files (default: A_ScriptDir "\language")

  ;Informations:
  .allLangs    associative array of objects with informations about the available languages. The keys are the language codes
    .code      the two character long code of the desired language
    .langname    language name
    .enlangname    language name in English
    .filepath    filepath of the translation file

  .allLangCodes  Map of strings with all available language codes, key is code
  .allLangNames  Map of strings with all available language names, key is code
  .allLangEnNames  Map of strings with all available language names in English, key is code
  
  ;other values are for internal use

*/

#Requires AutoHotkey v2

;--------------------------------- lang_init ---------------------------------
;Initialization. Find all available languages and set the current language
; Language is set via the AHK "A_Language" transformed to code via the Map "_languageHexToCode"
; Example: "A_Language" results in "0409" which transforms to "en-US"
; (not only "en" because 409 is "English (United States)" and "en" is "English" only, which has hex-code "0009")

; Changed: "A_Language" contains the installation language, not the current used language!
; Using user32.dll\GetKeyboardLayout to get the current used language via the keyboard layout.
 
;_language := Map()
translationsMap := Map()
 
;--------------------------------- lang_init ---------------------------------
lang_init() {
  global _language, codeSelected, langNumber
  local content

  _language := Object() ; an object literal
  _language.dir := A_ScriptDir "\language"
  _language.fallbacklang := "en-US" ; not used
  _language.codeSelected := "en-US"
  _language.allLangCodes := Map()
  _language.allLangNames := Map()
  _language.allLangEnNames := Map()
  _language.allLangsFilepath := Map()
  
  langProtoFile := _language.dir "\en-US.ini"
  
  ;Search for languages
  Loop Files, _language.dir "\*.ini" {
    code := StrReplace(A_LoopFileName, "." A_LoopFileExt,,,, 1)
    enlangname := IniRead(A_LoopFilePath, "language_info", "enname")
    langname := IniRead(A_LoopFilePath, "language_info", "name")
    
    if (enlangname != "Error" && langname != "Error" && code != "Error") {
      _language.allLangCodes.Set(code, code)
      _language.allLangNames.Set(code, langname)
      _language.allLangEnNames.Set(code, enlangname)
      _language.allLangsFilepath.Set(code, A_LoopFilePath)
    }
  }
    
  ThreadId := DllCall("user32.dll\GetWindowThreadProcessId", "Ptr", WinActive("A"), "UInt", 0, "UInt")
  langNumber := format("{:04x}",(0xFFFF & DllCall("user32.dll\GetKeyboardLayout", "UInt", ThreadId, "UInt")))
  ; A_Language gives system default language, not the selected language,
  ; but the DLL call is only valid if a gui is already opened!
  if (langNumber = "0000"){
    langNumber := A_Language
    ; msgbox languageHexToCode.Get(langNumber)
  }
  codeSelected := languageHexToCode.Get(langNumber)  ; Get the name current selected language.
  _language.codeSelected := codeSelected
  
  if (!_language.allLangsFilepath.Has(codeSelected)){
    langIniFile := _language.dir "\" codeSelected ".ini"
    
    if (!FileExist(langIniFile)){
      content := FileRead(langProtoFile)
      content := StrReplace(content, "enname=English (United States)", "enname=" languageHexToName.Get(langNumber))
      content := StrReplace(content, "name=English (United States)", "name=Please replace by the name of your language!")
    
      FileAppend content, langIniFile, "`n UTF-16"

      result := msgbox("Language " codeSelected " has no translation file.`nCreated the file: " langIniFile ",`nplease edit it and enter the translations!`n`nOpen " langIniFile " to edit?")
      if (result = "Yes")
        RunWait A_ComSpec " /c " langIniFile,,
      
      cleanMemory()
      
      reload
    }
  }
  
  generateTranslations(IniRead(_language.allLangsFilepath.Get(codeSelected), "translations"))
}
;--------------------------- generateTranslations ---------------------------
generateTranslations(translations){
  global translationsMap
  local trLines
  
  translationsMap.Clear()
    
  trLines := StrSplit(translations, "`n")

  Loop trLines.length {
    trA := StrSplit(trLines[A_Index], "=")
    if (trA[1] != "" && trA[2] != ""){
      translationsMap.Set(trA[1], trA[2])
    }
  }
}
;----------------------------- langSetLanguage -----------------------------
; Set a language, pass the code of the language.
; It can be called to set the language, "A_Language" (systemlanguage) is used otherwise (Changed!).

langSetLanguage(paramCode := "") {
  global _language
  local codeSelected
  
  if (paramCode != "") {
    if (!(_language.allLangCodes.Has(paramCode))){
      MsgBox("Unknown language-code, using default language", "Error occured!", "Icon!")
    } else {
      codeSelected := paramCode
      generateTranslations(IniRead(_language.allLangsFilepath.Get(codeSelected), "translations"))
      _language.codeSelected := codeSelected
    }
  }
}
;----------------------------------- lang -----------------------------------
;translate
lang(toBeTranslated) {
  global _language, translationsMap
  local translatedText, l
  
  if (toBeTranslated = "")
    return ""
  
  translatedText := translationsMap.Get(toBeTranslated, toBeTranslated) ; fallback, no translation
  
  return translatedText
}

;-------------------------------- cleanMemory --------------------------------
cleanMemory(){
  global
  
  translationsMap := ""
  _language.allLangCodes := ""
  _language.allLangNames := ""
  _language.allLangEnNames := ""
  _language.allLangsFilepath := ""
  language := ""
  
}
;----------------------------------------------------------------------------
languageHexToCode := Map(
  "0036", "af",
  "0436", "af-ZA",
  "001C", "sq",
  "041C", "sq-AL",
  "0484", "gsw-FR",
  "005E", "am",
  "045E", "am-ET",
  "0001", "ar",
  "1401", "ar-DZ",
  "3C01", "ar-BH",
  "0C01", "ar-EG",
  "0801", "ar-IQ",
  "2C01", "ar-JO",
  "3401", "ar-KW",
  "3001", "ar-LB",
  "1001", "ar-LY",
  "1801", "ar-MA",
  "2001", "ar-OM",
  "4001", "ar-QA",
  "0401", "ar-SA",
  "2801", "ar-SY",
  "1C01", "ar-TN",
  "3801", "ar-AE",
  "2401", "ar-YE",
  "002B", "hy",
  "042B", "hy-AM",
  "004D", "as",
  "044D", "as-IN",
  "002C", "az",
  "742C", "az-Cyrl",
  "082C", "az-Cyrl-AZ",
  "782C", "az-Latn",
  "042C", "az-Latn-AZ",
  "0045", "bn",
  "0845", "bn-BD",
  "006D", "ba",
  "046D", "ba-RU",
  "002D", "eu",
  "042D", "eu-ES",
  "0023", "be",
  "0423", "be-BY",
  "0445", "bn-IN",
  "781A", "bs",
  "641A", "bs-Cyrl",
  "201A", "bs-Cyrl-BA",
  "681A", "bs-Latn",
  "141A", "bs-Latn-BA",
  "007E", "br",
  "047E", "br-FR",
  "0002", "bg",
  "0402", "bg-BG",
  "0055", "my",
  "0455", "my-MM",
  "0003", "ca",
  "0403", "ca-ES",
  "005F", "tzm",
  "045F", "tzm-Arab-MA",
  "7C5F", "tzm-Latn",
  "085F", "tzm-Latn-DZ",
  "785F", "tzm-Tfng",
  "105F", "tzm-Tfng-MA",
  "0092", "ku",
  "7C92", "ku-Arab",
  "0492", "ku-Arab-IQ",
  "005C", "chr",
  "7C5C", "chr-Cher",
  "045C", "chr-Cher-US",
  "7804", "zh",
  "0004", "zh-Hans",
  "0804", "zh-CN",
  "1004", "zh-SG",
  "7C04", "zh-Hant",
  "0C04", "zh-HK",
  "1404", "zh-MO",
  "0404", "zh-TW",
  "0083", "co",
  "0483", "co-FR",
  "001A", "hr",
  "101A", "hr-BA",
  "041A", "hr-HR",
  "0005", "cs",
  "0405", "cs-CZ",
  "0006", "da",
  "0406", "da-DK",
  "0065", "dv",
  "0465", "dv-MV",
  "0013", "nl",
  "0813", "nl-BE",
  "0413", "nl-NL",
  "0C51", "dz-BT",
  "0066", "bin",
  "0466", "bin-NG",
  "0009", "en",
  "0C09", "en-AU",
  "2809", "en-BZ",
  "1009", "en-CA",
  "2409", "en-029",
  "3C09", "en-HK",
  "4009", "en-IN",
  "3809", "en-ID",
  "1809", "en-IE",
  "2009", "en-JM",
  "4409", "en-MY",
  "1409", "en-NZ",
  "3409", "en-PH",
  "4809", "en-SG",
  "1C09", "en-ZA",
  "2C09", "en-TT",
  "4C09", "en-AE",
  "0809", "en-GB",
  "0409", "en-US",
  "3009", "en-ZW",
  "0025", "et",
  "0425", "et-EE",
  "0038", "fo",
  "0438", "fo-FO",
  "0064", "fil",
  "0464", "fil-PH",
  "000B", "fi",
  "040B", "fi-FI",
  "000C", "fr",
  "080C", "fr-BE",
  "2C0C", "fr-CM",
  "0C0C", "fr-CA",
  "1C0C", "fr-029",
  "300C", "fr-CI",
  "040C", "fr-FR",
  "3C0C", "fr-HT",
  "140C", "fr-LU",
  "340C", "fr-ML",
  "180C", "fr-MC",
  "380C", "fr-MA",
  "200C", "fr-RE",
  "280C", "fr-SN",
  "100C", "fr-CH",
  "240C", "fr-CD",
  "0067", "ff",
  "7C67", "ff-Latn",
  "0467", "ff-Latn-NG",
  "0867", "ff-Latn-SN",
  "0056", "gl",
  "0456", "gl-ES",
  "0037", "ka",
  "0437", "ka-GE",
  "0007", "de",
  "0C07", "de-AT",
  "0407", "de-DE",
  "1407", "de-LI",
  "1007", "de-LU",
  "0807", "de-CH",
  "0008", "el",
  "0408", "el-GR",
  "0074", "gn",
  "0474", "gn-PY",
  "0047", "gu",
  "0447", "gu-IN",
  "0068", "ha",
  "7C68", "ha-Latn",
  "0468", "ha-Latn-NG",
  "0075", "haw",
  "0475", "haw-US",
  "000D", "he",
  "040D", "he-IL",
  "0039", "hi",
  "0439", "hi-IN",
  "000E", "hu",
  "040E", "hu-HU",
  "0069", "ibb",
  "0469", "ibb-NG",
  "000F", "is",
  "040F", "is-IS",
  "0070", "ig",
  "0470", "ig-NG",
  "0021", "id",
  "0421", "id-ID",
  "005D", "iu",
  "7C5D", "iu-Latn",
  "085D", "iu-Latn-CA",
  "785D", "iu-Cans",
  "045D", "iu-Cans-CA",
  "003C", "ga",
  "083C", "ga-IE",
  "0034", "xh",
  "0434", "xh-ZA",
  "0035", "zu",
  "0435", "zu-ZA",
  "0010", "it",
  "0410", "it-IT",
  "0810", "it-CH",
  "0011", "ja",
  "0411", "ja-JP",
  "006F", "kl",
  "046F", "kl-GL",
  "004B", "kn",
  "044B", "kn-IN",
  "0071", "kr",
  "0471", "kr-Latn-NG",
  "0060", "ks",
  "0460", "ks-Arab",
  "1000", "ks-Arab-IN",
  "0860", "ks-Deva-IN",
  "003F", "kk",
  "043F", "kk-KZ",
  "0053", "km",
  "0453", "km-KH",
  "0087", "rw",
  "0487", "rw-RW",
  "0041", "sw",
  "0441", "sw-KE",
  "0057", "kok",
  "0457", "kok-IN",
  "0012", "ko",
  "0412", "ko-KR",
  "0040", "ky",
  "0440", "ky-KG",
  "0086", "quc",
  "7C86", "quc-Latn",
  "0486", "quc-Latn-GT",
  "0054", "lo",
  "0454", "lo-LA",
  "0076", "la",
  "0476", "la-VA",
  "0026", "lv",
  "0426", "lv-LV",
  "0027", "lt",
  "0427", "lt-LT",
  "7C2E", "dsb",
  "082E", "dsb-DE",
  "006E", "lb",
  "046E", "lb-LU",
  "002F", "mk",
  "042F", "mk-MK",
  "003E", "ms",
  "083E", "ms-BN",
  "043E", "ms-MY",
  "004C", "ml",
  "044C", "ml-IN",
  "003A", "mt",
  "043A", "mt-MT",
  "0058", "mni",
  "0458", "mni-IN",
  "0081", "mi",
  "0481", "mi-NZ",
  "007A", "arn",
  "047A", "arn-CL",
  "004E", "mr",
  "044E", "mr-IN",
  "007C", "moh",
  "047C", "moh-CA",
  "0050", "mn",
  "7850", "mn-Cyrl",
  "0450", "mn-MN",
  "7C50", "mn-Mong",
  "0850", "mn-Mong-CN",
  "0C50", "mn-Mong-MN",
  "0061", "ne",
  "0861", "ne-IN",
  "0461", "ne-NP",
  "003B", "se",
  "0014", "no",
  "7C14", "nb",
  "0414", "nb-NO",
  "7814", "nn",
  "0814", "nn-NO",
  "0082", "oc",
  "0482", "oc-FR",
  "0048", "or",
  "0448", "or-IN",
  "0072", "om",
  "0472", "om-ET",
  "0079", "pap",
  "0479", "pap-029",
  "0063", "ps",
  "0463", "ps-AF",
  "0029", "fa",
  "008C", "fa",
  "048C", "fa-AF",
  "0429", "fa-IR",
  "0015", "pl",
  "0415", "pl-PL",
  "0016", "pt",
  "0416", "pt-BR",
  "0816", "pt-PT",
  "05FE", "qps-ploca",
  "09FF", "qps-plocm",
  "0901", "qps-Latn-x-sh",
  "0501", "qps-ploc",
  "0046", "pa",
  "7C46", "pa-Arab",
  "0446", "pa-IN",
  "0846", "pa-Arab-PK",
  "006B", "quz",
  "046B", "quz-BO",
  "086B", "quz-EC",
  "0C6B", "quz-PE",
  "0018", "ro",
  "0818", "ro-MD",
  "0418", "ro-RO",
  "0017", "rm",
  "0417", "rm-CH",
  "0019", "ru",
  "0819", "ru-MD",
  "0419", "ru-RU",
  "0085", "sah",
  "0485", "sah-RU",
  "703B", "smn",
  "7C3B", "smj",
  "743B", "sms",
  "783B", "sma",
  "243B", "smn-FI",
  "103B", "smj-NO",
  "143B", "smj-SE",
  "0C3B", "se-FI",
  "043B", "se-NO",
  "083B", "se-SE",
  "203B", "sms-FI",
  "183B", "sma-NO",
  "1C3B", "sma-SE",
  "004F", "sa",
  "044F", "sa-IN",
  "0091", "gd",
  "0491", "gd-GB",
  "7C1A", "sr",
  "6C1A", "sr-Cyrl",
  "1C1A", "sr-Cyrl-BA",
  "301A", "sr-Cyrl-ME",
  "0C1A", "sr-Cyrl-CS",
  "281A", "sr-Cyrl-RS",
  "701A", "sr-Latn",
  "181A", "sr-Latn-BA",
  "2C1A", "sr-Latn-ME",
  "081A", "sr-Latn-CS",
  "241A", "sr-Latn-RS",
  "0030", "st",
  "0430", "st-ZA",
  "006C", "nso",
  "046C", "nso-ZA",
  "0032", "tn",
  "0832", "tn-BW",
  "0432", "tn-ZA",
  "0059", "sd",
  "7C59", "sd-Arab",
  "0459", "sd-Deva-IN",
  "0859", "sd-Arab-PK",
  "005B", "si",
  "045B", "si-LK",
  "001B", "sk",
  "041B", "sk-SK",
  "0024", "sl",
  "0424", "sl-SI",
  "0077", "so",
  "0477", "so-SO",
  "000A", "es",
  "2C0A", "es-AR",
  "400A", "es-BO",
  "340A", "es-CL",
  "240A", "es-CO",
  "140A", "es-CR",
  "5C0A", "es-CU",
  "1C0A", "es-DO",
  "300A", "es-EC",
  "440A", "es-SV",
  "100A", "es-GT",
  "480A", "es-HN",
  "580A", "es-419",
  "080A", "es-MX",
  "4C0A", "es-NI",
  "180A", "es-PA",
  "3C0A", "es-PY",
  "280A", "es-PE",
  "500A", "es-PR",
  "0C0A", "es-ES",
  "040A", "es-ES_tradnl",
  "540A", "es-US",
  "380A", "es-UY",
  "200A", "es-VE",
  "001D", "sv",
  "081D", "sv-FI",
  "041D", "sv-SE",
  "0084", "gsw",
  "005A", "syr",
  "045A", "syr-SY",
  "0028", "tg",
  "7C28", "tg-Cyrl",
  "0428", "tg-Cyrl-TJ",
  "0049", "ta",
  "0449", "ta-IN",
  "0849", "ta-LK",
  "0044", "tt",
  "0444", "tt-RU",
  "004A", "te",
  "044A", "te-IN",
  "001E", "th",
  "041E", "th-TH",
  "0051", "bo",
  "0451", "bo-CN",
  "0073", "ti",
  "0873", "ti-ER",
  "0473", "ti-ET",
  "001F", "tr",
  "041F", "tr-TR",
  "0042", "tk",
  "0442", "tk-TM",
  "0022", "uk",
  "0422", "uk-UA",
  "002E", "hsb",
  "042E", "hsb-DE",
  "0020", "ur",
  "0820", "ur-IN",
  "0420", "ur-PK",
  "0080", "ug",
  "0480", "ug-CN",
  "0043", "uz",
  "7843", "uz-Cyrl",
  "0843", "uz-Cyrl-UZ",
  "7C43", "uz-Latn",
  "0443", "uz-Latn-UZ",
  "0803", "ca-ES-valencia",
  "0033", "ve",
  "0433", "ve-ZA",
  "002A", "vi",
  "042A", "vi-VN",
  "0052", "cy",
  "0452", "cy-GB",
  "0062", "fy",
  "0462", "fy-NL",
  "0088", "wo",
  "0488", "wo-SN",
  "0031", "ts",
  "0431", "ts-ZA",
  "0078", "ii",
  "0478", "ii-CN",
  "003D", "yi",
  "043D", "yi-001",
  "006A", "yo",
  "046A", "yo-NG"
)

languageHexToName := Map(
  "0036", "Afrikaans",  ; af
  "0436", "Afrikaans (South Africa)",  ; af-ZA
  "001C", "Albanian",  ; sq
  "041C", "Albanian (Albania)",  ; sq-AL
  "0484", "Alsatian (France)",  ; gsw-FR
  "005E", "Amharic",  ; am
  "045E", "Amharic (Ethiopia)",  ; am-ET
  "0001", "Arabic",  ; ar
  "1401", "Arabic (Algeria)",  ; ar-DZ
  "3C01", "Arabic (Bahrain)",  ; ar-BH
  "0C01", "Arabic (Egypt)",  ; ar-EG
  "0801", "Arabic (Iraq)",  ; ar-IQ
  "2C01", "Arabic (Jordan)",  ; ar-JO
  "3401", "Arabic (Kuwait)",  ; ar-KW
  "3001", "Arabic (Lebanon)",  ; ar-LB
  "1001", "Arabic (Libya)",  ; ar-LY
  "1801", "Arabic (Morocco)",  ; ar-MA
  "2001", "Arabic (Oman)",  ; ar-OM
  "4001", "Arabic (Qatar)",  ; ar-QA
  "0401", "Arabic (Saudi Arabia)",  ; ar-SA
  "2801", "Arabic (Syria)",  ; ar-SY
  "1C01", "Arabic (Tunisia)",  ; ar-TN
  "3801", "Arabic (United Arab Emirates)",  ; ar-AE
  "2401", "Arabic (Yemen)",  ; ar-YE
  "002B", "Armenian",  ; hy
  "042B", "Armenian (Armenia)",  ; hy-AM
  "004D", "Assamese",  ; as
  "044D", "Assamese (India)",  ; as-IN
  "002C", "Azerbaijani",  ; az
  "742C", "Azerbaijani (Cyrillic)",  ; az-Cyrl
  "082C", "Azerbaijani (Cyrillic, Azerbaijan)",  ; az-Cyrl-AZ
  "782C", "Azerbaijani (Latin)",  ; az-Latn
  "042C", "Azerbaijani (Latin, Azerbaijan)",  ; az-Latn-AZ
  "0045", "Bangla",  ; bn
  "0845", "Bangla (Bangladesh)",  ; bn-BD
  "006D", "Bashkir",  ; ba
  "046D", "Bashkir (Russia)",  ; ba-RU
  "002D", "Basque",  ; eu
  "042D", "Basque (Basque)",  ; eu-ES
  "0023", "Belarusian",  ; be
  "0423", "Belarusian (Belarus)",  ; be-BY
  "0445", "Bengali (India)",  ; bn-IN
  "781A", "Bosnian",  ; bs
  "641A", "Bosnian (Cyrillic)",  ; bs-Cyrl
  "201A", "Bosnian (Cyrillic, Bosnia and Herzegovina)",  ; bs-Cyrl-BA
  "681A", "Bosnian (Latin)",  ; bs-Latn
  "141A", "Bosnian (Latin, Bosnia & Herzegovina)",  ; bs-Latn-BA
  "007E", "Breton",  ; br
  "047E", "Breton (France)",  ; br-FR
  "0002", "Bulgarian",  ; bg
  "0402", "Bulgarian (Bulgaria)",  ; bg-BG
  "0055", "Burmese",  ; my
  "0455", "Burmese (Myanmar)",  ; my-MM
  "0003", "Catalan",  ; ca
  "0403", "Catalan (Catalan)",  ; ca-ES
  "005F", "Central Atlas Tamazight",  ; tzm
  "045F", "Central Atlas Tamazight (Arabic, Morocco)",  ; tzm-Arab-MA
  "7C5F", "Central Atlas Tamazight (Latin)",  ; tzm-Latn
  "085F", "Central Atlas Tamazight (Latin, Algeria)",  ; tzm-Latn-DZ
  "785F", "Central Atlas Tamazight (Tifinagh)",  ; tzm-Tfng
  "105F", "Central Atlas Tamazight (Tifinagh, Morocco)",  ; tzm-Tfng-MA
  "0092", "Central Kurdish",  ; ku
  "7C92", "Central Kurdish",  ; ku-Arab
  "0492", "Central Kurdish (Iraq)",  ; ku-Arab-IQ
  "005C", "Cherokee",  ; chr
  "7C5C", "Cherokee",  ; chr-Cher
  "045C", "Cherokee (Cherokee, United States)",  ; chr-Cher-US
  "7804", "Chinese",  ; zh
  "0004", "Chinese (Simplified)",  ; zh-Hans
  "0804", "Chinese (Simplified, China)",  ; zh-CN
  "1004", "Chinese (Simplified, Singapore)",  ; zh-SG
  "7C04", "Chinese (Traditional)",  ; zh-Hant
  "0C04", "Chinese (Traditional, Hong Kong SAR)",  ; zh-HK
  "1404", "Chinese (Traditional, Macao SAR)",  ; zh-MO
  "0404", "Chinese (Traditional, Taiwan)",  ; zh-TW
  "0083", "Corsican",  ; co
  "0483", "Corsican (France)",  ; co-FR
  "001A", "Croatian",  ; hr
  "101A", "Croatian (Bosnia & Herzegovina)",  ; hr-BA
  "041A", "Croatian (Croatia)",  ; hr-HR
  "0005", "Czech",  ; cs
  "0405", "Czech (Czechia)",  ; cs-CZ
  "0006", "Danish",  ; da
  "0406", "Danish (Denmark)",  ; da-DK
  "0065", "Divehi",  ; dv
  "0465", "Divehi (Maldives)",  ; dv-MV
  "0013", "Dutch",  ; nl
  "0813", "Dutch (Belgium)",  ; nl-BE
  "0413", "Dutch (Netherlands)",  ; nl-NL
  "0C51", "Dzongkha (Bhutan)",  ; dz-BT
  "0066", "Edo",  ; bin
  "0466", "Edo (Nigeria)",  ; bin-NG
  "0009", "English",  ; en
  "0C09", "English (Australia)",  ; en-AU
  "2809", "English (Belize)",  ; en-BZ
  "1009", "English (Canada)",  ; en-CA
  "2409", "English (Caribbean)",  ; en-029
  "3C09", "English (Hong Kong SAR)",  ; en-HK
  "4009", "English (India)",  ; en-IN
  "3809", "English (Indonesia)",  ; en-ID
  "1809", "English (Ireland)",  ; en-IE
  "2009", "English (Jamaica)",  ; en-JM
  "4409", "English (Malaysia)",  ; en-MY
  "1409", "English (New Zealand)",  ; en-NZ
  "3409", "English (Philippines)",  ; en-PH
  "4809", "English (Singapore)",  ; en-SG
  "1C09", "English (South Africa)",  ; en-ZA
  "2C09", "English (Trinidad & Tobago)",  ; en-TT
  "4C09", "English (United Arab Emirates)",  ; en-AE
  "0809", "English (United Kingdom)",  ; en-GB
  "0409", "English (United States)",  ; en-US
  "3009", "English (Zimbabwe)",  ; en-ZW
  "0025", "Estonian",  ; et
  "0425", "Estonian (Estonia)",  ; et-EE
  "0038", "Faroese",  ; fo
  "0438", "Faroese (Faroe Islands)",  ; fo-FO
  "0064", "Filipino",  ; fil
  "0464", "Filipino (Philippines)",  ; fil-PH
  "000B", "Finnish",  ; fi
  "040B", "Finnish (Finland)",  ; fi-FI
  "000C", "French",  ; fr
  "080C", "French (Belgium)",  ; fr-BE
  "2C0C", "French (Cameroon)",  ; fr-CM
  "0C0C", "French (Canada)",  ; fr-CA
  "1C0C", "French (Caribbean)",  ; fr-029
  "300C", "French (Côte d’Ivoire)",  ; fr-CI
  "040C", "French (France)",  ; fr-FR
  "3C0C", "French (Haiti)",  ; fr-HT
  "140C", "French (Luxembourg)",  ; fr-LU
  "340C", "French (Mali)",  ; fr-ML
  "180C", "French (Monaco)",  ; fr-MC
  "380C", "French (Morocco)",  ; fr-MA
  "200C", "French (Réunion)",  ; fr-RE
  "280C", "French (Senegal)",  ; fr-SN
  "100C", "French (Switzerland)",  ; fr-CH
  "240C", "French Congo (DRC)",  ; fr-CD
  "0067", "Fulah",  ; ff
  "7C67", "Fulah (Latin)",  ; ff-Latn
  "0467", "Fulah (Latin, Nigeria)",  ; ff-Latn-NG
  "0867", "Fulah (Latin, Senegal)",  ; ff-Latn-SN
  "0056", "Galician",  ; gl
  "0456", "Galician (Galician)",  ; gl-ES
  "0037", "Georgian",  ; ka
  "0437", "Georgian (Georgia)",  ; ka-GE
  "0007", "German",  ; de
  "0C07", "German (Austria)",  ; de-AT
  "0407", "German (Germany)",  ; de-DE
  "1407", "German (Liechtenstein)",  ; de-LI
  "1007", "German (Luxembourg)",  ; de-LU
  "0807", "German (Switzerland)",  ; de-CH
  "0008", "Greek",  ; el
  "0408", "Greek (Greece)",  ; el-GR
  "0074", "Guarani",  ; gn
  "0474", "Guarani (Paraguay)",  ; gn-PY
  "0047", "Gujarati",  ; gu
  "0447", "Gujarati (India)",  ; gu-IN
  "0068", "Hausa",  ; ha
  "7C68", "Hausa (Latin)",  ; ha-Latn
  "0468", "Hausa (Latin, Nigeria)",  ; ha-Latn-NG
  "0075", "Hawaiian",  ; haw
  "0475", "Hawaiian (United States)",  ; haw-US
  "000D", "Hebrew",  ; he
  "040D", "Hebrew (Israel)",  ; he-IL
  "0039", "Hindi",  ; hi
  "0439", "Hindi (India)",  ; hi-IN
  "000E", "Hungarian",  ; hu
  "040E", "Hungarian (Hungary)",  ; hu-HU
  "0069", "Ibibio",  ; ibb
  "0469", "Ibibio (Nigeria)",  ; ibb-NG
  "000F", "Icelandic",  ; is
  "040F", "Icelandic (Iceland)",  ; is-IS
  "0070", "Igbo",  ; ig
  "0470", "Igbo (Nigeria)",  ; ig-NG
  "0021", "Indonesian",  ; id
  "0421", "Indonesian (Indonesia)",  ; id-ID
  "005D", "Inuktitut",  ; iu
  "7C5D", "Inuktitut (Latin)",  ; iu-Latn
  "085D", "Inuktitut (Latin, Canada)",  ; iu-Latn-CA
  "785D", "Inuktitut (Syllabics)",  ; iu-Cans
  "045D", "Inuktitut (Syllabics, Canada)",  ; iu-Cans-CA
  "003C", "Irish",  ; ga
  "083C", "Irish (Ireland)",  ; ga-IE
  "0034", "isiXhosa",  ; xh
  "0434", "isiXhosa (South Africa)",  ; xh-ZA
  "0035", "isiZulu",  ; zu
  "0435", "isiZulu (South Africa)",  ; zu-ZA
  "0010", "Italian",  ; it
  "0410", "Italian (Italy)",  ; it-IT
  "0810", "Italian (Switzerland)",  ; it-CH
  "0011", "Japanese",  ; ja
  "0411", "Japanese (Japan)",  ; ja-JP
  "006F", "Kalaallisut",  ; kl
  "046F", "Kalaallisut (Greenland)",  ; kl-GL
  "004B", "Kannada",  ; kn
  "044B", "Kannada (India)",  ; kn-IN
  "0071", "Kanuri",  ; kr
  "0471", "Kanuri (Latin, Nigeria)",  ; kr-Latn-NG
  "0060", "Kashmiri",  ; ks
  "0460", "Kashmiri (Arabic)",  ; ks-Arab
  "1000", "Kashmiri (Arabic)",  ; ks-Arab-IN
  "0860", "Kashmiri (Devanagari)",  ; ks-Deva-IN
  "003F", "Kazakh",  ; kk
  "043F", "Kazakh (Kazakhstan)",  ; kk-KZ
  "0053", "Khmer",  ; km
  "0453", "Khmer (Cambodia)",  ; km-KH
  "0087", "Kinyarwanda",  ; rw
  "0487", "Kinyarwanda (Rwanda)",  ; rw-RW
  "0041", "Kiswahili",  ; sw
  "0441", "Kiswahili (Kenya)",  ; sw-KE
  "0057", "Konkani",  ; kok
  "0457", "Konkani (India)",  ; kok-IN
  "0012", "Korean",  ; ko
  "0412", "Korean (Korea)",  ; ko-KR
  "0040", "Kyrgyz",  ; ky
  "0440", "Kyrgyz (Kyrgyzstan)",  ; ky-KG
  "0086", "Kʼicheʼ",  ; quc
  "7C86", "Kʼicheʼ (Latin)",  ; quc-Latn
  "0486", "Kʼicheʼ (Latin, Guatemala)",  ; quc-Latn-GT
  "0054", "Lao",  ; lo
  "0454", "Lao (Laos)",  ; lo-LA
  "0076", "Latin",  ; la
  "0476", "Latin (Vatican City)",  ; la-VA
  "0026", "Latvian",  ; lv
  "0426", "Latvian (Latvia)",  ; lv-LV
  "0027", "Lithuanian",  ; lt
  "0427", "Lithuanian (Lithuania)",  ; lt-LT
  "7C2E", "Lower Sorbian",  ; dsb
  "082E", "Lower Sorbian (Germany)",  ; dsb-DE
  "006E", "Luxembourgish",  ; lb
  "046E", "Luxembourgish (Luxembourg)",  ; lb-LU
  "002F", "Macedonian",  ; mk
  "042F", "Macedonian (North Macedonia)",  ; mk-MK
  "003E", "Malay",  ; ms
  "083E", "Malay (Brunei)",  ; ms-BN
  "043E", "Malay (Malaysia)",  ; ms-MY
  "004C", "Malayalam",  ; ml
  "044C", "Malayalam (India)",  ; ml-IN
  "003A", "Maltese",  ; mt
  "043A", "Maltese (Malta)",  ; mt-MT
  "0058", "Manipuri",  ; mni
  "0458", "Manipuri (Bangla, India)",  ; mni-IN
  "0081", "Maori",  ; mi
  "0481", "Maori (New Zealand)",  ; mi-NZ
  "007A", "Mapuche",  ; arn
  "047A", "Mapuche (Chile)",  ; arn-CL
  "004E", "Marathi",  ; mr
  "044E", "Marathi (India)",  ; mr-IN
  "007C", "Mohawk",  ; moh
  "047C", "Mohawk (Canada)",  ; moh-CA
  "0050", "Mongolian",  ; mn
  "7850", "Mongolian",  ; mn-Cyrl
  "0450", "Mongolian (Mongolia)",  ; mn-MN
  "7C50", "Mongolian (Traditional Mongolian)",  ; mn-Mong
  "0850", "Mongolian (Traditional Mongolian, China)",  ; mn-Mong-CN
  "0C50", "Mongolian (Traditional Mongolian, Mongolia)",  ; mn-Mong-MN
  "0061", "Nepali",  ; ne
  "0861", "Nepali (India)",  ; ne-IN
  "0461", "Nepali (Nepal)",  ; ne-NP
  "003B", "Northern Sami",  ; se
  "0014", "Norwegian",  ; no
  "7C14", "Norwegian Bokmål",  ; nb
  "0414", "Norwegian Bokmål (Norway)",  ; nb-NO
  "7814", "Norwegian Nynorsk",  ; nn
  "0814", "Norwegian Nynorsk (Norway)",  ; nn-NO
  "0082", "Occitan",  ; oc
  "0482", "Occitan (France)",  ; oc-FR
  "0048", "Odia",  ; or
  "0448", "Odia (India)",  ; or-IN
  "0072", "Oromo",  ; om
  "0472", "Oromo (Ethiopia)",  ; om-ET
  "0079", "Papiamento",  ; pap
  "0479", "Papiamento (Caribbean)",  ; pap-029
  "0063", "Pashto",  ; ps
  "0463", "Pashto (Afghanistan)",  ; ps-AF
  "0029", "Persian",  ; fa
  "008C", "Persian",  ; fa
  "048C", "Persian (Afghanistan)",  ; fa-AF
  "0429", "Persian (Iran)",  ; fa-IR
  "0015", "Polish",  ; pl
  "0415", "Polish (Poland)",  ; pl-PL
  "0016", "Portuguese",  ; pt
  "0416", "Portuguese (Brazil)",  ; pt-BR
  "0816", "Portuguese (Portugal)",  ; pt-PT
  "05FE", "Pseudo (Pseudo Asia)",  ; qps-ploca
  "09FF", "Pseudo (Pseudo Mirrored)",  ; qps-plocm
  "0901", "Pseudo (Pseudo Selfhost)",  ; qps-Latn-x-sh
  "0501", "Pseudo (Pseudo)",  ; qps-ploc
  "0046", "Punjabi",  ; pa
  "7C46", "Punjabi",  ; pa-Arab
  "0446", "Punjabi (India)",  ; pa-IN
  "0846", "Punjabi (Pakistan)",  ; pa-Arab-PK
  "006B", "Quechua",  ; quz
  "046B", "Quechua (Bolivia)",  ; quz-BO
  "086B", "Quechua (Ecuador)",  ; quz-EC
  "0C6B", "Quechua (Peru)",  ; quz-PE
  "0018", "Romanian",  ; ro
  "0818", "Romanian (Moldova)",  ; ro-MD
  "0418", "Romanian (Romania)",  ; ro-RO
  "0017", "Romansh",  ; rm
  "0417", "Romansh (Switzerland)",  ; rm-CH
  "0019", "Russian",  ; ru
  "0819", "Russian (Moldova)",  ; ru-MD
  "0419", "Russian (Russia)",  ; ru-RU
  "0085", "Sakha",  ; sah
  "0485", "Sakha (Russia)",  ; sah-RU
  "703B", "Sami (Inari)",  ; smn
  "7C3B", "Sami (Lule)",  ; smj
  "743B", "Sami (Skolt)",  ; sms
  "783B", "Sami (Southern)",  ; sma
  "243B", "Sami, Inari (Finland)",  ; smn-FI
  "103B", "Sami, Lule (Norway)",  ; smj-NO
  "143B", "Sami, Lule (Sweden)",  ; smj-SE
  "0C3B", "Sami, Northern (Finland)",  ; se-FI
  "043B", "Sami, Northern (Norway)",  ; se-NO
  "083B", "Sami, Northern (Sweden)",  ; se-SE
  "203B", "Sami, Skolt (Finland)",  ; sms-FI
  "183B", "Sami, Southern (Norway)",  ; sma-NO
  "1C3B", "Sami, Southern (Sweden)",  ; sma-SE
  "004F", "Sanskrit",  ; sa
  "044F", "Sanskrit (India)",  ; sa-IN
  "0091", "Scottish Gaelic",  ; gd
  "0491", "Scottish Gaelic (United Kingdom)",  ; gd-GB
  "7C1A", "Serbian",  ; sr
  "6C1A", "Serbian (Cyrillic)",  ; sr-Cyrl
  "1C1A", "Serbian (Cyrillic, Bosnia and Herzegovina)",  ; sr-Cyrl-BA
  "301A", "Serbian (Cyrillic, Montenegro)",  ; sr-Cyrl-ME
  "0C1A", "Serbian (Cyrillic, Serbia and Montenegro (Former))",  ; sr-Cyrl-CS
  "281A", "Serbian (Cyrillic, Serbia)",  ; sr-Cyrl-RS
  "701A", "Serbian (Latin)",  ; sr-Latn
  "181A", "Serbian (Latin, Bosnia & Herzegovina)",  ; sr-Latn-BA
  "2C1A", "Serbian (Latin, Montenegro)",  ; sr-Latn-ME
  "081A", "Serbian (Latin, Serbia and Montenegro (Former))",  ; sr-Latn-CS
  "241A", "Serbian (Latin, Serbia)",  ; sr-Latn-RS
  "0030", "Sesotho",  ; st
  "0430", "Sesotho (South Africa)",  ; st-ZA
  "006C", "Sesotho sa Leboa",  ; nso
  "046C", "Sesotho sa Leboa (South Africa)",  ; nso-ZA
  "0032", "Setswana",  ; tn
  "0832", "Setswana (Botswana)",  ; tn-BW
  "0432", "Setswana (South Africa)",  ; tn-ZA
  "0059", "Sindhi",  ; sd
  "7C59", "Sindhi",  ; sd-Arab
  "0459", "Sindhi (Devanagari, India)",  ; sd-Deva-IN
  "0859", "Sindhi (Pakistan)",  ; sd-Arab-PK
  "005B", "Sinhala",  ; si
  "045B", "Sinhala (Sri Lanka)",  ; si-LK
  "001B", "Slovak",  ; sk
  "041B", "Slovak (Slovakia)",  ; sk-SK
  "0024", "Slovenian",  ; sl
  "0424", "Slovenian (Slovenia)",  ; sl-SI
  "0077", "Somali",  ; so
  "0477", "Somali (Somalia)",  ; so-SO
  "000A", "Spanish",  ; es
  "2C0A", "Spanish (Argentina)",  ; es-AR
  "400A", "Spanish (Bolivia)",  ; es-BO
  "340A", "Spanish (Chile)",  ; es-CL
  "240A", "Spanish (Colombia)",  ; es-CO
  "140A", "Spanish (Costa Rica)",  ; es-CR
  "5C0A", "Spanish (Cuba)",  ; es-CU
  "1C0A", "Spanish (Dominican Republic)",  ; es-DO
  "300A", "Spanish (Ecuador)",  ; es-EC
  "440A", "Spanish (El Salvador)",  ; es-SV
  "100A", "Spanish (Guatemala)",  ; es-GT
  "480A", "Spanish (Honduras)",  ; es-HN
  "580A", "Spanish (Latin America)",  ; es-419
  "080A", "Spanish (Mexico)",  ; es-MX
  "4C0A", "Spanish (Nicaragua)",  ; es-NI
  "180A", "Spanish (Panama)",  ; es-PA
  "3C0A", "Spanish (Paraguay)",  ; es-PY
  "280A", "Spanish (Peru)",  ; es-PE
  "500A", "Spanish (Puerto Rico)",  ; es-PR
  "0C0A", "Spanish (Spain, International Sort)",  ; es-ES
  "040A", "Spanish (Spain, Traditional Sort)",  ; es-ES_tradnl
  "540A", "Spanish (United States)",  ; es-US
  "380A", "Spanish (Uruguay)",  ; es-UY
  "200A", "Spanish (Venezuela)",  ; es-VE
  "001D", "Swedish",  ; sv
  "081D", "Swedish (Finland)",  ; sv-FI
  "041D", "Swedish (Sweden)",  ; sv-SE
  "0084", "Swiss German",  ; gsw
  "005A", "Syriac",  ; syr
  "045A", "Syriac (Syria)",  ; syr-SY
  "0028", "Tajik",  ; tg
  "7C28", "Tajik (Cyrillic)",  ; tg-Cyrl
  "0428", "Tajik (Cyrillic, Tajikistan)",  ; tg-Cyrl-TJ
  "0049", "Tamil",  ; ta
  "0449", "Tamil (India)",  ; ta-IN
  "0849", "Tamil (Sri Lanka)",  ; ta-LK
  "0044", "Tatar",  ; tt
  "0444", "Tatar (Russia)",  ; tt-RU
  "004A", "Telugu",  ; te
  "044A", "Telugu (India)",  ; te-IN
  "001E", "Thai",  ; th
  "041E", "Thai (Thailand)",  ; th-TH
  "0051", "Tibetan",  ; bo
  "0451", "Tibetan (China)",  ; bo-CN
  "0073", "Tigrinya",  ; ti
  "0873", "Tigrinya (Eritrea)",  ; ti-ER
  "0473", "Tigrinya (Ethiopia)",  ; ti-ET
  "001F", "Turkish",  ; tr
  "041F", "Turkish (Turkey)",  ; tr-TR
  "0042", "Turkmen",  ; tk
  "0442", "Turkmen (Turkmenistan)",  ; tk-TM
  "0022", "Ukrainian",  ; uk
  "0422", "Ukrainian (Ukraine)",  ; uk-UA
  "002E", "Upper Sorbian",  ; hsb
  "042E", "Upper Sorbian (Germany)",  ; hsb-DE
  "0020", "Urdu",  ; ur
  "0820", "Urdu (India)",  ; ur-IN
  "0420", "Urdu (Pakistan)",  ; ur-PK
  "0080", "Uyghur",  ; ug
  "0480", "Uyghur (China)",  ; ug-CN
  "0043", "Uzbek",  ; uz
  "7843", "Uzbek (Cyrillic)",  ; uz-Cyrl
  "0843", "Uzbek (Cyrillic, Uzbekistan)",  ; uz-Cyrl-UZ
  "7C43", "Uzbek (Latin)",  ; uz-Latn
  "0443", "Uzbek (Latin, Uzbekistan)",  ; uz-Latn-UZ
  "0803", "Valencian (Spain)",  ; ca-ES-valencia
  "0033", "Venda",  ; ve
  "0433", "Venda (South Africa)",  ; ve-ZA
  "002A", "Vietnamese",  ; vi
  "042A", "Vietnamese (Vietnam)",  ; vi-VN
  "0052", "Welsh",  ; cy
  "0452", "Welsh (United Kingdom)",  ; cy-GB
  "0062", "Western Frisian",  ; fy
  "0462", "Western Frisian (Netherlands)",  ; fy-NL
  "0088", "Wolof",  ; wo
  "0488", "Wolof (Senegal)",  ; wo-SN
  "0031", "Xitsonga",  ; ts
  "0431", "Xitsonga (South Africa)",  ; ts-ZA
  "0078", "Yi",  ; ii
  "0478", "Yi (China)",  ; ii-CN
  "003D", "Yiddish",  ; yi
  "043D", "Yiddish (World)",  ; yi-001
  "006A", "Yoruba",  ; yo
  "046A", "Yoruba (Nigeria)"  ; yo-NG
)

languageNameToCode := Map(
  "Afrikaans", "af",
  "Afrikaans (South Africa)", "af-ZA",
  "Albanian", "sq",
  "Albanian (Albania)", "sq-AL",
  "Alsatian (France)", "gsw-FR",
  "Amharic", "am",
  "Amharic (Ethiopia)", "am-ET",
  "Arabic", "ar",
  "Arabic (Algeria)", "ar-DZ",
  "Arabic (Bahrain)", "ar-BH",
  "Arabic (Egypt)", "ar-EG",
  "Arabic (Iraq)", "ar-IQ",
  "Arabic (Jordan)", "ar-JO",
  "Arabic (Kuwait)", "ar-KW",
  "Arabic (Lebanon)", "ar-LB",
  "Arabic (Libya)", "ar-LY",
  "Arabic (Morocco)", "ar-MA",
  "Arabic (Oman)", "ar-OM",
  "Arabic (Qatar)", "ar-QA",
  "Arabic (Saudi Arabia)", "ar-SA",
  "Arabic (Syria)", "ar-SY",
  "Arabic (Tunisia)", "ar-TN",
  "Arabic (United Arab Emirates)", "ar-AE",
  "Arabic (Yemen)", "ar-YE",
  "Armenian", "hy",
  "Armenian (Armenia)", "hy-AM",
  "Assamese", "as",
  "Assamese (India)", "as-IN",
  "Azerbaijani", "az",
  "Azerbaijani (Cyrillic)", "az-Cyrl",
  "Azerbaijani (Cyrillic, Azerbaijan)", "az-Cyrl-AZ",
  "Azerbaijani (Latin)", "az-Latn",
  "Azerbaijani (Latin, Azerbaijan)", "az-Latn-AZ",
  "Bangla", "bn",
  "Bangla (Bangladesh)", "bn-BD",
  "Bashkir", "ba",
  "Bashkir (Russia)", "ba-RU",
  "Basque", "eu",
  "Basque (Basque)", "eu-ES",
  "Belarusian", "be",
  "Belarusian (Belarus)", "be-BY",
  "Bengali (India)", "bn-IN",
  "Bosnian", "bs",
  "Bosnian (Cyrillic)", "bs-Cyrl",
  "Bosnian (Cyrillic, Bosnia and Herzegovina)", "bs-Cyrl-BA",
  "Bosnian (Latin)", "bs-Latn",
  "Bosnian (Latin, Bosnia & Herzegovina)", "bs-Latn-BA",
  "Breton", "br",
  "Breton (France)", "br-FR",
  "Bulgarian", "bg",
  "Bulgarian (Bulgaria)", "bg-BG",
  "Burmese", "my",
  "Burmese (Myanmar)", "my-MM",
  "Catalan", "ca",
  "Catalan (Catalan)", "ca-ES",
  "Central Atlas Tamazight", "tzm",
  "Central Atlas Tamazight (Arabic, Morocco)", "tzm-Arab-MA",
  "Central Atlas Tamazight (Latin)", "tzm-Latn",
  "Central Atlas Tamazight (Latin Algeria)", "tzm-Latn-DZ",
  "Central Atlas Tamazight (Tifinagh)", "tzm-Tfng",
  "Central Atlas Tamazight (Tifinagh, Morocco)", "tzm-Tfng-MA",
  "Central Kurdish", "ku",
  "Central Kurdish", "ku-Arab",
  "Central Kurdish (Iraq)", "ku-Arab-IQ",
  "Cherokee", "chr",
  "Cherokee", "chr-Cher",
  "Cherokee (Cherokee, United States)", "chr-Cher-US",
  "Chinese", "zh",
  "Chinese (Simplified)", "zh-Hans",
  "Chinese (Simplified, China)", "zh-CN",
  "Chinese (Simplified, Singapore)", "zh-SG",
  "Chinese (Traditional)", "zh-Hant",
  "Chinese (Traditional, Hong Kong SAR)", "zh-HK",
  "Chinese (Traditional, Macao SAR)", "zh-MO",
  "Chinese (Traditional, Taiwan)", "zh-TW",
  "Corsican", "co",
  "Corsican (France)", "co-FR",
  "Croatian", "hr",
  "Croatian (Bosnia & Herzegovina)", "hr-BA",
  "Croatian (Croatia)", "hr-HR",
  "Czech", "cs",
  "Czech (Czechia)", "cs-CZ",
  "Danish", "da",
  "Danish (Denmark)", "da-DK",
  "Divehi", "dv",
  "Divehi (Maldives)", "dv-MV",
  "Dutch", "nl",
  "Dutch (Belgium)", "nl-BE",
  "Dutch (Netherlands)", "nl-NL",
  "Dzongkha (Bhutan)", "dz-BT",
  "Edo", "bin",
  "Edo (Nigeria)", "bin-NG",
  "English", "en",
  "English (Australia)", "en-AU",
  "English (Belize)", "en-BZ",
  "English (Canada)", "en-CA",
  "English (Caribbean)", "en-029",
  "English (Hong Kong SAR)", "en-HK",
  "English (India)", "en-IN",
  "English (Indonesia)", "en-ID",
  "English (Ireland)", "en-IE",
  "English (Jamaica)", "en-JM",
  "English (Malaysia)", "en-MY",
  "English (New Zealand)", "en-NZ",
  "English (Philippines)", "en-PH",
  "English (Singapore)", "en-SG",
  "English (South Africa)", "en-ZA",
  "English (Trinidad & Tobago)", "en-TT",
  "English (United Arab Emirates)", "en-AE",
  "English (United Kingdom)", "en-GB",
  "English (United States)", "en-US",
  "English (Zimbabwe)", "en-ZW",
  "Estonian", "et",
  "Estonian (Estonia)", "et-EE",
  "Faroese", "fo",
  "Faroese (Faroe Islands)", "fo-FO",
  "Filipino", "fil",
  "Filipino (Philippines)", "fil-PH",
  "Finnish", "fi",
  "Finnish (Finland)", "fi-FI",
  "French", "fr",
  "French (Belgium)", "fr-BE",
  "French (Cameroon)", "fr-CM",
  "French (Canada)", "fr-CA",
  "French (Caribbean)", "fr-029",
  "French (Côte d’Ivoire)", "fr-CI",
  "French (France)", "fr-FR",
  "French (Haiti)", "fr-HT",
  "French (Luxembourg)", "fr-LU",
  "French (Mali)", "fr-ML",
  "French (Monaco)", "fr-MC",
  "French (Morocco)", "fr-MA",
  "French (Réunion)", "fr-RE",
  "French (Senegal)", "fr-SN",
  "French (Switzerland)", "fr-CH",
  "French Congo (DRC)", "fr-CD",
  "Fulah", "ff",
  "Fulah (Latin)", "ff-Latn",
  "Fulah (Latin, Nigeria)", "ff-Latn-NG",
  "Fulah (Latin, Senegal)", "ff-Latn-SN",
  "Galician", "gl",
  "Galician (Galician)", "gl-ES",
  "Georgian", "ka",
  "Georgian (Georgia)", "ka-GE",
  "German", "de",
  "German (Austria)", "de-AT",
  "German (Germany)", "de-DE",
  "German (Liechtenstein)", "de-LI",
  "German (Luxembourg)", "de-LU",
  "German (Switzerland)", "de-CH",
  "Greek", "el",
  "Greek (Greece)", "el-GR",
  "Guarani", "gn",
  "Guarani (Paraguay)", "gn-PY",
  "Gujarati", "gu",
  "Gujarati (India)", "gu-IN",
  "Hausa", "ha",
  "Hausa (Latin)", "ha-Latn",
  "Hausa (Latin, Nigeria)", "ha-Latn-NG",
  "Hawaiian", "haw",
  "Hawaiian (United States)", "haw-US",
  "Hebrew", "he",
  "Hebrew (Israel)", "he-IL",
  "Hindi", "hi",
  "Hindi (India)", "hi-IN",
  "Hungarian", "hu",
  "Hungarian (Hungary)", "hu-HU",
  "Ibibio", "ibb",
  "Ibibio (Nigeria)", "ibb-NG",
  "Icelandic", "is",
  "Icelandic (Iceland)", "is-IS",
  "Igbo", "ig",
  "Igbo (Nigeria)", "ig-NG",
  "Indonesian", "id",
  "Indonesian (Indonesia)", "id-ID",
  "Inuktitut", "iu",
  "Inuktitut (Latin)", "iu-Latn",
  "Inuktitut (Latin, Canada)", "iu-Latn-CA",
  "Inuktitut (Syllabics)", "iu-Cans",
  "Inuktitut (Syllabics, Canada)", "iu-Cans-CA",
  "Irish", "ga",
  "Irish (Ireland)", "ga-IE",
  "isiXhosa", "xh",
  "isiXhosa (South Africa)", "xh-ZA",
  "isiZulu", "zu",
  "isiZulu (South Africa)", "zu-ZA",
  "Italian", "it",
  "Italian (Italy)", "it-IT",
  "Italian (Switzerland)", "it-CH",
  "Japanese", "ja",
  "Japanese (Japan)", "ja-JP",
  "Kalaallisut", "kl",
  "Kalaallisut (Greenland)", "kl-GL",
  "Kannada", "kn",
  "Kannada (India)", "kn-IN",
  "Kanuri", "kr",
  "Kanuri (Latin, Nigeria)", "kr-Latn-NG",
  "Kashmiri", "ks",
  "Kashmiri (Arabic)", "ks-Arab",
  "Kashmiri (Arabic)", "ks-Arab-IN",
  "Kashmiri (Devanagari)", "ks-Deva-IN",
  "Kazakh", "kk",
  "Kazakh (Kazakhstan)", "kk-KZ",
  "Khmer", "km",
  "Khmer (Cambodia)", "km-KH",
  "Kinyarwanda", "rw",
  "Kinyarwanda (Rwanda)", "rw-RW",
  "Kiswahili", "sw",
  "Kiswahili (Kenya)", "sw-KE",
  "Konkani", "kok",
  "Konkani (India)", "kok-IN",
  "Korean", "ko",
  "Korean (Korea)", "ko-KR",
  "Kyrgyz", "ky",
  "Kyrgyz (Kyrgyzstan)", "ky-KG",
  "K'iche", "quc",
  "K'iche (Latin)", "quc-Latn",
  "K'iche (Latin, Guatemala)", "quc-Latn-GT",
  "Lao", "lo",
  "Lao (Laos)", "lo-LA",
  "Latin", "la",
  "Latin (Vatican City)", "la-VA",
  "Latvian", "lv",
  "Latvian (Latvia)", "lv-LV",
  "Lithuanian", "lt",
  "Lithuanian (Lithuania)", "lt-LT",
  "Lower Sorbian", "dsb",
  "Lower Sorbian (Germany)", "dsb-DE",
  "Luxembourgish", "lb",
  "Luxembourgish (Luxembourg)", "lb-LU",
  "Macedonian", "mk",
  "Macedonian (North Macedonia)", "mk-MK",
  "Malay", "ms",
  "Malay (Brunei)", "ms-BN",
  "Malay (Malaysia)", "ms-MY",
  "Malayalam", "ml",
  "Malayalam (India)", "ml-IN",
  "Maltese", "mt",
  "Maltese (Malta)", "mt-MT",
  "Manipuri", "mni",
  "Manipuri (Bangla, India)", "mni-IN",
  "Maori", "mi",
  "Maori (New Zealand)", "mi-NZ",
  "Mapuche", "arn",
  "Mapuche (Chile)", "arn-CL",
  "Marathi", "mr",
  "Marathi (India)", "mr-IN",
  "Mohawk", "moh",
  "Mohawk (Canada)", "moh-CA",
  "Mongolian", "mn",
  "Mongolian", "mn-Cyrl",
  "Mongolian (Mongolia)", "mn-MN",
  "Mongolian (Traditional Mongolian)", "mn-Mong",
  "Mongolian (Traditional Mongolian, China)", "mn-Mong-CN",
  "Mongolian (Traditional Mongolian, Mongolia)", "mn-Mong-MN",
  "Nepali", "ne",
  "Nepali (India)", "ne-IN",
  "Nepali (Nepal)", "ne-NP",
  "Northern Sami", "se",
  "Norwegian", "no",
  "Norwegian Bokm�l", "nb",
  "Norwegian Bokm�l (Norway)", "nb-NO",
  "Norwegian Nynorsk", "nn",
  "Norwegian Nynorsk (Norway)", "nn-NO",
  "Occitan", "oc",
  "Occitan (France)", "oc-FR",
  "Odia", "or",
  "Odia (India)", "or-IN",
  "Oromo", "om",
  "Oromo (Ethiopia)", "om-ET",
  "Papiamento", "pap",
  "Papiamento (Caribbean)", "pap-029",
  "Pashto", "ps",
  "Pashto (Afghanistan)", "ps-AF",
  "Persian", "fa",
  "Persian", "fa",
  "Persian (Afghanistan)", "fa-AF",
  "Persian (Iran)", "fa-IR",
  "Polish", "pl",
  "Polish (Poland)", "pl-PL",
  "Portuguese", "pt",
  "Portuguese (Brazil)", "pt-BR",
  "Portuguese (Portugal)", "pt-PT",
  "Pseudo (Pseudo Asia)", "qps-ploca",
  "Pseudo (Pseudo Mirrored)", "qps-plocm",
  "Pseudo (Pseudo Selfhost)", "qps-Latn-x-sh",
  "Pseudo (Pseudo)", "qps-ploc",
  "Punjabi", "pa",
  "Punjabi", "pa-Arab",
  "Punjabi (India)", "pa-IN",
  "Punjabi (Pakistan)", "pa-Arab-PK",
  "Quechua", "quz",
  "Quechua (Bolivia)", "quz-BO",
  "Quechua (Ecuador)", "quz-EC",
  "Quechua (Peru)", "quz-PE",
  "Romanian", "ro",
  "Romanian (Moldova)", "ro-MD",
  "Romanian (Romania)", "ro-RO",
  "Romansh", "rm",
  "Romansh (Switzerland)", "rm-CH",
  "Russian", "ru",
  "Russian (Moldova)", "ru-MD",
  "Russian (Russia)", "ru-RU",
  "Sakha", "sah",
  "Sakha (Russia)", "sah-RU",
  "Sami (Inari)", "smn",
  "Sami (Lule)", "smj",
  "Sami (Skolt)", "sms",
  "Sami (Southern)", "sma",
  "Sami, Inari (Finland)", "smn-FI",
  "Sami, Lule (Norway)", "smj-NO",
  "Sami, Lule (Sweden)", "smj-SE",
  "Sami, Northern (Finland)", "se-FI",
  "Sami, Northern (Norway)", "se-NO",
  "Sami, Northern (Sweden)", "se-SE",
  "Sami, Skolt (Finland)", "sms-FI",
  "Sami, Southern (Norway)", "sma-NO",
  "Sami, Southern (Sweden)", "sma-SE",
  "Sanskrit", "sa",
  "Sanskrit (India)", "sa-IN",
  "Scottish Gaelic", "gd",
  "Scottish Gaelic (United Kingdom)", "gd-GB",
  "Serbian", "sr",
  "Serbian (Cyrillic)", "sr-Cyrl",
  "Serbian (Cyrillic, Bosnia and Herzegovina)", "sr-Cyrl-BA",
  "Serbian (Cyrillic, Montenegro)", "sr-Cyrl-ME",
  "Serbian (Cyrillic, Serbia and Montenegro (Former))", "sr-Cyrl-CS",
  "Serbian (Cyrillic, Serbia)", "sr-Cyrl-RS",
  "Serbian (Latin)", "sr-Latn",
  "Serbian (Latin, Bosnia & Herzegovina)", "sr-Latn-BA",
  "Serbian (Latin, Montenegro)", "sr-Latn-ME",
  "Serbian (Latin, Serbia and Montenegro (Former))", "sr-Latn-CS",
  "Serbian (Latin, Serbia)", "sr-Latn-RS",
  "Sesotho", "st",
  "Sesotho (South Africa)", "st-ZA",
  "Sesotho sa Leboa", "nso",
  "Sesotho sa Leboa (South Africa)", "nso-ZA",
  "Setswana", "tn",
  "Setswana (Botswana)", "tn-BW",
  "Setswana (South Africa)", "tn-ZA",
  "Sindhi", "sd",
  "Sindhi", "sd-Arab",
  "Sindhi (Devanagari, India)", "sd-Deva-IN",
  "Sindhi (Pakistan)", "sd-Arab-PK",
  "Sinhala", "si",
  "Sinhala (Sri Lanka)", "si-LK",
  "Slovak", "sk",
  "Slovak (Slovakia)", "sk-SK",
  "Slovenian", "sl",
  "Slovenian (Slovenia)", "sl-SI",
  "Somali", "so",
  "Somali (Somalia)", "so-SO",
  "Spanish", "es",
  "Spanish (Argentina)", "es-AR",
  "Spanish (Bolivia)", "es-BO",
  "Spanish (Chile)", "es-CL",
  "Spanish (Colombia)", "es-CO",
  "Spanish (Costa Rica)", "es-CR",
  "Spanish (Cuba)", "es-CU",
  "Spanish (Dominican Republic)", "es-DO",
  "Spanish (Ecuador)", "es-EC",
  "Spanish (El Salvador)", "es-SV",
  "Spanish (Guatemala)", "es-GT",
  "Spanish (Honduras)", "es-HN",
  "Spanish (Latin America)", "es-419",
  "Spanish (Mexico)", "es-MX",
  "Spanish (Nicaragua)", "es-NI",
  "Spanish (Panama)", "es-PA",
  "Spanish (Paraguay)", "es-PY",
  "Spanish (Peru)", "es-PE",
  "Spanish (Puerto Rico)", "es-PR",
  "Spanish (Spain, International Sort)", "es-ES",
  "Spanish (Spain, Traditional Sort)", "es-ES_tradnl",
  "Spanish (United States)", "es-US",
  "Spanish (Uruguay)", "es-UY",
  "Spanish (Venezuela)", "es-VE",
  "Swedish", "sv",
  "Swedish (Finland)", "sv-FI",
  "Swedish (Sweden)", "sv-SE",
  "Swiss German", "gsw",
  "Syriac", "syr",
  "Syriac (Syria)", "syr-SY",
  "Tajik", "tg",
  "Tajik (Cyrillic)", "tg-Cyrl",
  "Tajik (Cyrillic, Tajikistan)", "tg-Cyrl-TJ",
  "Tamil", "ta",
  "Tamil (India)", "ta-IN",
  "Tamil (Sri Lanka)", "ta-LK",
  "Tatar", "tt",
  "Tatar (Russia)", "tt-RU",
  "Telugu", "te",
  "Telugu (India)", "te-IN",
  "Thai", "th",
  "Thai (Thailand)", "th-TH",
  "Tibetan", "bo",
  "Tibetan (China)", "bo-CN",
  "Tigrinya", "ti",
  "Tigrinya (Eritrea)", "ti-ER",
  "Tigrinya (Ethiopia)", "ti-ET",
  "Turkish", "tr",
  "Turkish (Turkey)", "tr-TR",
  "Turkmen", "tk",
  "Turkmen (Turkmenistan)", "tk-TM",
  "Ukrainian", "uk",
  "Ukrainian (Ukraine)", "uk-UA",
  "Upper Sorbian", "hsb",
  "Upper Sorbian (Germany)", "hsb-DE",
  "Urdu", "ur",
  "Urdu (India)", "ur-IN",
  "Urdu (Pakistan)", "ur-PK",
  "Uyghur", "ug",
  "Uyghur (China)", "ug-CN",
  "Uzbek", "uz",
  "Uzbek (Cyrillic)", "uz-Cyrl",
  "Uzbek (Cyrillic, Uzbekistan)", "uz-Cyrl-UZ",
  "Uzbek (Latin)", "uz-Latn",
  "Uzbek (Latin, Uzbekistan)", "uz-Latn-UZ",
  "Valencian (Spain)", "ca-ES-valencia",
  "Venda", "ve",
  "Venda (South Africa)", "ve-ZA",
  "Vietnamese", "vi",
  "Vietnamese (Vietnam)", "vi-VN",
  "Welsh", "cy",
  "Welsh (United Kingdom)", "cy-GB",
  "Western Frisian", "fy",
  "Western Frisian (Netherlands)", "fy-NL",
  "Wolof", "wo",
  "Wolof (Senegal)", "wo-SN",
  "Xitsonga", "ts",
  "Xitsonga (South Africa)", "ts-ZA",
  "Yi", "ii",
  "Yi (China)", "ii-CN",
  "Yiddish", "yi",
  "Yiddish (World)", "yi-001",
  "Yoruba", "yo",
  "Yoruba (Nigeria)", "yo-NG"
)

; not used
/*
languageCodeToName:= Map(
  "af", "Afrikaans",
  "af-ZA", "Afrikaans (South Africa)",
  "sq", "Albanian",
  "sq-AL", "Albanian (Albania)",
  "gsw-FR", "Alsatian (France)",
  "am", "Amharic",
  "am-ET", "Amharic (Ethiopia)",
  "ar", "Arabic",
  "ar-DZ", "Arabic (Algeria)",
  "ar-BH", "Arabic (Bahrain)",
  "ar-EG", "Arabic (Egypt)",
  "ar-IQ", "Arabic (Iraq)",
  "ar-JO", "Arabic (Jordan)",
  "ar-KW", "Arabic (Kuwait)",
  "ar-LB", "Arabic (Lebanon)",
  "ar-LY", "Arabic (Libya)",
  "ar-MA", "Arabic (Morocco)",
  "ar-OM", "Arabic (Oman)",
  "ar-QA", "Arabic (Qatar)",
  "ar-SA", "Arabic (Saudi Arabia)",
  "ar-SY", "Arabic (Syria)",
  "ar-TN", "Arabic (Tunisia)",
  "ar-AE", "Arabic (United Arab Emirates)",
  "ar-YE", "Arabic (Yemen)",
  "hy", "Armenian",
  "hy-AM", "Armenian (Armenia)",
  "as", "Assamese",
  "as-IN", "Assamese (India)",
  "az", "Azerbaijani",
  "az-Cyrl", "Azerbaijani (Cyrillic)",
  "az-Cyrl-AZ", "Azerbaijani (Cyrillic, Azerbaijan)",
  "az-Latn", "Azerbaijani (Latin)",
  "az-Latn-AZ", "Azerbaijani (Latin, Azerbaijan)",
  "bn", "Bangla",
  "bn-BD", "Bangla (Bangladesh)",
  "ba", "Bashkir",
  "ba-RU", "Bashkir (Russia)",
  "eu", "Basque",
  "eu-ES", "Basque (Basque)",
  "be", "Belarusian",
  "be-BY", "Belarusian (Belarus)",
  "bn-IN", "Bengali (India)",
  "bs", "Bosnian",
  "bs-Cyrl", "Bosnian (Cyrillic)",
  "bs-Cyrl-BA", "Bosnian (Cyrillic, Bosnia and Herzegovina)",
  "bs-Latn", "Bosnian (Latin)",
  "bs-Latn-BA", "Bosnian (Latin, Bosnia & Herzegovina)",
  "br", "Breton",
  "br-FR", "Breton (France)",
  "bg", "Bulgarian",
  "bg-BG", "Bulgarian (Bulgaria)",
  "my", "Burmese",
  "my-MM", "Burmese (Myanmar)",
  "ca", "Catalan",
  "ca-ES", "Catalan (Catalan)",
  "tzm", "Central Atlas Tamazight",
  "tzm-Arab-MA", "Central Atlas Tamazight (Arabic, Morocco)",
  "tzm-Latn", "Central Atlas Tamazight (Latin)",
  "tzm-Latn-DZ", "Central Atlas Tamazight (Latin Algeria)",
  "tzm-Tfng", "Central Atlas Tamazight (Tifinagh)",
  "tzm-Tfng-MA", "Central Atlas Tamazight (Tifinagh, Morocco)",
  "ku", "Central Kurdish",
  "ku-Arab", "Central Kurdish",
  "ku-Arab-IQ", "Central Kurdish (Iraq)",
  "chr", "Cherokee",
  "chr-Cher", "Cherokee",
  "chr-Cher-US", "Cherokee (Cherokee, United States)",
  "zh", "Chinese",
  "zh-Hans", "Chinese (Simplified)",
  "zh-CN", "Chinese (Simplified, China)",
  "zh-SG", "Chinese (Simplified, Singapore)",
  "zh-Hant", "Chinese (Traditional)",
  "zh-HK", "Chinese (Traditional, Hong Kong SAR)",
  "zh-MO", "Chinese (Traditional, Macao SAR)",
  "zh-TW", "Chinese (Traditional, Taiwan)",
  "co", "Corsican",
  "co-FR", "Corsican (France)",
  "hr", "Croatian",
  "hr-BA", "Croatian (Bosnia & Herzegovina)",
  "hr-HR", "Croatian (Croatia)",
  "cs", "Czech",
  "cs-CZ", "Czech (Czechia)",
  "da", "Danish",
  "da-DK", "Danish (Denmark)",
  "dv", "Divehi",
  "dv-MV", "Divehi (Maldives)",
  "nl", "Dutch",
  "nl-BE", "Dutch (Belgium)",
  "nl-NL", "Dutch (Netherlands)",
  "dz-BT", "Dzongkha (Bhutan)",
  "bin", "Edo",
  "bin-NG", "Edo (Nigeria)",
  "en", "English",
  "en-AU", "English (Australia)",
  "en-BZ", "English (Belize)",
  "en-CA", "English (Canada)",
  "en-029", "English (Caribbean)",
  "en-HK", "English (Hong Kong SAR)",
  "en-IN", "English (India)",
  "en-ID", "English (Indonesia)",
  "en-IE", "English (Ireland)",
  "en-JM", "English (Jamaica)",
  "en-MY", "English (Malaysia)",
  "en-NZ", "English (New Zealand)",
  "en-PH", "English (Philippines)",
  "en-SG", "English (Singapore)",
  "en-ZA", "English (South Africa)",
  "en-TT", "English (Trinidad & Tobago)",
  "en-AE", "English (United Arab Emirates)",
  "en-GB", "English (United Kingdom)",
  "en-US", "English (United States)",
  "en-ZW", "English (Zimbabwe)",
  "et", "Estonian",
  "et-EE", "Estonian (Estonia)",
  "fo", "Faroese",
  "fo-FO", "Faroese (Faroe Islands)",
  "fil", "Filipino",
  "fil-PH", "Filipino (Philippines)",
  "fi", "Finnish",
  "fi-FI", "Finnish (Finland)",
  "fr", "French",
  "fr-BE", "French (Belgium)",
  "fr-CM", "French (Cameroon)",
  "fr-CA", "French (Canada)",
  "fr-029", "French (Caribbean)",
  "fr-CI", "French (C�te d�Ivoire)",
  "fr-FR", "French (France)",
  "fr-HT", "French (Haiti)",
  "fr-LU", "French (Luxembourg)",
  "fr-ML", "French (Mali)",
  "fr-MC", "French (Monaco)",
  "fr-MA", "French (Morocco)",
  "fr-RE", "French (Réunion)",
  "fr-SN", "French (Senegal)",
  "fr-CH", "French (Switzerland)",
  "fr-CD", "French Congo (DRC)",
  "ff", "Fulah",
  "ff-Latn", "Fulah (Latin)",
  "ff-Latn-NG", "Fulah (Latin, Nigeria)",
  "ff-Latn-SN", "Fulah (Latin, Senegal)",
  "gl", "Galician",
  "gl-ES", "Galician (Galician)",
  "ka", "Georgian",
  "ka-GE", "Georgian (Georgia)",
  "de", "German",
  "de-AT", "German (Austria)",
  "de-DE", "German (Germany)",
  "de-LI", "German (Liechtenstein)",
  "de-LU", "German (Luxembourg)",
  "de-CH", "German (Switzerland)",
  "el", "Greek",
  "el-GR", "Greek (Greece)",
  "gn", "Guarani",
  "gn-PY", "Guarani (Paraguay)",
  "gu", "Gujarati",
  "gu-IN", "Gujarati (India)",
  "ha", "Hausa",
  "ha-Latn", "Hausa (Latin)",
  "ha-Latn-NG", "Hausa (Latin, Nigeria)",
  "haw", "Hawaiian",
  "haw-US", "Hawaiian (United States)",
  "he", "Hebrew",
  "he-IL", "Hebrew (Israel)",
  "hi", "Hindi",
  "hi-IN", "Hindi (India)",
  "hu", "Hungarian",
  "hu-HU", "Hungarian (Hungary)",
  "ibb", "Ibibio",
  "ibb-NG", "Ibibio (Nigeria)",
  "is", "Icelandic",
  "is-IS", "Icelandic (Iceland)",
  "ig", "Igbo",
  "ig-NG", "Igbo (Nigeria)",
  "id", "Indonesian",
  "id-ID", "Indonesian (Indonesia)",
  "iu", "Inuktitut",
  "iu-Latn", "Inuktitut (Latin)",
  "iu-Latn-CA", "Inuktitut (Latin, Canada)",
  "iu-Cans", "Inuktitut (Syllabics)",
  "iu-Cans-CA", "Inuktitut (Syllabics, Canada)",
  "ga", "Irish",
  "ga-IE", "Irish (Ireland)",
  "xh", "isiXhosa",
  "xh-ZA", "isiXhosa (South Africa)",
  "zu", "isiZulu",
  "zu-ZA", "isiZulu (South Africa)",
  "it", "Italian",
  "it-IT", "Italian (Italy)",
  "it-CH", "Italian (Switzerland)",
  "ja", "Japanese",
  "ja-JP", "Japanese (Japan)",
  "kl", "Kalaallisut",
  "kl-GL", "Kalaallisut (Greenland)",
  "kn", "Kannada",
  "kn-IN", "Kannada (India)",
  "kr", "Kanuri",
  "kr-Latn-NG", "Kanuri (Latin, Nigeria)",
  "ks", "Kashmiri",
  "ks-Arab", "Kashmiri (Arabic)",
  "ks-Arab-IN", "Kashmiri (Arabic)",
  "ks-Deva-IN", "Kashmiri (Devanagari)",
  "kk", "Kazakh",
  "kk-KZ", "Kazakh (Kazakhstan)",
  "km", "Khmer",
  "km-KH", "Khmer (Cambodia)",
  "rw", "Kinyarwanda",
  "rw-RW", "Kinyarwanda (Rwanda)",
  "sw", "Kiswahili",
  "sw-KE", "Kiswahili (Kenya)",
  "kok", "Konkani",
  "kok-IN", "Konkani (India)",
  "ko", "Korean",
  "ko-KR", "Korean (Korea)",
  "ky", "Kyrgyz",
  "ky-KG", "Kyrgyz (Kyrgyzstan)",
  "quc", "K'iche",
  "quc-Latn", "K'iche (Latin)",
  "quc-Latn-GT", "K'iche (Latin, Guatemala)",
  "lo", "Lao",
  "lo-LA", "Lao (Laos)",
  "la", "Latin",
  "la-VA", "Latin (Vatican City)",
  "lv", "Latvian",
  "lv-LV", "Latvian (Latvia)",
  "lt", "Lithuanian",
  "lt-LT", "Lithuanian (Lithuania)",
  "dsb", "Lower Sorbian",
  "dsb-DE", "Lower Sorbian (Germany)",
  "lb", "Luxembourgish",
  "lb-LU", "Luxembourgish (Luxembourg)",
  "mk", "Macedonian",
  "mk-MK", "Macedonian (North Macedonia)",
  "ms", "Malay",
  "ms-BN", "Malay (Brunei)",
  "ms-MY", "Malay (Malaysia)",
  "ml", "Malayalam",
  "ml-IN", "Malayalam (India)",
  "mt", "Maltese",
  "mt-MT", "Maltese (Malta)",
  "mni", "Manipuri",
  "mni-IN", "Manipuri (Bangla, India)",
  "mi", "Maori",
  "mi-NZ", "Maori (New Zealand)",
  "arn", "Mapuche",
  "arn-CL", "Mapuche (Chile)",
  "mr", "Marathi",
  "mr-IN", "Marathi (India)",
  "moh", "Mohawk",
  "moh-CA", "Mohawk (Canada)",
  "mn", "Mongolian",
  "mn-Cyrl", "Mongolian",
  "mn-MN", "Mongolian (Mongolia)",
  "mn-Mong", "Mongolian (Traditional Mongolian)",
  "mn-Mong-CN", "Mongolian (Traditional Mongolian, China)",
  "mn-Mong-MN", "Mongolian (Traditional Mongolian, Mongolia)",
  "ne", "Nepali",
  "ne-IN", "Nepali (India)",
  "ne-NP", "Nepali (Nepal)",
  "se", "Northern Sami",
  "no", "Norwegian",
  "nb", "Norwegian Bokm�l",
  "nb-NO", "Norwegian Bokm�l (Norway)",
  "nn", "Norwegian Nynorsk",
  "nn-NO", "Norwegian Nynorsk (Norway)",
  "oc", "Occitan",
  "oc-FR", "Occitan (France)",
  "or", "Odia",
  "or-IN", "Odia (India)",
  "om", "Oromo",
  "om-ET", "Oromo (Ethiopia)",
  "pap", "Papiamento",
  "pap-029", "Papiamento (Caribbean)",
  "ps", "Pashto",
  "ps-AF", "Pashto (Afghanistan)",
  "fa", "Persian",
  "fa", "Persian",
  "fa-AF", "Persian (Afghanistan)",
  "fa-IR", "Persian (Iran)",
  "pl", "Polish",
  "pl-PL", "Polish (Poland)",
  "pt", "Portuguese",
  "pt-BR", "Portuguese (Brazil)",
  "pt-PT", "Portuguese (Portugal)",
  "qps-ploca", "Pseudo (Pseudo Asia)",
  "qps-plocm", "Pseudo (Pseudo Mirrored)",
  "qps-Latn-x-sh", "Pseudo (Pseudo Selfhost)",
  "qps-ploc", "Pseudo (Pseudo)",
  "pa", "Punjabi",
  "pa-Arab", "Punjabi",
  "pa-IN", "Punjabi (India)",
  "pa-Arab-PK", "Punjabi (Pakistan)",
  "quz", "Quechua",
  "quz-BO", "Quechua (Bolivia)",
  "quz-EC", "Quechua (Ecuador)",
  "quz-PE", "Quechua (Peru)",
  "ro", "Romanian",
  "ro-MD", "Romanian (Moldova)",
  "ro-RO", "Romanian (Romania)",
  "rm", "Romansh",
  "rm-CH", "Romansh (Switzerland)",
  "ru", "Russian",
  "ru-MD", "Russian (Moldova)",
  "ru-RU", "Russian (Russia)",
  "sah", "Sakha",
  "sah-RU", "Sakha (Russia)",
  "smn", "Sami (Inari)",
  "smj", "Sami (Lule)",
  "sms", "Sami (Skolt)",
  "sma", "Sami (Southern)",
  "smn-FI", "Sami, Inari (Finland)",
  "smj-NO", "Sami, Lule (Norway)",
  "smj-SE", "Sami, Lule (Sweden)",
  "se-FI", "Sami, Northern (Finland)",
  "se-NO", "Sami, Northern (Norway)",
  "se-SE", "Sami, Northern (Sweden)",
  "sms-FI", "Sami, Skolt (Finland)",
  "sma-NO", "Sami, Southern (Norway)",
  "sma-SE", "Sami, Southern (Sweden)",
  "sa", "Sanskrit",
  "sa-IN", "Sanskrit (India)",
  "gd", "Scottish Gaelic",
  "gd-GB", "Scottish Gaelic (United Kingdom)",
  "sr", "Serbian",
  "sr-Cyrl", "Serbian (Cyrillic)",
  "sr-Cyrl-BA", "Serbian (Cyrillic, Bosnia and Herzegovina)",
  "sr-Cyrl-ME", "Serbian (Cyrillic, Montenegro)",
  "sr-Cyrl-CS", "Serbian (Cyrillic, Serbia and Montenegro (Former))",
  "sr-Cyrl-RS", "Serbian (Cyrillic, Serbia)",
  "sr-Latn", "Serbian (Latin)",
  "sr-Latn-BA", "Serbian (Latin, Bosnia & Herzegovina)",
  "sr-Latn-ME", "Serbian (Latin, Montenegro)",
  "sr-Latn-CS", "Serbian (Latin, Serbia and Montenegro (Former))",
  "sr-Latn-RS", "Serbian (Latin, Serbia)",
  "st", "Sesotho",
  "st-ZA", "Sesotho (South Africa)",
  "nso", "Sesotho sa Leboa",
  "nso-ZA", "Sesotho sa Leboa (South Africa)",
  "tn", "Setswana",
  "tn-BW", "Setswana (Botswana)",
  "tn-ZA", "Setswana (South Africa)",
  "sd", "Sindhi",
  "sd-Arab", "Sindhi",
  "sd-Deva-IN", "Sindhi (Devanagari, India)",
  "sd-Arab-PK", "Sindhi (Pakistan)",
  "si", "Sinhala",
  "si-LK", "Sinhala (Sri Lanka)",
  "sk", "Slovak",
  "sk-SK", "Slovak (Slovakia)",
  "sl", "Slovenian",
  "sl-SI", "Slovenian (Slovenia)",
  "so", "Somali",
  "so-SO", "Somali (Somalia)",
  "es", "Spanish",
  "es-AR", "Spanish (Argentina)",
  "es-BO", "Spanish (Bolivia)",
  "es-CL", "Spanish (Chile)",
  "es-CO", "Spanish (Colombia)",
  "es-CR", "Spanish (Costa Rica)",
  "es-CU", "Spanish (Cuba)",
  "es-DO", "Spanish (Dominican Republic)",
  "es-EC", "Spanish (Ecuador)",
  "es-SV", "Spanish (El Salvador)",
  "es-GT", "Spanish (Guatemala)",
  "es-HN", "Spanish (Honduras)",
  "es-419", "Spanish (Latin America)",
  "es-MX", "Spanish (Mexico)",
  "es-NI", "Spanish (Nicaragua)",
  "es-PA", "Spanish (Panama)",
  "es-PY", "Spanish (Paraguay)",
  "es-PE", "Spanish (Peru)",
  "es-PR", "Spanish (Puerto Rico)",
  "es-ES", "Spanish (Spain, International Sort)",
  "es-ES_tradnl", "Spanish (Spain, Traditional Sort)",
  "es-US", "Spanish (United States)",
  "es-UY", "Spanish (Uruguay)",
  "es-VE", "Spanish (Venezuela)",
  "sv", "Swedish",
  "sv-FI", "Swedish (Finland)",
  "sv-SE", "Swedish (Sweden)",
  "gsw", "Swiss German",
  "syr", "Syriac",
  "syr-SY", "Syriac (Syria)",
  "tg", "Tajik",
  "tg-Cyrl", "Tajik (Cyrillic)",
  "tg-Cyrl-TJ", "Tajik (Cyrillic, Tajikistan)",
  "ta", "Tamil",
  "ta-IN", "Tamil (India)",
  "ta-LK", "Tamil (Sri Lanka)",
  "tt", "Tatar",
  "tt-RU", "Tatar (Russia)",
  "te", "Telugu",
  "te-IN", "Telugu (India)",
  "th", "Thai",
  "th-TH", "Thai (Thailand)",
  "bo", "Tibetan",
  "bo-CN", "Tibetan (China)",
  "ti", "Tigrinya",
  "ti-ER", "Tigrinya (Eritrea)",
  "ti-ET", "Tigrinya (Ethiopia)",
  "tr", "Turkish",
  "tr-TR", "Turkish (Turkey)",
  "tk", "Turkmen",
  "tk-TM", "Turkmen (Turkmenistan)",
  "uk", "Ukrainian",
  "uk-UA", "Ukrainian (Ukraine)",
  "hsb", "Upper Sorbian",
  "hsb-DE", "Upper Sorbian (Germany)",
  "ur", "Urdu",
  "ur-IN", "Urdu (India)",
  "ur-PK", "Urdu (Pakistan)",
  "ug", "Uyghur",
  "ug-CN", "Uyghur (China)",
  "uz", "Uzbek",
  "uz-Cyrl", "Uzbek (Cyrillic)",
  "uz-Cyrl-UZ", "Uzbek (Cyrillic, Uzbekistan)",
  "uz-Latn", "Uzbek (Latin)",
  "uz-Latn-UZ", "Uzbek (Latin, Uzbekistan)",
  "ca-ES-valencia", "Valencian (Spain)",
  "ve", "Venda",
  "ve-ZA", "Venda (South Africa)",
  "vi", "Vietnamese",
  "vi-VN", "Vietnamese (Vietnam)",
  "cy", "Welsh",
  "cy-GB", "Welsh (United Kingdom)",
  "fy", "Western Frisian",
  "fy-NL", "Western Frisian (Netherlands)",
  "wo", "Wolof",
  "wo-SN", "Wolof (Senegal)",
  "ts", "Xitsonga",
  "ts-ZA", "Xitsonga (South Africa)",
  "ii", "Yi",
  "ii-CN", "Yi (China)",
  "yi", "Yiddish",
  "yi-001", "Yiddish (World)",
  "yo", "Yoruba",
  "yo-NG", "Yoruba (Nigeria)"
)
*/




