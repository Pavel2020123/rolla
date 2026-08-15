import 'package:flutter_test/flutter_test.dart';
import 'package:rolla/models/athlete_model.dart';
import 'package:rolla/models/event_model.dart';
import 'package:rolla/models/notification_model.dart';
import 'package:rolla/models/payment_model.dart';
import 'package:rolla/models/school_history_model.dart';
import 'package:rolla/models/school_model.dart';
import 'package:rolla/models/school_request_model.dart';
import 'package:rolla/models/training_model.dart';
import 'package:rolla/models/transfer_request_model.dart';
import 'package:rolla/models/user_model.dart';
import 'package:rolla/repositories/local_auth_repository.dart';
import 'package:rolla/repositories/local_event_repository.dart';
import 'package:rolla/repositories/local_notification_repository.dart';
import 'package:rolla/repositories/local_payment_repository.dart';
import 'package:rolla/repositories/local_school_repository.dart';
import 'package:rolla/repositories/local_training_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test(
    'LocalAuthRepository conserva usuario, sesión y caché de atleta',
    () async {
      final repository = LocalAuthRepository();
      final user = _user();
      final athlete = _athlete();

      await repository.saveUser(user);
      await repository.saveSession(user);
      await repository.saveCachedAthlete(athlete);
      await repository.savePublicAthlete(athlete);

      expect((await repository.getUser(user.email))?.toJson(), user.toJson());
      expect((await repository.getCurrentUser())?.toJson(), user.toJson());
      expect(await repository.getCurrentEmail(), user.email);
      expect(await repository.getCurrentRole(), user.role);
      expect((await repository.getCachedAthlete())?.toJson(), athlete.toJson());
      expect(
        (await repository.getPublicAthlete(athlete.email!))?.toJson(),
        athlete.toJson(),
      );

      expect(
        await repository.assignSchoolToUser(
          email: user.email,
          schoolId: 'school_2',
          schoolName: 'Nueva Escuela',
        ),
        isTrue,
      );
      expect((await repository.getUser(user.email))?.schoolId, 'school_2');
      expect((await repository.getCurrentUser())?.schoolId, 'school_2');

      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.containsKey('rolla_public_profile_${athlete.email}'),
        isTrue,
      );

      await repository.clearSession();
      expect(await repository.getCurrentUser(), isNull);
      expect(await repository.getCurrentRole(), isNull);
      expect(await repository.getUser(user.email), isNotNull);
    },
  );

  test('LocalSchoolRepository conserva todos los datos del dominio', () async {
    final repository = LocalSchoolRepository();
    final school = _school();
    final request = _request();
    final history = _history();
    final transfer = _transfer();

    await repository.saveSchool(school);
    await repository.saveRequests([request]);
    await repository.saveHistory('user_1', [history]);
    await repository.saveTransfers([transfer]);

    expect((await repository.getSchool('owner_1'))?.toJson(), school.toJson());
    expect((await repository.getRequests()).single.toJson(), request.toJson());
    expect(
      (await repository.getHistory('user_1')).single.toJson(),
      history.toJson(),
    );
    expect(
      (await repository.getTransfers()).single.toJson(),
      transfer.toJson(),
    );
  });

  test('LocalEventRepository separa eventos principales y caché', () async {
    final repository = LocalEventRepository();
    final event = _event();

    expect(await repository.getCachedEvents(), isNull);

    await repository.saveEvents([event]);
    await repository.saveCachedEvents([event.copyWith(id: 'cached_event')]);

    expect((await repository.getEvents()).single.id, event.id);
    expect((await repository.getCachedEvents())?.single.id, 'cached_event');
  });

  test('LocalPaymentRepository conserva pagos', () async {
    final repository = LocalPaymentRepository();
    final payment = _payment();

    await repository.savePayments([payment]);

    expect((await repository.getPayments()).single.toJson(), payment.toJson());
  });

  test('LocalNotificationRepository conserva notificaciones', () async {
    final repository = LocalNotificationRepository();
    final notification = _notification();

    await repository.saveNotifications([notification]);

    expect(
      (await repository.getNotifications()).single.toJson(),
      notification.toJson(),
    );
  });

  test('LocalTrainingRepository conserva entrenamientos', () async {
    final repository = LocalTrainingRepository();
    final training = _training();

    await repository.saveTrainings([training]);

    expect(
      (await repository.getTrainings()).single.toJson(),
      training.toJson(),
    );
  });
}

UserModel _user() {
  return UserModel(
    id: 'user_1',
    fullName: 'Laura Gómez',
    firstName: 'Laura',
    lastName: 'Gómez',
    email: 'laura@rolla.test',
    password: List.filled(64, 'a').join(),
    role: 'athlete',
    schoolId: 'school_1',
    schoolName: 'Ruedas del Norte',
    createdAt: DateTime.utc(2026, 1, 1),
  );
}

AthleteModel _athlete() {
  return AthleteModel(
    id: 'user_1',
    firstName: 'Laura',
    lastName: 'Gómez',
    role: 'athlete',
    schoolName: 'Ruedas del Norte',
    category: 'Juvenil',
    level: 'Avanzado',
    modality: 'Velocidad',
    email: 'laura@rolla.test',
    participationsCount: 3,
    goldMedals: 1,
    silverMedals: 1,
    bronzeMedals: 0,
  );
}

SchoolModel _school() {
  return SchoolModel(
    id: 'school_1',
    name: 'Ruedas del Norte',
    description: 'Escuela de patinaje',
    city: 'Bogotá',
    address: 'Calle 1',
    phone: '3000000000',
    email: 'escuela@rolla.test',
    createdAt: DateTime.utc(2026, 1, 1),
    ownerId: 'owner_1',
  );
}

SchoolRequestModel _request() {
  return SchoolRequestModel(
    id: 'request_1',
    athleteId: 'user_1',
    athleteName: 'Laura Gómez',
    athleteEmail: 'laura@rolla.test',
    schoolId: 'school_1',
    schoolName: 'Ruedas del Norte',
    createdAt: DateTime.utc(2026, 1, 2),
  );
}

SchoolHistoryModel _history() {
  return SchoolHistoryModel(
    id: 'history_1',
    schoolId: 'school_1',
    schoolName: 'Ruedas del Norte',
    joinedAt: DateTime.utc(2026, 1, 2),
  );
}

TransferRequestModel _transfer() {
  return TransferRequestModel(
    id: 'transfer_1',
    athleteId: 'user_1',
    athleteName: 'Laura Gómez',
    athleteEmail: 'laura@rolla.test',
    currentSchoolId: 'school_1',
    currentSchoolName: 'Ruedas del Norte',
    targetSchoolId: 'school_2',
    targetSchoolName: 'Nueva Escuela',
    type: 'transfer',
    createdAt: DateTime.utc(2026, 1, 3),
  );
}

EventModel _event() {
  return EventModel(
    id: 'event_1',
    schoolId: 'school_1',
    creatorId: 'owner_1',
    title: 'Festival de velocidad',
    description: 'Evento de prueba',
    date: DateTime.utc(2026, 2, 1),
    location: 'Pista principal',
    category: 'Juvenil',
    modality: 'Velocidad',
    price: 50000,
    status: 'published',
  );
}

PaymentModel _payment() {
  return PaymentModel(
    id: 'payment_1',
    eventId: 'event_1',
    eventTitle: 'Festival de velocidad',
    athleteId: 'user_1',
    athleteName: 'Laura Gómez',
    athleteEmail: 'laura@rolla.test',
    schoolId: 'school_1',
    amount: 50000,
    status: 'completed',
    createdAt: DateTime.utc(2026, 1, 5),
  );
}

NotificationModel _notification() {
  return NotificationModel(
    id: 'notification_1',
    userId: 'user_1',
    title: 'Nuevo evento',
    message: 'Tienes un evento disponible',
    type: 'event',
    date: DateTime.utc(2026, 1, 6),
  );
}

TrainingModel _training() {
  return TrainingModel(
    id: 'training_1',
    schoolId: 'school_1',
    coachId: 'owner_1',
    title: 'Técnica de salida',
    date: DateTime.utc(2026, 1, 7),
    location: 'Pista principal',
    createdAt: DateTime.utc(2026, 1, 6),
    confirmedAthletes: const ['user_1'],
  );
}
