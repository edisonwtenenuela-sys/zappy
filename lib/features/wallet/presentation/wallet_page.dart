import 'package:flutter/material.dart';
import 'package:zappy/features/wallet/data/wallet_mock_data.dart';
import 'package:zappy/features/wallet/domain/wallet_models.dart';

class WalletPage extends StatelessWidget {
  const WalletPage({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wallet'),
        actions: [
          IconButton(
            tooltip: 'Cerrar sesión',
            onPressed: onLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          _BalanceCard(
            coins: WalletMockData.balanceCoins,
            estimatedUsd: WalletMockData.estimatedUsd,
          ),
          const SizedBox(height: 18),
          _SectionTitle(
            title: 'Comprar monedas',
            actionLabel: 'Ver más',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _CoinPackages(packages: WalletMockData.packages),
          const SizedBox(height: 22),
          _SectionTitle(
            title: 'Regalos populares',
            actionLabel: 'Catálogo',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _GiftGrid(gifts: WalletMockData.gifts),
          const SizedBox(height: 22),
          _SectionTitle(
            title: 'Movimientos',
            actionLabel: 'Historial',
            onTap: () {},
          ),
          const SizedBox(height: 10),
          ...WalletMockData.transactions.map(_TransactionTile.new),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({required this.coins, required this.estimatedUsd});

  final int coins;
  final double estimatedUsd;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF0891B2), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Balance actual',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            '$coins coins',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Estimado: USD ${estimatedUsd.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(backgroundColor: Colors.white),
                  child: const Text(
                    'Retirar',
                    style: TextStyle(color: Color(0xFF0F172A)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white54),
                  ),
                  child: const Text('Transferir', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.actionLabel, required this.onTap});

  final String title;
  final String actionLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        TextButton(onPressed: onTap, child: Text(actionLabel)),
      ],
    );
  }
}

class _CoinPackages extends StatelessWidget {
  const _CoinPackages({required this.packages});

  final List<CoinPackage> packages;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: packages.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = packages[index];
          return Container(
            width: 150,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: item.isPopular ? const Color(0xFF06B6D4) : const Color(0xFFE2E8F0),
                width: item.isPopular ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.isPopular)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF06B6D4),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Popular',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  )
                else
                  const SizedBox(height: 22),
                const Spacer(),
                Text(
                  '${item.coins} coins',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text('USD ${item.priceUsd.toStringAsFixed(2)}'),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _GiftGrid extends StatelessWidget {
  const _GiftGrid({required this.gifts});

  final List<GiftItem> gifts;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: gifts.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, index) {
        final item = gifts[index];
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Text(item.emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text('${item.coinCost}'),
            ],
          ),
        );
      },
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile(this.item);

  final WalletTransaction item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        title: Text(item.title),
        subtitle: Text(item.dateLabel),
        trailing: Text(
          item.amountLabel,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: item.isPositive ? Colors.green : Colors.red,
          ),
        ),
      ),
    );
  }
}
