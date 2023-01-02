class CreateGame {
  final String? player1;
  final String? tryy;
  final int? entryfee;
  final int? round;

  const CreateGame({
    this.player1,
    this.tryy,
    this.entryfee,
    this.round
  });




  Map toMap() {
    return {
      "player1": {
        "id": player1,
        "won": 0
      },
      "try": tryy,
      //"time": DateTime.now().toIso8601String(),
      "time": DateTime.now().toString(),
      "entryFee": entryfee,
      "round":round,
      "buttons": {
        "0": {
          "state": "",
          "player": "0",
        },
        "1": {
          "state": "",
          "player": "0",
        },
        "2": {
          "state": "",
          "player": "0",
        },
        "3": {
          "state": "",
          "player": "0",
        },
        "4": {
          "state": "",
          "player": "0",
        },
        "5": {
          "state": "",
          "player": "0",
        },
        "6": {
          "state": "",
          "player": "0",
        },
        "7": {
          "state": "",
          "player": "0",
        },
        "8": {
          "state": "",
          "player": "0",
        }
      },
      "status": "pending",
      "won": "",
      "tie": 0
    };
  }
}
