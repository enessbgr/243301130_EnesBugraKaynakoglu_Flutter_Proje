import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Kullanıcının yazdığı e-posta ve şifreyi tutacağımız kontrolcüler
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false; // Yükleniyor animasyonu için

  // Güncellenmiş Kayıt Olma Fonksiyonu
  Future<void> _kayitOl() async {
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şifre en az 6 karakter olmalıdır!')),
      );
      return;
    }

    setState(() { _isLoading = true; });
    try {
      // 1. Supabase Auth (Kimlik) sistemine kayıt yap
      final response = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Kayıt başarılıysa, kullanıcının ID'sini alıp 'profiles' tablomuza ekle
      if (response.user != null) {
        await Supabase.instance.client.from('profiles').insert({
          'id': response.user!.id,
          'role': 'Teknisyen', // Yeni kaydolan herkes varsayılan olarak Teknisyen başlar
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kayıt başarılı! Şimdi giriş yapabilirsiniz.')),
      );
    } on AuthException catch (e) {
      if (e.message.contains('already registered') || e.code == 'user_already_exists') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bu e-posta adresi zaten kayıtlı! Lütfen giriş yapın.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Kayıt hatası: ${e.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sistemsel bir hata oluştu: $e')),
      );
    }
    setState(() { _isLoading = false; });
  }

  // Güncellenmiş Giriş Yapma Fonksiyonu
  Future<void> _girisYap() async {
    if (_passwordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Şifre en az 6 karakter olmalıdır!')),
      );
      return;
    }

    setState(() { _isLoading = true; });
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giriş başarılı! Yönlendiriliyorsunuz...')),
      );

      // Başarılı girişten sonra HomeScreen'e (Ana Sayfa) yönlendir
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Giriş başarısız. Lütfen bilgileri kontrol edin.')),
      );
    }
    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sisteme Giriş')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-posta'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Şifre'),
              obscureText: true, // Şifreyi gizler
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator() // Yükleniyorsa dönen ikon göster
                : Column(
              children: [
                ElevatedButton(
                  onPressed: _girisYap,
                  child: const Text('Giriş Yap'),
                ),
                TextButton(
                  onPressed: _kayitOl,
                  child: const Text('Kayıt Ol'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}