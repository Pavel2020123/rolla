import 'dart:convert';

import 'package:crypto/crypto.dart';
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

    final prefs = await SharedPreferences.getInstance();
    final registeredData =
        jsonDecode(prefs.getString('rolla_user_laura@rolla.test')!)
            as Map<String, dynamic>;
    final expectedHash = sha256.convert(utf8.encode('temporal')).toString();
    expect(registeredData['password'], expectedHash);
    expect(registeredData['password'], isNot('temporal'));

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

  test('login compara el hash y rechaza una contraseña incorrecta', () async {
    final provider = AuthProvider();
    await provider.register(
      fullName: 'Laura Gómez',
      email: 'laura@rolla.test',
      password: 'temporal',
    );
    await provider.setRole('athlete');
    await provider.logout();

    expect(
      await provider.login(email: 'laura@rolla.test', password: 'incorrecta'),
      isFalse,
    );
    expect(provider.isAuthenticated, isFalse);

    expect(
      await provider.login(email: 'laura@rolla.test', password: 'temporal'),
      isTrue,
    );
    expect(provider.isAuthenticated, isTrue);
  });

  test(
    'migra una contraseña antigua en texto plano al iniciar sesión',
    () async {
      final legacyUser = UserModel(
        id: 'usr_legacy',
        fullName: 'Usuario Antiguo',
        firstName: 'Usuario',
        lastName: 'Antiguo',
        email: 'legacy@rolla.test',
        password: 'clave-antigua',
        role: 'athlete',
        createdAt: DateTime.utc(2025),
      );
      SharedPreferences.setMockInitialValues({
        'rolla_user_legacy@rolla.test': jsonEncode(legacyUser.toJson()),
      });
      final provider = AuthProvider();
      final prefs = await SharedPreferences.getInstance();

      expect(
        await provider.login(
          email: 'legacy@rolla.test',
          password: 'incorrecta',
        ),
        isFalse,
      );
      final unmigratedData =
          jsonDecode(prefs.getString('rolla_user_legacy@rolla.test')!)
              as Map<String, dynamic>;
      expect(unmigratedData['password'], 'clave-antigua');

      expect(
        await provider.login(
          email: 'legacy@rolla.test',
          password: 'clave-antigua',
        ),
        isTrue,
      );

      final migratedData =
          jsonDecode(prefs.getString('rolla_user_legacy@rolla.test')!)
              as Map<String, dynamic>;
      final expectedHash = sha256
          .convert(utf8.encode('clave-antigua'))
          .toString();
      expect(migratedData['password'], expectedHash);
      expect(RegExp(r'^[a-f0-9]{64}$').hasMatch(expectedHash), isTrue);
    },
  );

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
