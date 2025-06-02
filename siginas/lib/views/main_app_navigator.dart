import 'package:flutter/material.dart';
import 'package:siginas/widgets/navigation_bar.dart';
import 'package:siginas/views/home_screen.dart';
import 'package:siginas/views/reports/reports_admin.dart';
import 'package:siginas/views/reports/reports_user.dart';
import 'package:siginas/views/profile/profile_screen.dart';

class MainAppNavigator extends StatefulWidget {
  final String role;

  const MainAppNavigator({super.key, required this.role});

  @override
  State<MainAppNavigator> createState() => _MainAppNavigatorState();
}

class _MainAppNavigatorState extends State<MainAppNavigator> {
  int _selectedIndex = 0; // Default: Home Screen

  // List of pages to be displayed in the IndexedStack
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    // Inisialisasi daftar halaman berdasarkan role
    _pages = [
      HomeScreen(role: widget.role),
      widget.role == 'admin'
          ? ReportsAdmin(role: widget.role)
          : ReportsUser(role: widget.role),
      ProfileScreen(role: widget.role),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Di sini tidak ada Navigator.pushReplacement
    // karena IndexedStack akan menangani tampilan halaman
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar mungkin perlu dipindahkan ke masing-masing halaman anak
      // atau dibuat dinamis di sini jika ada elemen umum di AppBar
      // AppBar(
      //   title: Text('SiGiNas'),
      // ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        initialIndex: _selectedIndex,
        role: widget.role,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}
