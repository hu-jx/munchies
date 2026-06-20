// ignore_for_file: non_constant_identifier_names

import 'package:frontend_munchies/models/user_profile.dart';

class FriendRequest {
  final String mongo_id;
  final UserProfile senderId;
  final String receiverId;
  final String status;

  const FriendRequest({
    required this.mongo_id,
    required this.senderId,
    required this.receiverId,
    required this.status,

  });

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(
      mongo_id: json['_id']?.toString() ?? '',
      senderId: UserProfile.fromJson(json['sender_id']),
      receiverId: json['receiver_id']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }
}
