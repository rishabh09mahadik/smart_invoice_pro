import 'package:shared_preferences/shared_preferences.dart';

class BusinessRepository {
  static const String _keyName = 'business_name';
  static const String _keyAddress = 'business_address';
  static const String _keyPhone = 'business_phone';
  static const String _keyEmail = 'business_email';
  static const String _keyGst = 'business_gst';
  static const String _keyCurrency = 'business_currency';

  Future<void> saveBusinessDetails({
    required String name,
    required String address,
    required String phone,
    required String email,
    required String gst,
    required String currency,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name);
    await prefs.setString(_keyAddress, address);
    await prefs.setString(_keyPhone, phone);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyGst, gst);
    await prefs.setString(_keyCurrency, currency);
  }

  Future<Map<String, String>> getBusinessDetails() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_keyName) ?? '',
      'address': prefs.getString(_keyAddress) ?? '',
      'phone': prefs.getString(_keyPhone) ?? '',
      'email': prefs.getString(_keyEmail) ?? '',
      'gst': prefs.getString(_keyGst) ?? '',
      'currency': prefs.getString(_keyCurrency) ?? 'USD',
    };
  }
}
