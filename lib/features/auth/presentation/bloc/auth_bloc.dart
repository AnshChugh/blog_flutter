import 'package:blog_flutter/features/auth/domain/entities/user.dart';
import 'package:blog_flutter/features/auth/domain/usecases/user_log_in.dart';
import 'package:blog_flutter/features/auth/domain/usecases/user_sign_up.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserSignUp _userSignUp;
  final UserLogin _userLogIn;
  AuthBloc({required UserSignUp userSignUp, required UserLogin userLogin})
      : _userSignUp = userSignUp,
        _userLogIn = userLogin,
        super(AuthInitial()) {
    on<AuthSignUp>(_onAuthSignUp);

    on<AuthLogin>(_onAuthLogin);
  }

  void _onAuthSignUp(AuthSignUp event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final response = await _userSignUp(UserSignUpParams(
        email: event.email, name: event.name, password: event.password));

    response.fold((l) => emit(AuthFailure(message: l.message)),
        (user) => emit(AuthSucess(user: user)));
  }

  void _onAuthLogin(AuthLogin event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final response = await _userLogIn(
        UserLoginParams(email: event.email, password: event.password));

    response.fold((l) => emit(AuthFailure(message: l.message)),
        (user) => emit(AuthSucess(user: user)));
  }
}
