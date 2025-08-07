// lib/widgets/app_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Imports inchangés
import 'package:odc_mobile_template/pages/home/homePage.dart';
import 'package:odc_mobile_template/pages/listProject/listProjectPage.dart';

// Définitions de couleurs inchangées
const Color primaryColor = Color(0xFF1A1A1A);
const Color accentColor = Color(0xFFFF6B35);
const Color lightGray = Color(0xFFF8F9FA);
const Color mediumGray = Color(0xFFE9ECEF);
const Color darkGray = Color(0xFF6C757D);
const Color cardBackground = Colors.white;

class AppShell extends StatefulWidget {
  final Widget child;
  final String currentLocation;

  const AppShell({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final List<String> _routes = [
    '/app/home',
    '/app/projects',
    '/app/create/project',
    '/app/notifications',
    '/app/jobs',
  ];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _updateCurrentIndex(widget.currentLocation);
  }

  @override
  void didUpdateWidget(covariant AppShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentLocation != oldWidget.currentLocation) {
      _updateCurrentIndex(widget.currentLocation);
    }
  }

  void _updateCurrentIndex(String location) {
    // Si la location actuelle n'est pas une route principale (ex: /app/projects/123), on trouve l'index de la route racine
    final index = _routes.indexWhere((route) => location.startsWith(route));
    if (index != -1 && _currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == _currentIndex && index != 2) return;

    if (index == 2) {
      debugPrint('Bouton Créer tapé !');
      GoRouter.of(context).push(_routes[index]);
    } else {
      GoRouter.of(context).go(_routes[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cardBackground,
        elevation: 1,
        toolbarHeight: 60,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: GestureDetector(
            onTap: () {
              debugPrint('Icône Profil/Menu tapée ! Redirection vers /app/profil');
              GoRouter.of(context).go('/app/profil');
            },
            child: CircleAvatar(
              backgroundColor: accentColor,
              child: const Text(
                'M',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        title: Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          decoration: BoxDecoration(
            color: darkGray,
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: TextField(
            readOnly: true,
            onTap: () {
              debugPrint('Champ de recherche tapé !');
            },
            decoration: const InputDecoration(
              hintText: 'Rechercher',
              hintStyle: TextStyle(color: lightGray),
              prefixIcon: Icon(Icons.search, color: lightGray),
              contentPadding: EdgeInsets.symmetric(vertical: 8.0),
              border: InputBorder.none,
              isDense: true,
            ),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.message_rounded, color: accentColor),
            onPressed: () {
              // L'action push() permet de naviguer vers une nouvelle page
              // tout en conservant le ShellRoute en arrière-plan.
              // L'AppBar et la BottomNavigationBar ne seront pas affichées sur MessageScreen.
              debugPrint('Icône Messages tapée ! Redirection vers /app/chats');
              GoRouter.of(context).push('/app/chats');
            },
          ),
          const SizedBox(width: 8.0),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: accentColor,
        unselectedItemColor: darkGray,
        backgroundColor: cardBackground,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Projets',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add),
            label: 'Créer',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.work),
            label: 'Mes Projets',
          ),
        ],
      ),
    );
  }
}