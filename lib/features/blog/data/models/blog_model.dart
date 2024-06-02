import 'dart:convert';

import 'package:blog_flutter/features/blog/domain/entities/blog.dart';

class BlogModel extends Blog {
  BlogModel(
      {required super.id,
      required super.posterId,
      required super.title,
      required super.content,
      required super.imageUrl,
      required super.topics,
      required super.updatedAt,
      super.posterName});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'posterId': posterId,
      'title': title,
      'content': content,
      'imageUrl': imageUrl,
      'topics': topics,
      'updatedAt': updatedAt.toIso8601String()
    };
  }

  factory BlogModel.fromMap(Map<String, dynamic> map) {
    return BlogModel(
      id: map['id'] ?? '',
      posterId: map['posterId'] ?? '',
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      topics: List<String>.from(map['topics'] ?? []),
      updatedAt: map['updatedAt'] == null
          ? DateTime.now()
          : DateTime.parse(map['updatedAt']),
    );
  }

  BlogModel copyWith(
      {String? id,
      String? posterId,
      String? title,
      String? content,
      String? imageUrl,
      List<String>? topics,
      DateTime? updatedAt,
      String? posterName}) {
    return BlogModel(
        id: id ?? this.id,
        posterId: posterId ?? this.posterId,
        title: title ?? this.title,
        content: content ?? this.content,
        imageUrl: imageUrl ?? this.imageUrl,
        topics: topics ?? this.topics,
        updatedAt: updatedAt ?? this.updatedAt,
        posterName: posterName ?? this.posterName);
  }

  String toJson() => jsonEncode(toMap());

  factory BlogModel.fromjson(String source) =>
      BlogModel.fromMap(jsonDecode(source));
}
