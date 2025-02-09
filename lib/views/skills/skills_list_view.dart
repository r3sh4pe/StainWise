import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/l10n.dart';
import '../../models/skill.dart';
import '../../viewmodels/skill_viewmodel.dart';
import 'skill_form_view.dart';

class SkillsListView extends StatefulWidget {
  const SkillsListView({super.key});

  @override
  State<SkillsListView> createState() => _SkillsListViewState();
}

class _SkillsListViewState extends State<SkillsListView> {
  String? _selectedTag;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.skills),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showTagFilterDialog(context),
          ),
        ],
      ),
      body: Consumer<SkillViewModel>(
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

          final skills = _selectedTag != null
              ? viewModel.getSkillsByTag(_selectedTag!)
              : viewModel.activeSkills;

          if (skills.isEmpty) {
            return Center(
              child: Text(
                l10n.noSkillsYet,
                style: theme.textTheme.bodyLarge,
              ),
            );
          }

          return ListView.builder(
            itemCount: skills.length,
            padding: const EdgeInsets.all(8),
            itemBuilder: (context, index) {
              final skill = skills[index];
              return SkillListTile(skill: skill);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SkillFormView(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showTagFilterDialog(BuildContext context) {
    final viewModel = context.read<SkillViewModel>();
    final l10n = context.l10n;

    showDialog(
      context: context,
      builder: (context) {
        final tags = viewModel.allTags.toList()..sort();

        return AlertDialog(
          title: Text(l10n.filterByTag),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('All'),
                  selected: _selectedTag == null,
                  onTap: () {
                    setState(() => _selectedTag = null);
                    Navigator.pop(context);
                  },
                ),
                ...tags.map((tag) => ListTile(
                  title: Text(tag),
                  selected: tag == _selectedTag,
                  onTap: () {
                    setState(() => _selectedTag = tag);
                    Navigator.pop(context);
                  },
                )),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SkillListTile extends StatelessWidget {
  final Skill skill;

  const SkillListTile({
    super.key,
    required this.skill,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        title: Text(skill.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (skill.description != null)
              Text(
                skill.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Text(
              l10n.skillRating(skill.averageRating.toStringAsFixed(1)),
              style: theme.textTheme.bodySmall,
            ),
            Text(
              l10n.skillStrainRange(
                skill.strainLowerFence,
                skill.strainUpperFence,
              ),
              style: theme.textTheme.bodySmall,
            ),
            if (skill.tags.isNotEmpty)
              Wrap(
                spacing: 4,
                children: skill.tags.map((tag) => Chip(
                  label: Text(
                    tag,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSecondaryContainer,
                    ),
                  ),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  padding: EdgeInsets.zero,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                )).toList(),
              ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SkillFormView(skill: skill),
            ),
          );
        },
      ),
    );
  }
}