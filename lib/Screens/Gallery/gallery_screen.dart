import 'dart:io';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mynust/Components/action_button.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../Components/hex_color.dart';
import '../../Core/app_Theme.dart';
import '../../Provider/theme_provider.dart';
import 'folder_screen.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  GalleryScreenState createState() => GalleryScreenState();
}

class GalleryScreenState extends State<GalleryScreen> {
  late Future<List<FileSystemEntity>> folders;
  List<FileSystemEntity> folderList = [];
  Directory? tempDir;
  @override
  void initState() {
    super.initState();
    folders = getFoldersInDirectory();
  }

  Future<List<FileSystemEntity>> getFoldersInDirectory() async {
    tempDir = await getExternalStorageDirectory();

    final folderPath = Directory("${tempDir!.path}/gallery");

    if (await folderPath.exists()) {
      return folderPath.listSync();
    } else {
      await folderPath.create(recursive: true);
      return [];
    }
  }

  Future<void> deleteAllFoldersInDirectory() async {
    String directoryPath = await getPath();
    final directory = Directory(directoryPath);

    if (await directory.exists()) {
      final folders = await directory.list().toList();

      for (var folder in folders) {
        if (folder is Directory) {
          await folder.delete(recursive: true);
        }
      }
      setState(() {
        folderList.clear();
      });
      folderList = await getFoldersInDirectory();
    }
  }

  Future<String> getPath() async {
    final filePath = Directory("${tempDir!.path}/gallery");
    if (await filePath.exists()) {
      return filePath.path;
    } else {
      await filePath.create(recursive: true);
      return filePath.path;
    }
  }

  void _deleteDialog(BuildContext context, bool isLightMode, bool all,
      {String folderPath = ''}) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor:
              isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
          title: Text(
            'Confirm Delete',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isLightMode ? Colors.black : Colors.white),
          ),
          content: Text(
              all
                  ? 'Are you sure you want to delete all folders?'
                  : 'Are you sure you want to delete this folders?',
              style: TextStyle(
                  fontSize: 14,
                  color: isLightMode ? Colors.black : Colors.white)),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel',
                  style: TextStyle(
                      fontSize: 14,
                      color: isLightMode ? Colors.black : Colors.white)),
            ),
            TextButton(
              onPressed: () {
                all ? deleteAllFoldersInDirectory() : deleteFolder(folderPath);
                Navigator.of(context).pop();
              },
              child: const Text('Delete',
                  style: TextStyle(fontSize: 14, color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteFolder(String folderPath) async {
    final folder = Directory(folderPath);
    if (await folder.exists()) {
      await folder.delete(recursive: true);
      setState(() {
        folderList.removeWhere((item) => item.path == folderPath);
      });
    }
  }

  void addFolder(bool isLightMode) {
    bool isSnackBarVisible = false;
    showDialog(
      context: context,
      builder: (context) {
        String newFolderName = '';
        return AlertDialog(
          backgroundColor:
              isLightMode ? AppTheme.nearlyWhite : AppTheme.nearlyBlack,
          title: Text(
            'Add Folder',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isLightMode ? Colors.black : Colors.white),
          ),
          content: TextField(
            style: TextStyle(color: isLightMode ? Colors.black : Colors.white),
            onChanged: (value) {
              newFolderName = value;
            },
            decoration: InputDecoration(
                labelText: 'Folder',
                labelStyle: TextStyle(
                    fontSize: 12,
                    color: isLightMode ? Colors.black : Colors.white)),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Add',
                  style: TextStyle(
                      fontSize: 12,
                      color: isLightMode ? Colors.black : Colors.white)),
              onPressed: () async {
                bool error = false;
                if (newFolderName.isNotEmpty) {
                  final galleryPath = Directory("${tempDir!.path}/gallery");
                  if (await galleryPath.exists()) {
                    final newFolderPath = "${galleryPath.path}/$newFolderName";
                    final newFolder = Directory(newFolderPath);
                    if (!folderList.toString().contains(newFolder.path)) {
                      print(
                          'not exists $folderList,, $newFolder ,, ${folderList.contains(newFolder) == false}');
                      await newFolder.create(recursive: true);
                      setState(() {
                        folderList.add(newFolder);
                      });
                    } else {
                      error = true;
                    }
                  } else {
                    error = true;
                  }
                } else {
                  error = true;
                }
                if (!error) {
                  Navigator.pop(context);
                } else {
                  if (!isSnackBarVisible) {
                    setState(() {
                      isSnackBarVisible = true;
                    });
                    final snackBar = SnackBar(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      content: AwesomeSnackbarContent(
                        title: 'Error',
                        message: "Incorrect name or folder already exists",
                        contentType: ContentType.warning,
                      ),
                    );

                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(snackBar).closed.then((_) {
                        setState(() {
                          isSnackBarVisible = false;
                        });
                      });
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  List<String> getImagesFromFolder(FileSystemEntity folder) {
    List<String> imagePaths = [];

    if (folder is Directory) {
      final directory = folder;
      final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp'];

      for (var entity in directory.listSync()) {
        if (entity is File) {
          final extension = entity.path.toLowerCase().split('.').last;
          if (imageExtensions.contains('.$extension')) {
            imagePaths.add(entity.path);
          }
        }
      }
    }

    return imagePaths;
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
          'Gallery',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isLightMode ? Colors.black : Colors.white),
        ),
        actions: [
          IconButton(
              onPressed: () => _deleteDialog(context, isLightMode, true),
              icon: const Icon(Icons.delete_rounded))
        ],
      ),
      body: FutureBuilder<List<FileSystemEntity>>(
        future: folders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: LoadingAnimationWidget.hexagonDots(
                size: 40,
                color: HexColor('#0F6FC5'),
              ),
            );
          } else if (snapshot.hasError) {
            return const Center(
                child: Text('Error!', style: TextStyle(color: Colors.red)));
          } else {
            folderList = snapshot.data ?? [];
            if (folderList.isEmpty) {
              return Center(
                  child: Text('No folder found.',
                      style: TextStyle(
                          color: isLightMode ? Colors.black : Colors.white)));
            }
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Wrap(
                spacing: 12.0,
                runSpacing: 16.0,
                children: List.generate(
                  folderList.length,
                  (index) {
                    final folder = folderList[index];
                    String name = folder.path.split('/').last;
                    return GestureDetector(
                      onLongPress: () => _deleteDialog(
                          context, isLightMode, false,
                          folderPath: folderList[index].path),
                      onDoubleTap: () => _deleteDialog(
                          context, isLightMode, false,
                          folderPath: folderList[index].path),
                      onTap: () async {
                        await Navigator.push(
                            context,
                            PageTransition(
                                duration: const Duration(milliseconds: 500),
                                type: PageTransitionType.rightToLeft,
                                alignment: Alignment.bottomCenter,
                                child: FolderScreen(
                                  folder: name,
                                ),
                                inheritTheme: true,
                                ctx: context));
                        setState(() {
                          folders = getFoldersInDirectory();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/gallery.png',
                              scale: .5,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Text(
                                name,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: isLightMode
                                        ? Colors.black
                                        : Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          }
        },
      ),
      floatingActionButton: ActionButton(
          func: () => addFolder(isLightMode),
          icon: Icons.add,
          color: Colors.white),
    );
  }
}
