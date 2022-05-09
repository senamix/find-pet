part of 'setting_bloc.dart';

enum SettingStatus{
  loading, success, failure
}

class SettingState extends Equatable{
  SettingState({
    this.status,this.auth, this.posts
  });

  SettingStatus? status;
  Auth? auth;
  List<Post>? posts;

  SettingState copyWith({
    SettingStatus? status,
    Auth? auth,
    List<Post>? posts
  }) {
    return SettingState(
      status: status ?? this.status,
      auth: auth ?? this.auth,
      posts: posts ?? this.posts
    );
  }

  @override
  List<Object?> get props => [
    status, auth, posts
  ];
}
