import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:info_popup/info_popup.dart';
import 'package:mynust/Components/hex_color.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClipboardWidget extends StatefulWidget {
  const ClipboardWidget({super.key, required this.name});
  final String name;
  @override
  State<ClipboardWidget> createState() => _ClipboardWidgetState();
}

class _ClipboardWidgetState extends State<ClipboardWidget> {
  TextEditingController idTextController = TextEditingController();

  TextEditingController passTextController = TextEditingController();

  final CustomPopupMenuController _controller = CustomPopupMenuController();

  @override
  void initState() {
    super.initState();
    loadTextValues();
  }

  Future<void> loadTextValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      idTextController.text = prefs.getString('ID_${widget.name}') ?? '';
      passTextController.text = prefs.getString('PASS_${widget.name}') ?? '';
    });
  }

  Future<void> saveTextValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('ID_${widget.name}', idTextController.text);
    await prefs.setString('PASS_${widget.name}', passTextController.text);
  }

  @override
  Widget build(BuildContext context) {
    bool hideId = true;
    bool hidePass = true;
    return CustomPopupMenu(
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
                              contentOffset: Offset(-10, 0),
                              arrowTheme: InfoPopupArrowTheme(
                                arrowDirection: ArrowDirection.down,
                                color: Colors.grey,
                              ),
                              contentTheme: InfoPopupContentTheme(
                                infoContainerBackgroundColor: Colors.grey,
                                infoTextStyle: TextStyle(color: Colors.white),
                                contentPadding: EdgeInsets.all(6),
                                contentBorderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                infoTextAlign: TextAlign.center,
                              ),
                              dismissTriggerBehavior:
                                  PopupDismissTriggerBehavior.anyWhere,
                              contentTitle:
                                  'Your ID and password are saved locally on your device.',
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
                            keyboardType: TextInputType.visiblePassword,
                            obscureText: hideId,
                            style: const TextStyle(color: Colors.white),
                            controller: idTextController,
                            decoration: InputDecoration(
                              labelText: '${widget.name} ID',
                              labelStyle: const TextStyle(color: Colors.white),
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      backgroundColor: HexColor('#0F6FC5'),
                                      content: const Text('ID Copied')));
                              Clipboard.setData(
                                  ClipboardData(text: idTextController.text));
                            },
                            icon: const Icon(Icons.copy, color: Colors.white),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                              child: TextField(
                            onChanged: (value) => saveTextValues(),
                            keyboardType: TextInputType.visiblePassword,
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      backgroundColor: HexColor('#0F6FC5'),
                                      content: const Text('Password Copied')));
                              Clipboard.setData(
                                  ClipboardData(text: passTextController.text));
                            },
                            icon: const Icon(Icons.copy, color: Colors.white),
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
      child: CircleAvatar(
        backgroundColor: HexColor('#0F6FC5'),
        radius: 25,
        child: const Icon(Icons.assignment_sharp, color: Colors.white),
      ),
    );
  }
}
