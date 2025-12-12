import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = [
    Locale('en'),
    Locale('ar'),
  ];

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // Simple key/value store. Keys stay stable even if English copy changes.
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Generic
      'lang.english': 'English',
      'lang.arabic': 'Arabic',
      'action.continue': 'Continue',
      'action.skip': 'Skip',
      'action.get_started': 'Get Started',
      'action.next': 'Next',
      'action.previous': 'Previous',
      'action.login': 'Login',
      'action.signup': 'Sign Up',
      'action.refresh': 'Refresh',
      'action.change_language': 'Change language',
      'label.parent_portal': 'Parent Portal',
      'label.safeplay_portal': 'SafePlay Portal',
      'label.welcome_parent': 'Welcome to SafePlay',
      'label.parent_subtitle': 'Your Child\'s Safety is Our Priority',
      'label.language_prompt': 'Choose your language',
      'label.language_description':
          'You can switch anytime from the menu in the parent dashboard.',
      'label.parent_login': 'Parent Login',
      'label.parent_signup': 'Parent Sign Up',
      'label.email': 'Email',
      'label.password': 'Password',
      'label.forgot_password': 'Forgot password?',
      'label.no_account': 'Don\'t have an account?',
      'label.have_account': 'Already have an account?',
      'label.home': 'Parent Dashboard',
      'label.controls': 'Browser Controls',
      'label.wellbeing': 'Wellbeing Reports',
      'label.messaging': 'Messaging Safety',
      'label.nav_home': 'Home',
      'label.nav_controls': 'Controls',
      'label.nav_wellbeing': 'Wellbeing',
      'label.nav_alerts': 'Alerts',
      'label.ai_wellbeing': 'AI wellbeing report',
      'label.recent_checkins': 'Recent check-ins',
      'label.this_weeks_mood': 'This week\'s mood',
      'label.browser_activity': 'Browser Activity History',
      'label.privacy_note':
          'Summaries stay abstract (no raw notes) and are meant to support gentle conversations.',
      'browser.summary_hint':
          'High-level summary of recent online activity (privacy-respecting).',
      'browser.error_title': 'Unable to load recent browsing insights.',
      'browser.empty': 'Not enough Safe Browser activity for a summary yet.',
      'label.language_setting': 'Language',
      'label.language_setting_desc':
          'Switch between English and Arabic for the parent experience.',
      'settings.title': 'Settings',
      'settings.subtitle': 'Manage your account and preferences',
      'settings.change_password': 'Change Password',
      'settings.change_password_desc': 'Update your account password',
      'settings.notifications': 'Notifications',
      'settings.notifications_desc': 'Manage notification preferences',
      'settings.privacy': 'Privacy & Security',
      'settings.privacy_desc': 'Manage your privacy settings',
      'settings.help': 'Help & Support',
      'settings.help_desc': 'Get help and contact support',
      'settings.logout': 'Log Out',
      'settings.delete_account': 'Delete Account',
      'settings.delete_account_desc':
          'Permanently delete your account and all data',
      'settings.sign_out': 'Sign Out',
      // Onboarding preview strings
      'preview.child1_name': 'Layan',
      'preview.child1_age': 'Junior (Age 5)',
      'preview.child2_name': 'Omar',
      'preview.child2_age': 'Bright (Age 8)',
      'preview.add_child_profile': 'Add Child Profile',
      'preview.status_ready': 'Ready',
      'preview.status_setup': 'Setup',
      'preview.safe_search': 'Safe Search',
      'preview.block_social': 'Block Social Media',
      'preview.block_violence': 'Block Violence',
      'preview.blocked_keywords': 'Blocked Keywords',
      'preview.keyword_violence': 'violence',
      'preview.keyword_gambling': 'gambling',
      'preview.wellbeing_overall': 'Overall Wellbeing',
      'preview.wellbeing_good': 'Good',
      'preview.day_mon': 'Mon',
      'preview.day_tue': 'Tue',
      'preview.day_wed': 'Wed',
      'preview.day_thu': 'Thu',
      'preview.day_fri': 'Fri',
      'preview.ai_guard': 'AI Safety Guard',
      'preview.active': 'Active',
      'preview.alert_inappropriate': 'Inappropriate Language',
      'preview.alert_detected': 'Detected 3h ago',
      'preview.badge_new': 'NEW',
      'preview.stat_children': 'Children',
      'preview.stat_streak': 'Streak',
      'preview.stat_safety': 'Safety',
      'preview.activity_title': 'Letter Sound Adventure',
      'preview.activity_meta': 'Emma • 2h ago',
      // Parent onboarding (titles/subtitles/highlights)
      'onboard.parent.1.title': 'Welcome to SafePlay',
      'onboard.parent.1.subtitle': 'Your Child\'s Safety is Our Priority',
      'onboard.parent.1.desc':
          'SafePlay provides a secure, engaging learning environment where your children can explore, learn, and grow safely online.',
      'onboard.parent.1.h1':
          'Age-appropriate content for all children',
      'onboard.parent.1.h2': 'AI-powered safety monitoring',
      'onboard.parent.1.h3': 'Educational games and activities',
      'onboard.parent.1.h4': 'Complete parental oversight',
      'onboard.parent.2.title': 'Manage Child Profiles',
      'onboard.parent.2.subtitle': 'Create & Customize Profiles',
      'onboard.parent.2.desc':
          'Add multiple children with personalized profiles. Set age groups, configure login methods, and track individual progress.',
      'onboard.parent.2.h1': 'Support for Junior and Bright age groups',
      'onboard.parent.2.h2': 'Customizable avatars and names',
      'onboard.parent.2.h3': 'Individual progress tracking',
      'onboard.parent.2.h4': 'Easy login setup for each child',
      'onboard.parent.3.title': 'Browser Controls',
      'onboard.parent.3.subtitle': 'Safe Internet Browsing',
      'onboard.parent.3.desc':
          'Configure comprehensive browser controls to ensure your children only access safe, age-appropriate content online.',
      'onboard.parent.3.h1': 'Safe search filtering enabled by default',
      'onboard.parent.3.h2': 'Block social media and harmful content',
      'onboard.parent.3.h3': 'Custom blocked keywords',
      'onboard.parent.3.h4': 'Whitelist trusted websites',
      'onboard.parent.4.title': 'Wellbeing Monitoring',
      'onboard.parent.4.subtitle': 'Track Emotional Health',
      'onboard.parent.4.desc':
          'Stay connected with your child\'s emotional wellbeing through regular check-ins and mood tracking reports.',
      'onboard.parent.4.h1': 'Weekly wellbeing check-ins',
      'onboard.parent.4.h2': 'Mood tracking and history',
      'onboard.parent.4.h3': 'Emotional health insights',
      'onboard.parent.4.h4': 'Early concern detection',
      'onboard.parent.5.title': 'Messaging Safety',
      'onboard.parent.5.subtitle': 'AI-Powered Protection',
      'onboard.parent.5.desc':
          'Our advanced AI monitors all messaging between students and teachers, instantly flagging any concerning content.',
      'onboard.parent.5.h1': 'Real-time message monitoring',
      'onboard.parent.5.h2': 'Profanity and bullying detection',
      'onboard.parent.5.h3': 'Instant parent notifications',
      'onboard.parent.5.h4': 'Complete conversation transparency',
      'onboard.parent.6.title': 'Activity Tracking',
      'onboard.parent.6.subtitle': 'Stay Informed',
      'onboard.parent.6.desc':
          'Monitor your child\'s learning journey with detailed activity reports, achievements, and progress metrics.',
      'onboard.parent.6.h1': 'Daily activity summaries',
      'onboard.parent.6.h2': 'Learning progress reports',
      'onboard.parent.6.h3': 'Achievement tracking',
      'onboard.parent.6.h4': 'Time spent analytics',
      'onboard.parent.7.title': 'Get Started',
      'onboard.parent.7.subtitle': 'You\'re All Set!',
      'onboard.parent.7.desc':
          'You\'re ready to create a safe learning environment for your children. Sign in to access your parent dashboard.',
      'onboard.parent.7.h1': 'Add your first child profile',
      'onboard.parent.7.h2': 'Configure safety settings',
      'onboard.parent.7.h3': 'Monitor progress anytime',
      'onboard.parent.7.h4': 'View activity reports',
    },
    'ar': {
      // Generic
      'lang.english': 'الإنجليزية',
      'lang.arabic': 'العربية',
      'action.continue': 'متابعة',
      'action.skip': 'تخطي',
      'action.get_started': 'ابدأ الآن',
      'action.next': 'التالي',
      'action.previous': 'السابق',
      'action.login': 'تسجيل الدخول',
      'action.signup': 'إنشاء حساب',
      'action.refresh': 'تحديث',
      'action.change_language': 'تغيير اللغة',
      'label.parent_portal': 'بوابة الوالدين',
      'label.safeplay_portal': 'بوابة سيف بلاي',
      'label.welcome_parent': 'مرحبًا بك في سيف بلاي',
      'label.parent_subtitle': 'سلامة طفلك هي أولويتنا',
      'label.language_prompt': 'اختر لغتك',
      'label.language_description':
          'يمكنك التبديل في أي وقت من القائمة داخل لوحة الوالدين.',
      'label.parent_login': 'تسجيل دخول الوالد',
      'label.parent_signup': 'إنشاء حساب ولي الأمر',
      'label.email': 'البريد الإلكتروني',
      'label.password': 'كلمة المرور',
      'label.forgot_password': 'هل نسيت كلمة المرور؟',
      'label.no_account': 'لا تملك حسابًا؟',
      'label.have_account': 'لديك حساب بالفعل؟',
      'label.home': 'لوحة الوالدين',
      'label.controls': 'ضوابط المتصفح',
      'label.wellbeing': 'تقارير الرفاه',
      'label.messaging': 'سلامة المراسلة',
      'label.nav_home': 'الرئيسية',
      'label.nav_controls': 'الضوابط',
      'label.nav_wellbeing': 'الرفاه',
      'label.nav_alerts': 'التنبيهات',
      'label.ai_wellbeing': 'تقرير الذكاء الاصطناعي للصحة النفسية',
      'label.recent_checkins': 'أحدث تسجيلات الشعور',
      'label.this_weeks_mood': 'مزاج هذا الأسبوع',
      'label.browser_activity': 'سجل نشاط المتصفح',
      'label.privacy_note':
          'يتم عرض ملخصات عامة دون ملاحظات خام، للمساعدة على محادثات لطيفة.',
      'browser.summary_hint':
          'ملخص عام للنشاط الإلكتروني الأخير مع الحفاظ على الخصوصية.',
      'browser.error_title': 'تعذر تحميل ملخص نشاط التصفح الأخير.',
      'browser.empty': 'لا يوجد نشاط كافٍ لعرض ملخص حتى الآن.',
      'label.language_setting': 'اللغة',
      'label.language_setting_desc':
          'بدّل بين الإنجليزية والعربية لتجربة الوالد.',
      'settings.title': 'الإعدادات',
      'settings.subtitle': 'إدارة الحساب والتفضيلات',
      'settings.change_password': 'تغيير كلمة المرور',
      'settings.change_password_desc': 'حدّث كلمة مرور حسابك',
      'settings.notifications': 'الإشعارات',
      'settings.notifications_desc': 'إدارة تفضيلات الإشعارات',
      'settings.privacy': 'الخصوصية والأمان',
      'settings.privacy_desc': 'إدارة إعدادات الخصوصية',
      'settings.help': 'المساعدة والدعم',
      'settings.help_desc': 'احصل على مساعدة وتواصل مع الدعم',
      'settings.logout': 'تسجيل الخروج',
      'settings.delete_account': 'حذف الحساب',
      'settings.delete_account_desc': 'حذف حسابك وكل البيانات نهائيًا',
      'settings.sign_out': 'تسجيل الخروج',
      // Parent onboarding (titles/subtitles/highlights)
      'onboard.parent.1.title': 'مرحبًا بك في سيف بلاي',
      'onboard.parent.1.subtitle': 'سلامة طفلك هي أولويتنا',
      'onboard.parent.1.desc':
          'يقدم سيف بلاي بيئة تعلم آمنة وجذابة ليكتشف الأطفال ويتعلموا وينموا بثقة.',
      'onboard.parent.1.h1': 'محتوى مناسب للعمر لكل طفل',
      'onboard.parent.1.h2': 'مراقبة أمان مدعومة بالذكاء الاصطناعي',
      'onboard.parent.1.h3': 'ألعاب وأنشطة تعليمية',
      'onboard.parent.1.h4': 'رقابة كاملة للوالدين',
      'onboard.parent.2.title': 'إدارة ملفات الأطفال',
      'onboard.parent.2.subtitle': 'إنشاء وتخصيص الملفات',
      'onboard.parent.2.desc':
          'أضف عدة أطفال بملفات شخصية. حدد الفئة العمرية، واضبط طرق الدخول، وتتبع التقدم لكل طفل.',
      'onboard.parent.2.h1': 'دعم لمجموعتي الأعمار جونيور وبرايت',
      'onboard.parent.2.h2': 'صور وأسماء قابلة للتخصيص',
      'onboard.parent.2.h3': 'تتبع تقدم فردي',
      'onboard.parent.2.h4': 'إعداد تسجيل دخول سهل لكل طفل',
      'onboard.parent.3.title': 'ضوابط المتصفح',
      'onboard.parent.3.subtitle': 'تصفح آمن للإنترنت',
      'onboard.parent.3.desc':
          'اضبط ضوابط المتصفح لضمان وصول أطفالك إلى محتوى آمن ومناسب لأعمارهم فقط.',
      'onboard.parent.3.h1': 'تفعيل البحث الآمن افتراضيًا',
      'onboard.parent.3.h2': 'حظر التواصل الاجتماعي والمحتوى الضار',
      'onboard.parent.3.h3': 'كلمات محظورة مخصصة',
      'onboard.parent.3.h4': 'قائمة بيضاء للمواقع الموثوقة',
      'onboard.parent.4.title': 'مراقبة الرفاه',
      'onboard.parent.4.subtitle': 'تتبع الحالة الشعورية',
      'onboard.parent.4.desc':
          'ابقَ على اتصال بصحة طفلك النفسية عبر تسجيلات الشعور المنتظمة وتقارير المزاج.',
      'onboard.parent.4.h1': 'تسجيل شعور أسبوعي',
      'onboard.parent.4.h2': 'تتبع المزاج والسجل',
      'onboard.parent.4.h3': 'رؤى للصحة النفسية',
      'onboard.parent.4.h4': 'اكتشاف مبكر للمخاوف',
      'onboard.parent.5.title': 'سلامة المراسلة',
      'onboard.parent.5.subtitle': 'حماية بالذكاء الاصطناعي',
      'onboard.parent.5.desc':
          'يُراقب الذكاء الاصطناعي الرسائل بين الطلاب والمعلمين ويبلغ فورًا عن أي محتوى مقلق.',
      'onboard.parent.5.h1': 'مراقبة الرسائل لحظيًا',
      'onboard.parent.5.h2': 'كشف الألفاظ الجارحة والتنمر',
      'onboard.parent.5.h3': 'تنبيهات فورية للوالدين',
      'onboard.parent.5.h4': 'شفافية كاملة للمحادثات',
      'onboard.parent.6.title': 'تتبع النشاط',
      'onboard.parent.6.subtitle': 'ابقَ على اطلاع',
      'onboard.parent.6.desc':
          'راقب رحلة تعلم طفلك بتقارير نشاط مفصلة، وإنجازات، ومقاييس تقدم.',
      'onboard.parent.6.h1': 'ملخصات نشاط يومية',
      'onboard.parent.6.h2': 'تقارير تقدم التعلم',
      'onboard.parent.6.h3': 'تتبع الإنجازات',
      'onboard.parent.6.h4': 'تحليلات وقت الاستخدام',
      'onboard.parent.7.title': 'ابدأ الآن',
      'onboard.parent.7.subtitle': 'كل شيء جاهز!',
      'onboard.parent.7.desc':
          'أنت جاهز لإنشاء بيئة تعلم آمنة لأطفالك. سجّل الدخول للوصول إلى لوحة الوالد.',
      'onboard.parent.7.h1': 'أضف أول ملف لطفلك',
      'onboard.parent.7.h2': 'اضبط إعدادات الأمان',
      'onboard.parent.7.h3': 'راقب التقدم في أي وقت',
      'onboard.parent.7.h4': 'اعرض تقارير النشاط',
    },
  };

  String t(String key) {
    return _localizedValues[locale.languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ar'].contains(locale.languageCode.toLowerCase());

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this);
}

extension LocalizedString on String {
  String tr(BuildContext context) => AppLocalizations.of(context).t(this);
}
