import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/forms.dart';
import '../../../../models/post.dart';

const int kMaxPostLength = 500;

/// Reusable composer dialog for creating or editing a text post.
///
/// Returns `(content, withImage)` or `null` when cancelled.
Future<(String, bool)?> showPostComposer(BuildContext context, {Post? existing}) {
  return showDialog<(String, bool)>(
    context: context,
    builder: (_) => _PostComposerDialog(existing: existing),
  );
}

class _PostComposerDialog extends StatefulWidget {
  const _PostComposerDialog({this.existing});

  final Post? existing;

  @override
  State<_PostComposerDialog> createState() => _PostComposerDialogState();
}

class _PostComposerDialogState extends State<_PostComposerDialog> {
  late final TextEditingController _controller;
  bool _withImage = false;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.existing?.content ?? '');
    _withImage = widget.existing?.hasImage ?? false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Write something before posting.');
      return;
    }
    if (text.length > kMaxPostLength) {
      setState(() => _error = 'Posts are limited to $kMaxPostLength characters.');
      return;
    }
    setState(() => _submitting = true);
    Navigator.of(context).pop((text, _withImage));
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final remaining = kMaxPostLength - _controller.text.length;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(isEdit ? 'Edit post' : 'Create post',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              maxLines: 5,
              minLines: 3,
              onChanged: (_) => setState(() => _error = null),
              decoration: const InputDecoration(
                hintText: 'Share a study tip, question or update…',
                filled: true,
                fillColor: AppColors.background,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Flexible(
                  child: Text(
                    '$remaining characters left',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: remaining < 0 ? AppColors.error : AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (!isEdit)
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onPressed: () => setState(() => _withImage = !_withImage),
                    icon: Icon(
                      _withImage ? Icons.check_box_rounded : Icons.image_outlined,
                      size: 18,
                      color: _withImage ? AppColors.teal : AppColors.textSecondary,
                    ),
                    label: Text(
                      _withImage ? 'Image attached' : 'Attach image',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: _withImage ? AppColors.teal : AppColors.textSecondary,
                      ),
                    ),
                  ),
              ],
            ),
            if (_withImage)
              Container(
                margin: const EdgeInsets.only(top: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.photo_library_outlined, size: 16, color: AppColors.teal),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tap to add a photo from your gallery.',
                        style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 12.5)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _submitting ? null : () => Navigator.pop(context),
          child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        AppButton(
          label: isEdit ? 'Save changes' : 'Post',
          expanded: false,
          onPressed: _submit,
        ),
      ],
    );
  }
}
