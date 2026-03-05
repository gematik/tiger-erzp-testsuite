# language: de

#Test für VPS-T-REZEPT
#Testfall prüft das Erzeugen eines T-Rezeptes. Zu erfüllende Vorbedingung: AuthN-Token anfordern für VPS-T-REZEPT.

@VPS-T-REZEPT_CREATE
@VPS-T-REZEPT
Funktion: eRp verordnend - GF E-T-Rezept erzeugen (ein Verordnungsdatensatz)

  Grundlage:
    Gegeben sei TGR lösche aufgezeichnete Nachrichten
    Gegeben sei TGR lösche alle default headers

  @VPS-T-REZEPT
  Szenario: Test: T-Rezept erzeugen
    Gegeben sei TGR pausiere Testausführung mit Nachricht "Bitte erzeugen Sie mit dem Primärsystem (PS) ein T-Rezept mit einem Verordnungsdatensatz."
    Und TGR finde die letzte Anfrage mit Pfad ".*" und Knoten "$.body.message.path.basicPath" der mit "/Task/$create" übereinstimmt
    Dann TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.body.Task.extension.valueCoding.code.value" überein mit "166"
    Und TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.responseCode" überein mit "201"
    Und TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.body" nicht überein mit "^Error:.*"
