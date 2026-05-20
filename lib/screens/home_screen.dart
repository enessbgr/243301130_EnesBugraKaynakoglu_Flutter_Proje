import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'add_task_screen.dart';
import 'login_screen.dart'; // Çıkış yapınca buraya dönecek

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userRole;
  bool _isLoading = true; // Veri çekilirken ekranda dönecek çember için

  @override
  void initState() {
    super.initState();
    // Sayfa ekrana çizmeden hemen önce bu fonksiyon çalışır
    _kullaniciRolunuGetir();
  }

  // Supabaseden kullanıcının rolünü çekmemize yarıyor
  Future<void> _kullaniciRolunuGetir() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // profiles tablosuna gider giriş yapan IDye ait rolü çekiyoruz
        final response = await Supabase.instance.client
            .from('profiles')
            .select('role')
            .eq('id', user.id)
            .single();

        setState(() {
          _userRole = response['role'];
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rol alınırken hata oluştu: $e')),
      );
      setState(() { _isLoading = false; });
    }
  }

  // Güvenli çıkış işlemi
  Future<void> _cikisYap() async {
    await Supabase.instance.client.auth.signOut();
    // Çıkış yaptıktan sonra giriş ekranına geri yönlendir ve geçmiş sayfaları sil
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Rol supabaseden gelene kadar bekleme ekranı gösterir
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Veri geldikten sonra rolüne göre başlık atıyoruz
    return Scaffold(
      appBar: AppBar(
        title: Text(_userRole == 'Yonetici' ? 'Yönetici Paneli' : 'Teknisyen Paneli'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Çıkış Yap',
            onPressed: _cikisYap,
          ),
        ],
      ),
      body: Column(
        children: [
          // Üst tarafta yine rolümüzü gösterelim
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Hoşgeldin! Sistemdeki Rolün: $_userRole',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(), // ince çizgi

          // Alt tarafa supabaseden canlı akan görev listesi yaptık
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              // tasks tablosunu en yeniden en eskiye doğru canlı dinliyoruz
              stream: Supabase.instance.client
                  .from('tasks')
                  .stream(primaryKey: ['id'])
                  .order('created_at', ascending: false),
              builder: (context, snapshot) {
                // Veri beklenirken dönen yuvarlak gösterir
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Eğer tablo boşsa veya veri yoksa mesaj ver
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Henüz hiçbir görev eklenmemiş.'));
                }

                // Veriler geldiyse listeyi çizmeye başlar
                final gorevler = snapshot.data!;
                return ListView.builder(
                  itemCount: gorevler.length,
                  itemBuilder: (context, index) {
                    final gorev = gorevler[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 2,
                      child: ListTile(
                        leading: const Icon(Icons.build_circle, color: Colors.blue, size: 40),
                        title: Text(gorev['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(gorev['description'] ?? 'Açıklama yok'),
                        trailing: Chip(
                          label: Text(gorev['status']),
                          // Durum bekliyor ise turuncu, değilse yeşil renk yap
                          backgroundColor: gorev['status'] == 'Bekliyor'
                              ? Colors.orange.shade100
                              : Colors.green.shade100,
                        ),
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${gorev['title']} detaylarına yakında eklenecek!')),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Butona basılınca AddTaskScreen sayfasına geçiş yapar
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );
        },
        tooltip: 'Yeni Görev Ekle',
        child: const Icon(Icons.add),
      ),);
  }
}