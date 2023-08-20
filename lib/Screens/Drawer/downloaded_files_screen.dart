import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../Components/hex_color.dart';
import '../../Core/app_Theme.dart';
import '../../Core/theme_provider.dart';

class DownloadedFilesScreen extends StatefulWidget {
  const DownloadedFilesScreen({super.key});

  @override
  DownloadedFilesScreenState createState() => DownloadedFilesScreenState();
}

class DownloadedFilesScreenState extends State<DownloadedFilesScreen> {
  late Future<List<FileSystemEntity>> files;

  @override
  void initState() {
    super.initState();
    files = getFilesInDirectory();
  }

  Future<List<FileSystemEntity>> getFilesInDirectory() async {
    final Directory? tempDir = await getExternalStorageDirectory();
    final filePath = Directory("${tempDir!.path}/files");

    if (await filePath.exists()) {
      return filePath.listSync();
    } else {
      await filePath.create(recursive: true);
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isLightMode = themeProvider.isLightMode ??
        MediaQuery.of(context).platformBrightness == Brightness.light;
    return Scaffold(
      backgroundColor:
          isLightMode == true ? AppTheme.white : AppTheme.nearlyBlack,
      appBar: AppBar(
        shadowColor: Colors.grey.withOpacity(0.6),
        elevation: 1,
        backgroundColor:
            isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
        leading: null,
        iconTheme:
            IconThemeData(color: isLightMode ? Colors.black : Colors.white),
        title: Text(
          'Files',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isLightMode ? Colors.black : Colors.white),
        ),
      ),
      body: FutureBuilder<List<FileSystemEntity>>(
        future: files,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.hexagonDots(
                size: 40,
                color: HexColor('#0F6FC5'),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final fileList = snapshot.data ?? [];
            if (fileList.isEmpty) {
              return const Center(child: Text('No files found.'));
            }
            return ListView.builder(
              itemCount: fileList.length,
              itemBuilder: (context, index) {
                final file = fileList[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: themeProvider.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: isLightMode
                              ? AppTheme.grey
                              : themeProvider.primaryColor.withOpacity(0.8),
                          width: 3),
                    ),
                    child: ListTile(
                      onTap: () => OpenFile.open(file.path),
                      title: Text(' ${file.uri.pathSegments.last}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color:
                                  isLightMode ? Colors.black : Colors.white)),
                      leading: Icon(Icons.open_in_new_rounded,
                          color: isLightMode ? Colors.black : Colors.white),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
