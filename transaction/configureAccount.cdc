import SongVest from "../contract/SongVest.cdc"

transaction {
  let accountAddress: Address
  
  prepare(account: AuthAccount) {
    let collection <- SongVest.createCollection()
    if collection.songs.length != 0 {
      panic("Collection size incorrect, needs to be empty.")
    }
    account.save(<- collection, to: /storage/SongVestCollection)
    account.link<&AnyResource{SongVest.CollectionReceiver}>(
      /public/SongVestCollectionReceiver,
      target: /storage/SongVestCollection
    )

    self.accountAddress = account.address;
  }
  post {
    getAccount(self.accountAddress)
      .getCapability<&AnyResource{SongVest.CollectionReceiver}>(/public/SongVestCollectionReceiver)
      .check() : "Collection receiver reference was not created correctly."
  }
}