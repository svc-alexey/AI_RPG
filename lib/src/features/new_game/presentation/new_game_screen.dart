import 'package:ai_prg/src/app/app_localizations.dart';
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
    final AppLocalizations l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.newCampaign)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: <Widget>[
              Text(
                l10n.buildScenarioTitle,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                l10n.buildScenarioDescription,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _heroController,
                decoration: InputDecoration(
                  labelText: l10n.heroName,
                  hintText: l10n.heroNameHint,
                ),
              ),
              const SizedBox(height: 24),
              _SectionTitle(title: l10n.settingTitle),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: CampaignSetting.values.map((item) {
                  return ChoiceChip(
                    label: Text(l10n.settingLabel(item)),
                    selected: _setting == item,
                    onSelected: (_) => setState(() => _setting = item),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              _SectionTitle(title: l10n.storyModeTitle),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: StoryMode.values.map((item) {
                  return ChoiceChip(
                    label: Text(l10n.storyModeLabel(item)),
                    selected: _mode == item,
                    onSelected: (_) => setState(() => _mode = item),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              _SectionTitle(title: l10n.difficultyTitle),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: DifficultyLevel.values.map((item) {
                  return ChoiceChip(
                    label: Text(l10n.difficultyLabel(item)),
                    selected: _difficulty == item,
                    onSelected: (_) => setState(() => _difficulty = item),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _isSaving ? null : _createCampaign,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.auto_stories_rounded),
                label: Text(l10n.createCampaignButton),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createCampaign() async {
    setState(() => _isSaving = true);

    final AppScope scope = AppScope.of(context);
    final NavigatorState navigator = Navigator.of(context);
    final CampaignState campaign = scope.gameEngine.createCampaign(
      draft: CampaignDraft(
        setting: _setting,
        mode: _mode,
        difficulty: _difficulty,
        heroName: _heroController.text,
      ),
      language: scope.appLanguageListenable.value,
    );

    await scope.campaignRepository.saveCampaign(campaign);
    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);
    await navigator.pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => ChatScreen(campaignId: campaign.id),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(final BuildContext context) => Text(
    title,
    style: Theme.of(
      context,
    ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
  );
}
