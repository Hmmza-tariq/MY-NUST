import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfrx/pdfrx.dart';

import '../../widgets/app_dialog.dart';
import '../../widgets/app_glass_surface.dart';
import '../../widgets/app_page_shell.dart';
import '../controllers/downloads_controller.dart';

class DownloadsView extends GetView<DownloadsController> {
  const DownloadsView({super.key});

  @override
  Widget build(BuildContext context) => AppPageShell(
        title: 'Downloaded files',
        subtitle:
            'Open and manage files saved from Qalam, LMS, and campus pages.',
        scrollable: false,
        trailing: IconButton.filledTonal(
          tooltip: 'Refresh files',
          onPressed: controller.refreshFiles,
          icon: const Icon(Icons.refresh_rounded),
        ),
        child: Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            return Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.tonalIcon(
                    onPressed: controller.browseCampusDownloads,
                    icon: const Icon(Icons.cloud_download_outlined),
                    label: const Text('Browse campus downloads'),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: controller.files.isEmpty
                      ? _EmptyDownloads(path: controller.directoryPath.value)
                      : RefreshIndicator(
                          onRefresh: controller.refreshFiles,
                          child: ListView.separated(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: controller.files.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, index) => _FileCard(
                              item: controller.files[index],
                              onOpen: () => _openFile(controller.files[index]),
                              onDelete: () async {
                                final item = controller.files[index];
                                final confirmed =
                                    await showAppConfirmationDialog(
                                  context: context,
                                  title: 'Delete this file?',
                                  message:
                                      '${item.name} will be permanently removed from this device.',
                                  confirmLabel: 'Delete',
                                  icon: Icons.delete_outline_rounded,
                                  destructive: true,
                                );
                                if (confirmed == true) {
                                  await controller.deleteFile(item);
                                }
                              },
                            ),
                          ),
                        ),
                ),
              ],
            );
          }),
        ),
      );

  void _openFile(DownloadedFile item) {
    const previewable = {
      'pdf',
      'jpg',
      'jpeg',
      'png',
      'webp',
      'gif',
      'txt',
      'csv',
      'log',
    };
    if (previewable.contains(item.extension)) {
      Get.to(() => _DownloadedFilePreview(item: item));
    } else {
      controller.openFile(item);
    }
  }
}

class _DownloadedFilePreview extends StatelessWidget {
  const _DownloadedFilePreview({required this.item});
  final DownloadedFile item;

  bool get _isImage =>
      const {'jpg', 'jpeg', 'png', 'webp', 'gif'}.contains(item.extension);
  bool get _isText => const {'txt', 'csv', 'log'}.contains(item.extension);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          actions: [
            IconButton(
              tooltip: 'Open with another app',
              onPressed: () => Get.find<DownloadsController>().openFile(item),
              icon: const Icon(Icons.open_in_new_rounded),
            ),
          ],
        ),
        body: _buildPreview(context),
      );

  Widget _buildPreview(BuildContext context) {
    if (item.extension == 'pdf') {
      return PdfViewer.file(
        item.file.path,
        params: PdfViewerParams(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        ),
      );
    }
    if (_isImage) {
      return ColoredBox(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        child: Center(
          child: InteractiveViewer(
            minScale: .5,
            maxScale: 5,
            child: Image.file(item.file, errorBuilder: _previewError),
          ),
        ),
      );
    }
    if (_isText) {
      return FutureBuilder<String>(
        future: item.file.readAsString(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _previewError(context, snapshot.error, null);
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: SelectableText(snapshot.data ?? ''),
          );
        },
      );
    }
    return _previewError(context, null, null);
  }

  Widget _previewError(
          BuildContext context, Object? error, StackTrace? stack) =>
      Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.broken_image_outlined,
                  size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 12),
              const Text('This file could not be previewed.'),
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: () => Get.find<DownloadsController>().openFile(item),
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Open with another app'),
              ),
            ],
          ),
        ),
      );
}

class _FileCard extends StatelessWidget {
  const _FileCard(
      {required this.item, required this.onOpen, required this.onDelete});
  final DownloadedFile item;
  final VoidCallback onOpen;
  final VoidCallback onDelete;

  IconData get _icon => switch (item.extension) {
        'pdf' => Icons.picture_as_pdf_outlined,
        'jpg' || 'jpeg' || 'png' || 'webp' => Icons.image_outlined,
        'doc' || 'docx' => Icons.description_outlined,
        'xls' || 'xlsx' || 'csv' => Icons.table_chart_outlined,
        'zip' || 'rar' || '7z' => Icons.folder_zip_outlined,
        _ => Icons.insert_drive_file_outlined,
      };

  String get _size {
    if (item.size < 1024) return '${item.size} B';
    if (item.size < 1024 * 1024) {
      return '${(item.size / 1024).toStringAsFixed(1)} KB';
    }
    return '${(item.size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get _date {
    final date = item.modified.toLocal();
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) => AppGlassSurface(
        child: InkWell(
          onTap: onOpen,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 6, 10),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_icon,
                      color:
                          Theme.of(context).colorScheme.onSecondaryContainer),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  )),
                      const SizedBox(height: 2),
                      Text('$_size · $_date',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: appSecondaryText(context),
                                  )),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'Delete file',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ],
            ),
          ),
        ),
      );
}

class _EmptyDownloads extends StatelessWidget {
  const _EmptyDownloads({required this.path});
  final String path;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.folder_open_rounded,
                  size: 58, color: Theme.of(context).colorScheme.primary),
              const SizedBox(height: 14),
              Text('No downloaded files yet',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      )),
              const SizedBox(height: 6),
              Text(
                  'Files downloaded through the in-app browser will appear here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: appSecondaryText(context))),
            ],
          ),
        ),
      );
}
