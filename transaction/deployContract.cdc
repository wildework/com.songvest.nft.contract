transaction(name: String, code: String) {
  prepare(account: AuthAccount) {
    account.contracts.add(
      name: name,
      code: code.decodeHex()
    )
  }
}