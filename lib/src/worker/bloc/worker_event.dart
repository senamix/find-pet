
part of 'worker_bloc.dart';

class WorkerEvent extends Equatable{
  const WorkerEvent();

  @override
  List<Object?> get props => [];
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

class WorkerCreatePlan extends WorkerEvent{
  const WorkerCreatePlan(this.id, this.name);
  final String id;
  final String name;
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







class WorkerDeletePlan extends WorkerEvent{
  const WorkerDeletePlan(this.planId, this.assignment);
  final String planId;
  final bool assignment;
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



