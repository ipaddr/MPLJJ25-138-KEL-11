import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final String role;
  final ValueChanged<int> onItemSelected;
  final int initialIndex;

  const CustomBottomNavigationBar({
    super.key,
    required this.role,
    required this.onItemSelected,
    this.initialIndex = 0, // ini akan menjadi current index awal
    // Hapus 'required int currentIndex,' dari sini
  });

  @override
  State<CustomBottomNavigationBar> createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant CustomBottomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Jika parent widget mengubah initialIndex, update _selectedIndex
    if (widget.initialIndex != oldWidget.initialIndex) {
      setState(() {
        _selectedIndex = widget.initialIndex;
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onItemSelected(index); // Panggil callback ke parent
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        const BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          // Logika perbedaan ikon dan label berdasarkan role
          icon: Icon(
            widget.role == 'admin'
                ? Icons.assessment
                : Icons.camera_alt, // Admin: Reports, User: Camera
          ),
          label: widget.role == 'admin'
              ? 'Laporan'
              : 'Kamera', // Admin: Laporan, User: Kamera
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profil',
        ),
      ],
      currentIndex: _selectedIndex,
      selectedItemColor: Colors.blue, // Sesuaikan warna
      onTap: _onItemTapped,
    );
  }
}
