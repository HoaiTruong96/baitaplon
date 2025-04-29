import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'homepage.dart'; // HomePage được tách riêng

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Supabase
  await Supabase.initialize(
    url: 'https://itnmoingffpzyfezhhxc.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml0bm1vaW5nZmZwenlmZXpoaHhjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU5MTM2MzksImV4cCI6MjA2MTQ4OTYzOX0.l7LP_0FS4Q68qtYJv7LOot_HhByYJvfuDpOy0x3RsLQ',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List Schedule',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
