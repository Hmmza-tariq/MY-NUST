import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:encrypt/encrypt.dart' as ec;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:info_popup/info_popup.dart';
import 'package:mynust/Components/hex_color.dart';
import 'package:mynust/Components/toasts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Provider/internet_provider.dart';

class ClipboardWidget extends StatefulWidget {
  const ClipboardWidget({super.key});
  @override
  State<ClipboardWidget> createState() => _ClipboardWidgetState();
}

class _ClipboardWidgetState extends State<ClipboardWidget> {
  TextEditingController idTextController = TextEditingController();
  TextEditingController passTextController = TextEditingController();
  final CustomPopupMenuController _controller = CustomPopupMenuController();
  final key = ec.Key.fromLength(32);
  final iv = ec.IV.fromLength(16);
  @override
  void initState() {
    super.initState();
    loadTextValues();
  }

  Future<void> loadTextValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      final encrypter = ec.Encrypter(ec.AES(key));
      final encryptedID = ec.Encrypted.fromBase64(prefs.getString('ID') ?? '');
      final encryptedPass =
          ec.Encrypted.fromBase64(prefs.getString('PASS') ?? '');
      idTextController.text = encrypter.decrypt(encryptedID, iv: iv);
      passTextController.text = encrypter.decrypt(encryptedPass, iv: iv);
    });
  }

  Future<void> saveTextValues() async {
    final encrypter = ec.Encrypter(ec.AES(key));
    final encryptedID = encrypter.encrypt(idTextController.text, iv: iv);
    final encryptedPass = encrypter.encrypt(passTextController.text, iv: iv);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('ID', encryptedID.base64);
    await prefs.setString('PASS', encryptedPass.base64);
  }

  @override
  Widget build(BuildContext context) {
    bool hideId = true;
    bool hidePass = true;
    return Provider.of<InternetProvider>(context).isConnected
        ? CustomPopupMenu(
            arrowColor: const Color.fromARGB(255, 23, 80, 165),
            menuBuilder: () => ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Container(
                width: 280,
                color: const Color.fromARGB(255, 23, 80, 165),
                child: IntrinsicWidth(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: StatefulBuilder(builder: (context, setState) {
                      return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'ID / Pass',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 12.0),
                                  child: InfoPopupWidget(
                                    contentOffset: Offset(-15, 0),
                                    arrowTheme: InfoPopupArrowTheme(
                                      arrowDirection: ArrowDirection.down,
                                      color: Colors.grey,
                                    ),
                                    contentTheme: InfoPopupContentTheme(
                                      infoContainerBackgroundColor: Colors.grey,
                                      infoTextStyle:
                                          TextStyle(color: Colors.white),
                                      contentPadding: EdgeInsets.all(6),
                                      contentBorderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      infoTextAlign: TextAlign.center,
                                    ),
                                    dismissTriggerBehavior:
                                        PopupDismissTriggerBehavior.anyWhere,
                                    contentTitle:
                                        'Your ID and password is saved locally on your device in  encrypted form.',
                                    child: Icon(
                                      Icons.info_outline,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: TextField(
                                  onChanged: (value) => saveTextValues(),
                                  keyboardType: hideId
                                      ? TextInputType.visiblePassword
                                      : TextInputType.name,
                                  obscureText: hideId,
                                  style: const TextStyle(color: Colors.white),
                                  controller: idTextController,
                                  decoration: const InputDecoration(
                                    labelText: 'ID',
                                    labelStyle: TextStyle(color: Colors.white),
                                  ),
                                )),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      hideId = !hideId;
                                    });
                                  },
                                  icon: Icon(
                                      hideId
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.white),
                                ),
                                IconButton(
                                  onPressed: () {
                                    saveTextValues();
                                    Clipboard.setData(ClipboardData(
                                        text: idTextController.text));
                                    Toast().successToast(context, 'ID copied');
                                  },
                                  icon: const Icon(Icons.copy,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                    child: TextField(
                                  onChanged: (value) => saveTextValues(),
                                  keyboardType: hidePass
                                      ? TextInputType.visiblePassword
                                      : TextInputType.name,
                                  obscureText: hidePass,
                                  style: const TextStyle(color: Colors.white),
                                  controller: passTextController,
                                  decoration: const InputDecoration(
                                    labelText: 'Pass',
                                    labelStyle: TextStyle(color: Colors.white),
                                  ),
                                )),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      hidePass = !hidePass;
                                    });
                                  },
                                  icon: Icon(
                                      hidePass
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.white),
                                ),
                                IconButton(
                                  onPressed: () {
                                    saveTextValues();
                                    Clipboard.setData(ClipboardData(
                                        text: passTextController.text));
                                    Toast().successToast(
                                        context, 'Password copied');
                                  },
                                  icon: const Icon(Icons.copy,
                                      color: Colors.white),
                                ),
                              ],
                            ),
                          ]);
                    }),
                  ),
                ),
              ),
            ),
            pressType: PressType.singleClick,
            verticalMargin: -10,
            controller: _controller,
            child: Container(
              alignment: Alignment.centerRight,
              width: 70,
              height: 50,
              decoration: BoxDecoration(
                color: HexColor('#0F6FC5'),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.assignment_rounded, color: Colors.white),
              ),
            ),
          )
        : Container();
  }
}
