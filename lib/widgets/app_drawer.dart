import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../views/symptoms/symptoms_list_view.dart';
import '../views/skills/skills_list_view.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
            ),
            child: Center(
              child: Text(
                l10n.appTitle,
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart),
            title: Text(l10n.strainLevel),
            onTap: () {
              Navigator.pop(context); // Close drawer
              // TODO: Navigate to strain page
            },
          ),
          ListTile(
            leading: const Icon(Icons.psychology),
            title: Text(l10n.skills),
            onTap: () {
              Navigator.pop(context); // Close drawer first
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SkillsListView(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.medical_information),
            title: Text(l10n.symptoms),
            onTap: () {
              Navigator.pop(context); // Close drawer first
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SymptomsListView(),
                ),
              );
            },
          ),
          const Spacer(),
          Divider(
            color: theme.colorScheme.outline,
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: Text(l10n.settings),
            onTap: () {
              Navigator.pop(context);
              // TODO: Navigate to settings page
            },
          ),
        ],
      ),
    );
  }
}