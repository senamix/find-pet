
part of 'worker_bloc.dart';

class WorkerEvent extends Equatable{
  const WorkerEvent();

  @override
  List<Object?> get props => [];
}

class WorkerSearchPostByConditions extends WorkerEvent{
  WorkerSearchPostByConditions({required this.tags, this.roadLocation, this.fromDate, this.toDate});
  String tags;
  String? roadLocation;
  String? fromDate;
  String? toDate;
}

class WorkerLoadViewListWork extends WorkerEvent{
  const WorkerLoadViewListWork();
}

class WorkerChangeToLoadStatus extends WorkerEvent{
  const WorkerChangeToLoadStatus();
}

class WorkerChangeToSuccessStatus extends WorkerEvent{
  const WorkerChangeToSuccessStatus();
}

class WorkerGetListPost extends WorkerEvent{
  WorkerGetListPost({this.page});
  int? page;
}

class WorkerfollowPost extends WorkerEvent{
  WorkerfollowPost({this.post});
  Post? post;
}

class WorkerGetFollowPost extends WorkerEvent{
  const WorkerGetFollowPost(this.post);
  final Post post;
}

class WorkerGetAllTags extends WorkerEvent{
  const WorkerGetAllTags();
}

class WorkerGetPostByParams extends WorkerEvent{
  WorkerGetPostByParams(this.roadLocation, this.tags);
  String? roadLocation;
  List<Tag>? tags;
}

class WorkerAddPost extends WorkerEvent{
  WorkerAddPost(this.tags, this.images, this.postLocation,this.title, this.content);
  String title;
  String content;
  List<String> tags;
  List<XFile> images;
  PostLocation? postLocation;
}

class WorkerDeletePost extends WorkerEvent{
  const WorkerDeletePost(this.postId);
  final String postId;
}

class WorkerGetListPhoto extends WorkerEvent{
  const WorkerGetListPhoto(this.post);
  final Post post;
}

class WorkerDeletePlanPhoto extends WorkerEvent{
  const WorkerDeletePlanPhoto(this.photoId);
  final String photoId;
}

class WorkerUploadImage extends WorkerEvent{
  const WorkerUploadImage();
}



