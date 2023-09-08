import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as ec;

class Hexagon {
  static String _author = '';
  static String _privacy = '';
  final key = ec.Key.fromLength(32);
  final iv = ec.IV.fromLength(16);

  Future<void> loadTextValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final encrypter = ec.Encrypter(ec.AES(key));
    final encryptedID =
        ec.Encrypted.fromBase64(prefs.getString('author') ?? '');
    final encryptedPass =
        ec.Encrypted.fromBase64(prefs.getString('privacy') ?? '');
    _author = encrypter.decrypt(encryptedID, iv: iv);
    _privacy = encrypter.decrypt(encryptedPass, iv: iv);
  }

  Future<void> saveTextValues(String a, String b) async {
    bool authorEmpty = a == '', privacyEmpty = b == '';
    _author = a;
    _privacy = b;
    final encrypter = ec.Encrypter(ec.AES(key));
    final encryptedID =
        (!authorEmpty) ? encrypter.encrypt(_author, iv: iv).base64 : _author;
    final encryptedPass =
        (!privacyEmpty) ? encrypter.encrypt(_privacy, iv: iv).base64 : _privacy;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('author', encryptedID);
    await prefs.setString('privacy', encryptedPass);
  }

  static String getAuthor() => _author;
  static String getPrivacy() => _privacy;
}
