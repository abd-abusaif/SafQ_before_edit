// features/supervisor/presentation/screens/supervisor_home_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../data/repositories/supervisor_repository_impl.dart';
import '../../domain/entities/supervisor_entity.dart';
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
  final _searchCtrl = TextEditingController();

  List<SupervisorLineEntity> _lines = [];
  SupervisorLineEntity? _selectedLine;
  int _totalActiveVehicles = 0;
  List<Map<String, dynamic>> _linesTable = [];
  List<SupervisorVehicleEntity> _queueVehicles = [];
  bool _isLoading = true;

  String get _firstName => widget.supervisorName.trim().split(' ').first;
  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  List<SupervisorLineEntity> get _filteredLines {
    final q = _searchCtrl.text.trim().toLowerCase();
    if (q.isEmpty) return _lines;
    return _lines
        .where((l) =>
            l.name.toLowerCase().contains(q) ||
            l.id.toLowerCase().contains(q))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _repo.getMyLines(widget.idNumber),
        _repo.getTotalActiveVehicles(widget.idNumber),
        _repo.getLinesTable(widget.idNumber),
      ]);
      final lines = results[0] as List<SupervisorLineEntity>;
      setState(() {
        _lines = lines;
        _selectedLine = lines.isNotEmpty ? lines.first : null;
        _totalActiveVehicles = results[1] as int;
        _linesTable = results[2] as List<Map<String, dynamic>>;
      });
      if (_selectedLine != null) await _loadQueue();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadQueue() async {
    if (_selectedLine == null) return;
    final vehicles = await _repo.getQueueVehicles(
        widget.idNumber, _selectedLine!.id);
    if (mounted) setState(() => _queueVehicles = vehicles);
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
                child: CircularProgressIndicator(color: AppColors.primary))
            : RefreshIndicator(
                color: AppColors.primary,
                onRefresh: _loadAll,
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildHeader()),
                    SliverToBoxAdapter(child: _buildActiveVehiclesCard()),
                    SliverToBoxAdapter(child: _buildLinesTable()),
                    SliverToBoxAdapter(child: _buildQueueSection()),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              ),
      ),
    );
  }

  // ── الهيدر ───────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    final size = AppDimensions.avatarSmall(context);
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
            width: size,
            height: size,
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

  // ── بطاقة المركبات النشطة ────────────────────────────────────────────────
  Widget _buildActiveVehiclesCard() {
    return Container(
      margin: EdgeInsets.all(AppDimensions.spacingMedium(context)),
      padding: EdgeInsets.symmetric(
        horizontal: AppDimensions.spacingLarge(context),
        vertical: AppDimensions.spacingMedium(context),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.85),
            AppColors.primary.withOpacity(0.6),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: EdgeInsets.all(AppDimensions.spacingSmall(context)),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.directions_car_rounded,
              color: Colors.white,
              size: AppDimensions.iconLarge(context),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'المركبات النشطة في المجمع',
                style: GoogleFonts.cairo(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: AppDimensions.fontSmall(context),
                ),
              ),
              Text(
                '$_totalActiveVehicles',
                style: GoogleFonts.cairo(
                  color: Colors.white,
                  fontSize: AppDimensions.fontTitle(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── جدول الخطوط ──────────────────────────────────────────────────────────
  Widget _buildLinesTable() {
    return Container(
      margin: EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMedium(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // رأس الجدول
          Container(
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
              children: [
                _tableHeader('السيارات', flex: 2),
                _tableHeader('اسم الخط', flex: 4),
                _tableHeader('رقم الخط', flex: 2),
              ],
            ),
          ),
          ..._linesTable.asMap().entries.map((e) {
            final item = e.value;
            final isLast = e.key == _linesTable.length - 1;
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppDimensions.spacingMedium(context),
                    vertical: AppDimensions.spacingSmall(context),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: AppDimensions.spacingXSmall(context)),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${item['vehicle_count']}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.cairo(
                              color: Colors.green,
                              fontSize: AppDimensions.fontMedium(context),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          '${item['line_name']}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            color: _isDark
                                ? AppColors.textPrimary
                                : Colors.black87,
                            fontSize: AppDimensions.fontSmall(context),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '${item['line_number']}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.cairo(
                            color: _isDark
                                ? AppColors.textSecondary
                                : Colors.black54,
                            fontSize: AppDimensions.fontSmall(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(
                      height: 1,
                      color: _isDark ? Colors.white12 : Colors.black12),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _tableHeader(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: GoogleFonts.cairo(
          color: AppColors.primary,
          fontSize: AppDimensions.fontSmall(context),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ── قسم الدور ────────────────────────────────────────────────────────────
  Widget _buildQueueSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
            AppDimensions.spacingMedium(context),
            AppDimensions.spacingLarge(context),
            AppDimensions.spacingMedium(context),
            AppDimensions.spacingSmall(context),
          ),
          child: Text(
            'إدارة الدور',
            style: GoogleFonts.cairo(
              color: _isDark ? AppColors.textPrimary : Colors.black87,
              fontSize: AppDimensions.fontLarge(context),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMedium(context)),
          child: Column(
            children: [
              // حقل البحث
              TextField(
                controller: _searchCtrl,
                onChanged: (_) => setState(() {}),
                textAlign: TextAlign.right,
                style: GoogleFonts.cairo(
                  color: _isDark ? AppColors.textPrimary : Colors.black87,
                  fontSize: AppDimensions.fontMedium(context),
                ),
                decoration: InputDecoration(
                  hintText: 'ابحث برقم أو اسم الخط...',
                  hintStyle: GoogleFonts.cairo(
                    color: _isDark ? AppColors.textSecondary : Colors.black38,
                    fontSize: AppDimensions.fontSmall(context),
                  ),
                  prefixIcon:
                      const Icon(Icons.search, color: AppColors.primary),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: AppColors.primary),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
              ),
              SizedBox(height: AppDimensions.spacingSmall(context)),
              // القائمة المنسدلة
              if (_filteredLines.isNotEmpty)
                DropdownButtonFormField<String>(
                  value: _selectedLine?.id,
                  dropdownColor: Theme.of(context).colorScheme.surface,
                  iconEnabledColor: AppColors.primary,
                  style: GoogleFonts.cairo(
                    color: _isDark ? AppColors.textPrimary : Colors.black87,
                    fontSize: AppDimensions.fontMedium(context),
                  ),
                  decoration: const InputDecoration(
                    prefixIcon:
                        Icon(Icons.route_outlined, color: AppColors.primary),
                  ),
                  items: _filteredLines
                      .map((l) => DropdownMenuItem(
                            value: l.id,
                            child:
                                Text(l.name, textAlign: TextAlign.right),
                          ))
                      .toList(),
                  onChanged: (v) {
                    final found = _lines.firstWhere((l) => l.id == v,
                        orElse: () => _lines.first);
                    setState(() => _selectedLine = found);
                    _loadQueue();
                  },
                ),
            ],
          ),
        ),
        SizedBox(height: AppDimensions.spacingMedium(context)),
        // قائمة الدور
        if (_queueVehicles.isEmpty)
          Padding(
            padding: EdgeInsets.all(AppDimensions.spacingLarge(context)),
            child: Center(
              child: Text(
                'لا توجد مركبات في الدور',
                style: GoogleFonts.cairo(
                  color:
                      _isDark ? AppColors.textSecondary : Colors.black54,
                  fontSize: AppDimensions.fontMedium(context),
                ),
              ),
            ),
          )
        else
          ...(_queueVehicles.map((v) => Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMedium(context),
                  vertical: AppDimensions.spacingXSmall(context),
                ),
                child: _buildQueueItem(v),
              ))),
      ],
    );
  }

  Widget _buildQueueItem(SupervisorVehicleEntity v) {
    return Container(
      padding: EdgeInsets.all(AppDimensions.spacingMedium(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border:
            Border.all(color: AppColors.primary.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // رقم الدور
          Container(
            width: AppDimensions.avatarSmall(context) * 0.75,
            height: AppDimensions.avatarSmall(context) * 0.75,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.15),
              border:
                  Border.all(color: AppColors.primary.withOpacity(0.5)),
            ),
            child: Center(
              child: Text(
                '#${v.queuePosition}',
                style: GoogleFonts.cairo(
                  color: AppColors.primary,
                  fontSize: AppDimensions.fontXSmall(context),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // معلومات السائق
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
              SizedBox(height: AppDimensions.spacingXSmall(context)),
              Row(
                children: [
                  Text(
                    v.entryTime,
                    style: GoogleFonts.cairo(
                      color: _isDark
                          ? AppColors.textSecondary
                          : Colors.black54,
                      fontSize: AppDimensions.fontXSmall(context),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppDimensions.spacingSmall(context)),
                    child: Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _isDark
                                ? Colors.white38
                                : Colors.black38)),
                  ),
                  Text(
                    v.vehiclePlate,
                    style: GoogleFonts.cairo(
                      color: _isDark
                          ? AppColors.textSecondary
                          : Colors.black54,
                      fontSize: AppDimensions.fontXSmall(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
