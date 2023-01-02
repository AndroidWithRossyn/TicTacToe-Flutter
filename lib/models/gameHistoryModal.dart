class GameHistoryModal {
  final uid;
  final oppornentId;
  final gameId;
  final playedDate;
  final playedStatus;
  final gotCoin;
  final type;

  GameHistoryModal(
      {this.uid,
      this.oppornentId = "not-available",
      this.gameId,
      this.playedDate,
      this.playedStatus,
      this.gotCoin,
      this.type});
  Map toMap() {
    return {
      "oppornentId": this.oppornentId,
      "playedStatus": this.playedStatus,
      "playedDate": this.playedDate,
      "gotCoin": this.gotCoin,
      "type": this.type
    };
  }
}
