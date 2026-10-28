import 'package:flutter_test/flutter_test.dart';

import 'package:social_school/app.dart';
import 'package:social_school/data/mock_data.dart';
import 'package:social_school/models/enums.dart';
import 'package:social_school/repositories/library_repository.dart';

void main() {
  test('Mock data satisfies the prototype minimum counts', () {
    expect(MockData.resources.length, greaterThanOrEqualTo(12));
    expect(MockData.posts.length, greaterThanOrEqualTo(8));
    expect(MockData.studentAccounts.length, greaterThanOrEqualTo(8));
    expect(MockData.conversations.length, greaterThanOrEqualTo(6));
    expect(MockData.communities.length, greaterThanOrEqualTo(7));
    expect(MockData.opportunities.length, greaterThanOrEqualTo(8));
    expect(MockData.reports.length, greaterThanOrEqualTo(5));
    expect(MockData.auditLog.length, greaterThanOrEqualTo(8));
  });

  test('Only approved resources are visible to students by default', () {
    final visible = LibraryRepository.instance.studentVisible;
    expect(visible, isNotEmpty);
    expect(
      visible.every((r) => r.status == ResourceStatus.approved),
      isTrue,
    );
    // The seeded pending/draft/rejected/archived items stay hidden.
    expect(visible.length, lessThan(MockData.resources.length));
  });

  testWidgets('Student app opens on the sign in screen', (tester) async {
    await tester.pumpWidget(const SocialSchoolApp());
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Welcome back'), findsWidgets);
    expect(find.text('Sign In'), findsWidgets);
    expect(find.text('Create Account'), findsWidgets);
  });
}
