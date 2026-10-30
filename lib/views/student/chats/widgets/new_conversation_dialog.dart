import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/states.dart';
import '../../../../core/widgets/ui_kit.dart';
import '../../../../data/mock_data.dart';
import '../../../../models/admin.dart';
import '../../../../repositories/chat_repository.dart';

/// Opens the student picker for a new conversation and, once a student is
/// chosen, sends the mutual-approval messaging request on their behalf.
Future<void> showNewConversationDialog(BuildContext context) async {
  final target = await showDialog<DemoStudentAccount>(
    context: context,
    builder: (_) => const _NewConversationDialog(),
  );
  if (target != null) {
    await ChatRepository.instance.sendRequest(target);
    if (context.mounted) {
      showAppSnackbar(context, 'Request sent — ${target.fullName} must accept before you can chat.');
    }
  }
}

class _NewConversationDialog extends StatefulWidget {
  const _NewConversationDialog();

  @override
  State<_NewConversationDialog> createState() => _NewConversationDialogState();
}

class _NewConversationDialogState extends State<_NewConversationDialog> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final students = MockData.requestableStudents()
        .where((s) => s.fullName.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('New conversation'),
      content: SizedBox(
        width: 420,
        height: 380,
        child: Column(
          children: [
            Text(
              'Messaging uses mutual approval: the other person must accept '
              'your request before you can chat.',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 10),
            AppSearchField(hint: 'Search people…', onChanged: (v) => setState(() => _query = v)),
            const SizedBox(height: 10),
            Expanded(
              child: students.isEmpty
                  ? const EmptyState(icon: Icons.search_off_rounded, title: 'No people found')
                  : ListView(
                      children: [
                        for (final student in students)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: AvatarCircle(name: student.fullName, radius: 18),
                            title: Text(student.fullName,
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            subtitle: Text(student.institution,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11.5)),
                            trailing: OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                minimumSize: const Size(0, 30),
                                side: const BorderSide(color: AppColors.primary),
                                textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                              ),
                              onPressed: () => Navigator.pop(context, student),
                              child: const Text('Request'),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
      ],
    );
  }
}
