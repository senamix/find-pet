import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmptyDataView extends StatelessWidget {
  const EmptyDataView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(child: Card(
      elevation: 1,
      child: Container(
        padding: const EdgeInsets.only(top: 15, right: 5, bottom: 15, left: 5,),
        child: const Text('데이터가 없습니다.'),
      ),
    )
    );
  }
}
