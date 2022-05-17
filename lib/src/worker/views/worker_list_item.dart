import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scim/src/utils/convert_date.dart';
import 'package:scim/src/worker/views/work_image_widget.dart';

import '../bloc/worker_bloc.dart';
import '../models/models.dart';

class WorkerListItem extends StatefulWidget {
  const WorkerListItem({Key? key, required this.post}) : super(key: key);
  final Post post;

  @override
  _WorkerListItemState createState() => _WorkerListItemState();
}

class _WorkerListItemState extends State<WorkerListItem> {
  final WorkerBloc _workerBloc = WorkerBloc();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return BlocConsumer<WorkerBloc, WorkerState>(
      bloc: _workerBloc,
      listener: (context, state){
      },
      builder: (context, state){
          return InkWell(
            onTap: () async {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => WorkerImageView(info: true, post: widget.post)));
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              elevation: 2,
              child: Container(
                width: size.width,
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: size.width*0.3,
                        height: size.height*0.15,
                        child: widget.post.photos?.isNotEmpty == true 
                          ? Image.network(widget.post.photos![0].url!)
                          : Image.asset("/assets/images/none.png"),
                      )
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 10, right: 5),
                          child: SizedBox(
                            width: size.width*0.57,
                            child: Text(widget.post.title ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(top: 5)),
                        Container(
                          padding: const EdgeInsets.only(left: 10, right: 5),
                          child: Text(ConvertDate.convertStringToLocalString(widget.post.createdAt ?? '')),
                        ),
                        Container(
                          padding: const EdgeInsets.only(left: 10, right: 5),
                          child: Text(widget.post.postLocation?.location ?? ''),
                        ),
                        const Padding(padding: EdgeInsets.only(top: 10)),
                        Container(
                          padding: const EdgeInsets.only(left: 10, right: 5),
                          child: Row(
                            children: [
                              const Icon(FontAwesomeIcons.solidHeart, color: Colors.red,),
                              Text(' ${widget.post.postParticipants?.length.toString() ?? ''}'),
                              Padding(padding: EdgeInsets.only(left: size.width*0.3)),
                              Container(
                                alignment: Alignment.bottomRight,
                                child: const Icon(FontAwesomeIcons.userCircle),
                              ),
                              Container(
                                alignment: Alignment.bottomRight,
                                child: Text(' ${widget.post.posterName  ?? ''}'),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
      });
  }
}