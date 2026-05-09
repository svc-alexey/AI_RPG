import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/core/models/billing_models.dart';
import 'package:ai_prg/src/features/auth/presentation/auth_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

final _pollingStateProvider =
    StateProvider<_PollingState>((final ref) => _PollingState.idle);

enum _PollingState { idle, polling, confirmed, timeout }

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  List<BillingPlan>? _plans;
  BillingWallet? _wallet;
  BillingWallet? _previousWallet;
  List<TransactionEntry>? _transactions;
  bool _loading = true;
  String? _error;
  String? _transactionsError;
  bool _offline = false;
  int _animatedTokens = 0;
  late final AppLifecycleListener _lifecycleObserver;

  bool get _isGuest {
    final session = ref.read(symmetrySessionProvider).valueOrNull;
    return session?.isGuest ?? true;
  }

  bool get _needsVerification {
    if (_isGuest) return false;
    final session = ref.read(symmetrySessionProvider).valueOrNull;
    if (session == null) return false;
    return !session.isEmailVerified;
  }

  bool get _blocked => _isGuest || _needsVerification;

  @override
  void initState() {
    super.initState();
    _lifecycleObserver = AppLifecycleListener(
      onResume: () => _checkPendingPayments(),
    );
    WidgetsBinding.instance.addObserver(_lifecycleObserver);
    _load();
    _checkPendingPayments();
  }

  @override
  void dispose() {
    _lifecycleObserver.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
      _offline = false;
    });
    try {
      final repo = ref.read(billingRepositoryProvider);

      if (!_blocked) {
        final cachedCatalog = await repo.loadCachedCatalog();
        final cachedWallet = await repo.loadCachedWallet();
        if (cachedCatalog != null) {
          setState(() {
            _plans = cachedCatalog;
            if (cachedWallet != null) {
              _previousWallet = _wallet;
              _wallet = cachedWallet;
              _animatedTokens = cachedWallet.totalTokensRemaining;
            }
          });
        }
      }

      if (_blocked) {
        final catalog = await repo.fetchCatalog();
        BillingWallet wallet;
        try {
          wallet = await repo.fetchWallet();
        } catch (_) {
          wallet = const BillingWallet();
        }
        if (!mounted) return;
        setState(() {
          _plans = catalog;
          _wallet = wallet;
          _animatedTokens = wallet.totalTokensRemaining;
          _transactions = [];
          _loading = false;
        });
      } else {
        final results = await Future.wait([
          repo.fetchCatalog(),
          repo.fetchWallet(),
          repo.fetchTransactions().catchError((final _) => <TransactionEntry>[]),
        ]);
        if (!mounted) return;
        setState(() {
          _plans = results[0] as List<BillingPlan>;
          _previousWallet = _wallet;
          _wallet = results[1] as BillingWallet;
          _animatedTokens = _wallet!.totalTokensRemaining;
          _transactions = results[2] as List<TransactionEntry>;
          _loading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      if (_plans != null && _wallet != null) {
        setState(() {
          _offline = true;
          _loading = false;
        });
      } else {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _checkout(final String planCode) async {
    final repo = ref.read(billingRepositoryProvider);
    setState(() {});
    try {
      final result = await repo.createCheckout(
        planCode: planCode,
        returnUrl: '/',
      );
      if (!mounted) return;
      await repo.savePendingOrderId(result.orderId);
      await launchUrl(Uri.parse(result.confirmationUrl),
          mode: LaunchMode.externalApplication);
      _startPolling(result.orderId);
    } catch (e) {
      if (!mounted) return;
      final l10n = context.l10n;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.billingPaymentFailed}: $e'),
          backgroundColor: Colors.red.shade800,
          action: SnackBarAction(
            label: l10n.billingTryAgain,
            onPressed: () => _checkout(planCode),
          ),
        ),
      );
    }
  }

  void _startPolling(final String orderId) {
    ref.read(_pollingStateProvider.notifier).state = _PollingState.polling;
    int attempts = 0;
    Future.doWhile(() async {
      await Future<void>.delayed(const Duration(seconds: 2));
      attempts++;
      if (!mounted) return false;
      try {
        final repo = ref.read(billingRepositoryProvider);
        final wallet = await repo.fetchWallet();
        if (!mounted) return false;
        final prevTotal = _previousWallet?.totalTokensRemaining ??
            _wallet?.totalTokensRemaining ??
            0;
        if (wallet.totalTokensRemaining > prevTotal) {
          setState(() {
            _previousWallet = _wallet;
            _wallet = wallet;
            _animatedTokens = wallet.totalTokensRemaining;
          });
          ref.read(_pollingStateProvider.notifier).state =
              _PollingState.confirmed;
          await repo.clearPendingOrderId();
          return false;
        }
        // Fallback: check order status at YooKassa
        final orderStatus = await repo.getOrderStatus(orderId);
        if (orderStatus != null) {
          if (orderStatus['status'] == 'succeeded') {
            final freshWallet = await repo.fetchWallet();
            await repo.clearPendingOrderId();
            if (!mounted) return false;
            setState(() {
              _previousWallet = _wallet;
              _wallet = freshWallet;
              _animatedTokens = freshWallet.totalTokensRemaining;
            });
            ref.read(_pollingStateProvider.notifier).state =
                _PollingState.confirmed;
            return false;
          } else if (orderStatus['status'] == 'canceled') {
            await repo.clearPendingOrderId();
            ref.read(_pollingStateProvider.notifier).state =
                _PollingState.idle;
            return false;
          }
        }
        if (attempts >= 30) {
          ref.read(_pollingStateProvider.notifier).state =
              _PollingState.timeout;
          return false;
        }
        return true;
      } catch (_) {
        if (attempts >= 30) {
          ref.read(_pollingStateProvider.notifier).state =
              _PollingState.timeout;
          return false;
        }
        return true;
      }
    });
  }

  void _claimWelcome() async {
    final l10n = context.l10n;
    try {
      final repo = ref.read(billingRepositoryProvider);
      final wallet = await repo.claimWelcomeGrant();
      if (!mounted) return;
      setState(() {
        _previousWallet = _wallet;
        _wallet = wallet;
        _animatedTokens = wallet.totalTokensRemaining;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${l10n.billingWelcomeClaimError}: $e'),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }

  Future<void> _checkPendingPayments() async {
    final repo = ref.read(billingRepositoryProvider);
    final pendingOrderId = await repo.getPendingOrderId();
    if (pendingOrderId == null) return;

    try {
      final orderStatus = await repo.getOrderStatus(pendingOrderId);
      if (orderStatus == null) return;

      if (orderStatus['status'] == 'succeeded') {
        final wallet = await repo.fetchWallet();
        await repo.clearPendingOrderId();
        if (!mounted) return;
        setState(() {
          _previousWallet = _wallet;
          _wallet = wallet;
          _animatedTokens = wallet.totalTokensRemaining;
        });
        ref.read(_pollingStateProvider.notifier).state = _PollingState.confirmed;
      } else if (orderStatus['status'] == 'canceled') {
        await repo.clearPendingOrderId();
        ref.read(_pollingStateProvider.notifier).state = _PollingState.idle;
      }
    } catch (_) {
      // Сетевая ошибка — проверим при следующем открытии
    }
  }

  @override
  Widget build(final BuildContext context) {
    final l10n = context.l10n;
    final AppResponsiveData responsive = context.responsive;
    final polling = ref.watch(_pollingStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0908),
      appBar: AppBar(
        title: Text(l10n.billingTitle),
        backgroundColor: const Color(0xFF0A0908),
        elevation: 0,
        actions: [
          if (polling == _PollingState.polling)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: const Color(0xFFBFA76F)),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: _loading
          ? _buildShimmer(responsive)
          : _error != null
              ? _buildError(l10n)
              : _buildContent(responsive, l10n),
    );
  }

  Widget _buildError(final AppLocalizations l10n) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Color(0xFF7A7570)),
            const SizedBox(height: 16),
            Text(
              l10n.billingBalanceUnavailable,
              style: const TextStyle(color: Color(0xFF7A7570), fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _load,
              child: Text(l10n.billingRetry),
            ),
          ],
        ),
      );

  Widget _buildShimmer(final AppResponsiveData responsive) {
    final maxWidth = responsive.dialogMaxWidth;
    return Center(
      child: SizedBox(
        width: maxWidth,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: responsive.pagePadding),
          child: Column(
            children: [
              const SizedBox(height: 24),
              _shimmerBox(200, 24),
              const SizedBox(height: 12),
              _shimmerBox(120, 16),
              const SizedBox(height: 12),
              _shimmerBox(180, 12),
              const SizedBox(height: 32),
              _shimmerBox(double.infinity, 96),
              const SizedBox(height: 16),
              _shimmerBox(double.infinity, 96),
              const SizedBox(height: 16),
              _shimmerBox(double.infinity, 96),
            ],
          ),
        ),
      ),
    );
  }

  Widget _shimmerBox(final double width, final double height) => Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(8),
          borderRadius: BorderRadius.circular(8),
        ),
      );

  Widget _buildContent(
      final AppResponsiveData responsive, final AppLocalizations l10n) {
    final maxWidth = responsive.dialogMaxWidth;
    final wallet = _wallet!;
    final plans = _plans!;
    final polling = ref.watch(_pollingStateProvider);

    return SingleChildScrollView(
      child: Center(
        child: SizedBox(
          width: maxWidth,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: responsive.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                if (_offline) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBFA76F).withAlpha(25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.cloud_off,
                            size: 18, color: Color(0xFFBFA76F)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.billingOfflineBanner,
                            style: const TextStyle(
                                color: Color(0xFFBFA76F), fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_blocked)
                  _GuestBalanceHint(l10n: l10n)
                else ...[
                  _HeroBalanceCard(
                    wallet: wallet,
                    animatedTokens: _animatedTokens,
                    polling: polling,
                    l10n: l10n,
                  ),
                  if (polling == _PollingState.timeout) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.schedule,
                            size: 16, color: Color(0xFFBFA76F)),
                        const SizedBox(width: 6),
                        Text(
                          l10n.billingStillProcessing,
                          style: const TextStyle(
                              color: Color(0xFFBFA76F), fontSize: 13),
                        ),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () {
                            ref
                                .read(_pollingStateProvider.notifier)
                                .state = _PollingState.idle;
                            _load();
                          },
                          child: Text(l10n.billingCheckAgain,
                              style: const TextStyle(fontSize: 13)),
                        ),
                      ],
                    ),
                  ],
                ],
                const SizedBox(height: 32),
                Text(
                  l10n.billingAcquireEssence,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE8E4E0),
                    fontFamily: 'Playfair Display',
                  ),
                ),
                if (_blocked)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      l10n.billingGuestLoginToBuy,
                      style: const TextStyle(
                          color: Color(0xFF7A7570), fontSize: 13),
                    ),
                  ),
                const SizedBox(height: 16),
                ...plans.map((final plan) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _TariffCard(
                        plan: plan,
                        hasWelcome: wallet.hasWelcomeGrant,
                        onTap: () => _onPlanTap(plan),
                        l10n: l10n,
                        isGuest: _blocked,
                      ),
                    )),
                if (!_blocked)
                  const SizedBox(height: 32),
                if (!_blocked)
                  _ChronicleSection(
                    transactions: _transactions,
                    error: _transactionsError,
                    l10n: l10n,
                  ),
                const SizedBox(height: 40),
                _LegalFooter(l10n: l10n),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _redirectToAuth() async {
    ref.read(deferredActionProvider.notifier).state = () async {
      _load();
    };
    if (!mounted) return;
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (final routeContext) => AuthScreen(
          onAuthenticated: () {
            final deferred =
                ref.read(deferredActionProvider.notifier).state;
            if (deferred != null) {
              deferred().then((final _) {
                ref.read(deferredActionProvider.notifier).state = null;
              });
            }
            Navigator.of(routeContext).pop(true);
          },
        ),
      ),
    );
    ref.invalidate(symmetrySessionProvider);
  }

  void _onPlanTap(final BillingPlan plan) {
    if (_blocked) {
      _redirectToAuth();
      return;
    }
    final l10n = context.l10n;
    if (plan.kind == 'welcome') {
      _claimWelcome();
    } else if (plan.effectivePriceMinor == 0) {
      _checkout(plan.code);
    } else {
      showModalBottomSheet<void>(
        context: context,
        backgroundColor: const Color(0xFF0F0D0B),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (final ctx) => _CheckoutSheet(
          plan: plan,
          onPay: () {
            Navigator.of(ctx).pop();
            _checkout(plan.code);
          },
          l10n: l10n,
        ),
      );
    }
  }
}

class _HeroBalanceCard extends StatelessWidget {
  const _HeroBalanceCard({
    required this.wallet,
    required this.animatedTokens,
    required this.polling,
    required this.l10n,
  });

  final BillingWallet wallet;
  final int animatedTokens;
  final _PollingState polling;
  final AppLocalizations l10n;

  String _formatTokens(final int tokens) {
    if (tokens >= 1_000_000) {
      return '${(tokens / 1_000_000).toStringAsFixed(1)}M';
    }
    if (tokens >= 1_000) {
      return '${(tokens / 1_000).toStringAsFixed(0)}K';
    }
    return tokens.toString();
  }

  @override
  Widget build(final BuildContext context) {
    final Color borderColor = polling == _PollingState.confirmed
        ? const Color(0xFF34D399)
        : polling == _PollingState.polling
            ? const Color(0xFFBFA76F)
            : const Color(0xFFC87941).withAlpha(50);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0D0B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: borderColor,
            width: polling == _PollingState.confirmed ? 2.0 : 1.0),
        boxShadow: polling == _PollingState.confirmed
            ? [
                BoxShadow(
                    color: const Color(0xFF34D399).withAlpha(40),
                    blurRadius: 16)
              ]
            : null,
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            children: [
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: 0, end: animatedTokens),
                duration: const Duration(milliseconds: 800),
                builder: (final context, final value, final child) => Text(
                  _formatTokens(value),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Playfair Display',
                    color: Color(0xFFC87941),
                  ),
                ),
              ),
              const Spacer(),
              if (polling == _PollingState.polling)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xFFBFA76F)),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.billingConfirming,
                      style: const TextStyle(
                          color: Color(0xFFBFA76F), fontSize: 13),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              l10n.billingAvailableEssence,
              style:
                  const TextStyle(color: Color(0xFF7A7570), fontSize: 15),
            ),
          ),
          if (wallet.totalTokensRemaining < 1000 &&
              wallet.totalTokensRemaining > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFBFA76F).withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  l10n.billingEssenceLow(wallet.totalTokensRemaining),
                  style: const TextStyle(
                      color: Color(0xFFBFA76F), fontSize: 12),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              _BalanceChip(
                  label:
                      '${_formatTokens(wallet.welcomeTokensRemaining)} ${l10n.billingWelcomePermanent}'),
              const SizedBox(width: 8),
              _BalanceChip(
                  label:
                      '${_formatTokens(wallet.subscriptionTokensRemaining)} ${l10n.billingMonthly}'),
              const SizedBox(width: 8),
              _BalanceChip(
                  label:
                      '${_formatTokens(wallet.paidTokensRemaining)} ${l10n.billingPermanent}'),
            ],
          ),
        ],
      ),
    );
  }
}

class _GuestBalanceHint extends StatelessWidget {
  const _GuestBalanceHint({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F0D0B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFC87941).withAlpha(50)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.lock_outline, size: 32, color: Color(0xFF7A7570)),
            const SizedBox(height: 12),
            Text(
              l10n.billingGuestBalanceHint,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF7A7570),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
}

class _BalanceChip extends StatelessWidget {
  const _BalanceChip({required this.label});
  final String label;

  @override
  Widget build(final BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFC87941).withAlpha(15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style:
                const TextStyle(color: Color(0xFFBFA76F), fontSize: 12)),
      );
}

String _planTitle(final BillingPlan plan, final AppLocalizations l10n) {
  if (plan.kind == 'token_pack') {
    if (plan.tokenGrant == 10_000_000) return l10n.billingPack10mTitle;
    if (plan.tokenGrant == 100_000_000) return l10n.billingPack100mTitle;
  }
  return plan.title;
}

String _planDesc(final BillingPlan plan, final AppLocalizations l10n) {
  if (plan.kind == 'token_pack') {
    if (plan.tokenGrant == 10_000_000) return l10n.billingPack10mDesc;
    if (plan.tokenGrant == 100_000_000) return l10n.billingPack100mDesc;
  }
  return plan.description;
}

class _TariffCard extends StatelessWidget {
  const _TariffCard({
    required this.plan,
    required this.hasWelcome,
    required this.onTap,
    required this.l10n,
    this.isGuest = false,
  });

  final BillingPlan plan;
  final bool hasWelcome;
  final VoidCallback onTap;
  final AppLocalizations l10n;
  final bool isGuest;

  bool get _isFeatured => plan.featured;
  bool get _isWelcome => plan.kind == 'welcome';
  bool get _isClaimed => _isWelcome && hasWelcome;

  @override
  Widget build(final BuildContext context) {
    if (_isClaimed) return _buildMinimal(context);
    if (_isFeatured) return _buildFeatured(context);
    return _buildStandard(context);
  }

  Widget _buildFeatured(final BuildContext context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F0D0B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFC87941), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFFC87941).withAlpha(15),
                blurRadius: 12)
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    _planTitle(plan, l10n),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE8E4E0),
                    ),
                  ),
                ),
                if (plan.saleBadgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBFA76F).withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      plan.saleBadgeText!,
                      style: const TextStyle(
                          color: Color(0xFFBFA76F),
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _planDesc(plan, l10n),
              style:
                  const TextStyle(color: Color(0xFF7A7570), fontSize: 13),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  plan.priceLabel,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Playfair Display',
                    color: Color(0xFFC87941),
                  ),
                ),
                if (plan.oldPriceLabel != null) ...[
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      plan.oldPriceLabel!,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF7A7570),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: isGuest ? null : onTap,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFC87941),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                    isGuest
                        ? l10n.billingGuestLoginToBuy
                        : l10n.billingSubscribeAction,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      );

  Widget _buildStandard(final BuildContext context) => Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F0D0B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withAlpha(12)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    plan.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFE8E4E0),
                    ),
                  ),
                ),
                if (plan.saleBadgeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFBFA76F).withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      plan.saleBadgeText!,
                      style: const TextStyle(
                          color: Color(0xFFBFA76F),
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(plan.description,
                style:
                    const TextStyle(color: Color(0xFF7A7570), fontSize: 13)),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  plan.priceLabel,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Playfair Display',
                    color: Color(0xFFC87941),
                  ),
                ),
                if (plan.oldPriceLabel != null) ...[
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      plan.oldPriceLabel!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF7A7570),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: isGuest ? null : onTap,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFC87941),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                    isGuest
                        ? l10n.billingGuestLoginToBuy
                        : l10n.billingBuyAction,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      );

  Widget _buildMinimal(final BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFF7A7570).withAlpha(30),
              strokeAlign: BorderSide.strokeAlignInside),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const Icon(Icons.check_circle,
                color: Color(0xFF34D399), size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.billingWelcomeClaimed,
                    style: const TextStyle(
                        color: Color(0xFFE8E4E0), fontSize: 16)),
                Text(l10n.billingWelcomeClaimedDesc,
                    style: const TextStyle(
                        color: Color(0xFF7A7570), fontSize: 13)),
              ],
            ),
          ],
        ),
      );
}

class _CheckoutSheet extends StatefulWidget {
  const _CheckoutSheet(
      {required this.plan, required this.onPay, required this.l10n});

  final BillingPlan plan;
  final VoidCallback onPay;
  final AppLocalizations l10n;

  @override
  State<_CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<_CheckoutSheet> {
  bool _agreed = false;
  bool _paying = false;

  @override
  Widget build(final BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF7A7570).withAlpha(60),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(widget.plan.title,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE8E4E0))),
            const SizedBox(height: 8),
            Text(
              widget.plan.priceLabel,
              style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Playfair Display',
                  color: Color(0xFFC87941)),
            ),
            if (widget.plan.kind == 'subscription') ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 16, color: Color(0xFF7A7570)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(_planDesc(widget.plan, widget.l10n),
                        style: const TextStyle(
                            color: Color(0xFF7A7570), fontSize: 12)),
                  ),
                ],
              ),
            ],
            const Divider(height: 32, color: Color(0x20FFFFFF)),
            Row(
              children: [
                Checkbox(
                  value: _agreed,
                  onChanged: (final v) =>
                      setState(() => _agreed = v ?? false),
                  activeColor: const Color(0xFFC87941),
                  checkColor: Colors.white,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _agreed = !_agreed),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            color: Color(0xFFE8E4E0), fontSize: 13),
                        children: [
                          TextSpan(
                              text: widget.l10n.billingAgreementLabel),
                          TextSpan(
                            text: widget.l10n.billingOfferLink,
                            style: const TextStyle(
                                color: Color(0xFFC87941),
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => launchUrl(
                                  Uri.parse(
                                      'https://beyondtheverge.online/offer.html'),
                                  mode: LaunchMode.externalApplication),
                          ),
                          TextSpan(
                              text: widget.l10n.billingAgreementAnd),
                          TextSpan(
                            text: widget.l10n.billingPrivacyLink,
                            style: const TextStyle(
                                color: Color(0xFFC87941),
                                decoration: TextDecoration.underline),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => launchUrl(
                                  Uri.parse(
                                      'https://beyondtheverge.online/privacy.html'),
                                  mode: LaunchMode.externalApplication),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 52,
              child: FilledButton(
                onPressed: (_agreed && !_paying)
                    ? () {
                        setState(() => _paying = true);
                        widget.onPay();
                      }
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFC87941),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _paying
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(
                        widget.l10n
                            .billingPayLabel(widget.plan.priceLabel),
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      );
}

class _ChronicleSection extends StatelessWidget {
  const _ChronicleSection({
    required this.transactions,
    required this.error,
    required this.l10n,
  });

  final List<TransactionEntry>? transactions;
  final String? error;
  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) {
    if (error != null) {
      return Column(
        children: [
          Text(
            l10n.billingChronicleHistoryUnavailable,
            style:
                const TextStyle(color: Color(0xFF7A7570), fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {},
            child: Text(l10n.billingRetry),
          ),
        ],
      );
    }
    if (transactions == null) {
      return Column(
        children: List.generate(
          3,
          (final i) => Padding(
            padding: EdgeInsets.only(top: i > 0 ? 12 : 0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(8),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 80,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    final txList = transactions!;
    if (txList.isEmpty) {
      return Column(
        children: [
          const Icon(Icons.calendar_today,
              size: 48, color: Color(0xFF7A7570)),
          const SizedBox(height: 12),
          Text(
            l10n.billingChronicleEmpty,
            style: const TextStyle(
                color: Color(0xFF7A7570), fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.billingChronicleEmptyDesc,
            style: const TextStyle(
                color: Color(0xFF7A7570), fontSize: 12),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.billingChronicleTitle,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFFE8E4E0),
            fontFamily: 'Playfair Display',
          ),
        ),
        const SizedBox(height: 16),
        ...txList.map((final tx) => _TransactionItem(tx: tx, l10n: l10n)),
      ],
    );
  }
}

class _TransactionItem extends StatelessWidget {
  const _TransactionItem({required this.tx, required this.l10n});

  final TransactionEntry tx;
  final AppLocalizations l10n;

  String _sourceLabel() {
    return switch (tx.reason) {
      'turn' => l10n.billingChronicleTurn,
      'purchase' => l10n.billingChroniclePurchase,
      'welcome_grant' => l10n.billingChronicleWelcomeGrant,
      'subscription_renewal' => l10n.billingChronicleSubscriptionRenewal,
      _ => tx.reason,
    };
  }

  @override
  Widget build(final BuildContext context) {
    final bool isCredit = tx.isCredit;
    final String dateStr = _formatDate(tx.createdAt);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            tx.reason == 'turn'
                ? Icons.play_circle_outline
                : tx.reason == 'welcome_grant'
                    ? Icons.card_giftcard
                    : isCredit
                        ? Icons.check_circle
                        : Icons.schedule,
            size: 20,
            color: isCredit ? const Color(0xFF34D399) : const Color(0xFFBFA76F),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _sourceLabel(),
                  style: const TextStyle(
                      color: Color(0xFFE8E4E0), fontSize: 14),
                ),
                Text(
                  dateStr,
                  style: const TextStyle(
                      color: Color(0xFF7A7570), fontSize: 11),
                ),
              ],
            ),
          ),
          Text(
            isCredit ? '+${_formatTokens(tx.amount)}' : _formatTokens(tx.amount),
            style: TextStyle(
              color: isCredit
                  ? const Color(0xFF34D399)
                  : const Color(0xFFE8E4E0),
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTokens(final int tokens) {
    final int abs = tokens.abs();
    if (abs >= 1_000_000) return '${(tokens / 1_000_000).toStringAsFixed(1)}M';
    if (abs >= 1_000) return '${(tokens / 1_000).toStringAsFixed(0)}K';
    return tokens.toString();
  }

  String _formatDate(final DateTime dt) {
    final String day = dt.day.toString().padLeft(2, '0');
    final String month = dt.month.toString().padLeft(2, '0');
    return '$day.$month.${dt.year}';
  }
}

class _LegalFooter extends StatelessWidget {
  const _LegalFooter({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(final BuildContext context) => Wrap(
        alignment: WrapAlignment.center,
        spacing: 16,
        runSpacing: 8,
        children: [
          _legalLink(l10n.billingFooterOffer,
              'https://beyondtheverge.online/offer.html'),
          _legalLink(l10n.billingFooterPrivacy,
              'https://beyondtheverge.online/privacy.html'),
          _legalLink(l10n.billingFooterSupport,
              'https://beyondtheverge.online/contacts.html'),
          _legalLink(l10n.billingFooterRefunds,
              'https://beyondtheverge.online/refunds.html'),
          _legalLink(l10n.billingFooterPricing,
              'https://beyondtheverge.online/pricing.html'),
          const Text('© 2026 AI RPG',
              style:
                  TextStyle(color: Color(0xFF7A7570), fontSize: 12)),
        ],
      );

  Widget _legalLink(final String label, final String url) => GestureDetector(
        onTap: () => launchUrl(Uri.parse(url),
            mode: LaunchMode.externalApplication),
        child: Text(label,
            style: const TextStyle(
                color: Color(0xFF7A7570),
                fontSize: 12,
                decoration: TextDecoration.underline)),
      );
}

void showPaywallOverlay(final BuildContext context,
    {final String? campaignName}) {
  final l10n = context.l10n;
  showDialog<void>(
    context: context,
    builder: (final ctx) => AlertDialog(
      backgroundColor: const Color(0xFF0F0D0B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFC87941).withAlpha(20),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.token, size: 32, color: Color(0xFFC87941)),
          ),
          const SizedBox(height: 20),
          Text(
            l10n.billingPaywallTitle,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: 'Playfair Display',
              color: Color(0xFFE8E4E0),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.billingPaywallBody(campaignName),
            textAlign: TextAlign.center,
            style:
                const TextStyle(color: Color(0xFF7A7570), fontSize: 14),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                      builder: (final _) => const BillingScreen()),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC87941),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(l10n.billingBuyTokensAction,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.billingNotNowAction,
                style: const TextStyle(color: Color(0xFF7A7570))),
          ),
        ],
      ),
    ),
  );
}
