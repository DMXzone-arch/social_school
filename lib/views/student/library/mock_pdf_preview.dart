import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/ui_kit.dart';
import '../../../../models/enums.dart';
import '../../../../models/resource.dart';

/// Reusable simulated PDF reader/preview.
///
/// No real file exists in the prototype — this renders clearly labelled
/// sample content so downloads never lead to broken links.
class MockPdfPreviewScreen extends StatelessWidget {
  const MockPdfPreviewScreen({required this.resource, super.key});

  final LibraryResource resource;

  @override
  Widget build(BuildContext context) {
    final pages = [
      resource.title,
      'About this sample preview',
      'Practice questions (sample)',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(resource.title, overflow: TextOverflow.ellipsis),
        actions: const [DemoBadge(label: 'SAMPLE PREVIEW'), SizedBox(width: 12)],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
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
                    'Preview of the first page. Download the file to read '
                    'the full document.',
                    style: TextStyle(fontSize: 12.5, color: Color(0xFF8A6100)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < pages.length; i++) ...[
            _PdfPage(pageNumber: i + 1, total: pages.length, title: pages[i], resource: resource),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }
}

class _PdfPage extends StatelessWidget {
  const _PdfPage({
    required this.pageNumber,
    required this.total,
    required this.title,
    required this.resource,
  });

  final int pageNumber;
  final int total;
  final String title;
  final LibraryResource resource;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        boxShadow: const [BoxShadow(color: Color(0x0A1F2937), blurRadius: 10, offset: Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              ),
              Text('Page $pageNumber of $total',
                  style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
            ],
          ),
          const Divider(height: 24),
          Text(
            '${resource.subject} · ${educationLevelLabel(resource.level)} · '
            'Source: ${resource.author}',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Text(_sampleBody(pageNumber), style: const TextStyle(height: 1.6, fontSize: 13.5)),
        ],
      ),
    );
  }

  String _sampleBody(int page) => switch (page) {
        1 =>
          'Welcome, member! Here is the first page of '
              '"${resource.title}".\n\n${resource.description}',
        2 =>
              'Continue reading for the full ${resource.fileType} '
              '(${resource.fileSize}), available to download below.',
        _ =>
          'Sample practice questions would appear here:\n\n'
              '1. Define the key terms from your ${resource.subject} syllabus.\n'
              '2. Explain the main process covered in this chapter.\n'
              '3. Attempt the past-style question at the end of the section.',
      };
}
