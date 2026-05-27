import 'package:flutter/material.dart';
import 'package:zappy/core/i18n/app_i18n.dart';
import 'package:zappy/features/wallet/data/repositories/wallet_repository.dart';
import 'package:zappy/features/wallet/domain/wallet_models.dart';
import 'package:zappy/features/wallet/domain/wallet_summary.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key, required this.onLogout});

  final VoidCallback onLogout;

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  late final Future<WalletSummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = WalletRepository().fetchWalletSummary();
  }

  @override
  Widget build(BuildContext context) {
    final i18n = AppI18n.of(context);
    final t = i18n.t;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.wallet),
        actions: [
          PopupMenuButton<String>(
            tooltip: t.language,
            onSelected: (value) async {
              await i18n.onChangeLanguage(value);
              if (context.mounted) {
                final updated = AppI18n.of(context).t;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${updated.languageChanged}: ${value.toUpperCase()}')),
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'es', child: Text('Español')),
              PopupMenuItem(value: 'en', child: Text('English')),
            ],
            icon: const Icon(Icons.language),
          ),
          IconButton(
            tooltip: t.logout,
            onPressed: widget.onLogout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: FutureBuilder<WalletSummary>(
        future: _summaryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final summary = snapshot.data;
          if (summary == null) {
            return const Center(child: Text('No data'));
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              _BalanceCard(
                coins: summary.balanceCoins,
                estimatedUsd: summary.estimatedUsd,
                title: t.balanceNow,
                estimatedLabel: t.estimated,
                withdrawLabel: t.withdraw,
                transferLabel: t.transfer,
              ),
              const SizedBox(height: 18),
              _SectionTitle(title: t.buyCoins, actionLabel: t.seeMore, onTap: () {}),
              const SizedBox(height: 10),
              _CoinPackages(packages: summary.packages, popularLabel: t.popular),
              const SizedBox(height: 22),
              _SectionTitle(title: t.popularGifts, actionLabel: t.catalog, onTap: () {}),
              const SizedBox(height: 10),
              _GiftGrid(gifts: summary.gifts),
              const SizedBox(height: 22),
              _SectionTitle(title: t.movements, actionLabel: t.history, onTap: () {}),
              const SizedBox(height: 10),
              ...summary.transactions.map(_TransactionTile.new),
            ],
          );
        },
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  const _BalanceCard({
    required this.coins,
    required this.estimatedUsd,
    required this.title,
    required this.estimatedLabel,
    required this.withdrawLabel,
    required this.transferLabel,
  });

  final int coins;
  final double estimatedUsd;
  final String title;
  final String estimatedLabel;
  final String withdrawLabel;
  final String transferLabel;

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
          Text(title, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            '$coins coins',
            style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '$estimatedLabel: USD ${estimatedUsd.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(backgroundColor: Colors.white),
                  child: Text(withdrawLabel, style: const TextStyle(color: Color(0xFF0F172A))),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white54)),
                  child: Text(transferLabel, style: const TextStyle(color: Colors.white)),
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
  const _CoinPackages({required this.packages, required this.popularLabel});

  final List<CoinPackage> packages;
  final String popularLabel;

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
                    child: Text(popularLabel, style: const TextStyle(color: Colors.white, fontSize: 11)),
                  )
                else
                  const SizedBox(height: 22),
                const Spacer(),
                Text('${item.coins} coins', style: const TextStyle(fontWeight: FontWeight.w700)),
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
              Expanded(child: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600))),
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
          style: TextStyle(fontWeight: FontWeight.w700, color: item.isPositive ? Colors.green : Colors.red),
        ),
      ),
    );
  }
}
