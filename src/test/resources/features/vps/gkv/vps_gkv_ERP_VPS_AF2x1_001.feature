# language: de

#Test für VPS
#Testfall prüft das Erzeugen eines E-Rezeptes. Zu erfüllende Vorbedingung: AuthN-Token anfordern für VPS.

@VPS_AF2x1_001
@VPS
Funktion: eRp verordnend - ERP_VPS_AF2x1_001 - GF E-Rezept erzeugen (ein Verordnungsdatensatz)

  Grundlage:
    Gegeben sei TGR lösche aufgezeichnete Nachrichten
    Gegeben sei TGR lösche alle default headers

  @VPS
  Szenario: Test: E-Rezept erzeugen
    Gegeben sei TGR pausiere Testausführung mit Nachricht "Bitte erzeugen Sie mit dem Primärsystem (PS) ein E-Rezept mit einem Verordnungsdatensatz."
    Und TGR finde die letzte Anfrage mit Pfad ".*" und Knoten "$.body.message.path.basicPath" der mit "/Task/$create" übereinstimmt
    Und TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.responseCode" überein mit "201"
    Und TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.body" nicht überein mit "^Error:.*"
