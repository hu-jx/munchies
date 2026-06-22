import 'package:flutter/material.dart';

class LikeButton extends StatelessWidget {
  final bool isLiked;
  final VoidCallback onPressed;

  const LikeButton({super.key, required this.isLiked, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Icon(isLiked ? Icons.favorite : Icons.favorite_border_outlined, color: isLiked ? Colors.red : Colors.grey),
    );
  }
}