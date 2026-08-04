import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmaconnect_catalog/pharmaconnect_catalog.dart';
import 'package:pharmaconnect_design_system/pharmaconnect_design_system.dart';

const double _adminReviewWideBreakpoint = 900;

class AdminCatalogReviewEntryPage extends ConsumerWidget {
  const AdminCatalogReviewEntryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ProductSummary>> queue = ref.watch(
      adminReviewQueueProvider(ProductLifecycleStatus.submitted),
    );

    return Scaffold(
      backgroundColor: PharmaConnectColors.canvas,
      appBar: AppBar(
        toolbarHeight: 72,
        titleSpacing: PharmaConnectSpacing.medium,
        title: const _AdminReviewAppBarTitle(),
        actions: const <Widget>[
          Padding(
            padding: EdgeInsets.only(right: PharmaConnectSpacing.medium),
            child: _AdminWorkspaceBadge(),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isWide =
                constraints.maxWidth >= _adminReviewWideBreakpoint;
            final double horizontalPadding = constraints.maxWidth < 380
                ? PharmaConnectSpacing.compact
                : constraints.maxWidth < 720
                ? PharmaConnectSpacing.medium
                : PharmaConnectSpacing.xLarge;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                PharmaConnectSpacing.large,
                horizontalPadding,
                PharmaConnectSpacing.large,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _ReviewQueueHeader(queue: queue),
                      const SizedBox(height: PharmaConnectSpacing.large),
                      _ReviewQueueContent(queue: queue, isWide: isWide),
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

class _AdminReviewAppBarTitle extends StatelessWidget {
  const _AdminReviewAppBarTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: PharmaConnectColors.primary,
            borderRadius: BorderRadius.circular(PharmaConnectRadii.control),
            border: Border.all(
              color: PharmaConnectColors.linkFocus.withValues(alpha: 0.5),
            ),
          ),
          child: const Icon(
            Icons.health_and_safety_outlined,
            color: PharmaConnectColors.primaryText,
            size: 22,
          ),
        ),
        const SizedBox(width: PharmaConnectSpacing.compact),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Pharamty',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: PharmaConnectColors.primaryText,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                'Catalog administration',
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: PharmaConnectColors.secondaryText,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AdminWorkspaceBadge extends StatelessWidget {
  const _AdminWorkspaceBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PharmaConnectSpacing.compact,
        vertical: PharmaConnectSpacing.small,
      ),
      decoration: BoxDecoration(
        color: PharmaConnectColors.unresolvedContainer,
        borderRadius: BorderRadius.circular(PharmaConnectRadii.pill),
        border: Border.all(color: PharmaConnectColors.unresolvedBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.admin_panel_settings_outlined,
            size: 16,
            color: PharmaConnectColors.linkFocus,
          ),
          const SizedBox(width: PharmaConnectSpacing.small),
          Text(
            'Admin',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: PharmaConnectColors.linkFocus,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewQueueHeader extends StatelessWidget {
  const _ReviewQueueHeader({required this.queue});

  final AsyncValue<List<ProductSummary>> queue;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String queueCount = queue.hasValue
        ? queue.requireValue.length.toString()
        : '—';
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: <Color>[
            PharmaConnectColors.deepBlue,
            PharmaConnectColors.primary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(PharmaConnectRadii.dialog),
        border: Border.all(color: PharmaConnectColors.unresolvedBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PharmaConnectSpacing.xLarge),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: PharmaConnectSpacing.large,
          runSpacing: PharmaConnectSpacing.large,
          children: <Widget>[
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 610),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'OFFICIAL CATALOG GOVERNANCE',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: PharmaConnectColors.primaryText,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: PharmaConnectSpacing.small),
                  Text(
                    'Catalog review workspace',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: PharmaConnectColors.primaryText,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: PharmaConnectSpacing.small),
                  Text(
                    'Review submitted company products for the official professional catalog. Company-page publication remains separate.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: PharmaConnectColors.primaryText.withValues(
                        alpha: 0.86,
                      ),
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              constraints: const BoxConstraints(minWidth: 168),
              padding: const EdgeInsets.all(PharmaConnectSpacing.medium),
              decoration: BoxDecoration(
                color: PharmaConnectColors.canvas.withValues(alpha: 0.36),
                borderRadius: BorderRadius.circular(PharmaConnectRadii.card),
                border: Border.all(
                  color: PharmaConnectColors.primaryText.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'SUBMITTED',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: PharmaConnectColors.primaryText.withValues(
                        alpha: 0.76,
                      ),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.9,
                    ),
                  ),
                  const SizedBox(height: PharmaConnectSpacing.xSmall),
                  Text(
                    queueCount,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: PharmaConnectColors.primaryText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'awaiting review',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: PharmaConnectColors.primaryText.withValues(
                        alpha: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewQueueContent extends ConsumerWidget {
  const _ReviewQueueContent({required this.queue, required this.isWide});

  final AsyncValue<List<ProductSummary>> queue;
  final bool isWide;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (queue.hasError) {
      return _ReviewQueueStateCard(
        icon: Icons.error_outline,
        title: 'Review queue could not load',
        message:
            'The submitted-product queue is temporarily unavailable. No review data has been changed.',
        presentation: PharmaConnectSemanticStatusMapper.error,
        actionLabel: 'Retry',
        onAction: () => ref.invalidate(
          adminReviewQueueProvider(ProductLifecycleStatus.submitted),
        ),
      );
    }

    if (queue.isLoading) {
      return const _ReviewQueueStateCard(
        icon: Icons.sync,
        title: 'Loading review queue',
        message: 'Fetching submitted products for this admin session.',
        presentation: PharmaConnectSemanticStatusMapper.unresolved,
        showProgress: true,
      );
    }

    final List<ProductSummary> products = queue.requireValue;
    if (products.isEmpty) {
      return const _ReviewQueueStateCard(
        icon: Icons.fact_check_outlined,
        title: 'No submitted products',
        message:
            'The official catalog queue is clear. Newly submitted products will appear here.',
        presentation: PharmaConnectSemanticStatusMapper.neutral,
      );
    }

    final Widget productCollection = isWide
        ? GridView.builder(
            key: const Key('admin-review-grid'),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: PharmaConnectSpacing.medium,
              mainAxisSpacing: PharmaConnectSpacing.medium,
              mainAxisExtent: 252,
            ),
            itemBuilder: (BuildContext context, int index) =>
                _ReviewQueueProductCard(product: products[index]),
          )
        : ListView.separated(
            key: const Key('admin-review-list'),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: products.length,
            separatorBuilder: (BuildContext context, int index) =>
                const SizedBox(height: PharmaConnectSpacing.medium),
            itemBuilder: (BuildContext context, int index) =>
                _ReviewQueueProductCard(product: products[index]),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: PharmaConnectColors.unresolvedContainer,
                borderRadius: BorderRadius.circular(PharmaConnectRadii.control),
                border: Border.all(color: PharmaConnectColors.unresolvedBorder),
              ),
              child: const Icon(
                Icons.fact_check_outlined,
                color: PharmaConnectColors.linkFocus,
                size: 20,
              ),
            ),
            const SizedBox(width: PharmaConnectSpacing.compact),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Submitted products',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: PharmaConnectColors.primaryText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${products.length} record${products.length == 1 ? '' : 's'} require official catalog review',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PharmaConnectColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: PharmaConnectSpacing.medium),
        productCollection,
      ],
    );
  }
}

class _ReviewQueueStateCard extends StatelessWidget {
  const _ReviewQueueStateCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.presentation,
    this.actionLabel,
    this.onAction,
    this.showProgress = false,
  });

  final IconData icon;
  final String title;
  final String message;
  final PharmaConnectStatusPresentation presentation;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: PharmaConnectColors.surface,
        borderRadius: BorderRadius.circular(PharmaConnectRadii.card),
        border: Border.all(color: presentation.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PharmaConnectSpacing.xLarge),
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: PharmaConnectSpacing.medium,
          runSpacing: PharmaConnectSpacing.medium,
          children: <Widget>[
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: presentation.container,
                borderRadius: BorderRadius.circular(PharmaConnectRadii.card),
                border: Border.all(color: presentation.border),
              ),
              alignment: Alignment.center,
              child: showProgress
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: presentation.foreground,
                      ),
                    )
                  : Icon(icon, size: 24, color: presentation.foreground),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 220, maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: PharmaConnectColors.primaryText,
                    ),
                  ),
                  const SizedBox(height: PharmaConnectSpacing.xSmall),
                  Text(
                    message,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: PharmaConnectColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
            if (actionLabel != null && onAction != null)
              OutlinedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh),
                label: Text(actionLabel!),
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

    final PharmaConnectStatusPresentation presentation =
        PharmaConnectSemanticStatusMapper.fromLifecycleValue(
          product.status.databaseValue,
        );

    return Container(
      key: Key('admin-review-card-${product.id}'),
      decoration: BoxDecoration(
        color: PharmaConnectColors.surface,
        borderRadius: BorderRadius.circular(PharmaConnectRadii.card),
        border: Border.all(color: PharmaConnectColors.subtleBorder),
      ),
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
                _StatusChip(label: data.status, presentation: presentation),
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
            const Divider(),
            const SizedBox(height: PharmaConnectSpacing.compact),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                key: Key('admin-open-review-${product.id}'),
                onPressed: () => showDialog<void>(
                  context: context,
                  builder: (BuildContext context) =>
                      _AdminProductReviewDialog(productId: product.id),
                ),
                icon: const Icon(Icons.rate_review_outlined),
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

    final Size viewport = MediaQuery.sizeOf(context);
    final double dialogPadding = viewport.width < 520
        ? PharmaConnectSpacing.medium
        : PharmaConnectSpacing.large;

    return Dialog(
      backgroundColor: PharmaConnectColors.canvas,
      insetPadding: EdgeInsets.all(
        viewport.width < 520
            ? PharmaConnectSpacing.small
            : PharmaConnectSpacing.medium,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 920,
          maxHeight: viewport.height * 0.92,
        ),
        child: Padding(
          padding: EdgeInsets.all(dialogPadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: PharmaConnectColors.unresolvedContainer,
                      borderRadius: BorderRadius.circular(
                        PharmaConnectRadii.control,
                      ),
                      border: Border.all(
                        color: PharmaConnectColors.unresolvedBorder,
                      ),
                    ),
                    child: const Icon(
                      Icons.rate_review_outlined,
                      color: PharmaConnectColors.linkFocus,
                    ),
                  ),
                  const SizedBox(width: PharmaConnectSpacing.compact),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Product review detail',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: PharmaConnectColors.primaryText,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: PharmaConnectSpacing.xSmall),
                        Text(
                          'Official catalog assessment',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: PharmaConnectColors.secondaryText,
                              ),
                        ),
                      ],
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
                          presentation:
                              PharmaConnectSemanticStatusMapper.neutral,
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
        presentation: PharmaConnectSemanticStatusMapper.error,
      );
    }

    if (detail.isLoading) {
      return const _ReviewQueueStateCard(
        icon: Icons.sync,
        title: 'Loading product detail',
        message: 'Fetching official catalog review information.',
        presentation: PharmaConnectSemanticStatusMapper.unresolved,
        showProgress: true,
      );
    }

    if (!detail.hasValue) {
      return const _ReviewQueueStateCard(
        icon: Icons.search_off,
        title: 'Product not found',
        message: 'This submitted product is not ready to display.',
        presentation: PharmaConnectSemanticStatusMapper.neutral,
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
    final PharmaConnectStatusPresentation presentation =
        PharmaConnectSemanticStatusMapper.fromLifecycleValue(data.status);
    return Container(
      decoration: BoxDecoration(
        color: PharmaConnectColors.surface,
        borderRadius: BorderRadius.circular(PharmaConnectRadii.card),
        border: Border.all(color: PharmaConnectColors.subtleBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PharmaConnectSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              data.brandName,
              style: theme.textTheme.headlineSmall?.copyWith(
                color: PharmaConnectColors.primaryText,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              data.genericName,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: PharmaConnectColors.secondaryText,
              ),
            ),
            const SizedBox(height: PharmaConnectSpacing.medium),
            Wrap(
              spacing: PharmaConnectSpacing.medium,
              runSpacing: PharmaConnectSpacing.small,
              children: <Widget>[
                _StatusChip(label: data.status, presentation: presentation),
                _MetadataText(label: 'Company', value: data.companyName),
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
    return Container(
      decoration: BoxDecoration(
        color: PharmaConnectColors.surface,
        borderRadius: BorderRadius.circular(PharmaConnectRadii.card),
        border: Border.all(color: PharmaConnectColors.subtleBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PharmaConnectSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: PharmaConnectColors.unresolvedContainer,
                    borderRadius: BorderRadius.circular(
                      PharmaConnectRadii.control,
                    ),
                    border: Border.all(
                      color: PharmaConnectColors.unresolvedBorder,
                    ),
                  ),
                  child: Icon(
                    icon,
                    size: 19,
                    color: PharmaConnectColors.linkFocus,
                  ),
                ),
                const SizedBox(width: PharmaConnectSpacing.compact),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: PharmaConnectColors.primaryText,
                      fontWeight: FontWeight.w800,
                    ),
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
        presentation: PharmaConnectSemanticStatusMapper.neutral,
      );
    }

    final AsyncValue<ProductDetail?> lifecycle = ref.watch(
      adminCatalogLifecycleController,
    );
    final bool isWorking = lifecycle.isLoading;

    return Container(
      decoration: BoxDecoration(
        color: PharmaConnectColors.warningContainer,
        borderRadius: BorderRadius.circular(PharmaConnectRadii.card),
        border: Border.all(color: PharmaConnectColors.warningBorder),
      ),
      child: Padding(
        padding: const EdgeInsets.all(PharmaConnectSpacing.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Icon(
                  Icons.gavel_outlined,
                  color: PharmaConnectColors.warning,
                ),
                const SizedBox(width: PharmaConnectSpacing.small),
                Expanded(
                  child: Text(
                    'Review decision',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: PharmaConnectColors.primaryText,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: PharmaConnectSpacing.small),
            Text(
              'Publish or return this submitted record for changes. Server validation remains authoritative.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: PharmaConnectColors.secondaryText,
              ),
            ),
            const SizedBox(height: PharmaConnectSpacing.medium),
            Wrap(
              spacing: PharmaConnectSpacing.medium,
              runSpacing: PharmaConnectSpacing.small,
              children: <Widget>[
                FilledButton.icon(
                  key: const Key('admin-publish-button'),
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
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Product published and removed from the submitted review queue.',
                                ),
                              ),
                            );
                          } catch (_) {
                            if (!context.mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Product could not be published. Please review the catalog data and try again.',
                                ),
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.check_circle_outline),
                  label: Text(isWorking ? 'Working...' : 'Publish'),
                  style: FilledButton.styleFrom(
                    backgroundColor: PharmaConnectColors.success,
                    foregroundColor: PharmaConnectColors.tooltip,
                  ),
                ),
                OutlinedButton.icon(
                  key: const Key('admin-request-changes-button'),
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
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Changes requested and the item was removed from the submitted review queue.',
                                ),
                              ),
                            );
                          } catch (_) {
                            if (!context.mounted) {
                              return;
                            }
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Changes could not be requested. Please review the reason and try again.',
                                ),
                              ),
                            );
                          }
                        },
                  icon: const Icon(Icons.rate_review_outlined),
                  label: Text(isWorking ? 'Working...' : 'Request changes'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: PharmaConnectColors.warning,
                    side: const BorderSide(
                      color: PharmaConnectColors.warningBorder,
                    ),
                  ),
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
      icon: const Icon(
        Icons.rate_review_outlined,
        color: PharmaConnectColors.warning,
      ),
      title: const Text('Request product changes'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Give the company a clear, professional reason. A reason is required before this review decision can be sent.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: PharmaConnectColors.secondaryText,
              ),
            ),
            const SizedBox(height: PharmaConnectSpacing.medium),
            TextField(
              key: const Key('admin-request-changes-reason'),
              controller: _controller,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Review reason',
                hintText: 'Explain what the company should update.',
              ),
              onChanged: (String value) {
                setState(() {
                  _hasReason = value.trim().isNotEmpty;
                });
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          key: const Key('admin-confirm-request-changes-button'),
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
  const _StatusChip({required this.label, required this.presentation});

  final String label;
  final PharmaConnectStatusPresentation presentation;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '${presentation.semanticCategory}: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PharmaConnectSpacing.compact,
          vertical: PharmaConnectSpacing.small,
        ),
        decoration: BoxDecoration(
          color: presentation.container,
          borderRadius: BorderRadius.circular(PharmaConnectRadii.pill),
          border: Border.all(color: presentation.border),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: presentation.foreground,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
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
      style: theme.textTheme.bodySmall?.copyWith(
        color: PharmaConnectColors.secondaryText,
      ),
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
