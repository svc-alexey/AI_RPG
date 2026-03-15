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
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isChecking = false;
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
                      'LM Studio / endpoint, совместимый с OpenAI',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Для LM Studio по умолчанию используется http://127.0.0.1:1234/v1. Укажи id модели так, как он называется в локальном сервере.',
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
                      onSelectionChanged: (selection) {
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
      await _autofillLmStudioModelIfNeeded();
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
      final AiSettings settings = _buildSettings();
      final client = scope.aiServiceFactory.create(settings);
      await client.checkConnection(settings: settings);
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
    });

    if (provider == AiProviderType.lmStudio) {
      await _autofillLmStudioModelIfNeeded();
    }
  }

  Future<void> _autofillLmStudioModelIfNeeded() async {
    if (_modelController.text.trim().isNotEmpty) {
      return;
    }

    final String baseUrl = _baseUrlController.text.trim().isEmpty
        ? const AiSettings.defaults().baseUrl
        : _baseUrlController.text.trim();

    try {
      final Uri uri = Uri.parse('${_normalizeBaseUrl(baseUrl)}/models');
      final http.Response response = await http
          .get(
            uri,
            headers: const <String, String>{'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return;
      }

      final Object? decoded = jsonDecode(response.body);
      if (decoded is! Map<String, Object?>) {
        return;
      }

      final List<Object?> items =
          (decoded['data'] as List<Object?>?) ?? const <Object?>[];
      if (items.isEmpty) {
        return;
      }

      final Map<String, Object?>? firstItem =
          items.first as Map<String, Object?>?;
      final String modelId = (firstItem?['id'] as String?)?.trim() ?? '';
      if (modelId.isEmpty || !mounted) {
        return;
      }

      setState(() {
        _baseUrlController.text = baseUrl;
        _modelController.text = modelId;
        _status = 'Модель LM Studio загружена автоматически: $modelId';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _baseUrlController.text = baseUrl;
        _status =
            'Localhost для LM Studio установлен. Запусти локальный сервер, чтобы модель подставилась автоматически.';
      });
    }
  }

  String _normalizeBaseUrl(final String baseUrl) => baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;
}
