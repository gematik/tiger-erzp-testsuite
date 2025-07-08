# language: de

#Test für APS
#Testfall prüft das Empfangen von Nachrichten. Zu erfüllende Vorbedingungen: 1) AuthN-Token anfordern
#        für VPS, 2) E-Rezept erzeugen, 3) E-Rezept einstellen, 4) Nachricht durch Patient einstellen, 5) AuthN-Token
#        anfordern für APS
@APS_AF4x6_001
@APS
Funktion: eRp abgebend - ERP_APS_AF4x6_001 - GF Nachricht empfangen (Text)

  Grundlage:
    Gegeben sei TGR lösche alle default headers

  @APS
  Szenario: Vorbedingung: lösche alte Nachrichten
    Gegeben sei TGR lösche aufgezeichnete Nachrichten
  @APS
  Szenario: Vorbedingung: Als Arztpraxis ein IDP Access Token abholen
    Gegeben sei TGR setze den default header "X-p12-bytes-base64" auf den Wert "!{resolve(file('src/test/resources/Arztpraxis_SMCB_AUT_E256_X509.p12.base64'))}"
    Und TGR setze den default header "X-keystore-password" auf den Wert "00"
    Und TGR setze den default header "X-scope" auf den Wert "${data.idp.scope}"
    Und TGR setze den default header "X-discovery-document-address" auf den Wert "${data.idp.discoveryDocumentAddress}"
    Und TGR setze den default header "X-client-id" auf den Wert "${data.idp.clientId}"
    Und TGR setze den default header "X-redirect-uri" auf den Wert "${data.idp.redirectUrl}"
    Wenn TGR sende eine leere GET Anfrage an "${data.idp_client_service}"
    Und TGR finde die letzte Anfrage mit Pfad "/" und Knoten "$..receiver" der mit "${data.dockerservices.idp.address}" übereinstimmt
    Dann TGR prüfe aktuelle Antwort stimmt im Knoten "$.responseCode" überein mit "200"
    Und TGR speichere Wert des Knotens "$.body" der aktuellen Antwort in der Variable "erp.access_token_arztpraxis"

  @APS
  Szenario: Vorbedingung: Als Arzt ein E-Rezept erstellen
    Und TGR setze folgende default headers:
  """
    Content-Type  = application/fhir+xml; charset=UTF-8
    Accept        = application/fhir+xml; charset=UTF-8
    Authorization = Bearer ${erp.access_token_arztpraxis}
    User-Agent    = ${data.user_agent_pvs}
  """

    Wenn TGR sende eine POST Anfrage an "${data.address_fachdienst}/Task/$create" mit folgenden mehrzeiligen Daten:
  """
  <Parameters xmlns="http://hl7.org/fhir">
    <parameter>
      <name value="workflowType"/>
      <valueCoding>
        <system value="https://gematik.de/fhir/erp/CodeSystem/GEM_ERP_CS_FlowType"/>
        <code value="200"/>
      </valueCoding>
    </parameter>
  </Parameters>
  """
    Und TGR finde die letzte Anfrage mit dem Pfad "/Task/$create"
    Dann TGR prüfe aktuelle Antwort stimmt im Knoten "$.responseCode" überein mit "201"
    Und TGR prüfe aktuelle Antwort stimmt im Knoten "$.body" nicht überein mit "^Error:.*"

    Und TGR speichere Wert des Knotens "$.body.Task.id.value" der aktuellen Antwort in der Variable "erp.task_id"
    Und TGR speichere Wert des Knotens "$.body.Task.identifier[?(lowerCase(@.system.value.basicPath) =$ 'accesscode')].value.value" der aktuellen Antwort in der Variable "erp.task_access_code"
    Und TGR speichere Wert des Knotens "$.body.Task.identifier[?(lowerCase(@.system.value.basicPath) =$ 'prescriptionid')].value.value" der aktuellen Antwort in der Variable "erp.task_prescription_id"

  @APS
  Szenario: Vorbedingung: als Arzt das KBV Bundle signieren
    Gegeben sei TGR setze globale Variable "erp.rnd_nr" auf "!{randomHex(12)}"
    Und Als Patient speichere ich meine KVNR in der Variable "erp.kvnr"
    Und Speichere das aktuelle Datum in "erp.current_date"
    Dann Als Arzt signiere ich "!{resolve(file('src/test/resources/Bundle_Arzt.xml'))}" und speichere es in der Variable in "erp.signed_document"

  @APS
  Szenario: Vorbedingung: Als Arzt das E-Rezept einstellen
    Und TGR setze folgende default headers:
  """
    Content-Type  = application/fhir+xml; charset=UTF-8
    Accept        = application/fhir+xml; charset=UTF-8
    Authorization = Bearer ${erp.access_token_arztpraxis}
    X-AccessCode  = ${erp.task_access_code}
  """

    Wenn TGR sende eine POST Anfrage an "${data.address_fachdienst}/Task/${erp.task_id}/$activate" mit folgenden mehrzeiligen Daten:
  """
  <Parameters xmlns="http://hl7.org/fhir">
    <parameter>
        <name value="ePrescription"/>
        <resource>
            <Binary>
                <contentType value="application/pkcs7-mime"/>
                <data value="${erp.signed_document}"/>
            </Binary>
        </resource>
    </parameter>
  </Parameters>
  """
    Und TGR finde die letzte Anfrage mit dem Pfad "/Task/${erp.task_id}/$activate"
    Dann TGR prüfe aktuelle Antwort stimmt im Knoten "$.responseCode" überein mit "200"
    Und TGR prüfe aktuelle Antwort stimmt im Knoten "$.body" nicht überein mit "^Error:.*"

  @APS
  Szenario: Vorbedingung: Als Patient ein IDP Access Token abholen
    Gegeben sei TGR setze den default header "X-p12-bytes-base64" auf den Wert "!{resolve(file('src/test/resources/Patient_AUT_E256.p12.base64'))}"
    Und TGR setze den default header "X-keystore-password" auf den Wert "00"
    Und TGR setze den default header "X-scope" auf den Wert "${data.idp.scope}"
    Und TGR setze den default header "X-discovery-document-address" auf den Wert "${data.idp.discoveryDocumentAddress}"
    Und TGR setze den default header "X-client-id" auf den Wert "${data.idp.clientId}"
    Und TGR setze den default header "X-redirect-uri" auf den Wert "${data.idp.redirectUrl}"
    Wenn TGR sende eine leere GET Anfrage an "${data.idp_client_service}"
    Und TGR finde die letzte Anfrage mit Pfad "/" und Knoten "$..receiver" der mit "${data.dockerservices.idp.address}" übereinstimmt
    Dann TGR prüfe aktuelle Antwort stimmt im Knoten "$.responseCode" überein mit "200"
    Und TGR speichere Wert des Knotens "$.body" der aktuellen Antwort in der Variable "erp.access_token_patient"
    Und TGR speichere Wert des Knotens "$.body.body.idNummer" der aktuellen Antwort in der Variable "erp.patient_kvnr"


  @APS
  Szenario: Vorbedingung: Patient holt Medication
    Und TGR setze folgende default headers:
  """
    Accept        = application/fhir+json; charset=UTF-8
    Authorization = Bearer ${erp.access_token_patient}
    Content-Type  = application/fhir+json; charset=UTF-8
    User-Agent    = ${data.user_agent}
    X-api-key     = ${data.x_api_key}
  """
    Wenn TGR sende eine leere GET Anfrage an "${data.address_fachdienst_fdv}/Task/${erp.task_id}"
    Und TGR finde die letzte Anfrage mit dem Pfad "/Task/${erp.task_id}"
    Dann TGR prüfe aktuelle Antwort stimmt im Knoten "$.responseCode" überein mit "200"
    Und TGR prüfe aktuelle Antwort stimmt im Knoten "$.body" nicht überein mit "^Error:.*"

  @APS
  Szenario: Vorbedingung: Patient sendet Zuweisung
    Und TGR setze folgende default headers:
  """
    Content-Type  = application/fhir+json; charset=UTF-8
    Accept        = application/fhir+json
    Authorization = Bearer ${erp.access_token_patient}
    User-Agent    = ${data.user_agent}
    X-api-key     = ${data.x_api_key}
  """

    Wenn TGR sende eine POST Anfrage an "${data.address_fachdienst_fdv}/Communication" mit folgenden mehrzeiligen Daten:
  """
    {
     "resourceType": "Communication",
     "id": "erp-communication-05-request-RezeptZuweisen",
     "meta": {
       "profile": [
         "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_PR_Communication_DispReq|1.4"
       ]
     },
     "status": "unknown",
     "extension": [
       {
         "url": "https://gematik.de/fhir/erp/StructureDefinition/GEM_ERP_EX_PrescriptionType",
         "valueCoding": {
           "code": "160",
           "system": "https://gematik.de/fhir/erp/CodeSystem/GEM_ERP_CS_FlowType",
           "display": "Muster 16 (Apothekenpflichtige Arzneimittel)"
         }
       }
     ],
     "recipient": [
       {
         "identifier": {
           "system": "https://gematik.de/fhir/sid/telematik-id",
           "value": "${data.aps_telematik_id}"
         }
       }
     ],
     "basedOn": [
       {
         "reference": "Task/${erp.task_id}/$accept?ac=${erp.task_access_code}"
       }
     ],
     "payload": [
       {
         "contentString": "{ \"version\": 1, \"supplyOptionsType\": \"onPremise\", \"name\": \"Dr. Maximilian von Muster\", \"address\": [ \"wohnhaft bei Emilia Fischer\", \"Bundesallee 312\", \"123. OG\", \"12345 Berlin\" ], \"phone\": \"004916094858168\" }"
       }
     ]
   }
  """
    Und TGR finde die letzte Anfrage mit dem Pfad "/Communication"
    Dann TGR prüfe aktuelle Antwort stimmt im Knoten "$.responseCode" überein mit "201"
    Und TGR prüfe aktuelle Antwort stimmt im Knoten "$.body" nicht überein mit "^Error:.*"

  @APS
  Szenario: Nachricht empfangen
    Gegeben sei TGR pausiere Testausführung mit Nachricht "Bitte rufen Sie alle empfangenen Nachrichten ab."
    Und TGR finde die letzte Anfrage mit Pfad ".*" und Knoten "$.body.message.path.basicPath" der mit "/Communication" übereinstimmt
    Dann TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.responseCode" überein mit "200"