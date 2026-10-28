// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:social_school/app.dart';
import 'package:social_school/repositories/auth_repository.dart';
import 'package:social_school/views/student/chats/widgets/community_card.dart';
import 'package:social_school/views/student/chats/widgets/conversation_tile.dart';
import 'package:social_school/views/student/library/widgets/resource_card.dart';
import 'package:social_school/views/student/opportunities/widgets/opportunity_card.dart';
import 'package:social_school/views/student/profile/edit_profile_view.dart';

/// Renders the student app at the exact logical size of the test phone
/// (1080×2412 px @ 3× ⇒ 360×804 dp), visits every screen — including register,
/// settings and dialog flows — and drains each reported exception with
/// [WidgetTester.takeException]. Fails if anything overflows, if an unexpected
/// error appears, or if a "ListTile background color" visibility warning fires.
void main() {
  testWidgets(
    'No layout overflows on a phone-sized screen',
    timeout: const Timeout(Duration(minutes: 3)),
    (tester) async {
      // Record the exact source location of every overflow by wrapping the
      // test binding's own error handler (forwarding to it so the framework's
      // takeException mechanism keeps working).
      final overflows = <String>[];
      final oldOnError = FlutterError.onError;
      FlutterError.onError = (details) {
        // Forward to the binding so tester.takeException() keeps working.
        oldOnError?.call(details);
      };
      addTearDown(() => FlutterError.onError = oldOnError);

      final unexpected = <String>[];
      final cosmetic = <String>[];

      void collect(String step) {
        var guard = 0;
        while (true) {
          final Object? error;
          try {
            error = tester.takeException();
          } catch (_) {
            break; // takeException itself complaining — nothing pending
          }
          if (error == null) break;
          final text = error.toString();
          if (text.contains('overflowed')) {
            overflows.add('[$step] ${text.split('\n').first}');
          } else if (text.contains('ListTile background color')) {
            cosmetic.add('[$step] ${text.split('\n').first}');
          } else {
            unexpected.add('[$step] $text');
          }
          if (++guard > 50) break;
        }
      }

      tester.view.physicalSize = const Size(1080, 2412);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      Future<void> settle([int pumps = 3]) async {
        for (var i = 0; i < pumps; i++) {
          await tester.pump(const Duration(milliseconds: 500));
        }
      }

      Future<void> scrollDown() async {
        final scrollables = find.byType(Scrollable);
        if (scrollables.evaluate().isEmpty) return;
        await tester.drag(scrollables.first, const Offset(0, -500));
        await settle(2);
      }

      Future<void> backOrSkip() async {
        final back = find.byType(BackButton);
        final appBarBack = find.byTooltip('Back');
        if (back.evaluate().isNotEmpty) {
          await tester.tap(back.first, warnIfMissed: false);
        } else if (appBarBack.evaluate().isNotEmpty) {
          await tester.tap(appBarBack.first, warnIfMissed: false);
        }
      }

      Future<void> openAndBack(Finder finder, String step) async {
        if (finder.evaluate().isEmpty) return;
        await tester.tap(finder.first, warnIfMissed: false);
        await settle(3);
        collect('$step detail');
        await backOrSkip();
        await settle(3);
        collect('$step back');
      }

      print('step: pump app');
      await tester.pumpWidget(const SocialSchoolApp());
      await settle();
      collect('welcome');

      print('step: register');
      AuthRepository.instance.goToRegister();
      await settle(3);
      collect('register');
      // Toggle the terms checkbox so its rebuild path is covered too.
      final terms = find.byType(CheckboxListTile);
      if (terms.evaluate().isNotEmpty) {
        await tester.tap(terms.first, warnIfMissed: false);
        await settle(2);
        collect('register checkbox toggled');
      }
      AuthRepository.instance.goToSignIn();
      await settle(3);
      collect('back on sign in');

      print('step: sign in');
      final signIn = AuthRepository.instance.signIn(
        email: 'student@demo.com',
        password: 'demo1234',
      );
      await settle(3);
      await signIn;
      await settle(4);
      collect('signed in');

      print('step: feed');
      await scrollDown();
      await scrollDown();
      collect('feed');

      print('step: library');
      await tester.tap(find.byIcon(Icons.menu_book_outlined));
      await settle(4);
      await scrollDown();
      await scrollDown();
      collect('library');
      await openAndBack(find.byType(ResourceCard), 'resource');
      collect('library after detail');

      print('step: chats');
      await tester.tap(find.byIcon(Icons.chat_bubble_outline_rounded));
      await settle(4);
      await scrollDown();
      collect('chats');
      await openAndBack(find.byType(ConversationTile), 'conversation');
      collect('chats after detail');
      // Conversation info dialog (contains ListTiles inside a dialog).
      if (find.byType(ConversationTile).evaluate().isNotEmpty) {
        await tester.tap(find.byType(ConversationTile).first, warnIfMissed: false);
        await settle(3);
        final infoButton = find.byTooltip('Conversation info');
        if (infoButton.evaluate().isNotEmpty) {
          await tester.tap(infoButton.first, warnIfMissed: false);
          await settle(3);
          collect('conversation info dialog');
          final close = find.widgetWithText(TextButton, 'Close');
          if (close.evaluate().isNotEmpty) {
            await tester.tap(close.first, warnIfMissed: false);
            await settle(3);
          }
        }
        await backOrSkip();
        await settle(3);
        collect('chats after info dialog');
      }

      print('step: communities');
      final communitiesButton = find.widgetWithText(OutlinedButton, 'Communities');
      if (communitiesButton.evaluate().isNotEmpty) {
        await tester.tap(communitiesButton);
        await settle(4);
        collect('communities');
        await scrollDown();
        collect('communities scrolled');
        await openAndBack(find.byType(CommunityCard), 'community');
        if (find.byType(CommunityCard).evaluate().isNotEmpty) {
          await tester.tap(find.byType(CommunityCard).first, warnIfMissed: false);
          await settle(4);
          await scrollDown();
          await scrollDown();
          collect('community detail');
          await backOrSkip();
          await settle(3);
        }
        await backOrSkip();
        await settle(3);
        collect('back to chats');
      }

      print('step: opportunities');
      await tester.tap(find.byIcon(Icons.school_outlined));
      await settle(4);
      await scrollDown();
      await scrollDown();
      collect('opportunities');
      await openAndBack(find.byType(OpportunityCard), 'opportunity');
      collect('opportunities after detail');

      print('step: profile');
      await tester.tap(find.byIcon(Icons.person_outline_rounded));
      await settle(4);
      await scrollDown();
      collect('profile');
      await openAndBack(find.byType(EditProfileView), 'edit profile');
      collect('profile after detail');

      print('step: settings');
      final accountMenu = find.byTooltip('Account menu');
      if (accountMenu.evaluate().isNotEmpty) {
        await tester.tap(accountMenu.first, warnIfMissed: false);
        await settle(3);
        final settingsItem = find.widgetWithText(PopupMenuItem<String>, 'Settings');
        if (settingsItem.evaluate().isNotEmpty) {
          await tester.tap(settingsItem.first, warnIfMissed: false);
          await settle(3);
          await scrollDown();
          collect('settings');
        }
        await backOrSkip();
        await settle(3);
        collect('settings back');
      }

      print('step: drain timers');
      for (var i = 0; i < 6; i++) {
        await tester.pump(const Duration(seconds: 2));
      }
      collect('final');
      print('step: done (overflows=${overflows.length}, '
          'unexpected=${unexpected.length}, cosmetic=${cosmetic.length})');

      // Restore error handling BEFORE asserting (required by flutter_test).
      FlutterError.onError = oldOnError;

      expect(
        overflows,
        isEmpty,
        reason: 'Layout overflows at 360×804 dp:\n'
            '${overflows.join('\n')}',
      );
      expect(
        unexpected,
        isEmpty,
        reason: 'Unexpected errors:\n${unexpected.join('\n')}',
      );
      expect(
        cosmetic,
        isEmpty,
        reason: 'ListTile background/ink visibility warnings:\n'
            '${cosmetic.join('\n')}',
      );
    },
  );
}
