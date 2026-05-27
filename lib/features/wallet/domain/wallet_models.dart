class CoinPackage {
  const CoinPackage({required this.coins, required this.priceUsd, required this.isPopular});

  final int coins;
  final double priceUsd;
  final bool isPopular;
}

class GiftItem {
  const GiftItem({required this.name, required this.coinCost, required this.emoji});

  final String name;
  final int coinCost;
  final String emoji;
}

class WalletTransaction {
  const WalletTransaction({
    required this.title,
    required this.dateLabel,
    required this.amountLabel,
    required this.isPositive,
  });

  final String title;
  final String dateLabel;
  final String amountLabel;
  final bool isPositive;
}
