import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/strain_entry.dart';
import '../../viewmodels/strain_entry_viewmodel.dart';

class StrainEntryEditView extends StatefulWidget {
  final StrainEntry entry;

  const StrainEntryEditView({
    super.key,
    required this.entry,
  });

  @override
  State<StrainEntryEditView> createState() => _StrainEntryEditViewState();
}

class _StrainEntryEditViewState extends State<StrainEntryEditView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _noteController;
  late int _strainLevel;
  double _skillRating = 3.0; // Default rating
  bool _isRatingSkill = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry.title);
    _noteController = TextEditingController(text: widget.entry.note);
    _strainLevel = widget.entry.strainLevel;
  }

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
      await viewModel.updateEntry(
        widget.entry,
        title: _titleController.text,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        strainLevel: _strainLevel,
      );

      if (_isRatingSkill) {
        await viewModel.rateSkill(widget.entry, _skillRating);
      }

      navigator.pop();
    } catch (e) {
      _showErrorDialog(viewModel.errorMessage ?? context.l10n.errorOccurred);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editEntry),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
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
            TextFormField(
              controller: _noteController,
              decoration: InputDecoration(
                labelText: l10n.entryNote,
                filled: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
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
            if (widget.entry.usedSkill != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.usedSkill,
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(widget.entry.usedSkill!.name),
                      if (!widget.entry.isSkillRated) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Checkbox(
                              value: _isRatingSkill,
                              onChanged: (value) {
                                setState(() => _isRatingSkill = value ?? false);
                              },
                            ),
                            Text(l10n.rateSkillNow),
                          ],
                        ),
                        if (_isRatingSkill) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: Slider(
                                  value: _skillRating,
                                  min: 0,
                                  max: 5,
                                  divisions: 10,
                                  label: _skillRating.toStringAsFixed(1),
                                  onChanged: (value) {
                                    setState(() => _skillRating = value);
                                  },
                                ),
                              ),
                              Container(
                                width: 50,
                                alignment: Alignment.center,
                                child: Text(
                                  _skillRating.toStringAsFixed(1),
                                  style: theme.textTheme.titleMedium,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ] else
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            l10n.skillRating(
                              widget.entry.skillRating!.toStringAsFixed(1),
                            ),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            ElevatedButton(
              onPressed: _saveEntry,
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
