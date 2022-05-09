part of 'setting_bloc.dart';

class SettingEvent extends Equatable{
  const SettingEvent();

  @override
  List<Object?> get props => [];
}

class SettingGetUser extends SettingEvent{
  const SettingGetUser();
}

class SettingGetMyPosts extends SettingEvent{
  const SettingGetMyPosts();
}

class SettingGetUploadPic extends SettingEvent{
  const SettingGetUploadPic();
}