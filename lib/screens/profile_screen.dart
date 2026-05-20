import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  final String userRole;

  const ProfileScreen({super.key, required this.userRole});

  Future<void> _cikisYap(BuildContext context) async {
    await Supabase.instance.client.auth.signOut();
    if (context.mounted) {
      // Tüm geçmiş sayfaları silerek giriş ekranına atar
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Giriş yapan kullanıcının epostasını supabaseden çekiyoruz
    final userEmail = Supabase.instance.client.auth.currentUser?.email ?? 'Bilinmiyor';

    return Scaffold(
      appBar: AppBar(title: const Text('Profilim')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text('E-posta: $userEmail', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text('Sistemdeki Rolünüz: $userRole',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _cikisYap(context),
              icon: const Icon(Icons.logout),
              label: const Text('Sistemden Çıkış Yap'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade100),
            )
          ],
        ),
      ),
    );
  }
}