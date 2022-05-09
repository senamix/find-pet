
import 'package:bloc_concurrency/bloc_concurrency.dart';
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
    on<WorkerCreatePlan>(_onCreatePlan);
    on<WorkerLoadViewListWork>(_onLoadViewListWork);
    on<WorkerChangeToLoadStatus>(_onChangeLoadStatus);
    on<WorkerChangeToSuccessStatus>(_onChangeSuccessStatus);
    on<WorkerGetListPost>(_onGetListPost);
    on<WorkerGetListPhoto>(_onGetPostPhotoList);
    on<WorkerUploadImage>(_onUploadImages);
    on<WorkerfollowPost>(_onFollowPost);
    on<WorkerGetFollowPost>(_onGetFollowPost);
    on<WorkerGetAllTags>(_onGetAllTags);
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

  void _onCreatePlan(WorkerCreatePlan event, Emitter<WorkerState> emit) async {
    emit(state.copyWith(status: WorkerStatus.loading));
    try {
      Post? plan = await workerRepository.createdNewPlan(event.id, event.name);
      if(plan != null){
        emit(state.copyWith(status: WorkerStatus.created));
      }
    } catch (e) {
      emit(state.copyWith(status: WorkerStatus.failure));
    }
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

  void _onUploadImages(WorkerUploadImage event, Emitter<WorkerState> emit) async {
    emit(state.copyWith(status: WorkerStatus.loading));
    try {
      bool? uploaded = await workerRepository.uploadPlanPhoto();
      if(uploaded != null && uploaded == true){
        emit(state.copyWith(status: WorkerStatus.success));
      }
    } catch (e) {
      emit(state.copyWith(status: WorkerStatus.failure));
    }
  }
}
