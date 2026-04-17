import 'package:flutter/material.dart';
import 'translations/ar.dart';
import 'translations/en.dart';

class AppLocalizations {
  final Locale locale;
  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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

  String translate(String key) => _translations[key] ?? key;
  String call(String key) => translate(key);
  bool get isArabic => locale.languageCode == 'ar';

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

  // Roles
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

  // Loading Validity
  String get loadingValidity => translate('loading_validity');
  String get loadingValidityExpired => translate('loading_validity_expired');
  String get dayLabel => translate('day');
  String get hourLabel => translate('hour');
  String get minuteLabel => translate('minute');
  String get expiredLabel => translate('expired');

  // License Warning
  String get operatingLicense => translate('operating_license');
  String get vehicleLicWarn => translate('vehicle_license_warn');
  String get driverLicWarn => translate('driver_license_warn');
  String get licenseExpiredWarn => translate('license_expired_warn');
  String get registerBlocked => translate('register_blocked');

  // Movement Permit
  String get movementPermit => translate('movement_permit');
  String get availableSlots => translate('available_slots');
  String get generatePermit => translate('generate_permit');
  String get permitVehicle => translate('permit_vehicle');
  String get permitExitTime => translate('permit_exit_time');
  String get permitExitGate => translate('permit_exit_gate');
  String get permitLicenseNum => translate('permit_license_num');
  String get permitDestination => translate('permit_destination');
  String get close => translate('close');

  // Entered Vehicles
  String get enteredVehicles => translate('entered_vehicles');
  String get entryTime => translate('entry_time');

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
  String get lineFromTo => translate('line_from_to');
  String get lineRoute => translate('line_route');
  String get passengerFare => translate('passenger_fare');
  String get vehicleNumber => translate('vehicle_number');
  String get vehicleCode => translate('vehicle_code');
  String get company => translate('company');
  String get model => translate('model');
  String get productionYear => translate('production_year');
  String get driverType => translate('driver_type');
  String get seats => translate('seats');
  String get operationExpiry => translate('operation_expiry');
  String get vehicleLicExpiry => translate('vehicle_lic_expiry');
  String get insuranceExpiry => translate('insurance_expiry');
  String get chassisNumber => translate('chassis_number');
  String get chassisConfirm => translate('chassis_confirm');
  String get loadingAllowed => translate('loading_allowed');
  String get loadingYes => translate('loading_yes');
  String get loadingNo => translate('loading_no');
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
  String get reasonRequired => translate('reason_required');
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
  String get totalCount => translate('total_count');
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

// ── Extension for new keys ────────────────────────────────────────────────────
extension AppLocalizationsExtended on AppLocalizations {
  // Navigation
  String get myLines => translate('my_lines');
  String get myAccount => translate('my_account');

  // Supervisor Home
  String get activeVehiclesInCompound =>
      translate('active_vehicles_in_compound');
  String get noVehiclesInQueue => translate('no_vehicles_in_queue');
  String get searchLine => translate('search_line');
  String get vehiclesCol => translate('vehicles_col');
  String get lineNameCol => translate('line_name_col');
  String get lineNumberCol => translate('line_number_col');

  // Security Home
  String get approvedCount => translate('approved_count');

  // Supervisor Permissions Center
  String get permissionsCenter => translate('permissions_center');
  String get pendingTab => translate('pending_tab');
  String get approvedTab => translate('approved_tab');
  String get rejectedTab => translate('rejected_tab');
  String get noPendingPermissions => translate('no_pending_permissions');
  String get pendingStatus => translate('pending_status');
  String get approvedStatus => translate('approved_status');
  String get rejectedStatus => translate('rejected_status');
  String get noApprovedPermissions => translate('no_approved_permissions');
  String get noRejectedPermissions => translate('no_rejected_permissions');
  String get rejectPermission => translate('reject_permission');
  String get rejectReasonHint => translate('reject_reason_hint');
  String get rejectReasonExample => translate('reject_reason_example');
  String get send => translate('send');
  String get approveBtn => translate('approve_btn');
  String get rejectBtn => translate('reject_btn');
  String get driverNameLabel => translate('driver_name_label');
  String get vehicleNumLabel => translate('vehicle_num_label');
  String get lineLabel => translate('line_label');
  String get durationLabel => translate('duration_label');
  String get requestDateLabel => translate('request_date_label');
  String get rejectionNoteLabel => translate('rejection_note_label');

  // Supervisor Lines
  String get myLinesTitle => translate('my_lines_title');
  String get noAssignedLines => translate('no_assigned_lines');
  String get linePrefix => translate('line_prefix');
  String get registeredVehicles => translate('registered_vehicles');
  String get vehiclesCount => translate('vehicles_count');
  String get passengerFareLabel => translate('passenger_fare_label');
  String get vehicleDetails => translate('vehicle_details');
  String get operatingLicenseLabel => translate('operating_license_label');
  String get driverIdLabel => translate('driver_id_label');
  String get driverPhoneLabel => translate('driver_phone_label');

  // Supervisor Notifications
  String get rejectedLabelCount => translate('rejected_label_count');
  String get handledStatus => translate('handled_status');
  String get needsIntervention => translate('needs_intervention');
  String get handleVehicleBtn => translate('handle_vehicle_btn');
  String get handleConfirmTitle => translate('handle_confirm_title');
  String get handleConfirmMsg => translate('handle_confirm_msg');
  String get driverLabel => translate('driver_label');
  String get vehicleLabel => translate('vehicle_label');
  String get lineRouteLabel => translate('line_route_label');

  // Security Notifications
  String get needsAttentionCount => translate('needs_attention_count');
  String get rejectedVehicleNotification =>
      translate('rejected_vehicle_notification');
  String get handledBySupervisor => translate('handled_by_supervisor');
  String get rejectionReasonLabel => translate('rejection_reason_label');

  // Profile - shared
  String get personalInfo => translate('personal_info');
  String get supervisorRoleLabel => translate('supervisor_role_label');
  String get securityRoleLabel => translate('security_role_label');
  String get nameLabel => translate('name_label');
  String get idLabel => translate('id_label');
  String get phoneInfoLabel => translate('phone_info_label');

  // General
  String get exit => translate('exit');
  String get signOut => translate('sign_out');
  String get signOutQuestion => translate('sign_out_question');
}
