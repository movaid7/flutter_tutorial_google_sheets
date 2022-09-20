import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tutorial_google_sheets/home_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // store creds to secure local storage
  final creds = await rootBundle.loadString('assets/creds.txt');
  const storage = FlutterSecureStorage();
  await storage.write(key: 'GSheet', value: creds);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primarySwatch: Colors.deepOrange),
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}
