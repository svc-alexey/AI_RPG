import 'package:ai_prg/src/core/data/isar/campaign_storage_mapper.dart';
import 'package:ai_prg/src/core/data/isar/isar_collections.dart';
import 'package:ai_prg/src/core/models/campaign_models.dart';
import 'package:isar/isar.dart';

class CampaignLocalDataSource {
  const CampaignLocalDataSource();

  Future<List<CampaignState>> loadAllCampaigns(final Isar isar) async {
    final List<CampaignRecord> campaigns =
        await isar.campaignRecords.where().findAll();
    final List<CampaignState> result = <CampaignState>[];

    for (final CampaignRecord campaign in campaigns) {
      result.add(await loadCampaignByRecord(isar, campaign));
    }

    result.sort((final a, final b) => b.updatedAt.compareTo(a.updatedAt));
    return result;
  }

  Future<CampaignState?> loadCampaign(final Isar isar, final String id) async {
    final CampaignRecord? campaign = await isar.campaignRecords
        .filter()
        .campaignIdEqualTo(id)
        .findFirst();
    if (campaign == null) {
      return null;
    }
    return loadCampaignByRecord(isar, campaign);
  }

  Future<CampaignState> loadCampaignByRecord(
    final Isar isar,
    final CampaignRecord campaign,
  ) async {
    final WorldStateRecord? worldState = await isar.worldStateRecords
        .filter()
        .campaignIdEqualTo(campaign.campaignId)
        .findFirst();
    final List<MessageRecord> messages = await isar.messageRecords
        .filter()
        .campaignIdEqualTo(campaign.campaignId)
        .findAll();
    final List<InventoryItemRecord> inventoryItems = await isar
        .inventoryItemRecords
        .filter()
        .campaignIdEqualTo(campaign.campaignId)
        .findAll();

    return CampaignStorageMapper.fromRecords(
      campaign: campaign,
      worldState: worldState,
      messages: messages,
      inventoryItems: inventoryItems,
    );
  }

  Future<void> saveCampaign(final Isar isar, final CampaignState campaign) async {
    await isar.writeTxn(() async {
      await isar.campaignRecords.put(CampaignStorageMapper.toCampaignRecord(campaign));
      await isar.worldStateRecords.put(
        CampaignStorageMapper.toWorldStateRecord(campaign),
      );

      final List<MessageRecord> existingMessages = await isar.messageRecords
          .filter()
          .campaignIdEqualTo(campaign.id)
          .findAll();
      if (existingMessages.isNotEmpty) {
        await isar.messageRecords.deleteAll(
          existingMessages.map((final item) => item.id).toList(),
        );
      }

      final List<MessageRecord> nextMessages =
          CampaignStorageMapper.toMessageRecords(campaign);
      if (nextMessages.isNotEmpty) {
        await isar.messageRecords.putAll(nextMessages);
      }

      final List<InventoryItemRecord> existingInventory = await isar
          .inventoryItemRecords
          .filter()
          .campaignIdEqualTo(campaign.id)
          .findAll();
      if (existingInventory.isNotEmpty) {
        await isar.inventoryItemRecords.deleteAll(
          existingInventory.map((final item) => item.id).toList(),
        );
      }

      final List<InventoryItemRecord> nextInventory =
          CampaignStorageMapper.toInventoryRecords(campaign);
      if (nextInventory.isNotEmpty) {
        await isar.inventoryItemRecords.putAll(nextInventory);
      }
    });
  }

  Future<void> deleteCampaign(final Isar isar, final String id) async {
    await isar.writeTxn(() async {
      final CampaignRecord? campaign = await isar.campaignRecords
          .filter()
          .campaignIdEqualTo(id)
          .findFirst();
      if (campaign != null) {
        await isar.campaignRecords.delete(campaign.id);
      }

      final WorldStateRecord? worldState = await isar.worldStateRecords
          .filter()
          .campaignIdEqualTo(id)
          .findFirst();
      if (worldState != null) {
        await isar.worldStateRecords.delete(worldState.id);
      }

      final List<MessageRecord> messages = await isar.messageRecords
          .filter()
          .campaignIdEqualTo(id)
          .findAll();
      if (messages.isNotEmpty) {
        await isar.messageRecords.deleteAll(
          messages.map((final item) => item.id).toList(),
        );
      }

      final List<InventoryItemRecord> inventoryItems = await isar
          .inventoryItemRecords
          .filter()
          .campaignIdEqualTo(id)
          .findAll();
      if (inventoryItems.isNotEmpty) {
        await isar.inventoryItemRecords.deleteAll(
          inventoryItems.map((final item) => item.id).toList(),
        );
      }
    });
  }
}
