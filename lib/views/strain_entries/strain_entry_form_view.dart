import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/skill.dart';
import '../../models/symptom.dart';
import '../../viewmodels/skill_viewmodel.dart';
import '../../viewmodels/strain_entry_viewmodel.dart';
import '../../viewmodels/symptom_viewmodel.dart';

class StrainEntryFormView extends StatefulWidget {
  const StrainEntryFormView({super.key});

  @override
  State<StrainEntryFormView> createState() => _StrainEntryFormViewState();
}

class _StrainEntryFormViewState extends State<StrainEntryFormView> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  int _strainLevel = 50;
  final List<Symptom> _selectedSymptoms = [];
  Skill? _selectedSkill;

  @override
  void dispose() {
    _titleController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.error),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.l10n.cancel),
          ),
        ],
      ),
    );
  }

  Future<void> _saveEntry() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<StrainEntryViewModel>();
    final navigator = Navigator.of(context);

    try {
      await viewModel.createEntry(
        title: _titleController.text,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        strainLevel: _strainLevel,
        symptoms: _selectedSymptoms,
        usedSkill: _selectedSkill,
      );
      if (mounted) {
        navigator.pop();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(viewModel.errorMessage ?? context.l10n.errorOccurred);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createEntry),
      ),
      body: Consumer3<StrainEntryViewModel, SkillViewModel, SymptomViewModel>(
        builder:
            (context, strainViewModel, skillViewModel, symptomViewModel, _) {
          if (strainViewModel.isLoading ||
              skillViewModel.isLoading ||
              symptomViewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final skills = skillViewModel.activeSkills;
          final symptoms = symptomViewModel.activeSymptoms;

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Title
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: l10n.entryTitle,
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.pleaseEnterTitle;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Note
                TextFormField(
                  controller: _noteController,
                  decoration: InputDecoration(
                    labelText: l10n.entryNote,
                    filled: true,
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Strain Level
                Text(
                  l10n.strainLevel,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Slider(
                        value: _strainLevel.toDouble(),
                        min: 0,
                        max: 100,
                        divisions: 100,
                        label: _strainLevel.toString(),
                        onChanged: (value) {
                          setState(() => _strainLevel = value.round());
                        },
                      ),
                    ),
                    Container(
                      width: 50,
                      alignment: Alignment.center,
                      child: Text(
                        _strainLevel.toString(),
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Symptoms
                if (symptoms.isNotEmpty) ...[
                  Text(
                    l10n.selectSymptoms,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: symptoms.map((symptom) {
                      final isSelected = _selectedSymptoms.contains(symptom);
                      return FilterChip(
                        label: Text(symptom.name),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedSymptoms.add(symptom);
                            } else {
                              _selectedSymptoms.remove(symptom);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                // Skills
                if (skills.isNotEmpty) ...[
                  Text(
                    l10n.suggestedSkills,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  ...skills.map((skill) {
                    final isApplicable =
                        skill.isApplicableForStrain(_strainLevel);
                    final rating = skill.averageRating;

                    return ListTile(
                      title: Text(skill.name),
                      subtitle:
                          Text(l10n.skillRating(rating.toStringAsFixed(1))),
                      leading: Radio<Skill>(
                        value: skill,
                        groupValue: _selectedSkill,
                        onChanged: (value) {
                          setState(() => _selectedSkill = value);
                        },
                      ),
                      enabled: isApplicable,
                      tileColor: isApplicable
                          ? _getSkillHighlightColor(
                              rating,
                              theme.colorScheme,
                            )
                          : null,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }),
                ],
                const SizedBox(height: 32),

                // Save Button
                ElevatedButton(
                  onPressed: _saveEntry,
                  child: Text(l10n.save),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color? _getSkillHighlightColor(double rating, ColorScheme colors) {
    if (rating >= 4) {
      return colors.primaryContainer.withValues(alpha: 0.3);
    } else if (rating >= 3) {
      return colors.secondaryContainer.withValues(alpha: 0.2);
    }
    return null;
  }
}
