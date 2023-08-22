import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:swipeable_tile/swipeable_tile.dart';

import '../../Components/action_button.dart';
import '../../Components/hex_color.dart';
import '../../Core/app_Theme.dart';
import '../../Provider/theme_provider.dart';

class FolderScreen extends StatefulWidget {
  const FolderScreen({super.key, required this.folder});
  final String folder;
  @override
  FolderScreenState createState() => FolderScreenState();
}

class FolderScreenState extends State<FolderScreen> {
  late Future<List<FileSystemEntity>> files;
  List<FileSystemEntity> fileList = [];
  bool _cameraPermissionGranted = false;
  bool _photosPermissionGranted = false;
  @override
  void initState() {
    super.initState();
    files = getFilesInDirectory();
  }

  Future<List<FileSystemEntity>> getFilesInDirectory() async {
    final Directory? tempDir = await getExternalStorageDirectory();
    final filePath = Directory("${tempDir!.path}/gallery/${widget.folder}");

    if (await filePath.exists()) {
      return filePath.listSync();
    } else {
      await filePath.create(recursive: true);
      return [];
    }
  }

  Future<void> deleteAllFilesInDirectory() async {
    String directoryPath = await getPath();
    final directory = Directory(directoryPath);

    if (await directory.exists()) {
      final files = await directory.list().toList();

      for (var file in files) {
        if (file is File) {
          await file.delete();
        }
      }
      setState(() {
        fileList.clear();
      });
    }
  }

  Future<String> getPath() async {
    final Directory? tempDir = await getExternalStorageDirectory();
    final filePath = Directory("${tempDir!.path}/gallery/${widget.folder}");
    if (await filePath.exists()) {
      return filePath.path;
    } else {
      await filePath.create(recursive: true);
      return filePath.path;
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
          content: Text('Are you sure you want to delete all images?',
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
                deleteAllFilesInDirectory();
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

  Future<void> deleteFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  void pickImage() async {
    checkPhotosPermission();
    if (_photosPermissionGranted) {
      try {
        final image =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        if (image == null) {
          return;
        } else {
          await saveImage(image);
        }
      } catch (e) {
        print(e);
      }
    }
  }

  void checkCameraPermission() async {
    var hasCameraPermission = await Permission.camera.isGranted;
    if (!hasCameraPermission) {
      final status = await Permission.camera.request();
      hasCameraPermission = status.isGranted;
    }
    setState(() {
      _cameraPermissionGranted = hasCameraPermission;
    });
  }

  void checkPhotosPermission() async {
    var hasPhotosPermission = await Permission.photos.isGranted;
    if (!hasPhotosPermission) {
      final status = await Permission.photos.request();
      hasPhotosPermission = status.isGranted;
    }
    setState(() {
      _photosPermissionGranted = hasPhotosPermission;
    });
  }

  void takeImage() async {
    checkCameraPermission();
    if (_cameraPermissionGranted) {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) {
        return;
      } else {
        await saveImage(image);
      }
    }
  }

  Future<String> saveImage(XFile pickedImage) async {
    final Directory galleryDir = await getGalleryDirectory(widget.folder);
    final String imageName = DateTime.now().millisecondsSinceEpoch.toString();
    final String imagePath = '${galleryDir.path}/$imageName.png';

    final File newImage = File(imagePath);
    await newImage.writeAsBytes(await pickedImage.readAsBytes());

    return imagePath;
  }

  Future<Directory> getGalleryDirectory(String folderName) async {
    final Directory? tempDir = await getExternalStorageDirectory();
    final galleryPath = Directory("${tempDir!.path}/gallery/$folderName");

    if (await galleryPath.exists()) {
      return galleryPath;
    } else {
      await galleryPath.create(recursive: true);
      return galleryPath;
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
          widget.folder,
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
            return const Center(
                child: Text('Error!', style: TextStyle(color: Colors.red)));
          } else {
            fileList = snapshot.data ?? [];
            if (fileList.isEmpty) {
              return Center(
                  child: Text('No image found.',
                      style: TextStyle(
                          color: isLightMode ? Colors.black : Colors.white)));
            }
            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Wrap(
                spacing: 16.0,
                runSpacing: 16.0,
                children: List.generate(
                  fileList.length,
                  (index) {
                    final file = fileList[index];
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
                      onSwiped: (direction) => deleteFile(file.path),
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
                      child: GestureDetector(
                        onTap: () => OpenFile.open(file.path),
                        child: SizedBox(
                          width: 100,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset('assets/images/file.png'),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text(
                                  ' ${file.uri.pathSegments.last}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 8,
                                      color: isLightMode
                                          ? Colors.black
                                          : Colors.white),
                                ),
                              ),
                            ],
                          ),
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 30, bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ActionButton(
              func: () => pickImage,
              icon: Icons.upload,
              color: AppTheme.grey,
            ),
            Expanded(child: Container()),
            ActionButton(
              func: () => takeImage,
              icon: Icons.camera_alt_rounded,
              color: Colors.pink,
            ),
          ],
        ),
      ),
    );
  }
}
