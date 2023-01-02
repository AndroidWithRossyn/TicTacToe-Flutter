import 'package:TicTacToe/Helper/constant.dart';
import 'package:TicTacToe/Helper/utils.dart';
import 'package:flutter/material.dart';

class LifeCycleManager extends StatefulWidget {
  final Widget? child;
  const LifeCycleManager({Key? key, this.child}) : super(key: key);

  @override
  _LifeCycleManagerState createState() => _LifeCycleManagerState();
}

class _LifeCycleManagerState extends State<LifeCycleManager> with WidgetsBindingObserver{

  @override
  void initState() {

    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose() {

    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async{

    if(state == AppLifecycleState.resumed)
      {
        await music.play(backMusic);
      }
    else
      {
        await music.stop();
      }
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      child: widget.child,
    );
  }
}
