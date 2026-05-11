import 'package:flutter/material.dart';

import '../widgets/app_header.dart';
import 'api_todo_page.dart';
import 'local_todo_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final _pages = const [LocalTodoPage(), ApiTodoPage()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const AppHeader(),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                child: _pages[_selectedIndex],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.checklist_rounded),
            selectedIcon: Icon(Icons.checklist_rounded),
            label: 'Todo Lokal',
          ),
          NavigationDestination(
            icon: Icon(Icons.cloud_sync_outlined),
            selectedIcon: Icon(Icons.cloud_sync_rounded),
            label: 'Todo API',
          ),
        ],
      ),
    );
  }
}
