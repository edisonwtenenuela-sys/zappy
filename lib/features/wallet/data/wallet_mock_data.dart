import 'package:zappy/features/wallet/domain/wallet_models.dart';

class WalletMockData {
  static const int balanceCoins = 3250;
  static const double estimatedUsd = 32.50;

  static const packages = [
    CoinPackage(coins: 100, priceUsd: 0.99, isPopular: false),
    CoinPackage(coins: 550, priceUsd: 4.99, isPopular: true),
    CoinPackage(coins: 1200, priceUsd: 9.99, isPopular: false),
    CoinPackage(coins: 2500, priceUsd: 19.99, isPopular: false),
  ];

  static const gifts = [
    GiftItem(name: 'Rose', coinCost: 10, emoji: '🌹'),
    GiftItem(name: 'Fire', coinCost: 50, emoji: '🔥'),
    GiftItem(name: 'Crown', coinCost: 120, emoji: '👑'),
    GiftItem(name: 'Rocket', coinCost: 350, emoji: '🚀'),
  ];

  static const transactions = [
    WalletTransaction(
      title: 'Compra de monedas',
      dateLabel: 'Hoy, 11:10',
      amountLabel: '+550 coins',
      isPositive: true,
    ),
    WalletTransaction(
      title: 'Regalo enviado a @AnaCreator',
      dateLabel: 'Hoy, 10:42',
      amountLabel: '-120 coins',
      isPositive: false,
    ),
    WalletTransaction(
      title: 'Regalo recibido en live',
      dateLabel: 'Ayer, 22:15',
      amountLabel: '+800 coins',
      isPositive: true,
    ),
    WalletTransaction(
      title: 'Solicitud de retiro',
      dateLabel: 'Ayer, 16:30',
      amountLabel: '-1,000 coins',
      isPositive: false,
    ),
  ];
}
