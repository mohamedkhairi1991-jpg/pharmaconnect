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
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (BuildContext context) =>
                      _AdminProductReviewDialog(productId: product.id),
                ),
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

class _AdminProductReviewDialog extends ConsumerWidget {
  const _AdminProductReviewDialog({required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String normalizedProductId = productId.trim();
    final AsyncValue<ProductDetail>? detail = normalizedProductId.isEmpty
        ? null
        : ref.watch(adminProductDetailProvider(normalizedProductId));

    return Dialog(
      insetPadding: const EdgeInsets.all(PharmaConnectSpacing.medium),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: Padding(
          padding: const EdgeInsets.all(PharmaConnectSpacing.large),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Expanded(
                    child: Text(
                      'Product review detail',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Close review detail',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: PharmaConnectSpacing.medium),
              Flexible(
                child: SingleChildScrollView(
                  child: detail == null
                      ? const _ReviewQueueStateCard(
                          icon: Icons.search_off,
                          title: 'Product not found',
                          message:
                              'This review item could not be opened safely.',
                        )
                      : _AdminProductReviewDetailContent(detail: detail),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminProductReviewDetailContent extends ConsumerWidget {
  const _AdminProductReviewDetailContent({required this.detail});

  final AsyncValue<ProductDetail> detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (detail.hasError) {
      return const _ReviewQueueStateCard(
        icon: Icons.error_outline,
        title: 'Product detail could not load',
        message: 'Please try again later.',
      );
    }

    if (detail.isLoading) {
      return const _ReviewQueueStateCard(
        icon: Icons.sync,
        title: 'Loading product detail',
        message: 'Fetching official catalog review information.',
      );
    }

    if (!detail.hasValue) {
      return const _ReviewQueueStateCard(
        icon: Icons.search_off,
        title: 'Product not found',
        message: 'This submitted product is not ready to display.',
      );
    }

    final ProductDetail product = detail.requireValue;
    final _AdminProductDetailDisplay data =
        _AdminProductDetailDisplay.fromProduct(product);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _ReviewDetailHeader(data: data),
        const SizedBox(height: PharmaConnectSpacing.medium),
        _ReviewDetailSection(
          title: 'Product basics',
          icon: Icons.medication_outlined,
          rows: <_ReviewDetailRow>[
            _ReviewDetailRow('Category', data.category),
            _ReviewDetailRow('Dosage form', data.dosageForm),
            _ReviewDetailRow('Strength', data.strength),
            _ReviewDetailRow('Route', data.route),
            _ReviewDetailRow('Package', data.packSize),
          ],
        ),
        if (data.composition.isNotEmpty) ...<Widget>[
          const SizedBox(height: PharmaConnectSpacing.medium),
          _ReviewDetailTextSection(
            title: 'Composition',
            icon: Icons.science_outlined,
            items: data.composition,
          ),
        ],
        if (data.marketRows.isNotEmpty) ...<Widget>[
          const SizedBox(height: PharmaConnectSpacing.medium),
          _ReviewDetailSection(
            title: 'Iraq market metadata',
            icon: Icons.verified_outlined,
            rows: data.marketRows,
          ),
        ],
        if (data.clinicalRows.isNotEmpty) ...<Widget>[
          const SizedBox(height: PharmaConnectSpacing.medium),
          _ReviewDetailSection(
            title: 'Clinical catalog text',
            icon: Icons.health_and_safety_outlined,
            rows: data.clinicalRows,
          ),
        ],
        const SizedBox(height: PharmaConnectSpacing.medium),
        _ReviewDetailSection(
          title: 'Review metadata',
          icon: Icons.assignment_outlined,
          rows: data.reviewRows,
        ),
        if (data.metadataRows.isNotEmpty) ...<Widget>[
          const SizedBox(height: PharmaConnectSpacing.medium),
          _ReviewDetailSection(
            title: 'Media and brochure metadata',
            icon: Icons.perm_media_outlined,
            rows: data.metadataRows,
          ),
        ],
        const SizedBox(height: PharmaConnectSpacing.medium),
        _ReviewLifecycleActions(product: product),
      ],
    );
  }
}

class _ReviewDetailHeader extends StatelessWidget {
  const _ReviewDetailHeader({required this.data});

  final _AdminProductDetailDisplay data;

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
              data.brandName,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(data.genericName, style: theme.textTheme.bodyLarge),
            const SizedBox(height: PharmaConnectSpacing.medium),
            Wrap(
              spacing: PharmaConnectSpacing.medium,
              runSpacing: PharmaConnectSpacing.small,
              children: <Widget>[
                _MetadataText(label: 'Company', value: data.companyName),
                _MetadataText(label: 'Status', value: data.status),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewDetailSection extends StatelessWidget {
  const _ReviewDetailSection({
    required this.title,
    required this.icon,
    required this.rows,
  });

  final String title;
  final IconData icon;
  final List<_ReviewDetailRow> rows;

  @override
  Widget build(BuildContext context) {
    final List<_ReviewDetailRow> visibleRows = rows
        .where((_ReviewDetailRow row) => row.value.trim().isNotEmpty)
        .toList(growable: false);
    if (visibleRows.isEmpty) {
      return const SizedBox.shrink();
    }

    final ThemeData theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PharmaConnectSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: PharmaConnectSpacing.small),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: PharmaConnectSpacing.medium),
            for (
              int index = 0;
              index < visibleRows.length;
              index++
            ) ...<Widget>[
              _ReviewDetailRowView(row: visibleRows[index]),
              if (index != visibleRows.length - 1)
                const SizedBox(height: PharmaConnectSpacing.small),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReviewDetailTextSection extends StatelessWidget {
  const _ReviewDetailTextSection({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return _ReviewDetailSection(
      title: title,
      icon: icon,
      rows: items
          .map((String item) => _ReviewDetailRow('Ingredient', item))
          .toList(growable: false),
    );
  }
}

class _ReviewDetailRowView extends StatelessWidget {
  const _ReviewDetailRowView({required this.row});

  final _ReviewDetailRow row;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Text.rich(
      TextSpan(
        children: <InlineSpan>[
          TextSpan(
            text: '${row.label}: ',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          TextSpan(text: row.value),
        ],
      ),
      style: theme.textTheme.bodyMedium,
    );
  }
}

class _ReviewLifecycleActions extends ConsumerWidget {
  const _ReviewLifecycleActions({required this.product});

  final ProductDetail product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isSubmitted = product.status == ProductLifecycleStatus.submitted;
    if (!isSubmitted) {
      return const _ReviewQueueStateCard(
        icon: Icons.lock_outline,
        title: 'Lifecycle actions unavailable',
        message: 'Review actions are only available for submitted products.',
      );
    }

    final AsyncValue<ProductDetail?> lifecycle = ref.watch(
      adminCatalogLifecycleController,
    );
    final bool isWorking = lifecycle.isLoading;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(PharmaConnectSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Lifecycle actions',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: PharmaConnectSpacing.small),
            const Text(
              'Client checks are advisory. Server validation remains authoritative.',
            ),
            const SizedBox(height: PharmaConnectSpacing.medium),
            Wrap(
              spacing: PharmaConnectSpacing.medium,
              runSpacing: PharmaConnectSpacing.small,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: isWorking
                      ? null
                      : () async {
                          try {
                            await ref
                                .read(adminCatalogLifecycleController.notifier)
                                .publish(product.id);
                            if (!context.mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Product published.'),
                              ),
                            );
                          } catch (_) {
                            if (!context.mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Product could not be published.',
                                ),
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(isWorking ? 'Working...' : 'Publish'),
                ),
                OutlinedButton.icon(
                  onPressed: isWorking
                      ? null
                      : () async {
                          final String? reason = await _requestChangesReason(
                            context,
                          );
                          if (reason == null || reason.trim().isEmpty) {
                            return;
                          }
                          try {
                            await ref
                                .read(adminCatalogLifecycleController.notifier)
                                .requestChanges(product.id, reason.trim());
                            if (!context.mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Changes requested.'),
                              ),
                            );
                          } catch (_) {
                            if (!context.mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Changes could not be requested.',
                                ),
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.rate_review_outlined),
                  label: Text(isWorking ? 'Working...' : 'Request changes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<String?> _requestChangesReason(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (BuildContext context) => const _RequestChangesDialog(),
  );
}

class _RequestChangesDialog extends StatefulWidget {
  const _RequestChangesDialog();

  @override
  State<_RequestChangesDialog> createState() => _RequestChangesDialogState();
}

class _RequestChangesDialogState extends State<_RequestChangesDialog> {
  final TextEditingController _controller = TextEditingController();
  bool _hasReason = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Request changes'),
      content: TextField(
        controller: _controller,
        minLines: 3,
        maxLines: 5,
        decoration: const InputDecoration(
          labelText: 'Reason',
          hintText: 'Explain what the company should change.',
          border: OutlineInputBorder(),
        ),
        onChanged: (String value) {
          setState(() {
            _hasReason = value.trim().isNotEmpty;
          });
        },
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _hasReason
              ? () => Navigator.of(context).pop(_controller.text.trim())
              : null,
          child: const Text('Request changes'),
        ),
      ],
    );
  }
}

final class _ReviewDetailRow {
  const _ReviewDetailRow(this.label, this.value);

  final String label;
  final String value;
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

final class _AdminProductDetailDisplay {
  const _AdminProductDetailDisplay({
    required this.brandName,
    required this.genericName,
    required this.companyName,
    required this.status,
    required this.category,
    required this.dosageForm,
    required this.strength,
    required this.route,
    required this.packSize,
    required this.composition,
    required this.marketRows,
    required this.clinicalRows,
    required this.reviewRows,
    required this.metadataRows,
  });

  final String brandName;
  final String genericName;
  final String companyName;
  final String status;
  final String category;
  final String dosageForm;
  final String strength;
  final String route;
  final String packSize;
  final List<String> composition;
  final List<_ReviewDetailRow> marketRows;
  final List<_ReviewDetailRow> clinicalRows;
  final List<_ReviewDetailRow> reviewRows;
  final List<_ReviewDetailRow> metadataRows;

  static _AdminProductDetailDisplay fromProduct(ProductDetail product) {
    final ProductMarket? market = product.iraqMarket;
    final ProductMarketTranslation? marketTranslation = market?.translations
        .resolve(ContentLocale.english);
    final List<String> composition =
        product.genericDrug?.composition
            .map(
              (GenericCompositionEntry entry) => _fallback(
                entry.ingredient.translations
                    .resolve(ContentLocale.english)
                    ?.name,
                entry.ingredient.code,
              ),
            )
            .where((String value) => value.trim().isNotEmpty)
            .toList(growable: false) ??
        const <String>[];
    final List<_ReviewDetailRow> marketRows = <_ReviewDetailRow>[
      if (_hasText(market?.registrationStatus.databaseValue))
        _ReviewDetailRow(
          'Registration status',
          _readableCatalogValue(market!.registrationStatus.databaseValue),
        ),
      if (_hasText(market?.registrationNumber))
        _ReviewDetailRow('Registration number', market!.registrationNumber!),
      if (_hasText(market?.registrationAuthority))
        _ReviewDetailRow(
          'Registration authority',
          market!.registrationAuthority!,
        ),
      if (_hasText(market?.marketStatus.databaseValue))
        _ReviewDetailRow(
          'Market status metadata',
          _readableCatalogValue(market!.marketStatus.databaseValue),
        ),
    ];
    final List<_ReviewDetailRow> clinicalRows = <_ReviewDetailRow>[
      if (_hasText(marketTranslation?.approvedIndications))
        _ReviewDetailRow('Indications', marketTranslation!.approvedIndications),
      if (_hasText(marketTranslation?.usualAdultDose))
        _ReviewDetailRow('Dosing notes', marketTranslation!.usualAdultDose),
      if (_hasText(marketTranslation?.contraindications))
        _ReviewDetailRow(
          'Contraindications',
          marketTranslation!.contraindications,
        ),
      if (_hasText(marketTranslation?.commonAdverseEffects))
        _ReviewDetailRow('Warnings', marketTranslation!.commonAdverseEffects),
    ];
    final List<_ReviewDetailRow> reviewRows = <_ReviewDetailRow>[
      _ReviewDetailRow('Updated', _formatShortDate(product.updatedAt)),
      if (product.lifecycle.submittedAt != null)
        _ReviewDetailRow(
          'Submitted',
          _formatShortDate(product.lifecycle.submittedAt!),
        ),
    ];
    final List<_ReviewDetailRow> metadataRows = <_ReviewDetailRow>[
      if (product.media.isNotEmpty)
        _ReviewDetailRow(
          'Media metadata',
          '${product.media.length} item(s) recorded',
        ),
      if (product.brochures.isNotEmpty)
        _ReviewDetailRow(
          'Brochure metadata',
          '${product.brochures.length} document(s) recorded',
        ),
    ];

    return _AdminProductDetailDisplay(
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
      category: _readableCatalogValue(product.category.databaseValue),
      dosageForm: _fallback(market?.dosageForm, 'Not recorded'),
      strength: _fallback(market?.strength, 'Not recorded'),
      route: _fallback(market?.route, 'Not recorded'),
      packSize: _fallback(market?.packSize, 'Not recorded'),
      composition: composition,
      marketRows: marketRows,
      clinicalRows: clinicalRows,
      reviewRows: reviewRows,
      metadataRows: metadataRows,
    );
  }

  static String _fallback(String? value, String fallback) {
    if (!_hasText(value)) {
      return fallback;
    }
    return value!.trim();
  }

  static bool _hasText(String? value) =>
      value != null && value.trim().isNotEmpty;
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
