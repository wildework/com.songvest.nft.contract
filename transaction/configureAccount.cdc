import SongVest from "../contract/SongVest.cdc"
import NonFungibleToken from "../contract/NonFungibleToken.cdc"

transaction {
  let accountAddress: Address
  
  prepare(account: AuthAccount) {
    if account.borrow<&SongVest.Collection>(from: SongVest.CollectionStoragePath) == nil {
      let collection <- SongVest.createEmptyCollection()
      account.save(<- collection, to: SongVest.CollectionStoragePath)
      account.link<&SongVest.Collection{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, SongVest.SongCollection}>(
        SongVest.CollectionPublicPath,
        target: SongVest.CollectionStoragePath
      )
    }

    self.accountAddress = account.address;
  }
  post {
    getAccount(self.accountAddress)
      .getCapability<&AnyResource{NonFungibleToken.Receiver, NonFungibleToken.CollectionPublic, SongVest.SongCollection}>(SongVest.CollectionPublicPath)
      .check() : "Collection reference was not created correctly."
  }
}