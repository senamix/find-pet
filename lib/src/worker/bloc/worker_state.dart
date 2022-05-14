
part of 'worker_bloc.dart';

enum WorkerStatus{
  loading, success, failure, created, deleted
}

class WorkerState extends Equatable{
  WorkerState({
      this.status,
      this.doingPlans = const <Post>[],
      this.searchPosts = const <Post>[],
      this.photos =  const <Photo>[],
      this.tags =  const <Tag>[],
      this.address = '',
      this.hasReachedMax = false,
      this.follow = false,
      this.heart = false,

    });

    WorkerStatus? status;
    final List<Post> doingPlans;
    final List<Post> searchPosts;
    final List<Photo> photos;
    final List<Tag> tags;
    final String address;
    final bool heart;
    final bool hasReachedMax;
    final bool follow;

  WorkerState copyWith({
    WorkerStatus? status,
    List<Post>? doingPlans,
    List<Post>? searchPosts,
    List<Photo>? photos,
    List<Tag>? tags,
    String? address,
    bool? hasReachedMax,
    bool? heart,
    bool? follow,
    }) {
      return WorkerState(
          status: status ?? this.status,
          doingPlans: doingPlans ?? this.doingPlans,
          searchPosts : searchPosts ?? this.searchPosts,
          photos: photos ?? this.photos,
          tags: tags ?? this.tags,
          address : address ?? this.address,
          heart: heart ?? this.heart,
          follow: follow ?? this.follow,
          hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      );
    }

    @override
    List<Object?> get props => [
      status, doingPlans,searchPosts, photos, tags,address, heart, follow, hasReachedMax
    ];
  }
