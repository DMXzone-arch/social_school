import 'package:flutter/material.dart';

import '../../../core/widgets/responsive.dart';
import '../../../core/widgets/states.dart';
import '../../../repositories/opportunity_repository.dart';
import '../opportunities/opportunity_detail_view.dart';
import '../opportunities/widgets/opportunity_card.dart';

/// Opportunities the signed-in student saved.
///
/// Reached from the profile page's "Saved opportunities" action row; the
/// profile itself no longer inlines the list.
class SavedOpportunitiesView extends StatelessWidget {
  const SavedOpportunitiesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved opportunities')),
      body: ListenableBuilder(
        listenable: OpportunityRepository.instance,
        builder: (context, _) {
          final saved = OpportunityRepository.instance.saved;
          if (saved.isEmpty) {
            return const EmptyState(
              icon: Icons.school_outlined,
              title: 'No saved opportunities',
              message: 'Save scholarships or internships to track their deadlines.',
            );
          }

          return CenteredContent(
            maxWidth: 680,
            child: ListView.separated(
              itemCount: saved.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final opportunity = saved[index];
                return OpportunityCard(
                  opportunity: opportunity,
                  onOpen: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => OpportunityDetailView(opportunityId: opportunity.id),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
