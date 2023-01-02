import 'package:TicTacToe/models/gameHistoryModal.dart';
import 'package:firebase_database/firebase_database.dart';

class History {
  final FirebaseDatabase _db = FirebaseDatabase.instance;
  void update({gameid, required uid, date, status, gotcoin, oppornentId, type}) {
    GameHistoryModal modal = GameHistoryModal(
        gameId: gameid,
        gotCoin: gotcoin,
        oppornentId: oppornentId,
        playedDate: date,
        playedStatus: status,
        type: type,
        uid: uid);


    _db
        .ref()
        .child("gameHistory")
        .child(uid)
        .child("played")
        .push()
        .set(modal.toMap())
        .onError((dynamic error, stackTrace) {
     
    });
  }
}
