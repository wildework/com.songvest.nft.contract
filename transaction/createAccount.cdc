transaction(publicKey: String) {
  prepare(signer: AuthAccount) {
    let account = AuthAccount(payer: signer);
    let key = PublicKey(
      publicKey: publicKey.decodeHex(),
      signatureAlgorithm: SignatureAlgorithm.ECDSA_Secp256k1
    )
    account.keys.add(
      publicKey: key,
      hashAlgorithm: HashAlgorithm.SHA3_256,
      weight: 1000.0
    )
  }
}