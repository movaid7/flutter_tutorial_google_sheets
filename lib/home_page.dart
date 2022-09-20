import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_tutorial_google_sheets/google_sheets_api.dart';
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
  final Map<String, String> _times = {};
  Worksheet? sheet;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  // wait for the data to be fetched from google sheets
  void startLoading() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (GoogleSheetsApi.loading == false) {
        setState(() {});
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // start loading until the data arrives
    if (GoogleSheetsApi.loading == true) {
      startLoading();
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Sheets'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: Container(
                child: GoogleSheetsApi.loading
                    ? const Center(child: CircularProgressIndicator())
                    : TimesList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimesList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: GoogleSheetsApi.currentTimes.length,
      itemBuilder: (BuildContext context, int index) {
        final name = GoogleSheetsApi.currentTimes.keys.elementAt(index);
        final time = GoogleSheetsApi.currentTimes.values.elementAt(index);
        return Column(
          children: [
            if (index % 2 == 0)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text(
                  '${name.substring(0, 1).toUpperCase()}${name.substring(0, name.length - 5).substring(1)}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: ListTile(
                title: Text(name),
                trailing: Text(time),
                tileColor: Colors.grey[200],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            if (index % 2 == 1) const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}
