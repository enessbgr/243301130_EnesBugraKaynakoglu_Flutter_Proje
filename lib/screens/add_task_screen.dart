import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _baslikController = TextEditingController();
  final _aciklamaController = TextEditingController();
  bool _isLoading = false;

  Future<void> _gorevKaydet() async {
    // Başlık boşsa uyarı ver ve işlemi durdur
    if (_baslikController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen görev başlığı girin!')),
      );
      return;
    }

    setState(() { _isLoading = true; });

    try {
      // Giriş yapan kullanıcının IDsini alıyoruz
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final baslik = _baslikController.text.trim();

      // 1. Yeni görevi tasks tablosuna ekler
      await Supabase.instance.client.from('tasks').insert({
        'title': baslik,
        'description': _aciklamaController.text.trim(),
        'status': 'Bekliyor', // Varsayılan durum
      });

      await Supabase.instance.client.from('logs').insert({
        'user_id': userId,
        'action': 'Yeni görev eklendi: $baslik',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Görev başarıyla eklendi!')),
      );

      // Başarılı olunca bir önceki sayfaya (Ana Sayfaya) geri dön
      if (mounted) Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kayıt hatası: $e')),
      );
    }

    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yeni Görev Ekle')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _baslikController,
              decoration: const InputDecoration(
                labelText: 'Görev Başlığı (Örn: Asansör Bakımı)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _aciklamaController,
              maxLines: 3, // Açıklama kutusu biraz daha geniş olsun
              decoration: const InputDecoration(
                labelText: 'Görev Açıklaması / Adres Bilgisi',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
              width: double.infinity, // Butonu tam genişlikte yapıyor
              child: ElevatedButton(
                onPressed: _gorevKaydet,
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text('Görevi Kaydet ve Log Oluştur', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}