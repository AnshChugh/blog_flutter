import 'package:blog_flutter/core/error/exceptions.dart';
import 'package:blog_flutter/features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:firebase_auth/firebase_auth.dart";

abstract interface class AuthRemoteDataSource {
  Future<UserModel> signUpWithEmailPassword(
      {required String name, required String email, required String password});
  Future<UserModel> loginWithEmailPassword(
      {required String email, required String password});
  Future<UserModel?> getCurrentUserData();
}

class FirebaseRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth firebaseAuthInstance;
  final FirebaseFirestore firestoreInstance;
  FirebaseRemoteDataSourceImpl(
      this.firebaseAuthInstance, this.firestoreInstance);
  @override
  Future<UserModel> signUpWithEmailPassword(
      {required String name,
      required String email,
      required String password}) async {
    try {
      await firebaseAuthInstance.createUserWithEmailAndPassword(
          email: email, password: password);
      await firebaseAuthInstance.currentUser!.updateDisplayName(name);
      await firebaseAuthInstance.currentUser!.reload();
      final currentUser = firebaseAuthInstance.currentUser!;
      UserModel user = UserModel(
          id: currentUser.uid,
          name: currentUser.displayName!,
          email: currentUser.email!);
      await firestoreInstance
          .collection('users')
          .doc(user.id)
          .set(user.toMap());
      return user;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel> loginWithEmailPassword(
      {required String email, required String password}) async {
    try {
      final userCred = await firebaseAuthInstance.signInWithEmailAndPassword(
          email: email, password: password);
      UserModel user = UserModel(
          id: userCred.user!.uid,
          name: userCred.user!.displayName!,
          email: userCred.user!.email!);
      return user;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserModel?> getCurrentUserData() async {
    try {
      if (firebaseAuthInstance.currentUser != null) {
        final userSnapshot = await firestoreInstance
            .collection('users')
            .doc(firebaseAuthInstance.currentUser!.uid)
            .get();
        final user = UserModel.fromMap(userSnapshot.data()!);
        return user;
      }

      return null;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
