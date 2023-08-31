import 'dart:io';

import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:mynust/Components/action_button.dart';
import 'package:page_transition/page_transition.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:swipeable_tile/swipeable_tile.dart';

import '../../Components/hex_color.dart';
import '../../Components/toasts.dart';
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
  Directory? folderPath;
  @override
  void initState() {
    super.initState();
    folders = getFoldersInDirectory();
  }

  Future<List<FileSystemEntity>> getFoldersInDirectory() async {
    Directory? tempDir = await getExternalStorageDirectory();
    folderPath = Directory("${tempDir!.path}/gallery");

    if (await folderPath!.exists()) {
      return folderPath!.listSync();
    } else {
      await folderPath!.create(recursive: true);
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
    if (await folderPath!.exists()) {
      return folderPath!.path;
    } else {
      await folderPath!.create(recursive: true);
      return folderPath!.path;
    }
  }

  void _deleteDialog(BuildContext context, bool isLightMode) async {
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
          content: Text('Are you sure you want to delete all folders?',
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
                deleteAllFoldersInDirectory();
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
    TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
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
            controller: controller,
            style: TextStyle(color: isLightMode ? Colors.black : Colors.white),
            onChanged: (value) {},
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
                if (controller.text.isNotEmpty) {
                  if (await folderPath!.exists()) {
                    final newFolderPath =
                        "${folderPath!.path}/${controller.text.toUpperCase()}";
                    if (!folderList.any((folder) =>
                        folder.path == Directory(newFolderPath).path)) {
                      final newFolder = Directory(newFolderPath);
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
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                } else {
                  // ignore: use_build_context_synchronously
                  Toast().errorToast(
                      context, 'Incorrect name or folder already exists');
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
              onPressed: () => _deleteDialog(context, isLightMode),
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
            return ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: folderList.length,
              itemBuilder: (context, index) {
                final folder = folderList[index];
                String name = folder.path.split('/').last;
                int files = getImagesFromFolder(folder).length;
                return SwipeableTile.card(
                  color: Colors.transparent,
                  shadow: const BoxShadow(
                    color: Colors.transparent,
                    blurRadius: 0,
                    offset: Offset(2, 2),
                  ),
                  horizontalPadding: 0,
                  verticalPadding: 0,
                  direction: SwipeDirection.horizontal,
                  onSwiped: (direction) {
                    deleteFolder(folderList[index].path);
                  },
                  backgroundBuilder: (context, direction, progress) {
                    return AnimatedBuilder(
                      animation: progress,
                      builder: (context, child) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          color: progress.value > 0.4
                              ? const Color(0xFFed7474)
                              : isLightMode
                                  ? AppTheme.white
                                  : AppTheme.nearlyBlack,
                        );
                      },
                    );
                  },
                  key: UniqueKey(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color:
                            isLightMode ? AppTheme.white : AppTheme.nearlyBlack,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: isLightMode
                                ? AppTheme.notWhite
                                : themeProvider.primaryColor,
                            width: 3),
                        boxShadow: !isLightMode
                            ? null
                            : <BoxShadow>[
                                BoxShadow(
                                    color: Colors.grey.withOpacity(0.6),
                                    offset: const Offset(4, 4),
                                    blurRadius: 8.0),
                              ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
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
                          leading: Image.asset(
                            'assets/images/gallery.png',
                            filterQuality: FilterQuality.high,
                            scale: .3,
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                name,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    color: isLightMode
                                        ? AppTheme.nearlyBlack
                                        : Colors.white),
                              ),
                              Text(
                                (files > 1) ? '$files Images' : '$files Image',
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: isLightMode
                                        ? AppTheme.nearlyBlack
                                        : Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
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
