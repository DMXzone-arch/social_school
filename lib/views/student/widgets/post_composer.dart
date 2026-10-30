import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/ui_kit.dart';
import '../../../../models/post.dart';
import '../../../../models/post_background.dart';
import '../../../../repositories/auth_repository.dart';
import 'composer_options.dart';

const int kMaxPostLength = 500;

/// Full-screen "Create post" page, Facebook Lite style: your avatar and
/// name, a large text area (optionally on a colour background) and an
/// "Add to your post" action bar — photo, background, tag people, location.
///
/// Also used for editing an existing post. Returns a [PostDraft] or `null`
/// when closed.
Future<PostDraft?> showPostComposer(BuildContext context, {Post? existing}) {
  return Navigator.of(context).push<PostDraft>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => _PostComposerPage(existing: existing),
    ),
  );
}

class _PostComposerPage extends StatefulWidget {
  const _PostComposerPage({this.existing});

  final Post? existing;

  @override
  State<_PostComposerPage> createState() => _PostComposerPageState();
}

class _PostComposerPageState extends State<_PostComposerPage> {
  late final TextEditingController _controller;
  bool _withImage = false;
  String? _backgroundId;
  List<String> _tagged = const [];
  String? _location;
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.existing?.content ?? '');
    _withImage = widget.existing?.hasImage ?? false;
    _backgroundId = widget.existing?.backgroundId;
    _tagged = List.of(widget.existing?.taggedNames ?? const []);
    _location = widget.existing?.location;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isEdit => widget.existing != null;

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) {
      setState(() => _error = 'Write something before posting.');
      return;
    }
    if (text.length > kMaxPostLength) {
      setState(() => _error = 'Posts are limited to $kMaxPostLength characters.');
      return;
    }
    Navigator.of(context).pop(PostDraft(
      content: text,
      withImage: _withImage,
      backgroundId: _backgroundId,
      taggedNames: _tagged,
      location: _location,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final me = AuthRepository.instance.currentUser;
    final remaining = kMaxPostLength - _controller.text.length;
    final background = PostBackground.byId(_backgroundId);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          tooltip: 'Close',
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
        title: Text(
          _isEdit ? 'Edit post' : 'Create post',
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 38),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _submit,
              child: Text(_isEdit ? 'SAVE' : 'POST'),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Author + tagged / location line -----------------------------
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                AvatarCircle(name: me?.fullName ?? 'Member', radius: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        me?.fullName ?? 'Member',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                      ),
                      if (_tagged.isNotEmpty || _location != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            [
                              if (_tagged.isNotEmpty)
                                '— with ${_tagged.map((n) => n.split(' ').first).join(', ')}',
                              ?_location,
                            ].join('  ·  '),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Text area (on the chosen background when one is set) ---------
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: background == null
                  ? _textField()
                  : Container(
                      decoration: BoxDecoration(
                        gradient: background.gradient,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: _textField(
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            height: 1.4,
                            color: Colors.white),
                        hintColor: Colors.white70,
                        textAlign: TextAlign.center,
                      ),
                    ),
            ),
          ),

          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child:
                  Text(_error!, style: const TextStyle(color: AppColors.error, fontSize: 12.5)),
            ),

          // "Add to your post" bar ---------------------------------------
          Divider(height: 1, color: AppColors.border),
          ComposerAddBar(
            remaining: remaining,
            showPhoto: !_isEdit,
            photoActive: _withImage,
            backgroundActive: _backgroundId != null,
            tagActive: _tagged.isNotEmpty,
            locationActive: _location != null,
            onPhoto: () => setState(() => _withImage = !_withImage),
            onBackground: _pickBackground,
            onTagPeople: _pickPeople,
            onLocation: _pickLocation,
          ),
        ],
      ),
    );
  }

  Widget _textField({
    TextStyle? style,
    Color? hintColor,
    TextAlign textAlign = TextAlign.start,
  }) {
    return TextField(
      controller: _controller,
      autofocus: true,
      maxLines: null,
      minLines: 6,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      textAlign: textAlign,
      onChanged: (_) => setState(() => _error = null),
      style: style ?? const TextStyle(fontSize: 16.5, height: 1.5),
      cursorColor: _backgroundId != null ? Colors.white : AppColors.primary,
      decoration: InputDecoration(
        hintText: _isEdit ? 'Edit your post…' : 'Share a study tip, question or update…',
        hintStyle: TextStyle(
          color: hintColor ?? AppColors.textSecondary,
          fontSize: style != null ? 20 : 16.5,
          fontWeight: style != null ? FontWeight.w800 : FontWeight.w400,
          height: 1.5,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: false,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  Future<void> _pickBackground() async {
    final id = await showBackgroundPicker(context);
    if (id != null && mounted) setState(() => _backgroundId = id);
  }

  Future<void> _pickPeople() async {
    final picked = await showTagPeopleDialog(context, selected: _tagged);
    if (picked != null && mounted) setState(() => _tagged = picked);
  }

  Future<void> _pickLocation() async {
    final place = await showLocationDialog(context);
    if (place != null && mounted) setState(() => _location = place);
  }
}
