import 'package:blog_flutter/core/error/exceptions.dart';
import "package:firebase_auth/firebase_auth.dart";

abstract interface class AuthRemoteDataSource {
  Future<String> signUpWithEmailPassword(
      {required String name, required String email, required String password});
  Future<String> loginWithEmailPassword(
      {required String email, required String password});
}

class FirebaseRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuthInstance;
  FirebaseRemoteDataSourceImpl(this.firebaseAuthInstance);
  @override
  Future<String> signUpWithEmailPassword(
      {required String name,
      required String email,
      required String password}) async {
    try {
      final userCredentials = await firebaseAuthInstance
          .createUserWithEmailAndPassword(email: email, password: password);
      await userCredentials.user?.updateDisplayName(name);
      await userCredentials.user?.reload();
      return userCredentials.user!.uid;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> loginWithEmailPassword(
      {required String email, required String password}) {
    //TODO: Implement LoginWithEmailPassword
    throw UnimplementedError();
  }
}
