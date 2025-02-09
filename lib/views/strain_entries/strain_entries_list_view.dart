import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/strain_entry.dart';
import '../../viewmodels/strain_entry_viewmodel.dart';
import 'strain_entry_edit_view.dart';
import 'strain_entry_form_view.dart';

class StrainEntriesListView extends StatefulWidget {
  const StrainEntriesListView({super.key});

  @override
  State<StrainEntriesListView> createState() => _StrainEntriesListViewState();
}

class _StrainEntriesListViewState extends State<StrainEntriesListView> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.strainLevel),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Consumer<StrainEntryViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(viewModel.errorMessage!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: viewModel.clearError,
                    child: Text(l10n.cancel),
                  ),
                ],
              ),
            );
          }

          final entries = viewModel.getEntriesForDate(_selectedDate);
          final unratedCount = entries
              .where((entry) => entry.usedSkill != null && !entry.isSkillRated)
              .length;

          return Column(
            children: [
              // Date selector
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () => _changeDate(-1),
                    ),
                    TextButton(
                      onPressed: () => _selectDate(context),
                      child: Text(
                        DateFormat.yMMMd().format(_selectedDate),
                        style: theme.textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: _selectedDate.isBefore(DateTime.now())
                          ? () => _changeDate(1)
                          : null,
                    ),
                  ],
                ),
              ),

              if (entries.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          l10n.noEntriesYet,
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const StrainEntryFormView(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: Text(l10n.createEntry),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                // Summary cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      // Average strain
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(l10n.averageStrain),
                              Text(
                                viewModel
                                    .getAverageStrainForDate(_selectedDate)!
                                    .toStringAsFixed(1),
                                style: theme.textTheme.headlineSmall,
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Unrated skills indicator
                      if (unratedCount > 0)
                        Card(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star_outline,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$unratedCount skills need rating',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Entries list
                Expanded(
                  child: ListView.builder(
                    itemCount: entries.length,
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      return StrainEntryListTile(entry: entry);
                    },
                  ),
                ),
              ],
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StrainEntryFormView(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
  }
}

class StrainEntryListTile extends StatelessWidget {
  final StrainEntry entry;

  const StrainEntryListTile({
    super.key,
    required this.entry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final needsRating = entry.usedSkill != null && !entry.isSkillRated;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: needsRating
            ? BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              )
            : BorderSide.none,
      ),
      color: needsRating ? theme.colorScheme.primary.withOpacity(0.05) : null,
      child: ListTile(
        leading: _buildStrainIndicator(context),
        title: Text(entry.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (entry.note != null)
              Text(
                entry.note!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            if (entry.symptoms.isNotEmpty)
              Wrap(
                spacing: 4,
                children: entry.symptoms
                    .map((symptom) => Chip(
                          label: Text(
                            symptom.name,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                          backgroundColor: theme.colorScheme.secondaryContainer,
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList(),
              ),
            if (entry.usedSkill != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.psychology,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    entry.usedSkill!.name,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  if (entry.skillRating != null) ...[
                    const SizedBox(width: 8),
                    Text(
                      '${entry.skillRating!.toStringAsFixed(1)}/5',
                      style: theme.textTheme.bodySmall,
                    ),
                  ] else ...[
                    const SizedBox(width: 8),
                    Icon(
                      Icons.star_outline,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.needsRating,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
        trailing: Text(
          DateFormat.Hm().format(entry.createdAt),
          style: theme.textTheme.bodySmall,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StrainEntryEditView(entry: entry),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStrainIndicator(BuildContext context) {
    final theme = Theme.of(context);

    Color getStrainColor(int level) {
      if (level < 30) return theme.colorScheme.primary;
      if (level < 70) return theme.colorScheme.secondary;
      return theme.colorScheme.error;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: getStrainColor(entry.strainLevel),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          entry.strainLevel.toString(),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
