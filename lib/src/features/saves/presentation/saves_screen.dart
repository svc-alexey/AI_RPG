import 'package:ai_prg/src/app/app_scope.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/features/chat/presentation/chat_screen.dart';
import 'package:flutter/material.dart';

class SavesScreen extends StatefulWidget {
  const SavesScreen({super.key});

  @override
  State<SavesScreen> createState() => _SavesScreenState();
}

class _SavesScreenState extends State<SavesScreen> {
  bool _isLoading = true;
  bool _didLoad = false;
  List<CampaignState> _campaigns = const <CampaignState>[];

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
  Widget build(final BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сохраненные кампании')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _campaigns.isEmpty
          ? const Center(
              child: Text(
                'Пока нет сохранений. Создай новую кампанию на главном экране.',
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _campaigns.length,
              itemBuilder: (context, index) {
                final CampaignState campaign = _campaigns[index];
                return Card(
                  child: ListTile(
                    title: Text(campaign.title),
                    subtitle: Text(
                      '${campaign.location} • ход ${campaign.turnNumber}',
                    ),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (context) =>
                              ChatScreen(campaignId: campaign.id),
                        ),
                      );
                    },
                    trailing: IconButton(
                      onPressed: () => _delete(campaign.id),
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _load() async {
    final AppScope scope = AppScope.of(context);
    final List<CampaignState> campaigns = await scope.campaignRepository
        .loadAllCampaigns();
    setState(() {
      _campaigns = campaigns;
      _isLoading = false;
    });
  }

  Future<void> _delete(final String id) async {
    final AppScope scope = AppScope.of(context);
    await scope.campaignRepository.deleteCampaign(id);
    await _load();
  }
}
