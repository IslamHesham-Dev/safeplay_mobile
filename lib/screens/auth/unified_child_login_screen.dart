import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../constants/authentication_options.dart';
import '../../design_system/colors.dart';
import '../../widgets/auth/picture_password_grid.dart';
import '../../widgets/auth/pin_entry_widget.dart';
import '../../widgets/auth/add_child_dialog.dart';
import '../../services/local_child_storage.dart';
import '../../models/user_profile.dart';
import '../../models/user_type.dart';
import '../../navigation/route_names.dart';
import '../../providers/auth_provider.dart';

/// Unified child login screen that determines age group based on input method
class UnifiedChildLoginScreen extends StatefulWidget {
  const UnifiedChildLoginScreen({super.key});

  @override
  State<UnifiedChildLoginScreen> createState() =>
      _UnifiedChildLoginScreenState();
}

class _UnifiedChildLoginScreenState extends State<UnifiedChildLoginScreen>
    with TickerProviderStateMixin {
  // Real children data from Firebase
  List<ChildProfile> _availableChildren = [];
  String? _verifiedParentEmail;

  // Login state
  String? _selectedChildId;
  ChildProfile? _selectedChild;
  String _loginMethod = ''; // 'emoji' or 'picture_pin'

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Emoji authentication
  final List<String> _juniorEmojis = juniorEmojiOptions;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _fadeController.forward();
    _slideController.forward();

    // Load children data (all children from local storage)
    _loadChildren();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _loadChildren({String? parentEmail}) async {
    try {
      final filterEmail = parentEmail ?? _verifiedParentEmail;
      print('[UnifiedChildLogin]: Loading children for email: $filterEmail');

      // If no specific parent email is provided, load ALL children from local storage
      // This ensures children persist across app restarts on each device
      final children = filterEmail == null
          ? await LocalChildStorage.getChildren()
          : await LocalChildStorage.getChildrenForParent(filterEmail);

      print('[UnifiedChildLogin]: Found ${children.length} children');
      for (final child in children) {
        print(
            '[UnifiedChildLogin]: Child: ${child.name} (${child.id}) - Gender: ${child.gender} - AgeGroup: ${child.ageGroup}');
      }

      if (!mounted) return;
      setState(() {
        _availableChildren = children;
      });
    } catch (e) {
      print('Error loading children: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading children: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _selectChild(ChildProfile child) {
    setState(() {
      _selectedChildId = child.id;
      _selectedChild = child;
      _loginMethod = _determineLoginMethod(child);
    });
  }

  String _determineLoginMethod(ChildProfile child) {
    // Determine login method based on authData.authType
    if (child.authData != null) {
      final authType = child.authData!['authType'] as String?;
      if (authType == 'picture+pin') {
        return 'picture_pin';
      } else if (authType == 'emoji' || authType == 'picture') {
        return 'emoji';
      }
    }

    // Fallback to age group if no authData
    return child.ageGroup == AgeGroup.junior ? 'emoji' : 'picture_pin';
  }

  void _goBack() {
    setState(() {
      _selectedChildId = null;
      _selectedChild = null;
      _loginMethod = '';
    });
  }

  String _getAddButtonText() {
    return _availableChildren.isEmpty ? 'Add First Child' : 'Add Another Child';
  }

  void _showAddChildDialog() {
    // First, show parent verification dialog
    _showParentVerificationDialog();
  }

  void _showParentVerificationDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => _ParentVerificationDialog(
        onVerified: (email) {
          Navigator.of(dialogContext).pop();
          _showAddChildDialogWithParent(email);
        },
      ),
    );
  }

  void _showAddChildDialogWithParent(String parentEmail) {
    final normalizedEmail = parentEmail.trim().toLowerCase();
    setState(() {
      _verifiedParentEmail = normalizedEmail;
    });
    _loadChildren(parentEmail: normalizedEmail);

    showDialog(
      context: context,
      builder: (context) => AddChildDialog(
        parentEmail: parentEmail, // Display original parent email
        onChildAdded: (child) async {
          print(
              '[UnifiedChildLogin]: Child added callback called for: ${child.name}');
          print('[UnifiedChildLogin]: Child data: ${child.toJson()}');

          await _loadChildren(parentEmail: normalizedEmail);
          if (!mounted) return;

          print(
              '[UnifiedChildLogin]: Loaded ${_availableChildren.length} children after adding');
          for (final c in _availableChildren) {
            print('[UnifiedChildLogin]: Available child: ${c.name} (${c.id})');
          }

          // Child is now added to the "who is here" page
          // Parent stays on the child selector screen
        },
      ),
    );
  }

  Future<void> _onEmojiSequenceComplete(List<String> sequence) async {
    if (_selectedChild == null) return;

    print('[UnifiedChildLogin]: ===== EMOJI AUTHENTICATION DEBUG =====');
    print('[UnifiedChildLogin]: Child ID: ${_selectedChild!.id}');
    print('[UnifiedChildLogin]: Child Name: ${_selectedChild!.name}');
    print('[UnifiedChildLogin]: Child Age Group: ${_selectedChild!.ageGroup}');
    print('[UnifiedChildLogin]: Auth Data: ${_selectedChild!.authData}');
    print('[UnifiedChildLogin]: Provided emoji sequence: $sequence');
    print('[UnifiedChildLogin]: ========================================');

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signInChildWithPicturePassword(
        _selectedChild!.id,
        sequence,
      );

      print('[UnifiedChildLogin]: Authentication result: $success');

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome back, ${_selectedChild!.name}!'),
              backgroundColor: SafePlayColors.success,
            ),
          );
          context.go(RouteNames.childDashboard);
        }
      } else {
        print('[UnifiedChildLogin]: Emoji authentication failed');
        _handleFailedAttempt();
      }
    } catch (e) {
      print('[UnifiedChildLogin]: Emoji authentication error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _onPicturePinComplete(List<String> pictures, String pin) async {
    if (_selectedChild == null) return;

    print('[UnifiedChildLogin]: ===== PICTURE+PIN AUTHENTICATION DEBUG =====');
    print('[UnifiedChildLogin]: Child ID: ${_selectedChild!.id}');
    print('[UnifiedChildLogin]: Child Name: ${_selectedChild!.name}');
    print('[UnifiedChildLogin]: Child Age Group: ${_selectedChild!.ageGroup}');
    print('[UnifiedChildLogin]: Auth Data: ${_selectedChild!.authData}');
    print('[UnifiedChildLogin]: Provided pictures: $pictures');
    print('[UnifiedChildLogin]: Provided PIN: $pin');
    print('[UnifiedChildLogin]: =============================================');

    try {
      final authProvider = context.read<AuthProvider>();
      final success = await authProvider.signInChildWithPicturePin(
        _selectedChild!.id,
        pictures,
        pin,
      );

      print('[UnifiedChildLogin]: Authentication result: $success');

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome back, ${_selectedChild!.name}!'),
              backgroundColor: SafePlayColors.success,
            ),
          );
          context.go(RouteNames.childDashboard);
        }
      } else {
        print('[UnifiedChildLogin]: Picture+PIN authentication failed');
        _handleFailedAttempt();
      }
    } catch (e) {
      print('[UnifiedChildLogin]: Picture+PIN authentication error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Authentication error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _handleFailedAttempt() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Oops! That\'s not right. Try again!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9FA),
              Color(0xFFE3F2FD),
            ],
          ),
        ),
        child: SafeArea(
          child: _selectedChildId == null
              ? _buildChildSelector()
              : _buildLoginInterface(),
        ),
      ),
    );
  }

  Widget _buildChildSelector() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back button and title in same row
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: SafePlayColors.brandTeal500,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Who\'s here?',
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: SafePlayColors.brandTeal500,
                              ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 48), // Balance the back button width
                ],
              ),

              const SizedBox(height: 16),

              Text(
                'Choose your profile to start learning!',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: SafePlayColors.neutral600,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Children grid or empty state
              Expanded(
                child: _availableChildren.isEmpty
                    ? _buildEmptyState()
                    : Column(
                        children: [
                          Expanded(
                            child: GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.85,
                              ),
                              itemCount: _availableChildren.length,
                              itemBuilder: (context, index) {
                                final child = _availableChildren[index];
                                return _buildChildCard(child);
                              },
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Add Child button
                          ElevatedButton.icon(
                            onPressed: _showAddChildDialog,
                            icon: const Icon(Icons.add, color: Colors.white),
                            label: const Text('Add Another Child'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SafePlayColors.brandTeal500,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.child_care_outlined,
                  size: 80,
                  color: SafePlayColors.neutral400,
                ),
                const SizedBox(height: 24),
                Text(
                  'No children found',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: SafePlayColors.neutral600,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add your child\'s profile and set up their login credentials.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: SafePlayColors.neutral500,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        // Buttons at bottom
        ElevatedButton.icon(
          onPressed: _showAddChildDialog,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(_getAddButtonText()),
          style: ElevatedButton.styleFrom(
            backgroundColor: SafePlayColors.brandTeal500,
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () => context.pop(),
          icon: const Icon(Icons.arrow_back),
          label: const Text('Go Back'),
          style: TextButton.styleFrom(
            foregroundColor: SafePlayColors.brandTeal500,
          ),
        ),
      ],
    );
  }

  Widget _buildChildCard(ChildProfile child) {
    final isJunior = child.ageGroup == AgeGroup.junior;
    final ageGroupColor =
        isJunior ? SafePlayColors.juniorPurple : SafePlayColors.brightIndigo;
    final ageGroupLabel = isJunior ? 'Junior Explorer' : 'Bright Minds';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () => _selectChild(child),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar
              CircleAvatar(
                radius: 40,
                backgroundColor: ageGroupColor.withValues(alpha: 0.1),
                child: ClipOval(
                  child: Image.asset(
                    _getChildAvatarPath(child),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        _getChildAvatar(child),
                        style: const TextStyle(fontSize: 40),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Name
              Text(
                child.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 8),

              // Age group badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: ageGroupColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: ageGroupColor, width: 1),
                ),
                child: Text(
                  ageGroupLabel,
                  style: TextStyle(
                    color: ageGroupColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getChildAvatarPath(ChildProfile child) {
    // Use gender-based avatar if available
    if (child.gender != null) {
      return child.gender == 'female'
          ? 'assets/images/avatars/girl_img.png'
          : 'assets/images/avatars/boy_img.png';
    }

    // Fallback to age group
    return child.ageGroup == AgeGroup.junior
        ? 'assets/images/avatars/girl_img.png'
        : 'assets/images/avatars/boy_img.png';
  }

  String _getChildAvatar(ChildProfile child) {
    // Use gender-based avatar if available
    if (child.gender != null) {
      return child.gender == 'female' ? '👧' : '👦';
    }

    // Fallback to age group
    return child.ageGroup == AgeGroup.junior ? '👧' : '👦';
  }

  Widget _buildLoginInterface() {
    if (_selectedChild == null) return const SizedBox();

    final isJunior = _loginMethod == 'emoji';
    final childName = _selectedChild!.name;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Back button
              Row(
                children: [
                  IconButton(
                    onPressed: _goBack,
                    icon: const Icon(Icons.arrow_back),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: SafePlayColors.brandTeal500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: isJunior
                    ? SafePlayColors.juniorPurple.withValues(alpha: 0.1)
                    : SafePlayColors.brightIndigo.withValues(alpha: 0.1),
                child: ClipOval(
                  child: Image.asset(
                    _getChildAvatarPath(_selectedChild!),
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Text(
                        _getChildAvatar(_selectedChild!),
                        style: const TextStyle(fontSize: 50),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Welcome message
              Text(
                'Hi $childName!',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isJunior
                          ? SafePlayColors.juniorPurple
                          : SafePlayColors.brightIndigo,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                isJunior
                    ? 'Select your 4 emoji pictures to log in'
                    : 'Select your 3 pictures and enter your PIN',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: SafePlayColors.neutral600,
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Login interface
              Expanded(
                child: _buildAuthInterface(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthInterface() {
    if (_selectedChild == null) return const SizedBox();

    // Check if child has authentication set up
    if (_selectedChild!.authData == null) {
      return _buildNoAuthSetup();
    }

    final authType = _selectedChild!.authData!['authType'] as String?;

    if (authType == 'emoji' || authType == 'picture') {
      return _buildJuniorLogin();
    } else if (authType == 'picture+pin') {
      return _buildBrightLogin();
    } else {
      return _buildNoAuthSetup();
    }
  }

  Widget _buildNoAuthSetup() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outline,
            size: 80,
            color: SafePlayColors.neutral400,
          ),
          const SizedBox(height: 24),
          Text(
            'Login not set up',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: SafePlayColors.neutral600,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ask your parent to set up your login first.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: SafePlayColors.neutral500,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _goBack,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Go Back'),
            style: ElevatedButton.styleFrom(
              backgroundColor: SafePlayColors.brandTeal500,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJuniorLogin() {
    return PicturePasswordGrid(
      key: const ValueKey('junior-grid'),
      pictures: _juniorEmojis,
      sequenceLength: 4,
      onSequenceComplete: _onEmojiSequenceComplete,
      selectionColor: SafePlayColors.juniorPurple,
    );
  }

  Widget _buildBrightLogin() {
    return _BrightPicturePinLoginEmbedded(
      key: const ValueKey('bright-login'),
      onPicturePinComplete: _onPicturePinComplete,
    );
  }
}

/// Bright Minds login interface with picture + PIN (embedded version)
class _BrightPicturePinLoginEmbedded extends StatefulWidget {
  final Function(List<String>, String) onPicturePinComplete;

  const _BrightPicturePinLoginEmbedded({
    super.key,
    required this.onPicturePinComplete,
  });

  @override
  State<_BrightPicturePinLoginEmbedded> createState() =>
      _BrightPicturePinLoginEmbeddedState();
}

class _BrightPicturePinLoginEmbeddedState
    extends State<_BrightPicturePinLoginEmbedded> {
  final List<String> _brightPictures = brightPictureOptions;

  bool _pictureStepComplete = false;
  List<String>? _selectedPictures;

  void _onPicturesSelected(List<String> selectedPictures) {
    setState(() {
      _selectedPictures = selectedPictures;
      _pictureStepComplete = true;
    });
  }

  void _onPinComplete(String pin) {
    if (_selectedPictures != null) {
      widget.onPicturePinComplete(_selectedPictures!, pin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Step indicator
          Row(
            children: [
              Expanded(
                child: _buildStepCard(
                  '1',
                  'Pictures',
                  _pictureStepComplete,
                  SafePlayColors.brightIndigo,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStepCard(
                  '2',
                  'PIN',
                  false,
                  SafePlayColors.brightIndigo,
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),

          // Content based on step
          if (!_pictureStepComplete) ...[
            Text(
              'Select your 3 pictures',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: SafePlayColors.brightIndigo,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            PicturePasswordGrid(
              pictures: _brightPictures,
              sequenceLength: 3,
              onSequenceComplete: _onPicturesSelected,
              useAvatarStyle: true,
              selectionColor: SafePlayColors.brightIndigo,
            ),
          ] else ...[
            Text(
              'Enter your 4-digit PIN',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: SafePlayColors.brightIndigo,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),
            PinEntryWidget(
              onPinComplete: _onPinComplete,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _pictureStepComplete = false;
                  _selectedPictures = null;
                });
              },
              child: const Text('Change Pictures'),
              style: TextButton.styleFrom(
                foregroundColor: SafePlayColors.brightIndigo,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStepCard(
      String step, String label, bool isComplete, Color color) {
    return Card(
      color: isComplete ? color.withValues(alpha: 0.1) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isComplete
                    ? SafePlayColors.success
                    : color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isComplete
                    ? const Icon(Icons.check, color: Colors.white)
                    : Text(
                        step,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: color,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParentVerificationDialog extends StatefulWidget {
  final Function(String) onVerified;

  const _ParentVerificationDialog({
    required this.onVerified,
  });

  @override
  State<_ParentVerificationDialog> createState() =>
      _ParentVerificationDialogState();
}

class _ParentVerificationDialogState extends State<_ParentVerificationDialog> {
  final _parentEmailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isVerifying = false;

  @override
  void dispose() {
    _parentEmailController.dispose();
    super.dispose();
  }

  Future<bool> _validateParentEmail(String email) async {
    return LocalChildStorage.validateParentEmail(email.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Verify Parent Identity'),
      content: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'Please enter your email address to verify you are the parent:'),
            const SizedBox(height: 16),
            TextFormField(
              controller: _parentEmailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Your Email',
                hintText: 'Enter your email address',
                prefixIcon: Icon(Icons.email),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                    .hasMatch(value.trim())) {
                  return 'Please enter a valid email address';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isVerifying
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isVerifying
              ? null
              : () async {
                  if (!(_formKey.currentState?.validate() ?? false)) {
                    return;
                  }

                  final email = _parentEmailController.text.trim();
                  setState(() {
                    _isVerifying = true;
                  });

                  final exists = await _validateParentEmail(email);

                  if (!mounted) return;

                  if (!exists) {
                    setState(() {
                      _isVerifying = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Parent email $email does not exist. Please check your email or contact support.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  widget.onVerified(email);
                },
          child: _isVerifying
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Continue'),
        ),
      ],
    );
  }
}
