import 'package:blog_flutter/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:blog_flutter/core/network/connection_checker.dart';
import 'package:blog_flutter/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:blog_flutter/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:blog_flutter/features/auth/domain/repository/auth_repository.dart';
import 'package:blog_flutter/features/auth/domain/usecases/current_user.dart';
import 'package:blog_flutter/features/auth/domain/usecases/user_log_in.dart';
import 'package:blog_flutter/features/auth/domain/usecases/user_sign_up.dart';
import 'package:blog_flutter/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:blog_flutter/features/blog/data/datasources/blog_local_data_source.dart';
import 'package:blog_flutter/features/blog/data/datasources/blog_remote_data_source.dart';
import 'package:blog_flutter/features/blog/data/repositories/blog_repository_impl.dart';
import 'package:blog_flutter/features/blog/domain/repositories/blog_repository.dart';
import 'package:blog_flutter/features/blog/domain/usecases/get_all_blogs.dart';
import 'package:blog_flutter/features/blog/domain/usecases/upload_blog.dart';
import 'package:blog_flutter/features/blog/presentation/bloc/blog_bloc.dart';
import 'package:blog_flutter/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Hive.defaultDirectory = (await getApplicationDocumentsDirectory()).path;
  serviceLocator
    ..registerLazySingleton(() => FirebaseAuth.instance)
    ..registerLazySingleton(() => FirebaseFirestore.instance)
    ..registerLazySingleton(() => FirebaseStorage.instance)
    ..registerLazySingleton(() => Hive.box(name: 'blogs'))
    ..registerFactory(() => InternetConnection())
    ..registerFactory<ConnectionChecker>(
        () => ConnectionCheckerImpl(serviceLocator()));

  //core
  serviceLocator.registerLazySingleton(
    () => AppUserCubit(),
  );
  _initAuth();
  _initBlog();
}

void _initAuth() {
  serviceLocator
    // Datasource
    ..registerFactory<AuthRemoteDataSource>(() => FirebaseRemoteDataSourceImpl(
        serviceLocator<FirebaseAuth>(), serviceLocator<FirebaseFirestore>()))
    ..registerFactory<BlogLocalDataSource>(
        () => BlogLocalDataSourceImpl(serviceLocator()))
    // Repository
    ..registerFactory<AuthRepository>(
        () => AuthRepositoryImpl(serviceLocator(), serviceLocator()))
    // use cases
    ..registerFactory(() => UserSignUp(serviceLocator()))
    ..registerFactory(() => UserLogin(serviceLocator()))
    ..registerFactory(() => CurrentUser(serviceLocator()))
    // Bloc
    ..registerLazySingleton(() => AuthBloc(
        userSignUp: serviceLocator(),
        userLogin: serviceLocator(),
        currentUser: serviceLocator(),
        appUserCubit: serviceLocator()));
}

void _initBlog() {
  serviceLocator
    //data source
    ..registerFactory<BlogRemoteDataSource>(
      () => BlogRemoteDataSourceImpl(serviceLocator(), serviceLocator()),
    )
    // repository
    ..registerFactory<BlogRepository>(
      () => BlogRepositoryImpl(
          serviceLocator(), serviceLocator(), serviceLocator()),
    )
    // usecase
    ..registerFactory(
      () => UploadBlog(serviceLocator()),
    )
    ..registerFactory(() => GetAllBlogs(serviceLocator()))
    // bloc
    ..registerLazySingleton(
      () => BlogBloc(serviceLocator(), serviceLocator()),
    );
}
