import '../models/school_history_model.dart';
import '../models/school_model.dart';
import '../models/school_request_model.dart';
import '../models/transfer_request_model.dart';

abstract class SchoolRepository {
  Future<SchoolModel?> getSchool(String ownerId);

  Future<void> saveSchool(SchoolModel school);

  Future<List<SchoolRequestModel>> getRequests();

  Future<void> saveRequests(List<SchoolRequestModel> requests);

  Future<List<SchoolHistoryModel>> getHistory(String userId);

  Future<void> saveHistory(String userId, List<SchoolHistoryModel> history);

  Future<List<TransferRequestModel>> getTransfers();

  Future<void> saveTransfers(List<TransferRequestModel> transfers);
}
