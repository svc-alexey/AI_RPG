import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
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

  Future<void> _openLegal(final String path) async {
    await launchUrl(Uri.base.resolve(path), webOnlyWindowName: '_blank');
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
          : RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                padding: EdgeInsets.all(responsive.pagePadding),
                children: <Widget>[
                  if (_error != null)
                    AetherCard(
                      child: Text(_error!, style: theme.textTheme.bodyLarge),
                    ),
                  if (summary != null) ...<Widget>[
                    _SectionTitle(
                      text: _billingText('Ваш доступ', 'Your access'),
                    ),
                    AetherCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            summary.activePlanTitle ??
                                _billingText(
                                  'Бесплатный доступ',
                                  'Free access',
                                ),
                            style: theme.textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _billingText(
                              'Остаток: ${_formatTokens(summary.totalTokensRemaining)} токенов',
                              'Remaining: ${_formatTokens(summary.totalTokensRemaining)} tokens',
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _billingText(
                              'Welcome: ${_formatTokens(summary.welcomeTokensRemaining)} | Пакеты: ${_formatTokens(summary.paidTokensRemaining)} | Подписка: ${_formatTokens(summary.subscriptionTokensRemaining)}',
                              'Welcome: ${_formatTokens(summary.welcomeTokensRemaining)} | Packs: ${_formatTokens(summary.paidTokensRemaining)} | Subscription: ${_formatTokens(summary.subscriptionTokensRemaining)}',
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AetherPalette.textMuted,
                            ),
                          ),
                          if (summary.currentPeriodEndAt != null) ...<Widget>[
                            const SizedBox(height: 8),
                            Text(
                              _billingText(
                                'Период до ${_formatDate(summary.currentPeriodEndAt!)}',
                                'Period until ${_formatDate(summary.currentPeriodEndAt!)}',
                              ),
                            ),
                          ],
                          if (summary.paywallReason != null) ...<Widget>[
                            const SizedBox(height: 8),
                            Text(
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
                          ],
                          if ((summary.subscriptionStatus == 'active' ||
                                  summary.subscriptionStatus == 'canceling') &&
                              !summary.cancelAtPeriodEnd) ...<Widget>[
                            const SizedBox(height: 12),
                            OutlinedButton(
                              onPressed: _isSubmitting
                                  ? null
                                  : _cancelSubscription,
                              child: Text(
                                _billingText(
                                  'Отменить автопродление',
                                  'Cancel auto-renew',
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 18),
                  _SectionTitle(text: _billingText('Тарифы', 'Plans')),
                  for (final item in _catalog) ...<Widget>[
                    _CatalogCard(
                      item: item,
                      priceLabel: _formatRub(item.finalPriceMinor),
                      oldPriceLabel: item.isSaleActive
                          ? _formatRub(item.basePriceMinor)
                          : null,
                      onBuy: () => _buy(item),
                    ),
                    const SizedBox(height: 12),
                  ],
                  const SizedBox(height: 18),
                  _SectionTitle(text: _billingText('История', 'History')),
                  if (_history.isEmpty)
                    AetherCard(
                      child: Text(
                        _billingText(
                          'История платежей пока пустая.',
                          'Your payment history is empty for now.',
                        ),
                      ),
                    )
                  else
                    AetherCard(
                      child: Column(
                        children: _history
                            .take(8)
                            .map(
                              (final item) => ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(item.title),
                                subtitle: Text(
                                  '${_formatDate(item.createdAt)} · ${item.status}',
                                ),
                                trailing: Text(_formatRub(item.amountMinor)),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  const SizedBox(height: 18),
                  _SectionTitle(
                    text: _billingText('Юридическая информация', 'Legal'),
                  ),
                  AetherCard(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: <Widget>[
                        OutlinedButton(
                          onPressed: () => _openLegal('/offer.html'),
                          child: Text(_billingText('Оферта', 'Offer')),
                        ),
                        OutlinedButton(
                          onPressed: () => _openLegal('/privacy.html'),
                          child: Text(
                            _billingText('Конфиденциальность', 'Privacy'),
                          ),
                        ),
                        OutlinedButton(
                          onPressed: () => _openLegal('/refunds.html'),
                          child: Text(_billingText('Возвраты', 'Refunds')),
                        ),
                        OutlinedButton(
                          onPressed: () => _openLegal('/contacts.html'),
                          child: Text(_billingText('Контакты', 'Contacts')),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  String _billingText(final String ru, final String en) =>
      context.l10n.language.name == 'ru' ? ru : en;

  String _formatTokens(final int value) => value.toString();

  String _formatRub(final int minor) {
    final double rub = minor / 100.0;
    return '${rub.toStringAsFixed(rub.truncateToDouble() == rub ? 0 : 2)} RUB';
  }

  String _formatDate(final DateTime value) {
    final DateTime local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}.${local.year}';
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(final BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Text(text, style: Theme.of(context).textTheme.headlineSmall),
  );
}

class _CatalogCard extends StatelessWidget {
  const _CatalogCard({
    required this.item,
    required this.priceLabel,
    required this.oldPriceLabel,
    required this.onBuy,
  });

  final SymmetryBillingCatalogItem item;
  final String priceLabel;
  final String? oldPriceLabel;
  final VoidCallback onBuy;

  @override
  Widget build(final BuildContext context) => AetherCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                item.title,
                style: Theme.of(context).textTheme.titleLarge,
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
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(item.description),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            if (oldPriceLabel != null) ...<Widget>[
              Text(
                oldPriceLabel!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  decoration: TextDecoration.lineThrough,
                  color: AetherPalette.textMuted,
                ),
              ),
              const SizedBox(width: 10),
            ],
            Text(priceLabel, style: Theme.of(context).textTheme.headlineSmall),
          ],
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: onBuy,
          child: Text(
            context.l10n.language.name == 'ru'
                ? (item.isSubscription ? 'Оплатить подписку' : 'Купить')
                : (item.isSubscription ? 'Start subscription' : 'Buy now'),
          ),
        ),
      ],
    ),
  );
}
