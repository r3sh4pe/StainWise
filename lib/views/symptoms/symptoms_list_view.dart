import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/symptom.dart';
import '../../viewmodels/symptom_viewmodel.dart';
import 'symptom_form_view.dart';

class SymptomsListView extends StatelessWidget {
  const SymptomsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.symptoms),
      ),
      body: Consumer<SymptomViewModel>(
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

          final symptoms = viewModel.symptoms;
          if (symptoms.isEmpty) {
            return Center(
              child: Text(
                'No symptoms added yet', // TODO: Add to localizations
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          return ListView.builder(
            itemCount: symptoms.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final symptom = symptoms[index];
              return SymptomListTile(symptom: symptom);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SymptomFormView(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class SymptomListTile extends StatelessWidget {
  final Symptom symptom;

  const SymptomListTile({
    super.key,
    required this.symptom,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final latestLevel = symptom.getLatestStrainLevel();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(symptom.name),
        subtitle: symptom.description != null
            ? Text(
                symptom.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: latestLevel != null
            ? Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _getStrainColor(latestLevel, theme),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  '$latestLevel',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SymptomFormView(symptom: symptom),
            ),
          );
        },
      ),
    );
  }

  Color _getStrainColor(int level, ThemeData theme) {
    if (level < 30) return theme.colorScheme.primary;
    if (level < 70) return theme.colorScheme.secondary;
    return theme.colorScheme.error;
  }
}
