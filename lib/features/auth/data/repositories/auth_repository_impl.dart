import 'package:blog_flutter/core/error/exceptions.dart';
import 'package:blog_flutter/core/error/failures.dart';
import 'package:blog_flutter/core/network/connection_checker.dart';
import 'package:blog_flutter/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:blog_flutter/core/common/entities/user.dart';
import 'package:blog_flutter/features/auth/data/models/user_model.dart';
import 'package:blog_flutter/features/auth/domain/repository/auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:fpdart/fpdart.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final ConnectionChecker connectionChecker;
  AuthRepositoryImpl(this.remoteDataSource, this.connectionChecker);

  @override
  Future<Either<Failure, User>> currentUser() async {
    try {
      if (!(await connectionChecker.isConnected)) {
        final user = remoteDataSource.currentUser;
        if (user == null) {
          return left(Failure('User Not logged In'));
        }
        return right(
            UserModel(id: user.id, name: user.name, email: user.email));
      }
      final user = await remoteDataSource.getCurrentUserData();
      if (user == null) {
        return left(Failure('user not logged in'));
      }
      return right(user);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }

  @override
  Future<Either<Failure, User>> logInWithEmailPassword(
      {required String email, required String password}) async {
    return _getUser(() async => await remoteDataSource.loginWithEmailPassword(
        email: email, password: password));
  }

  @override
  Future<Either<Failure, User>> signUpWithEmailPassword(
      {required String name,
      required String email,
      required String password}) async {
    return _getUser(() async => await remoteDataSource.signUpWithEmailPassword(
        name: name, email: email, password: password));
  }

  Future<Either<Failure, User>> _getUser(Future<User> Function() fn) async {
    try {
      if (!(await connectionChecker.isConnected)) {
        return left(Failure('No Internet Connection'));
      }
      final user = await fn();
      return Right(user);
    } on fb.FirebaseAuthException catch (e) {
      return Left(Failure(e.message!));
    } on ServerException catch (e) {
      return Left(Failure(e.message));
    }
  }
}
