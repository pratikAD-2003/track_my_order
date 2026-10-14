import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefService {
  static SharedPreferences? _prefs;

  /// Initializes SharedPreferences instance. Must be called in main().
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  // ── Keys ─────────────────────────────────────────────────────────────
  static const String _keyIsLogin = 'is_login';
  static const String _keyIsProfileCompleted = 'is_profile_completed';
  static const String _keyInvoicePrefix = 'invoice_prefix';
  static const String _keyInvoiceStartNumber = 'invoice_start_number';
  static const String _keyDefaultTerms = 'default_terms';
  static const String _keyInvoiceTemplate = 'invoice_template';
  static const String _keyTaxType = 'tax_type';
  static const String _keyRoundOff = 'round_off';
  static const String _keyShowBankDetails = 'show_bank_details';
  static const String _keyShowPaymentQR = 'show_payment_qr';
  static const String _keyShowSignature = 'show_signature';
  static const String _keyShowNotesAndTerms = 'show_notes_and_terms';
  static const String _keyShowDueDate = 'show_due_date';
  static const String _keyShowQROnInvoice = 'show_qr_on_invoice';
  static const String _keyAppLanguage = 'app_language';
  static const String _keyAppTheme = 'app_theme';
  static const String _keyFontSize = 'font_size';
  static const String _keyAppLockEnabled = 'app_lock_enabled';
  static const String _keyBiometricEnabled = 'biometric_enabled';

  // ── Auth & Profile Flags ─────────────────────────────────────────────
  static Future<void> setIsLogin(bool value) async {
    await init();
    await _prefs?.setBool(_keyIsLogin, value);
  }

  static bool getIsLogin({bool defaultValue = false}) {
    return _prefs?.getBool(_keyIsLogin) ?? defaultValue;
  }

  static Future<void> setIsProfileCompleted(bool value) async {
    await init();
    await _prefs?.setBool(_keyIsProfileCompleted, value);
  }

  static bool getIsProfileCompleted({bool defaultValue = false}) {
    return _prefs?.getBool(_keyIsProfileCompleted) ?? defaultValue;
  }

  // ── Invoice Settings ─────────────────────────────────────────────────
  static Future<void> setInvoicePrefix(String value) async {
    await init();
    await _prefs?.setString(_keyInvoicePrefix, value);
  }

  static String getInvoicePrefix({String defaultValue = 'INV'}) {
    return _prefs?.getString(_keyInvoicePrefix) ?? defaultValue;
  }

  static Future<void> setInvoiceStartNumber(int value) async {
    await init();
    await _prefs?.setInt(_keyInvoiceStartNumber, value);
  }

  static int getInvoiceStartNumber({int defaultValue = 1001}) {
    return _prefs?.getInt(_keyInvoiceStartNumber) ?? defaultValue;
  }

  static Future<void> setDefaultTerms(String value) async {
    await init();
    await _prefs?.setString(_keyDefaultTerms, value);
  }

  static String getDefaultTerms({String defaultValue = 'Payment due within 30 days of invoice date.'}) {
    return _prefs?.getString(_keyDefaultTerms) ?? defaultValue;
  }

  static Future<void> setInvoiceTemplate(String value) async {
    await init();
    await _prefs?.setString(_keyInvoiceTemplate, value);
  }

  static String getInvoiceTemplate({String defaultValue = 'Classic'}) {
    return _prefs?.getString(_keyInvoiceTemplate) ?? defaultValue;
  }

  static Future<void> setTaxType(String value) async {
    await init();
    await _prefs?.setString(_keyTaxType, value);
  }

  static String getTaxType({String defaultValue = 'Exclusive'}) {
    return _prefs?.getString(_keyTaxType) ?? defaultValue;
  }

  static Future<void> setRoundOff(bool value) async {
    await init();
    await _prefs?.setBool(_keyRoundOff, value);
  }

  static bool getRoundOff({bool defaultValue = true}) {
    return _prefs?.getBool(_keyRoundOff) ?? defaultValue;
  }

  static Future<void> setShowBankDetails(bool value) async {
    await init();
    await _prefs?.setBool(_keyShowBankDetails, value);
  }

  static bool getShowBankDetails({bool defaultValue = true}) {
    return _prefs?.getBool(_keyShowBankDetails) ?? defaultValue;
  }

  static Future<void> setShowPaymentQR(bool value) async {
    await init();
    await _prefs?.setBool(_keyShowPaymentQR, value);
  }

  static bool getShowPaymentQR({bool defaultValue = true}) {
    return _prefs?.getBool(_keyShowPaymentQR) ?? defaultValue;
  }

  static Future<void> setShowSignature(bool value) async {
    await init();
    await _prefs?.setBool(_keyShowSignature, value);
  }

  static bool getShowSignature({bool defaultValue = false}) {
    return _prefs?.getBool(_keyShowSignature) ?? defaultValue;
  }

  static Future<void> setShowNotesAndTerms(bool value) async {
    await init();
    await _prefs?.setBool(_keyShowNotesAndTerms, value);
  }

  static bool getShowNotesAndTerms({bool defaultValue = true}) {
    return _prefs?.getBool(_keyShowNotesAndTerms) ?? defaultValue;
  }

  static Future<void> setShowDueDate(bool value) async {
    await init();
    await _prefs?.setBool(_keyShowDueDate, value);
  }

  static bool getShowDueDate({bool defaultValue = true}) {
    return _prefs?.getBool(_keyShowDueDate) ?? defaultValue;
  }

  static Future<void> setShowQROnInvoice(bool value) async {
    await init();
    await _prefs?.setBool(_keyShowQROnInvoice, value);
  }

  static bool getShowQROnInvoice({bool defaultValue = true}) {
    return _prefs?.getBool(_keyShowQROnInvoice) ?? defaultValue;
  }

  // ── App Settings ─────────────────────────────────────────────────────
  static Future<void> setAppLanguage(String value) async {
    await init();
    await _prefs?.setString(_keyAppLanguage, value);
  }

  static String getAppLanguage({String defaultValue = 'English'}) {
    return _prefs?.getString(_keyAppLanguage) ?? defaultValue;
  }

  static Future<void> setAppTheme(String value) async {
    await init();
    await _prefs?.setString(_keyAppTheme, value);
  }

  static String getAppTheme({String defaultValue = 'Light'}) {
    return _prefs?.getString(_keyAppTheme) ?? defaultValue;
  }

  static Future<void> setFontSize(String value) async {
    await init();
    await _prefs?.setString(_keyFontSize, value);
  }

  static String getFontSize({String defaultValue = 'Medium'}) {
    return _prefs?.getString(_keyFontSize) ?? defaultValue;
  }

  static Future<void> setAppLockEnabled(bool value) async {
    await init();
    await _prefs?.setBool(_keyAppLockEnabled, value);
  }

  static bool getAppLockEnabled({bool defaultValue = false}) {
    return _prefs?.getBool(_keyAppLockEnabled) ?? defaultValue;
  }

  static Future<void> setBiometricEnabled(bool value) async {
    await init();
    await _prefs?.setBool(_keyBiometricEnabled, value);
  }

  static bool getBiometricEnabled({bool defaultValue = false}) {
    return _prefs?.getBool(_keyBiometricEnabled) ?? defaultValue;
  }
}
