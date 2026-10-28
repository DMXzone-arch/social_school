import '../models/admin.dart';
import '../models/community.dart';
import '../models/conversation.dart';
import '../models/enums.dart';
import '../models/notification_item.dart';
import '../models/opportunity.dart';
import '../models/post.dart';
import '../models/resource.dart';
import '../models/student_profile.dart';

/// Central collection of realistic **fictional** sample data.
///
/// This is the only place with hardcoded arrays. Repositories copy from
/// here into mutable in-memory state, so the UI never depends on raw data.
///
/// NOTE: All names, institutions, providers and files are fictional demo
/// content. No real student data, copyrighted books or live links are used.
class MockData {
  MockData._();

  // ---------------------------------------------------------------------------
  // Education levels, institutions and programmes
  // ---------------------------------------------------------------------------

  static const List<String> subjects = [
    'Mathematics', 'Physics', 'Chemistry', 'Biology', 'English',
    'Computer Science', 'Engineering', 'Business Studies', 'Statistics',
    'Research', 'Technical Drawing', 'Geography', 'Study Skills',
  ];

  static List<Institution> institutions = [
    Institution(id: 'i1', name: 'Nkhata Bay Secondary School', type: InstitutionType.secondary, location: 'Nkhata Bay', programmes: ['MSCE', 'JCE']),
    Institution(id: 'i2', name: 'Chichiri Girls Secondary School', type: InstitutionType.secondary, location: 'Blantyre', programmes: ['MSCE', 'Sciences']),
    Institution(id: 'i3', name: 'Kambiri University', type: InstitutionType.university, location: 'Lilongwe', programmes: ['Computer Science', 'Education', 'Business Studies', 'Engineering']),
    Institution(id: 'i4', name: 'Kasungu University', type: InstitutionType.university, location: 'Kasungu', programmes: ['Business Studies', 'Social Sciences']),
    Institution(id: 'i5', name: 'Lilongwe Institute of Technology', type: InstitutionType.college, location: 'Lilongwe', programmes: ['Electrical Engineering', 'Information Technology']),
    Institution(id: 'i6', name: 'Mzuzu City College', type: InstitutionType.college, location: 'Mzuzu', programmes: ['Accounting', 'Business Studies']),
    Institution(id: 'i7', name: 'Zomba College of Science', type: InstitutionType.college, location: 'Zomba', programmes: ['Statistics', 'Laboratory Technology']),
    Institution(id: 'i8', name: 'Blantyre Technical College', type: InstitutionType.college, location: 'Blantyre', programmes: ['Technical Drawing', 'Building Studies']),
  ];

  // ---------------------------------------------------------------------------
  // Student accounts
  // ---------------------------------------------------------------------------

  /// The demo student used when signing in as `student@demo.com`.
  static StudentProfile demoStudent = StudentProfile(
    id: 'me',
    fullName: 'Chikondi Banda',
    email: 'student@demo.com',
    educationLevel: EducationLevel.university,
    country: 'Malawi',
    institution: 'Kambiri University',
    interests: ['Computer Science', 'Mathematics', 'Debate'],
    bio: 'Second-year CS student. Happy to share revision notes!',
    avatarIndex: kDefaultAvatarIndex,
    age: 20,
    gender: Gender.female,
    district: 'Lilongwe City',
  );

  static List<DemoStudentAccount> studentAccounts = [
    DemoStudentAccount(id: 'u1', fullName: 'Chikondi Banda', email: 'student@demo.com', level: EducationLevel.university, institution: 'Kambiri University', registered: DateTime(2026, 8, 12)),
    DemoStudentAccount(id: 'u2', fullName: 'Tadala Phiri', email: 'tadala.phiri@example.invalid', level: EducationLevel.secondary, institution: 'Chichiri Girls Secondary School', registered: DateTime(2026, 8, 20)),
    DemoStudentAccount(id: 'u3', fullName: 'Mphatso Nyirenda', email: 'mphatso.n@example.invalid', level: EducationLevel.university, institution: 'Kambiri University', registered: DateTime(2026, 8, 21)),
    DemoStudentAccount(id: 'u4', fullName: 'Kondwani Chirwa', email: 'kondwani.c@example.invalid', level: EducationLevel.university, institution: 'Kambiri University', registered: DateTime(2026, 9, 2)),
    DemoStudentAccount(id: 'u5', fullName: 'Lindiwe Zgambo', email: 'lindiwe.z@example.invalid', level: EducationLevel.university, institution: 'Kambiri University', registered: DateTime(2026, 9, 5)),
    DemoStudentAccount(id: 'u6', fullName: 'Blessings Kalua', email: 'blessings.k@example.invalid', level: EducationLevel.college, institution: 'Lilongwe Institute of Technology', registered: DateTime(2026, 9, 9)),
    DemoStudentAccount(id: 'u7', fullName: 'Mary Chasukwa', email: 'mary.c@example.invalid', level: EducationLevel.college, institution: 'Zomba College of Science', registered: DateTime(2026, 9, 14)),
    DemoStudentAccount(id: 'u8', fullName: 'Thoko Kaunda', email: 'thoko.k@example.invalid', level: EducationLevel.university, institution: 'Kasungu University', registered: DateTime(2026, 9, 18)),
    DemoStudentAccount(id: 'u9', fullName: 'Agness Mbewe', email: 'agness.m@example.invalid', level: EducationLevel.secondary, institution: 'Nkhata Bay Secondary School', registered: DateTime(2026, 10, 1)),
    DemoStudentAccount(id: 'u10', fullName: 'Frank Banda', email: 'frank.b@example.invalid', level: EducationLevel.college, institution: 'Blantyre Technical College', registered: DateTime(2026, 10, 6)),
  ];

  // ---------------------------------------------------------------------------
  // Feed posts
  // ---------------------------------------------------------------------------

  static List<Post> posts = [
    Post(
      id: 'p1',
      authorId: null,
      authorName: 'Social School Admin',
      authorInstitution: 'Social School',
      type: PostType.adminAnnouncement,
      title: 'Second semester timetable published',
      content: 'Hello students! The second semester timetable is now available. '
          'Check your institution notices and prepare for classes starting '
          '2 November. Happy studying!',
      timestamp: DateTime(2026, 10, 28, 9, 15),
      likeCount: 46,
      comments: [
        Comment(id: 'cm1', authorName: 'Mphatso Nyirenda', text: 'Thank you! Finally 😅', timestamp: DateTime(2026, 10, 28, 9, 40)),
      ],
    ),
    Post(
      id: 'p2',
      authorId: null,
      authorName: 'Nkhata Bay Secondary — Head Office',
      authorInstitution: 'Nkhata Bay Secondary School',
      type: PostType.schoolAnnouncement,
      title: 'MSCE mock examinations begin 12 November',
      content: 'Form 4 candidates: MSCE mock examinations begin on 12 November '
          'in the main hall. Revision timetables have been shared with your '
          'class teachers. All the best!',
      timestamp: DateTime(2026, 10, 27, 16, 0),
      likeCount: 31,
      comments: [
        Comment(id: 'cm2', authorName: 'Agness Mbewe', text: 'We are ready! 💪', timestamp: DateTime(2026, 10, 27, 16, 20)),
        Comment(id: 'cm3', authorName: 'Tadala Phiri', text: 'Where do we get extra past papers?', timestamp: DateTime(2026, 10, 27, 17, 2)),
      ],
    ),
    Post(
      id: 'p3',
      authorId: 'u2',
      authorName: 'Tadala Phiri',
      authorInstitution: 'Chichiri Girls Secondary School',
      type: PostType.studentPost,
      content: 'Form 4 revision check-in: I\'m doing Maths (Algebra) tonight '
          'from 7pm, then Physics revision questions. Anyone revising with me? '
          'Drop a 🙌 and we can share answers tomorrow.',
      timestamp: DateTime(2026, 10, 28, 14, 2),
      likeCount: 18,
      comments: [
        Comment(id: 'cm4', authorName: 'Agness Mbewe', text: '🙌 Count me in!', timestamp: DateTime(2026, 10, 28, 14, 15)),
        Comment(id: 'cm5', authorName: 'Frank Banda', text: 'Same, I\'m doing Technical Drawing after.', timestamp: DateTime(2026, 10, 28, 14, 40)),
      ],
    ),
    Post(
      id: 'p4',
      authorId: 'u3',
      authorName: 'Mphatso Nyirenda',
      authorInstitution: 'Kambiri University',
      type: PostType.studentPost,
      content: 'Study tips that got me through organic chemistry:\n'
          '1. Draw mechanisms by hand, twice.\n'
          '2. Teach a friend — gaps show fast.\n'
          '3. Past papers > re-reading notes.\n'
          '4. 25-minute focus blocks with real breaks.\n'
          '5. Sleep. Seriously.',
      timestamp: DateTime(2026, 10, 27, 20, 30),
      likeCount: 52,
      comments: [
        Comment(id: 'cm6', authorName: 'Chikondi Banda', text: 'Number 3 changed everything for me.', timestamp: DateTime(2026, 10, 27, 21, 5)),
      ],
    ),
    Post(
      id: 'p5',
      authorId: 'u4',
      authorName: 'Kondwani Chirwa',
      authorInstitution: 'Kambiri University',
      type: PostType.studentPost,
      content: 'Academic question: can someone explain the practical difference '
          'between stack and heap memory? I understand the theory but I keep '
          'mixing them up in exam questions.',
      timestamp: DateTime(2026, 10, 26, 11, 10),
      likeCount: 12,
      comments: [
        Comment(id: 'cm7', authorName: 'Mphatso Nyirenda', text: 'Think: stack = automatic/ordered, heap = manual/dynamic. I\'ll share my notes.', timestamp: DateTime(2026, 10, 26, 11, 45)),
      ],
    ),
    Post(
      id: 'p6',
      authorId: 'u5',
      authorName: 'Lindiwe Zgambo',
      authorInstitution: 'Kambiri University',
      type: PostType.studentPost,
      content: 'Reminder for Form 6 students: Kambiri University applications '
          'close on 30 November. Get your forms early and check the '
          'requirements twice — late applications are not accepted.',
      timestamp: DateTime(2026, 10, 25, 8, 45),
      likeCount: 64,
      comments: [],
    ),
    Post(
      id: 'p7',
      authorId: 'u6',
      authorName: 'Blessings Kalua',
      authorInstitution: 'Lilongwe Institute of Technology',
      type: PostType.studentPost,
      content: 'I\'ve uploaded my Physics practical notes (Ohm\'s law + circuits) '
          'to the Library — it\'s free to download. Check Library → Physics → '
          'Practical Guides. Feedback welcome!',
      timestamp: DateTime(2026, 10, 24, 17, 25),
      likeCount: 39,
      comments: [
        Comment(id: 'cm8', authorName: 'Mary Chasukwa', text: 'Just downloaded it, very clear. Zikomo!', timestamp: DateTime(2026, 10, 24, 18, 0)),
      ],
    ),
    Post(
      id: 'p8',
      authorId: 'u7',
      authorName: 'Mary Chasukwa',
      authorInstitution: 'Zomba College of Science',
      type: PostType.studentPost,
      content: 'Small win: scored 84% in my first programming exam! 💻 Thank you '
          'to everyone in the Computer Science Students community who answered '
          'my loop questions last month.',
      timestamp: DateTime(2026, 10, 23, 19, 5),
      likeCount: 87,
      comments: [
        Comment(id: 'cm9', authorName: 'Kondwani Chirwa', text: 'Congratulations! 🎉', timestamp: DateTime(2026, 10, 23, 19, 20)),
      ],
    ),
    Post(
      id: 'p9',
      authorId: 'u8',
      authorName: 'Thoko Kaunda',
      authorInstitution: 'Kasungu University',
      type: PostType.studentPost,
      content: 'Scholarship alert: the Ubuntu Learning Trust undergraduate '
          'scholarship closes on 30 November. Applications are open to '
          'full-time students — details are in the Opportunities section.',
      timestamp: DateTime(2026, 10, 22, 10, 15),
      likeCount: 44,
      comments: [],
    ),
    Post(
      id: 'p10',
      authorId: 'u9',
      authorName: 'Agness Mbewe',
      authorInstitution: 'Nkhata Bay Secondary School',
      type: PostType.studentPost,
      content: 'Does anyone have Biology Form 6 past papers? I have Maths and '
          'Physics papers to trade. Please help a Form 6 student survive revision 😭',
      timestamp: DateTime(2026, 10, 21, 13, 50),
      likeCount: 9,
      comments: [
        Comment(id: 'cm10', authorName: 'Tadala Phiri', text: 'Check the Library — there are Biology revision questions there.', timestamp: DateTime(2026, 10, 21, 14, 10)),
      ],
    ),
    Post(
      id: 'p11',
      authorId: 'u10',
      authorName: 'Frank Banda',
      authorInstitution: 'Blantyre Technical College',
      type: PostType.studentPost,
      content: 'Finally finished my isometric drawing practice set (30 exercises). '
          'Happy to share the PDF with anyone revising Technical Drawing 📐',
      timestamp: DateTime(2026, 10, 20, 9, 0),
      likeCount: 23,
      comments: [],
    ),
  ];

  // ---------------------------------------------------------------------------
  // Library resources (sample files — not copyrighted textbooks)
  // ---------------------------------------------------------------------------

  static List<LibraryResource> resources = [
    LibraryResource(
      id: 'r1', title: 'Mathematics Revision Guide — Form 4',
      description: 'A revision guide covering algebra, geometry, statistics and '
          'trigonometry for Form 4 students preparing for MSCE examinations.',
      subject: 'Mathematics', level: EducationLevel.secondary,
      institution: 'Chichiri Girls Secondary School',
      category: ResourceCategory.revisionNotes, author: 'K. Tembo',
      fileType: 'PDF', fileSize: '4.8 MB', fileSizeMb: 4.8,
      dateAdded: DateTime(2026, 10, 26), status: ResourceStatus.approved,
      downloadCount: 214,
    ),
    LibraryResource(
      id: 'r2', title: 'Physics Practical Notes',
      description: 'Practical write-ups for common secondary school experiments: '
          'Ohm\'s law, circuits, lenses and measurement errors.',
      subject: 'Physics', level: EducationLevel.secondary,
      institution: 'Lilongwe Institute of Technology',
      category: ResourceCategory.practicalGuides, author: 'Blessings Kalua',
      fileType: 'PDF', fileSize: '3.2 MB', fileSizeMb: 3.2,
      dateAdded: DateTime(2026, 10, 24), status: ResourceStatus.approved,
      downloadCount: 178, failNextDownload: true,
    ),
    LibraryResource(
      id: 'r3', title: 'Chemistry Examination Preparation',
      description: 'Condensed revision notes and practice questions for MSCE '
          'Chemistry: periodic table trends, organic chemistry and titration.',
      subject: 'Chemistry', level: EducationLevel.secondary,
      institution: 'Chichiri Girls Secondary School',
      category: ResourceCategory.studyGuides, author: 'Study Group',
      fileType: 'PDF', fileSize: '5.1 MB', fileSizeMb: 5.1,
      dateAdded: DateTime(2026, 10, 22), status: ResourceStatus.approved,
      downloadCount: 196,
    ),
    LibraryResource(
      id: 'r4', title: 'English Language Study Guide',
      description: 'Comprehension, summary writing and essay techniques with '
          'sample answers for secondary school students.',
      subject: 'English', level: EducationLevel.secondary,
      institution: 'Nkhata Bay Secondary School',
      category: ResourceCategory.studyGuides, author: 'English Department',
      fileType: 'PDF', fileSize: '2.7 MB', fileSizeMb: 2.7,
      dateAdded: DateTime(2026, 10, 20), status: ResourceStatus.approved,
      downloadCount: 143,
    ),
    LibraryResource(
      id: 'r5', title: 'Introduction to Engineering Mathematics',
      description: 'First-year engineering mathematics: calculus, linear algebra, '
          'differential equations and applications.',
      subject: 'Engineering', level: EducationLevel.university,
      institution: 'Kambiri University',
      category: ResourceCategory.textbooks, author: 'Faculty of Engineering',
      fileType: 'PDF', fileSize: '8.4 MB', fileSizeMb: 8.4,
      dateAdded: DateTime(2026, 10, 18), status: ResourceStatus.approved,
      downloadCount: 302,
    ),
    LibraryResource(
      id: 'r6', title: 'Electrical Engineering Fundamentals',
      description: 'Lecture notes on circuit analysis, transformers, machines and '
          'power systems for diploma students.',
      subject: 'Engineering', level: EducationLevel.university,
      institution: 'Lilongwe Institute of Technology',
      category: ResourceCategory.lectureNotes, author: 'Lecturer',
      fileType: 'PDF', fileSize: '6.2 MB', fileSizeMb: 6.2,
      dateAdded: DateTime(2026, 10, 16), status: ResourceStatus.approved,
      downloadCount: 167,
    ),
    LibraryResource(
      id: 'r7', title: 'Computer Science Lecture Notes',
      description: 'Introduction to programming, data structures, algorithms and '
          'databases, with worked examples in Python-style pseudocode.',
      subject: 'Computer Science', level: EducationLevel.university,
      institution: 'Kambiri University',
      category: ResourceCategory.lectureNotes, author: 'CS Department',
      fileType: 'PDF', fileSize: '3.9 MB', fileSizeMb: 3.9,
      dateAdded: DateTime(2026, 10, 15), status: ResourceStatus.approved,
      downloadCount: 288,
    ),
    LibraryResource(
      id: 'r8', title: 'Academic Research Methods',
      description: 'Step-by-step guide to choosing a topic, literature reviews, '
          'research ethics, data collection and report writing.',
      subject: 'Research', level: EducationLevel.university,
      institution: 'Kasungu University',
      category: ResourceCategory.textbooks, author: 'Research Office',
      fileType: 'PDF', fileSize: '5.6 MB', fileSizeMb: 5.6,
      dateAdded: DateTime(2026, 10, 12), status: ResourceStatus.approved,
      downloadCount: 231,
    ),
    LibraryResource(
      id: 'r9', title: 'Biology Revision Questions',
      description: 'Topic-by-topic revision questions with answers for cell '
          'biology, ecology, human physiology and genetics.',
      subject: 'Biology', level: EducationLevel.secondary,
      institution: 'Nkhata Bay Secondary School',
      category: ResourceCategory.revisionNotes, author: 'Biology Teachers',
      fileType: 'PDF', fileSize: '2.1 MB', fileSizeMb: 2.1,
      dateAdded: DateTime(2026, 10, 10), status: ResourceStatus.approved,
      downloadCount: 175,
    ),
    LibraryResource(
      id: 'r10', title: 'Business Studies Notes',
      description: 'Introduction to business, marketing, accounting basics and '
          'entrepreneurship for first-year college students.',
      subject: 'Business Studies', level: EducationLevel.college,
      institution: 'Mzuzu City College',
      category: ResourceCategory.lectureNotes, author: 'Business Faculty',
      fileType: 'PDF', fileSize: '1.9 MB', fileSizeMb: 1.9,
      dateAdded: DateTime(2026, 10, 8), status: ResourceStatus.approved,
      downloadCount: 98,
    ),
    LibraryResource(
      id: 'r11', title: 'Technical Drawing Practice',
      description: 'Practice sheets: orthographic projection, isometric drawing, '
          'sections and dimensioning, with model answers.',
      subject: 'Technical Drawing', level: EducationLevel.secondary,
      institution: 'Blantyre Technical College',
      category: ResourceCategory.practicalGuides, author: 'Frank Banda',
      fileType: 'PDF', fileSize: '7.3 MB', fileSizeMb: 7.3,
      dateAdded: DateTime(2026, 10, 5), status: ResourceStatus.approved,
      downloadCount: 121,
    ),
    LibraryResource(
      id: 'r12', title: 'University Study Skills Guide',
      description: 'Note-taking, time management, group study, exam strategies '
          'and where to find support as a first-year student.',
      subject: 'Study Skills', level: EducationLevel.university,
      institution: 'Kambiri University',
      category: ResourceCategory.generalAcademic, author: 'Student Affairs',
      fileType: 'PDF', fileSize: '1.5 MB', fileSizeMb: 1.5,
      dateAdded: DateTime(2026, 10, 3), status: ResourceStatus.approved,
      downloadCount: 260,
    ),
    LibraryResource(
      id: 'r13', title: 'MSCE Past Papers — Mathematics (2019–2024)',
      description: 'Collection of past examination papers with mark schemes for '
          'MSCE Mathematics, arranged by year.',
      subject: 'Mathematics', level: EducationLevel.secondary,
      institution: 'Nkhata Bay Secondary School',
      category: ResourceCategory.pastPapers, author: 'Examinations Desk',
      fileType: 'PDF', fileSize: '12.6 MB', fileSizeMb: 12.6,
      dateAdded: DateTime(2026, 9, 29), status: ResourceStatus.approved,
      downloadCount: 412,
    ),
    // ---- Admin workflow samples (not visible to students yet) ----
    LibraryResource(
      id: 'r14', title: 'Statistics Lecture Notes',
      description: 'Descriptive statistics, probability and inference for '
          'first-year college students.',
      subject: 'Statistics', level: EducationLevel.college,
      institution: 'Zomba College of Science',
      category: ResourceCategory.lectureNotes, author: 'Mary Chasukwa',
      fileType: 'PDF', fileSize: '2.4 MB', fileSizeMb: 2.4,
      dateAdded: DateTime(2026, 10, 27), status: ResourceStatus.pendingReview,
      submittedBy: 'Mary Chasukwa',
    ),
    LibraryResource(
      id: 'r15', title: 'Form 2 Geography Notes',
      description: 'Weather, climate and map reading notes for Form 2.',
      subject: 'Geography', level: EducationLevel.secondary,
      institution: 'Nkhata Bay Secondary School',
      category: ResourceCategory.lectureNotes, author: 'Teacher',
      fileType: 'PDF', fileSize: '1.2 MB', fileSizeMb: 1.2,
      dateAdded: DateTime(2026, 10, 28), status: ResourceStatus.draft,
      submittedBy: 'Teacher',
    ),
    LibraryResource(
      id: 'r16', title: 'Scanned Copy — Unknown Source',
      description: 'Uncredited scanned file submitted without attribution.',
      subject: 'Business Studies', level: EducationLevel.college,
      institution: 'Mzuzu City College',
      category: ResourceCategory.textbooks, author: 'Unknown',
      fileType: 'PDF', fileSize: '9.9 MB', fileSizeMb: 9.9,
      dateAdded: DateTime(2026, 10, 14), status: ResourceStatus.rejected,
      submittedBy: 'Uploader',
      rejectionReason: 'No source attribution or distribution rights confirmed.',
    ),
    LibraryResource(
      id: 'r17', title: 'Science Fair Pack 2024',
      description: 'Old science fair guidance pack, superseded by the 2026 edition.',
      subject: 'Biology', level: EducationLevel.secondary,
      institution: 'Nkhata Bay Secondary School',
      category: ResourceCategory.generalAcademic, author: 'Science Club',
      fileType: 'PDF', fileSize: '3.0 MB', fileSizeMb: 3.0,
      dateAdded: DateTime(2026, 6, 10), status: ResourceStatus.archived,
      submittedBy: 'Science Club',
    ),
  ];

  // ---------------------------------------------------------------------------
  // Conversations and requests
  // ---------------------------------------------------------------------------

  static List<Conversation> conversations = [
    Conversation(
      id: 'c1', peerName: 'Mphatso Nyirenda', peerInstitution: 'Kambiri University',
      peerSubtitle: 'Year 2 · Computer Science', unreadCount: 1,
      createdAt: DateTime(2026, 10, 20),
      messages: [
        Message(id: 'm1', text: 'Hi Chikondi! Did you get the data structures notes?', fromMe: false, timestamp: DateTime(2026, 10, 26, 18, 2), status: MessageStatus.read),
        Message(id: 'm2', text: 'Yes! I\'m reading them now, very helpful 🙏', fromMe: true, timestamp: DateTime(2026, 10, 26, 18, 10), status: MessageStatus.read),
        Message(id: 'm3', text: 'Great. Want to revise together tomorrow at the library?', fromMe: false, timestamp: DateTime(2026, 10, 28, 8, 30), status: MessageStatus.read),
        Message(id: 'm4', text: 'Sure, 2pm works for me!', fromMe: false, timestamp: DateTime(2026, 10, 28, 8, 31), status: MessageStatus.delivered),
      ],
    ),
    Conversation(
      id: 'c2', peerName: 'Tadala Phiri', peerInstitution: 'Chichiri Girls Secondary School',
      peerSubtitle: 'Form 4', createdAt: DateTime(2026, 10, 18),
      messages: [
        Message(id: 'm5', text: 'Thanks for the algebra tips!', fromMe: false, timestamp: DateTime(2026, 10, 25, 15, 0), status: MessageStatus.read),
        Message(id: 'm6', text: 'Anytime. Ask whenever you\'re stuck 😊', fromMe: true, timestamp: DateTime(2026, 10, 25, 15, 22), status: MessageStatus.read),
      ],
    ),
    Conversation(
      id: 'c3', peerName: 'Blessings Kalua', peerInstitution: 'Lilongwe Institute of Technology',
      peerSubtitle: 'Year 2 · Electrical Engineering', createdAt: DateTime(2026, 10, 22),
      messages: [
        Message(id: 'm7', text: 'Your physics notes helped a lot, zikomo!', fromMe: true, timestamp: DateTime(2026, 10, 24, 19, 0), status: MessageStatus.read),
        Message(id: 'm8', text: 'Welcome! I\'ll upload the circuits part soon.', fromMe: false, timestamp: DateTime(2026, 10, 24, 19, 15), status: MessageStatus.read),
      ],
    ),
    Conversation(
      id: 'rq1', peerName: 'Agness Mbewe', peerInstitution: 'Nkhata Bay Secondary School',
      peerSubtitle: 'Form 6', isRequest: true, createdAt: DateTime(2026, 10, 28, 10, 5),
      messages: [
        Message(id: 'm9', text: 'Hi Chikondi! I saw your Computer Science posts. Can we connect? I have Biology revision questions to share.', fromMe: false, timestamp: DateTime(2026, 10, 28, 10, 5), status: MessageStatus.read),
      ],
    ),
    Conversation(
      id: 'rq2', peerName: 'Frank Banda', peerInstitution: 'Blantyre Technical College',
      peerSubtitle: 'Year 2 · Technical Drawing', isRequest: true, createdAt: DateTime(2026, 10, 27, 21, 0),
      messages: [
        Message(id: 'm10', text: 'Muli bwanaji! I\'d like to join your study circle, is that OK?', fromMe: false, timestamp: DateTime(2026, 10, 27, 21, 0), status: MessageStatus.read),
      ],
    ),
    Conversation(
      id: 'rq3', peerName: 'Mary Chasukwa', peerInstitution: 'Zomba College of Science',
      peerSubtitle: 'Year 1 · Statistics', outgoingRequest: true, accepted: false, createdAt: DateTime(2026, 10, 26, 12, 0),
      messages: [],
    ),
    Conversation(
      id: 'gc1', peerName: 'Computer Science Students', peerInstitution: 'Community group chat',
      peerSubtitle: '428 members', isGroup: true, accepted: true, createdAt: DateTime(2026, 10, 12),
      messages: [
        Message(id: 'm11', text: 'Welcome to the CS group chat! Share questions and resources here.', fromMe: false, timestamp: DateTime(2026, 10, 12, 9, 0), status: MessageStatus.read),
        Message(id: 'm12', text: 'Anyone past papers for algorithms?', fromMe: false, timestamp: DateTime(2026, 10, 26, 16, 40), status: MessageStatus.read),
      ],
    ),
    Conversation(
      id: 'gc2', peerName: 'Scholarship Opportunities', peerInstitution: 'Community group chat',
      peerSubtitle: '312 members', isGroup: true, accepted: true, createdAt: DateTime(2026, 10, 8),
      messages: [
        Message(id: 'm13', text: 'Scholarship reminders are posted here every Monday.', fromMe: false, timestamp: DateTime(2026, 10, 20, 8, 0), status: MessageStatus.read),
      ],
    ),
  ];

  // ---------------------------------------------------------------------------
  // Communities
  // ---------------------------------------------------------------------------

  static List<Community> communities = [
    Community(id: 'cmty1', name: 'Secondary School Mathematics', description: 'Form 1–6 maths help, revision tips and past paper discussions.', level: EducationLevel.secondary, memberCount: 512, feed: [
      CommunityPost(authorName: 'Tadala Phiri', text: 'Algebra practice set posted — check the Library for past papers!', timestamp: DateTime(2026, 10, 27, 12, 0)),
    ]),
    Community(id: 'cmty2', name: 'Malawi University Students', description: 'A general space for university students across Malawi to connect.', level: EducationLevel.university, memberCount: 876, feed: [
      CommunityPost(authorName: 'Lindiwe Zgambo', text: 'Applications close 30 November — start early!', timestamp: DateTime(2026, 10, 25, 9, 30)),
    ]),
    Community(id: 'cmty3', name: 'Computer Science Students', description: 'Programming help, algorithms, projects and tech career chat.', level: EducationLevel.university, memberCount: 428, joined: true, conversationId: 'gc1', feed: [
      CommunityPost(authorName: 'Kondwani Chirwa', text: 'Stack vs heap — thanks for the explanations!', timestamp: DateTime(2026, 10, 26, 15, 0)),
      CommunityPost(authorName: 'Mary Chasukwa', text: 'My loops finally make sense 😭🎉', timestamp: DateTime(2026, 10, 23, 20, 0)),
    ]),
    Community(id: 'cmty4', name: 'Engineering Students', description: 'Electrical, civil and mechanical engineering students sharing notes and practicals.', level: EducationLevel.university, memberCount: 264, requiresApproval: true, feed: [
      CommunityPost(authorName: 'Blessings Kalua', text: 'Circuit analysis notes coming this week.', timestamp: DateTime(2026, 10, 24, 18, 30)),
    ]),
    Community(id: 'cmty5', name: 'Science Revision Group', description: 'Physics, Chemistry and Biology revision for secondary students.', level: EducationLevel.secondary, memberCount: 391, requiresApproval: true, feed: [
      CommunityPost(authorName: 'Agness Mbewe', text: 'Tonight: Biology cell revision at 7pm!', timestamp: DateTime(2026, 10, 28, 11, 0)),
    ]),
    Community(id: 'cmty6', name: 'Scholarship Opportunities', description: 'Sharing and discussing scholarships, bursaries and education funding.', level: EducationLevel.university, memberCount: 312, joined: true, conversationId: 'gc2', feed: [
      CommunityPost(authorName: 'Thoko Kaunda', text: 'Ubuntu Learning Trust closes 30 November!', timestamp: DateTime(2026, 10, 22, 11, 0)),
    ]),
    Community(id: 'cmty7', name: 'College and Technical Education', description: 'Diploma and technical students: courses, practicals and careers.', level: EducationLevel.college, memberCount: 189, feed: [
      CommunityPost(authorName: 'Frank Banda', text: 'Isometric drawing practice set is in the Library 📐', timestamp: DateTime(2026, 10, 20, 10, 0)),
    ]),
  ];

  // ---------------------------------------------------------------------------
  // Opportunities (fictional demo listings)
  // ---------------------------------------------------------------------------

  static List<Opportunity> opportunities = [
    Opportunity(
      id: 'o1', title: 'Undergraduate Scholarship Programme 2027',
      provider: 'Ubuntu Learning Trust',
      category: OpportunityCategory.scholarship, level: EducationLevel.university,
      eligibility: 'Full-time undergraduate students in Malawi with a strong '
          'academic record (minimum 60% average) and demonstrated financial need.',
      deadline: DateTime(2026, 11, 30), location: 'Blantyre, Malawi',
      verified: true,
      description: 'The Ubuntu Learning Trust supports '
          '20 undergraduates per year with tuition support and mentoring.',
      requiredDocuments: ['Academic transcripts', 'Proof of registration', 'Personal statement (1 page)', 'Recommendation letter'],
      instructions: 'Submit the listed documents to the trust office for review.',
    ),
    Opportunity(
      id: 'o2', title: 'Youth Coding Internship (6 months)',
      provider: 'Kuunika Youth Foundation',
      category: OpportunityCategory.internship, level: EducationLevel.university,
      eligibility: 'University students studying computing or IT. Basic '
          'programming knowledge required. Open to all genders.',
      deadline: DateTime(2026, 11, 15), location: 'Remote (Lilongwe hub)', remote: true,
      verified: true,
      description: 'A six-month part-time internship supporting community '
          'digital projects.',
      requiredDocuments: ['CV (2 pages max)', 'One code sample or project link'],
      instructions: 'Applications open through the foundation office.',
    ),
    Opportunity(
      id: 'o3', title: 'Malawi Young Scientists Competition',
      provider: 'Young Minds Malawi',
      category: OpportunityCategory.competition, level: EducationLevel.secondary,
      eligibility: 'Secondary school students (Form 3–6) with a science project '
          'supervised by a teacher.',
      deadline: DateTime(2026, 12, 20), location: 'Lilongwe, Malawi',
      description: 'National science fair for secondary students.',
      requiredDocuments: ['Project abstract', 'Supervisor contact', 'School letter'],
      instructions: 'Register through your school.',
    ),
    Opportunity(
      id: 'o4', title: 'Digital Skills Training Programme',
      provider: 'Nkhalango Digital Institute',
      category: OpportunityCategory.training, level: EducationLevel.college,
      eligibility: 'College students and recent graduates aged 18–30. No prior '
          'digital skills required.',
      deadline: DateTime(2026, 11, 10), location: 'Mzuzu, Malawi',
      verified: true,
      description: 'A 12-week part-time course covering office tools, internet '
          'safety and basic web development.',
      requiredDocuments: ['National ID (copy)', 'One-page motivation letter'],
      instructions: 'Apply at the institute desk.',
    ),
    Opportunity(
      id: 'o5', title: 'East African Education Conference 2027',
      provider: 'EduConnect Africa',
      category: OpportunityCategory.conference, level: EducationLevel.university,
      eligibility: 'University students and early-career researchers interested '
          'in education innovation. Student rate available.',
      deadline: DateTime(2027, 1, 15), location: 'Nairobi, Kenya', remote: true,
      description: 'A regional conference on digital learning.',
      requiredDocuments: ['Short bio', 'Abstract (optional for students)'],
      instructions: 'Registration is handled by the conference secretariat.',
    ),
    Opportunity(
      id: 'o6', title: 'Teen Entrepreneurs Youth Programme',
      provider: 'Chipembedzo Youth Initiative',
      category: OpportunityCategory.youthProgramme, level: EducationLevel.secondary,
      eligibility: 'Secondary school students aged 14–19 with a small business '
          'idea or existing hustle.',
      deadline: DateTime(2026, 11, 5), location: 'Zomba, Malawi',
      description: 'Mentorship and seed support for student entrepreneurs.',
      requiredDocuments: ['Business idea summary (1 page)', 'Parent/guardian consent'],
      instructions: 'Submit ideas at participating schools.',
    ),
    Opportunity(
      id: 'o7', title: 'Research Methods Workshop (expired listing)',
      provider: 'Kambiri University',
      category: OpportunityCategory.training, level: EducationLevel.university,
      eligibility: 'Final-year students preparing dissertations.',
      deadline: DateTime(2026, 9, 15), location: 'Lilongwe, Malawi',
      verified: true,
      description: 'A two-day workshop on research design and academic writing.',
      requiredDocuments: ['Registration form'],
      instructions: 'Closed.',
    ),
    Opportunity(
      id: 'o8', title: 'Girls in STEM Bootcamp',
      provider: 'Tiyende Girls Foundation',
      category: OpportunityCategory.training, level: EducationLevel.secondary,
      eligibility: 'Form 3–5 girls interested in science and technology.',
      deadline: DateTime(2026, 12, 12), location: 'Blantyre, Malawi',
      description: 'A one-week holiday bootcamp with hands-on science '
          'activities.',
      requiredDocuments: ['School letter', 'Guardian consent'],
      instructions: 'Apply through your school.',
      published: false,
    ),
  ];

  // ---------------------------------------------------------------------------
  // Reports, audit log, notifications
  // ---------------------------------------------------------------------------

  static List<Report> reports = [
    Report(id: 'rp1', target: ReportTarget.post, targetId: 'p5', targetTitle: 'Stack vs heap memory question', reason: ModerationReason.spam, reporter: 'Frank Banda', timestamp: DateTime(2026, 10, 26, 12, 0), status: ReportStatus.dismissed, notes: 'Reviewed: genuine academic question, not spam.'),
    Report(id: 'rp2', target: ReportTarget.resource, targetId: 'r16', targetTitle: 'Scanned Copy — Unknown Source', reason: ModerationReason.unauthorisedMaterials, reporter: 'Reviewer', timestamp: DateTime(2026, 10, 15, 9, 0)),
    Report(id: 'rp3', target: ReportTarget.opportunity, targetId: 'o5', targetTitle: 'East African Education Conference 2027', reason: ModerationReason.suspiciousOpportunity, reporter: 'Student', timestamp: DateTime(2026, 10, 19, 14, 30)),
    Report(id: 'rp4', target: ReportTarget.post, targetId: 'p11', targetTitle: 'Isometric drawing practice set', reason: ModerationReason.spam, reporter: 'Student', timestamp: DateTime(2026, 10, 21, 8, 15)),
    Report(id: 'rp5', target: ReportTarget.user, targetId: 'u10', targetTitle: 'Frank Banda', reason: ModerationReason.harassment, reporter: 'Student', timestamp: DateTime(2026, 10, 12, 17, 45), status: ReportStatus.resolved, notes: 'Account reviewed; warning issued.'),
    Report(id: 'rp6', target: ReportTarget.post, targetId: 'p9', targetTitle: 'Scholarship alert post', reason: ModerationReason.suspiciousOpportunity, reporter: 'Student', timestamp: DateTime(2026, 10, 22, 13, 0)),
  ];

  static List<AuditEntry> auditLog = [
    AuditEntry(id: 'a1', adminName: 'Admin', action: 'Approved resource "MSCE Past Papers — Mathematics (2019–2024)"', timestamp: DateTime(2026, 9, 29, 10, 0)),
    AuditEntry(id: 'a2', adminName: 'Admin', action: 'Rejected resource "Scanned Copy — Unknown Source" (no attribution)', timestamp: DateTime(2026, 10, 15, 9, 30)),
    AuditEntry(id: 'a3', adminName: 'Admin', action: 'Published announcement "Second semester timetable published"', timestamp: DateTime(2026, 10, 28, 9, 15)),
    AuditEntry(id: 'a4', adminName: 'Admin', action: 'Verified opportunity "Undergraduate Scholarship Programme 2027"', timestamp: DateTime(2026, 10, 10, 11, 0)),
    AuditEntry(id: 'a5', adminName: 'Admin', action: 'Dismissed report rp1 as not a violation', timestamp: DateTime(2026, 10, 26, 13, 0)),
    AuditEntry(id: 'a6', adminName: 'Admin', action: 'Suspended account "Frank Banda"', timestamp: DateTime(2026, 10, 12, 18, 0)),
    AuditEntry(id: 'a7', adminName: 'Admin', action: 'Restored account "Frank Banda"', timestamp: DateTime(2026, 10, 13, 9, 0)),
    AuditEntry(id: 'a8', adminName: 'Admin', action: 'Archived resource "Science Fair Pack 2024"', timestamp: DateTime(2026, 8, 2, 15, 0)),
    AuditEntry(id: 'a9', adminName: 'Admin', action: 'Added institution "Blantyre Technical College"', timestamp: DateTime(2026, 7, 21, 12, 0)),
  ];

  static List<AppNotification> notifications = [
    AppNotification(id: 'n1', type: AppNotificationType.request, title: 'New conversation request', body: 'Agness Mbewe would like to connect with you.', timestamp: DateTime(2026, 10, 28, 10, 5)),
    AppNotification(id: 'n2', type: AppNotificationType.accepted, title: 'Request accepted', body: 'Mphatso Nyirenda accepted your conversation request.', timestamp: DateTime(2026, 10, 20, 9, 0)),
    AppNotification(id: 'n3', type: AppNotificationType.comment, title: 'New comment', body: 'Mphatso Nyirenda commented on your post.', timestamp: DateTime(2026, 10, 27, 21, 5)),
    AppNotification(id: 'n4', type: AppNotificationType.adminAnnouncement, title: 'School announcement', body: 'Second semester timetable published.', timestamp: DateTime(2026, 10, 28, 9, 15)),
    AppNotification(id: 'n5', type: AppNotificationType.scholarship, title: 'Scholarship deadline approaching', body: 'Ubuntu Learning Trust scholarship closes on 30 Nov 2026.', timestamp: DateTime(2026, 10, 26, 8, 0)),
  ];

  /// Accounts offered when a student starts a new conversation request.
  static List<DemoStudentAccount> requestableStudents() => studentAccounts
      .where((account) => account.id != 'u1')
      .toList();
}
