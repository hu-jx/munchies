import 'package:frontend_munchies/models/user_profile.dart';

abstract class AuthServicesRepo {
   Future<UserProfile> fetchProfileData(String idToken);
   Future<void> createProfile(String idToken, UserProfile profile);
}