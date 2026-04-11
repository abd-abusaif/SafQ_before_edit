import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/utils/session_manager.dart';
import '../../data/repositories/violation_repository_impl.dart';
import '../../domain/entities/violation_entity.dart';

class ViolationsScreen extends StatefulWidget {
  const ViolationsScreen({super.key});

  @override
  State<ViolationsScreen> createState() => _ViolationsScreenState();
}

class _ViolationsScreenState extends State<ViolationsScreen> {
  final _repo = ViolationRepositoryImpl();

  List<ViolationEntity> _violations = [];
  bool _isLoading = true;
  String _idNumber = '';

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
      final violations = await _repo.getMyViolations(_idNumber);
      setState(() => _violations = violations);
    } catch (e) {
      setState(() => _violations = []);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  double get _totalAmount => _violations.fold(0.0, (sum, v) => sum + v.amount);
  bool get _hasBlockEntry => _violations.any((v) => v.blockEntry);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text(
          l.violationsTitle,
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
                  crossAxisAlignment: l.isArabic
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    if (_hasBlockEntry) _buildBlockWarning(),
                    if (_hasBlockEntry)
                      SizedBox(height: AppDimensions.spacingMedium(context)),
                    if (_violations.isNotEmpty) _buildTotalCard(),
                    if (_violations.isNotEmpty)
                      SizedBox(height: AppDimensions.spacingMedium(context)),
                    if (_violations.isEmpty)
                      _buildEmptyState()
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _violations.length,
                        itemBuilder: (context, index) =>
                            _buildViolationCard(_violations[index]),
                      ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBlockWarning() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
      decoration: BoxDecoration(
        color: Colors.redAccent.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(color: Colors.redAccent, width: 1.5),
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
              l.blockEntryWarn,
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

  Widget _buildTotalCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLarge(context),
        vertical: AppDimensions.spacingMedium(context),
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(color: AppColors.primary.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (!l.isArabic)
            Text(
              '${_totalAmount.toStringAsFixed(2)} ₪',
              style: GoogleFonts.cairo(
                color: Colors.redAccent,
                fontSize: AppDimensions.fontLarge(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          Row(
            children: [
              if (l.isArabic) ...[
                Text(
                  l.totalViolations,
                  style: GoogleFonts.cairo(
                    color: _isDark ? AppColors.textSecondary : Colors.black54,
                    fontSize: AppDimensions.fontSmall(context),
                  ),
                ),
                SizedBox(width: AppDimensions.spacingSmall(context)),
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.primary,
                  size: AppDimensions.iconSmall(context),
                ),
              ] else ...[
                Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppColors.primary,
                  size: AppDimensions.iconSmall(context),
                ),
                SizedBox(width: AppDimensions.spacingSmall(context)),
                Text(
                  l.totalViolations,
                  style: GoogleFonts.cairo(
                    color: _isDark ? AppColors.textSecondary : Colors.black54,
                    fontSize: AppDimensions.fontSmall(context),
                  ),
                ),
              ],
            ],
          ),
          if (l.isArabic)
            Text(
              '${_totalAmount.toStringAsFixed(2)} ₪',
              style: GoogleFonts.cairo(
                color: Colors.redAccent,
                fontSize: AppDimensions.fontLarge(context),
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppDimensions.spacingXLarge(context)),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: Colors.green,
              size: AppDimensions.iconXLarge(context) * 1.5,
            ),
            SizedBox(height: AppDimensions.spacingMedium(context)),
            Text(
              l.noViolations,
              style: GoogleFonts.cairo(
                color: Colors.green,
                fontSize: AppDimensions.fontLarge(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppDimensions.spacingSmall(context)),
            Text(
              l.cleanRecord,
              style: GoogleFonts.cairo(
                color: _isDark ? AppColors.textSecondary : Colors.black54,
                fontSize: AppDimensions.fontSmall(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViolationCard(ViolationEntity violation) {
    final borderColor = violation.blockEntry ? Colors.redAccent : Colors.orange;

    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacingSmall(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(color: borderColor.withOpacity(0.4), width: 1),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMedium(context),
              vertical: AppDimensions.spacingSmall(context),
            ),
            decoration: BoxDecoration(
              color: borderColor.withOpacity(0.08),
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
                      violation.blockEntry
                          ? Icons.block
                          : Icons.warning_amber_rounded,
                      color: borderColor,
                      size: AppDimensions.iconSmall(context),
                    ),
                    SizedBox(width: AppDimensions.spacingXSmall(context)),
                    Text(
                      violation.blockEntry ? l.withBlock : l.withoutBlock,
                      style: GoogleFonts.cairo(
                        color: borderColor,
                        fontSize: AppDimensions.fontXSmall(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  violation.violationNumber,
                  style: GoogleFonts.cairo(
                    color: _isDark ? AppColors.textPrimary : Colors.black87,
                    fontSize: AppDimensions.fontSmall(context),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
            child: Column(
              children: [
                _buildDetailRow(
                  Icons.description_outlined,
                  l.violationType,
                  violation.type,
                ),
                Divider(
                  color: _isDark ? Colors.white38 : Colors.black12,
                  height: 12,
                ),
                _buildDetailRow(
                  Icons.attach_money,
                  l.amount,
                  '${violation.amount.toStringAsFixed(2)} ₪',
                  valueColor: Colors.redAccent,
                ),
                Divider(
                  color: _isDark ? Colors.white38 : Colors.black12,
                  height: 12,
                ),
                _buildDetailRow(Icons.calendar_today, l.date, violation.date),
                if (violation.notes != null) ...[
                  Divider(
                    color: _isDark ? Colors.white38 : Colors.black12,
                    height: 12,
                  ),
                  _buildDetailRow(Icons.notes, l.notes, violation.notes!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // ← القيمة
        Text(
          value,
          style: GoogleFonts.cairo(
            color:
                valueColor ??
                (_isDark ? AppColors.textPrimary : Colors.black87),
            fontSize: AppDimensions.fontSmall(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        // ← الـ Label
        Row(
          children: [
            if (l.isArabic) ...[
              Text(
                label,
                style: GoogleFonts.cairo(
                  color: _isDark ? AppColors.textSecondary : Colors.black54,
                  fontSize: AppDimensions.fontXSmall(context),
                ),
              ),
              SizedBox(width: AppDimensions.spacingXSmall(context)),
              Icon(
                icon,
                color: AppColors.primary.withOpacity(0.7),
                size: AppDimensions.iconSmall(context),
              ),
            ] else ...[
              Icon(
                icon,
                color: AppColors.primary.withOpacity(0.7),
                size: AppDimensions.iconSmall(context),
              ),
              SizedBox(width: AppDimensions.spacingXSmall(context)),
              Text(
                label,
                style: GoogleFonts.cairo(
                  color: _isDark ? AppColors.textSecondary : Colors.black54,
                  fontSize: AppDimensions.fontXSmall(context),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
