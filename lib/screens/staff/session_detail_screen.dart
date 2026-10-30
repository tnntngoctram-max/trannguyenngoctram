import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../services/attendance_service.dart';
import '../../utils/constants.dart';

/// Quản lý chi tiết phiên điểm danh (Làm mới QR, Đóng phiên, Xem danh sách sinh viên)
class SessionDetailScreen extends StatefulWidget {
  final int sessionId;
  final int classSessionId;
  final bool isOpenInitial;
  final String? qrCodeInitial;

  const SessionDetailScreen({
    super.key,
    required this.sessionId,
    required this.classSessionId,
    required this.isOpenInitial,
    this.qrCodeInitial,
  });

  @override
  State<SessionDetailScreen> createState() => _SessionDetailScreenState();
}

class _SessionDetailScreenState extends State<SessionDetailScreen> {
  final AttendanceService _attendanceService = AttendanceService();
  late bool _isOpen;
  String? _qrCode;
  List<dynamic> _checkedInStudents = [];
  bool _isLoadingRecords = true;
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _isOpen = widget.isOpenInitial;
    _qrCode = widget.qrCodeInitial;
    _loadRecords();
  }

  void _loadRecords() async {
    setState(() => _isLoadingRecords = true);
    final records = await _attendanceService.getSessionDetails(widget.sessionId);
    setState(() {
      _checkedInStudents = records;
      _isLoadingRecords = false;
    });
  }

  void _refreshQr() async {
    setState(() => _isActionLoading = true);
    final result = await _attendanceService.refreshQr(widget.sessionId);
    setState(() {
      _isActionLoading = false;
      if (result != null) {
        _qrCode = result['qrCode'];
        _isOpen = true;
      }
    });

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Làm mới mã QR thành công!')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể làm mới mã QR!')),
      );
    }
  }

  void _closeSession() async {
    setState(() => _isActionLoading = true);
    final success = await _attendanceService.closeSession(widget.sessionId);
    setState(() {
      _isActionLoading = false;
      if (success) {
        _isOpen = false;
        _qrCode = null;
      }
    });

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã đóng phiên điểm danh!')),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể đóng phiên!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Quản lý Phiên #${widget.sessionId}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppConstants.cardColor,
                borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
              ),
              child: Column(
                children: [
                  Text('Lớp học ID: ${widget.classSessionId}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Trạng thái: '),
                      Text(
                        _isOpen ? 'Đang mở' : 'Đã đóng',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _isOpen ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (_isOpen && _qrCode != null) ...[
              Center(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppConstants.primaryColor, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SizedBox(
                    width: 160,
                    height: 160,
                    child: QrImageView(
                      data: _qrCode!,
                      version: QrVersions.auto,
                      size: 160.0,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: AppConstants.secondaryColor),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Làm mới QR'),
                      onPressed: _isActionLoading ? null : _refreshQr,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      icon: const Icon(Icons.lock_rounded),
                      label: const Text('Đóng phiên'),
                      onPressed: _isActionLoading ? null : _closeSession,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
            const Text('Danh sách sinh viên đã điểm danh:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoadingRecords
                  ? const Center(child: CircularProgressIndicator())
                  : _checkedInStudents.isEmpty
                      ? const Center(child: Text('Chưa có sinh viên nào điểm danh.'))
                      : ListView.builder(
                          itemCount: _checkedInStudents.length,
                          itemBuilder: (context, index) {
                            final item = _checkedInStudents[index];
                            final name = item['fullName'] ?? item['studentName'] ?? 'Sinh viên';
                            final code = item['studentCode'] ?? '';
                            final status = item['status'] ?? 'Present';
                            return Card(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.defaultRadius)),
                              child: ListTile(
                                leading: const Icon(Icons.check_circle_rounded, color: AppConstants.accentColor),
                                title: Text('$code - $name', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Trạng thái: $status'),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
