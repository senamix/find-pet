import 'package:flutter/material.dart';

class DialogWidget {
  static void flutterDialog(BuildContext context,{String title = "알림",
    String content = "Alert",String buttonText = "확인"}) {
      showDialog(
        context: context,
        //barrierDismissible - Dialog를 제외한 다른 화면 터치 x
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            // RoundedRectangleBorder - Dialog 화면 모서리 둥글게 조절
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0)),
            //Dialog Main Title
            title: Column(
              children: <Widget>[
                Text(title),
              ],
            ),
            //
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(content),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                child: Text(buttonText),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        }
      );
  }

  static void flutterSnackBar(BuildContext context, {String content = ""}){
    final snackBar = SnackBar(
      content: Text(content),
      action: SnackBarAction(
        label: 'OK',
        onPressed: () {
          // Some code to undo the change.
        },
      ),
    );
    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void flutterNotify(BuildContext context,
  {String title = "공지사항",String content = "Alert",String buttonNoView = "더 이상 보지 않기",String buttonText = "확인"}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext contextDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            title: Column(
              children: <Widget>[
                Text(title),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(content),
              ],
            ),
            actions: <Widget>[
              ElevatedButton(
                child: Text(buttonNoView),
                onPressed: () async {
                },
              ),
              ElevatedButton(
                child: Text(buttonText),
                onPressed: () async {
                },
              ),
            ],
          );
        }
    );
  }
}