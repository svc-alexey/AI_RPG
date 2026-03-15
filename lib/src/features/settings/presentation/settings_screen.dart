import 'dart:convert';

import 'package:ai_prg/src/app/app_scope.dart';
import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _baseUrlController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _timeoutController = TextEditingController();

  AiProviderType _provider = AiProviderType.lmStudio;
  bool _fastResponses = true;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isChecking = false;
  bool _isDetectingModel = false;
  bool _didLoad = false;
  String? _status;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didLoad) {
      return;
    }
    _didLoad = true;
    _load();
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _modelController.dispose();
    _apiKeyController.dispose();
    _timeoutController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Настройки ИИ')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 880),
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: <Widget>[
                    Text(
                      'LM Studio и OpenAI-compatible endpoint',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Для LM Studio по умолчанию используется http://127.0.0.1:1234/v1. Если локальный сервер LM Studio запущен, приложение само подберет подходящую загруженную модель.',
                    ),
                    const SizedBox(height: 24),
                    SegmentedButton<AiProviderType>(
                      segments: const <ButtonSegment<AiProviderType>>[
                        ButtonSegment<AiProviderType>(
                          value: AiProviderType.lmStudio,
                          label: Text('LM Studio'),
                        ),
                        ButtonSegment<AiProviderType>(
                          value: AiProviderType.openAiCompatible,
                          label: Text('Совместимый с OpenAI'),
                        ),
                      ],
                      selected: <AiProviderType>{_provider},
                      onSelectionChanged: (final Set<AiProviderType> selection) {
                        _handleProviderChanged(selection.first);
                      },
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _baseUrlController,
                      decoration: const InputDecoration(
                        labelText: 'Базовый URL',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _modelController,
                      decoration: const InputDecoration(labelText: 'Модель'),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _apiKeyController,
                      decoration: const InputDecoration(
                        labelText: 'API-ключ',
                        hintText: 'Для LM Studio обычно не нужен',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _timeoutController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Таймаут в секундах',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Быстрый режим LM Studio'),
                      subtitle: const Text(
                        'Добавляет /no_think и строгий JSON-формат для более быстрых ответов.',
                      ),
                      value: _fastResponses,
                      onChanged: (final bool value) {
                        setState(() => _fastResponses = value);
                      },
                    ),
                    const SizedBox(height: 20),
                    if (_status != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _status!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: <Widget>[
                        FilledButton(
                          onPressed: _isSaving ? null : _save,
                          child: _isSaving
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Сохранить настройки'),
                        ),
                        OutlinedButton(
                          onPressed: _isChecking ? null : _checkConnection,
                          child: _isChecking
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Проверить подключение'),
                        ),
                        TextButton(
                          onPressed: _isDetectingModel
                              ? null
                              : _detectAndApplyLmStudioModel,
                          child: _isDetectingModel
                              ? const Text('Подбираю модель...')
                              : const Text('Подобрать модель автоматически'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _load() async {
    final AppScope scope = AppScope.of(context);
    final AiSettings settings = await scope.settingsRepository.loadAiSettings();

    _provider = settings.provider;
    _fastResponses = settings.fastResponses;
    _baseUrlController.text =
        settings.baseUrl.trim().isEmpty &&
            settings.provider == AiProviderType.lmStudio
        ? const AiSettings.defaults().baseUrl
        : settings.baseUrl;
    _modelController.text = settings.model;
    _apiKeyController.text = settings.apiKey;
    _timeoutController.text = settings.timeoutSeconds.toString();

    setState(() => _isLoading = false);

    if (_provider == AiProviderType.lmStudio) {
      await _detectAndApplyLmStudioModel(silentWhenUnavailable: true);
    }
  }

  Future<void> _save() async {
    setState(() {
      _isSaving = true;
      _status = null;
    });

    final AppScope scope = AppScope.of(context);
    await scope.settingsRepository.saveAiSettings(_buildSettings());

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
      _status = 'Настройки сохранены.';
    });
  }

  Future<void> _checkConnection() async {
    setState(() {
      _isChecking = true;
      _status = null;
    });

    try {
      final AppScope scope = AppScope.of(context);
      final client = scope.aiServiceFactory.create(_buildSettings());
      await client.checkConnection(settings: _buildSettings());
      if (!mounted) {
        return;
      }
      setState(() => _status = 'Подключение успешно.');
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _status = 'Не удалось подключиться: $error');
    } finally {
      if (mounted) {
        setState(() => _isChecking = false);
      }
    }
  }

  AiSettings _buildSettings() {
    return AiSettings(
      provider: _provider,
      baseUrl: _baseUrlController.text.trim(),
      model: _modelController.text.trim(),
      apiKey: _apiKeyController.text.trim(),
      timeoutSeconds: int.tryParse(_timeoutController.text.trim()) ?? 60,
      fastResponses: _fastResponses,
    );
  }

  Future<void> _handleProviderChanged(final AiProviderType provider) async {
    setState(() {
      _provider = provider;
      _status = null;
      if (provider == AiProviderType.lmStudio &&
          _baseUrlController.text.trim().isEmpty) {
        _baseUrlController.text = const AiSettings.defaults().baseUrl;
      }
      if (provider != AiProviderType.lmStudio) {
        _fastResponses = false;
      } else if (!_fastResponses) {
        _fastResponses = true;
      }
    });

    if (provider == AiProviderType.lmStudio) {
      await _detectAndApplyLmStudioModel(silentWhenUnavailable: true);
    }
  }

  Future<void> _detectAndApplyLmStudioModel({
    final bool silentWhenUnavailable = false,
  }) async {
    if (_provider != AiProviderType.lmStudio) {
      return;
    }

    setState(() {
      _isDetectingModel = true;
      if (!silentWhenUnavailable) {
        _status = null;
      }
    });

    final String baseUrl = _baseUrlController.text.trim().isEmpty
        ? const AiSettings.defaults().baseUrl
        : _baseUrlController.text.trim();

    try {
      final List<String> modelIds = await _fetchModelIds(baseUrl);
      final String modelId = _selectPreferredModel(modelIds);
      if (modelId.isEmpty) {
        if (!silentWhenUnavailable && mounted) {
          setState(() {
            _status =
                'LM Studio ответил, но подходящая модель не найдена.';
          });
        }
        return;
      }

      _baseUrlController.text = baseUrl;
      _modelController.text = modelId;

      final AppScope scope = AppScope.of(context);
      await scope.settingsRepository.saveAiSettings(_buildSettings());

      if (!mounted) {
        return;
      }

      setState(() {
        _status = 'Автоматически выбрана модель LM Studio: $modelId';
      });
    } catch (error) {
      if (!mounted || silentWhenUnavailable) {
        return;
      }
      setState(() {
        _status =
            'Не удалось автоматически определить модель LM Studio. Убедись, что локальный сервер запущен: $error';
      });
    } finally {
      if (mounted) {
        setState(() => _isDetectingModel = false);
      }
    }
  }

  Future<List<String>> _fetchModelIds(final String baseUrl) async {
    final Uri uri = Uri.parse('${_normalizeBaseUrl(baseUrl)}/models');
    final http.Response response = await http
        .get(
          uri,
          headers: const <String, String>{'Content-Type': 'application/json'},
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('сервер вернул ${response.statusCode}');
    }

    final Object? decoded = jsonDecode(response.body);
    if (decoded is! Map<String, Object?>) {
      throw Exception('неожиданный формат ответа');
    }

    final List<Object?> items =
        (decoded['data'] as List<Object?>?) ?? const <Object?>[];

    return items
        .map((final Object? item) => item as Map<String, Object?>?)
        .whereType<Map<String, Object?>>()
        .map((final Map<String, Object?> item) => (item['id'] as String?) ?? '')
        .map((final String item) => item.trim())
        .where((final String item) => item.isNotEmpty)
        .toList();
  }

  String _selectPreferredModel(final List<String> modelIds) {
    if (modelIds.isEmpty) {
      return '';
    }

    final Iterable<String> chatModels = modelIds.where((final String modelId) {
      final String normalized = modelId.toLowerCase();
      return !normalized.contains('embedding') &&
          !normalized.contains('embed') &&
          !normalized.contains('rerank');
    });

    if (chatModels.isNotEmpty) {
      return chatModels.first;
    }

    return modelIds.first;
  }

  String _normalizeBaseUrl(final String baseUrl) => baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;
}
