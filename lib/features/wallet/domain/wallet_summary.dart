import 'package:zappy/features/wallet/domain/wallet_models.dart';

class WalletSummary {
  const WalletSummary({
    required this.balanceCoins,
    required this.estimatedUsd,
    required this.packages,
    required this.gifts,
    required this.transactions,
  });

  final int balanceCoins;
  final double estimatedUsd;
  final List<CoinPackage> packages;
  final List<GiftItem> gifts;
  final List<WalletTransaction> transactions;
}
