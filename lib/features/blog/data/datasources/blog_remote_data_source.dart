import 'dart:io';

import 'package:blog_flutter/core/error/exceptions.dart';
import 'package:blog_flutter/features/blog/data/models/blog_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract interface class BlogRemoteDataSource {
  Future<BlogModel> uploadBlog(BlogModel blog);
  Future<String> uploadBlogImage(
      {required File image, required BlogModel blog});
}

class BlogRemoteDataSourceImpl extends BlogRemoteDataSource {
  final FirebaseFirestore firestoreClient;
  final FirebaseStorage firebaseStorage;
  BlogRemoteDataSourceImpl(this.firestoreClient, this.firebaseStorage);
  @override
  Future<BlogModel> uploadBlog(BlogModel blog) async {
    try {
      await firestoreClient.collection('posts').doc(blog.id).set(blog.toMap());
      return blog;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadBlogImage(
      {required File image, required BlogModel blog}) async {
    try {
      Reference ref = firebaseStorage.ref();
      ref = ref.child('blogImages').child(blog.posterId).child(blog.id);
      UploadTask uploadTask = ref.putFile(image);
      TaskSnapshot snap = await uploadTask;
      String downloadUrl = await snap.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
