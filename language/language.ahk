﻿/*
lang() by bichlepa
https://github.com/bichlepa/lang

converted to AHK2 by JVR
not a 1:1 translation!

license: GPL v3

Please take a look at (https://github.com/jvr-ks/lang2/raw/main/license.txt)  

contents of _language:
  ;Settings:
  .lang      the two character language code of the desired language (eg. "en" or "de") (default: automatic then "en")
  .fallbacklang  fallback language if a translation is not available in the desired language (default: "en")
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
 
_language := Map()
translationsMap := Map()
 
;--------------------------------- lang_init ---------------------------------
lang_init() {
  global _language
  local codeSelected
  
  initLanguageCodes()
  
  _language := Object() ; an object literal
  _language.dir := A_ScriptDir "\language"
  _language.fallbacklang := "en-US"
  _language.codeSelected := "en-US"
  _language.allLangCodes := Map()
  _language.allLangNames := Map()
  _language.allLangEnNames := Map()
  _language.allLangsFilepath := Map()
  
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
    
  if (!(_language.allLangCodes.Has(_language.fallbacklang))){
    MsgBox("Fallback language not found in directory: " _language.dir, "Severe error occured, execution canceled!", "Icon!")
    exitApp
  }
  
  codeSelected := _languageHexToCode.Get(A_Language)  ; Get the name of the system's default language.
  _language.codeSelected := codeSelected
  
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
; It can be called to set the language, "A_Language" (systemlanguage) is used otherwise.

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
;----------------------------- initLanguageCodes -----------------------------
initLanguageCodes() {
  global
  
  _languageHexToCode := Map(
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
  
  _languageNameToCode := Map(
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
}
