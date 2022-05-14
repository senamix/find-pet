
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scim/src/configs/base_config.dart';
import 'package:scim/src/worker/models/models.dart';
import 'package:scim/src/worker/models/tag.dart';
import 'package:stream_transform/stream_transform.dart';

import '../worker_repository.dart';

part 'worker_event.dart';
part 'worker_state.dart';

const throttleDuration = Duration(milliseconds: 100);

EventTransformer<E> throttleDroppable<E>(Duration duration) {
  return (events, mapper) {
    return droppable<E>().call(events.throttle(duration), mapper);
  };
}

class WorkerBloc extends Bloc<WorkerEvent, WorkerState>{
  WorkerBloc() : super(WorkerState()) {
    on<WorkerLoadViewListWork>(_onLoadViewListWork);
    on<WorkerChangeToLoadStatus>(_onChangeLoadStatus);
    on<WorkerChangeToSuccessStatus>(_onChangeSuccessStatus);
    on<WorkerGetListPost>(_onGetListPost);
    on<WorkerGetListPhoto>(_onGetPostPhotoList);
    on<WorkerfollowPost>(_onFollowPost);
    on<WorkerGetFollowPost>(_onGetFollowPost);
    on<WorkerGetAllTags>(_onGetAllTags);
    on<WorkerGetPostByParams>(_onGetPostByParams);
    on<WorkerAddPost>(_onAddPost);
    on<WorkerDeletePost>(_onDeletePost);
    on<WorkerSearchPostByConditions>(_onSearchPostByConditions);
  }

  WorkerRepository workerRepository = WorkerRepository();

  void _onLoadViewListWork(WorkerLoadViewListWork event, Emitter<WorkerState> emit) async{
    emit(state.copyWith(status: WorkerStatus.success));
  }

  void _onChangeLoadStatus(WorkerChangeToLoadStatus event, Emitter<WorkerState> emit) async{
    emit(state.copyWith(status: WorkerStatus.loading));
  }

  void _onChangeSuccessStatus(WorkerChangeToSuccessStatus event, Emitter<WorkerState> emit) async{
    emit(state.copyWith(status: WorkerStatus.success));
  }

  void _onGetListPost(WorkerGetListPost event, Emitter<WorkerState> emit) async {
    emit(state.copyWith(status: WorkerStatus.loading));
    if (state.hasReachedMax) return;
    try {
      if (event.page != null) {
        final plans = await workerRepository.getListPost();
        return emit(state.copyWith(
          status: WorkerStatus.success,
          doingPlans: plans,
          hasReachedMax: false,
        ));
      }

      if(state.doingPlans.length >= BaseConfig.limit){
        List<Post>? plans = await workerRepository.getListPost((state.doingPlans.length ~/ BaseConfig.limit) + 1);
        if(plans != null && plans.isNotEmpty){
          List<Post> planList = List.of(state.doingPlans)..addAll(plans);
          plans.isEmpty ? emit(state.copyWith(hasReachedMax: true))
              : emit(state.copyWith(
            status: WorkerStatus.success,
            doingPlans: planList.toSet().toList(),
            hasReachedMax: false,
          )
          );
        }
      }
    } catch (e) {
      emit(state.copyWith(status: WorkerStatus.failure));
    }
  }

  void _onFollowPost(WorkerfollowPost event, Emitter<WorkerState> emit) async{
    emit(state.copyWith(status: WorkerStatus.loading));
    try {
      bool? follow = await workerRepository.followPost(event.post?.id ?? '');
      if(follow != null && follow == true){
        emit(state.copyWith(
          status: WorkerStatus.success,
          heart: true,
        )
        );
      }
    } catch (e) {
      emit(state.copyWith(status: WorkerStatus.failure));
    }
  }

  void _onDeletePost(WorkerDeletePost event, Emitter<WorkerState> emit) async{
    emit(state.copyWith(status: WorkerStatus.loading));
    try {
      bool? deleted = await workerRepository.deletePost(event.postId ?? '');
      if(deleted != null && deleted == true){
        emit(state.copyWith(status: WorkerStatus.deleted));
      }
    } catch (e) {
      emit(state.copyWith(status: WorkerStatus.failure));
    }
  }

  void _onSearchPostByConditions(WorkerSearchPostByConditions event, Emitter<WorkerState> emit) async {
    emit(state.copyWith(status: WorkerStatus.loading));
    try {
      //ng nam
      List<String> tags = event.tags.split(",");
      tags.addAll([',',',',',',',',',']);
      List<Post>? posts = await workerRepository.getSearchByConditions(roadLocation: event.roadLocation, tags: tags);
      if(posts != null){
        emit(state.copyWith(
          status: WorkerStatus.success,
          doingPlans: posts.toSet().toList(),
          )
        );
      }
    } catch (e) {
      emit(state.copyWith(status: WorkerStatus.failure));
    }
  }

  void _onGetPostPhotoList(WorkerGetListPhoto event, Emitter<WorkerState> emit) async {
    emit(state.copyWith(status: WorkerStatus.loading));
    try {
      List<Photo>? photos = await workerRepository.getListPhotoPlan(event.post.id ?? '');
      if(photos != null && photos.isNotEmpty){
        emit(state.copyWith(
          status: WorkerStatus.success,
          photos: photos,
          hasReachedMax: false,
        )
        );
      }
    } catch (e) {
      emit(state.copyWith(status: WorkerStatus.failure));
    }
  }

  void _onGetFollowPost(WorkerGetFollowPost event, Emitter<WorkerState> emit) async {
    emit(state.copyWith(status: WorkerStatus.loading));
    try{
      final follow = await workerRepository.getFollowPost(event.post.id ?? '');
      if(follow != null && follow == true){
        return emit(state.copyWith(
          status: WorkerStatus.success,
          follow: true,
        ));
      }
    }catch (e) {
      emit(state.copyWith(status: WorkerStatus.failure));
    }
  }

  void _onGetAllTags(WorkerGetAllTags event, Emitter<WorkerState> emit) async {
    emit(state.copyWith(status: WorkerStatus.loading));
    try{
      final tags = await workerRepository.getAllTags();
      if(tags != null){
        return emit(state.copyWith(
          status: WorkerStatus.success,
          tags: tags,
        ));
      }
    }catch (e) {
      emit(state.copyWith(status: WorkerStatus.failure));
    }
  }

  void _onGetPostByParams(WorkerGetPostByParams event, Emitter<WorkerState> emit) async {
    emit(state.copyWith(status: WorkerStatus.loading));
    try{
      final tags = await workerRepository.getAllTags();
      if(tags != null){
        return emit(state.copyWith(
          status: WorkerStatus.success,
          tags: tags,
        ));
      }
    }catch (e) {
      emit(state.copyWith(status: WorkerStatus.failure));
    }
  }

  //ng nam
  void _onAddPost(WorkerAddPost event, Emitter<WorkerState> emit) async {
    emit(state.copyWith(status: WorkerStatus.loading));
    try{
      final tags = await workerRepository.createNewPost(event.images, event.postLocation, event.title, event.content, event.tags);
      if(tags != null){
        emit(state.copyWith(status: WorkerStatus.created));
      }
    }catch (e) {
      emit(state.copyWith(status: WorkerStatus.failure));
    }
  }
}
