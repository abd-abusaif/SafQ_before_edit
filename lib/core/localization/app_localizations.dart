import 'package:flutter/material.dart';
import 'translations/ar.dart';
import 'translations/en.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  // ← الطريقة السهلة للوصول من أي شاشة
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  // ← اختيار اللغة المناسبة
  Map<String, String> get _translations {
    switch (locale.languageCode) {
      case 'ar':
        return arTranslations;
      case 'en':
        return enTranslations;
      default:
        return arTranslations;
    }
  }

  // ← الدالة الرئيسية للترجمة
  String translate(String key) {
    return _translations[key] ?? key;
  }

  // ← اختصار مريح
  String call(String key) => translate(key);

  // ← هل اللغة عربية؟
  bool get isArabic => locale.languageCode == 'ar';

  // ── Getters لكل النصوص ──────────────────────────

  // Auth
  String get appName => translate('app_name');
  String get stationName => translate('station_name');
  String get welcome => translate('welcome');
  String get loginSubtitle => translate('login_subtitle');
  String get idNumber => translate('id_number');
  String get idHint => translate('id_hint');
  String get password => translate('password');
  String get passwordHint => translate('password_hint');
  String get userType => translate('user_type');
  String get loginBtn => translate('login_btn');
  String get forgotPassword => translate('forgot_password');
  String get logout => translate('logout');
  String get logoutConfirm => translate('logout_confirm');
  String get logoutQuestion => translate('logout_question');
  String get cancel => translate('cancel');
  String get ok => translate('ok');

  // User Roles
  String get driver => translate('driver');
  String get supervisor => translate('supervisor');
  String get security => translate('security');

  // Validation
  String get enterId => translate('enter_id');
  String get id9Digits => translate('id_9_digits');
  String get idNumbersOnly => translate('id_numbers_only');
  String get enterPassword => translate('enter_password');
  String get passwordMin6 => translate('password_min_6');
  String get passwordSymbol => translate('password_symbol');
  String get wrongCredentials => translate('wrong_credentials');
  String get wrongCredentialsMsg => translate('wrong_credentials_msg');
  String get wrongRole => translate('wrong_role');
  String get wrongRoleMsg => translate('wrong_role_msg');
  String get unexpectedError => translate('unexpected_error');
  String get tryAgain => translate('try_again');

  // Navigation
  String get home => translate('home');
  String get notifications => translate('notifications');
  String get profile => translate('profile');
  String get permissions => translate('permissions');
  String get violations => translate('violations');

  // Home — Driver
  String get welcomeUser => translate('welcome_user');
  String get queueStatus => translate('queue_status');
  String get queueNumber => translate('queue_number');
  String get queueTime => translate('queue_time');
  String get queueReg => translate('queue_reg');
  String get rejectedQueue => translate('rejected_queue');
  String get rejectedMsg => translate('rejected_msg');
  String get violationBlockWarn => translate('violation_block_warn');

  // Home — Supervisor
  String get manageQueue => translate('manage_queue');
  String get activeVehicles => translate('active_vehicles');
  String get waiting => translate('waiting');
  String get completedTrips => translate('completed_trips');

  // Home — Security
  String get vehicleStatus => translate('vehicle_status');
  String get noVehicles => translate('no_vehicles');
  String get rejectedCount => translate('rejected_count');
  String get handledConfirm => translate('handled_confirm');
  String get handledQuestion => translate('handled_question');
  String get done => translate('done');
  String get approvedLabel => translate('approved');
  String get rejectedLabel => translate('rejected');
  String get markHandled => translate('mark_handled');

  // Profile
  String get personalPage => translate('personal_page');
  String get editPassword => translate('edit_password');
  String get switchLight => translate('switch_light');
  String get switchDark => translate('switch_dark');
  String get switchLanguage => translate('switch_language');
  String get driverInfo => translate('driver_info');
  String get lineInfo => translate('line_info');
  String get vehicleInfo => translate('vehicle_info');
  String get ownerInfo => translate('owner_info');
  String get supervisorInfo => translate('supervisor_info');
  String get securityInfo => translate('security_info');
  String get fullName => translate('full_name');
  String get idNumberLabel => translate('id_number_label');
  String get phone1 => translate('phone1');
  String get phone2 => translate('phone2');
  String get licenseNumber => translate('license_number');
  String get licenseGrade => translate('license_grade');
  String get licenseExpiry => translate('license_expiry');
  String get medicalExpiry => translate('medical_expiry');
  String get lineNumber => translate('line_number');
  String get passengerFare => translate('passenger_fare');
  String get vehicleNumber => translate('vehicle_number');
  String get vehicleCode => translate('vehicle_code');
  String get model => translate('model');
  String get driverType => translate('driver_type');
  String get seats => translate('seats');
  String get operationExpiry => translate('operation_expiry');
  String get vehicleLicExpiry => translate('vehicle_lic_expiry');
  String get insuranceExpiry => translate('insurance_expiry');
  String get chassisNumber => translate('chassis_number');
  String get ownerName => translate('owner_name');
  String get ownerId => translate('owner_id');
  String get ownerPhone => translate('owner_phone');
  String get gateName => translate('gate_name');
  String get phoneLabel => translate('phone_label');
  String get linesResponsible => translate('lines_responsible');
  String get linesCount => translate('lines_count');

  // Change Password
  String get changePassword => translate('change_password');
  String get currentPassword => translate('current_password');
  String get currentPassHint => translate('current_pass_hint');
  String get newPassword => translate('new_password');
  String get newPassHint => translate('new_pass_hint');
  String get confirmPassword => translate('confirm_password');
  String get confirmPassHint => translate('confirm_pass_hint');
  String get save => translate('save');
  String get passwordChanged => translate('password_changed');
  String get passwordChangedMsg => translate('password_changed_msg');
  String get wrongCurrentPass => translate('wrong_current_pass');
  String get passMin6 => translate('pass_min_6');
  String get passSymbol => translate('pass_symbol');
  String get passSame => translate('pass_same');
  String get passNoMatch => translate('pass_no_match');
  String get enterCurrentPass => translate('enter_current_pass');
  String get enterNewPass => translate('enter_new_pass');
  String get confirmPass => translate('confirm_pass');

  // Permissions
  String get permissionsTitle => translate('permissions_title');
  String get approvedPermissions => translate('approved_permissions');
  String get newPermission => translate('new_permission');
  String get permissionType => translate('permission_type');
  String get maintenance => translate('maintenance');
  String get parcel => translate('parcel');
  String get other => translate('other');
  String get permissionReason => translate('permission_reason');
  String get reasonHint => translate('reason_hint');
  String get requestDate => translate('request_date');
  String get duration => translate('duration');
  String get sendRequest => translate('send_request');
  String get requestSent => translate('request_sent');
  String get requestSentMsg => translate('request_sent_msg');
  String get myPermissions => translate('my_permissions');
  String get noPermissions => translate('no_permissions');
  String get noApproved => translate('no_approved');
  String get permissionApproved => translate('permission_approved');
  String get permissionRejected => translate('permission_rejected');
  String get permissionPending => translate('permission_pending');
  String get rejectionReason => translate('rejection_reason');
  String get vehiclePlate => translate('vehicle_plate');
  String get errorTryAgain => translate('error_try_again');

  // Violations
  String get violationsTitle => translate('violations_title');
  String get noViolations => translate('no_violations');
  String get cleanRecord => translate('clean_record');
  String get totalViolations => translate('total_violations');
  String get blockEntryWarn => translate('block_entry_warn');
  String get withBlock => translate('with_block');
  String get withoutBlock => translate('without_block');
  String get violationType => translate('violation_type');
  String get amount => translate('amount');
  String get date => translate('date');
  String get notes => translate('notes');

  // Notifications
  String get notificationsTitle => translate('notifications_title');
  String get noNotifications => translate('no_notifications');

  // General
  String get error => translate('error');
  String get unexpectedErr => translate('unexpected_err');
  String get refresh => translate('refresh');
  String get loading => translate('loading');
}

// ── Delegate ─────────────────────────────────────────
class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ar', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
