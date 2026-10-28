import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:social_school/core/widgets/forms.dart';

/// Regression test: AppDateField must open its calendar even when lastDate is
/// in the past (date of birth with a minimum-age limit) and nothing is picked
/// yet — previously showDatePicker's initialDate assertion silently failed.
void main() {
  testWidgets('opens calendar when lastDate is in the past and value is null',
      (tester) async {
    DateTime? picked;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => AppDateField(
              label: 'Date of birth',
              value: picked,
              firstDate: DateTime(1920, 1, 1),
              lastDate: DateTime(2016, 1, 1), // "10 years ago" style limit
              onChanged: (d) => setState(() => picked = d),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byType(InputDecorator));
    await tester.pumpAndSettle();

    // Calendar is visible.
    expect(find.byType(DatePickerDialog), findsOneWidget);
    expect(tester.takeException(), isNull);

    // Pick a date and confirm it is reported back.
    await tester.tap(find.text('15').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(picked, isNotNull);
    expect(find.byType(DatePickerDialog), findsNothing);
  });
}
