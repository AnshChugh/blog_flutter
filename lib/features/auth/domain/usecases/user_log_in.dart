import 'package:blog_flutter/core/error/failures.dart';
import 'package:blog_flutter/core/usecase/usecase.dart';
import 'package:blog_flutter/core/common/entities/user.dart';
import 'package:blog_flutter/features/auth/domain/repository/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class UserLoginParams {
  final String email;
  final String password;

  UserLoginParams({required this.email, required this.password});
}

class UserLogin implements UseCase<User, UserLoginParams> {
  final AuthRepository authRepository;
  const UserLogin(this.authRepository);
  @override
  Future<Either<Failure, User>> call(UserLoginParams params) async {
    return await authRepository.logInWithEmailPassword(
        email: params.email, password: params.password);
  }
}
