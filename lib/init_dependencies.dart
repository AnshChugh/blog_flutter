import 'package:blog_flutter/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:blog_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:blog_flutter/features/auth/domain/repository/auth_repository.dart';
import 'package:blog_flutter/features/auth/domain/usecases/user_log_in.dart';
import 'package:blog_flutter/features/auth/domain/usecases/user_sign_up.dart';
import 'package:blog_flutter/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blog_flutter/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  serviceLocator.registerLazySingleton(() => FirebaseAuth.instance);
  serviceLocator.registerLazySingleton(() => FirebaseFirestore.instance);
  _initAuth();
}

void _initAuth() {
  serviceLocator.registerFactory<AuthRemoteDataSource>(() =>
      FirebaseRemoteDataSourceImpl(
          serviceLocator<FirebaseAuth>(), serviceLocator<FirebaseFirestore>()));

  serviceLocator.registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(serviceLocator()));

  serviceLocator.registerFactory(() => UserSignUp(serviceLocator()));
  serviceLocator.registerFactory(() => UserLogin(serviceLocator()));

  serviceLocator.registerLazySingleton(() =>
      AuthBloc(userSignUp: serviceLocator(), userLogin: serviceLocator()));
}
