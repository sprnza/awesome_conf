#!/usr/bin/env python3
from yandex_translate import YandexTranslate
translate=YandexTranslate("trnsl.1.1.20170203T104113Z.466c5acbae0ce4e5.1dd807b0f2f6a102868a15d39d6df89a57eb7b28")
import gi
gi.require_version("Gtk", "3.0")
from gi.repository import Gtk, Gdk, GObject
from alphabet_detector import AlphabetDetector

clip = Gtk.Clipboard.get(Gdk.SELECTION_PRIMARY)
text = clip.wait_for_text()

lang = translate.detect(text)
ad = AlphabetDetector()

if list(ad.detect_alphabet(text))[0] == "CYRILLIC":
    print("EN: " + translate.translate(text, "ru-en")['text'][0])
    print("IT: " + translate.translate(text, "ru-it")['text'][0])
elif list(ad.detect_alphabet(text))[0] == "LATIN":
    en_trans = translate.translate(text, "en-ru")['text'][0]
    it_trans = translate.translate(text, "it-ru")['text'][0]
    if ad.only_alphabet_chars(en_trans, "CYRILLIC"):
        print("EN: " + en_trans)
        en_success = True
    else:
        en_success = False
    if ad.only_alphabet_chars(it_trans, "CYRILLIC"):
        print("IT: " + it_trans)
        it_success = True
    else:
        it_success = False
    if not en_success and not it_success:
        print("Перевод не найден ни для одного языка")

