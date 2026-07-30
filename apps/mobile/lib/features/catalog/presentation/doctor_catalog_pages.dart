import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmaconnect_catalog/pharmaconnect_catalog.dart';
import 'package:pharmaconnect_design_system/pharmaconnect_design_system.dart';

const ProductListRequest _doctorCatalogRequest = ProductListRequest();
const double _wideCatalogBreakpoint = 760;

String _productDetailLocation(String productId) =>
    '/catalog/products/${Uri.encodeComponent(productId)}';

class DoctorCatalogHomePage extends ConsumerStatefulWidget {
  const DoctorCatalogHomePage({super.key});

  @override
  ConsumerState<DoctorCatalogHomePage> createState() =>
      _DoctorCatalogHomePageState();
}

class _DoctorCatalogHomePageState extends ConsumerState<DoctorCatalogHomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setQuery(String value) {
    setState(() {
      _query = value;
    });
  }

  void _clearQuery() {
    _searchController.clear();
    _setQuery('');
  }

  List<ProductSummary> _filter(List<ProductSummary> products) {
    final String normalizedQuery = _query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) {
      return products;
    }

    return products
        .where(
          (ProductSummary product) => _DoctorProductSummaryData.fromProduct(
            product,
          ).searchText.contains(normalizedQuery),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<ProductSummary>> products = ref.watch(
      officialProductListProvider(_doctorCatalogRequest),
    );

    return Scaffold(
      backgroundColor: PharmaConnectColors.canvas,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isWide = constraints.maxWidth >= _wideCatalogBreakpoint;
            final double horizontalPadding = constraints.maxWidth < 380
                ? PharmaConnectSpacing.medium
                : isWide
                ? PharmaConnectSpacing.xLarge
                : PharmaConnectSpacing.large;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                PharmaConnectSpacing.large,
                horizontalPadding,
                PharmaConnectSpacing.xxLarge,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _CatalogTopBar(isWide: isWide),
                      const SizedBox(height: PharmaConnectSpacing.large),
                      _CatalogSearchPanel(
                        controller: _searchController,
                        query: _query,
                        isWide: isWide,
                        onChanged: _setQuery,
                        onClear: _clearQuery,
                      ),
                      const SizedBox(height: PharmaConnectSpacing.xLarge),
                      _CatalogResults(
                        products: products,
                        filteredProducts: products.maybeWhen(
                          data: _filter,
                          orElse: () => const <ProductSummary>[],
                        ),
                        query: _query,
                        isWide: isWide,
                        onRetry: () => ref.invalidate(
                          officialProductListProvider(_doctorCatalogRequest),
                        ),
                      ),
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

class _CatalogTopBar extends StatelessWidget {
  const _CatalogTopBar({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        const _CatalogBrandMark(),
        const SizedBox(width: PharmaConnectSpacing.compact),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Pharamty',
                style: isWide
                    ? PharmaConnectTypography.featureTitle
                    : PharmaConnectTypography.cardTitle,
              ),
              const Text(
                'Official clinical catalog',
                style: PharmaConnectTypography.supporting,
              ),
            ],
          ),
        ),
        const _PublishedSourceBadge(),
      ],
    );
  }
}

class _CatalogBrandMark extends StatelessWidget {
  const _CatalogBrandMark();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: PharmaConnectSpacing.xxxLarge,
      height: PharmaConnectSpacing.xxxLarge,
      decoration: BoxDecoration(
        color: PharmaConnectColors.primary,
        borderRadius: BorderRadius.circular(PharmaConnectRadii.card),
        border: Border.all(
          color: PharmaConnectColors.linkFocus.withValues(alpha: 0.5),
        ),
      ),
      child: const Icon(
        Icons.health_and_safety_outlined,
        color: PharmaConnectColors.primaryText,
      ),
    );
  }
}

class _PublishedSourceBadge extends StatelessWidget {
  const _PublishedSourceBadge();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Published official sources',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: PharmaConnectSpacing.compact,
          vertical: PharmaConnectSpacing.small,
        ),
        decoration: BoxDecoration(
          color: PharmaConnectColors.successContainer,
          borderRadius: BorderRadius.circular(PharmaConnectRadii.pill),
          border: Border.all(color: PharmaConnectColors.successBorder),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.verified_outlined,
              color: PharmaConnectColors.success,
              size: 18,
            ),
            SizedBox(width: PharmaConnectSpacing.small),
            Text(
              'Published',
              style: TextStyle(
                color: PharmaConnectColors.success,
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogSearchPanel extends StatelessWidget {
  const _CatalogSearchPanel({
    required this.controller,
    required this.query,
    required this.isWide,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final bool isWide;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isWide ? PharmaConnectSpacing.xLarge : PharmaConnectSpacing.large,
      ),
      decoration: BoxDecoration(
        color: PharmaConnectColors.surface,
        borderRadius: BorderRadius.circular(PharmaConnectRadii.dialog),
        border: Border.all(color: PharmaConnectColors.subtleBorder),
      ),
      child: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                const Expanded(flex: 4, child: _CatalogIntroduction()),
                const SizedBox(width: PharmaConnectSpacing.xLarge),
                Expanded(
                  flex: 5,
                  child: _CatalogSearchField(
                    controller: controller,
                    query: query,
                    onChanged: onChanged,
                    onClear: onClear,
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const _CatalogIntroduction(),
                const SizedBox(height: PharmaConnectSpacing.large),
                _CatalogSearchField(
                  controller: controller,
                  query: query,
                  onChanged: onChanged,
                  onClear: onClear,
                ),
              ],
            ),
    );
  }
}

class _CatalogIntroduction extends StatelessWidget {
  const _CatalogIntroduction();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Official medicine catalog',
          style: PharmaConnectTypography.pageTitle,
        ),
        SizedBox(height: PharmaConnectSpacing.small),
        Text(
          'Review published product information from verified catalog sources.',
          style: PharmaConnectTypography.body,
        ),
        SizedBox(height: PharmaConnectSpacing.medium),
        Wrap(
          spacing: PharmaConnectSpacing.small,
          runSpacing: PharmaConnectSpacing.small,
          children: <Widget>[
            _SearchScopeChip(label: 'Trade name'),
            _SearchScopeChip(label: 'Generic name'),
            _SearchScopeChip(label: 'Company'),
          ],
        ),
      ],
    );
  }
}

class _SearchScopeChip extends StatelessWidget {
  const _SearchScopeChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PharmaConnectSpacing.compact,
        vertical: PharmaConnectSpacing.small,
      ),
      decoration: BoxDecoration(
        color: PharmaConnectColors.elevatedSurface,
        borderRadius: BorderRadius.circular(PharmaConnectRadii.pill),
        border: Border.all(color: PharmaConnectColors.subtleBorder),
      ),
      child: Text(label, style: PharmaConnectTypography.auxiliary),
    );
  }
}

class _CatalogSearchField extends StatelessWidget {
  const _CatalogSearchField({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textField: true,
      label: 'Search the official catalog',
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        maxLines: 1,
        decoration: InputDecoration(
          hintText: 'Search drugs, generics, companies...',
          prefixIcon: const Icon(Icons.search_outlined),
          suffixIcon: query.trim().isEmpty
              ? null
              : IconButton(
                  tooltip: 'Clear catalog search',
                  onPressed: onClear,
                  icon: const Icon(Icons.close_outlined),
                ),
        ),
      ),
    );
  }
}

class _CatalogResults extends StatelessWidget {
  const _CatalogResults({
    required this.products,
    required this.filteredProducts,
    required this.query,
    required this.isWide,
    required this.onRetry,
  });

  final AsyncValue<List<ProductSummary>> products;
  final List<ProductSummary> filteredProducts;
  final String query;
  final bool isWide;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final int totalCount = products.hasValue ? products.requireValue.length : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _ResultsHeading(
          resultCount: filteredProducts.length,
          totalCount: totalCount,
          hasData: products.hasValue,
          hasQuery: query.trim().isNotEmpty,
        ),
        const SizedBox(height: PharmaConnectSpacing.medium),
        if (products.hasError)
          _CatalogStatePanel.error(onRetry: onRetry)
        else if (products.isLoading)
          const _CatalogStatePanel.loading()
        else if (products.requireValue.isEmpty)
          const _CatalogStatePanel.empty()
        else if (filteredProducts.isEmpty)
          _CatalogStatePanel.noMatch(query: query.trim())
        else
          _ResponsiveProductResults(products: filteredProducts, isWide: isWide),
      ],
    );
  }
}

class _ResultsHeading extends StatelessWidget {
  const _ResultsHeading({
    required this.resultCount,
    required this.totalCount,
    required this.hasData,
    required this.hasQuery,
  });

  final int resultCount;
  final int totalCount;
  final bool hasData;
  final bool hasQuery;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Published products',
                style: PharmaConnectTypography.sectionTitle,
              ),
              SizedBox(height: PharmaConnectSpacing.xSmall),
              Text(
                'Official catalog information for approved professionals.',
                style: PharmaConnectTypography.supporting,
              ),
            ],
          ),
        ),
        if (hasData)
          Text(
            hasQuery ? '$resultCount of $totalCount' : '$totalCount products',
            style: PharmaConnectTypography.label.copyWith(
              color: PharmaConnectColors.linkFocus,
            ),
          ),
      ],
    );
  }
}

class _ResponsiveProductResults extends StatelessWidget {
  const _ResponsiveProductResults({
    required this.products,
    required this.isWide,
  });

  final List<ProductSummary> products;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    if (!isWide) {
      return Column(
        key: const Key('doctor-catalog-list'),
        children: <Widget>[
          for (int index = 0; index < products.length; index++) ...<Widget>[
            if (index > 0) const SizedBox(height: PharmaConnectSpacing.compact),
            _DoctorProductCard(product: products[index]),
          ],
        ],
      );
    }

    return GridView.builder(
      key: const Key('doctor-catalog-grid'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: PharmaConnectSpacing.medium,
        mainAxisSpacing: PharmaConnectSpacing.medium,
        mainAxisExtent: 232,
      ),
      itemBuilder: (BuildContext context, int index) =>
          _DoctorProductCard(product: products[index]),
    );
  }
}

class _DoctorProductCard extends StatelessWidget {
  const _DoctorProductCard({required this.product});

  final ProductSummary product;

  @override
  Widget build(BuildContext context) {
    final _DoctorProductSummaryData data =
        _DoctorProductSummaryData.fromProduct(product);

    return SizedBox(
      height: 232,
      child: Semantics(
        button: true,
        label: 'Open ${data.brandName} official product details',
        child: Material(
          color: PharmaConnectColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(PharmaConnectRadii.card),
            side: const BorderSide(color: PharmaConnectColors.subtleBorder),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(PharmaConnectRadii.card),
            onTap: () => context.push(_productDetailLocation(product.id)),
            child: Padding(
              padding: const EdgeInsets.all(PharmaConnectSpacing.roomy),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      const _PublishedProductBadge(),
                      const Spacer(),
                      Text(
                        data.updatedLabel,
                        style: PharmaConnectTypography.auxiliary,
                      ),
                    ],
                  ),
                  const SizedBox(height: PharmaConnectSpacing.medium),
                  Text(
                    data.brandName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: PharmaConnectTypography.featureTitle,
                  ),
                  const SizedBox(height: PharmaConnectSpacing.xSmall),
                  Text(
                    data.genericName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: PharmaConnectTypography.body.copyWith(
                      color: PharmaConnectColors.linkFocus,
                    ),
                  ),
                  const SizedBox(height: PharmaConnectSpacing.medium),
                  _ProductMetadataLine(
                    icon: Icons.apartment_outlined,
                    value: data.companyName,
                  ),
                  const SizedBox(height: PharmaConnectSpacing.small),
                  _ProductMetadataLine(
                    icon: Icons.medication_outlined,
                    value: data.presentation,
                  ),
                  const Spacer(),
                  const Align(
                    alignment: Alignment.centerRight,
                    child: Icon(
                      Icons.arrow_forward_outlined,
                      color: PharmaConnectColors.linkFocus,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PublishedProductBadge extends StatelessWidget {
  const _PublishedProductBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PharmaConnectSpacing.compact,
        vertical: PharmaConnectSpacing.xSmall,
      ),
      decoration: BoxDecoration(
        color: PharmaConnectColors.successContainer,
        borderRadius: BorderRadius.circular(PharmaConnectRadii.pill),
        border: Border.all(color: PharmaConnectColors.successBorder),
      ),
      child: const Text(
        'Published',
        style: TextStyle(
          color: PharmaConnectColors.success,
          fontSize: 11,
          height: 16 / 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ProductMetadataLine extends StatelessWidget {
  const _ProductMetadataLine({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(icon, color: PharmaConnectColors.secondaryText, size: 18),
        const SizedBox(width: PharmaConnectSpacing.small),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: PharmaConnectTypography.supporting,
          ),
        ),
      ],
    );
  }
}

enum _CatalogStateKind { loading, error, empty, noMatch }

class _CatalogStatePanel extends StatelessWidget {
  const _CatalogStatePanel.loading()
    : kind = _CatalogStateKind.loading,
      query = '',
      onRetry = null;

  const _CatalogStatePanel.empty()
    : kind = _CatalogStateKind.empty,
      query = '',
      onRetry = null;

  const _CatalogStatePanel.error({required this.onRetry})
    : kind = _CatalogStateKind.error,
      query = '';

  const _CatalogStatePanel.noMatch({required this.query})
    : kind = _CatalogStateKind.noMatch,
      onRetry = null;

  final _CatalogStateKind kind;
  final String query;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final (
      IconData icon,
      Color accent,
      String title,
      String message,
    ) = switch (kind) {
      _CatalogStateKind.loading => (
        Icons.manage_search_outlined,
        PharmaConnectColors.linkFocus,
        'Loading official catalog',
        'Fetching published product information for this session.',
      ),
      _CatalogStateKind.error => (
        Icons.error_outline,
        PharmaConnectColors.error,
        'Catalog information could not load',
        'The official catalog could not be retrieved. Try again safely.',
      ),
      _CatalogStateKind.empty => (
        Icons.library_books_outlined,
        PharmaConnectColors.secondaryText,
        'No official products yet',
        'Published catalog entries will appear here.',
      ),
      _CatalogStateKind.noMatch => (
        Icons.search_off_outlined,
        PharmaConnectColors.warning,
        'No catalog matches found',
        query.isEmpty
            ? 'Try a different trade name, generic name, or company.'
            : 'No published products match "$query".',
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PharmaConnectSpacing.xLarge),
      decoration: BoxDecoration(
        color: PharmaConnectColors.surface,
        borderRadius: BorderRadius.circular(PharmaConnectRadii.card),
        border: Border.all(color: PharmaConnectColors.subtleBorder),
      ),
      child: Column(
        children: <Widget>[
          if (kind == _CatalogStateKind.loading)
            const SizedBox.square(
              dimension: PharmaConnectSpacing.xLarge,
              child: CircularProgressIndicator(strokeWidth: 3),
            )
          else
            Icon(icon, color: accent, size: PharmaConnectSpacing.xLarge),
          const SizedBox(height: PharmaConnectSpacing.medium),
          Text(title, style: PharmaConnectTypography.cardTitle),
          const SizedBox(height: PharmaConnectSpacing.small),
          Text(
            message,
            textAlign: TextAlign.center,
            style: PharmaConnectTypography.supporting,
          ),
          if (onRetry != null) ...<Widget>[
            const SizedBox(height: PharmaConnectSpacing.large),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_outlined),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

class DoctorCatalogProductDetailPage extends ConsumerWidget {
  const DoctorCatalogProductDetailPage({required this.productId, super.key});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String normalizedId = productId.trim();
    final AsyncValue<ProductDetail>? detail = normalizedId.isEmpty
        ? null
        : ref.watch(officialProductDetailProvider(normalizedId));

    return Scaffold(
      backgroundColor: PharmaConnectColors.canvas,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isWide = constraints.maxWidth >= _wideCatalogBreakpoint;
            final double horizontalPadding = constraints.maxWidth < 380
                ? PharmaConnectSpacing.medium
                : isWide
                ? PharmaConnectSpacing.xLarge
                : PharmaConnectSpacing.large;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                PharmaConnectSpacing.large,
                horizontalPadding,
                PharmaConnectSpacing.xxLarge,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const _ProductDetailTopBar(),
                      const SizedBox(height: PharmaConnectSpacing.large),
                      if (detail == null)
                        const _ProductDetailState.notFound()
                      else
                        _ProductDetailBody(detail: detail, isWide: isWide),
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

class _ProductDetailTopBar extends StatelessWidget {
  const _ProductDetailTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton.outlined(
          tooltip: 'Back to official catalog',
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/catalog'),
          icon: const Icon(Icons.arrow_back_outlined),
        ),
        const SizedBox(width: PharmaConnectSpacing.compact),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Official product detail',
                style: PharmaConnectTypography.sectionTitle,
              ),
              Text(
                'Published catalog information',
                style: PharmaConnectTypography.supporting,
              ),
            ],
          ),
        ),
        const _PublishedSourceBadge(),
      ],
    );
  }
}

class _ProductDetailBody extends StatelessWidget {
  const _ProductDetailBody({required this.detail, required this.isWide});

  final AsyncValue<ProductDetail> detail;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    if (detail.hasError) {
      return const _ProductDetailState.error();
    }
    if (detail.isLoading) {
      return const _ProductDetailState.loading();
    }
    if (!detail.hasValue) {
      return const _ProductDetailState.notFound();
    }

    final _DoctorProductDetailData data = _DoctorProductDetailData.fromDetail(
      detail.requireValue,
    );
    final List<Widget> secondarySections = <Widget>[
      _DetailInformationCard(
        title: 'Product basics',
        icon: Icons.medication_outlined,
        rows: <_DetailInformationRow>[
          _DetailInformationRow('Dosage form', data.dosageForm),
          _DetailInformationRow('Strength', data.strength),
          _DetailInformationRow('Route', data.route),
          _DetailInformationRow('Presentation', data.packSize),
        ],
      ),
      if (data.composition.isNotEmpty)
        _DetailListCard(
          title: 'Composition',
          icon: Icons.science_outlined,
          items: data.composition,
        ),
      if (data.registrationRows.isNotEmpty)
        _DetailInformationCard(
          title: 'Iraq registration',
          icon: Icons.verified_outlined,
          rows: data.registrationRows,
        ),
      if (data.clinicalRows.isNotEmpty)
        _DetailInformationCard(
          title: 'Clinical information',
          icon: Icons.health_and_safety_outlined,
          caption: 'Official catalog information',
          rows: data.clinicalRows,
        ),
      if (data.catalogMetadataRows.isNotEmpty)
        _DetailInformationCard(
          title: 'Catalog metadata',
          icon: Icons.description_outlined,
          rows: data.catalogMetadataRows,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _ProductDetailHero(data: data),
        const SizedBox(height: PharmaConnectSpacing.medium),
        if (isWide)
          GridView.builder(
            key: const Key('doctor-product-detail-grid'),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: secondarySections.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: PharmaConnectSpacing.medium,
              mainAxisSpacing: PharmaConnectSpacing.medium,
              mainAxisExtent: 300,
            ),
            itemBuilder: (BuildContext context, int index) =>
                secondarySections[index],
          )
        else
          Column(
            key: const Key('doctor-product-detail-list'),
            children: <Widget>[
              for (
                int index = 0;
                index < secondarySections.length;
                index++
              ) ...<Widget>[
                if (index > 0)
                  const SizedBox(height: PharmaConnectSpacing.medium),
                secondarySections[index],
              ],
            ],
          ),
      ],
    );
  }
}

class _ProductDetailHero extends StatelessWidget {
  const _ProductDetailHero({required this.data});

  final _DoctorProductDetailData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PharmaConnectSpacing.xLarge),
      decoration: BoxDecoration(
        color: PharmaConnectColors.surface,
        borderRadius: BorderRadius.circular(PharmaConnectRadii.dialog),
        border: Border.all(color: PharmaConnectColors.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _PublishedProductBadge(),
          const SizedBox(height: PharmaConnectSpacing.medium),
          Text(data.brandName, style: PharmaConnectTypography.pageTitle),
          const SizedBox(height: PharmaConnectSpacing.small),
          Text(
            data.genericName,
            style: PharmaConnectTypography.featureTitle.copyWith(
              color: PharmaConnectColors.linkFocus,
            ),
          ),
          const SizedBox(height: PharmaConnectSpacing.large),
          Wrap(
            spacing: PharmaConnectSpacing.small,
            runSpacing: PharmaConnectSpacing.small,
            children: <Widget>[
              _DetailFactChip(
                icon: Icons.apartment_outlined,
                label: data.companyName,
              ),
              _DetailFactChip(
                icon: Icons.category_outlined,
                label: data.category,
              ),
              _DetailFactChip(
                icon: Icons.update_outlined,
                label: 'Updated ${data.updatedDate}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailFactChip extends StatelessWidget {
  const _DetailFactChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PharmaConnectSpacing.compact,
        vertical: PharmaConnectSpacing.small,
      ),
      decoration: BoxDecoration(
        color: PharmaConnectColors.elevatedSurface,
        borderRadius: BorderRadius.circular(PharmaConnectRadii.pill),
        border: Border.all(color: PharmaConnectColors.subtleBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 17, color: PharmaConnectColors.linkFocus),
          const SizedBox(width: PharmaConnectSpacing.small),
          Text(label, style: PharmaConnectTypography.label),
        ],
      ),
    );
  }
}

class _DetailInformationCard extends StatelessWidget {
  const _DetailInformationCard({
    required this.title,
    required this.icon,
    required this.rows,
    this.caption,
  });

  final String title;
  final IconData icon;
  final List<_DetailInformationRow> rows;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final List<_DetailInformationRow> visibleRows = rows
        .where((_DetailInformationRow row) => row.value.trim().isNotEmpty)
        .toList(growable: false);
    if (visibleRows.isEmpty) {
      return const SizedBox.shrink();
    }

    return _DetailSectionCard(
      title: title,
      icon: icon,
      caption: caption,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          for (int index = 0; index < visibleRows.length; index++) ...<Widget>[
            if (index > 0) const Divider(),
            Text(
              visibleRows[index].label,
              style: PharmaConnectTypography.auxiliary,
            ),
            const SizedBox(height: PharmaConnectSpacing.xSmall),
            Text(visibleRows[index].value, style: PharmaConnectTypography.body),
          ],
        ],
      ),
    );
  }
}

class _DetailListCard extends StatelessWidget {
  const _DetailListCard({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return _DetailSectionCard(
      title: title,
      icon: icon,
      child: Column(
        children: <Widget>[
          for (final String item in items)
            Padding(
              padding: const EdgeInsets.only(
                bottom: PharmaConnectSpacing.small,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(top: PharmaConnectSpacing.small),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: PharmaConnectColors.linkFocus,
                    ),
                  ),
                  const SizedBox(width: PharmaConnectSpacing.compact),
                  Expanded(
                    child: Text(item, style: PharmaConnectTypography.body),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailSectionCard extends StatelessWidget {
  const _DetailSectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.caption,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PharmaConnectSpacing.roomy),
      decoration: BoxDecoration(
        color: PharmaConnectColors.surface,
        borderRadius: BorderRadius.circular(PharmaConnectRadii.card),
        border: Border.all(color: PharmaConnectColors.subtleBorder),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  width: PharmaConnectSpacing.xxLarge,
                  height: PharmaConnectSpacing.xxLarge,
                  decoration: BoxDecoration(
                    color: PharmaConnectColors.deepBlue,
                    borderRadius: BorderRadius.circular(
                      PharmaConnectRadii.control,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: PharmaConnectColors.linkFocus,
                    size: 21,
                  ),
                ),
                const SizedBox(width: PharmaConnectSpacing.compact),
                Expanded(
                  child: Text(title, style: PharmaConnectTypography.cardTitle),
                ),
              ],
            ),
            if (caption != null) ...<Widget>[
              const SizedBox(height: PharmaConnectSpacing.small),
              Text(
                caption!,
                style: PharmaConnectTypography.auxiliary.copyWith(
                  color: PharmaConnectColors.linkFocus,
                ),
              ),
            ],
            const SizedBox(height: PharmaConnectSpacing.medium),
            child,
          ],
        ),
      ),
    );
  }
}

enum _ProductDetailStateKind { loading, error, notFound }

class _ProductDetailState extends StatelessWidget {
  const _ProductDetailState.loading() : kind = _ProductDetailStateKind.loading;

  const _ProductDetailState.error() : kind = _ProductDetailStateKind.error;

  const _ProductDetailState.notFound()
    : kind = _ProductDetailStateKind.notFound;

  final _ProductDetailStateKind kind;

  @override
  Widget build(BuildContext context) {
    final (
      IconData icon,
      Color accent,
      String title,
      String message,
    ) = switch (kind) {
      _ProductDetailStateKind.loading => (
        Icons.description_outlined,
        PharmaConnectColors.linkFocus,
        'Loading product detail',
        'Fetching the published official catalog entry.',
      ),
      _ProductDetailStateKind.error => (
        Icons.error_outline,
        PharmaConnectColors.error,
        'Product detail could not load',
        'Return to the catalog and try opening this product again.',
      ),
      _ProductDetailStateKind.notFound => (
        Icons.search_off_outlined,
        PharmaConnectColors.warning,
        'Product not found',
        'This official catalog entry could not be displayed safely.',
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PharmaConnectSpacing.xLarge),
      decoration: BoxDecoration(
        color: PharmaConnectColors.surface,
        borderRadius: BorderRadius.circular(PharmaConnectRadii.card),
        border: Border.all(color: PharmaConnectColors.subtleBorder),
      ),
      child: Column(
        children: <Widget>[
          if (kind == _ProductDetailStateKind.loading)
            const CircularProgressIndicator()
          else
            Icon(icon, size: PharmaConnectSpacing.xLarge, color: accent),
          const SizedBox(height: PharmaConnectSpacing.medium),
          Text(title, style: PharmaConnectTypography.cardTitle),
          const SizedBox(height: PharmaConnectSpacing.small),
          Text(
            message,
            textAlign: TextAlign.center,
            style: PharmaConnectTypography.supporting,
          ),
        ],
      ),
    );
  }
}

final class _DoctorProductSummaryData {
  const _DoctorProductSummaryData({
    required this.brandName,
    required this.genericName,
    required this.companyName,
    required this.presentation,
    required this.updatedLabel,
    required this.searchText,
  });

  factory _DoctorProductSummaryData.fromProduct(ProductSummary product) {
    final String brandName = _safeText(
      product.translations.resolve(ContentLocale.english)?.brandName,
      'Unnamed product',
    );
    final String genericName = _safeText(
      product.genericDrug?.translations.resolve(ContentLocale.english)?.name,
      'Generic name not recorded',
    );
    final String companyName = _safeText(
      product.company.companyName,
      'Company not recorded',
    );
    final ProductMarket? market = product.iraqMarket;
    final List<String> presentationParts = <String>[
      if (_hasText(market?.strength)) market!.strength.trim(),
      if (_hasText(market?.dosageForm)) market!.dosageForm.trim(),
    ];

    return _DoctorProductSummaryData(
      brandName: brandName,
      genericName: genericName,
      companyName: companyName,
      presentation: presentationParts.isEmpty
          ? 'Presentation not recorded'
          : presentationParts.join(' / '),
      updatedLabel: _formatShortDate(product.updatedAt),
      searchText: <String>[
        brandName,
        genericName,
        companyName,
      ].join(' ').toLowerCase(),
    );
  }

  final String brandName;
  final String genericName;
  final String companyName;
  final String presentation;
  final String updatedLabel;
  final String searchText;
}

final class _DoctorProductDetailData {
  const _DoctorProductDetailData({
    required this.brandName,
    required this.genericName,
    required this.companyName,
    required this.category,
    required this.updatedDate,
    required this.dosageForm,
    required this.strength,
    required this.route,
    required this.packSize,
    required this.composition,
    required this.registrationRows,
    required this.clinicalRows,
    required this.catalogMetadataRows,
  });

  factory _DoctorProductDetailData.fromDetail(ProductDetail detail) {
    final ProductMarket? market = detail.iraqMarket;
    final ProductMarketTranslation? clinical = market?.translations.resolve(
      ContentLocale.english,
    );
    final List<String> composition =
        detail.genericDrug?.composition
            .map(
              (GenericCompositionEntry entry) => _safeText(
                entry.ingredient.translations
                    .resolve(ContentLocale.english)
                    ?.name,
                entry.ingredient.code,
              ),
            )
            .where((String value) => value.isNotEmpty)
            .toList(growable: false) ??
        const <String>[];

    return _DoctorProductDetailData(
      brandName: _safeText(
        detail.translations.resolve(ContentLocale.english)?.brandName,
        'Unnamed product',
      ),
      genericName: _safeText(
        detail.genericDrug?.translations.resolve(ContentLocale.english)?.name,
        'Generic name not recorded',
      ),
      companyName: _safeText(
        detail.company.companyName,
        'Company not recorded',
      ),
      category: _readableValue(detail.category.databaseValue),
      updatedDate: _formatShortDate(detail.updatedAt),
      dosageForm: _safeText(market?.dosageForm, 'Not recorded'),
      strength: _safeText(market?.strength, 'Not recorded'),
      route: _safeText(market?.route, 'Not recorded'),
      packSize: _safeText(market?.packSize, 'Not recorded'),
      composition: composition,
      registrationRows: <_DetailInformationRow>[
        if (market != null)
          _DetailInformationRow(
            'Registration status',
            _readableValue(market.registrationStatus.databaseValue),
          ),
        if (_hasText(market?.registrationNumber))
          _DetailInformationRow(
            'Registration number',
            market!.registrationNumber!.trim(),
          ),
        if (_hasText(market?.registrationAuthority))
          _DetailInformationRow(
            'Registration authority',
            market!.registrationAuthority!.trim(),
          ),
        if (market?.registrationExpiresOn != null)
          _DetailInformationRow(
            'Registration expiry',
            _formatShortDate(market!.registrationExpiresOn!),
          ),
      ],
      clinicalRows: <_DetailInformationRow>[
        if (_hasText(clinical?.approvedIndications))
          _DetailInformationRow(
            'Indications',
            clinical!.approvedIndications.trim(),
          ),
        if (_hasText(clinical?.usualAdultDose))
          _DetailInformationRow(
            'Dosing notes',
            clinical!.usualAdultDose.trim(),
          ),
        if (_hasText(clinical?.contraindications))
          _DetailInformationRow(
            'Contraindications',
            clinical!.contraindications.trim(),
          ),
        if (_hasText(clinical?.commonAdverseEffects))
          _DetailInformationRow(
            'Warnings and adverse effects',
            clinical!.commonAdverseEffects.trim(),
          ),
      ],
      catalogMetadataRows: <_DetailInformationRow>[
        if (detail.media.isNotEmpty)
          _DetailInformationRow(
            'Media records',
            '${detail.media.length} item(s) recorded',
          ),
        if (detail.brochures.isNotEmpty)
          _DetailInformationRow(
            'Brochure records',
            '${detail.brochures.length} document(s) recorded',
          ),
      ],
    );
  }

  final String brandName;
  final String genericName;
  final String companyName;
  final String category;
  final String updatedDate;
  final String dosageForm;
  final String strength;
  final String route;
  final String packSize;
  final List<String> composition;
  final List<_DetailInformationRow> registrationRows;
  final List<_DetailInformationRow> clinicalRows;
  final List<_DetailInformationRow> catalogMetadataRows;
}

final class _DetailInformationRow {
  const _DetailInformationRow(this.label, this.value);

  final String label;
  final String value;
}

String _safeText(String? value, String fallback) {
  return _hasText(value) ? value!.trim() : fallback;
}

bool _hasText(String? value) => value != null && value.trim().isNotEmpty;

String _readableValue(String value) {
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
