import 'dart:convert';

import 'package:ai_prg/src/core/models/billing_models.dart';
import 'package:ai_prg/src/core/repositories/symmetry_auth_repository.dart';
import 'package:ai_prg/src/core/services/symmetry_api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BillingRepository {
  BillingRepository({required final SymmetryAuthRepository authRepository})
    : _authRepository = authRepository;

  final SymmetryAuthRepository _authRepository;
  static const _catalogCacheKey = 'billing_catalog_cache';
  static const _walletCacheKey = 'billing_wallet_cache';

  SymmetryApiClient _client(final String baseUrl) =>
      SymmetryApiClient(baseUrl: baseUrl);

  Future<List<BillingPlan>> fetchCatalog() async {
    final String baseUrl = await _authRepository.loadBaseUrl();
    final List<Map<String, dynamic>> raw =
        await _client(baseUrl).getBillingCatalog();
    final List<BillingPlan> plans =
        raw.map((final m) => BillingPlan.fromJson(m)).toList();
    _cacheJson(_catalogCacheKey, raw);
    return plans;
  }

  Future<BillingWallet> fetchWallet() async {
    return _authRepository.runWithAuthorizedSession(
      (final s) async {
        final Map<String, dynamic> data = await _client(s.baseUrl).getBillingWallet(
          accessToken: s.tokens.accessToken,
        );
        final wallet = BillingWallet.fromJson(data);
        _cacheJson(_walletCacheKey, data);
        return wallet;
      },
      allowGuest: false,
    );
  }

  Future<CheckoutResult> createCheckout({
    required final String planCode,
    final String returnUrl = '/',
  }) async {
    return _authRepository.runWithAuthorizedSession(
      (final s) async {
        final Map<String, dynamic> result =
            await _client(s.baseUrl).postBillingCheckout(
          accessToken: s.tokens.accessToken,
          planCode: planCode,
          returnUrl: returnUrl,
        );
        return CheckoutResult.fromJson(result);
      },
      allowGuest: false,
    );
  }

  Future<BillingWallet> claimWelcomeGrant() async {
    return _authRepository.runWithAuthorizedSession(
      (final s) async {
        final Map<String, dynamic> data =
            await _client(s.baseUrl).postClaimWelcome(
          accessToken: s.tokens.accessToken,
        );
        final wallet = BillingWallet.fromJson(data);
        _cacheJson(_walletCacheKey, data);
        return wallet;
      },
      allowGuest: false,
    );
  }

  Future<List<TransactionEntry>> fetchTransactions({final int limit = 20}) async {
    return _authRepository.runWithAuthorizedSession(
      (final s) async {
        final List<Map<String, dynamic>> raw =
            await _client(s.baseUrl).getBillingTransactions(
          accessToken: s.tokens.accessToken,
          limit: limit,
        );
        return raw.map((final m) => TransactionEntry.fromJson(m)).toList();
      },
      allowGuest: false,
    );
  }

  static const _pendingOrderKey = 'billing_pending_order_id';

  Future<void> savePendingOrderId(final String orderId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingOrderKey, orderId);
  }

  Future<String?> getPendingOrderId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pendingOrderKey);
  }

  Future<void> clearPendingOrderId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingOrderKey);
  }

  Future<Map<String, dynamic>?> getOrderStatus(final String orderId) async {
    return _authRepository.runWithAuthorizedSession(
      (final s) async {
        try {
          return await _client(s.baseUrl).getBillingOrder(
            accessToken: s.tokens.accessToken,
            orderId: orderId,
          );
        } catch (_) {
          return null;
        }
      },
      allowGuest: false,
    );
  }

  Future<void> migrateGuestCampaigns(final String guestUserId) async {
    await _authRepository.runWithAuthorizedSession(
      (final s) async {
        await _client(s.baseUrl).postMigrateGuest(
          accessToken: s.tokens.accessToken,
          guestUserId: guestUserId,
        );
      },
      allowGuest: false,
    );
  }

  Future<List<BillingPlan>?> loadCachedCatalog() async {
    final data = await _loadCachedJson(_catalogCacheKey);
    if (data == null) return null;
    return (data as List)
        .map((final m) => BillingPlan.fromJson(m as Map<String, dynamic>))
        .toList();
  }

  Future<BillingWallet?> loadCachedWallet() async {
    final data = await _loadCachedJson(_walletCacheKey);
    if (data == null) return null;
    return BillingWallet.fromJson(data as Map<String, dynamic>);
  }

  void _cacheJson(final String key, final dynamic data) {
    SharedPreferences.getInstance().then((final prefs) {
      prefs.setString(key, jsonEncode(data));
    });
  }

  Future<dynamic> _loadCachedJson(final String key) async {
    final prefs = await SharedPreferences.getInstance();
    final String? raw = prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }
}
