import 'dart:io';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class PageViewScreen extends StatefulWidget {
  const PageViewScreen(
      {super.key,
      required this.fileList,
      required this.index,
      required this.name});
  final List<FileSystemEntity> fileList;
  final int index;
  final String name;

  @override
  State<PageViewScreen> createState() => _PageViewScreenState();
}

class _PageViewScreenState extends State<PageViewScreen> {
  PageController controller = PageController();
  int currentPageIndex = 0;
  @override
  void initState() {
    currentPageIndex = widget.index;
    controller = PageController(initialPage: currentPageIndex);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final int itemCount = widget.fileList.length;
    return SafeArea(
      child: Center(
        child: PhotoViewGallery.builder(
            customSize: Size(MediaQuery.of(context).size.width,
                MediaQuery.of(context).size.height / .5),
            backgroundDecoration: const BoxDecoration(
              color: Color.fromARGB(170, 0, 0, 0),
            ),
            pageController: controller,
            itemCount: itemCount,
            builder: (context, index) {
              return PhotoViewGalleryPageOptions(
                  maxScale: PhotoViewComputedScale.contained * 4,
                  minScale: PhotoViewComputedScale.contained,
                  imageProvider: FileImage(
                    File(widget.fileList[index].path),
                  ));
            }),
      ),
    );
  }
}
