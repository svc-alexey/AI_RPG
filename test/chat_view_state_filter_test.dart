import 'package:ai_prg/src/core/models/ai_settings.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/features/chat/application/chat_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'visibleMessages filters empty player bubbles from campaign and pending state',
    () {
      final ChatViewState state = ChatViewState(
        isLoading: false,
        isSending: true,
        campaign: CampaignState(
          id: 'campaign',
          schemaVersion: 4,
          title: 'Ash Harbor',
          setting: CampaignSetting.cozyCrime,
          mode: StoryMode.longCampaign,
          difficulty: DifficultyLevel.medium,
          character: const CharacterStats(
            name: 'Iris',
            hp: 12,
            maxHp: 12,
            energy: 8,
            maxEnergy: 8,
            might: 2,
            wit: 3,
            spirit: 2,
          ),
          location: 'Туманный причал',
          objective: 'Найти свидетеля',
          turnNumber: 1,
          memory: const CampaignMemory(
            rollingSummary: 'Ирис вышла к причалу.',
            activeGoal: 'Найти свидетеля',
            activeSituation: 'Над водой висит туман.',
            recentTurns: <RecentTurnSummary>[],
          ),
          modules: const <CampaignModuleState>[],
          inventory: const <String>[],
          companions: const <CampaignCompanion>[],
          notes: const <String>[],
          resources: const <CampaignResource>[],
          progression: null,
          messages: <ChatMessage>[
            ChatMessage(
              id: 'empty-player',
              role: ChatRole.player,
              text: '',
              createdAt: DateTime(2026, 4, 7),
            ),
            ChatMessage(
              id: 'narrator',
              role: ChatRole.narrator,
              text: 'Туман расползается вдоль причала.',
              createdAt: DateTime(2026, 4, 7),
            ),
          ],
          choices: const <Choice>[],
          updatedAt: DateTime(2026, 4, 7),
        ),
        settings: AiSettings.withEnvFallbacks(const AiSettings.defaults()),
        status: null,
        pendingPlayerMessage: ChatMessage(
          id: 'pending-player',
          role: ChatRole.player,
          text: '',
          createdAt: DateTime(2026, 4, 7),
        ),
        pendingNarratorMessage: ChatMessage(
          id: 'pending-narrator',
          role: ChatRole.narrator,
          text: 'Генерация...',
          createdAt: DateTime(2026, 4, 7),
        ),
        transientNotifications: const <StateChangeNotification>[],
        highlightedModules: const <CampaignModule>[],
        newlyUnlockedModules: const <CampaignModule>[],
        worldRumors: const <SymmetryWorldRumor>[],
        clearInputRevision: 0,
      );

      final List<ChatMessage> visible = state.visibleMessages;

      expect(visible.length, 2);
      expect(visible.first.role, ChatRole.narrator);
      expect(visible.last.id, 'pending-narrator');
    },
  );
}
