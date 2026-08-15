import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:rolla/models/user_model.dart';
import 'package:rolla/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('registro, rol y sesión usan UserModel', () async {
    final provider = AuthProvider();

    expect(
      await provider.register(
        fullName: 'Laura Gómez',
        email: 'laura@rolla.test',
        password: 'temporal',
      ),
      isTrue,
    );
    await provider.setRole('athlete');

    expect(provider.user, isA<UserModel>());
    expect(provider.user?.firstName, 'Laura');
    expect(provider.user?.lastName, 'Gómez');
    expect(provider.role, 'athlete');

    final restoredProvider = AuthProvider();
    expect(await restoredProvider.checkSession(), isTrue);
    expect(restoredProvider.user, isA<UserModel>());
    expect(restoredProvider.user?.email, 'laura@rolla.test');
  });

  test('actualiza el perfil y permite abandonar la escuela', () async {
    final provider = AuthProvider();
    await provider.register(
      fullName: 'Laura Gómez',
      email: 'laura@rolla.test',
      password: 'temporal',
    );
    await provider.setRole('athlete');
    await provider.assignSchool('school_1', 'Ruedas del Norte');
    await provider.updateAthleteProfile(
      firstName: 'Laurita',
      category: 'Juvenil',
      birthDate: DateTime.utc(2010, 3, 9),
    );

    expect(provider.user?.fullName, 'Laurita Gómez');
    expect(provider.user?.schoolId, 'school_1');
    expect(provider.user?.category, 'Juvenil');

    await provider.leaveSchool();

    expect(provider.user?.schoolId, isNull);
    expect(provider.user?.schoolName, isNull);

    final prefs = await SharedPreferences.getInstance();
    final storedUser = UserModel.fromJson(
      jsonDecode(prefs.getString('rolla_user')!) as Map<String, dynamic>,
    );
    expect(storedUser.schoolId, isNull);
    expect(storedUser.firstName, 'Laurita');
  });
}
