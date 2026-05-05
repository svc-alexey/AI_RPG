import 'package:ai_prg/src/app/app_providers.dart';
import 'package:ai_prg/src/app/responsive.dart';
import 'package:ai_prg/src/core/models/billing_models.dart';
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
  bool _loading = true;
  String? _error;
  int _animatedTokens = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = ref.read(billingRepositoryProvider);
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
      final results = await Future.wait([
        repo.fetchCatalog(),
        repo.fetchWallet(),
      ]);
      if (!mounted) return;
      setState(() {
        _plans = results[0] as List<BillingPlan>;
        _previousWallet = _wallet;
        _wallet = results[1] as BillingWallet;
        _animatedTokens = _wallet!.totalTokensRemaining;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _checkout(final String planCode) async {
    final repo = ref.read(billingRepositoryProvider);
    // Double-click protection
    setState(() {});
    try {
      final result = await repo.createCheckout(
        planCode: planCode,
        returnUrl: '/',
      );
      if (!mounted) return;
      await launchUrl(Uri.parse(result.confirmationUrl), mode: LaunchMode.externalApplication);
      // Start polling for payment confirmation
      _startPolling();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: Colors.red.shade800,
          action: SnackBarAction(label: 'Try again', onPressed: () => _checkout(planCode)),
        ),
      );
    }
  }

  void _startPolling() {
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
        final prevTotal = _previousWallet?.totalTokensRemaining ?? _wallet?.totalTokensRemaining ?? 0;
        if (wallet.totalTokensRemaining > prevTotal) {
          setState(() {
            _previousWallet = _wallet;
            _wallet = wallet;
            _animatedTokens = wallet.totalTokensRemaining;
          });
          ref.read(_pollingStateProvider.notifier).state = _PollingState.confirmed;
          return false;
        }
        if (attempts >= 15) {
          ref.read(_pollingStateProvider.notifier).state = _PollingState.timeout;
          return false;
        }
        return true;
      } catch (_) {
        if (attempts >= 15) {
          ref.read(_pollingStateProvider.notifier).state = _PollingState.timeout;
          return false;
        }
        return true;
      }
    });
  }

  void _claimWelcome() async {
    try {
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Claim failed: $e')),
      );
    }
  }

  @override
  Widget build(final BuildContext context) {
    final AppResponsiveData responsive = context.responsive;
    final polling = ref.watch(_pollingStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0908),
      appBar: AppBar(
        title: const Text('Tokens & Subscriptions'),
        backgroundColor: const Color(0xFF0A0908),
        elevation: 0,
        actions: [
          if (polling == _PollingState.polling)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFBFA76F)),
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
              ? _buildError()
              : _buildContent(responsive),
    );
  }

  Widget _buildError() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.cloud_off, size: 48, color: Color(0xFF7A7570)),
        const SizedBox(height: 16),
        const Text(
          'Balance unavailable',
          style: TextStyle(color: Color(0xFF7A7570), fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: _load, child: const Text('Retry')),
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

  Widget _buildContent(final AppResponsiveData responsive) {
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
                _HeroBalanceCard(
                  wallet: wallet,
                  animatedTokens: _animatedTokens,
                  polling: polling,
                ),
                const SizedBox(height: 32),
                const Text(
                  'Acquire Essence',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFE8E4E0),
                    fontFamily: 'Playfair Display',
                  ),
                ),
                const SizedBox(height: 16),
                ...plans.map((final plan) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _TariffCard(
                    plan: plan,
                    hasWelcome: wallet.hasWelcomeGrant,
                    onTap: () => _onPlanTap(plan),
                  ),
                )),
                const SizedBox(height: 40),
                const _LegalFooter(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onPlanTap(final BillingPlan plan) {
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
  });

  final BillingWallet wallet;
  final int animatedTokens;
  final _PollingState polling;

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
        border: Border.all(color: borderColor, width: polling == _PollingState.confirmed ? 2.0 : 1.0),
        boxShadow: polling == _PollingState.confirmed
            ? [BoxShadow(color: const Color(0xFF34D399).withAlpha(40), blurRadius: 16)]
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
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFBFA76F)),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Confirming…',
                      style: TextStyle(color: Color(0xFFBFA76F), fontSize: 13),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 4),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Available Essence',
              style: TextStyle(color: Color(0xFF7A7570), fontSize: 15),
            ),
          ),
          if (wallet.totalTokensRemaining < 1000 && wallet.totalTokensRemaining > 0)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFBFA76F).withAlpha(25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Essence running low — ${wallet.totalTokensRemaining} remaining',
                  style: const TextStyle(color: Color(0xFFBFA76F), fontSize: 12),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              _BalanceChip(label: '${_formatTokens(wallet.welcomeTokensRemaining)} welcome'),
              const SizedBox(width: 8),
              _BalanceChip(label: '${_formatTokens(wallet.subscriptionTokensRemaining)} monthly'),
              const SizedBox(width: 8),
              _BalanceChip(label: '${_formatTokens(wallet.paidTokensRemaining)} permanent'),
            ],
          ),
        ],
      ),
    );
  }
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
    child: Text(label, style: const TextStyle(color: Color(0xFFBFA76F), fontSize: 12)),
  );
}

class _TariffCard extends StatelessWidget {
  const _TariffCard({
    required this.plan,
    required this.hasWelcome,
    required this.onTap,
  });

  final BillingPlan plan;
  final bool hasWelcome;
  final VoidCallback onTap;

  bool get _isFeatured => plan.featured;
  bool get _isWelcome => plan.kind == 'welcome';
  bool get _isClaimed => _isWelcome && hasWelcome;

  @override
  Widget build(final BuildContext context) {
    if (_isClaimed) {
      return _buildMinimal(context);
    }
    if (_isFeatured) {
      return _buildFeatured(context);
    }
    return _buildStandard(context);
  }

  Widget _buildFeatured(final BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF0F0D0B),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFC87941), width: 1.5),
      boxShadow: [BoxShadow(color: const Color(0xFFC87941).withAlpha(15), blurRadius: 12)],
    ),
    padding: const EdgeInsets.all(20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Pro Monthly',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFE8E4E0),
                ),
              ),
            ),
            if (plan.saleBadgeText != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFBFA76F).withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  plan.saleBadgeText!,
                  style: const TextStyle(color: Color(0xFFBFA76F), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Auto-renews monthly. Cancel anytime.',
          style: TextStyle(color: Color(0xFF7A7570), fontSize: 13),
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
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC87941),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Subscribe', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFBFA76F).withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  plan.saleBadgeText!,
                  style: const TextStyle(color: Color(0xFFBFA76F), fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(plan.description, style: const TextStyle(color: Color(0xFF7A7570), fontSize: 13)),
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
            onPressed: onTap,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC87941),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Buy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    ),
  );

  Widget _buildMinimal(final BuildContext context) => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFF7A7570).withAlpha(30), strokeAlign: BorderSide.strokeAlignInside),
    ),
    padding: const EdgeInsets.all(20),
    child: Row(
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF34D399), size: 24),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome Pack — Claimed', style: TextStyle(color: Color(0xFFE8E4E0), fontSize: 16)),
            Text('1,000,000 tokens granted', style: TextStyle(color: Color(0xFF7A7570), fontSize: 13)),
          ],
        ),
      ],
    ),
  );
}

class _CheckoutSheet extends StatefulWidget {
  const _CheckoutSheet({required this.plan, required this.onPay});

  final BillingPlan plan;
  final VoidCallback onPay;

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
        Text(widget.plan.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFFE8E4E0))),
        const SizedBox(height: 8),
        Text(
          widget.plan.priceLabel,
          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, fontFamily: 'Playfair Display', color: Color(0xFFC87941)),
        ),
        if (widget.plan.kind == 'subscription') ...[
          const SizedBox(height: 8),
          const Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Color(0xFF7A7570)),
              SizedBox(width: 6),
              Text('Auto-renews monthly. Cancel anytime.', style: TextStyle(color: Color(0xFF7A7570), fontSize: 12)),
            ],
          ),
        ],
        const Divider(height: 32, color: Color(0x20FFFFFF)),
        Row(
          children: [
            Checkbox(
              value: _agreed,
              onChanged: (final v) => setState(() => _agreed = v ?? false),
              activeColor: const Color(0xFFC87941),
              checkColor: Colors.white,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _agreed = !_agreed),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Color(0xFFE8E4E0), fontSize: 13),
                    children: [
                      const TextSpan(text: 'I accept the '),
                      TextSpan(
                        text: 'Offer',
                        style: TextStyle(color: const Color(0xFFC87941), decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()..onTap = () => launchUrl(Uri.parse('https://beyondtheverge.online/offer.html'), mode: LaunchMode.externalApplication),
                      ),
                      const TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(color: const Color(0xFFC87941), decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()..onTap = () => launchUrl(Uri.parse('https://beyondtheverge.online/privacy.html'), mode: LaunchMode.externalApplication),
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
            onPressed: (_agreed && !_paying) ? () {
              setState(() => _paying = true);
              widget.onPay();
            } : null,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC87941),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _paying
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text('Pay ${widget.plan.priceLabel}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
        ),
      ],
    ),
  );
}

class _LegalFooter extends StatelessWidget {
  const _LegalFooter();

  @override
  Widget build(final BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    spacing: 16,
    runSpacing: 8,
    children: [
      _legalLink('Offer', 'https://beyondtheverge.online/offer.html'),
      _legalLink('Privacy', 'https://beyondtheverge.online/privacy.html'),
      _legalLink('Support', 'https://beyondtheverge.online/contacts.html'),
      _legalLink('Refunds', 'https://beyondtheverge.online/refunds.html'),
      const Text('© 2026 AI RPG', style: TextStyle(color: Color(0xFF7A7570), fontSize: 12)),
    ],
  );

  Widget _legalLink(final String label, final String url) => GestureDetector(
    onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
    child: Text(label, style: const TextStyle(color: Color(0xFF7A7570), fontSize: 12, decoration: TextDecoration.underline)),
  );
}

void showPaywallOverlay(final BuildContext context, {final String? campaignName}) {
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
            child: const Icon(Icons.token, size: 32, color: Color(0xFFC87941)),
          ),
          const SizedBox(height: 20),
          const Text(
            'Not Enough Essence',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: 'Playfair Display',
              color: Color(0xFFE8E4E0),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            campaignName != null
                ? 'Your essence fades mid-journey in "$campaignName". Acquire more tokens to continue.'
                : 'Your arcane reserves are depleted. Acquire more tokens to continue your journey.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF7A7570), fontSize: 14),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (final _) => const BillingScreen()),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC87941),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Buy Tokens', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Not Now', style: TextStyle(color: Color(0xFF7A7570))),
          ),
        ],
      ),
    ),
  );
}
