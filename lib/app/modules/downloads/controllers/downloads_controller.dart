import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import '../../../controllers/stories_controller.dart';
import '../../../domain/downloads/downloaded_file_name.dart';
import '../../../routes/app_pages.dart';
import '../../widgets/custom_snackbar.dart';

class DownloadedFile {
  const DownloadedFile({
    required this.file,
    required this.size,
    required this.modified,
  });

  final File file;
  final int size;
  final DateTime modified;
  String get name => file.uri.pathSegments.last;
  String get extension =>
      name.contains('.') ? name.split('.').last.toLowerCase() : '';
}

class DownloadsController extends GetxController {
  final files = <DownloadedFile>[].obs;
  final isLoading = true.obs;
  final directoryPath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    refreshFiles();
  }

  Future<Directory> _downloadDirectory() async {
    if (Platform.isAndroid) {
      final directory = await getExternalStorageDirectory();
      if (directory != null) return directory;
    }
    return getApplicationDocumentsDirectory();
  }

  Future<void> refreshFiles() async {
    isLoading.value = true;
    try {
      final directory = await _downloadDirectory();
      directoryPath.value = directory.path;
      if (!await directory.exists()) await directory.create(recursive: true);
      final found = <DownloadedFile>[];
      final knownPaths = <String>{};
      await _collectDirectory(directory, found, knownPaths);
      if (Platform.isAndroid) {
        await _collectPublicAndroidDownloads(found, knownPaths);
      }
      found.sort((a, b) => b.modified.compareTo(a.modified));
      files.assignAll(found);
    } catch (error, stackTrace) {
      debugPrint('Could not read downloaded files: $error\n$stackTrace');
      AppSnackbar.error(message: 'Could not read the downloads folder');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _collectDirectory(
    Directory directory,
    List<DownloadedFile> found,
    Set<String> knownPaths,
  ) async {
    await for (final entity in directory.list(recursive: true)) {
      if (entity is File) await _addFile(entity, found, knownPaths);
    }
  }

  Future<void> _collectPublicAndroidDownloads(
    List<DownloadedFile> found,
    Set<String> knownPaths,
  ) async {
    final tasks = await FlutterDownloader.loadTasks() ?? const <DownloadTask>[];
    final publicDirectory = await getDownloadsDirectory();
    final completedNames = tasks
        .where((task) =>
            task.status == DownloadTaskStatus.complete && task.filename != null)
        .map((task) => task.filename!)
        .toSet();

    final publicDirectories = <Directory>{
      if (publicDirectory != null) publicDirectory,
      Directory('/storage/emulated/0/Download'),
    };
    for (final directory in publicDirectories) {
      try {
        if (!await directory.exists()) continue;
        await for (final entity in directory.list()) {
          if (entity is File &&
              completedNames.any((name) => DownloadedFileName.matches(
                    expected: name,
                    actual: entity.uri.pathSegments.last,
                  ))) {
            await _addFile(entity, found, knownPaths);
          }
        }
      } catch (error) {
        debugPrint('Public downloads are not directly readable: $error');
      }
    }

    for (final task in tasks) {
      if (task.status != DownloadTaskStatus.complete || task.filename == null) {
        continue;
      }
      final privateCandidate = File('${task.savedDir}/${task.filename}');
      if (await privateCandidate.exists()) {
        await _addFile(privateCandidate, found, knownPaths);
      }
    }
  }

  Future<void> _addFile(
    File file,
    List<DownloadedFile> found,
    Set<String> knownPaths,
  ) async {
    if (!knownPaths.add(file.absolute.path)) return;
    final stat = await file.stat();
    found.add(DownloadedFile(
      file: file,
      size: stat.size,
      modified: stat.modified,
    ));
  }

  Future<void> openFile(DownloadedFile item) async {
    final result = await OpenFilex.open(item.file.path);
    if (result.type != ResultType.done) {
      AppSnackbar.error(
          message: result.message.isEmpty
              ? 'No compatible viewer is installed for this file'
              : result.message);
    }
  }

  Future<void> deleteFile(DownloadedFile item) async {
    try {
      await item.file.delete();
      await refreshFiles();
      AppSnackbar.success(message: '${item.name} deleted');
    } catch (error) {
      AppSnackbar.error(message: 'Could not delete ${item.name}');
    }
  }

  void browseCampusDownloads() {
    final campus = Get.find<StoriesController>();
    Get.toNamed(
      Routes.WEB,
      parameters: {'url': '${campus.getCampusUrl()}/downloads'},
    );
  }
}
