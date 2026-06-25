import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmaconnect_catalog/pharmaconnect_catalog.dart';
import 'package:pharmaconnect_design_system/pharmaconnect_design_system.dart';

class AdminCatalogReviewEntryPage extends ConsumerWidget {
  const AdminCatalogReviewEntryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ProductSummary>> queue = ref.watch(
      adminReviewQueueProvider(ProductLifecycleStatus.submitted),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Catalog review queue')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double horizontalPadding = constraints.maxWidth < 640
                ? PharmaConnectSpacing.medium
                : PharmaConnectSpacing.large;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                PharmaConnectSpacing.large,
                horizontalPadding,
                PharmaConnectSpacing.large,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 960),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const _ReviewQueueHeader(),
                      const SizedBox(height: PharmaConnectSpacing.large),
                      _ReviewQueueContent(queue: queue),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ReviewQueueHeader extends StatelessWidget {
  const _ReviewQueueHeader();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PharmaConnectSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Official catalog review',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: PharmaConnectSpacing.small),
            Text(
              'Submitted company products waiting for official catalog review.',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewQueueContent extends StatelessWidget {
  const _ReviewQueueContent({required this.queue});

  final AsyncValue<List<ProductSummary>> queue;

  @override
  Widget build(BuildContext context) {
    if (queue.hasError) {
      return const _ReviewQueueStateCard(
        icon: Icons.error_outline,
        title: 'Review queue could not load',
        message: 'Please try again later.',
      );
    }

    if (queue.isLoading) {
      return const _ReviewQueueStateCard(
        icon: Icons.sync,
        title: 'Loading review queue',
        message: 'Fetching submitted products for this admin session.',
      );
    }

    final List<ProductSummary> products = queue.requireValue;
    if (products.isEmpty) {
      return const _ReviewQueueStateCard(
        icon: Icons.fact_check_outlined,
        title: 'No submitted products',
        message: 'Submitted catalog products will appear here.',
      );
    }

    return Column(
      children: <Widget>[
        for (int index = 0; index < products.length; index++)
          Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : 12),
            child: _ReviewQueueProductCard(product: products[index]),
          ),
      ],
    );
  }
}

class _ReviewQueueStateCard extends StatelessWidget {
  const _ReviewQueueStateCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PharmaConnectSpacing.large),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 32, color: theme.colorScheme.primary),
            const SizedBox(width: PharmaConnectSpacing.medium),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(message),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewQueueProductCard extends StatelessWidget {
  const _ReviewQueueProductCard({required this.product});

  final ProductSummary product;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final _AdminProductSummaryDisplay data =
        _AdminProductSummaryDisplay.fromProduct(product);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PharmaConnectSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        data.brandName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        data.genericName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: PharmaConnectSpacing.medium),
                _StatusChip(label: data.status),
              ],
            ),
            const SizedBox(height: PharmaConnectSpacing.medium),
            Wrap(
              spacing: PharmaConnectSpacing.medium,
              runSpacing: PharmaConnectSpacing.small,
              children: <Widget>[
                _MetadataText(label: 'Company', value: data.companyName),
                _MetadataText(label: 'Updated', value: data.updatedAt),
              ],
            ),
            const SizedBox(height: PharmaConnectSpacing.medium),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Review detail flow is not implemented yet.',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Open review'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Chip(
      label: Text(label),
      backgroundColor: colorScheme.primaryContainer,
      labelStyle: TextStyle(color: colorScheme.onPrimaryContainer),
    );
  }
}

class _MetadataText extends StatelessWidget {
  const _MetadataText({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: value),
        ],
      ),
      style: theme.textTheme.bodySmall,
    );
  }
}

final class _AdminProductSummaryDisplay {
  const _AdminProductSummaryDisplay({
    required this.brandName,
    required this.genericName,
    required this.companyName,
    required this.status,
    required this.updatedAt,
  });

  final String brandName;
  final String genericName;
  final String companyName;
  final String status;
  final String updatedAt;

  static _AdminProductSummaryDisplay fromProduct(ProductSummary product) {
    return _AdminProductSummaryDisplay(
      brandName: _fallback(
        product.translations.resolve(ContentLocale.english)?.brandName,
        'Unnamed product',
      ),
      genericName: _fallback(
        product.genericDrug?.translations.resolve(ContentLocale.english)?.name,
        'Generic name not recorded',
      ),
      companyName: _fallback(
        product.company.companyName,
        'Company not recorded',
      ),
      status: _readableCatalogValue(product.status.databaseValue),
      updatedAt: _formatShortDate(product.updatedAt),
    );
  }

  static String _fallback(String? value, String fallback) {
    if (value == null || value.trim().isEmpty) {
      return fallback;
    }
    return value.trim();
  }
}

String _readableCatalogValue(String value) {
  return value
      .split('_')
      .where((String part) => part.isNotEmpty)
      .map((String part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String _formatShortDate(DateTime value) {
  const List<String> months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[value.month - 1]} ${value.day}, ${value.year}';
}
