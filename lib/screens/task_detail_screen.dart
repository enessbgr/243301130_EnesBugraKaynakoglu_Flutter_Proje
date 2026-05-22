import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TaskDetailScreen extends StatefulWidget {
  final Map<String, dynamic> task; // Tıklanan görevin verilerini alıyoruz

  const TaskDetailScreen({super.key, required this.task});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  bool _isLoading = false;
  late String _currentStatus;

  @override
  void initState() {
    super.initState();
    _currentStatus = widget.task['status']; // Ekran açıldığında mevcut durumu alır
  }

  // Görevi tamamlandı olarak güncelleme ve log kayıtlarını tutacak
  Future<void> _goreviTamamla() async {
    setState(() { _isLoading = true; });

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final taskId = widget.task['id'];
      final taskTitle = widget.task['title'];

      // 1. tasks tablosunda durumu güncelle
      await Supabase.instance.client
          .from('tasks')
          .update({'status': 'Tamamlandi'})
          .eq('id', taskId);

      // logs tablosuna yazdır
      await Supabase.instance.client.from('logs').insert({
        'user_id': userId,
        'action': 'Görev tamamlandı olarak işaretlendi: $taskTitle',
      });

      setState(() { _currentStatus = 'Tamamlandi'; });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Görev başarıyla tamamlandı!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Güncelleme hatası: $e')),
      );
    }

    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Görev Detayları')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.task['title'],
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Açıklama / Adres:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(widget.task['description'] ?? 'Açıklama bulunmuyor.', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Mevcut Durum: ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Chip(
                  label: Text(_currentStatus),
                  backgroundColor: _currentStatus == 'Bekliyor' ? Colors.orange.shade100 : Colors.green.shade100,
                ),
              ],
            ),
            const Spacer(), // Butonu en alta iter

            // Eğer görev hala bekliyorsa tamamla butonunu göster
            if (_currentStatus == 'Bekliyor')
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _goreviTamamla,
                  icon: const Icon(Icons.check_circle, color: Colors.white),
                  label: const Text('Görevi Tamamlandı Olarak İşaretle',
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}