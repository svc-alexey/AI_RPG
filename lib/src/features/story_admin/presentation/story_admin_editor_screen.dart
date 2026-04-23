import 'dart:convert';
import 'dart:typed_data';

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

class _StoryAdminEditorScreenState
    extends ConsumerState<StoryAdminEditorScreen> {
  static const int _maxCoverBytes = 6 * 1024 * 1024;

  late final TextEditingController _titleController;
  late final TextEditingController _summaryController;
  late final TextEditingController _promptController;
  late final TextEditingController _characterPromptController;
  late final TextEditingController _campaignTitleController;
  late final TextEditingController _objectiveHintController;
  late final TextEditingController _characterNameController;
  late final TextEditingController _characterRaceController;
  late final TextEditingController _characterPersonalityController;
  late final TextEditingController _characterSkillsController;
  late final TextEditingController _characterPerksController;
  late final TextEditingController _tagsController;
  late final TextEditingController _metadataController;
  late CampaignSetting _campaignSetting;
  LiteraryGenre? _campaignLiteraryGenre;
  StoryMode? _storyMode;
  DifficultyLevel? _difficulty;
  CharacterGender _characterGender = CharacterGender.other;
  CharacterClass _characterClass = CharacterClass.unspecified;
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
    _characterPromptController = TextEditingController(
      text: e?.characterPrompt ?? e?.character?.promptFragment ?? '',
    );
    _campaignTitleController = TextEditingController(
      text: e?.campaignTitle ?? '',
    );
    _objectiveHintController = TextEditingController(
      text: e?.objectiveHint ?? '',
    );
    _characterNameController = TextEditingController(
      text: e?.character?.name ?? '',
    );
    _characterRaceController = TextEditingController(
      text: e?.character?.race ?? '',
    );
    _characterPersonalityController = TextEditingController(
      text: e?.character?.personality ?? '',
    );
    _characterSkillsController = TextEditingController(
      text: e == null ? '' : e.character?.skills.join(', ') ?? '',
    );
    _characterPerksController = TextEditingController(
      text: e == null ? '' : e.character?.perks.join(', ') ?? '',
    );
    _tagsController = TextEditingController(
      text: e == null ? '' : e.tags.join(', '),
    );
    _campaignSetting = parseCampaignSetting(e?.setting);
    _campaignLiteraryGenre = parseLiteraryGenre(e?.literaryGenre);
    _storyMode = e?.mode;
    _difficulty = e?.difficulty;
    _characterGender = e?.character?.gender ?? CharacterGender.other;
    _characterClass =
        e?.character?.characterClass ?? CharacterClass.unspecified;
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
    _characterPromptController.dispose();
    _campaignTitleController.dispose();
    _objectiveHintController.dispose();
    _characterNameController.dispose();
    _characterRaceController.dispose();
    _characterPersonalityController.dispose();
    _characterSkillsController.dispose();
    _characterPerksController.dispose();
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

  List<String> _parseCsv(final String raw) => raw
      .split(',')
      .map((final String s) => s.trim())
      .where((final String s) => s.isNotEmpty)
      .toList();

  Map<String, Object?>? _buildCharacterPayload() {
    final String name = _characterNameController.text.trim();
    final String race = _characterRaceController.text.trim();
    final String personality = _characterPersonalityController.text.trim();
    final String promptFragment = _characterPromptController.text.trim();
    final List<String> skills = _parseCsv(_characterSkillsController.text);
    final List<String> perks = _parseCsv(_characterPerksController.text);
    final bool hasAny =
        name.isNotEmpty ||
        race.isNotEmpty ||
        personality.isNotEmpty ||
        promptFragment.isNotEmpty ||
        skills.isNotEmpty ||
        perks.isNotEmpty ||
        _characterGender != CharacterGender.other ||
        _characterClass != CharacterClass.unspecified;
    if (!hasAny) {
      return null;
    }
    return <String, Object?>{
      'name': name,
      'gender': _characterGender.name,
      'race': race,
      'character_class': _characterClass.name,
      'personality': personality,
      'prompt_fragment': promptFragment,
      'skills': skills,
      'perks': perks,
    };
  }

  bool _hasAnyImportTargetValue() =>
      _titleController.text.trim().isNotEmpty ||
      _summaryController.text.trim().isNotEmpty ||
      _promptController.text.trim().isNotEmpty ||
      _characterPromptController.text.trim().isNotEmpty ||
      _campaignTitleController.text.trim().isNotEmpty ||
      _objectiveHintController.text.trim().isNotEmpty ||
      _characterNameController.text.trim().isNotEmpty ||
      _characterRaceController.text.trim().isNotEmpty ||
      _characterPersonalityController.text.trim().isNotEmpty ||
      _characterSkillsController.text.trim().isNotEmpty ||
      _characterPerksController.text.trim().isNotEmpty ||
      _tagsController.text.trim().isNotEmpty ||
      _storyMode != null ||
      _difficulty != null ||
      _campaignLiteraryGenre != null;

  Future<bool> _confirmImportOverwrite() async {
    if (!_hasAnyImportTargetValue()) {
      return true;
    }
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (final BuildContext context) => AlertDialog(
        title: Text(context.l10n.storyAdminImportOverwriteTitle),
        content: Text(context.l10n.storyAdminImportOverwriteBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.l10n.storyAdminImportApply),
          ),
        ],
      ),
    );
    return ok ?? false;
  }

  Future<void> _importJsonFile() async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: const <String>['json'],
      withData: true,
      allowMultiple: false,
    );
    if (result == null || result.files.isEmpty) {
      return;
    }
    final Uint8List? bytes = result.files.single.bytes;
    if (bytes == null) {
      return;
    }
    await _applyImportedJson(utf8.decode(bytes));
  }

  Future<void> _showPasteJsonDialog() async {
    final TextEditingController controller = TextEditingController();
    final String? raw = await showDialog<String>(
      context: context,
      builder: (final BuildContext context) => AlertDialog(
        title: Text(context.l10n.storyAdminImportPasteTitle),
        content: SizedBox(
          width: 640,
          child: TextField(
            controller: controller,
            minLines: 10,
            maxLines: 18,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontFamily: 'monospace'),
            decoration: InputDecoration(
              hintText: context.l10n.storyAdminImportPasteHint,
              alignLabelWithHint: true,
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: Text(context.l10n.storyAdminImportApply),
          ),
        ],
      ),
    );
    controller.dispose();
    if (raw == null || raw.trim().isEmpty) {
      return;
    }
    await _applyImportedJson(raw);
  }

  Future<void> _applyImportedJson(final String raw) async {
    late final Map<String, Object?> data;
    try {
      final Object? decoded = jsonDecode(raw);
      if (decoded is! Map<Object?, Object?>) {
        throw const FormatException('JSON root must be an object');
      }
      data = decoded.map(
        (final Object? key, final Object? value) =>
            MapEntry(key.toString(), _jsonToMetadataValue(value)),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(context.l10n.storyAdminImportInvalidJson)),
        );
      return;
    }
    if (!await _confirmImportOverwrite()) {
      return;
    }
    _fillFromImportedMap(data);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(context.l10n.storyAdminImportApplied)),
      );
  }

  void _fillFromImportedMap(final Map<String, Object?> data) {
    final Map<String, Object?>? metadata = _mapValue(data['metadata']);
    final Map<String, Object?> setup =
        _mapValue(data['campaign_setup']) ??
        _mapValue(metadata?['campaign_setup']) ??
        data;
    final Map<String, Object?>? character = _mapValue(
      setup['character'] ?? data['character'],
    );
    final List<String> tags = _stringListValue(data['tags']);

    setState(() {
      _setText(_titleController, _stringValue(data['title']));
      _setText(_summaryController, _stringValue(data['summary']));
      _setText(
        _promptController,
        _stringValue(
          setup['story_prompt'] ??
              setup['storyPrompt'] ??
              data['prompt_text'] ??
              data['promptText'],
        ),
      );
      _setText(
        _characterPromptController,
        _stringValue(
          setup['character_prompt'] ??
              setup['characterPrompt'] ??
              character?['prompt_fragment'] ??
              character?['promptFragment'],
        ),
      );
      _setText(
        _campaignTitleController,
        _stringValue(setup['campaign_title'] ?? setup['campaignTitle']),
      );
      _setText(
        _objectiveHintController,
        _stringValue(setup['objective_hint'] ?? setup['objectiveHint']),
      );
      _setText(_tagsController, tags.isEmpty ? '' : tags.join(', '));

      final CampaignSetting? setting = _parseCampaignSettingOrNull(
        _stringValue(setup['setting'] ?? data['setting']),
      );
      if (setting != null) {
        _campaignSetting = setting;
      }
      _campaignLiteraryGenre =
          parseLiteraryGenre(
            _stringValue(setup['literary_genre'] ?? setup['literaryGenre']),
          ) ??
          _campaignLiteraryGenre;
      _storyMode = _parseStoryMode(_stringValue(setup['mode'])) ?? _storyMode;
      _difficulty =
          _parseDifficulty(_stringValue(setup['difficulty'])) ?? _difficulty;
      final String genreSlug = _stringValue(
        data['literary_genre_slug'] ?? data['literaryGenreSlug'],
      );
      if (genreSlug.isNotEmpty) {
        _literaryGenreSlug = genreSlug;
        _literaryGenres = _mergeOrphanGenreSlug(_literaryGenres);
      }
      if (character != null) {
        _setText(_characterNameController, _stringValue(character['name']));
        _setText(_characterRaceController, _stringValue(character['race']));
        _setText(
          _characterPersonalityController,
          _stringValue(character['personality']),
        );
        _setText(
          _characterSkillsController,
          _stringListValue(character['skills']).join(', '),
        );
        _setText(
          _characterPerksController,
          _stringListValue(character['perks']).join(', '),
        );
        _characterGender =
            _parseGender(_stringValue(character['gender'])) ?? _characterGender;
        _characterClass =
            _parseCharacterClass(
              _stringValue(
                character['character_class'] ?? character['characterClass'],
              ),
            ) ??
            _characterClass;
      }
    });
  }

  static void _setText(
    final TextEditingController controller,
    final String value,
  ) {
    if (value.trim().isNotEmpty) {
      controller.text = value.trim();
    }
  }

  static String _stringValue(final Object? value) {
    if (value == null) {
      return '';
    }
    return value.toString().trim();
  }

  static Map<String, Object?>? _mapValue(final Object? value) {
    if (value is Map<String, Object?>) {
      return value;
    }
    if (value is Map<Object?, Object?>) {
      return value.map(
        (final key, final item) => MapEntry(key.toString(), item),
      );
    }
    return null;
  }

  static List<String> _stringListValue(final Object? value) {
    if (value is List<Object?>) {
      return value
          .map((final Object? item) => item.toString().trim())
          .where((final String item) => item.isNotEmpty)
          .toList();
    }
    if (value is String && value.trim().isNotEmpty) {
      return value
          .split(',')
          .map((final String item) => item.trim())
          .where((final String item) => item.isNotEmpty)
          .toList();
    }
    return const <String>[];
  }

  static CampaignSetting? _parseCampaignSettingOrNull(final String raw) {
    for (final CampaignSetting item in CampaignSetting.values) {
      if (item.name == raw) {
        return item;
      }
    }
    return null;
  }

  static StoryMode? _parseStoryMode(final String raw) {
    for (final StoryMode item in StoryMode.values) {
      if (item.name == raw) {
        return item;
      }
    }
    return null;
  }

  static DifficultyLevel? _parseDifficulty(final String raw) {
    for (final DifficultyLevel item in DifficultyLevel.values) {
      if (item.name == raw) {
        return item;
      }
    }
    return null;
  }

  static CharacterGender? _parseGender(final String raw) {
    for (final CharacterGender item in CharacterGender.values) {
      if (item.name == raw) {
        return item;
      }
    }
    return null;
  }

  static CharacterClass? _parseCharacterClass(final String raw) {
    for (final CharacterClass item in CharacterClass.values) {
      if (item.name == raw) {
        return item;
      }
    }
    return null;
  }

  Future<void> _save() async {
    final AppLocalizations l10n = context.l10n;
    final String title = _resolvedTitleForSave(l10n);
    final String prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.storyAdminFillPrompt)));
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
        'literary_genre': _campaignLiteraryGenre?.name,
        'mode': _storyMode?.name,
        'difficulty': _difficulty?.name,
        'story_prompt': prompt,
        'character_prompt': _characterPromptController.text.trim(),
        'campaign_title': _campaignTitleController.text.trim(),
        'objective_hint': _objectiveHintController.text.trim(),
        if (_buildCharacterPayload() != null)
          'character': _buildCharacterPayload(),
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
        await ref
            .read(storyLibraryRepositoryProvider)
            .uploadStoryTemplateCover(
              templateId: templateId,
              bytes: _pickedCoverBytes!,
              contentType: _pickedCoverMime ?? 'image/jpeg',
            );
      } else if (_removeServerCover && widget.existing != null) {
        await ref
            .read(storyLibraryRepositoryProvider)
            .deleteStoryTemplateCover(templateId);
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

  String _resolvedTitleForSave(final AppLocalizations l10n) {
    final String explicit = _titleController.text.trim();
    if (explicit.isNotEmpty) {
      return explicit;
    }
    final String campaignTitle = _campaignTitleController.text.trim();
    if (campaignTitle.isNotEmpty) {
      return campaignTitle;
    }
    final String prompt = _promptController.text.trim();
    if (prompt.isEmpty) {
      return l10n.storyTemplateSelectedFallbackTitle;
    }
    final String firstPhrase = prompt.split(RegExp(r'[.!?\n]')).first.trim();
    if (firstPhrase.isEmpty) {
      return l10n.storyTemplateSelectedFallbackTitle;
    }
    final List<String> words = firstPhrase
        .split(RegExp(r'\s+'))
        .take(4)
        .toList();
    return words.join(' ');
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
          child: Image.memory(_pickedCoverBytes!, fit: BoxFit.cover),
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
    final bool showPreview =
        _pickedCoverBytes != null ||
        (!_removeServerCover &&
            widget.existing != null &&
            (widget.existing!.coverImageHref != null &&
                    widget.existing!.coverImageHref!.trim().isNotEmpty ||
                widget.existing!.coverImageUrlFromMetadata != null));
    final SymmetrySession? symForCover = ref
        .watch(symmetrySessionProvider)
        .value;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(isEdit ? l10n.storyAdminEdit : l10n.storyAdminCreate),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: responsive.dialogMaxWidth),
          child: ListView(
              padding: EdgeInsets.all(responsive.pagePadding),
              children: <Widget>[
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: <Widget>[
                    OutlinedButton.icon(
                      onPressed: _isSaving ? null : _importJsonFile,
                      icon: const Icon(Icons.upload_file_outlined),
                      label: Text(l10n.storyAdminImportFile),
                    ),
                    OutlinedButton.icon(
                      onPressed: _isSaving ? null : _showPasteJsonDialog,
                      icon: const Icon(Icons.content_paste_rounded),
                      label: Text(l10n.storyAdminImportPaste),
                    ),
                  ],
                ),
                SizedBox(height: responsive.sectionSpacing),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: l10n.storyAdminFieldTitle,
                  ),
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
                TextField(
                  controller: _campaignTitleController,
                  decoration: InputDecoration(
                    labelText: l10n.storyAdminFieldCampaignTitle,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                SizedBox(height: responsive.blockSpacing),
                TextField(
                  controller: _objectiveHintController,
                  decoration: InputDecoration(
                    labelText: l10n.storyAdminFieldObjectiveHint,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                SizedBox(height: responsive.blockSpacing),
                DropdownButtonFormField<StoryMode?>(
                  initialValue: _storyMode,
                  decoration: InputDecoration(labelText: l10n.storyModeTitle),
                  items: <DropdownMenuItem<StoryMode?>>[
                    DropdownMenuItem<StoryMode?>(
                      value: null,
                      child: Text(l10n.storyAdminOptionalNone),
                    ),
                    ...StoryMode.values.map(
                      (final StoryMode value) => DropdownMenuItem<StoryMode?>(
                        value: value,
                        child: Text(l10n.storyModeLabel(value)),
                      ),
                    ),
                  ],
                  onChanged: (final StoryMode? v) =>
                      setState(() => _storyMode = v),
                ),
                SizedBox(height: responsive.blockSpacing),
                DropdownButtonFormField<DifficultyLevel?>(
                  initialValue: _difficulty,
                  decoration: InputDecoration(labelText: l10n.difficultyTitle),
                  items: <DropdownMenuItem<DifficultyLevel?>>[
                    DropdownMenuItem<DifficultyLevel?>(
                      value: null,
                      child: Text(l10n.storyAdminOptionalNone),
                    ),
                    ...DifficultyLevel.values.map(
                      (final DifficultyLevel value) =>
                          DropdownMenuItem<DifficultyLevel?>(
                            value: value,
                            child: Text(l10n.difficultyLabel(value)),
                          ),
                    ),
                  ],
                  onChanged: (final DifficultyLevel? v) =>
                      setState(() => _difficulty = v),
                ),
                SizedBox(height: responsive.blockSpacing),
                DropdownButtonFormField<LiteraryGenre?>(
                  initialValue: _campaignLiteraryGenre,
                  decoration: InputDecoration(
                    labelText: l10n.literaryGenreTitle,
                  ),
                  items: <DropdownMenuItem<LiteraryGenre?>>[
                    DropdownMenuItem<LiteraryGenre?>(
                      value: null,
                      child: Text(l10n.storyAdminOptionalNone),
                    ),
                    ...LiteraryGenre.values.map(
                      (final LiteraryGenre value) =>
                          DropdownMenuItem<LiteraryGenre?>(
                            value: value,
                            child: Text(l10n.literaryGenreLabel(value)),
                          ),
                    ),
                  ],
                  onChanged: (final LiteraryGenre? v) =>
                      setState(() => _campaignLiteraryGenre = v),
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
                  controller: _characterPromptController,
                  decoration: InputDecoration(
                    labelText: l10n.storyAdminFieldCharacterPrompt,
                  ),
                  minLines: 2,
                  maxLines: 8,
                ),
                SizedBox(height: responsive.blockSpacing),
                TextField(
                  controller: _characterNameController,
                  decoration: InputDecoration(
                    labelText: l10n.storyAdminFieldCharacterName,
                  ),
                  textCapitalization: TextCapitalization.words,
                ),
                SizedBox(height: responsive.blockSpacing),
                DropdownButtonFormField<CharacterGender>(
                  initialValue: _characterGender,
                  decoration: InputDecoration(
                    labelText: l10n.storyAdminFieldCharacterGender,
                  ),
                  items: CharacterGender.values
                      .map(
                        (final CharacterGender value) =>
                            DropdownMenuItem<CharacterGender>(
                              value: value,
                              child: Text(value.name),
                            ),
                      )
                      .toList(),
                  onChanged: (final CharacterGender? v) {
                    if (v != null) {
                      setState(() => _characterGender = v);
                    }
                  },
                ),
                SizedBox(height: responsive.blockSpacing),
                TextField(
                  controller: _characterRaceController,
                  decoration: InputDecoration(
                    labelText: l10n.storyAdminFieldCharacterRace,
                  ),
                ),
                SizedBox(height: responsive.blockSpacing),
                DropdownButtonFormField<CharacterClass>(
                  initialValue: _characterClass,
                  decoration: InputDecoration(
                    labelText: l10n.storyAdminFieldCharacterClass,
                  ),
                  items: CharacterClass.values
                      .map(
                        (final CharacterClass value) =>
                            DropdownMenuItem<CharacterClass>(
                              value: value,
                              child: Text(value.name),
                            ),
                      )
                      .toList(),
                  onChanged: (final CharacterClass? v) {
                    if (v != null) {
                      setState(() => _characterClass = v);
                    }
                  },
                ),
                SizedBox(height: responsive.blockSpacing),
                TextField(
                  controller: _characterPersonalityController,
                  decoration: InputDecoration(
                    labelText: l10n.storyAdminFieldCharacterPersonality,
                  ),
                  minLines: 1,
                  maxLines: 4,
                ),
                SizedBox(height: responsive.blockSpacing),
                TextField(
                  controller: _characterSkillsController,
                  decoration: InputDecoration(
                    labelText: l10n.storyAdminFieldCharacterSkills,
                  ),
                ),
                SizedBox(height: responsive.blockSpacing),
                TextField(
                  controller: _characterPerksController,
                  decoration: InputDecoration(
                    labelText: l10n.storyAdminFieldCharacterPerks,
                  ),
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
                          (widget.existing != null &&
                              !_removeServerCover &&
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
    );
  }
}
