import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/l10n.dart';
import '../../models/symptom.dart';
import '../../viewmodels/symptom_viewmodel.dart';

class SymptomFormView extends StatefulWidget {
  final Symptom? symptom;

  const SymptomFormView({
    super.key,
    this.symptom,
  });

  @override
  State<SymptomFormView> createState() => _SymptomFormViewState();
}

class _SymptomFormViewState extends State<SymptomFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  bool _isActive = true;
  int _strainLevel = 50;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.symptom?.name);
    _descriptionController =
        TextEditingController(text: widget.symptom?.description);
    if (widget.symptom != null) {
      _isActive = widget.symptom!.isActive;
      _strainLevel = widget.symptom?.getLatestStrainLevel() ?? 50;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveSymptom(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<SymptomViewModel>();
    final navigator = Navigator.of(context); // Capture Navigator before async
    final scaffoldMessenger =
        ScaffoldMessenger.of(context); // Capture Messenger before async

    try {
      if (widget.symptom == null) {
        await viewModel.createSymptom(
          name: _nameController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
        );
      } else {
        await viewModel.updateSymptom(
          widget.symptom!,
          name: _nameController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          isActive: _isActive,
        );

        if (_strainLevel != widget.symptom?.getLatestStrainLevel()) {
          await viewModel.addStrainLevel(widget.symptom!, _strainLevel);
        }
      }

      if (mounted) {
        navigator.pop(); // Use captured Navigator
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
              content: Text(viewModel.errorMessage ?? 'An error occurred')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isEditing = widget.symptom != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit ${widget.symptom!.name}' : l10n.symptoms),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final navigator = Navigator.of(context); // Capture before async
                final viewModel = context.read<SymptomViewModel>();

                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Symptom?'),
                    content: const Text('This action cannot be undone.'),
                    actions: [
                      TextButton(
                        onPressed: () => navigator.pop(false),
                        // Use captured navigator
                        child: Text(l10n.cancel),
                      ),
                      TextButton(
                        onPressed: () => navigator.pop(true),
                        // Use captured navigator
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirmed == true) {
                  await viewModel.deleteSymptom(widget.symptom!);
                  if (mounted) {
                    navigator.pop(); // Use captured navigator
                  }
                }
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: l10n.symptomName,
                filled: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name'; // TODO: Add to localizations
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.symptomDescription,
                filled: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            if (isEditing) ...[
              SwitchListTile(
                title: const Text('Active'), // TODO: Add to localizations
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
              const SizedBox(height: 16),
              Text(
                'Current Strain Level: $_strainLevel',
                // TODO: Add to localizations
                style: theme.textTheme.titleMedium,
              ),
              Slider(
                value: _strainLevel.toDouble(),
                min: 0,
                max: 100,
                divisions: 100,
                label: _strainLevel.toString(),
                onChanged: (value) =>
                    setState(() => _strainLevel = value.round()),
              ),
            ],
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _saveSymptom(context),
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
