import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:info_popup/info_popup.dart';
import 'package:mynust/Components/hex_color.dart';
import 'package:mynust/Components/toasts.dart';
import 'package:mynust/Core/credentials.dart';
import 'package:provider/provider.dart';
import '../Provider/internet_provider.dart';

class ClipboardWidget extends StatefulWidget {
  final bool isLMS;
  const ClipboardWidget({super.key, required this.isLMS});
  @override
  State<ClipboardWidget> createState() => _ClipboardWidgetState();
}

class _ClipboardWidgetState extends State<ClipboardWidget> {
  final CustomPopupMenuController _controller = CustomPopupMenuController();
  @override
  void initState() {
    super.initState();
    Hexagon().loadTextValues();
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
                                        'Can be changed through settings.',
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
                                  child: Text(
                                    hideId
                                        ? '*' * Hexagon.getAuthor().length
                                        : Hexagon.getAuthor(),
                                    style: const TextStyle(color: Colors.white),
                                    maxLines: 1,
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
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
                                    Clipboard.setData(ClipboardData(
                                        text: Hexagon.getAuthor()));
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
                                  child: Text(
                                    widget.isLMS
                                        ? hidePass
                                            ? '*' * Hexagon.getPrivacy1().length
                                            : Hexagon.getPrivacy1()
                                        : hidePass
                                            ? '*' * Hexagon.getPrivacy2().length
                                            : Hexagon.getPrivacy2(),
                                    style: const TextStyle(color: Colors.white),
                                    maxLines: 1,
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
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
                                    Clipboard.setData(ClipboardData(
                                        text: widget.isLMS
                                            ? Hexagon.getPrivacy1()
                                            : Hexagon.getPrivacy2()));
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
