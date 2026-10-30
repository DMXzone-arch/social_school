# Social School

**Learn together. Connect. Grow.**

A **mock-data-only frontend prototype** of a student social learning platform:
students connect with classmates, read school announcements, download study
resources from a digital library, join communities, discover opportunities —
all from one Flutter codebase built for **Android + web**.

> **This is a prototype.** There is **no backend of any kind** — no Supabase,
> no Cloudflare R2, no Firebase, no APIs, no keys, no real emails or uploads.
> Every account, post, book, chat and report is **fictional demo content**
> (labelled DEMO where shown). No data ever leaves the device.

---

## One app: the student app

This project contains **only the student app** — no admin UI and no admin
entry point exist here. The admin/moderation app that once shared this
codebase has been split out into a **separate project**; it is maintained
independently and is not built from this repository.

The student app still *files* moderation data (report a post, chat, resource
or opportunity) into `lib/repositories/report_repository.dart` — reviewing
those reports happens in the separate admin project.

| | Student app |
|---|---|
| Entry point | `lib/main.dart` |
| Demo sign-in | `student@demo.com` / `demo1234` |
| Auth behaviour | Any valid email + 6+ char password works (simulated) |

Prototype state is kept in **local device/browser storage** (a
clearly-labelled prototype mechanism, see `lib/data/demo_state_store.dart`)
— nothing is uploaded anywhere, and changes survive a relaunch.

## Run it

```bash
flutter pub get

# Student app
flutter run -d chrome                       # web
flutter run                                 # Android (emulator/device)
```

Release builds:

```bash
flutter build apk                           # Android -> build/app/outputs/flutter-apk/
flutter build web                           # web     -> build/web/
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
  approval to join), community feed + group chat.
- **Opportunities** — scholarships, internships, trainings, competitions with
  deadlines, eligibility, verification badges; expired listings excluded.
- **Profile** — profile editing, settings, notification centre.

Onboarding: welcome → register → simulated email verification → profile setup
→ app.

## Project structure (MVVM)

```
lib/
  main.dart                  # student app entry point
  app.dart                   # student MaterialApp + auth-stage routing
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
    demo_state_store.dart    # prototype-only local persistence of demo state
  repositories/              # ChangeNotifier singletons = the "backend":
                             # auth, feed, library, chat, community,
                             # opportunity, notification, report
  viewmodels/                # per-feature UI state (feed, library, chat,
                             # opportunity)
  views/
    auth/                    # welcome, register, sign-in, verify, setup
    student/                 # student shell + home/library/chats/opportunities/
                             # profile screens and their private widgets
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
- Change **data & business rules** → `repositories/`.
- Change **sample content** → `lib/data/mock_data.dart` only.
- Shared reusable widgets live in `core/widgets/` (`ui_kit.dart`,
  `forms.dart`, `states.dart`, `responsive.dart`); screen-private widgets live
  next to their screen in `widgets/`.

## Responsive layout

| Breakpoint | Layout |
|---|---|
| **< 600 px** (mobile) | Bottom navigation bar, drawer menus, card lists |
| **600–1023 px** (tablet) | Wider cards/grids, still bottom navigation |
| **≥ 1024 px** (desktop) | Persistent sidebars, centred content (`CenteredContent`), split views in chats |

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
  - `report_repository.dart` → `reports` table guarded by row level security
    (students insert, moderators read).
- **Cloudflare R2 (files)**
  - Resource PDFs uploaded to an R2 bucket; `mock_pdf_preview.dart` and
    `download_button.dart` swap simulated progress for presigned URL
    downloads.
- **Prototype-only code to delete later**: `lib/data/demo_state_store.dart`
  (local-storage persistence of the demo world) and the simulated latencies
  inside the repositories.

## Tests

```bash
flutter test     # mock-data minimum counts, student-visibility rules,
                 # welcome-screen smoke test
flutter analyze  # zero issues
```
