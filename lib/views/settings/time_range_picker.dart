import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

class TimeRangePicker extends StatefulWidget {
  final TimeOfDay initialStartTime;
  final TimeOfDay initialEndTime;

  const TimeRangePicker({
    super.key,
    required this.initialStartTime,
    required this.initialEndTime,
  });

  @override
  State<TimeRangePicker> createState() => _TimeRangePickerState();
}

class _TimeRangePickerState extends State<TimeRangePicker> {
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _startTime = widget.initialStartTime;
    _endTime = widget.initialEndTime;
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
      helpText: context.l10n.selectSleepStart,
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
      helpText: context.l10n.selectSleepEnd,
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(l10n.setSleepTime),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.sleepTimeDescription,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ListTile(
            title: Text(l10n.sleepStart),
            subtitle: Text(_formatTime(_startTime)),
            trailing: const Icon(Icons.schedule),
            onTap: _selectStartTime,
          ),
          ListTile(
            title: Text(l10n.sleepEnd),
            subtitle: Text(_formatTime(_endTime)),
            trailing: const Icon(Icons.schedule),
            onTap: _selectEndTime,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, (_startTime, _endTime));
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
