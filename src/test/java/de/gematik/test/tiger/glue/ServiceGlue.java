/*
 * Copyright 2025, gematik GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * *******
 *
 * For additional notes and disclaimer from gematik and in case of changes by gematik find details in the "Readme" file.
 */

package de.gematik.test.tiger.glue;

import de.gematik.test.tiger.common.config.TigerGlobalConfiguration;
import de.gematik.test.tiger.service.egk.KvnrHelper;
import de.gematik.test.tiger.service.qes.SignatureService;
import io.cucumber.java.en.Given;

import java.io.IOException;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;

public class ServiceGlue {
    private final SignatureService signatureService = new SignatureService();

    private static DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

    @Given("Store current date in {tigerResolvedString}")
    @Given("Speichere das aktuelle Datum in {tigerResolvedString}")
    public void store_current_date_in(String storeUnderName) {
        LocalDate currentDate = LocalDate.now();
        TigerGlobalConfiguration.putValue(storeUnderName, currentDate.format(formatter));
    }

    @Given("As a doctor I want sign {tigerResolvedString} and store in variable {tigerResolvedString}")
    @Given("Als Arzt signiere ich {tigerResolvedString} und speichere es in der Variable in {tigerResolvedString}")   public void as_doctor_i_want_to_sign_something(String toBeSigned, String storeUnderName) throws Exception {
        var hbaBytes = getResourceBytes("Arzt_HBA_QES_E256.p12");
        var signedBytes = signatureService.createQES(toBeSigned.getBytes(StandardCharsets.UTF_8), hbaBytes, "00");
        TigerGlobalConfiguration.putValue(storeUnderName, signedBytes);
    }

    @Given("As a patient I want to store my KVNR in variable {tigerResolvedString}")
    @Given("Als Patient speichere ich meine KVNR in der Variable {tigerResolvedString}")
    public void as_patient_i_want_to_store_my_KVNR_in_variable(String storeUnderName) throws Exception {
        var egk = getResourceBytes("Patient_AUT_E256.p12");
        var kvnr = KvnrHelper.extract_kvnr_from(egk, "00");
        TigerGlobalConfiguration.putValue(storeUnderName, kvnr);
    }

    private byte[] getResourceBytes(String filename) throws IOException {
        try (InputStream inputStream = this.getClass().getClassLoader().getResourceAsStream(filename)) {
            if (inputStream == null) {
                throw new IOException("Resource not found: " + filename);
            }
            return inputStream.readAllBytes();
        }
    }
}
