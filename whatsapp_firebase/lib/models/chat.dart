class Chat {
  String senderId;
  String addresseeId;
  String lastMessage;
  String addresseeName;
  String addresseeEmail;
  String addresseeImageUrl;

  Chat(
    this.senderId,
    this.addresseeId,
    this.lastMessage,
    this.addresseeName,
    this.addresseeEmail,
    this.addresseeImageUrl,
  );

  //ToMap é necessário para conseguir salvar no Firebase no formato correto
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "senderId": this.senderId,
      "addresseeId": this.addresseeId,
      "lastMessage": this.lastMessage,
      "addresseeName": this.addresseeName,
      "addresseeEmail": this.addresseeEmail,
      "addresseeImageUrl": this.addresseeImageUrl,
    };
    return map;
  }
}
