import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../widgets/app_drawer.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
      ),
      endDrawer: const AppDrawer(), // Places drawer on the right side
      body: const Center(
        child: Text('Welcome to Strain Monitor'),
      ),
    );
  }
}
