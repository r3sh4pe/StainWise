import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../theme/theme_constants.dart';
import '../../theme/theme_provider.dart';
import '../../viewmodels/settings_viewmodel.dart';
import 'time_range_picker.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: Consumer2<SettingsViewModel, ThemeProvider>(
        builder: (context, settingsViewModel, themeProvider, _) {
          if (settingsViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final settings = settingsViewModel.settings;

          return ListView(
            children: [
              // Language Section
              ListTile(
                title: Text(l10n.settingsLanguage),
                subtitle: Text(settings.locale == 'en' ? 'English' : 'Deutsch'),
                leading: const Icon(Icons.language),
                onTap: () => _showLanguageDialog(context, settingsViewModel),
              ),
              const Divider(),

              // Theme Section
              ListTile(
                title: Text(l10n.settingsTheme),
                subtitle: Text(settings.theme),
                leading: const Icon(Icons.palette),
                onTap: () => _showThemeDialog(
                  context,
                  settingsViewModel,
                  themeProvider,
                ),
              ),
              const Divider(),

              // Notifications Section
              SwitchListTile(
                title: Text(l10n.settingsNotifications),
                subtitle: Text(l10n.settingsNotificationsDesc),
                value: settings.notificationsEnabled,
                onChanged: (value) async {
                  await settingsViewModel.updateNotificationsEnabled(value);
                },
                secondary: const Icon(Icons.notifications),
              ),

              if (settings.notificationsEnabled) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.settingsSleepTime,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.settingsSleepTimeDesc,
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(settings.getReadableTimeRange()),
                              TextButton(
                                onPressed: () => _showTimeRangePicker(
                                  context,
                                  settingsViewModel,
                                ),
                                child: Text(l10n.edit),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],

              const Divider(),

              // Reset Settings
              ListTile(
                title: Text(l10n.settingsReset),
                subtitle: Text(l10n.settingsResetDesc),
                leading: const Icon(Icons.restore),
                onTap: () => _showResetDialog(context, settingsViewModel),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showLanguageDialog(
    BuildContext context,
    SettingsViewModel viewModel,
  ) {
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              trailing: viewModel.settings.locale == 'en'
                  ? const Icon(Icons.check)
                  : null,
              onTap: () async {
                await viewModel.updateLocale('en');
                if (context.mounted) Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Deutsch'),
              trailing: viewModel.settings.locale == 'de'
                  ? const Icon(Icons.check)
                  : null,
              onTap: () async {
                await viewModel.updateLocale('de');
                if (context.mounted) Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(
    BuildContext context,
    SettingsViewModel settingsViewModel,
    ThemeProvider themeProvider,
  ) {
    final l10n = context.l10n;
    final themes = settingsViewModel.getAvailableThemes();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsTheme),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: themes
              .map((theme) => ListTile(
                    title: Text(theme),
                    trailing: settingsViewModel.settings.theme == theme
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () async {
                      await settingsViewModel.updateTheme(theme);
                      themeProvider.setThemeVariant(
                        ThemeVariant.values.firstWhere(
                          (v) => v.name == theme,
                        ),
                      );
                      if (context.mounted) Navigator.pop(context);
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }

  void _showTimeRangePicker(
    BuildContext context,
    SettingsViewModel viewModel,
  ) async {
    final result = await showDialog<(TimeOfDay, TimeOfDay)?>(
      context: context,
      builder: (context) => TimeRangePicker(
        initialStartTime: viewModel.settings.sleepTimeStart,
        initialEndTime: viewModel.settings.sleepTimeEnd,
      ),
    );

    if (result != null && context.mounted) {
      final (start, end) = result;
      await viewModel.updateSleepTimeRange(start, end);
    }
  }

  void _showResetDialog(
    BuildContext context,
    SettingsViewModel viewModel,
  ) {
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsReset),
        content: Text(l10n.settingsResetConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              await viewModel.resetToDefault();
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l10n.settingsReset),
          ),
        ],
      ),
    );
  }
}
