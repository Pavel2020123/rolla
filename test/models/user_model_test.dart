import 'package:flutter_test/flutter_test.dart';
import 'package:rolla/models/user_model.dart';

void main() {
  group('UserModel', () {
    test('serializa y deserializa todos sus campos', () {
      final createdAt = DateTime.utc(2026, 8, 14);
      final birthDate = DateTime.utc(2010, 3, 9);
      final user = UserModel(
        id: 'usr_1',
        fullName: 'Laura Gómez',
        firstName: 'Laura',
        lastName: 'Gómez',
        email: 'laura@rolla.test',
        password: 'temporal',
        role: 'athlete',
        schoolId: 'school_1',
        schoolName: 'Ruedas del Norte',
        createdAt: createdAt,
        category: 'Juvenil',
        level: 'Avanzado',
        modality: 'Velocidad',
        photoUrl: '/foto/perfil.jpg',
        birthDate: birthDate,
        participationsCount: 8,
        goldMedals: 3,
        silverMedals: 2,
        bronzeMedals: 1,
      );

      final restored = UserModel.fromJson(user.toJson());

      expect(restored.toJson(), user.toJson());
    });

    test('mantiene compatibilidad con usuarios antiguos', () {
      final user = UserModel.fromJson({
        'id': 'usr_legacy',
        'fullName': 'Ana María Pérez',
        'email': 'ana@rolla.test',
        'password': 'temporal',
        'createdAt': '2025-01-02T03:04:05.000',
      });

      expect(user.firstName, 'Ana');
      expect(user.lastName, 'María Pérez');
      expect(user.category, 'Prejuvenil');
      expect(user.level, 'Principiante');
      expect(user.modality, 'Velocidad');
    });

    test('copyWith permite limpiar campos opcionales', () {
      final user = UserModel(
        id: 'usr_1',
        fullName: 'Laura Gómez',
        firstName: 'Laura',
        lastName: 'Gómez',
        email: 'laura@rolla.test',
        password: 'temporal',
        createdAt: DateTime.utc(2026),
        schoolId: 'school_1',
        schoolName: 'Ruedas del Norte',
        photoUrl: '/foto/perfil.jpg',
      );

      final updated = user.copyWith(
        schoolId: null,
        schoolName: null,
        photoUrl: null,
      );

      expect(updated.schoolId, isNull);
      expect(updated.schoolName, isNull);
      expect(updated.photoUrl, isNull);
    });

    test('detecta si la contraseña requiere migración', () {
      final legacyUser = UserModel(
        id: 'usr_legacy',
        fullName: 'Usuario Antiguo',
        firstName: 'Usuario',
        lastName: 'Antiguo',
        email: 'legacy@rolla.test',
        password: 'texto-plano',
        createdAt: DateTime.utc(2025),
      );
      final hash = List.filled(64, 'a').join();
      final invalidHash = List.filled(64, 'z').join();
      final hashedUser = legacyUser.copyWith(password: hash);

      expect(legacyUser.needsPasswordMigration, isTrue);
      expect(
        legacyUser.copyWith(password: invalidHash).needsPasswordMigration,
        isTrue,
      );
      expect(hashedUser.needsPasswordMigration, isFalse);
      expect(hashedUser.passwordMatches(hash), isTrue);
    });
  });
}
