import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/location_service.dart';
import '../../utils/constants.dart';

/// Màn hình Chia sẻ & Kiểm tra vị trí GPS của sinh viên
class LocationShareScreen extends StatefulWidget {
  const LocationShareScreen({super.key});

  @override
  State<LocationShareScreen> createState() => _LocationShareScreenState();
}

class _LocationShareScreenState extends State<LocationShareScreen> {
  final LocationService _locationService = LocationService();
  bool _isLoading = false;
  Position? _currentPosition;
  String _statusMessage = 'Chưa lấy vị trí GPS.';

  void _getLocation() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Đang lấy tọa độ GPS...';
    });

    final pos = await _locationService.getCurrentLocation();
    setState(() {
      _isLoading = false;
      _currentPosition = pos;
      _statusMessage = pos != null ? 'Đã lấy vị trí thành công!' : 'Không thể lấy vị trí. Vui lòng bật GPS!';
    });
  }

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chia sẻ vị trí GPS')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppConstants.cardColor,
                borderRadius: BorderRadius.circular(AppConstants.defaultRadius),
              ),
              child: Column(
                children: [
                  const Icon(Icons.location_on_rounded, size: 64, color: AppConstants.primaryColor),
                  const SizedBox(height: 12),
                  Text(_statusMessage, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (_currentPosition != null) ...[
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.defaultRadius)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vĩ độ (Latitude): ${_currentPosition!.latitude}', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Kinh độ (Longitude): ${_currentPosition!.longitude}', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Độ chính xác: ${_currentPosition!.accuracy.toStringAsFixed(1)} mét', style: const TextStyle(fontSize: 16)),
                      const SizedBox(height: 8),
                      Text('Thời gian: ${_currentPosition!.timestamp}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(18)),
              icon: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Icon(Icons.my_location_rounded),
              label: const Text('Làm mới vị trí hiện tại', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              onPressed: _isLoading ? null : _getLocation,
            ),
          ],
        ),
      ),
    );
  }
}
