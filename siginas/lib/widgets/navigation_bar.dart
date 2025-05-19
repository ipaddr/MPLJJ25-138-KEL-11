import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final String role;
  final ValueChanged<int> onItemSelected;
  final int initialIndex;

  const CustomBottomNavigationBar({
    super.key,
    required this.role,
    required this.onItemSelected,
    this.initialIndex = 0,
    required int currentIndex,
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    widget.onItemSelected(index);
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
          icon: Icon(
              widget.role == 'admin' ? Icons.assessment : Icons.assessment),
          label: widget.role == 'admin' ? 'Laporan' : 'Laporan',
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
