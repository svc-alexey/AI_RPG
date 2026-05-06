class BillingPlan {
  const BillingPlan({
    required this.code,
    required this.kind,
    required this.title,
    this.description = '',
    this.currency = 'RUB',
    required this.basePriceMinor,
    this.salePriceMinor,
    this.saleBadgeText,
    this.salePercent,
    this.tokenGrant = 0,
    this.featured = false,
    this.isActive = true,
    this.sortOrder = 0,
  });

  final String code;
  final String kind;
  final String title;
  final String description;
  final String currency;
  final int basePriceMinor;
  final int? salePriceMinor;
  final String? saleBadgeText;
  final int? salePercent;
  final int tokenGrant;
  final bool featured;
  final bool isActive;
  final int sortOrder;

  factory BillingPlan.fromJson(final Map<String, dynamic> json) => BillingPlan(
    code: json['code'] as String? ?? '',
    kind: json['kind'] as String? ?? 'token_pack',
    title: json['title'] as String? ?? '',
    description: json['description'] as String? ?? '',
    currency: json['currency'] as String? ?? 'RUB',
    basePriceMinor: json['base_price_minor'] as int? ?? 0,
    salePriceMinor: json['sale_price_minor'] as int?,
    saleBadgeText: json['sale_badge_text'] as String?,
    salePercent: json['sale_percent'] as int?,
    tokenGrant: json['token_grant'] as int? ?? 0,
    featured: json['featured'] as bool? ?? false,
    isActive: json['is_active'] as bool? ?? true,
    sortOrder: json['sort_order'] as int? ?? 0,
  );

  String get priceLabel {
    final int price = salePriceMinor ?? basePriceMinor;
    if (price == 0) return 'Free';
    return '${(price / 100).toStringAsFixed(0)} RUB';
  }

  String? get oldPriceLabel {
    if (salePriceMinor == null || salePriceMinor == basePriceMinor) return null;
    return '${(basePriceMinor / 100).toStringAsFixed(0)} RUB';
  }

  int get effectivePriceMinor => salePriceMinor ?? basePriceMinor;
}

class BillingWallet {
  const BillingWallet({
    this.welcomeTokensRemaining = 0,
    this.paidTokensRemaining = 0,
    this.subscriptionTokensRemaining = 0,
    this.totalTokensRemaining = 0,
    this.subscriptionQuotaResetsAt,
    this.welcomeExpiresAt,
  });

  final int welcomeTokensRemaining;
  final int paidTokensRemaining;
  final int subscriptionTokensRemaining;
  final int totalTokensRemaining;
  final DateTime? subscriptionQuotaResetsAt;
  final DateTime? welcomeExpiresAt;

  factory BillingWallet.fromJson(final Map<String, dynamic> json) =>
      BillingWallet(
        welcomeTokensRemaining: json['welcome_tokens_remaining'] as int? ?? 0,
        paidTokensRemaining: json['paid_tokens_remaining'] as int? ?? 0,
        subscriptionTokensRemaining:
            json['subscription_tokens_remaining'] as int? ?? 0,
        totalTokensRemaining: json['total_tokens_remaining'] as int? ?? 0,
        subscriptionQuotaResetsAt: json['subscription_quota_resets_at'] != null
            ? DateTime.tryParse(json['subscription_quota_resets_at'] as String)
            : null,
        welcomeExpiresAt: json['welcome_expires_at'] != null
            ? DateTime.tryParse(json['welcome_expires_at'] as String)
            : null,
      );

  bool get hasWelcomeGrant => welcomeTokensRemaining > 0;
}

class CheckoutResult {
  const CheckoutResult({
    required this.orderId,
    required this.confirmationUrl,
    required this.amountMinor,
    this.currency = 'RUB',
  });

  final String orderId;
  final String confirmationUrl;
  final int amountMinor;
  final String currency;

  factory CheckoutResult.fromJson(final Map<String, dynamic> json) =>
      CheckoutResult(
        orderId: json['order_id'] as String? ?? '',
        confirmationUrl: json['confirmation_url'] as String? ?? '',
        amountMinor: json['amount_minor'] as int? ?? 0,
        currency: json['currency'] as String? ?? 'RUB',
      );
}

class TransactionEntry {
  const TransactionEntry({
    required this.id,
    required this.amount,
    required this.reason,
    this.source = '',
    this.planCode,
    this.campaignId,
    required this.createdAt,
  });

  final String id;
  final int amount;
  final String reason;
  final String source;
  final String? planCode;
  final String? campaignId;
  final DateTime createdAt;

  factory TransactionEntry.fromJson(final Map<String, dynamic> json) =>
      TransactionEntry(
        id: json['id'] as String? ?? '',
        amount: json['amount'] as int? ?? 0,
        reason: json['reason'] as String? ?? '',
        source: json['source'] as String? ?? '',
        planCode: json['plan_code'] as String?,
        campaignId: json['campaign_id'] as String?,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      );

  bool get isCredit => amount > 0;
  bool get isDebit => amount < 0;
}
