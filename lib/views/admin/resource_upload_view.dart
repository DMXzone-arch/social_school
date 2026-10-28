import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/forms.dart';
import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/ui_kit.dart';
import '../../../models/enums.dart';
import '../../../models/resource.dart';
import '../../../repositories/admin_repository.dart';

/// Simulated resource upload form.
///
/// The file selector only reads local metadata — nothing is uploaded to any
/// server or cloud storage in this prototype.
class ResourceUploadView extends StatefulWidget {
  const ResourceUploadView({super.key});

  @override
  State<ResourceUploadView> createState() => _ResourceUploadViewState();
}

class _ResourceUploadViewState extends State<ResourceUploadView> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final _subject = TextEditingController();
  final _institution = TextEditingController();
  final _source = TextEditingController();

  EducationLevel _level = EducationLevel.secondary;
  ResourceCategory _category = ResourceCategory.revisionNotes;
  bool _rightsConfirmed = false;
  String? _fileName;
  double _fileSizeMb = 2.5;
  bool _submitting = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _subject.dispose();
    _institution.dispose();
    _source.dispose();
    super.dispose();
  }

  /// Simulated file picker: attaches fake local metadata only.
  void _pickFile() {
    setState(() {
      _fileName = 'sample-document.pdf';
      _fileSizeMb = 1.2 + (_title.text.length % 8) * 0.7;
    });
    showAppSnackbar(context, 'Selected a local sample file (nothing was uploaded).');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_rightsConfirmed) {
      showAppSnackbar(context, 'Please confirm you have the rights to share this file.', error: true);
      return;
    }
    if (_fileName == null) {
      showAppSnackbar(context, 'Please attach a file (simulated).', error: true);
      return;
    }

    setState(() => _submitting = true);
    final resource = LibraryResource(
      id: 'r${DateTime.now().millisecondsSinceEpoch}',
      title: _title.text.trim(),
      description: _description.text.trim(),
      subject: _subject.text.trim(),
      level: _level,
      institution: _institution.text.trim().isEmpty ? 'General (demo)' : _institution.text.trim(),
      category: _category,
      author: _source.text.trim().isEmpty ? 'Unknown (demo)' : _source.text.trim(),
      fileType: 'PDF',
      fileSize: '${_fileSizeMb.toStringAsFixed(1)} MB',
      fileSizeMb: _fileSizeMb,
      dateAdded: DateTime.now(),
      status: ResourceStatus.pendingReview,
      submittedBy: 'Demo Admin',
    );

    await AdminRepository.instance.submitResource(resource);
    if (!mounted) return;
    showAppSnackbar(context, 'Submitted for review — appears as Pending in the queue.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Resource')),
      body: CenteredContent(
        maxWidth: 720,
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  border: Border.all(color: AppColors.gold),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF8A6100)),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Simulated upload: the selected file is never sent to a '
                        'server or cloud storage. Only local metadata is shown below.',
                        style: TextStyle(fontSize: 12.5, color: Color(0xFF8A6100), height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SSCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      label: 'Resource title',
                      hint: 'e.g. Mathematics Revision Guide — Form 4',
                      controller: _title,
                      validator: (v) => (v == null || v.trim().length < 4) ? 'Enter a title' : null,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Description',
                      hint: 'What does this resource cover?',
                      controller: _description,
                      maxLines: 3,
                      validator: (v) => (v == null || v.trim().length < 10)
                          ? 'Add a short description (10+ characters)'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Subject',
                      hint: 'e.g. Mathematics',
                      controller: _subject,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter a subject' : null,
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 14,
                      runSpacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SizedBox(
                          width: 220,
                          child: DropdownButtonFormField<EducationLevel>(
                            initialValue: _level,
                            decoration: _inputDecoration('Education level'),
                            items: [
                              for (final level in EducationLevel.values)
                                DropdownMenuItem(
                                  value: level,
                                  child: Text(educationLevelLabel(level)),
                                ),
                            ],
                            onChanged: (v) => setState(() => _level = v ?? _level),
                          ),
                        ),
                        SizedBox(
                          width: 240,
                          child: DropdownButtonFormField<ResourceCategory>(
                            initialValue: _category,
                            decoration: _inputDecoration('Resource category'),
                            items: [
                              for (final category in ResourceCategory.values)
                                DropdownMenuItem(
                                  value: category,
                                  child: Text(resourceCategoryLabel(category)),
                                ),
                            ],
                            onChanged: (v) => setState(() => _category = v ?? _category),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Institution or programme',
                      hint: 'e.g. Kambiri University (fictional)',
                      controller: _institution,
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Source and attribution',
                      hint: 'e.g. Demo Mathematics Department',
                      controller: _source,
                    ),
                    const Divider(height: 30),

                    // File selector (local-only) --------------------------
                    const Text('File', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _pickFile,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.background,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _fileName == null ? Icons.upload_file_rounded : Icons.description_rounded,
                              color: _fileName == null ? AppColors.textSecondary : AppColors.teal,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _fileName ?? 'Choose a file (local only — nothing is uploaded)',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w600,
                                      color: _fileName == null
                                          ? AppColors.textSecondary
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  if (_fileName != null)
                                    Text(
                                      '$_fileName · ${_fileSizeMb.toStringAsFixed(1)} MB · local preview only',
                                      style: const TextStyle(
                                          fontSize: 11.5, color: AppColors.textSecondary),
                                    ),
                                ],
                              ),
                            ),
                            const Text('Browse', style: TextStyle(color: AppColors.primary, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: _rightsConfirmed,
                      onChanged: (v) => setState(() => _rightsConfirmed = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: const Text(
                        'I confirm I have the rights to share this material and '
                        'it is not unauthorised copyrighted content.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Submit for Review',
                      loading: _submitting,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: 6),
                    const Center(
                      child: Text(
                        'The resource enters the Pending Review queue — it is not '
                        'visible to students until approved.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        filled: true,
        fillColor: AppColors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      );
}
