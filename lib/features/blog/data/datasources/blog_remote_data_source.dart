import 'dart:io';

import 'package:blog_flutter/core/error/exceptions.dart';
import 'package:blog_flutter/features/blog/data/models/blog_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

abstract interface class BlogRemoteDataSource {
  Future<BlogModel> uploadBlog(BlogModel blog);
  Future<String> uploadBlogImage(
      {required File image, required BlogModel blog});
  Future<List<BlogModel>> getAllBlogs();
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

  @override
  Future<List<BlogModel>> getAllBlogs() async {
    try {

      // chatgpt thanks for reducing database requests to two

      final snaps = await firestoreClient.collection('posts').get();
      final docs = snaps.docs;

       // Step 2: Collect unique poster IDs
    final posterIds = docs.map((doc) => doc.data()['posterId']).toSet();
    
    // Step 3: Fetch all users' data for those poster IDs in a single batched request
    final usersSnap = await firestoreClient
        .collection('users')
        .where(FieldPath.documentId, whereIn: posterIds.toList())
        .get();
    
    // Create a map of user ID to user data for quick lookup
    final Map<String, dynamic> usersData = {
      for (var userDoc in usersSnap.docs) userDoc.id: userDoc.data(),
    };
    
    // Step 4: Map posts to BlogModel instances using the fetched users' data
    final List<BlogModel> blogs = docs.map((doc) {
      final data = doc.data();
      final posterId = data['posterId'];
      final posterName = usersData[posterId]?['name'] ?? 'Unknown';  // Handle case where name might not be found
      BlogModel blogModel = BlogModel.fromMap(data);
      return blogModel.copyWith(posterName: posterName);
    }).toList();
    
    return blogs;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
