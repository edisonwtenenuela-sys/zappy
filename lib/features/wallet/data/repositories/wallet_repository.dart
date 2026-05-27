import 'package:zappy/core/data/fake_api_client.dart';
import 'package:zappy/features/wallet/data/wallet_mock_data.dart';
import 'package:zappy/features/wallet/domain/wallet_summary.dart';

class WalletRepository {
  WalletRepository({FakeApiClient? apiClient}) : _apiClient = apiClient ?? const FakeApiClient();

  final FakeApiClient _apiClient;

  Future<WalletSummary> fetchWalletSummary() {
    return _apiClient.request(
      () => const WalletSummary(
        balanceCoins: WalletMockData.balanceCoins,
        estimatedUsd: WalletMockData.estimatedUsd,
        packages: WalletMockData.packages,
        gifts: WalletMockData.gifts,
        transactions: WalletMockData.transactions,
      ),
    );
  }
}
