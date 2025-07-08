# language: de

#Test für VPS
#Testfall prüft das Erzeugen eines PKV E-Rezeptes. Zu erfüllende Vorbedingung: AuthN-Token anfordern für VPS.
@VPS_AF200x1_001
@VPS
Funktion: eRp verordnend - ERP_VPS_AF200x1_001 - GF PKV E-Rezept erzeugen (WF 200)

  Grundlage:
    Gegeben sei TGR lösche alle default headers

  @VPS
  Szenario: Vorbedingung: lösche alte Nachrichten
    Gegeben sei TGR lösche aufgezeichnete Nachrichten

  @VPS
  Szenario: Vorbedingung: PKV E-Rezept erzeugen
    Gegeben sei TGR pausiere Testausführung mit Nachricht "Bitte erzeugen Sie mit dem Primärsystem (PS) ein PKV E-Rezept."
    Und TGR finde die letzte Anfrage mit Pfad ".*" und Knoten "$.body.message.path.basicPath" der mit "/Task/$create" übereinstimmt
    Dann TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.body.Task.extension.valueCoding.code.value" überein mit "200"
    Und TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.responseCode" überein mit "201"
    Und TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.body" nicht überein mit "^Error:.*"
    Und TGR speichere Wert des Knotens "$.body.message.body.Task.id.value" der aktuellen Antwort in der Variable "erp.task_id"

  @VPS
  Szenario: Test: PKV E-Rezept einstellen
    Gegeben sei TGR pausiere Testausführung mit Nachricht "Bitte stellen Sie das bereits erzeugte E-Rezept ein."
    Und TGR finde die letzte Anfrage mit Pfad ".*" und Knoten "$.body.message.path.basicPath" der mit "/Task/${erp.task_id}/$activate" übereinstimmt
    Und TGR prüfe aktueller Request enthält Knoten "$.body.message.body.Parameters.parameter.resource.Binary.data.value.[?(@..name == 'ocspBasic')]"
    Dann TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.responseCode" überein mit "200"
    Und TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.body" nicht überein mit "^Error:.*"



