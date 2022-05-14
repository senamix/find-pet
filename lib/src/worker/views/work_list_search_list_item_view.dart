import 'package:flutter/cupertino.dart';
import 'package:scim/src/worker/views/views.dart';

import '../models/models.dart';

class WorkListSearchListItemView extends StatelessWidget {
  const WorkListSearchListItemView({Key? key, required this.posts}) : super(key: key);
  final List<Post> posts;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: posts.map((post){
          return WorkerListItem(post: post);
        }).toList(),
      ),
    );
  }
}
