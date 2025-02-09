import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/l10n.dart';
import '../../models/skill.dart';
import '../../viewmodels/skill_viewmodel.dart';

class SkillFormView extends StatefulWidget {
  final Skill? skill;

  const SkillFormView({
    super.key,
    this.skill,
  });

  @override
  State<SkillFormView> createState() => _SkillFormViewState();
}

class _SkillFormViewState extends State<SkillFormView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _tagController;
  bool _isActive = true;
  int _strainLowerFence = 0;
  int _strainUpperFence = 100;
  final List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.skill?.name);
    _descriptionController = TextEditingController(text: widget.skill?.description);
    _tagController = TextEditingController();
    if (widget.skill != null) {
      _isActive = widget.skill!.isActive;
      _strainLowerFence = widget.skill!.strainLowerFence;
      _strainUpperFence = widget.skill!.strainUpperFence;
      _tags.addAll(widget.skill!.tags);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _showErrorDialog(BuildContext context, String message) {
    if (!mounted) return;
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

  Future<void> _saveSkill() async {
    if (!_formKey.currentState!.validate()) return;
    if (_strainLowerFence > _strainUpperFence) {
      _showErrorDialog(context, 'Lower fence cannot be greater than upper fence');
      return;
    }

    final viewModel = context.read<SkillViewModel>();

    try {
      if (widget.skill == null) {
        await viewModel.createSkill(
          name: _nameController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          strainLowerFence: _strainLowerFence,
          strainUpperFence: _strainUpperFence,
          tags: _tags,
        );
      } else {
        await viewModel.updateSkill(
          widget.skill!,
          name: _nameController.text,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          isActive: _isActive,
          tags: _tags,
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(context, viewModel.errorMessage ?? context.l10n.errorOccurred);
      }
    }
  }

  Future<void> _deleteSkill() async {
    final viewModel = context.read<SkillViewModel>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.delete),
        content: Text(context.l10n.deleteConfirmation),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await viewModel.deleteSkill(widget.skill!);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog(context, viewModel.errorMessage ?? context.l10n.errorOccurred);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isEditing = widget.skill != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit ${widget.skill!.name}' : l10n.skills),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteSkill,
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
                labelText: l10n.skillName,
                filled: true,
              ),
              validator: (value) => (value == null || value.isEmpty) ? l10n.pleaseEnterName : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: l10n.skillDescription,
                filled: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Text('Strain Range', style: theme.textTheme.titleMedium),
            RangeSlider(
              values: RangeValues(_strainLowerFence.toDouble(), _strainUpperFence.toDouble()),
              min: 0,
              max: 100,
              divisions: 100,
              labels: RangeLabels('$_strainLowerFence', '$_strainUpperFence'),
              onChanged: (values) {
                setState(() {
                  _strainLowerFence = values.start.round();
                  _strainUpperFence = values.end.round();
                });
              },
            ),
            if (isEditing)
              SwitchListTile(
                title: Text(l10n.active),
                value: _isActive,
                onChanged: (value) => setState(() => _isActive = value),
              ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveSkill,
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );
  }
}
