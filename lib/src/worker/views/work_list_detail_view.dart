import 'package:scim/src/worker/views/views.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';

class WorkListDetailView extends StatefulWidget {
  const WorkListDetailView({Key? key,required this.post}) : super(key: key);
  final Post post;

  @override
  _WorkListDetailViewState createState() => _WorkListDetailViewState();
}

class _WorkListDetailViewState extends State<WorkListDetailView> {

  @override
  Widget build(BuildContext context) {
    return WorkerImageView(info: true, post: widget.post);
  }
}
