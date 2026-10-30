import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/forms.dart';
import '../../../../data/mock_data.dart';
import '../../../../models/post_background.dart';

/// Bottom sheet with Facebook-style colour backgrounds for a text post.
/// Returns the chosen background id, or `null` when dismissed.
Future<String?> showBackgroundPicker(BuildContext context) {  return showModalBottomSheet<String>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Choose background',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final background in PostBackground.all)
                  GestureDetector(
                    onTap: () => Navigator.pop(context, background.id),
                    child: Container(
                      width: 76,
                      height: 76,
                      decoration: BoxDecoration(
                        gradient: background.gradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('Aa',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

/// Dialog to pick classmates to tag ("with …"). Returns the selected names,
/// or `null` when dismissed.
Future<List<String>?> showTagPeopleDialog(
  BuildContext context, {
  List<String> selected = const [],
}) {
  return showDialog<List<String>>(
    context: context,
    builder: (_) => _TagPeopleDialog(selected: selected),
  );
}

class _TagPeopleDialog extends StatefulWidget {
  const _TagPeopleDialog({required this.selected});

  final List<String> selected;

  @override
  State<_TagPeopleDialog> createState() => _TagPeopleDialogState();
}

class _TagPeopleDialogState extends State<_TagPeopleDialog> {
  late final Set<String> _picked = Set.of(widget.selected);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Tag people',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      content: SizedBox(
        width: 420,
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final name in MockData.taggableStudents)
              CheckboxListTile(
                value: _picked.contains(name),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
                dense: true,
                title: Text(name, style: const TextStyle(fontSize: 14)),
                onChanged: (checked) => setState(() {
                  checked == true ? _picked.add(name) : _picked.remove(name);
                }),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
        AppButton(
          label: 'Done',
          expanded: false,
          onPressed: () => Navigator.pop(context, _picked.toList()),
        ),
      ],
    );
  }
}

/// Dialog to pick a check-in location. Returns the chosen place, or `null`
/// when dismissed.
Future<String?> showLocationDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Add location',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
      content: SizedBox(
        width: 420,
        child: ListView(
          shrinkWrap: true,
          children: [
            for (final place in MockData.postLocations)
              ListTile(
                contentPadding: EdgeInsets.zero,
                dense: true,
                leading:
                    const Icon(Icons.location_on_outlined, color: AppColors.teal, size: 20),
                title: Text(place, style: const TextStyle(fontSize: 14)),
                onTap: () => Navigator.pop(context, place),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
        ),
      ],
    ),
  );
}

/// The "Add to your post" action bar shown at the bottom of the composer:
/// photo (optional), background colour, tag people and location.
class ComposerAddBar extends StatelessWidget {
  const ComposerAddBar({
    required this.onPhoto,
    required this.onBackground,
    required this.onTagPeople,
    required this.onLocation,
    this.remaining,
    this.showPhoto = true,
    this.photoActive = false,
    this.backgroundActive = false,
    this.tagActive = false,
    this.locationActive = false,
    super.key,
  });

  final VoidCallback onPhoto;
  final VoidCallback onBackground;
  final VoidCallback onTagPeople;
  final VoidCallback onLocation;
  final int? remaining;
  final bool showPhoto;
  final bool photoActive;
  final bool backgroundActive;
  final bool tagActive;
  final bool locationActive;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Add to your post',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            if (remaining != null && remaining! <= 100)
              Padding(
                padding: const EdgeInsets.only(right: 2),
                child: Text(
                  '$remaining left',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: remaining! < 0 ? AppColors.error : AppColors.textSecondary,
                  ),
                ),
              ),
            if (showPhoto)
              _optionButton(
                icon: Icons.photo_outlined,
                tooltip: 'Photo',
                active: photoActive,
                onTap: onPhoto,
              ),
            _optionButton(
              icon: Icons.color_lens_outlined,
              tooltip: 'Background colour',
              active: backgroundActive,
              onTap: onBackground,
            ),
            _optionButton(
              icon: Icons.person_add_alt_1_outlined,
              tooltip: 'Tag people',
              active: tagActive,
              onTap: onTagPeople,
            ),
            _optionButton(
              icon: Icons.location_on_outlined,
              tooltip: 'Location',
              active: locationActive,
              onTap: onLocation,
            ),
          ],
        ),
      ),
    );
  }

  Widget _optionButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onTap,
      icon: Icon(icon, color: active ? AppColors.teal : AppColors.textSecondary),
    );
  }
}
