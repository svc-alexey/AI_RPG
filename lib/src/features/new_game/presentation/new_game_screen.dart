import 'package:ai_prg/src/app/app_scope.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/features/chat/presentation/chat_screen.dart';
import 'package:flutter/material.dart';

class NewGameScreen extends StatefulWidget {
  const NewGameScreen({super.key});

  @override
  State<NewGameScreen> createState() => _NewGameScreenState();
}

class _NewGameScreenState extends State<NewGameScreen> {
  final TextEditingController _heroController = TextEditingController();
  CampaignSetting _setting = CampaignSetting.fantasy;
  StoryMode _mode = StoryMode.shortStory;
  DifficultyLevel _difficulty = DifficultyLevel.easy;
  bool _isSaving = false;

  @override
  void dispose() {
    _heroController.dispose();
    super.dispose();
  }

  @override
  Widget build(final BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Новая кампания')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: <Widget>[
              Text(
                'Соберем первый рабочий сценарий',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Выбираем сеттинг, режим и имя героя. После создания сразу откроется игровой чат.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _heroController,
                decoration: const InputDecoration(
                  labelText: 'Имя героя',
                  hintText: 'Мира, Ясень, Грач...',
                ),
              ),
              const SizedBox(height: 24),
              const _SectionTitle(title: 'Сеттинг'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: CampaignSetting.values.map((item) {
                  return ChoiceChip(
                    label: Text(_settingLabel(item)),
                    selected: _setting == item,
                    onSelected: (_) => setState(() => _setting = item),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const _SectionTitle(title: 'Режим истории'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: StoryMode.values.map((item) {
                  return ChoiceChip(
                    label: Text(_modeLabel(item)),
                    selected: _mode == item,
                    onSelected: (_) => setState(() => _mode = item),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              const _SectionTitle(title: 'Сложность'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: DifficultyLevel.values.map((item) {
                  return ChoiceChip(
                    label: Text(_difficultyLabel(item)),
                    selected: _difficulty == item,
                    onSelected: (_) => setState(() => _difficulty = item),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _isSaving ? null : () => _createCampaign(context),
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_stories_rounded),
                label: const Text('Создать кампанию'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createCampaign(final BuildContext context) async {
    setState(() => _isSaving = true);

    final AppScope scope = AppScope.of(context);
    final CampaignState campaign = scope.gameEngine.createCampaign(
      CampaignDraft(
        setting: _setting,
        mode: _mode,
        difficulty: _difficulty,
        heroName: _heroController.text,
      ),
    );

    await scope.campaignRepository.saveCampaign(campaign);
    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => ChatScreen(campaignId: campaign.id),
      ),
    );
  }

  String _settingLabel(final CampaignSetting value) => switch (value) {
    CampaignSetting.fantasy => 'Фэнтези',
    CampaignSetting.detective => 'Детектив',
    CampaignSetting.sciFi => 'Sci-fi',
  };

  String _modeLabel(final StoryMode value) => switch (value) {
    StoryMode.shortStory => 'Короткая история',
    StoryMode.longCampaign => 'Длинная кампания',
  };

  String _difficultyLabel(final DifficultyLevel value) => switch (value) {
    DifficultyLevel.easy => 'Легко',
    DifficultyLevel.medium => 'Нормально',
    DifficultyLevel.hardcore => 'Хардкор',
  };
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(final BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}
