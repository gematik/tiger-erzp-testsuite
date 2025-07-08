# language: de

#Test für APS
#Testfall prüft das Ändern von PKV-Abrechnungsdaten durch die Apotheke.
@APS_AF4x10_003
@APS
Funktion: eRp abgebend - ERP_APS_AF4x10_003 - GF PKV - Abrechnungsinfos ändern

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
  Szenario: Vorbedingung: Als Apotheker das E-Rezept abrufen
    Gegeben sei TGR pausiere Testausführung mit Nachricht "Bitte rufen Sie als Apotheker das E-Rezept mit TaskId: ${erp.task_id} und AccessCode: ${erp.task_access_code} ab."
    Und TGR finde die letzte Anfrage mit Pfad ".*" und Knoten "$.body.message.path.basicPath" der mit "/Task/${erp.task_id}/$accept" übereinstimmt
    Dann TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.responseCode" überein mit "200"
    Und TGR speichere Wert des Knotens "$.body..identifier[?(lowerCase(@.system.value.basicPath) =$ 'secret')].value.value" der aktuellen Antwort in der Variable "erp.task_secret"
    Und TGR speichere Wert des Knotens "$.body..Binary.data.value" der aktuellen Antwort in der Variable "erp.signed_document"
    Und TGR speichere Wert des Knotens "$.body..identifier[?(lowerCase(@.system.value.basicPath) =$ 'prescriptionid')].value.value" der aktuellen Antwort in der Variable "erp.aps_prescription_id"

    Und TGR setze globale Variable "erp.binary_data_value" auf "!{base64Decode(getValue('erp.signed_document'))}"
    Und TGR setze globale Variable "erp.aps_medication" auf "!{'<Medication>' + subStringBefore(subStringAfter(getValue('erp.binary_data_value'), '<Medication>') , '</Medication>') + '</Medication>'}"
    Und TGR setze globale Variable "erp.aps_medication_id" auf "!{subStringBefore(subStringAfter(getValue('erp.aps_medication'), '<id value=\"'), '\"')}"

  @APS
  Szenario: Vorbedingung: Als Apotheker die E-Rezept-Abgabe vollziehen
    Gegeben sei TGR pausiere Testausführung mit Nachricht "Bitte vollziehen Sie als Apotheker die E-Rezept-Abgabe."
    Und TGR finde die letzte Anfrage mit Pfad ".*" und Knoten "$.body.message.path.basicPath" der mit "/Task/${erp.task_id}/$close" übereinstimmt
    Dann TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.responseCode" überein mit "200"
    Und TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.body" nicht überein mit "^Error:.*"

  @APS
  Szenario: Vorbedingung: Als Apotheker den PKV-Abgabedatensatz signieren
    Gegeben sei TGR pausiere Testausführung mit Nachricht "Bitte signieren Sie als Apotheker den PKV-Abgabedatensatz auf einer HBA mit Generation 2.1."

  @APS
  Szenario: Vorbedingung: Als Apotheker PKV-Abrechnungsinformationen bereitstellen
    Gegeben sei TGR pausiere Testausführung mit Nachricht "Bitte stellen Sie Abrechnungsdaten ein."
    Dann TGR finde die letzte Anfrage mit Pfad ".*" und Knoten "$.body.message.path.basicPath" der mit "/ChargeItem" übereinstimmt
    Dann TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.responseCode" überein mit "201"
    Und TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.body" nicht überein mit "^Error:.*"

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
  Szenario: Vorbedingung: Patient holt PKV-Abrechnungsinformationen
    Und TGR setze folgende default headers:
  """
    Content-Type  = application/fhir+json; charset=UTF-8
    Accept        = application/fhir+json
    Authorization = Bearer ${erp.access_token_patient}
    User-Agent    = ${data.user_agent}
    X-api-key     = ${data.x_api_key}
  """
    Wenn TGR sende eine leere GET Anfrage an "${data.address_fachdienst_fdv}/ChargeItem/${erp.task_id}"
    Und TGR finde die letzte Anfrage mit dem Pfad "/ChargeItem/${erp.task_id}"
    Dann TGR prüfe aktuelle Antwort stimmt im Knoten "$.responseCode" überein mit "200"
    Und TGR speichere Wert des Knotens "$.body..resource.identifier.[?(lowerCase(@.system.content.basicPath) =$ 'accesscode')].value.content" der aktuellen Antwort in der Variable "erp.patient_access_code"

  @APS
  Szenario: Abrechnungsdaten ändern
    Gegeben sei TGR pausiere Testausführung mit Nachricht "Bitte ändern Sie Abrechnungsdaten für den Patient mit dem AccessCode: ${erp.patient_access_code}"
    Dann TGR finde die letzte Anfrage mit Pfad ".*" und Knoten "$.body.message.path.basicPath" der mit "/ChargeItem/${erp.task_id}" übereinstimmt
    Dann TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.responseCode" überein mit "200"
    Dann TGR prüfe aktuelle Antwort stimmt im Knoten "$.body.message.body" nicht überein mit "^Error:.*"
    Dann TGR prüfe aktueller Request stimmt im Knoten "$.body.message.method" überein mit "PUT"
