import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gsheets/gsheets.dart';

class GoogleSheetsApi {
  // set up & connect to the spreadsheet
  static const _spreadsheetId = '1j2yHzgaXfKQSmRPYPvs_bGjq7W9JWFLTcjVlGsDVn4Q';
  static Worksheet? _worksheet;

  // some variables to keep track of..
  static Map<String, String> currentTimes = {};
  static bool loading = true;

  // initialise the spreadsheet!
  Future init() async {
    const storage = FlutterSecureStorage();
    String? creds = (await storage.read(key: 'GSheet'));
    final gsheets = GSheets(creds);
    final ss = await gsheets.spreadsheet(_spreadsheetId);
    _worksheet = ss.worksheetByTitle('Times');
    loadTimes();
  }

  // fetch times from the spreadsheet
  static Future loadTimes() async {
    if (_worksheet == null) return;

    final names = await _worksheet!.values.column(1);
    final times = await _worksheet!.values.column(2);
    names.removeAt(0);
    times.removeAt(0);
    // convert time decimal to standard form
    // e.g. 0.725694444444444 represents 17:25
    for (var i = 0; i < times.length; i++) {
      final time = double.parse(times[i]);
      final hour = (time * 24).floor();
      final minute = ((time * 24 - hour) * 60).floor();
      times[i] = '${hour.toString().padLeft(2, '0')}:'
          '${minute.toString().padLeft(2, '0')}';
    }
    currentTimes = Map.fromIterables(names, times);
    // this will stop the circular loading indicator
    loading = false;
  }
}
