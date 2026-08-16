import '../models/athlete_model.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> getUser(String email);

  Future<void> saveUser(UserModel user);

  Future<UserModel?> getCurrentUser();

  Future<String?> getCurrentEmail();

  Future<String?> getCurrentRole();

  Future<void> setCurrentEmail(String email);

  Future<void> saveSession(UserModel user);

  Future<void> clearSession();

  Future<bool> assignSchoolToUser({
    required String email,
    required String? schoolId,
    required String? schoolName,
  });

  Future<AthleteModel?> getCachedAthlete();

  Future<void> saveCachedAthlete(AthleteModel athlete);

  Future<void> savePublicAthlete(AthleteModel athlete);

  Future<AthleteModel?> getPublicAthlete(String email);

  Future<bool> updatePassword(String email, String newPasswordHash);  

}
