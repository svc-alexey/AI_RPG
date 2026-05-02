import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/app/legal_links.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/features/auth/presentation/require_account.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key, this.initialOrderId});

  final String? initialOrderId;

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;
  SymmetryBillingSummary? _summary;
  List<SymmetryBillingCatalogItem> _catalog =
      const <SymmetryBillingCatalogItem>[];
  List<SymmetryBillingHistoryItem> _history =
      const <SymmetryBillingHistoryItem>[];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final repo = ref.read(billingRepositoryProvider);
      final results = await Future.wait<Object>(<Future<Object>>[
        repo.loadCatalog(),
        repo.loadSummary(),
      ]);
      final SymmetryBillingSummary summary =
          results[1] as SymmetryBillingSummary;
      List<SymmetryBillingHistoryItem> history =
          const <SymmetryBillingHistoryItem>[];
      if (summary.isAuthenticated && !summary.isGuest) {
        history = await repo.loadHistory();
      }
      if (widget.initialOrderId != null &&
          widget.initialOrderId!.trim().isNotEmpty &&
          summary.isAuthenticated &&
          !summary.isGuest) {
        await repo.loadOrderStatus(orderId: widget.initialOrderId!.trim());
      }
      if (!mounted) {
        return;
      }
      setState(() {
        _catalog = results[0] as List<SymmetryBillingCatalogItem>;
        _summary = summary;
        _history = history;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = context.l10n.symmetryFriendlyError(error);
        _isLoading = false;
      });
    }
  }

  Future<void> _openLegal(final LandingLegalTab tab) async {
    await launchUrl(
      buildLandingLegalUri(tab: tab, language: context.l10n.language.name),
      webOnlyWindowName: '_blank',
    );
  }

  Future<void> _buy(final SymmetryBillingCatalogItem item) async {
    if (_isSubmitting) {
      return;
    }
    final SymmetryBillingSummary? current = _summary;
    if (current == null || !current.isAuthenticated || current.isGuest) {
      final bool ready = await requireRegisteredAccount(context, ref);
      if (!ready) {
        return;
      }
      await _reload();
    }
    if (!mounted) {
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final checkout = await ref
          .read(billingRepositoryProvider)
          .createCheckout(planCode: item.code);
      final bool launched = await launchUrl(
        Uri.parse(checkout.confirmationUrl),
        webOnlyWindowName: '_self',
      );
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _billingText(
                'Не удалось открыть оплату.',
                'Could not open the payment page.',
              ),
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.symmetryFriendlyError(error))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _cancelSubscription() async {
    setState(() => _isSubmitting = true);
    try {
      await ref.read(billingRepositoryProvider).cancelSubscription();
      await _reload();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.symmetryFriendlyError(error))),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(final BuildContext context) {
    final theme = Theme.of(context);
    final responsive = context.responsive;
    final summary = _summary;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(_billingText('Подписка и токены', 'Billing & tokens')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                final double maxWidth = responsive.isWide
                    ? 980
                    : constraints.maxWidth;
                return Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: RefreshIndicator(
                      onRefresh: _reload,
                      child: ListView(
                        padding: EdgeInsets.fromLTRB(
                          responsive.pagePadding,
                          responsive.pagePadding,
                          responsive.pagePadding,
                          responsive.blockSpacing * 2,
                        ),
                        children: <Widget>[
                          if (_error != null) ...<Widget>[
                            AetherCard(
                              borderColor: theme.colorScheme.error,
                              child: Text(
                                _error!,
                                style: theme.textTheme.bodyLarge,
                              ),
                            ),
                            SizedBox(height: responsive.blockSpacing),
                          ],
                          if (summary != null) ...<Widget>[
                            _SectionHeader(
                              title: _billingText('Ваш доступ', 'Your access'),
                              subtitle: _billingText(
                                'Активный план, остаток токенов и состояние оплаты в одном центре управления.',
                                'Your active plan, remaining tokens, and billing state in one control room.',
                              ),
                            ),
                            SizedBox(height: responsive.sectionSpacing),
                            _buildSummaryHero(context, summary),
                            SizedBox(height: responsive.blockSpacing),
                          ],
                          _SectionHeader(
                            title: _billingText('Тарифы', 'Plans'),
                            subtitle: _billingText(
                              'Разовые пакеты и подписки с понятным лимитом доступа.',
                              'One-time packs and subscriptions with explicit access limits.',
                            ),
                          ),
                          SizedBox(height: responsive.sectionSpacing),
                          _buildCatalogGrid(context),
                          SizedBox(height: responsive.blockSpacing),
                          _SectionHeader(
                            title: _billingText(
                              'Хроника платежей',
                              'Payment chronicle',
                            ),
                            subtitle: _billingText(
                              'Последние списания, статусы оплаты и история начислений.',
                              'Recent charges, payment statuses, and your latest billing events.',
                            ),
                          ),
                          SizedBox(height: responsive.sectionSpacing),
                          _buildHistorySection(context),
                          SizedBox(height: responsive.blockSpacing),
                          _SectionHeader(
                            title: _billingText(
                              'Юридическая информация',
                              'Legal center',
                            ),
                            subtitle: _billingText(
                              'Все документы открываются на landing page в отдельных вкладках legal center.',
                              'Every document opens on the landing page inside the shared legal center.',
                            ),
                          ),
                          SizedBox(height: responsive.sectionSpacing),
                          _buildLegalSection(context),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  String _billingText(final String ru, final String en) =>
      context.l10n.language.name == 'ru' ? ru : en;

  Widget _buildSummaryHero(
    final BuildContext context,
    final SymmetryBillingSummary summary,
  ) {
    final ThemeData theme = Theme.of(context);
    final AppResponsiveData responsive = context.responsive;
    final bool canCancelSubscription =
        (summary.subscriptionStatus == 'active' ||
            summary.subscriptionStatus == 'canceling') &&
        !summary.cancelAtPeriodEnd;
    final List<_MetaItemData> metaItems = <_MetaItemData>[
      _MetaItemData(
        label: _billingText('Состояние', 'State'),
        value: _planStateLabel(summary),
      ),
      if (summary.currentPeriodEndAt != null)
        _MetaItemData(
          label: _billingText('Оплачен до', 'Paid through'),
          value: _formatDate(summary.currentPeriodEndAt!),
        ),
      if (summary.nextChargeAt != null)
        _MetaItemData(
          label: _billingText('Следующее списание', 'Next charge'),
          value: _formatDate(summary.nextChargeAt!),
        ),
      if (summary.subscriptionQuotaResetsAt != null)
        _MetaItemData(
          label: _billingText('Сброс квоты', 'Quota reset'),
          value: _formatDate(summary.subscriptionQuotaResetsAt!),
        ),
      if (summary.welcomeExpiresAt != null)
        _MetaItemData(
          label: _billingText('Welcome действует до', 'Welcome valid until'),
          value: _formatDate(summary.welcomeExpiresAt!),
        ),
      if (summary.maskedPaymentMethodLabel.trim().isNotEmpty)
        _MetaItemData(
          label: _billingText('Способ оплаты', 'Payment method'),
          value: summary.maskedPaymentMethodLabel.trim(),
        ),
    ];

    return AetherCard(
      highlight: true,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(responsive.cardRadius),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -60,
              right: -24,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AetherPalette.accent.withValues(alpha: 0.12),
                ),
              ),
            ),
            Positioned(
              left: -36,
              bottom: -48,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AetherPalette.gold.withValues(alpha: 0.08),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(responsive.cardPadding + 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          _billingText(
                            'Текущий доступ',
                            'Current access',
                          ).toUpperCase(),
                          style: theme.textTheme.bodySmall?.copyWith(
                            letterSpacing: 2.8,
                            color: AetherPalette.gold,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.auto_awesome_rounded,
                        color: AetherPalette.accent,
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.sectionSpacing),
                  Text(
                    summary.activePlanTitle ??
                        _billingText('Бесплатный доступ', 'Free access'),
                    style: theme.textTheme.headlineSmall,
                  ),
                  SizedBox(height: responsive.sectionSpacing / 2),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.end,
                    spacing: 10,
                    runSpacing: 4,
                    children: <Widget>[
                      Text(
                        _formatTokenCompact(summary.totalTokensRemaining),
                        style: theme.textTheme.displayMedium?.copyWith(
                          height: 0.95,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          _billingText('токенов доступно', 'tokens available'),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: AetherPalette.gold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: responsive.sectionSpacing),
                  Text(
                    _billingText(
                      'Баланс делится на welcome, пакеты и квоту активной подписки. Мы показываем только реальные данные из вашего аккаунта.',
                      'Your balance is split into welcome, purchased packs, and the active subscription quota. Only real account data is shown here.',
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AetherPalette.narrativeText,
                    ),
                  ),
                  SizedBox(height: responsive.sectionSpacing),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      _BreakdownChip(
                        label: _billingText('Welcome', 'Welcome'),
                        value: _formatTokenCompact(
                          summary.welcomeTokensRemaining,
                        ),
                      ),
                      _BreakdownChip(
                        label: _billingText('Пакеты', 'Packs'),
                        value: _formatTokenCompact(summary.paidTokensRemaining),
                      ),
                      _BreakdownChip(
                        label: _billingText('Подписка', 'Subscription'),
                        value: _formatTokenCompact(
                          summary.subscriptionTokensRemaining,
                        ),
                      ),
                    ],
                  ),
                  if (metaItems.isNotEmpty) ...<Widget>[
                    SizedBox(height: responsive.blockSpacing),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final bool twoColumns =
                            constraints.maxWidth > 720 && metaItems.length > 1;
                        const double gap = 12;
                        final double itemWidth = twoColumns
                            ? (constraints.maxWidth - gap) / 2
                            : constraints.maxWidth;
                        return Wrap(
                          spacing: gap,
                          runSpacing: gap,
                          children: metaItems
                              .map(
                                (item) => SizedBox(
                                  width: itemWidth,
                                  child: _MetaPanel(item: item),
                                ),
                              )
                              .toList(),
                        );
                      },
                    ),
                  ],
                  if (summary.paywallReason != null &&
                      summary.paywallReason!.trim().isNotEmpty) ...<Widget>[
                    SizedBox(height: responsive.sectionSpacing),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: theme.colorScheme.error.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        context.l10n.symmetryFriendlyError(
                          SymmetryApiException(
                            message: summary.paywallReason!,
                            detailCode: summary.paywallReason,
                          ),
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                  if (canCancelSubscription) ...<Widget>[
                    SizedBox(height: responsive.blockSpacing),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: _isSubmitting ? null : _cancelSubscription,
                        icon: const Icon(Icons.event_busy_outlined, size: 18),
                        label: Text(
                          _billingText(
                            'Отключить автопродление',
                            'Cancel auto-renew',
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatalogGrid(final BuildContext context) {
    final AppResponsiveData responsive = context.responsive;
    if (_catalog.isEmpty) {
      return AetherCard(
        child: Text(
          _billingText(
            'Каталог тарифов временно недоступен. Обновите экран чуть позже.',
            'The plan catalog is temporarily unavailable. Try refreshing in a moment.',
          ),
        ),
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool twoColumns =
            responsive.isWide &&
            constraints.maxWidth > 760 &&
            _catalog.length > 1;
        const double gap = 14;
        final double itemWidth = twoColumns
            ? (constraints.maxWidth - gap) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: _catalog
              .map(
                (item) => SizedBox(
                  width: itemWidth,
                  child: _CatalogCard(
                    item: item,
                    priceLabel: _formatRub(item.finalPriceMinor),
                    oldPriceLabel: item.isSaleActive
                        ? _formatRub(item.basePriceMinor)
                        : null,
                    primaryMeta: _primaryCatalogMeta(item),
                    secondaryMeta: _secondaryCatalogMeta(item),
                    onBuy: () => _buy(item),
                    isBusy: _isSubmitting,
                    buttonLabel: _billingText(
                      item.isSubscription
                          ? 'Запустить подписку'
                          : (item.finalPriceMinor == 0 ? 'Получить' : 'Купить'),
                      item.isSubscription
                          ? 'Start subscription'
                          : (item.finalPriceMinor == 0 ? 'Claim' : 'Buy now'),
                    ),
                  ),
                ),
              )
              .toList(),
        );
      },
    );
  }

  Widget _buildHistorySection(final BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppResponsiveData responsive = context.responsive;
    if (_history.isEmpty) {
      return AetherCard(
        child: Text(
          _billingText(
            'История платежей пока пустая. Как только появятся оплаты или начисления, они появятся здесь.',
            'Your payment history is empty for now. Charges and grants will appear here as soon as they happen.',
          ),
          style: theme.textTheme.bodyLarge,
        ),
      );
    }

    final List<SymmetryBillingHistoryItem> historyItems = _history
        .take(8)
        .toList(growable: false);
    return AetherCard(
      child: Column(
        children: <Widget>[
          for (int index = 0; index < historyItems.length; index++) ...<Widget>[
            Padding(
              padding: EdgeInsets.only(
                bottom: index == historyItems.length - 1
                    ? 0
                    : responsive.sectionSpacing,
              ),
              child: Column(
                children: <Widget>[
                  _HistoryRow(
                    title: historyItems[index].title,
                    amountLabel: _formatRub(historyItems[index].amountMinor),
                    dateLabel: _formatDate(historyItems[index].createdAt),
                    providerLabel: historyItems[index].provider.isEmpty
                        ? null
                        : historyItems[index].provider.toUpperCase(),
                    statusLabel: _historyStatusLabel(
                      historyItems[index].status,
                    ),
                    statusColor: _historyStatusColor(
                      historyItems[index].status,
                    ),
                  ),
                  if (index != historyItems.length - 1) ...<Widget>[
                    SizedBox(height: responsive.sectionSpacing),
                    Divider(
                      height: 1,
                      color: AetherPalette.panelBorderSolid.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegalSection(final BuildContext context) => AetherCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          _billingText(
            'Документы открываются на landing page и переключаются вкладками внутри общего legal center.',
            'Documents open on the landing page and switch as tabs inside the shared legal center.',
          ),
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AetherPalette.narrativeText),
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: <Widget>[
            _LegalLinkButton(
              icon: Icons.description_outlined,
              label: _billingText('Оферта', 'License'),
              onPressed: () => _openLegal(LandingLegalTab.offer),
            ),
            _LegalLinkButton(
              icon: Icons.policy_outlined,
              label: _billingText('Конфиденциальность', 'Privacy'),
              onPressed: () => _openLegal(LandingLegalTab.privacy),
            ),
            _LegalLinkButton(
              icon: Icons.receipt_long_outlined,
              label: _billingText('Возвраты', 'Refunds'),
              onPressed: () => _openLegal(LandingLegalTab.refunds),
            ),
            _LegalLinkButton(
              icon: Icons.alternate_email_outlined,
              label: _billingText('Контакты', 'Contacts'),
              onPressed: () => _openLegal(LandingLegalTab.contacts),
            ),
          ],
        ),
      ],
    ),
  );

  String _formatTokens(final int value) => value.toString();

  String _formatTokenCompact(final int value) {
    if (value >= 1000000) {
      final double millions = value / 1000000;
      final String suffix =
          millions >= 10 || millions == millions.truncateToDouble()
          ? millions.toStringAsFixed(0)
          : millions.toStringAsFixed(1);
      return '${suffix}M';
    }
    if (value >= 1000) {
      final double thousands = value / 1000;
      final String suffix =
          thousands >= 10 || thousands == thousands.truncateToDouble()
          ? thousands.toStringAsFixed(0)
          : thousands.toStringAsFixed(1);
      return '${suffix}K';
    }
    return _formatTokens(value);
  }

  String _primaryCatalogMeta(final SymmetryBillingCatalogItem item) {
    if (item.isSubscription && item.monthlyQuota > 0) {
      return _billingText(
        '${_formatTokenCompact(item.monthlyQuota)} в месяц',
        '${_formatTokenCompact(item.monthlyQuota)} / month',
      );
    }
    if (item.tokenGrant > 0) {
      return _billingText(
        '${_formatTokenCompact(item.tokenGrant)} токенов',
        '${_formatTokenCompact(item.tokenGrant)} tokens',
      );
    }
    return _billingText('Доступ к старту', 'Starter access');
  }

  String? _secondaryCatalogMeta(final SymmetryBillingCatalogItem item) {
    if (item.isSubscription && item.fairUseLimit > 0) {
      return _billingText(
        'fair use до ${_formatTokenCompact(item.fairUseLimit)}',
        'fair use up to ${_formatTokenCompact(item.fairUseLimit)}',
      );
    }
    if (!item.isSubscription && item.fairUseLimit > 0) {
      return _billingText(
        'лимит выдачи ${_formatTokenCompact(item.fairUseLimit)}',
        'delivery cap ${_formatTokenCompact(item.fairUseLimit)}',
      );
    }
    return item.isSubscription
        ? _billingText('Автопродление', 'Auto-renew')
        : _billingText('Разовая покупка', 'One-time purchase');
  }

  String _planStateLabel(final SymmetryBillingSummary summary) {
    if (summary.cancelAtPeriodEnd) {
      return _billingText('Остановится в конце периода', 'Stops at period end');
    }
    switch (summary.subscriptionStatus) {
      case 'active':
        return _billingText('Подписка активна', 'Subscription active');
      case 'canceling':
        return _billingText('Продление отключено', 'Renewal disabled');
      case 'past_due':
        return _billingText(
          'Нужно подтвердить оплату',
          'Payment needs attention',
        );
      case 'canceled':
        return _billingText('Подписка остановлена', 'Subscription canceled');
      default:
        if (summary.totalTokensRemaining > 0) {
          return _billingText('Доступ через токены', 'Access via tokens');
        }
        return _billingText('Базовый доступ', 'Base access');
    }
  }

  String _historyStatusLabel(final String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'succeeded':
        return _billingText('Оплачено', 'Paid');
      case 'pending':
        return _billingText('Ожидает', 'Pending');
      case 'canceled':
        return _billingText('Отменено', 'Canceled');
      case 'failed':
        return _billingText('Ошибка', 'Failed');
      default:
        return status;
    }
  }

  Color _historyStatusColor(final String status) {
    switch (status.toLowerCase()) {
      case 'paid':
      case 'succeeded':
        return AetherPalette.success;
      case 'pending':
        return AetherPalette.gold;
      case 'canceled':
        return AetherPalette.textMuted;
      case 'failed':
        return Theme.of(context).colorScheme.error;
      default:
        return AetherPalette.textMuted;
    }
  }

  String _formatRub(final int minor) {
    final double rub = minor / 100.0;
    return '${rub.toStringAsFixed(rub.truncateToDouble() == rub ? 0 : 2)} RUB';
  }

  String _formatDate(final DateTime value) {
    final DateTime local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}.${local.year}';
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(final BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Text(title, style: Theme.of(context).textTheme.headlineSmall),
      const SizedBox(height: 8),
      Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: AetherPalette.narrativeText),
      ),
    ],
  );
}

class _MetaItemData {
  const _MetaItemData({required this.label, required this.value});

  final String label;
  final String value;
}

class _MetaPanel extends StatelessWidget {
  const _MetaPanel({required this.item});

  final _MetaItemData item;

  @override
  Widget build(final BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      color: Colors.white.withValues(alpha: 0.03),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          item.label.toUpperCase(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AetherPalette.gold,
            letterSpacing: 1.8,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(item.value, style: Theme.of(context).textTheme.titleMedium),
      ],
    ),
  );
}

class _BreakdownChip extends StatelessWidget {
  const _BreakdownChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(final BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      color: Colors.white.withValues(alpha: 0.03),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AetherPalette.textMuted),
        ),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    ),
  );
}

class _CatalogCard extends StatelessWidget {
  const _CatalogCard({
    required this.item,
    required this.priceLabel,
    required this.oldPriceLabel,
    required this.primaryMeta,
    required this.secondaryMeta,
    required this.onBuy,
    required this.isBusy,
    required this.buttonLabel,
  });

  final SymmetryBillingCatalogItem item;
  final String priceLabel;
  final String? oldPriceLabel;
  final String primaryMeta;
  final String? secondaryMeta;
  final VoidCallback onBuy;
  final bool isBusy;
  final String buttonLabel;

  @override
  Widget build(final BuildContext context) => AetherCard(
    highlight: item.isSaleActive,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.isSubscription
                        ? (context.l10n.language.name == 'ru'
                              ? 'Подписка'
                              : 'Subscription')
                        : (item.finalPriceMinor == 0
                              ? (context.l10n.language.name == 'ru'
                                    ? 'Подарок'
                                    : 'Gift')
                              : (context.l10n.language.name == 'ru'
                                    ? 'Токен-пак'
                                    : 'Token pack')),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AetherPalette.gold,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            if (item.isSaleActive)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AetherPalette.accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.saleBadgeText.isNotEmpty
                      ? item.saleBadgeText
                      : '-${item.salePercent}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AetherPalette.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          item.description,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AetherPalette.narrativeText),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: <Widget>[
            _InlineMetaChip(text: primaryMeta),
            if (secondaryMeta != null) _InlineMetaChip(text: secondaryMeta!),
          ],
        ),
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            if (oldPriceLabel != null) ...<Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  oldPriceLabel!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: AetherPalette.textMuted,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                priceLabel,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: isBusy ? null : onBuy,
          icon: Icon(
            item.isSubscription
                ? Icons.workspace_premium_outlined
                : Icons.local_fire_department_outlined,
            size: 18,
          ),
          label: Text(buttonLabel),
        ),
      ],
    ),
  );
}

class _InlineMetaChip extends StatelessWidget {
  const _InlineMetaChip({required this.text});

  final String text;

  @override
  Widget build(final BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      color: Colors.white.withValues(alpha: 0.025),
    ),
    child: Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(color: AetherPalette.textMuted),
    ),
  );
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({
    required this.title,
    required this.amountLabel,
    required this.dateLabel,
    required this.statusLabel,
    required this.statusColor,
    this.providerLabel,
  });

  final String title;
  final String amountLabel;
  final String dateLabel;
  final String statusLabel;
  final Color statusColor;
  final String? providerLabel;

  @override
  Widget build(final BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.04),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: const Icon(
          Icons.history_toggle_off_rounded,
          color: AetherPalette.gold,
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              providerLabel == null ? dateLabel : '$dateLabel · $providerLabel',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AetherPalette.textMuted),
            ),
          ],
        ),
      ),
      const SizedBox(width: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(amountLabel, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: statusColor.withValues(alpha: 0.12),
              border: Border.all(color: statusColor.withValues(alpha: 0.26)),
            ),
            child: Text(
              statusLabel,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

class _LegalLinkButton extends StatelessWidget {
  const _LegalLinkButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(final BuildContext context) => OutlinedButton.icon(
    onPressed: onPressed,
    icon: Icon(icon, size: 18),
    label: Text(label),
  );
}
