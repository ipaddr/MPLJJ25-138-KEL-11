import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];

  late final GenerativeModel _model;
  late final ChatSession _chat;

  bool _isLoading = false;
  String? _userRole; // Variabel untuk menyimpan peran pengguna
  String? _userName; // Variabel untuk menyimpan nama pengguna

  // Instances Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Inisialisasi model Gemini.
    _model = GenerativeModel(
      model: 'gemini-1.5-flash', // ✅ Gunakan model yang valid
      apiKey: 'AIzaSyCczypulZKnwl6MAI3x87nIb18BRuyBG0U', // Ganti dengan API key-mu
    );
    _chat = _model.startChat();

    // Ambil peran dan nama pengguna, lalu tambahkan pesan selamat datang
    _fetchUserRoleAndName();
  }

  // Fungsi untuk mengambil peran dan nama pengguna dari Firestore
  Future<void> _fetchUserRoleAndName() async {
    User? currentUser = _auth.currentUser;
    String fetchedUserName = 'Pengguna'; // Nama default jika tidak ditemukan
    String fetchedUserRole = 'Tamu'; // Peran default jika tidak ditemukan

    if (currentUser != null) {
      try {
        DocumentSnapshot userDoc = await _firestore.collection('users').doc(currentUser.uid).get();
        if (userDoc.exists && userDoc.data() != null) {
          fetchedUserName = (userDoc.data() as Map<String, dynamic>)['name'] ?? currentUser.email ?? 'Pengguna';
          fetchedUserRole = (userDoc.data() as Map<String, dynamic>)['role'] ?? 'Tidak Diketahui';
        } else {
          fetchedUserName = currentUser.email ?? 'Pengguna'; // Fallback ke email jika dokumen tidak ada
          fetchedUserRole = "Tidak Diketahui";
        }
      } catch (e) {
        print("Error fetching user data: $e");
        fetchedUserName = currentUser.email ?? 'Pengguna'; // Fallback ke email jika error
        fetchedUserRole = "Tidak Diketahui";
      }
    }

    setState(() {
      _userName = fetchedUserName;
      _userRole = fetchedUserRole;
      // Tambahkan pesan selamat datang dari chatbot setelah data pengguna diambil
      _messages.insert(0, {'role': 'bot', 'text': 'Halo, $_userName! Apakah ada yang bisa saya bantu?'});
    });
  }

  Future<void> _sendMessage() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    setState(() {
      _messages.add({'role': 'user', 'text': input});
      _controller.clear();
      _isLoading = true; // Aktifkan indikator loading
    });

    try {
      final response = await _chat.sendMessage(Content.text(input));
      final output = response.text ?? 'Tidak ada balasan dari Gemini.';

      setState(() {
        _messages.add({'role': 'bot', 'text': output});
      });
    } catch (e) {
      setState(() {
        _messages.add({'role': 'bot', 'text': '❌ Error: $e'});
      });
    } finally {
      setState(() {
        _isLoading = false; // Matikan indikator loading
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chatbot', // Hanya judul "Chatbot" di AppBar
          style: TextStyle(color: Colors.white), // Warna teks putih
        ),
        backgroundColor: Colors.blueAccent, // Warna latar belakang AppBar
        iconTheme: const IconThemeData(color: Colors.white), // Warna ikon (misal: tombol kembali)
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['role'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[200] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(message['text'] ?? ''),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) // Tampilkan indikator loading jika _isLoading true
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onSubmitted: (value) => _sendMessage(), // Panggil _sendMessage saat Enter ditekan
                    decoration: const InputDecoration(
                      hintText: 'Ketik pesan...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isLoading ? null : _sendMessage, // Nonaktifkan tombol saat loading
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}