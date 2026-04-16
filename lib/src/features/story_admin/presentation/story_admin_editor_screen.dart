import 'dart:convert';
import 'dart:typed_data';

import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/core/models/app_language.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/models/literary_genre_model.dart';
import 'package:ai_prg/src/core/models/story_template_model.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/features/story_library/presentation/widgets/authenticated_cover_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoryAdminEditorScreen extends ConsumerStatefulWidget {
  const StoryAdminEditorScreen({super.key, this.existing});

  final StoryTemplate? existing;

  @override
  ConsumerState<StoryAdminEditorScreen> createState() =>
      _StoryAdminEditorScreenState();
}

class _StoryAdminEditorScreenState extends ConsumerState<StoryAdminEditorScreen> {
  static const int _maxCoverBytes = 6 * 1024 * 1024;

  late final TextEditingController _titleController;
  late final TextEditingController _summaryController;
  late final TextEditingController _promptController;
  late final TextEditingController _tagsController;
  late final TextEditingController _metadataController;
  late CampaignSetting _campaignSetting;
  String? _literaryGenreSlug;
  bool _isPublic = true;
  bool _isMasterCurated = false;
  bool _isSaving = false;
  List<LiteraryGenreCatalogItem> _literaryGenres =
      const <LiteraryGenreCatalogItem>[];
  Uint8List? _pickedCoverBytes;
  String? _pickedCoverMime;
  bool _removeServerCover = false;

  static String _metadataToJson(final Map<String, Object?> metadata) {
    const JsonEncoder encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(metadata);
  }

  static Map<String, Object?> _metadataWithoutCover(
    final Map<String, Object?> metadata,
  ) {
    final Map<String, Object?> out = Map<String, Object?>.from(metadata);
    out.remove('cover_image_url');
    return out;
  }

  static String _mimeFromExtension(final String? ext) {
    final String e = (ext ?? '').toLowerCase().trim();
    if (e == 'png') {
      return 'image/png';
    }
    if (e == 'webp') {
      return 'image/webp';
    }
    if (e == 'gif') {
      return 'image/gif';
    }
    return 'image/jpeg';
  }

  @override
  void initState() {
    super.initState();
    final StoryTemplate? e = widget.existing;
    _titleController = TextEditingController(text: e?.title ?? '');
    _summaryController = TextEditingController(text: e?.summary ?? '');
    _promptController = TextEditingController(text: e?.promptText ?? '');
    _tagsController = TextEditingController(
      text: e == null ? '' : e.tags.join(', '),
    );
    _campaignSetting = parseCampaignSetting(e?.setting);
    _literaryGenreSlug = e?.literaryGenreSlug;
    _metadataController = TextEditingController(
      text: e == null
          ? '{}'
          : _metadataToJson(_metadataWithoutCover(e.metadata)),
    );
    _isPublic = e?.isPublic ?? true;
    _isMasterCurated = e?.isMasterCurated ?? false;
    WidgetsBinding.instance.addPostFrameCallback((final Duration _) {
      _loadLiteraryGenres();
    });
  }

  Future<void> _loadLiteraryGenres() async {
    try {
      final List<LiteraryGenreCatalogItem> rows = await ref
          .read(storyLibraryRepositoryProvider)
          .loadLiteraryGenres();
      if (!mounted) {
        return;
      }
      setState(() {
        _literaryGenres = _mergeOrphanGenreSlug(rows);
      });
    } catch (_) {
      // Editor still works without catalog.
    }
  }

  List<LiteraryGenreCatalogItem> _mergeOrphanGenreSlug(
    final List<LiteraryGenreCatalogItem> rows,
  ) {
    final String? slug = _literaryGenreSlug;
    if (slug == null || slug.isEmpty) {
      return rows;
    }
    if (rows.any((final g) => g.slug == slug)) {
      return rows;
    }
    return <LiteraryGenreCatalogItem>[
      ...rows,
      LiteraryGenreCatalogItem(
        slug: slug,
        titleEn: slug,
        titleRu: slug,
        sortOrder: 9999,
      ),
    ];
  }

  Future<void> _pickCoverFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) {
      return;
    }
    final PlatformFile f = result.files.single;
    final Uint8List? bytes = f.bytes;
    if (bytes == null) {
      return;
    }
    if (bytes.length > _maxCoverBytes) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.storyAdminCoverTooLarge)),
        );
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _pickedCoverBytes = bytes;
      _pickedCoverMime = _mimeFromExtension(f.extension);
      _removeServerCover = false;
    });
  }

  void _clearCoverChoice() {
    setState(() {
      _pickedCoverBytes = null;
      _pickedCoverMime = null;
      if (widget.existing != null &&
          (widget.existing!.coverImageHref != null &&
                  widget.existing!.coverImageHref!.trim().isNotEmpty ||
              widget.existing!.coverImageUrlFromMetadata != null)) {
        _removeServerCover = true;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _promptController.dispose();
    _tagsController.dispose();
    _metadataController.dispose();
    super.dispose();
  }

  List<String> _parseTags() {
    return _tagsController.text
        .split(',')
        .map((final String s) => s.trim())
        .where((final String s) => s.isNotEmpty)
        .toList();
  }

  Future<void> _save() async {
    final AppLocalizations l10n = context.l10n;
    final String title = _titleController.text.trim();
    final String prompt = _promptController.text.trim();
    if (title.isEmpty || prompt.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.storyAdminFillTitlePrompt)),
        );
      return;
    }
    late final Map<String, Object?> metadata;
    try {
      final Object? decoded = jsonDecode(_metadataController.text);
      if (decoded is! Map<Object?, Object?>) {
        throw FormatException(l10n.storyAdminInvalidMetadata);
      }
      metadata = decoded.map(
        (final Object? key, final Object? value) =>
            MapEntry(key.toString(), _jsonToMetadataValue(value)),
      );
    } catch (_) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.storyAdminInvalidMetadata)));
      return;
    }
    metadata.remove('cover_image_url');
    setState(() => _isSaving = true);
    bool didPop = false;
    try {
      final Map<String, Object?> payload = <String, Object?>{
        'title': title,
        'summary': _summaryController.text.trim(),
        'prompt_text': prompt,
        'setting': _campaignSetting.name,
        'literary_genre_slug': _literaryGenreSlug,
        'tags': _parseTags(),
        'is_public': _isPublic,
        'is_master_curated': _isMasterCurated,
        'metadata': metadata,
      };
      final StoryTemplate saved = await ref
          .read(storyLibraryRepositoryProvider)
          .saveStoryTemplateAdmin(
            payload: payload,
            templateId: widget.existing?.id,
          );
      final String templateId = saved.id;
      if (_pickedCoverBytes != null) {
        await ref.read(storyLibraryRepositoryProvider).uploadStoryTemplateCover(
          templateId: templateId,
          bytes: _pickedCoverBytes!,
          contentType: _pickedCoverMime ?? 'image/jpeg',
        );
      } else if (_removeServerCover && widget.existing != null) {
        await ref.read(storyLibraryRepositoryProvider).deleteStoryTemplateCover(
          templateId,
        );
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.storyAdminSaved)));
      Navigator.of(context).pop(true);
      didPop = true;
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10n.symmetryFriendlyError(error))),
        );
    } finally {
      if (mounted && !didPop) {
        setState(() => _isSaving = false);
      }
    }
  }

  static Object? _jsonToMetadataValue(final Object? value) {
    if (value is Map<Object?, Object?>) {
      return value.map(
        (final Object? k, final Object? v) =>
            MapEntry(k.toString(), _jsonToMetadataValue(v)),
      );
    }
    if (value is List<Object?>) {
      return value.map(_jsonToMetadataValue).toList();
    }
    return value;
  }

  Widget _buildCoverPreview(
    final ThemeData theme,
    final SymmetrySession? symSession,
  ) {
    if (_pickedCoverBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.memory(
            _pickedCoverBytes!,
            fit: BoxFit.cover,
          ),
        ),
      );
    }
    if (_removeServerCover) {
      return const SizedBox.shrink();
    }
    final StoryTemplate? e = widget.existing;
    if (e == null) {
      return const SizedBox.shrink();
    }
    final String base = symSession?.baseUrl ?? '';
    final String? url = base.isNotEmpty
        ? e.resolveCoverDisplayUrl(symmetryBaseUrl: base)
        : e.coverImageUrlFromMetadata;
    if (url == null || url.isEmpty) {
      return const SizedBox.shrink();
    }
    final Map<String, String>? headers =
        symSession != null &&
            symSession.tokens.accessToken.trim().isNotEmpty &&
            base.isNotEmpty &&
            url.startsWith(base)
        ? <String, String>{
            'Authorization': 'Bearer ${symSession.tokens.accessToken}',
          }
        : null;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: AuthenticatedCoverImage(
          imageUrl: url,
          requestHeaders: headers,
          fit: BoxFit.cover,
          errorBuilder: (final _, final __, final ___) => ColoredBox(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: theme.colorScheme.outline,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = context.l10n;
    final AppResponsiveData responsive = context.responsive;
    final bool isEdit = widget.existing != null;
    final bool ru = l10n.language == AppLanguage.ru;
    final bool showPreview = _pickedCoverBytes != null ||
        (!_removeServerCover &&
            widget.existing != null &&
            (widget.existing!.coverImageHref != null &&
                    widget.existing!.coverImageHref!.trim().isNotEmpty ||
                widget.existing!.coverImageUrlFromMetadata != null));
    final SymmetrySession? symForCover =
        ref.watch(symmetrySessionProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? l10n.storyAdminEdit : l10n.storyAdminCreate),
      ),
      body: AetherBackdrop(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: responsive.dialogMaxWidth),
            child: ListView(
              padding: EdgeInsets.all(responsive.pagePadding),
              children: <Widget>[
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(labelText: l10n.storyAdminFieldTitle),
                  textCapitalization: TextCapitalization.sentences,
                ),
                SizedBox(height: responsive.blockSpacing),
                TextField(
                  controller: _summaryController,
                  decoration: InputDecoration(
                    labelText: l10n.storyAdminFieldSummary,
                  ),
                  minLines: 2,
                  maxLines: 6,
                ),
                SizedBox(height: responsive.blockSpacing),
                TextField(
                  controller: _promptController,
                  decoration: InputDecoration(
                    labelText: l10n.storyAdminFieldPrompt,
                  ),
                  minLines: 4,
                  maxLines: 12,
                ),
                SizedBox(height: responsive.blockSpacing),
                DropdownButtonFormField<String?>(
                  initialValue: _literaryGenreSlug,
                  decoration: InputDecoration(
                    labelText: l10n.storyAdminFieldLiteraryGenre,
                  ),
                  items: <DropdownMenuItem<String?>>[
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(l10n.storyAdminLiteraryGenreNone),
                    ),
                    ..._literaryGenres.map(
                      (final g) => DropdownMenuItem<String?>(
                        value: g.slug,
                        child: Text(g.labelForLocale(isRussian: ru)),
                      ),
                    ),
                  ],
                  onChanged: (final String? v) =>
                      setState(() => _literaryGenreSlug = v),
                ),
                SizedBox(height: responsive.blockSpacing),
                DropdownButtonFormField<CampaignSetting>(
                  initialValue: _campaignSetting,
                  decoration: InputDecoration(
                    labelText: l10n.storyAdminFieldSetting,
                  ),
                  items: CampaignSetting.values
                      .map(
                        (final CampaignSetting s) =>
                            DropdownMenuItem<CampaignSetting>(
                          value: s,
                          child: Text(l10n.settingLabel(s)),
                        ),
                      )
                      .toList(),
                  onChanged: (final CampaignSetting? v) {
                    if (v != null) {
                      setState(() => _campaignSetting = v);
                    }
                  },
                ),
                SizedBox(height: responsive.blockSpacing),
                TextField(
                  controller: _tagsController,
                  decoration: InputDecoration(
                    labelText: l10n.storyAdminFieldTags,
                  ),
                  autocorrect: false,
                ),
                SizedBox(height: responsive.blockSpacing),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: <Widget>[
                      OutlinedButton.icon(
                        onPressed: _isSaving ? null : _pickCoverFile,
                        icon: const Icon(Icons.image_outlined),
                        label: Text(l10n.storyAdminCoverChooseFile),
                      ),
                      if (_pickedCoverBytes != null ||
                          (widget.existing != null && !_removeServerCover &&
                              (widget.existing!.coverImageHref != null &&
                                      widget.existing!.coverImageHref!
                                          .trim()
                                          .isNotEmpty ||
                                  widget.existing!.coverImageUrlFromMetadata !=
                                      null)))
                        TextButton(
                          onPressed: _isSaving ? null : _clearCoverChoice,
                          child: Text(l10n.storyAdminCoverRemove),
                        ),
                    ],
                  ),
                ),
                if (showPreview) ...<Widget>[
                  SizedBox(height: responsive.blockSpacing),
                  _buildCoverPreview(theme, symForCover),
                ],
                SizedBox(height: responsive.blockSpacing),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.storyAdminPublic),
                  value: _isPublic,
                  onChanged: (final bool v) => setState(() => _isPublic = v),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.storyAdminMasterCurated),
                  value: _isMasterCurated,
                  onChanged: (final bool v) =>
                      setState(() => _isMasterCurated = v),
                ),
                SizedBox(height: responsive.blockSpacing),
                TextField(
                  controller: _metadataController,
                  decoration: InputDecoration(
                    labelText: l10n.storyAdminMetadataJson,
                    alignLabelWithHint: true,
                  ),
                  minLines: 6,
                  maxLines: 18,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                  ),
                  autocorrect: false,
                ),
                SizedBox(height: responsive.sectionSpacing),
                FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.storyAdminSave),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
