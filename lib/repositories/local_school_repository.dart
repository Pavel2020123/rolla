import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/school_history_model.dart';
import '../models/school_model.dart';
import '../models/school_request_model.dart';
import '../models/transfer_request_model.dart';
import 'school_repository.dart';

class LocalSchoolRepository implements SchoolRepository {
  static const _requestsKey = 'rolla_school_requests';
  static const _transfersKey = 'rolla_transfers';

  String _schoolKey(String ownerId) => 'rolla_school_$ownerId';

  String _historyKey(String userId) => 'rolla_school_history_$userId';

  @override
  Future<SchoolModel?> getSchool(String ownerId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_schoolKey(ownerId));
    if (data == null) return null;
    return SchoolModel.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  @override
  Future<void> saveSchool(SchoolModel school) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _schoolKey(school.ownerId),
      jsonEncode(school.toJson()),
    );
  }

  @override
  Future<List<SchoolRequestModel>> getRequests() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_requestsKey);
    if (data == null) return [];
    final decoded = jsonDecode(data) as List<dynamic>;
    return decoded
        .map(
          (entry) => SchoolRequestModel.fromJson(entry as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> saveRequests(List<SchoolRequestModel> requests) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _requestsKey,
      jsonEncode(requests.map((request) => request.toJson()).toList()),
    );
  }

  @override
  Future<List<SchoolHistoryModel>> getHistory(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_historyKey(userId));
    if (data == null) return [];
    final decoded = jsonDecode(data) as List<dynamic>;
    return decoded
        .map(
          (entry) => SchoolHistoryModel.fromJson(entry as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> saveHistory(
    String userId,
    List<SchoolHistoryModel> history,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _historyKey(userId),
      jsonEncode(history.map((entry) => entry.toJson()).toList()),
    );
  }

  @override
  Future<List<TransferRequestModel>> getTransfers() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_transfersKey);
    if (data == null) return [];
    final decoded = jsonDecode(data) as List<dynamic>;
    return decoded
        .map(
          (entry) =>
              TransferRequestModel.fromJson(entry as Map<String, dynamic>),
        )
        .toList();
  }

  @override
  Future<void> saveTransfers(List<TransferRequestModel> transfers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _transfersKey,
      jsonEncode(transfers.map((transfer) => transfer.toJson()).toList()),
    );
  }
}
