import 'package:campus_care/features/presentation/views/announcements_view.dart';
import 'package:campus_care/features/presentation/views/dashboard_view.dart';
import 'package:campus_care/features/presentation/views/events_view.dart';
import 'package:campus_care/features/presentation/views/maintenance_requests_view.dart';
import 'package:campus_care/features/presentation/views/personel_view.dart';
import 'package:campus_care/features/presentation/views/profile_view.dart';
import 'package:flutter/material.dart';

class MainNavigationView extends StatefulWidget {
  const MainNavigationView({super.key});

  @override
  State<MainNavigationView> createState() => _MainNavigationViewState();
}

class _MainNavigationViewState extends State<MainNavigationView> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    DashboardView(),
    MaintenanceRequestsView(),
    AnnouncementsView(),
    EventsView(),
    PersonelView(),
    ProfileView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF5C6FFF),
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 12),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Ana Sayfa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.build_outlined),
              activeIcon: Icon(Icons.build),
              label: 'Talepler',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.campaign_outlined),
              activeIcon: Icon(Icons.campaign),
              label: 'Duyurular',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.event_outlined),
              activeIcon: Icon(Icons.event),
              label: 'Etkinlikler',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              activeIcon: Icon(Icons.person),
              label: 'Personel',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
