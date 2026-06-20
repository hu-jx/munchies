import 'package:frontend_munchies/models/record.dart';
abstract class RecordRepository {
  Stream<void> get recordStream;
  //fetchAllRecords should replace getFilteredRecord so that there is only one method calling the same API service
  Future<List<Record>> fetchAllRecords(Map<String, String>? query);
  Future<void> deleteRec(String recordId);
  Future<void> saveRecord(Record record);
  Future<void> patchRecord(String recordId, Map<String, dynamic> updates);
  Future<Record> getRecord(String recordId);
}