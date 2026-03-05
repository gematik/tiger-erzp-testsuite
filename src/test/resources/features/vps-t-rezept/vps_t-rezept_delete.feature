# language: de

#Test für VPS
#Testfall prüft das Löschen eines T-Rezeptes. Zu erfüllende Vorbedingungen:
#   1) AuthN-Token anfordern für VPS,
#   2) T-Rezept erzeugen,
#   3) T-Rezept einstellen
@VPS-T-REZEPT_DELETE
@VPS-T-REZEPT
Funktion: eRp verordnend - GF T-Rezept durch Verordnenden löschen

  Grundlage:
    Gegeben sei TGR lösche alle default headers

  @VPS-T-REZEPT
  Szenario: Vorbedingung: lösche alte Nachrichten
    Gegeben sei TGR lösche aufgezeichnete Nachrichten

  @VPS-T-REZEPT
  Szenario: Vorbedingung: T-Rezept erzeugen
    Gegeben sei TGR pausiere Testausführung mit Nachricht "Bitte erzeugen Sie mit dem Primärsystem (PS) ein T-Rezept mit einem Verordnungsdatensatz."
    Und TGR finde die letzte Anfrage mit Pfad ".*" und Knoten "$.body.message.path.basicPath" der mit "/Task/$create" übereinstimmt
    Dann TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.body.Task.extension.valueCoding.code.value" überein mit "166"
    Dann TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.responseCode" überein mit "201"
    Und TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.body" nicht überein mit "^Error:.*"
    Und TGR speichere Wert des Knotens "$.body.message.body.Task.id.value" der aktuellen Antwort in der Variable "erp.task_id"

  @VPS-T-REZEPT
  Szenario: Vorbedingung: T-Rezept einstellen
    Gegeben sei TGR pausiere Testausführung mit Nachricht "Bitte stellen Sie das bereits erzeugte T-Rezept ein."
    Und TGR finde die letzte Anfrage mit Pfad ".*" und Knoten "$.body.message.path.basicPath" der mit "/Task/${erp.task_id}/$activate" übereinstimmt
    Dann TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.responseCode" überein mit "200"
    Und TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.body" nicht überein mit "^Error:.*"
    Und TGR prüfe aktueller Request enthält Knoten "$.body.message.body.Parameters.parameter.resource.Binary.data.value.[?(@..name == 'ocspBasic')]"

  @VPS-T-REZEPT
  Szenario: Test: T-Rezept löschen
    Gegeben sei TGR pausiere Testausführung mit Nachricht "Bitte löschen Sie das vorher erzeugte T-Rezept."
    Und TGR finde die letzte Anfrage mit Pfad ".*" und Knoten "$.body.message.path.basicPath" der mit "/Task/${erp.task_id}/$abort" übereinstimmt
    Dann TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.responseCode" überein mit "204"
    Und TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.body" nicht überein mit "^Error:.*"


