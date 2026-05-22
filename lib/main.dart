import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart'; // Ana sayfamızı tanıması için bunu ekledik

Future<void> main() async {
  // 1. Flutter çalıştığından emin olduk
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Supabasei başlattık
  await Supabase.initialize(
    url: 'https://kbujlladhfcolutrjkzh.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtidWpsbGFkaGZjb2x1dHJqa3poIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg5MzIxNzgsImV4cCI6MjA5NDUwODE3OH0.pvxuVXIxFNBiFApwBe2JeqIBhlIGoGEy4YlwC2xWb9U',
  );

  // 3. Uygulamayı çalıştır
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Supabasein hafızasında aktif bir oturum var mı kontrol ediyoruz
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      debugShowCheckedModeBanner: false, // Sağ üstteki DEBUG yazısını siler
      title: 'Periyodik Kontrol',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      // Eğer oturum varsa ana sayfayı aç, yoksa kayıt ekranını
      home: session != null ? const HomeScreen() : const LoginScreen(),
    );
  }
}