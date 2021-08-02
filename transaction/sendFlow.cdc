import FungibleToken from %FUNGIBLE_TOKEN_ACCOUNT%

transaction(receiverAddress: Address, amount: UFix64) {
  let vault: @FungibleToken.Vault
  prepare(authorizer: AuthAccount) {
    let senderVaultRef = authorizer.borrow<&AnyResource{FungibleToken.Provider}>(from: /storage/flowTokenVault) ?? panic("Couldn't borrow /storage/flowFungibleToken from sender.")
    self.vault <- senderVaultRef.withdraw(amount: amount)
  }
  execute {
    let receiver = getAccount(receiverAddress)
    let receiverCapability = receiver.getCapability(/public/flowTokenReceiver)
    let receiverVaultRef = receiverCapability.borrow<&AnyResource{FungibleToken.Receiver}>() ?? panic("Couldn't borrow /public/flowTokenReceiver from receiver.")
    receiverVaultRef.deposit(from: <- self.vault)
  }
}