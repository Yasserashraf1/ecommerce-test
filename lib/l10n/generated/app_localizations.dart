import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Notes App'**
  String get appTitle;

  /// No description provided for @myNotes.
  ///
  /// In en, this message translates to:
  /// **'My Notes'**
  String get myNotes;

  /// No description provided for @addNote.
  ///
  /// In en, this message translates to:
  /// **'Add Note'**
  String get addNote;

  /// No description provided for @editNote.
  ///
  /// In en, this message translates to:
  /// **'Edit Note'**
  String get editNote;

  /// No description provided for @noteDetails.
  ///
  /// In en, this message translates to:
  /// **'Note Details'**
  String get noteDetails;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @favorites.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favorites;

  /// No description provided for @aboutCreator.
  ///
  /// In en, this message translates to:
  /// **'About Creator'**
  String get aboutCreator;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcome;

  /// No description provided for @loginToContinue.
  ///
  /// In en, this message translates to:
  /// **'Login to continue using the app'**
  String get loginToContinue;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @login.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// No description provided for @register.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get register;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// No description provided for @orLoginWith.
  ///
  /// In en, this message translates to:
  /// **'Or Login With'**
  String get orLoginWith;

  /// No description provided for @dontHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t Have an Account?'**
  String get dontHaveAccount;

  /// No description provided for @haveAccount.
  ///
  /// In en, this message translates to:
  /// **'Have an Account?'**
  String get haveAccount;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @enterInformation.
  ///
  /// In en, this message translates to:
  /// **'Enter your information to get started'**
  String get enterInformation;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @userName.
  ///
  /// In en, this message translates to:
  /// **'User Name'**
  String get userName;

  /// No description provided for @noteTitle.
  ///
  /// In en, this message translates to:
  /// **'Note Title'**
  String get noteTitle;

  /// No description provided for @noteContent.
  ///
  /// In en, this message translates to:
  /// **'Note Content'**
  String get noteContent;

  /// No description provided for @enterNoteTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter note title'**
  String get enterNoteTitle;

  /// No description provided for @enterNoteContent.
  ///
  /// In en, this message translates to:
  /// **'Enter note content'**
  String get enterNoteContent;

  /// No description provided for @updateNote.
  ///
  /// In en, this message translates to:
  /// **'Update Note'**
  String get updateNote;

  /// No description provided for @deleteNote.
  ///
  /// In en, this message translates to:
  /// **'Delete Note'**
  String get deleteNote;

  /// No description provided for @noNotesYet.
  ///
  /// In en, this message translates to:
  /// **'No notes yet!'**
  String get noNotesYet;

  /// No description provided for @tapToAddFirstNote.
  ///
  /// In en, this message translates to:
  /// **'Tap the + button to add your first note'**
  String get tapToAddFirstNote;

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImage;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Gallery'**
  String get gallery;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @uploadingImage.
  ///
  /// In en, this message translates to:
  /// **'Uploading image...'**
  String get uploadingImage;

  /// No description provided for @removingImage.
  ///
  /// In en, this message translates to:
  /// **'Removing image...'**
  String get removingImage;

  /// No description provided for @imageUploadedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Image uploaded successfully!'**
  String get imageUploadedSuccessfully;

  /// No description provided for @failedToUploadImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image'**
  String get failedToUploadImage;

  /// No description provided for @imageRemovedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Image removed successfully!'**
  String get imageRemovedSuccessfully;

  /// No description provided for @failedToRemoveImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to remove image'**
  String get failedToRemoveImage;

  /// No description provided for @editYourName.
  ///
  /// In en, this message translates to:
  /// **'Edit Your Name'**
  String get editYourName;

  /// No description provided for @enterFullName.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get enterFullName;

  /// No description provided for @updateName.
  ///
  /// In en, this message translates to:
  /// **'Update Name'**
  String get updateName;

  /// No description provided for @accountInformation.
  ///
  /// In en, this message translates to:
  /// **'Account Information'**
  String get accountInformation;

  /// No description provided for @accountStatus.
  ///
  /// In en, this message translates to:
  /// **'Account Status'**
  String get accountStatus;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @created.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get created;

  /// No description provided for @profileUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully!'**
  String get profileUpdatedSuccessfully;

  /// No description provided for @failedToUpdateProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile'**
  String get failedToUpdateProfile;

  /// No description provided for @updateProfileImage.
  ///
  /// In en, this message translates to:
  /// **'Update Profile Image'**
  String get updateProfileImage;

  /// No description provided for @profileImageUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Profile image updated successfully!'**
  String get profileImageUpdatedSuccessfully;

  /// No description provided for @failedToUpdateProfileImage.
  ///
  /// In en, this message translates to:
  /// **'Failed to update profile image'**
  String get failedToUpdateProfileImage;

  /// No description provided for @appSettings.
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// No description provided for @account.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get account;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push Notifications'**
  String get pushNotifications;

  /// No description provided for @receiveNotifications.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications for reminders'**
  String get receiveNotifications;

  /// No description provided for @darkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get darkMode;

  /// No description provided for @switchToTheme.
  ///
  /// In en, this message translates to:
  /// **'Switch to dark theme'**
  String get switchToTheme;

  /// No description provided for @autoSave.
  ///
  /// In en, this message translates to:
  /// **'Auto Save'**
  String get autoSave;

  /// No description provided for @autoSaveDescription.
  ///
  /// In en, this message translates to:
  /// **'Automatically save notes while typing'**
  String get autoSaveDescription;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @updateAccountPassword.
  ///
  /// In en, this message translates to:
  /// **'Update your account password'**
  String get updateAccountPassword;

  /// No description provided for @backupSync.
  ///
  /// In en, this message translates to:
  /// **'Backup & Sync'**
  String get backupSync;

  /// No description provided for @backupToCloud.
  ///
  /// In en, this message translates to:
  /// **'Backup your notes to cloud'**
  String get backupToCloud;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountPermanently.
  ///
  /// In en, this message translates to:
  /// **'Permanently delete your account'**
  String get deleteAccountPermanently;

  /// No description provided for @helpFAQ.
  ///
  /// In en, this message translates to:
  /// **'Help & FAQ'**
  String get helpFAQ;

  /// No description provided for @getHelpAnswers.
  ///
  /// In en, this message translates to:
  /// **'Get help and find answers'**
  String get getHelpAnswers;

  /// No description provided for @reportBug.
  ///
  /// In en, this message translates to:
  /// **'Report a Bug'**
  String get reportBug;

  /// No description provided for @helpImproveApp.
  ///
  /// In en, this message translates to:
  /// **'Help us improve the app'**
  String get helpImproveApp;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @restartToApplyTheme.
  ///
  /// In en, this message translates to:
  /// **'Restart app to apply theme changes'**
  String get restartToApplyTheme;

  /// No description provided for @noFavoritesYet.
  ///
  /// In en, this message translates to:
  /// **'No Favorites Yet'**
  String get noFavoritesYet;

  /// No description provided for @markFavorites.
  ///
  /// In en, this message translates to:
  /// **'Mark your favorite notes to see them here'**
  String get markFavorites;

  /// No description provided for @aboutThisApp.
  ///
  /// In en, this message translates to:
  /// **'About This App'**
  String get aboutThisApp;

  /// No description provided for @appDescription.
  ///
  /// In en, this message translates to:
  /// **'A beautiful and intuitive notes app built with Flutter and PHP. Features include:'**
  String get appDescription;

  /// No description provided for @feature1.
  ///
  /// In en, this message translates to:
  /// **'📝 Create and edit notes'**
  String get feature1;

  /// No description provided for @feature2.
  ///
  /// In en, this message translates to:
  /// **'📷 Add images to notes'**
  String get feature2;

  /// No description provided for @feature3.
  ///
  /// In en, this message translates to:
  /// **'👤 User profiles'**
  String get feature3;

  /// No description provided for @feature4.
  ///
  /// In en, this message translates to:
  /// **'🎨 Modern teal theme'**
  String get feature4;

  /// No description provided for @feature5.
  ///
  /// In en, this message translates to:
  /// **'🔒 Secure authentication'**
  String get feature5;

  /// No description provided for @madeWith.
  ///
  /// In en, this message translates to:
  /// **'Made with Flutter & PHP'**
  String get madeWith;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait...'**
  String get pleaseWait;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @pleaseFillAllFields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get pleaseFillAllFields;

  /// No description provided for @nameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty'**
  String get nameCannotBeEmpty;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login Failed, Check Your Email and Password'**
  String get loginFailed;

  /// No description provided for @registrationSuccessful.
  ///
  /// In en, this message translates to:
  /// **'SignUp Successfully'**
  String get registrationSuccessful;

  /// No description provided for @registrationFailed.
  ///
  /// In en, this message translates to:
  /// **'SignUp Failed'**
  String get registrationFailed;

  /// No description provided for @noteAddedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Note added successfully!'**
  String get noteAddedSuccessfully;

  /// No description provided for @failedToAddNote.
  ///
  /// In en, this message translates to:
  /// **'Failed to add note'**
  String get failedToAddNote;

  /// No description provided for @noteUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Note updated successfully!'**
  String get noteUpdatedSuccessfully;

  /// No description provided for @failedToUpdateNote.
  ///
  /// In en, this message translates to:
  /// **'Failed to update note'**
  String get failedToUpdateNote;

  /// No description provided for @noteDeletedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Note deleted successfully!'**
  String get noteDeletedSuccessfully;

  /// No description provided for @failedToDeleteNote.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete note'**
  String get failedToDeleteNote;

  /// No description provided for @confirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this note?'**
  String get confirmDelete;

  /// No description provided for @confirmDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete your account? This action cannot be undone and all your notes will be permanently deleted.'**
  String get confirmDeleteAccount;

  /// No description provided for @confirmRemoveImage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this image?'**
  String get confirmRemoveImage;

  /// No description provided for @confirmLogout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get confirmLogout;

  /// No description provided for @deleteNoteDescription.
  ///
  /// In en, this message translates to:
  /// **'This will also remove the associated image.'**
  String get deleteNoteDescription;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon!'**
  String get comingSoon;

  /// No description provided for @featureComingSoon.
  ///
  /// In en, this message translates to:
  /// **'This feature is coming soon!'**
  String get featureComingSoon;

  /// No description provided for @tapToAddImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to add image (optional)'**
  String get tapToAddImage;

  /// No description provided for @tapToAddImageRequired.
  ///
  /// In en, this message translates to:
  /// **'Tap to add image'**
  String get tapToAddImageRequired;

  /// No description provided for @addImage.
  ///
  /// In en, this message translates to:
  /// **'Add\nImage'**
  String get addImage;

  /// No description provided for @noImage.
  ///
  /// In en, this message translates to:
  /// **'No\nImage'**
  String get noImage;

  /// No description provided for @errorPickingImage.
  ///
  /// In en, this message translates to:
  /// **'Error picking image'**
  String get errorPickingImage;

  /// No description provided for @errorSelectingImage.
  ///
  /// In en, this message translates to:
  /// **'Error selecting image'**
  String get errorSelectingImage;

  /// No description provided for @noName.
  ///
  /// In en, this message translates to:
  /// **'No Name'**
  String get noName;

  /// No description provided for @noEmail.
  ///
  /// In en, this message translates to:
  /// **'No email'**
  String get noEmail;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @recentlyJoined.
  ///
  /// In en, this message translates to:
  /// **'Recently joined'**
  String get recentlyJoined;

  /// No description provided for @imageOptions.
  ///
  /// In en, this message translates to:
  /// **'Image Options'**
  String get imageOptions;

  /// No description provided for @subtitle.
  ///
  /// In en, this message translates to:
  /// **'Flutter Developer & Data Science Enthusiast'**
  String get subtitle;

  /// No description provided for @myName.
  ///
  /// In en, this message translates to:
  /// **'Eng.Yasser Ashraf'**
  String get myName;

  /// No description provided for @them_s.
  ///
  /// In en, this message translates to:
  /// **'Them'**
  String get them_s;

  /// No description provided for @system_s.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system_s;

  /// No description provided for @light_s.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light_s;

  /// No description provided for @dark_s.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark_s;

  /// No description provided for @themMode_s.
  ///
  /// In en, this message translates to:
  /// **'Them Mode'**
  String get themMode_s;

  /// No description provided for @alwaysUseLight.
  ///
  /// In en, this message translates to:
  /// **'Always Use Light Theme'**
  String get alwaysUseLight;

  /// No description provided for @alwaysUseDark.
  ///
  /// In en, this message translates to:
  /// **'Always Use Dark Theme'**
  String get alwaysUseDark;

  /// No description provided for @followSystemTheme.
  ///
  /// In en, this message translates to:
  /// **'Follow System Theme'**
  String get followSystemTheme;

  /// No description provided for @quickToggleFor.
  ///
  /// In en, this message translates to:
  /// **'Quick Toggle for dark/ligth mode'**
  String get quickToggleFor;

  /// No description provided for @languageChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Language changed successfully!'**
  String get languageChangedSuccessfully;

  /// No description provided for @themeChangedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Theme changed successfully!'**
  String get themeChangedSuccessfully;

  /// No description provided for @addedToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Added to favorites'**
  String get addedToFavorites;

  /// No description provided for @removedFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Removed from favorites'**
  String get removedFromFavorites;

  /// No description provided for @noFavorites.
  ///
  /// In en, this message translates to:
  /// **'No favorites yet'**
  String get noFavorites;

  /// No description provided for @noFavoritesDescription.
  ///
  /// In en, this message translates to:
  /// **'Tap the heart icon on any note to add it to your favorites.'**
  String get noFavoritesDescription;

  /// No description provided for @backToNotes.
  ///
  /// In en, this message translates to:
  /// **'Back to Notes'**
  String get backToNotes;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from Favorites'**
  String get removeFromFavorites;

  /// No description provided for @confirmRemoveFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this note from your favorites?'**
  String get confirmRemoveFromFavorites;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
