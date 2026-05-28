import 'package:zappy/core/data/api_client.dart';
import 'package:zappy/features/wallet/data/wallet_mock_data.dart';
import 'package:zappy/features/wallet/domain/wallet_models.dart';
import 'package:zappy/features/wallet/domain/wallet_summary.dart';

class WalletRepository {
  WalletRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  Future<WalletSummary> fetchWalletSummary() async {
    try {
      final json = await _apiClient.getJson('/api/wallet/summary');
      final data = json['data'] as Map<String, dynamic>?;
      if (data == null) throw Exception('Missing wallet data');

      final packages = (data['packages'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => CoinPackage(
              coins: (item['coins'] as num?)?.toInt() ?? 0,
              priceUsd: (item['priceUsd'] as num?)?.toDouble() ?? 0,
              isPopular: item['isPopular'] == true,
            ),
          )
          .toList();

      final gifts = (data['gifts'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => GiftItem(
              name: item['name']?.toString() ?? '',
              coinCost: (item['coinCost'] as num?)?.toInt() ?? 0,
              emoji: item['emoji']?.toString() ?? '🎁',
            ),
          )
          .toList();

      final transactions = (data['transactions'] as List<dynamic>? ?? <dynamic>[])
          .whereType<Map<String, dynamic>>()
          .map(
            (item) => WalletTransaction(
              title: item['title']?.toString() ?? '',
              dateLabel: item['dateLabel']?.toString() ?? '',
              amountLabel: item['amountLabel']?.toString() ?? '',
              isPositive: item['isPositive'] == true,
            ),
          )
          .toList();

      return WalletSummary(
        balanceCoins: (data['balanceCoins'] as num?)?.toInt() ?? 0,
        estimatedUsd: (data['estimatedUsd'] as num?)?.toDouble() ?? 0,
        packages: packages,
        gifts: gifts,
        transactions: transactions,
      );
    } catch (_) {
      return const WalletSummary(
        balanceCoins: WalletMockData.balanceCoins,
        estimatedUsd: WalletMockData.estimatedUsd,
        packages: WalletMockData.packages,
        gifts: WalletMockData.gifts,
        transactions: WalletMockData.transactions,
      );
    }
  }
}
