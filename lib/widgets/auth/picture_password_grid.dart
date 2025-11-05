import 'package:flutter/material.dart';
import '../avatar_widget.dart';
import '../../design_system/colors.dart';

/// Picture password grid widget for Junior Explorer
class PicturePasswordGrid extends StatefulWidget {
  final List<String> pictures;
  final int sequenceLength;
  final Function(List<String>) onSequenceComplete;
  final bool showSelection;
  final VoidCallback? onClear;
  final bool useAvatarStyle;
  final Color selectionColor;

  const PicturePasswordGrid({
    super.key,
    required this.pictures,
    this.sequenceLength = 4,
    required this.onSequenceComplete,
    this.showSelection = true,
    this.onClear,
    this.useAvatarStyle = false,
    this.selectionColor = SafePlayColors.juniorPurple,
  });

  @override
  State<PicturePasswordGrid> createState() => _PicturePasswordGridState();
}

class _PicturePasswordGridState extends State<PicturePasswordGrid>
    with SingleTickerProviderStateMixin {
  final List<String> _selectedPictures = [];
  late AnimationController _animationController;
  String? _lastTappedPicture;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onPictureTap(String picture) {
    if (_selectedPictures.length >= widget.sequenceLength) return;

    setState(() {
      _selectedPictures.add(picture);
      _lastTappedPicture = picture;
    });

    // Animate
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // Play sound effect (TODO: implement sound)

    // Provide haptic feedback
    // HapticFeedback.lightImpact();

    // Check if sequence is complete
    if (_selectedPictures.length == widget.sequenceLength) {
      Future.delayed(const Duration(milliseconds: 300), () {
        widget.onSequenceComplete(_selectedPictures);
      });
    }
  }

  void _clearSelection() {
    setState(() {
      _selectedPictures.clear();
      _lastTappedPicture = null;
    });
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Selection indicator
          if (widget.showSelection) _buildSelectionIndicator(),

          const SizedBox(height: 24),

          // Picture grid (4x4)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.0,
            ),
            itemCount: widget.pictures.length,
            itemBuilder: (context, index) {
              final picture = widget.pictures[index];
              final isSelected = _selectedPictures.contains(picture);
              final selectionOrder = _selectedPictures.indexOf(picture) + 1;

              return _buildPictureItem(
                picture,
                isSelected,
                selectionOrder,
                picture == _lastTappedPicture,
              );
            },
          ),

          const SizedBox(height: 24),

          // Clear button
          if (_selectedPictures.isNotEmpty)
            TextButton.icon(
              onPressed: _clearSelection,
              icon: const Icon(Icons.refresh),
              label: const Text('Start Over'),
              style: TextButton.styleFrom(
                foregroundColor: SafePlayColors.brandOrange500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSelectionIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.selectionColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.sequenceLength,
          (index) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: index < _selectedPictures.length
                    ? widget.selectionColor
                    : Colors.white,
                border: Border.all(
                  color: widget.selectionColor,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: index < _selectedPictures.length
                  ? Center(
                      child: widget.useAvatarStyle
                          ? AvatarWidget(
                              name: _selectedPictures[index],
                              size: 32,
                              backgroundColor: widget.selectionColor,
                              textColor: Colors.white,
                            )
                          : Text(
                              _selectedPictures[index],
                              style: const TextStyle(fontSize: 28),
                            ),
                    )
                  : Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: SafePlayColors.neutral500,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPictureItem(
    String picture,
    bool isSelected,
    int selectionOrder,
    bool isLastTapped,
  ) {
    final Color highlightColor = widget.selectionColor;
    final bool useAvatar = widget.useAvatarStyle;

    final Widget content = useAvatar
        ? AvatarWidget(
            name: picture,
            size: 56,
            backgroundColor: isSelected ? highlightColor : null,
            textColor: Colors.white,
          )
        : Text(
            picture,
            style: const TextStyle(fontSize: 40),
          );

    final Color borderColor = useAvatar
        ? (isSelected ? highlightColor : Colors.transparent)
        : (isSelected ? highlightColor : SafePlayColors.neutral200);
    final double borderWidth =
        useAvatar ? (isSelected ? 3 : 0) : (isSelected ? 3 : 2);
    final Color? containerColor = useAvatar ? Colors.transparent : Colors.white;
    final Color shadowColor =
        highlightColor.withValues(alpha: useAvatar ? 0.25 : 0.4);

    return ScaleTransition(
      scale: Tween<double>(begin: 1.0, end: 1.1).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Curves.easeInOut,
        ),
      ),
      child: GestureDetector(
        onTap: () => _onPictureTap(picture),
        child: Container(
          decoration: BoxDecoration(
            color: containerColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor,
              width: borderWidth,
            ),
            boxShadow: [
              if (isLastTapped)
                BoxShadow(
                  color: shadowColor,
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: content,
              ),
              if (isSelected)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: highlightColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$selectionOrder',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
