# language: de

#Test für VPS
#Testfall prüft das Einstellen eines E-Rezeptes. Zu erfüllende Vorbedingungen:
#   1) AuthN-Token anfordern für VPS,
#   2) E-Rezept erzeugen

@VPS_AF2x3_001
@VPS
Funktion: eRp verordnend - ERP_VPS_AF2x3_001 - GF E-Rezept einstellen

  Grundlage:
    Gegeben sei TGR lösche alle default headers

  @VPS
  Szenario: Vorbedingung: lösche alte Nachrichten
    Gegeben sei TGR lösche aufgezeichnete Nachrichten

  @VPS
  Szenario: Vorbedingung: E-Rezept erzeugen
    Gegeben sei TGR pausiere Testausführung mit Nachricht "Bitte erzeugen Sie mit dem Primärsystem (PS) ein E-Rezept mit einem Verordnungsdatensatz."
    Und TGR finde die letzte Anfrage mit Pfad ".*" und Knoten "$.body.message.path.basicPath" der mit "/Task/$create" übereinstimmt
    Dann TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.responseCode" überein mit "201"
    Und TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.body" nicht überein mit "^Error:.*"
    Und TGR speichere Wert des Knotens "$.body.message.body.Task.id.value" der aktuellen Antwort in der Variable "erp.task_id"

  @VPS
  Szenario: Test: E-Rezept einstellen
    Gegeben sei TGR pausiere Testausführung mit Nachricht "Bitte stellen Sie das bereits erzeugte E-Rezept ein."
    Und TGR finde die letzte Anfrage mit Pfad ".*" und Knoten "$.body.message.path.basicPath" der mit "/Task/${erp.task_id}/$activate" übereinstimmt
    Und TGR prüfe aktueller Request enthält Knoten "$.body.message.body.Parameters.parameter.resource.Binary.data.value.[?(@..name == 'ocspBasic')]"
    Dann TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.responseCode" überein mit "200"
    Und TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.body" nicht überein mit "^Error:.*"
