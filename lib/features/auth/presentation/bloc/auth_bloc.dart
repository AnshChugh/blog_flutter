import 'package:blog_flutter/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blog_flutter/core/usecase/usecase.dart';
import 'package:blog_flutter/core/common/entities/user.dart';
import 'package:blog_flutter/features/auth/domain/usecases/current_user.dart';
import 'package:blog_flutter/features/auth/domain/usecases/user_log_in.dart';
import 'package:blog_flutter/features/auth/domain/usecases/user_sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserLogin _userLogIn;
  final CurrentUser _currentUser;
  final AppUserCubit _appUserCubit;
  AuthBloc(
      {required UserSignUp userSignUp,
      required UserLogin userLogin,
      required CurrentUser currentUser,
      required AppUserCubit appUserCubit})
      : _userSignUp = userSignUp,
        _userLogIn = userLogin,
        _currentUser = currentUser,
        _appUserCubit = appUserCubit,
        super(AuthInitial()) {
    on<AuthEvent>((_, emit) => emit(AuthLoading()));
    on<AuthSignUp>(_onAuthSignUp);
    on<AuthLogin>(_onAuthLogin);
    on<AuthIsUserLoggedIn>(_isUserLoggedIn);
  }

  void _onAuthSignUp(AuthSignUp event, Emitter<AuthState> emit) async {
    final response = await _userSignUp(UserSignUpParams(
        email: event.email, name: event.name, password: event.password));

    response.fold((l) => emit(AuthFailure(message: l.message)),
        (user) => _emitAuthSucess(user, emit));
  }

  void _onAuthLogin(AuthLogin event, Emitter<AuthState> emit) async {
    final response = await _userLogIn(
        UserLoginParams(email: event.email, password: event.password));

    response.fold((l) => emit(AuthFailure(message: l.message)),
        (user) => _emitAuthSucess(user, emit));
  }

  void _isUserLoggedIn(
    AuthIsUserLoggedIn event,
    Emitter<AuthState> emit,
  ) async {
    final res = await _currentUser(NoParams());
    res.fold((l) => emit(AuthFailure(message: l.message)),
        (user) => _emitAuthSucess(user, emit));
  }

  void _emitAuthSucess(User user, Emitter<AuthState> emit) {
    emit(AuthSucess(user: user));
    _appUserCubit.updateUser(user);
  }
}
