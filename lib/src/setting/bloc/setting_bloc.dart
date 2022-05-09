import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scim/src/auth/authentication_repository.dart';
import 'package:scim/src/setting/user_repository.dart';

import '../../auth/models/auth.dart';
import '../../worker/models/models.dart';

part 'setting_event.dart';
part 'setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  //constructor of SettingBloc
  SettingBloc() : super(SettingState()) {
    on<SettingGetUser>(_onGetUser);
  }

  UserRepository userRepository = UserRepository();
  AuthenticationRepository authenticationRepository = AuthenticationRepository();

  void _onGetUser(SettingGetUser event, Emitter<SettingState> emit) async {
    emit(state.copyWith(status: SettingStatus.loading));
    try {
      Auth? auth = await authenticationRepository.getAccountInfo();
      if (auth != null) {
        emit(state.copyWith(status: SettingStatus.success));
        emit(state.copyWith(auth: auth));
      }
    } catch (e) {
      emit(state.copyWith(status: SettingStatus.failure));
    }
  }
}