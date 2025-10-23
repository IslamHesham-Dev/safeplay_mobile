import 'package:flutter/material.dart';
import '../design_system/colors.dart';

/// Widget for displaying avatar images with fallback to generated avatars
class AvatarWidget extends StatelessWidget {
  final String? imagePath;
  final String name;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final String? gender; // 'male' or 'female' for gender-specific avatars

  const AvatarWidget({
    super.key,
    this.imagePath,
    required this.name,
    this.size = 60.0,
    this.backgroundColor,
    this.textColor,
    this.gender,
  });

  @override
  Widget build(BuildContext context) {
    // Try to load the image first
    if (imagePath != null) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(color: SafePlayColors.neutral300, width: 2),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: Image.asset(
            imagePath!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to generated avatar if image fails to load
              return _buildGeneratedAvatar();
            },
          ),
        ),
      );
    }

    // Generate avatar if no image path provided
    return _buildGeneratedAvatar();
  }

  Widget _buildGeneratedAvatar() {
    // Use gender-specific emoji if available, otherwise use initials
    final displayText = _getDisplayText();
    final bgColor = backgroundColor ?? _getColorFromName(name);
    final txtColor = textColor ?? Colors.white;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(color: SafePlayColors.neutral300, width: 2),
      ),
      child: Center(
        child: Text(
          displayText,
          style: TextStyle(
            color: txtColor,
            fontSize: gender != null ? size * 0.5 : size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getDisplayText() {
    // Use gender-specific emoji if gender is provided
    if (gender != null) {
      return gender == 'female' ? '👧' : '👦';
    }

    // Fallback to initials
    return _getInitials(name);
  }

  String _getInitials(String name) {
    final words = name.split(' ');
    if (words.isEmpty) return '?';

    if (words.length == 1) {
      return words[0].substring(0, 1).toUpperCase();
    }

    return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  Color _getColorFromName(String name) {
    // Generate a consistent color based on the name
    final colors = [
      SafePlayColors.brandTeal500,
      SafePlayColors.brandOrange500,
      SafePlayColors.success,
      SafePlayColors.warning,
      Colors.purple,
      Colors.pink,
      Colors.indigo,
      Colors.cyan,
      Colors.amber,
      Colors.deepOrange,
    ];

    final hash = name.hashCode;
    return colors[hash.abs() % colors.length];
  }
}

/// Widget for displaying a grid of avatar options
class AvatarGridWidget extends StatelessWidget {
  final List<String> avatarNames;
  final List<String> selectedAvatars;
  final int maxSelections;
  final Function(String) onAvatarSelected;
  final double avatarSize;
  final int crossAxisCount;

  const AvatarGridWidget({
    super.key,
    required this.avatarNames,
    required this.selectedAvatars,
    required this.maxSelections,
    required this.onAvatarSelected,
    this.avatarSize = 80.0,
    this.crossAxisCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: avatarNames.length,
      itemBuilder: (context, index) {
        final avatarName = avatarNames[index];
        final isSelected = selectedAvatars.contains(avatarName);
        final canSelect = selectedAvatars.length < maxSelections;

        return InkWell(
          onTap: canSelect || isSelected
              ? () => onAvatarSelected(avatarName)
              : null,
          borderRadius: BorderRadius.circular(avatarSize / 2),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(avatarSize / 2),
              border: Border.all(
                color: isSelected
                    ? SafePlayColors.brandOrange500
                    : SafePlayColors.neutral300,
                width: isSelected ? 3 : 2,
              ),
            ),
            child: AvatarWidget(
              name: avatarName,
              size: avatarSize,
            ),
          ),
        );
      },
    );
  }
}
