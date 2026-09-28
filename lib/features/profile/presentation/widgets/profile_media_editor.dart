import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

import 'package:apsaratalent_mobile/core/network/api_exception.dart';
import 'package:apsaratalent_mobile/core/themes/app_shape.dart';
import 'package:apsaratalent_mobile/core/utils/media_url.dart';
import 'package:apsaratalent_mobile/features/profile/domain/entities/user_profile.dart';
import 'package:apsaratalent_mobile/features/profile/domain/repositories/profile_repository.dart';
import 'package:apsaratalent_mobile/features/profile/providers/profile_notifier.dart';
import 'package:apsaratalent_mobile/shared/widgets/ui/ui.dart';

class ProfileMediaEditor extends ConsumerStatefulWidget {
  const ProfileMediaEditor({super.key, required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<ProfileMediaEditor> createState() => _ProfileMediaEditorState();
}

class _ProfileMediaEditorState extends ConsumerState<ProfileMediaEditor> {
  static const _imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  static const _documentExtensions = ['pdf', 'doc', 'docx'];
  static const _maxImageBytes = 5 * 1024 * 1024;
  static const _maxDocumentBytes = 10 * 1024 * 1024;

  String? _busy;

  bool _isBusy(String action) => _busy == action;

  @override
  Widget build(BuildContext context) => switch (widget.profile) {
        EmployeeProfile() => _employee(widget.profile as EmployeeProfile),
        CompanyProfile() => _company(widget.profile as CompanyProfile),
      };

  Widget _employee(EmployeeProfile profile) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle(
            title: 'Photo',
            subtitle: 'JPEG, PNG, GIF or WebP · up to 5 MB',
          ),
          _avatar(profile),
          const SectionTitle(
            title: 'Documents',
            subtitle: 'PDF or Word · up to 10 MB',
          ),
          _document(
            profile,
            type: EmployeeDocumentType.resume,
            title: 'Résumé',
            value: profile.resume,
          ),
          const SizedBox(height: AppShape.space3),
          _document(
            profile,
            type: EmployeeDocumentType.coverLetter,
            title: 'Cover letter',
            value: profile.coverLetter,
          ),
        ],
      );

  Widget _company(CompanyProfile profile) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle(
            title: 'Logo',
            subtitle: 'JPEG, PNG, GIF or WebP · up to 5 MB',
          ),
          _avatar(profile),
          const SectionTitle(title: 'Cover image'),
          _imageAsset(
            value: profile.coverUrl,
            emptyLabel: 'No cover image',
            uploadAction: 'cover-upload',
            removeAction: 'cover-remove',
            onUpload: (file) =>
                ref.read(profileProvider.notifier).uploadCompanyCover(file),
            onRemove: () =>
                ref.read(profileProvider.notifier).removeCompanyCover(),
          ),
          const SectionTitle(
            title: 'Company photos',
            subtitle: 'Choose up to 5 photos at a time',
          ),
          _gallery(profile),
        ],
      );

  Widget _avatar(UserProfile profile) => AppSurface(
        child: Row(
          children: [
            AppAvatar(
              name: profile.displayName,
              imageUrl: profile.avatarUrl,
              size: AppAvatarSize.xl,
            ),
            const SizedBox(width: AppShape.space4),
            Expanded(
              child: Wrap(
                spacing: AppShape.space2,
                runSpacing: AppShape.space2,
                children: [
                  AppButton(
                    label: profile.avatarUrl == null ? 'Add photo' : 'Replace',
                    size: AppButtonSize.sm,
                    loading: _isBusy('avatar-upload'),
                    onPressed: _busy == null
                        ? () => _pickOneImage(
                              action: 'avatar-upload',
                              upload: (file) => ref
                                  .read(profileProvider.notifier)
                                  .uploadAvatar(file),
                            )
                        : null,
                  ),
                  if (profile.avatarUrl != null)
                    AppButton(
                      label: 'Remove',
                      size: AppButtonSize.sm,
                      variant: AppButtonVariant.destructive,
                      loading: _isBusy('avatar-remove'),
                      onPressed: _busy == null
                          ? () => _confirmAndRun(
                                title: 'Remove profile photo?',
                                action: 'avatar-remove',
                                work: () => ref
                                    .read(profileProvider.notifier)
                                    .removeAvatar(),
                              )
                          : null,
                    ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _imageAsset({
    required String? value,
    required String emptyLabel,
    required String uploadAction,
    required String removeAction,
    required Future<void> Function(ProfileUpload) onUpload,
    required Future<void> Function() onRemove,
  }) =>
      AppSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 140,
              child: value == null
                  ? Center(child: Text(emptyLabel))
                  : Image.network(
                      resolveMediaUrl(value) ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Center(
                          child: Icon(Icons.broken_image_outlined)),
                    ),
            ),
            const SizedBox(height: AppShape.space3),
            Wrap(
              spacing: AppShape.space2,
              runSpacing: AppShape.space2,
              children: [
                AppButton(
                  label: value == null ? 'Add image' : 'Replace',
                  size: AppButtonSize.sm,
                  loading: _isBusy(uploadAction),
                  onPressed: _busy == null
                      ? () => _pickOneImage(
                            action: uploadAction,
                            upload: onUpload,
                          )
                      : null,
                ),
                if (value != null)
                  AppButton(
                    label: 'Remove',
                    size: AppButtonSize.sm,
                    variant: AppButtonVariant.destructive,
                    loading: _isBusy(removeAction),
                    onPressed: _busy == null
                        ? () => _confirmAndRun(
                              title: 'Remove cover image?',
                              action: removeAction,
                              work: onRemove,
                            )
                        : null,
                  ),
              ],
            ),
          ],
        ),
      );

  Widget _document(
    EmployeeProfile profile, {
    required EmployeeDocumentType type,
    required String title,
    required String? value,
  }) {
    final key = type.apiValue;
    return AppSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.description_outlined),
              const SizedBox(width: AppShape.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall),
                    Text(value == null ? 'Not uploaded' : _basename(value)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppShape.space3),
          Wrap(
            spacing: AppShape.space2,
            runSpacing: AppShape.space2,
            children: [
              AppButton(
                label: value == null ? 'Upload' : 'Replace',
                size: AppButtonSize.sm,
                loading: _isBusy('$key-upload'),
                onPressed: _busy == null ? () => _pickDocument(type) : null,
              ),
              if (value != null) ...[
                AppButton(
                  label: 'Open',
                  size: AppButtonSize.sm,
                  variant: AppButtonVariant.outline,
                  loading: _isBusy('$key-open'),
                  onPressed: _busy == null
                      ? () => _openDocument(profile.id, type, value)
                      : null,
                ),
                AppButton(
                  label: 'Remove',
                  size: AppButtonSize.sm,
                  variant: AppButtonVariant.destructive,
                  loading: _isBusy('$key-remove'),
                  onPressed: _busy == null
                      ? () => _confirmAndRun(
                            title: 'Remove $title?',
                            action: '$key-remove',
                            work: () => ref
                                .read(profileProvider.notifier)
                                .removeDocument(type),
                          )
                      : null,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _gallery(CompanyProfile profile) => AppSurface(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (profile.images.isEmpty)
              const Padding(
                padding: EdgeInsets.only(bottom: AppShape.space3),
                child: Text('No company photos yet.'),
              )
            else
              Padding(
                padding: const EdgeInsets.only(bottom: AppShape.space3),
                child: Wrap(
                  spacing: AppShape.space2,
                  runSpacing: AppShape.space2,
                  children: [
                    for (final image in profile.images)
                      Stack(
                        children: [
                          SizedBox(
                            width: 104,
                            height: 82,
                            child: Image.network(
                              resolveMediaUrl(image.url) ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.broken_image_outlined)),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            child: IconButton.filled(
                              tooltip: 'Remove photo',
                              iconSize: 18,
                              onPressed: _busy == null
                                  ? () => _confirmAndRun(
                                        title: 'Remove this company photo?',
                                        action: 'gallery-${image.id}',
                                        work: () => ref
                                            .read(profileProvider.notifier)
                                            .removeCompanyImage(image.id),
                                      )
                                  : null,
                              icon: _isBusy('gallery-${image.id}')
                                  ? const SizedBox.square(
                                      dimension: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.close),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            AppButton(
              label: 'Add company photos',
              size: AppButtonSize.sm,
              loading: _isBusy('gallery-upload'),
              onPressed: _busy == null ? _pickGallery : null,
            ),
          ],
        ),
      );

  Future<void> _pickOneImage({
    required String action,
    required Future<void> Function(ProfileUpload) upload,
  }) async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: _imageExtensions,
    );
    if (file == null) return;
    try {
      final selected = await _read(file, _maxImageBytes, 'Image');
      await _run(action, () => upload(selected), success: 'Image updated.');
    } on ApiException catch (error) {
      if (mounted) _snack(error.message);
    }
  }

  Future<void> _pickDocument(EmployeeDocumentType type) async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: _documentExtensions,
    );
    if (file == null) return;
    try {
      final selected = await _read(file, _maxDocumentBytes, 'Document');
      await _run(
        '${type.apiValue}-upload',
        () => ref.read(profileProvider.notifier).uploadDocument(type, selected),
        success: 'Document uploaded.',
      );
    } on ApiException catch (error) {
      if (mounted) _snack(error.message);
    }
  }

  Future<void> _pickGallery() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: _imageExtensions,
    );
    if (files.isEmpty) return;
    if (files.length > 5) {
      _snack('Choose no more than 5 photos at a time.');
      return;
    }
    try {
      final uploads = <ProfileUpload>[];
      for (final file in files) {
        uploads.add(await _read(file, _maxImageBytes, 'Each image'));
      }
      await _run(
        'gallery-upload',
        () => ref.read(profileProvider.notifier).uploadCompanyImages(uploads),
        success: 'Company photos added.',
      );
    } on ApiException catch (error) {
      if (mounted) _snack(error.message);
    }
  }

  Future<ProfileUpload> _read(
      PlatformFile file, int maxBytes, String label) async {
    try {
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty || bytes.length > maxBytes) {
        final mb = maxBytes ~/ (1024 * 1024);
        throw ApiException(message: '$label must be smaller than $mb MB.');
      }
      return ProfileUpload(filename: file.name, bytes: bytes);
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(message: '$label could not be read.');
    }
  }

  Future<void> _openDocument(
    String employeeId,
    EmployeeDocumentType type,
    String storedName,
  ) =>
      _run('${type.apiValue}-open', () async {
        final bytes = await ref
            .read(profileRepositoryProvider)
            .downloadEmployeeDocument(employeeId, type);
        final extension = _basename(storedName).split('.').last;
        final directory = await getTemporaryDirectory();
        final file = await File(
          '${directory.path}/${type.apiValue}.$extension',
        ).writeAsBytes(bytes, flush: true);
        final result = await OpenFilex.open(file.path);
        if (result.type != ResultType.done) {
          throw ApiException(message: 'No application could open this file.');
        }
      });

  Future<void> _confirmAndRun({
    required String title,
    required String action,
    required Future<void> Function() work,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: const Text('This removes the stored file from your profile.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await _run(action, work, success: 'File removed.');
    }
  }

  Future<void> _run(
    String action,
    Future<void> Function() work, {
    String? success,
  }) async {
    if (_busy != null) return;
    setState(() => _busy = action);
    try {
      await work();
      if (mounted && success != null) _snack(success);
    } on ApiException catch (error) {
      if (mounted) _snack(error.message);
    } catch (_) {
      if (mounted) _snack('The file operation could not be completed.');
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  String _basename(String value) {
    final path = Uri.tryParse(value)?.path ?? value;
    return path.split('/').last;
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}
