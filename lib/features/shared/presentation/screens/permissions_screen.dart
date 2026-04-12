import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../driver/data/repositories/permission_repository_impl.dart';
import '../../../driver/domain/entities/permission_entity.dart';

class PermissionsScreen extends StatefulWidget {
  const PermissionsScreen({super.key});

  @override
  State<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends State<PermissionsScreen> {
  final _repo = PermissionRepositoryImpl();
  final _reasonCtrl = TextEditingController();

  String _idNumber = '';
  bool _isLoading = false;
  bool _isSubmitting = false;
  List<PermissionEntity> _permissions = [];

  final String _todayDate = DateTime.now().toString().split(' ')[0];

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  AppLocalizations get l => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final session = await SessionManager.getSession();
      if (session != null) _idNumber = session['idNumber'] ?? '';
      final perms = await _repo.getMyPermissions(_idNumber);
      setState(() => _permissions = perms);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _onSubmit() async {
    final reason = _reasonCtrl.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.reasonRequired, style: GoogleFonts.cairo()),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await _repo.submitPermission(
        idNumber: _idNumber,
        reason: reason,
        requestDate: _todayDate,
      );
      if (!mounted) return;

      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppDimensions.cardRadius(context),
            ),
            side: const BorderSide(color: Colors.green, width: 1),
          ),
          icon: Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: AppDimensions.iconXLarge(context),
          ),
          title: Text(
            l.requestSent,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              color: _isDark ? AppColors.textPrimary : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: AppDimensions.fontLarge(context),
            ),
          ),
          content: Text(
            l.requestSentMsg,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              color: _isDark ? AppColors.textSecondary : Colors.black54,
              fontSize: AppDimensions.fontMedium(context),
              height: 1.6,
            ),
          ),
          actionsAlignment: MainAxisAlignment.center,
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _reasonCtrl.clear();
                _loadData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppDimensions.cardRadius(context),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingXLarge(context),
                  vertical: AppDimensions.spacingSmall(context),
                ),
              ),
              child: Text(
                l.ok,
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: AppDimensions.fontMedium(context),
                ),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l.errorTryAgain, style: GoogleFonts.cairo()),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _reasonCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final crossAxis = l.isArabic
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          l.permissionsTitle,
          style: GoogleFonts.cairo(
            color: _isDark ? AppColors.textPrimary : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: AppDimensions.fontLarge(context),
          ),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
                child: Column(
                  crossAxisAlignment: crossAxis,
                  children: [
                    _buildRequestCard(),
                    SizedBox(height: AppDimensions.spacingLarge(context)),
                    _buildMyPermissions(),
                  ],
                ),
              ),
            ),
    );
  }

  // ═══════════════════════════════════════════════
  //  بطاقة إرسال الطلب — حقل نص حر
  // ═══════════════════════════════════════════════
  Widget _buildRequestCard() {
    final textAlign = l.isArabic ? TextAlign.right : TextAlign.left;
    final textDir = l.isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: l.isArabic
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMedium(context),
              vertical: AppDimensions.spacingSmall(context),
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.cardRadius(context)),
                topRight: Radius.circular(AppDimensions.cardRadius(context)),
              ),
            ),
            child: Row(
              mainAxisAlignment: l.isArabic
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                if (!l.isArabic) ...[
                  Icon(
                    Icons.add_circle_outline,
                    color: AppColors.primary,
                    size: AppDimensions.iconMedium(context),
                  ),
                  SizedBox(width: AppDimensions.spacingSmall(context)),
                ],
                Text(
                  l.newPermission,
                  style: GoogleFonts.cairo(
                    color: AppColors.primary,
                    fontSize: AppDimensions.fontMedium(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (l.isArabic) ...[
                  SizedBox(width: AppDimensions.spacingSmall(context)),
                  Icon(
                    Icons.add_circle_outline,
                    color: AppColors.primary,
                    size: AppDimensions.iconMedium(context),
                  ),
                ],
              ],
            ),
          ),

          // Body — حقل نص حر
          Padding(
            padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
            child: Column(
              crossAxisAlignment: l.isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // Label
                Text(
                  l.permissionReason,
                  textAlign: textAlign,
                  style: GoogleFonts.cairo(
                    color: _isDark ? AppColors.textSecondary : Colors.black54,
                    fontSize: AppDimensions.fontSmall(context),
                  ),
                ),
                SizedBox(height: AppDimensions.spacingSmall(context)),

                // ← حقل النص الحر (بدل dropdown)
                TextField(
                  controller: _reasonCtrl,
                  textAlign: textAlign,
                  textDirection: textDir,
                  maxLines: 4,
                  style: GoogleFonts.cairo(
                    color: _isDark ? AppColors.textPrimary : Colors.black87,
                    fontSize: AppDimensions.fontMedium(context),
                  ),
                  decoration: InputDecoration(
                    hintText: l.reasonHint,
                    hintStyle: GoogleFonts.cairo(
                      color: _isDark ? AppColors.textHint : Colors.black38,
                    ),
                    filled: true,
                    fillColor: _isDark
                        ? AppColors.inputFill
                        : AppColors.inputFillLight,
                    prefixIcon: Icon(Icons.edit_note, color: AppColors.primary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.cardRadius(context),
                      ),
                      borderSide: BorderSide(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.cardRadius(context),
                      ),
                      borderSide: BorderSide(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.cardRadius(context),
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: AppDimensions.spacingSmall(context)),

                // تاريخ الطلب
                Text(
                  l.requestDate,
                  textAlign: textAlign,
                  style: GoogleFonts.cairo(
                    color: _isDark ? AppColors.textSecondary : Colors.black54,
                    fontSize: AppDimensions.fontSmall(context),
                  ),
                ),
                SizedBox(height: AppDimensions.spacingXSmall(context)),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingMedium(context),
                    vertical: AppDimensions.spacingMedium(context),
                  ),
                  decoration: BoxDecoration(
                    color: _isDark ? AppColors.inputFill : Colors.white,
                    borderRadius: BorderRadius.circular(
                      AppDimensions.cardRadius(context),
                    ),
                    border: Border.all(
                      color: _isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: AppColors.primary,
                        size: AppDimensions.iconSmall(context),
                      ),
                      Text(
                        _todayDate,
                        style: GoogleFonts.cairo(
                          color: _isDark
                              ? AppColors.textSecondary
                              : Colors.black54,
                          fontSize: AppDimensions.fontMedium(context),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppDimensions.spacingLarge(context)),

                // زر الإرسال
                SizedBox(
                  width: double.infinity,
                  height: AppDimensions.buttonHeight(context),
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                          AppDimensions.cardRadius(context),
                        ),
                      ),
                    ),
                    child: _isSubmitting
                        ? const CircularProgressIndicator(
                            color: AppColors.background,
                          )
                        : Text(
                            l.sendRequest,
                            style: GoogleFonts.cairo(
                              color: AppColors.background,
                              fontSize: AppDimensions.fontLarge(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  قائمة الطلبات السابقة
  // ═══════════════════════════════════════════════
  Widget _buildMyPermissions() {
    return Column(
      crossAxisAlignment: l.isArabic
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: l.isArabic
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            if (!l.isArabic) ...[
              Icon(
                Icons.history,
                color: AppColors.primary,
                size: AppDimensions.iconMedium(context),
              ),
              SizedBox(width: AppDimensions.spacingSmall(context)),
            ],
            Text(
              l.myPermissions,
              style: GoogleFonts.cairo(
                color: _isDark ? AppColors.textPrimary : Colors.black87,
                fontSize: AppDimensions.fontLarge(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            if (l.isArabic) ...[
              SizedBox(width: AppDimensions.spacingSmall(context)),
              Icon(
                Icons.history,
                color: AppColors.primary,
                size: AppDimensions.iconMedium(context),
              ),
            ],
          ],
        ),
        SizedBox(height: AppDimensions.spacingSmall(context)),
        _permissions.isEmpty
            ? Center(
                child: Padding(
                  padding: EdgeInsets.all(AppDimensions.spacingXLarge(context)),
                  child: Text(
                    l.noPermissions,
                    style: GoogleFonts.cairo(
                      color: _isDark ? AppColors.textSecondary : Colors.black54,
                      fontSize: AppDimensions.fontMedium(context),
                    ),
                  ),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _permissions.length,
                itemBuilder: (_, i) => _buildPermissionCard(_permissions[i]),
              ),
      ],
    );
  }

  Widget _buildPermissionCard(PermissionEntity permission) {
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (permission.status) {
      case 'approved':
        statusColor = Colors.green;
        statusLabel = l.permissionApproved;
        statusIcon = Icons.check_circle_outline;
        break;
      case 'rejected':
        statusColor = Colors.redAccent;
        statusLabel = l.permissionRejected;
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusColor = Colors.orange;
        statusLabel = l.permissionPending;
        statusIcon = Icons.hourglass_empty;
    }

    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacingSmall(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(color: statusColor.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMedium(context),
              vertical: AppDimensions.spacingSmall(context),
            ),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.08),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.cardRadius(context)),
                topRight: Radius.circular(AppDimensions.cardRadius(context)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      statusIcon,
                      color: statusColor,
                      size: AppDimensions.iconSmall(context),
                    ),
                    SizedBox(width: AppDimensions.spacingXSmall(context)),
                    Text(
                      statusLabel,
                      style: GoogleFonts.cairo(
                        color: statusColor,
                        fontSize: AppDimensions.fontSmall(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  'طلب #${permission.id}',
                  style: GoogleFonts.cairo(
                    color: _isDark ? AppColors.textSecondary : Colors.black54,
                    fontSize: AppDimensions.fontXSmall(context),
                  ),
                ),
              ],
            ),
          ),

          // Body
          Padding(
            padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
            child: Column(
              crossAxisAlignment: l.isArabic
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                // ← سبب الطلب (نص حر)
                Text(
                  permission.reason,
                  textAlign: l.isArabic ? TextAlign.right : TextAlign.left,
                  style: GoogleFonts.cairo(
                    color: _isDark ? AppColors.textPrimary : Colors.black87,
                    fontSize: AppDimensions.fontMedium(context),
                  ),
                ),
                SizedBox(height: AppDimensions.spacingXSmall(context)),
                Text(
                  '📅 ${permission.requestDate}',
                  style: GoogleFonts.cairo(
                    color: _isDark ? AppColors.textSecondary : Colors.black54,
                    fontSize: AppDimensions.fontXSmall(context),
                  ),
                ),

                // ← سبب الرفض من المشرف
                if (permission.status == 'rejected' &&
                    permission.rejectionReason != null) ...[
                  SizedBox(height: AppDimensions.spacingSmall(context)),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDimensions.spacingSmall(context),
                      vertical: AppDimensions.spacingXSmall(context),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.cardRadius(context) * 0.6,
                      ),
                      border: Border.all(
                        color: Colors.redAccent.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: l.isArabic
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        if (!l.isArabic) ...[
                          Icon(
                            Icons.info_outline,
                            color: Colors.redAccent,
                            size: AppDimensions.iconSmall(context),
                          ),
                          SizedBox(width: AppDimensions.spacingXSmall(context)),
                          Text(
                            l.rejectionReason,
                            style: GoogleFonts.cairo(
                              color: Colors.redAccent,
                              fontSize: AppDimensions.fontXSmall(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: AppDimensions.spacingXSmall(context)),
                        ],
                        Expanded(
                          child: Text(
                            permission.rejectionReason!,
                            textAlign: l.isArabic
                                ? TextAlign.right
                                : TextAlign.left,
                            style: GoogleFonts.cairo(
                              color: Colors.redAccent,
                              fontSize: AppDimensions.fontXSmall(context),
                              height: 1.5,
                            ),
                          ),
                        ),
                        if (l.isArabic) ...[
                          SizedBox(width: AppDimensions.spacingXSmall(context)),
                          Icon(
                            Icons.info_outline,
                            color: Colors.redAccent,
                            size: AppDimensions.iconSmall(context),
                          ),
                          SizedBox(width: AppDimensions.spacingXSmall(context)),
                          Text(
                            l.rejectionReason,
                            style: GoogleFonts.cairo(
                              color: Colors.redAccent,
                              fontSize: AppDimensions.fontXSmall(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
