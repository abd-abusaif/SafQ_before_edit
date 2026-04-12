// features/supervisor/presentation/screens/supervisor_lines_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../data/repositories/supervisor_repository_impl.dart';
import '../../domain/entities/supervisor_entity.dart';
import '../../domain/entities/line_detail_entity.dart';

// ── صفحة الخطوط ──────────────────────────────────────────────────────────────
class SupervisorLinesScreen extends StatefulWidget {
  final String idNumber;
  const SupervisorLinesScreen({super.key, required this.idNumber});

  @override
  State<SupervisorLinesScreen> createState() => _SupervisorLinesScreenState();
}

class _SupervisorLinesScreenState extends State<SupervisorLinesScreen> {
  final _repo = SupervisorRepositoryImpl();
  List<SupervisorLineEntity> _lines = [];
  bool _isLoading = true;
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final lines = await _repo.getMyLines(widget.idNumber);
      setState(() => _lines = lines);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'خطوطي 🚌',
          style: GoogleFonts.cairo(
            color: _isDark ? AppColors.textPrimary : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: AppDimensions.fontLarge(context),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _load,
              child: _lines.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد خطوط مسؤول عنها',
                        style: GoogleFonts.cairo(
                          color: _isDark
                              ? AppColors.textSecondary
                              : Colors.black54,
                          fontSize: AppDimensions.fontMedium(context),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(
                        AppDimensions.spacingMedium(context),
                      ),
                      itemCount: _lines.length,
                      itemBuilder: (_, i) => _buildLineCard(_lines[i], i),
                    ),
            ),
    );
  }

  Widget _buildLineCard(SupervisorLineEntity line, int index) {
    final colors = [
      AppColors.primary,
      const Color(0xFF4FC3F7),
      const Color(0xFF81C784),
      const Color(0xFFBA68C8),
    ];
    final color = colors[index % colors.length];

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => LineDetailScreen(
            idNumber: widget.idNumber,
            lineId: line.id,
            lineName: line.name,
          ),
        ),
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: AppDimensions.spacingSmall(context)),
        padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(
            AppDimensions.cardRadius(context),
          ),
          border: Border.all(color: color.withOpacity(0.35), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.arrow_back_ios_new,
              color: color.withOpacity(0.5),
              size: AppDimensions.iconSmall(context),
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      line.name,
                      style: GoogleFonts.cairo(
                        color: _isDark ? AppColors.textPrimary : Colors.black87,
                        fontSize: AppDimensions.fontMedium(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'الخط رقم ${line.id}',
                      style: GoogleFonts.cairo(
                        color: _isDark
                            ? AppColors.textSecondary
                            : Colors.black54,
                        fontSize: AppDimensions.fontXSmall(context),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: AppDimensions.spacingSmall(context)),
                Container(
                  width: AppDimensions.avatarSmall(context) * 0.8,
                  height: AppDimensions.avatarSmall(context) * 0.8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withOpacity(0.15),
                    border: Border.all(color: color.withOpacity(0.4)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.route_outlined,
                      color: color,
                      size: AppDimensions.iconSmall(context),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── صفحة تفاصيل الخط ─────────────────────────────────────────────────────────
class LineDetailScreen extends StatefulWidget {
  final String idNumber;
  final String lineId;
  final String lineName;

  const LineDetailScreen({
    super.key,
    required this.idNumber,
    required this.lineId,
    required this.lineName,
  });

  @override
  State<LineDetailScreen> createState() => _LineDetailScreenState();
}

class _LineDetailScreenState extends State<LineDetailScreen> {
  final _repo = SupervisorRepositoryImpl();
  LineDetailEntity? _detail;
  bool _isLoading = true;
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    try {
      final d = await _repo.getLineDetail(widget.idNumber, widget.lineId);
      setState(() => _detail = d);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: _isDark ? AppColors.textPrimary : Colors.black87,
        ),
        title: Text(
          widget.lineName,
          style: GoogleFonts.cairo(
            color: _isDark ? AppColors.textPrimary : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: AppDimensions.fontLarge(context),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _load,
              child: ListView(
                padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
                children: [
                  _buildFareCard(),
                  SizedBox(height: AppDimensions.spacingMedium(context)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingSmall(context),
                          vertical: AppDimensions.spacingXSmall(context),
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          '${_detail?.vehicles.length ?? 0} مركبة',
                          style: GoogleFonts.cairo(
                            color: AppColors.primary,
                            fontSize: AppDimensions.fontXSmall(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'المركبات المسجّلة',
                        style: GoogleFonts.cairo(
                          color: _isDark
                              ? AppColors.textPrimary
                              : Colors.black87,
                          fontSize: AppDimensions.fontMedium(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppDimensions.spacingSmall(context)),
                  ...(_detail?.vehicles.map(_buildVehicleCard) ?? []),
                ],
              ),
            ),
    );
  }

  Widget _buildFareCard() {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(color: AppColors.primary.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMedium(context),
              vertical: AppDimensions.spacingSmall(context),
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _detail?.passengerFare ?? '--',
              style: GoogleFonts.cairo(
                color: AppColors.primary,
                fontSize: AppDimensions.fontXLarge(context),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Row(
            children: [
              Text(
                'أجرة الراكب',
                style: GoogleFonts.cairo(
                  color: _isDark ? AppColors.textPrimary : Colors.black87,
                  fontSize: AppDimensions.fontMedium(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: AppDimensions.spacingSmall(context)),
              Icon(
                Icons.monetization_on_outlined,
                color: AppColors.primary,
                size: AppDimensions.iconMedium(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleCard(LineVehicleEntity v) {
    return GestureDetector(
      onTap: () => _showDetails(v),
      child: Container(
        margin: EdgeInsets.only(bottom: AppDimensions.spacingSmall(context)),
        padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(
            AppDimensions.cardRadius(context),
          ),
          border: Border.all(
            color: const Color(0xFF4FC3F7).withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(
              Icons.chevron_left,
              color: const Color(0xFF4FC3F7).withOpacity(0.5),
              size: AppDimensions.iconSmall(context),
            ),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      v.driverName,
                      style: GoogleFonts.cairo(
                        color: _isDark ? AppColors.textPrimary : Colors.black87,
                        fontSize: AppDimensions.fontMedium(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      v.vehiclePlate,
                      style: GoogleFonts.cairo(
                        color: _isDark
                            ? AppColors.textSecondary
                            : Colors.black54,
                        fontSize: AppDimensions.fontXSmall(context),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: AppDimensions.spacingSmall(context)),
                Container(
                  width: AppDimensions.avatarSmall(context) * 0.75,
                  height: AppDimensions.avatarSmall(context) * 0.75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF4FC3F7).withOpacity(0.15),
                    border: Border.all(
                      color: const Color(0xFF4FC3F7).withOpacity(0.4),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.directions_car_outlined,
                      color: const Color(0xFF4FC3F7),
                      size: AppDimensions.iconSmall(context),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(LineVehicleEntity v) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.cardRadius(context) * 1.5),
        ),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.only(
                bottom: AppDimensions.spacingMedium(context),
              ),
              decoration: BoxDecoration(
                color: _isDark ? Colors.white24 : Colors.black26,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              'تفاصيل المركبة',
              style: GoogleFonts.cairo(
                color: _isDark ? AppColors.textPrimary : Colors.black87,
                fontSize: AppDimensions.fontLarge(context),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppDimensions.spacingMedium(context)),
            _detailRow(
              Icons.directions_car_outlined,
              'رقم المركبة',
              v.vehiclePlate,
            ),
            _detailDivider(),
            _detailRow(
              Icons.badge_outlined,
              'رخصة التشغيل',
              v.operatingLicense,
            ),
            _detailDivider(),
            _detailRow(Icons.person_outline, 'اسم السائق', v.driverName),
            _detailDivider(),
            _detailRow(Icons.fingerprint, 'هوية السائق', v.driverIdNumber),
            _detailDivider(),
            _detailRow(Icons.phone_outlined, 'رقم الهاتف', v.driverPhone),
            SizedBox(height: AppDimensions.spacingLarge(context)),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            color: _isDark ? AppColors.textPrimary : Colors.black87,
            fontSize: AppDimensions.fontMedium(context),
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
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
          ],
        ),
      ],
    );
  }

  Widget _detailDivider() =>
      Divider(color: _isDark ? Colors.white12 : Colors.black12, height: 20);
}
