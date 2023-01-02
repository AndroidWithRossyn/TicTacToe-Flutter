class CreateUser {
  final username;
  final userid;
  final matchplayed;
  final matchWon;
  final profilePic;
  final coin;
  final score;
  final type;

  CreateUser(
      {this.username,
      this.userid,
      this.matchplayed,
      this.matchWon,
      this.profilePic,
      this.coin,
      this.score,
      this.type});

  Map<String, dynamic> map() {
    return {
      "username": username,
      "userid": userid,
      "matchplayed": matchplayed,
      "matchwon": matchWon,
      "profilePic": profilePic,
      "coin": this.coin != null ? this.coin : 500,
      "score": this.score != null ? this.score : 0,
      "type": this.type
    };
  }
}
