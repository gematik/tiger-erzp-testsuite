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

import eu.europa.esig.dss.cades.CAdESSignatureParameters;
import eu.europa.esig.dss.cades.signature.CAdESService;
import eu.europa.esig.dss.enumerations.*;
import eu.europa.esig.dss.model.DSSDocument;
import eu.europa.esig.dss.model.InMemoryDocument;
import eu.europa.esig.dss.model.SignatureValue;
import eu.europa.esig.dss.model.ToBeSigned;
import eu.europa.esig.dss.model.x509.CertificateToken;
import eu.europa.esig.dss.token.DSSPrivateKeyEntry;
import eu.europa.esig.dss.token.SignatureTokenConnection;
import eu.europa.esig.dss.validation.CommonCertificateVerifier;
import java.io.ByteArrayOutputStream;
import java.util.Date;
import org.apache.commons.io.IOUtils;

public class CAdES {
    public static byte[] sign(
            SignatureTokenConnection signingToken,
            byte[] toBeSigned,
            SignaturePackaging signaturePackaging)
            throws Exception {

        DSSPrivateKeyEntry privateKey = signingToken.getKeys().get(0);
        CAdESSignatureParameters parameters = new CAdESSignatureParameters();

        parameters.setSignatureLevel(SignatureLevel.CAdES_BASELINE_B);
        parameters.setSignaturePackaging(signaturePackaging);

        EncryptionAlgorithm encryptionAlgorithm =
                signingToken.getKeys().get(0).getEncryptionAlgorithm();

        parameters.bLevel().setSigningDate(new Date());

        parameters.setDigestAlgorithm(DigestAlgorithm.SHA256);
        parameters.setEncryptionAlgorithm(encryptionAlgorithm);
        if (encryptionAlgorithm.equals(EncryptionAlgorithm.RSA)) {
            parameters.setMaskGenerationFunction(MaskGenerationFunction.MGF1);
        }
        parameters.setSignaturePackaging(SignaturePackaging.ENVELOPING);

        CertificateToken certificateToken = privateKey.getCertificate();
        parameters.setSigningCertificate(certificateToken);

        CommonCertificateVerifier commonCertificateVerifier = new CommonCertificateVerifier();

        CAdESService service = new CAdESService(commonCertificateVerifier);

        DSSDocument toSignDocument = new InMemoryDocument(toBeSigned);
        ToBeSigned dataToSign = service.getDataToSign(toSignDocument, parameters);

        // eigentliche low level Signatur wird erzeugt
        SignatureValue signatureValue =
                signingToken.sign(
                        dataToSign,
                        parameters.getDigestAlgorithm(),
                        parameters.getMaskGenerationFunction(),
                        privateKey);

        // high level Signatur wird zusammengebaut
        DSSDocument signedDocument = service.signDocument(toSignDocument, parameters, signatureValue);

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        IOUtils.copy(signedDocument.openStream(), baos);
        byte[] signedDocumentBytes = baos.toByteArray();
        return signedDocumentBytes;
    }
}
