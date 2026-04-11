import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../data/repositories/supervisor_repository_impl.dart';
import '../widgets/vehicle_item_widget.dart';
import '../../domain/entities/supervisor_stats_entity.dart';
import '../../domain/entities/supervisor_vehicle_entity.dart';

class SupervisorHomeScreen extends StatefulWidget {
  final String supervisorName;
  final String idNumber;

  const SupervisorHomeScreen({
    super.key,
    required this.supervisorName,
    required this.idNumber,
  });

  @override
  State<SupervisorHomeScreen> createState() => _SupervisorHomeScreenState();
}

class _SupervisorHomeScreenState extends State<SupervisorHomeScreen> {
  final _repo = SupervisorRepositoryImpl();

  List<String> _lines = [];
  String? _selectedLine;
  SupervisorStatsEntity? _stats;
  List<SupervisorVehicleEntity> _vehicles = [];
  bool _isLoading = true;

  String get _firstName => widget.supervisorName.trim().split(' ').first;
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _loadLines();
  }

  Future<void> _loadLines() async {
    setState(() => _isLoading = true);
    try {
      final lines = await _repo.getMyLines(widget.idNumber);
      setState(() {
        _lines = lines;
        _selectedLine = lines.isNotEmpty ? lines.first : null;
      });
      if (_selectedLine != null) await _loadData();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadData() async {
    if (_selectedLine == null) return;
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _repo.getStats(widget.idNumber, _selectedLine!),
        _repo.getVehicles(widget.idNumber, _selectedLine!),
      ]);
      setState(() {
        _stats = results[0] as SupervisorStatsEntity;
        _vehicles = results[1] as List<SupervisorVehicleEntity>;
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
                    SliverToBoxAdapter(child: _buildStats()),
                    SliverToBoxAdapter(child: _buildLineSelector()),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          AppDimensions.spacingMedium(context),
                          AppDimensions.spacingMedium(context),
                          AppDimensions.spacingMedium(context),
                          AppDimensions.spacingSmall(context),
                        ),
                        child: Text(
                          'إدارة الدور',
                          textAlign: TextAlign.right,
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
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingMedium(context),
                      ),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              VehicleItemWidget(vehicle: _vehicles[index]),
                          childCount: _vehicles.length,
                        ),
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
                _getInitials(widget.supervisorName),
                style: GoogleFonts.cairo(
                  color: AppColors.primary,
                  fontSize: AppDimensions.fontMedium(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Text(
            'أهلاً $_firstName',
            textAlign: TextAlign.right,
            style: GoogleFonts.cairo(
              color: _isDark ? AppColors.textPrimary : Colors.black87,
              fontSize: AppDimensions.fontLarge(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
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
                _buildStatLabel('السيارات\nالنشطة'),
                _buildStatDivider(),
                _buildStatLabel('في\nالانتظار'),
                _buildStatDivider(),
                _buildStatLabel('الرحلات\nالمكتملة'),
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
                _buildStatValue('${_stats?.activeVehicles ?? 0}', Colors.green),
                _buildStatDivider(),
                _buildStatValue(
                  '${_stats?.waitingVehicles ?? 0}',
                  Colors.orange,
                ),
                _buildStatDivider(),
                _buildStatValue(
                  '${_stats?.completedTrips ?? 0}',
                  AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLineSelector() {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingMedium(context),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedLine,
        dropdownColor: Theme.of(context).colorScheme.surface,
        iconEnabledColor: AppColors.primary,
        style: GoogleFonts.cairo(
          color: _isDark ? AppColors.textPrimary : Colors.black87,
          fontSize: AppDimensions.fontMedium(context),
        ),
        decoration: const InputDecoration(
          prefixIcon: Icon(Icons.route_outlined, color: AppColors.primary),
        ),
        items: _lines.map((line) {
          return DropdownMenuItem(
            value: line,
            child: Text(line, textAlign: TextAlign.right),
          );
        }).toList(),
        onChanged: (v) {
          setState(() => _selectedLine = v);
          _loadData();
        },
      ),
    );
  }

  Widget _buildStatLabel(String text) {
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

  Widget _buildStatValue(String text, Color color) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(
          color: color,
          fontSize: AppDimensions.fontXLarge(context),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 0.5,
      height: AppDimensions.spacingXLarge(context),
      color: _isDark ? Colors.white12 : Colors.black12,
    );
  }
}
