import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class GetUserInfo {
  FirebaseDatabase _db = FirebaseDatabase.instance;

  getCoin() async {
    DatabaseEvent snap = await _db
        .ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .once();
    var val = (snap.snapshot.value as Map)["coin"];

    return val;
  }

  getProfilePic() async {
    DatabaseEvent snap = await _db
        .ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .once();
    var val = (snap.snapshot.value as Map)["profilePic"];

    return val;
  }

  setProfilePic(var value) async {
       await _db
        .ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .update({"profilePic":value});

  }

  setUsername(var value) async {
    await _db
        .ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .update({"username":value});
  }

  getFieldValue(String fieldname) async {
    DatabaseEvent snap = await _db
        .ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .once();
    var val = (snap.snapshot.value as Map)[fieldname];

    return val;
  }

  Future detectChange(String field, Function(dynamic value) callBack) async {
    dynamic _coin = 0;
    _db
        .ref()
        .child("users")
        .child(FirebaseAuth.instance.currentUser!.uid)
        .onChildChanged
        .listen((DatabaseEvent ev) {
      if (ev.snapshot.key == "$field") {
        _coin = ev.snapshot.value;
     
        if (callBack != null) {
          callBack(ev.snapshot.value);
        }
      }
    });
    return _coin;
  }
}
