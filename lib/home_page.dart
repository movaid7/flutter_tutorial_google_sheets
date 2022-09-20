import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:gsheets/gsheets.dart';

const _spreadsheetId = '1j2yHzgaXfKQSmRPYPvs_bGjq7W9JWFLTcjVlGsDVn4Q';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // fetch creds from secure storage
  String? _creds;
  Map<String, String> _times = {};
  Worksheet? sheet;

  Future<void> _openGSheet() async {
    const storage = FlutterSecureStorage();
    _creds = (await storage.read(key: 'GSheet'));
    try {
      final gsheets = GSheets(_creds);
      final ss = await gsheets.spreadsheet(_spreadsheetId);
      sheet = ss.worksheetByTitle('Times');
      _read();
    } catch (e) {
      print(e);
    }
  }

  Future<void> _read() async {
    if (sheet == null) {
      return;
    } else if (_times.isNotEmpty) {
      return;
    } else {
      final names = await sheet!.values.column(1);
      final times = await sheet!.values.column(2);
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
      setState(() {
        _times = Map.fromIterables(names, times);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _openGSheet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Sheets'),
      ),
      body: FutureBuilder(
        future: _read(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return _buildListView(_times);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

Widget _buildListView(Map<String, String> times) {
  return ListView.builder(
    itemCount: times.length,
    itemBuilder: (BuildContext context, int index) {
      final name = times.keys.elementAt(index);
      final time = times.values.elementAt(index);
      return ListTile(
        title: Text(name),
        trailing: Text(time),
      );
    },
  );
}
