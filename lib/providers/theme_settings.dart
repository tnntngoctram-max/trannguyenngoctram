import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Provider quản lý màu sắc chủ đạo và cỡ chữ toàn ứng dụng
class ThemeSettings extends ChangeNotifier {
  Color _primaryColor = AppConstants.primaryColor;
  double _fontScale = 1.0;

  Color get primaryColor => _primaryColor;
  double get fontScale => _fontScale;

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }

  void setFontScale(double scale) {
    _fontScale = scale;
    notifyListeners();
  }
}
