class Message {
  String userId;
  String text;
  String date;

  Message(
    this.userId,
    this.text,
    this.date,
  );

//ToMap é necessário para conseguir salvar no Firebase no formato correto
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "userId": this.userId,
      "text": this.text,
      "date": this.date,
    };
    return map;
  }
}
