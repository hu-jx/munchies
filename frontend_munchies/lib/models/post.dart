import 'package:frontend_munchies/models/record.dart';
import 'package:frontend_munchies/models/user_profile.dart';

class Post {
  final Record record;
  final UserProfile posterProfile;
  bool isLiked;
  int count;

  Post({
    required this.record,
    required this.posterProfile,
    required this.isLiked,
    required this.count,
  });

}