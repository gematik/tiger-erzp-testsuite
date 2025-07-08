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

package de.gematik.test.tiger.service.egk;

import de.gematik.test.tiger.service.BouncyCastleConfig;

import java.io.ByteArrayInputStream;
import java.security.KeyStore;
import java.security.cert.Certificate;
import java.security.cert.X509Certificate;
import java.util.Arrays;
import java.util.Set;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

public class KvnrHelper {
    private static Pattern kvnrPattern = Pattern.compile("^([A-Z]{1})([0-9]{8})([0-9]{1})$");

    public static String extract_kvnr_from(byte[] egk, String password) throws Exception {
        BouncyCastleConfig.initialize();
        var subject = getCertificateSubject(egk, password);
        // extract OU Value from subject
        {
            Set<String> kvnrCandidates = Arrays.stream(subject.split(","))
                    .map(String::trim)
                    .filter((it)->it.startsWith("OU") && it.contains("="))
                    .map((it)->it.split("=")[1].trim())
                    .filter((it)->kvnrPattern.matcher(it).matches())
                    .collect(Collectors.toSet());

            if(kvnrCandidates.size()!=1) {
                throw new IllegalStateException("expected 1 kvnr, but found " + kvnrCandidates.size() + "in subject: " + subject);
            }
            return kvnrCandidates.iterator().next();
        }
    }

    private static String getCertificateSubject(byte[] p12Bytes, String password) throws Exception {
        KeyStore keyStore = KeyStore.getInstance("PKCS12", "BC");
        try (ByteArrayInputStream inputStream = new ByteArrayInputStream(p12Bytes)) {
            keyStore.load(inputStream, password.toCharArray());
        }

        String alias = keyStore.aliases().nextElement();
        Certificate certificate = keyStore.getCertificate(alias);
        X509Certificate x509Certificate = (X509Certificate) certificate;

        return x509Certificate.getSubjectX500Principal().getName();
    }
}