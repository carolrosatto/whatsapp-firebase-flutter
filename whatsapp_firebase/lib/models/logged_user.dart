class LoggedUser {
  String userId;
  String name;
  String email;
  String imageUrl;

  LoggedUser(
    this.userId,
    this.name,
    this.email, {
    this.imageUrl = "",
  });

//ToMap é necessário para conseguir salvar no Firebase no formato correto
  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {
      "userId": this.userId,
      "name": this.name,
      "email": this.email,
      "imageUrl": this.imageUrl,
    };
    return map;
  }
}
