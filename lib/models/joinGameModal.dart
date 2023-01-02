class JoinModel {
  final String? player1;
  final String? player2;
  final String? status;
  final String? time;
  final int? entryFee, round;

  JoinModel(
      {this.player1,
      this.player2,
      this.status,
      this.time,
      this.entryFee,
      this.round});

  factory JoinModel.fromJson(json) {

    String? player2="";

   if(json.containsKey("player2"))
     {
       player2=json["player2"]["id"];
     }
    return JoinModel(
        entryFee: json["entryFee"],
        player1: json["player1"]["id"],
        player2:player2,
        status: json["status"],
        time: json["time"],
        round: json["round"]);
  }
}
