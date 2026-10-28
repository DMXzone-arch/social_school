# Social School

**Learn together. Connect. Grow.**

A **mock-data-only frontend prototype** of a student social learning platform:
students connect with classmates, read school announcements, download study
resources from a digital library, join communities, discover opportunities —
and a **separate admin app** moderates all of it. Built with Flutter for
**Android + web** from one codebase.

> **This is a prototype.** There is **no backend of any kind** — no Supabase,
> no Cloudflare R2, no Firebase, no APIs, no keys, no real emails or uploads.
> Every account, post, book, chat and report is **fictional demo content**
> (labelled DEMO where shown). No data ever leaves the device.

---

## The two apps

The student app and the admin app are **two separate apps** with their own
entry points. The student app contains **no admin UI** at all.

| | Student app | Admin app |
|---|---|---|
| Entry point | `lib/main.dart` | `lib/main_admin.dart` |
| Demo sign-in | `student@demo.com` / `demo1234` | `admin@demo.com` / `admin1234` |
| Auth behaviour | Any valid email + 6+ char password works (simulated) | Any valid email + 6+ char password works (simulated) |

Despite being separate apps, they **share the same demo world**: approving a
resource in the admin app makes it appear in the student library, publishing an
announcement adds it to the student feed, publishing an opportunity lists it
for students, and so on. This is achieved with **local device/browser storage**
(a clearly-labelled prototype mechanism, see `lib/data/demo_state_store.dart`)
— nothing is uploaded anywhere. Admin → **Storage & Settings** → *Reset demo
data* reseeds the original sample content in both apps.

## Run it

```bash
flutter pub get

# Student app
flutter run -d chrome                       # web
flutter run                                 # Android (emulator/device)

# Admin app (separate entry point)
flutter run -d chrome -t lib/main_admin.dart
```

Release builds:

```bash
flutter build apk                           # Android -> build/app/outputs/flutter-apk/
flutter build web                           # student web app -> build/web/
flutter build web -t lib/main_admin.dart    # admin web app  -> build/web/
```

## What's inside

**Student app** — bottom navigation with 5 destinations:

- **Home** — social feed: posts, school/admin announcements, likes, comments,
  post reporting, demo composer.
- **Library** — digital library with subject/level search, simulated downloads
  (progress states), bookmarks, mock PDF preview, resource reporting.
- **Chats** — mutual-approval messaging: you can only chat after the other
  student accepts your request (incoming/outgoing request flows); group chats
  unlock via communities; block/report actions.
- **Communities** — join/leave subject & cause communities (some require
  admin-style approval), community feed + group chat.
- **Opportunities** — scholarships, internships, trainings, competitions with
  deadlines, eligibility, verification badges; expired listings excluded.
- **Profile** — profile editing, settings, notification centre.

Onboarding: welcome → register → simulated email verification → profile setup
→ app.

**Admin app** — sign-in + 9 sections (desktop sidebar / mobile drawer):

1. **Dashboard** — demo statistics + recent admin activity.
2. **Resource Management** — approve / reject (with reason) / archive /
   restore / edit metadata / delete; preview; simulated upload form with
   rights confirmation.
3. **Feed Management** — publish announcements to the student feed, remove /
   restore posts.
4. **Opportunities** — create / publish / unpublish / verify / set deadline /
   delete listings.
5. **User Management** — search, suspend / restore demo accounts.
6. **Reports & Moderation** — queue of user reports with detail panel,
   resolve / dismiss with notes.
7. **Institutions** — add / remove fictional institutions.
8. **Storage & Settings** — illustrative storage figures, file-type
   distribution, **Reset demo data**.
9. **Audit Log** — every admin action, newest first.

## Project structure (MVVM)

```
lib/
  main.dart                  # student app entry point
  main_admin.dart            # admin app entry point (separate app)
  app.dart                   # student MaterialApp + auth-stage routing
  admin_app.dart             # admin MaterialApp + sign-in routing
  core/
    constants/               # AppColors, AppConstants (brand palette, tagline)
    theme/                   # Material 3 theme (re-exports AppColors)
    utils/                   # date/time/relative formatters
    widgets/                 # reusable kit: SSCard, StatusPill, AppButton,
                             # AppTextField, ResponsiveBuilder/CenteredContent,
                             # EmptyState, skeletons, search, chips…
  models/                    # plain data classes + enums (no Flutter widgets)
  data/
    mock_data.dart           # single source of ALL demo content
    demo_state_store.dart    # prototype-only local sync between the two apps
  repositories/              # ChangeNotifier singletons = the "backend":
                             # auth, feed, library, chat, community,
                             # opportunity, notification, admin
  viewmodels/                # per-feature UI state (feed, library, chat,
                             # opportunity)
  views/
    auth/                    # welcome, register, sign-in, verify, setup
    student/                 # student shell + home/library/chats/opportunities/
                             # profile screens and their private widgets
    admin/                   # admin shell + 9 section screens + widgets
```

**How the layers talk to each other**

```
View  ──listens to──►  ViewModel  ──calls──►  Repository  ──reads/writes──►  Model
                                                     ▲
                                          MockData (demo seed data)
```

Rules of thumb for easy editing:

- Change **how something looks** → `views/` + `core/theme/` + `core/widgets/`.
- Change **screen behaviour / state** → `viewmodels/`.
- Change **data & business rules** (incl. admin cross-effects) → `repositories/`.
- Change **sample content** → `lib/data/mock_data.dart` only.
- Shared reusable widgets live in `core/widgets/` (`ui_kit.dart`,
  `forms.dart`, `states.dart`, `responsive.dart`); screen-private widgets live
  next to their screen in `widgets/`.

## Responsive layout

| Breakpoint | Layout |
|---|---|
| **< 600 px** (mobile) | Bottom navigation bar, drawer menus, card lists |
| **600–1023 px** (tablet) | Wider cards/grids, still bottom navigation |
| **≥ 1024 px** (desktop) | Persistent sidebars, centred content (`CenteredContent`), data **tables** in admin (resources, users, reports, institutions), split views in chats |

Implemented with `core/widgets/responsive.dart` (`ResponsiveBuilder`,
`ScreenType`, `screenTypeOf`) — one codebase adapts automatically.

## Future backend integration points

This prototype is structured so a real backend can be added **only inside
`repositories/`** — no view or viewmodel changes needed. The integration
points are documented in code (search for `FUTURE BACKEND INTEGRATION POINT`):

- **Supabase (data + auth)**
  - `auth_repository.dart` → Supabase Auth (email verification, sessions).
  - `feed_repository.dart` → `posts` / `comments` tables + realtime
    subscriptions.
  - `library_repository.dart` → `resources` table (status workflow =
    moderation columns).
  - `chat_repository.dart` → `conversations` / `messages` tables + realtime,
    mutual-approval as a `requests` table.
  - `community_repository.dart`, `opportunity_repository.dart`,
    `notification_repository.dart` → respective tables.
  - `admin_repository.dart` → same tables guarded by row level security with
    an `is_admin` claim; `audit_log` table for admin actions.
- **Cloudflare R2 (files)**
  - Resource PDFs uploaded to an R2 bucket; `mock_pdf_preview.dart` and
    `download_button.dart` swap simulated progress for presigned URL
    downloads.
- **Prototype-only code to delete later**: `lib/data/demo_state_store.dart`
  (local-storage sync between the two apps) and the simulated latencies inside
  the repositories.

## Tests

```bash
flutter test     # mock-data minimum counts, student-visibility rules,
                 # welcome-screen smoke test
flutter analyze  # zero issues
```
