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

package de.gematik.test.tiger.service.qes;

import de.gematik.test.tiger.service.BouncyCastleConfig;
import eu.europa.esig.dss.enumerations.SignaturePackaging;
import eu.europa.esig.dss.token.Pkcs12SignatureToken;
import eu.europa.esig.dss.token.SignatureTokenConnection;

import java.security.KeyStore;

/**
 *  The code here was adapted from the <a href="https://gitlab.prod.ccs.gematik.solutions/git/Testtools/titus/erp-modul/-/blob/4f290fb51f534d13f8c6adabfe162b06dd2d3ec6/erezept-lib/src/main/java/de/gematik/titus/erezept/service/QESHelper.java">
 *      QESHelper in an old version (commit 4f290fb5) of  erp-modul</a>.
 */

public class SignatureService {

    public SignatureService() {
        BouncyCastleConfig.initialize();
    }

    public byte[] createQES(byte[] toBeSigned, byte[] pksc12, String keystorePassword) throws Exception {
        SignatureTokenConnection signingToken = new Pkcs12SignatureToken(
                pksc12,
                new KeyStore.PasswordProtection(keystorePassword.toCharArray())
        );
        return CAdES.sign(signingToken, toBeSigned, SignaturePackaging.ENVELOPING);
    }
}
