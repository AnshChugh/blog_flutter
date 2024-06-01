import 'dart:io';

import 'package:blog_flutter/core/error/exceptions.dart';
import 'package:blog_flutter/core/error/failures.dart';
import 'package:blog_flutter/features/blog/data/models/blog_model.dart';
import 'package:blog_flutter/features/blog/data/datasources/blog_remote_data_source.dart';
import 'package:blog_flutter/features/blog/domain/entities/blog.dart';
import 'package:blog_flutter/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

class BlogRepositoryImpl implements BlogRepository {
  final BlogRemoteDataSource blogRemoteDataSource;
  BlogRepositoryImpl(this.blogRemoteDataSource);

  @override
  Future<Either<Failure, Blog>> uploadBlog({
    required File image,
    required String title,
    required String content,
    required String posterId,
    required List<String> topics,
  }) async {
    try {
      BlogModel blogModel = BlogModel(
        id: const Uuid().v1(),
        posterId: posterId,
        title: title,
        content: content,
        imageUrl: '',
        topics: topics,
        updatedAt: DateTime.now(),
      );

      final imageUrl = await blogRemoteDataSource.uploadBlogImage(
          image: image, blog: blogModel);

      blogModel = blogModel.copyWith(imageUrl: imageUrl);

      blogModel = await blogRemoteDataSource.uploadBlog(blogModel);

      return right(blogModel);
    } on ServerException catch (e) {
      return left(Failure(e.toString()));
    }
  }
}
