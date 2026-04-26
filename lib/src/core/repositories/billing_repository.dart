import 'package:ai_prg/src/core/models/symmetry_models.dart';
import 'package:ai_prg/src/core/repositories/symmetry_auth_repository.dart';
import 'package:ai_prg/src/core/services/symmetry_api_client.dart';

class BillingRepository {
  BillingRepository({required SymmetryAuthRepository authRepository})
    : _authRepository = authRepository;

  final SymmetryAuthRepository _authRepository;

  SymmetryApiClient _client(final String baseUrl) =>
      SymmetryApiClient(baseUrl: baseUrl);

  Future<String> _loadBaseUrl() => _authRepository.loadBaseUrl();

  Future<SymmetrySession?> _loadSession() => _authRepository.loadSession();

  Future<List<SymmetryBillingCatalogItem>> loadCatalog() async {
    final String baseUrl = await _loadBaseUrl();
    final SymmetrySession? session = await _loadSession();
    return _client(
      baseUrl,
    ).getBillingCatalog(accessToken: session?.tokens.accessToken);
  }

  Future<SymmetryBillingSummary> loadSummary() async {
    final String baseUrl = await _loadBaseUrl();
    final SymmetrySession? session = await _loadSession();
    return _client(
      baseUrl,
    ).getBillingSummary(accessToken: session?.tokens.accessToken);
  }

  Future<List<SymmetryBillingHistoryItem>> loadHistory() =>
      _authRepository.runWithAuthorizedSession(
        (final session) => _client(
          session.baseUrl,
        ).getBillingHistory(accessToken: session.tokens.accessToken),
        allowGuest: false,
      );

  Future<SymmetryBillingCheckout> createCheckout({
    required final String planCode,
  }) => _authRepository.runWithAuthorizedSession(
    (final session) => _client(session.baseUrl).createBillingCheckout(
      accessToken: session.tokens.accessToken,
      planCode: planCode,
    ),
    allowGuest: false,
  );

  Future<SymmetryBillingOrderStatus> loadOrderStatus({
    required final String orderId,
  }) => _authRepository.runWithAuthorizedSession(
    (final session) => _client(session.baseUrl).getBillingOrderStatus(
      accessToken: session.tokens.accessToken,
      orderId: orderId,
    ),
    allowGuest: false,
  );

  Future<SymmetryBillingSummary> cancelSubscription() =>
      _authRepository.runWithAuthorizedSession(
        (final session) => _client(
          session.baseUrl,
        ).cancelBillingSubscription(accessToken: session.tokens.accessToken),
        allowGuest: false,
      );
}
