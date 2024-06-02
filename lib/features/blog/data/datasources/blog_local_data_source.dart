import 'package:blog_flutter/features/blog/data/models/blog_model.dart';
import 'package:hive/hive.dart';

abstract interface class BlogLocalDataSource {
  void uploadLocalBlogs({required List<BlogModel> blogs});
  List<BlogModel> loadBlogs();
}

class BlogLocalDataSourceImpl extends BlogLocalDataSource {
  final Box box;
  BlogLocalDataSourceImpl(this.box);

  @override
  void uploadLocalBlogs({required List<BlogModel> blogs}) {
    box.write(() {
      for (int i = 0; i < blogs.length; i++) {
        box.put(i.toString(), blogs[i].toJson());
      }
    });
  }

  @override
  List<BlogModel> loadBlogs() {
    List<BlogModel> blogs = [];
    box.read(() {
      for (int i = 0; i < box.length; i++) {
        blogs.add(BlogModel.fromjson(box.get(i.toString())));
      }
    });
    return blogs;
  }
}
