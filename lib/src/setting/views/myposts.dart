import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../auth/models/models.dart';

class MyPosts extends StatelessWidget {
  MyPosts({Key? key, this.auth}) : super(key: key);
  Auth? auth;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          title:  const Text("나의 정보"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              {
                Navigator.pop(context);
              }
            },
          )
      ),
      body: Card(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.all(size.width*0.04),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(auth?.displayName ?? '')
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
