import 'package:shared_preferences/shared_preferences.dart';
import 'package:encrypt/encrypt.dart' as ec;

class Hexagon {
  static String _author = '';
  static String _privacy1 = '';
  static String _privacy2 = '';
  final key = ec.Key.fromLength(32);
  final iv = ec.IV.fromLength(16);

  Future<void> loadTextValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final encrypter = ec.Encrypter(ec.AES(key));
    final encryptedID =
        ec.Encrypted.fromBase64(prefs.getString('author') ?? '');
    final encryptedPass1 =
        ec.Encrypted.fromBase64(prefs.getString('privacy1') ?? '');
    final encryptedPass2 =
        ec.Encrypted.fromBase64(prefs.getString('privacy2') ?? '');
    _author = encrypter.decrypt(encryptedID, iv: iv);
    _privacy1 = encrypter.decrypt(encryptedPass1, iv: iv);
    _privacy2 = encrypter.decrypt(encryptedPass2, iv: iv);
  }

  Future<void> saveTextValues(String a, String b, String c) async {
    bool authorEmpty = a == '',
        privacy1Empty = b == '',
        privacy2Empty = c == '';
    _author = a;
    _privacy1 = b;
    _privacy2 = c;
    final encrypter = ec.Encrypter(ec.AES(key));
    final encryptedID =
        (!authorEmpty) ? encrypter.encrypt(_author, iv: iv).base64 : _author;
    final encryptedPass1 = (!privacy1Empty)
        ? encrypter.encrypt(_privacy1, iv: iv).base64
        : _privacy1;
    final encryptedPass2 = (!privacy2Empty)
        ? encrypter.encrypt(_privacy2, iv: iv).base64
        : _privacy2;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('author', encryptedID);
    await prefs.setString('privacy1', encryptedPass1);
    await prefs.setString('privacy2', encryptedPass2);
  }

  static String getAuthor() => _author;
  static String getPrivacy1() => _privacy1;
  static String getPrivacy2() => _privacy2;
}
