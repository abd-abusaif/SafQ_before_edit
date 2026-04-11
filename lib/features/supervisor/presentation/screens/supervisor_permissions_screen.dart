import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/session_manager.dart';
import '../../../driver/data/repositories/permission_repository_impl.dart';
import '../../../driver/domain/entities/permission_entity.dart';

class SupervisorPermissionsScreen extends StatefulWidget {
  const SupervisorPermissionsScreen({super.key});

  @override
  State<SupervisorPermissionsScreen> createState() =>
      _SupervisorPermissionsScreenState();
}

class _SupervisorPermissionsScreenState
    extends State<SupervisorPermissionsScreen> {
  final _repo = PermissionRepositoryImpl();
  List<PermissionEntity> _permissions = [];
  bool _isLoading = true;
  String _idNumber = '';

  bool get _isDark => Theme.of(context).brightness == Brightness.dark;

  final Map<String, String> _types = {
    'maintenance': 'صيانة المركبة',
    'parcel': 'استلام طرد',
    'other': 'أخرى',
  };

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
      final all = await _repo.getMyPermissions(_idNumber);
      setState(() {
        _permissions = all.where((p) => p.status == 'approved').toList();
      });
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
        title: Text(
          'الأذونات الموافق عليها',
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
              child: _permissions.isEmpty
                  ? Center(
                      child: Text(
                        'لا توجد أذونات موافق عليها',
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
                      itemCount: _permissions.length,
                      itemBuilder: (context, index) {
                        return _buildPermissionCard(_permissions[index]);
                      },
                    ),
            ),
    );
  }

  Widget _buildPermissionCard(PermissionEntity p) {
    return Container(
      margin: EdgeInsets.only(bottom: AppDimensions.spacingSmall(context)),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius(context)),
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingMedium(context),
              vertical: AppDimensions.spacingSmall(context),
            ),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
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
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: AppDimensions.iconSmall(context),
                    ),
                    SizedBox(width: AppDimensions.spacingXSmall(context)),
                    Text(
                      'موافق عليه',
                      style: GoogleFonts.cairo(
                        color: Colors.green,
                        fontSize: AppDimensions.fontXSmall(context),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Text(
                  _types[p.type] ?? p.type,
                  style: GoogleFonts.cairo(
                    color: _isDark ? AppColors.textPrimary : Colors.black87,
                    fontSize: AppDimensions.fontMedium(context),
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
                  Icons.directions_car_outlined,
                  'رقم المركبة',
                  p.vehiclePlate ?? 'غير محدد',
                ),
                Divider(
                  color: _isDark ? Colors.white38 : Colors.black12,
                  height: 12,
                ),
                _buildDetailRow(Icons.calendar_today, 'التاريخ', p.requestDate),
                Divider(
                  color: _isDark ? Colors.white38 : Colors.black12,
                  height: 12,
                ),
                _buildDetailRow(Icons.timer_outlined, 'المدة', p.duration),
                if (p.reason != null) ...[
                  Divider(
                    color: _isDark ? Colors.white38 : Colors.black12,
                    height: 12,
                  ),
                  _buildDetailRow(Icons.edit_note, 'السبب', p.reason!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          value,
          style: GoogleFonts.cairo(
            color: _isDark ? AppColors.textPrimary : Colors.black87,
            fontSize: AppDimensions.fontSmall(context),
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
              color: Colors.green.withOpacity(0.7),
              size: AppDimensions.iconSmall(context),
            ),
          ],
        ),
      ],
    );
  }
}
