import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../data/repositories/driver_repository_impl.dart';
import '../../domain/entities/queue_entry_entity.dart';
import '../widgets/queue_item_widget.dart';

class DriverHomeScreen extends StatefulWidget {
  final String driverName;
  final String idNumber;
  final String lineFrom;
  final String lineTo;

  const DriverHomeScreen({
    super.key,
    required this.driverName,
    required this.idNumber,
    required this.lineFrom,
    required this.lineTo,
  });

  @override
  State<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  final DriverRepositoryImpl _repo = DriverRepositoryImpl();

  List<QueueEntryEntity> _queueList = [];
  QueueEntryEntity? _myEntry;
  bool _isLoading = true;
  bool _isRegistered = true;
  String _rejectionReason = '';
  bool _hasBlockViolation = false;

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
      final allList = await _repo.getQueueList();
      final filteredList = allList
          .where(
            (e) => e.lineFrom == widget.lineFrom && e.lineTo == widget.lineTo,
          )
          .toList();
      final myEntry = await _repo.getMyQueueEntry(widget.idNumber);

      setState(() {
        _hasBlockViolation = false;
        _isRegistered = true;
        _rejectionReason = '';
        _queueList = _isRegistered ? filteredList : [];
        _myEntry = _isRegistered ? myEntry : null;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts.first[0]}${parts.last[0]}';
    return parts.first[0];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _loadData,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader()),
                    if (_hasBlockViolation)
                      SliverToBoxAdapter(child: _buildViolationWarning()),
                    if (_isRegistered)
                      SliverToBoxAdapter(child: _buildInfoCard()),
                    if (!_isRegistered)
                      SliverToBoxAdapter(child: _buildRejectedCard()),
                    if (_isRegistered)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            AppDimensions.spacingMedium(context),
                            AppDimensions.spacingLarge(context),
                            AppDimensions.spacingMedium(context),
                            AppDimensions.spacingSmall(context),
                          ),
                          child: Text(
                            l.queueStatus,
                            textAlign: l.isArabic
                                ? TextAlign.right
                                : TextAlign.left,
                            style: GoogleFonts.cairo(
                              color: _isDark
                                  ? AppColors.textPrimary
                                  : Colors.black87,
                              fontSize: AppDimensions.fontLarge(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (_isRegistered)
                      SliverPadding(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingMedium(context),
                        ),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            final entry = _queueList[index];
                            return QueueItemWidget(
                              entry: entry,
                              isCurrentDriver:
                                  entry.queuePosition ==
                                  _myEntry?.queuePosition,
                            );
                          }, childCount: _queueList.length),
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 20)),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    final avatarSize = AppDimensions.avatarSmall(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppDimensions.spacingMedium(context),
        AppDimensions.spacingMedium(context),
        AppDimensions.spacingMedium(context),
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ← في العربي: الأفاتار يسار، في الإنجليزي: يمين
          if (!l.isArabic)
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.2),
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: Center(
                child: Text(
                  _getInitials(widget.driverName),
                  style: GoogleFonts.cairo(
                    color: AppColors.primary,
                    fontSize: AppDimensions.fontMedium(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          Text(
            '${l.welcomeUser} ${widget.driverName}',
            textAlign: l.isArabic ? TextAlign.right : TextAlign.left,
            style: GoogleFonts.cairo(
              color: _isDark ? AppColors.textPrimary : Colors.black87,
              fontSize: AppDimensions.fontLarge(context),
              fontWeight: FontWeight.bold,
            ),
          ),

          if (l.isArabic)
            Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.2),
                border: Border.all(color: AppColors.primary, width: 1.5),
              ),
              child: Center(
                child: Text(
                  _getInitials(widget.driverName),
                  style: GoogleFonts.cairo(
                    color: AppColors.primary,
                    fontSize: AppDimensions.fontMedium(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildViolationWarning() {
    return Container(
      margin: EdgeInsets.fromLTRB(
        AppDimensions.spacingMedium(context),
        AppDimensions.spacingMedium(context),
        AppDimensions.spacingMedium(context),
        0,
      ),
      padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(color: Colors.redAccent, width: 1),
      ),
      child: Row(
        mainAxisAlignment: l.isArabic
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!l.isArabic) ...[
            Icon(
              Icons.block,
              color: Colors.redAccent,
              size: AppDimensions.iconLarge(context),
            ),
            SizedBox(width: AppDimensions.spacingSmall(context)),
          ],
          Expanded(
            child: Text(
              l.violationBlockWarn,
              textAlign: l.isArabic ? TextAlign.right : TextAlign.left,
              style: GoogleFonts.cairo(
                color: Colors.redAccent,
                fontSize: AppDimensions.fontSmall(context),
                height: 1.6,
              ),
            ),
          ),
          if (l.isArabic) ...[
            SizedBox(width: AppDimensions.spacingSmall(context)),
            Icon(
              Icons.block,
              color: Colors.redAccent,
              size: AppDimensions.iconLarge(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      margin: EdgeInsets.all(AppDimensions.spacingMedium(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.spacingMedium(context),
              AppDimensions.spacingMedium(context),
              AppDimensions.spacingMedium(context),
              AppDimensions.spacingSmall(context),
            ),
            child: Row(
              children: [
                _buildCardLabel(l.queueNumber),
                _buildDividerVertical(),
                _buildCardLabel(l.queueTime),
                _buildDividerVertical(),
                _buildCardLabel(l.queueReg),
              ],
            ),
          ),
          Divider(color: _isDark ? Colors.white12 : Colors.black12, height: 1),
          Padding(
            padding: EdgeInsets.fromLTRB(
              AppDimensions.spacingMedium(context),
              AppDimensions.spacingSmall(context),
              AppDimensions.spacingMedium(context),
              AppDimensions.spacingMedium(context),
            ),
            child: Row(
              children: [
                _buildCardValue('${_myEntry?.queuePosition ?? '-'}'),
                _buildDividerVertical(),
                _buildCardValue(
                  '${_myEntry?.entryTime ?? '-'} –\n${_myEntry?.exitTime ?? '-'}',
                  isSmall: true,
                ),
                _buildDividerVertical(),
                _buildCardValue('${_myEntry?.registrationNumber ?? '-'}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRejectedCard() {
    return Container(
      margin: EdgeInsets.all(AppDimensions.spacingMedium(context)),
      padding: EdgeInsets.all(AppDimensions.spacingLarge(context)),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(color: Colors.redAccent, width: 1),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cancel_outlined,
            color: Colors.redAccent,
            size: AppDimensions.iconXLarge(context),
          ),
          SizedBox(height: AppDimensions.spacingSmall(context)),
          Text(
            l.rejectedQueue,
            style: GoogleFonts.cairo(
              color: Colors.redAccent,
              fontSize: AppDimensions.fontLarge(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppDimensions.spacingSmall(context)),
          Text(
            _rejectionReason.isNotEmpty ? _rejectionReason : l.rejectedMsg,
            textAlign: TextAlign.center,
            style: GoogleFonts.cairo(
              color: _isDark ? AppColors.textSecondary : Colors.black54,
              fontSize: AppDimensions.fontMedium(context),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardLabel(String text) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(
          color: _isDark ? AppColors.textSecondary : Colors.black54,
          fontSize: AppDimensions.fontXSmall(context),
        ),
      ),
    );
  }

  Widget _buildCardValue(String text, {bool isSmall = false}) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(
          color: _isDark ? AppColors.textPrimary : Colors.black87,
          fontSize: isSmall
              ? AppDimensions.fontSmall(context)
              : AppDimensions.fontXLarge(context),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDividerVertical() {
    return Container(
      width: 0.5,
      height: AppDimensions.spacingXLarge(context),
      color: _isDark ? Colors.white12 : Colors.black12,
    );
  }
}
