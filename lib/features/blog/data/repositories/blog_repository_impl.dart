import 'dart:io';

import 'package:blog_flutter/core/error/exceptions.dart';
import 'package:blog_flutter/core/error/failures.dart';
import 'package:blog_flutter/core/network/connection_checker.dart';
import 'package:blog_flutter/features/blog/data/datasources/blog_local_data_source.dart';
import 'package:blog_flutter/features/blog/data/models/blog_model.dart';
import 'package:blog_flutter/features/blog/data/datasources/blog_remote_data_source.dart';
import 'package:blog_flutter/features/blog/domain/entities/blog.dart';
import 'package:blog_flutter/features/blog/domain/repositories/blog_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

class BlogRepositoryImpl implements BlogRepository {
  final BlogRemoteDataSource blogRemoteDataSource;
  final BlogLocalDataSource blogLocalDataSource;
  final ConnectionChecker connectionChecker;
  BlogRepositoryImpl(this.blogRemoteDataSource, this.blogLocalDataSource,
      this.connectionChecker);

  @override
  Future<Either<Failure, Blog>> uploadBlog({
    required File image,
    required String title,
    required String content,
    required String posterId,
    required List<String> topics,
  }) async {
    try {
      if (!await (connectionChecker.isConnected)) {
        return left(Failure('No Internet Connection'));
      }
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

  @override
  Future<Either<Failure, List<Blog>>> getAllBlogs() async {
    try {
      if (!await (connectionChecker.isConnected)) {
        final blogs = blogLocalDataSource.loadBlogs();
        return right(blogs);
      }
      final blogs = await blogRemoteDataSource.getAllBlogs();
      blogLocalDataSource.uploadLocalBlogs(blogs: blogs);
      return Right(blogs);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
