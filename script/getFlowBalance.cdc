import FungibleToken from %FUNGIBLE_TOKEN_ACCOUNT%
import FlowToken from %FLOW_TOKEN_ACCOUNT%

pub fun main(accountAddress: Address): UFix64 {
  let vaultRef = getAccount(accountAddress)
    .getCapability(/public/flowTokenBalance)
    .borrow<&FlowToken.Vault{FungibleToken.Balance}>()
    ?? panic("Could not borrow Balance reference to the Vault");

  return vaultRef.balance;
}