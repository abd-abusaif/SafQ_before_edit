// features/supervisor/presentation/screens/supervisor_external_requests_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/session_manager.dart';
import '../../data/repositories/supervisor_repository_impl.dart';
import '../../domain/entities/external_request_entity.dart';

class SupervisorExternalRequestsScreen extends StatefulWidget {
  const SupervisorExternalRequestsScreen({super.key});

  @override
  State<SupervisorExternalRequestsScreen> createState() =>
      _SupervisorExternalRequestsScreenState();
}

class _SupervisorExternalRequestsScreenState
    extends State<SupervisorExternalRequestsScreen>
    with SingleTickerProviderStateMixin {
  final _repo = SupervisorRepositoryImpl();
  String _idNumber = '';
  bool _isLoading = true;
  List<ExternalRequestEntity> _requests = [];
  late TabController _tabCtrl;

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;
  AppLocalizations get l => AppLocalizations.of(context);

  List<ExternalRequestEntity> get _pending =>
      _requests.where((r) => r.status == 'pending').toList();
  List<ExternalRequestEntity> get _archived =>
      _requests.where((r) => r.status != 'pending').toList();

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final session = await SessionManager.getSession();
      if (session != null) _idNumber = session['idNumber'] ?? '';
      final reqs = await _repo.getExternalRequests(_idNumber);
      if (mounted) setState(() => _requests = reqs);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _approve(ExternalRequestEntity req) async {
    await _repo.approveExternalRequest(req.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l.translate('ext_req_approved_snack'),
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: Colors.green,
      ),
    );
    _loadData();
  }

  Future<void> _reject(ExternalRequestEntity req) async {
    await _repo.rejectExternalRequest(req.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l.translate('ext_req_rejected_snack'),
          style: GoogleFonts.cairo(),
        ),
        backgroundColor: Colors.redAccent,
      ),
    );
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: l.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            l.translate('external_requests_title'),
            style: GoogleFonts.cairo(
              color: _isDark ? AppColors.textPrimary : Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: AppDimensions.fontLarge(context),
            ),
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          bottom: TabBar(
            controller: _tabCtrl,
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: _isDark
                ? AppColors.textSecondary
                : Colors.black54,
            labelStyle: GoogleFonts.cairo(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: l.translate('pending_tab')),
              Tab(text: l.translate('archived_tab')),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _loadData,
                child: TabBarView(
                  controller: _tabCtrl,
                  children: [
                    _buildList(_pending, showActions: true),
                    _buildList(_archived, showActions: false),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildList(
    List<ExternalRequestEntity> items, {
    required bool showActions,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          l.translate('no_external_requests'),
          style: GoogleFonts.cairo(
            color: _isDark ? AppColors.textSecondary : Colors.black54,
            fontSize: AppDimensions.fontMedium(context),
          ),
        ),
      );
    }
    return ListView.builder(
      padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
      itemCount: items.length,
      itemBuilder: (_, i) =>
          _buildRequestCard(items[i], showActions: showActions),
    );
  }

  Widget _buildRequestCard(
    ExternalRequestEntity req, {
    required bool showActions,
  }) {
    final isParcel = req.type == ExternalRequestType.parcel;
    final typeColor = isParcel ? const Color(0xFFFFB74D) : AppColors.primary;
    final typeIcon = isParcel
        ? Icons.inventory_2_outlined
        : Icons.people_outline;
    final typeLabel = isParcel
        ? l.translate('ext_type_parcel')
        : l.translate('ext_type_passengers');

    Color statusColor;
    String statusLabel;
    switch (req.status) {
      case 'approved':
        statusColor = Colors.green;
        statusLabel = l.translate('approved_status');
        break;
      case 'rejected':
        statusColor = Colors.redAccent;
        statusLabel = l.translate('rejected_status');
        break;
      default:
        statusColor = Colors.orange;
        statusLabel = l.translate('pending_status');
    }

    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacingSmall(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(color: typeColor.withOpacity(0.35), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── رأس البطاقة: النوع + الحالة ───────────────
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMedium(context),
              vertical: AppDimensions.spacingSmall(context),
            ),
            decoration: BoxDecoration(
              color: typeColor.withOpacity(0.08),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppDimensions.cardRadius(context)),
                topRight: Radius.circular(AppDimensions.cardRadius(context)),
              ),
            ),
            child: Row(
              textDirection: TextDirection.ltr,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // النوع — يسار
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      typeIcon,
                      color: typeColor,
                      size: AppDimensions.iconSmall(context),
                    ),
                    SizedBox(width: AppDimensions.spacingXSmall(context)),
                    Text(
                      typeLabel,
                      style: GoogleFonts.cairo(
                        color: typeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: AppDimensions.fontSmall(context),
                      ),
                    ),
                  ],
                ),
                // الحالة — يمين
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingSmall(context),
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: statusColor.withOpacity(0.4),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    statusLabel,
                    style: GoogleFonts.cairo(
                      color: statusColor,
                      fontSize: AppDimensions.fontXSmall(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── محتوى البطاقة ─────────────────────────────
          Padding(
            padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // الاسم + الهاتف
                _infoRow(
                  Icons.person_outline,
                  l.translate('requester_name'),
                  req.requesterName,
                  AppColors.primary,
                ),
                SizedBox(height: AppDimensions.spacingXSmall(context)),
                _infoRow(
                  Icons.phone_outlined,
                  l.translate('requester_phone'),
                  req.requesterPhone,
                  AppColors.primary,
                  isLtr: true,
                ),

                Divider(
                  color: _isDark ? Colors.white12 : Colors.black12,
                  height: AppDimensions.spacingMedium(context) * 2,
                ),

                // تفاصيل النوع
                if (isParcel) ...[
                  _infoRow(
                    Icons.inventory_2_outlined,
                    l.translate('parcel_name'),
                    req.parcelName ?? '-',
                    typeColor,
                  ),
                ] else ...[
                  _infoRow(
                    Icons.people_outline,
                    l.translate('passenger_count'),
                    '${req.passengersCount ?? 0} ${l.translate("passengers_unit")}',
                    typeColor,
                  ),
                ],

                // الوجهة
                SizedBox(height: AppDimensions.spacingXSmall(context)),
                _infoRow(
                  Icons.location_on_outlined,
                  l.translate('requester_location'),
                  req.location,
                  const Color(0xFF81C784),
                ),
                SizedBox(height: AppDimensions.spacingXSmall(context)),
                _infoRow(
                  Icons.flag_outlined,
                  l.translate('destination_label'),
                  req.destination,
                  const Color(0xFF81C784),
                ),

                // تفاصيل إضافية
                if (req.parcelDetails != null &&
                    req.parcelDetails!.isNotEmpty) ...[
                  SizedBox(height: AppDimensions.spacingXSmall(context)),
                  _infoRow(
                    Icons.notes_outlined,
                    l.translate('parcel_details_label'),
                    req.parcelDetails!,
                    Colors.grey,
                  ),
                ],

                // أزرار القبول/الرفض
                if (showActions) ...[
                  SizedBox(height: AppDimensions.spacingMedium(context)),
                  Row(
                    textDirection: TextDirection.ltr,
                    children: [
                      // رفض
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _reject(req),
                          icon: Icon(
                            Icons.close,
                            color: Colors.redAccent,
                            size: AppDimensions.iconSmall(context),
                          ),
                          label: Text(
                            l.translate('reject_btn'),
                            style: GoogleFonts.cairo(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                              fontSize: AppDimensions.fontSmall(context),
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.redAccent),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.cardRadius(context),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppDimensions.spacingSmall(context)),
                      // قبول
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _approve(req),
                          icon: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: AppDimensions.iconSmall(context),
                          ),
                          label: Text(
                            l.translate('approve_btn'),
                            style: GoogleFonts.cairo(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: AppDimensions.fontSmall(context),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppDimensions.cardRadius(context),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(
    IconData icon,
    String label,
    String value,
    Color iconColor, {
    bool isLtr = false,
  }) {
    final valueWidget = isLtr
        ? Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              value,
              style: GoogleFonts.cairo(
                color: _isDark ? AppColors.textPrimary : Colors.black87,
                fontSize: AppDimensions.fontSmall(context),
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        : Text(
            value,
            style: GoogleFonts.cairo(
              color: _isDark ? AppColors.textPrimary : Colors.black87,
              fontSize: AppDimensions.fontSmall(context),
              fontWeight: FontWeight.w600,
            ),
          );

    final labelWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: iconColor, size: AppDimensions.iconSmall(context)),
        SizedBox(width: AppDimensions.spacingXSmall(context)),
        Text(
          label,
          style: GoogleFonts.cairo(
            color: _isDark ? AppColors.textSecondary : Colors.black54,
            fontSize: AppDimensions.fontXSmall(context),
          ),
        ),
      ],
    );

    return Row(
      textDirection: TextDirection.ltr,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: l.isArabic
          ? [valueWidget, labelWidget]
          : [labelWidget, valueWidget],
    );
  }
}
