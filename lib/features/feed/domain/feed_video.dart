import 'package:flutter/material.dart';

class FeedVideo {
  const FeedVideo({
    required this.creator,
    required this.description,
    required this.likes,
    required this.comments,
    required this.shares,
    required this.color,
  });

  final String creator;
  final String description;
  final int likes;
  final int comments;
  final int shares;
  final Color color;
}
