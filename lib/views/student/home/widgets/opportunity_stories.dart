import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../models/enums.dart';
import '../../../../models/opportunity.dart';
import '../../../../repositories/opportunity_repository.dart';
import '../../opportunities/opportunity_detail_view.dart';

/// Facebook-Lite-style horizontal stories strip at the top of the home feed —
/// instead of friends' stories, each tile is an advertisement for a live
/// opportunity. Tapping a tile opens the opportunity's detail page.
///
/// FUTURE BACKEND INTEGRATION POINT (Supabase): source tiles from an
/// `opportunities` table filtered by `promoted = true`, ordered by deadline.
class OpportunityStories extends StatelessWidget {
  const OpportunityStories({super.key});

  @override
  Widget build(BuildContext context) {
    final ads = OpportunityRepository.instance.published.take(8).toList();
    if (ads.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 8),
          child: Text('Opportunities',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
        ),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: ads.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) => _StoryAdTile(opportunity: ads[index]),
          ),
        ),
      ],
    );
  }
}

/// One story-sized opportunity advertisement.
class _StoryAdTile extends StatelessWidget {
  const _StoryAdTile({required this.opportunity});

  final Opportunity opportunity;

  ({Color color, IconData icon, String asset}) get _style =>
      switch (opportunity.category) {
        OpportunityCategory.scholarship => (
            color: AppColors.primary,
            icon: Icons.school_outlined,
            asset: 'assets/opportunities/scholarship.jpg'),
        OpportunityCategory.internship => (
            color: AppColors.teal,
            icon: Icons.work_outline,
            asset: 'assets/opportunities/internship.jpg'),
        OpportunityCategory.competition => (
            color: AppColors.gold,
            icon: Icons.emoji_events_outlined,
            asset: 'assets/opportunities/competition.jpg'),
        OpportunityCategory.training => (
            color: const Color(0xFF6D28D9),
            icon: Icons.workspace_premium_outlined,
            asset: 'assets/opportunities/training.jpg'),
        OpportunityCategory.conference => (
            color: const Color(0xFF0369A1),
            icon: Icons.groups_outlined,
            asset: 'assets/opportunities/conference.jpg'),
        OpportunityCategory.youthProgramme => (
            color: AppColors.success,
            icon: Icons.diversity_3_outlined,
            asset: 'assets/opportunities/youth.jpg'),
      };

  @override
  Widget build(BuildContext context) {
    final style = _style;
    final days = daysUntil(opportunity.deadline);

    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => OpportunityDetailView(opportunityId: opportunity.id),
        ),
      ),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 118,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          // Fallback gradient shown while the bundled art loads (or on the
          // web build before the asset resolves).
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [style.color, style.color.withValues(alpha: 0.72)],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              style.asset,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
            // Text scrim so white copy stays readable over the art.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge ---------------------------------------
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.22),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(style.icon, size: 16, color: Colors.white),
                  ),
                  const Spacer(),
                  Text(
                    opportunity.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    opportunity.provider,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Deadline urgency -------------------------------------
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      days < 0 ? 'Closed' : days == 0 ? 'Closes today' : '${days}d left',
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: days <= 3 ? AppColors.error : style.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
