import SongVest from "../contract/SongVest.cdc"

transaction(seriesNumber: UInt, serialNumber: UInt, recipientAddress: Address) {
    let song: @SongVest.Song

    prepare(account: AuthAccount) {
        let collectionRef = account.borrow<&SongVest.Collection>(from: /storage/SongVestCollection) ?? panic ("Account doesn't have a SongVest.Collection.")
        self.song <- collectionRef.remove(series: seriesNumber, serialNumber: serialNumber, senderAddress: account.address)
    }
    execute {
        let recipient = getAccount(recipientAddress)

        let recipientCollectionReceiverRef = recipient.getCapability<&AnyResource{SongVest.CollectionReceiver}>(/public/SongVestCollectionReceiver).borrow() ?? panic("Recipient doesn't have a SongVest.Collection")
        recipientCollectionReceiverRef.add(song: <- self.song, receiverAddress: recipientAddress)
    }
}