import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmaconnect_catalog/pharmaconnect_catalog.dart';
import 'package:pharmaconnect_design_system/pharmaconnect_design_system.dart';

const ProductListRequest _officialCatalogHomeRequest = ProductListRequest();

class MobileOfficialCatalogEntryPage extends StatelessWidget {
  const MobileOfficialCatalogEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _OfficialCatalogHome();
  }
}

class MobileCompanyCatalogEntryPage extends StatelessWidget {
  const MobileCompanyCatalogEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Company catalog workflow entry')),
    );
  }
}

class _OfficialCatalogHome extends ConsumerStatefulWidget {
  const _OfficialCatalogHome();

  static const Color _background = Color(0xFF0B111B);
  static const Color _surface = Color(0xFF151E2C);
  static const Color _surfaceSoft = Color(0xFF1B2636);
  static const Color _mutedText = Color(0xFF93A3B8);

  @override
  ConsumerState<_OfficialCatalogHome> createState() =>
      _OfficialCatalogHomeState();
}

class _OfficialCatalogHomeState extends ConsumerState<_OfficialCatalogHome> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedChip = 'For you';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  void _selectChip(String label) {
    setState(() {
      _selectedChip = label;
    });
  }

  List<ProductSummary> _filterProducts(List<ProductSummary> products) {
    final String query = _searchQuery.trim().toLowerCase();
    final String chipQuery = _selectedChip == 'For you'
        ? ''
        : _selectedChip.toLowerCase();

    if (query.isEmpty && chipQuery.isEmpty) {
      return products;
    }

    return products
        .where((ProductSummary product) {
          final String searchableText = _ProductDisplayData.fromProduct(
            product,
          ).searchableText;
          return (query.isEmpty || searchableText.contains(query)) &&
              (chipQuery.isEmpty || searchableText.contains(chipQuery));
        })
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<ProductSummary>> products = ref.watch(
      officialProductListProvider(_officialCatalogHomeRequest),
    );

    return Scaffold(
      backgroundColor: _OfficialCatalogHome._background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double horizontalPadding = constraints.maxWidth < 380
                ? PharmaConnectSpacing.medium
                : PharmaConnectSpacing.large;
            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                PharmaConnectSpacing.medium,
                horizontalPadding,
                40,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const _CatalogHeader(),
                      const SizedBox(height: PharmaConnectSpacing.large),
                      _CatalogSearchBar(
                        controller: _searchController,
                        onChanged: _handleSearchChanged,
                        onClear: _searchQuery.isEmpty ? null : _clearSearch,
                      ),
                      const SizedBox(height: PharmaConnectSpacing.large),
                      const _SectionHeading(
                        title: 'Explore catalog',
                        trailing: 'Official sources',
                      ),
                      const SizedBox(height: 14),
                      const _QuickActionStrip(),
                      const SizedBox(height: 28),
                      _CategoryChips(
                        selectedLabel: _selectedChip,
                        onSelected: _selectChip,
                      ),
                      const SizedBox(height: 28),
                      const _SectionHeading(
                        title: 'Official products',
                        trailing: 'Provider data',
                      ),
                      const SizedBox(height: 14),
                      _OfficialProductSection(
                        products: products,
                        filteredProducts: products.maybeWhen(
                          data: _filterProducts,
                          orElse: () => const <ProductSummary>[],
                        ),
                        searchQuery: _searchQuery,
                        selectedChip: _selectedChip,
                        onRetry: () => ref.invalidate(
                          officialProductListProvider(
                            _officialCatalogHomeRequest,
                          ),
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

class _CatalogHeader extends StatelessWidget {
  const _CatalogHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: <Color>[Color(0xFF167FDE), Color(0xFF16B8A7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.person_outline_rounded, color: Colors.white),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Good morning, Doctor',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Explore the official medical catalog',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: _OfficialCatalogHome._mutedText,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        const _HeaderActionButton(icon: Icons.notifications_none_rounded),
      ],
    );
  }
}

class _HeaderActionButton extends StatelessWidget {
  const _HeaderActionButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _OfficialCatalogHome._surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Icon(icon, color: Colors.white, size: 23),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: Color(0xFF2BD4C0),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CatalogSearchBar extends StatelessWidget {
  const _CatalogSearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: _OfficialCatalogHome._surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x24000000),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          const Icon(Icons.search_rounded, color: Color(0xFF7F91A8), size: 25),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              cursorColor: const Color(0xFF2BC7B5),
              maxLines: 1,
              textInputAction: TextInputAction.search,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search drugs, generics, companies...',
                hintStyle: TextStyle(
                  color: _OfficialCatalogHome._mutedText,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (onClear != null)
            IconButton(
              tooltip: 'Clear catalog search',
              visualDensity: VisualDensity.compact,
              onPressed: onClear,
              icon: const Icon(
                Icons.close_rounded,
                color: Color(0xFF93A3B8),
                size: 20,
              ),
            )
          else
            const Icon(Icons.tune_rounded, color: Color(0xFF2BC7B5), size: 22),
        ],
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.trailing});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ),
        Text(
          trailing,
          style: const TextStyle(
            color: Color(0xFF35C9B7),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _QuickActionStrip extends StatelessWidget {
  const _QuickActionStrip();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 134,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            _QuickActionCard(
              label: 'Medicines',
              icon: Icons.medication_outlined,
              colors: <Color>[Color(0xFF1878DE), Color(0xFF2853B9)],
            ),
            SizedBox(width: 12),
            _QuickActionCard(
              label: 'Generics',
              icon: Icons.science_outlined,
              colors: <Color>[Color(0xFF735EDB), Color(0xFF523B9E)],
            ),
            SizedBox(width: 12),
            _QuickActionCard(
              label: 'Companies',
              icon: Icons.apartment_rounded,
              colors: <Color>[Color(0xFF119E98), Color(0xFF08706F)],
            ),
            SizedBox(width: 12),
            _QuickActionCard(
              label: 'New Products',
              icon: Icons.auto_awesome_outlined,
              colors: <Color>[Color(0xFFD06C9E), Color(0xFF874EAB)],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.label,
    required this.icon,
    required this.colors,
  });

  final String label;
  final IconData icon;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 122,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colors.last.withValues(alpha: 0.24),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 23),
          ),
          const Spacer(),
          Text(
            label,
            maxLines: 2,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({required this.selectedLabel, required this.onSelected});

  final String selectedLabel;
  final ValueChanged<String> onSelected;

  static const List<String> _labels = <String>[
    'For you',
    'Respiratory',
    'Cardiology',
    'Antibiotics',
    'Diabetes',
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _labels.length,
        separatorBuilder: (BuildContext context, int index) =>
            const SizedBox(width: 9),
        itemBuilder: (BuildContext context, int index) {
          final String label = _labels[index];
          final bool selected = label == selectedLabel;
          return InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => onSelected(label),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 17),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? PharmaConnectColors.primary
                    : _OfficialCatalogHome._surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF21C9B8)
                      : Colors.white.withValues(alpha: 0.06),
                ),
              ),
              child: Text(
                label,
                style: TextStyle(
                  color: selected
                      ? Colors.white
                      : _OfficialCatalogHome._mutedText,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _OfficialProductSection extends StatelessWidget {
  const _OfficialProductSection({
    required this.products,
    required this.filteredProducts,
    required this.searchQuery,
    required this.selectedChip,
    required this.onRetry,
  });

  final AsyncValue<List<ProductSummary>> products;
  final List<ProductSummary> filteredProducts;
  final String searchQuery;
  final String selectedChip;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (products.hasError) {
      return _CatalogStateCard(
        icon: Icons.error_outline_rounded,
        accent: const Color(0xFFFF9B8D),
        title: 'Catalog information could not load',
        subtitle: 'Please try again or return later.',
        actionLabel: 'Retry',
        onAction: onRetry,
      );
    }

    if (products.isLoading) {
      return const _CatalogStateCard(
        icon: Icons.sync_rounded,
        accent: Color(0xFF35C9B7),
        title: 'Loading official catalog',
        subtitle: 'Fetching verified product information for this session.',
      );
    }

    final List<ProductSummary> productList = products.requireValue;
    if (productList.isEmpty) {
      return const _CatalogStateCard(
        icon: Icons.inventory_2_outlined,
        accent: Color(0xFF8C7CFF),
        title: 'No official products yet',
        subtitle: 'Published catalog entries will appear here.',
      );
    }

    if (filteredProducts.isEmpty) {
      return _CatalogStateCard(
        icon: Icons.search_off_rounded,
        accent: const Color(0xFF35C9B7),
        title: 'No catalog matches found',
        subtitle: _noMatchMessage,
      );
    }

    return Column(
      children: <Widget>[
        for (
          int index = 0;
          index < filteredProducts.length && index < 12;
          index++
        )
          Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : 14),
            child: index == 0
                ? _FeaturedProductCard(product: filteredProducts[index])
                : _ProductUpdateCard(product: filteredProducts[index]),
          ),
      ],
    );
  }

  String get _noMatchMessage {
    final String query = searchQuery.trim();
    final bool hasChip = selectedChip != 'For you';
    if (query.isNotEmpty && hasChip) {
      return 'No loaded products match "$query" in $selectedChip.';
    }
    if (query.isNotEmpty) {
      return 'No loaded products match "$query".';
    }
    return 'No loaded products match $selectedChip.';
  }
}

class _FeaturedProductCard extends StatelessWidget {
  const _FeaturedProductCard({required this.product});

  final ProductSummary product;

  @override
  Widget build(BuildContext context) {
    final _ProductDisplayData data = _ProductDisplayData.fromProduct(product);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _OfficialCatalogHome._surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Stack(
        children: <Widget>[
          const Positioned(
            right: -26,
            top: -38,
            child: _DecorativeOrb(
              size: 154,
              colors: <Color>[Color(0xFF176FCD), Color(0xFF16AFA1)],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text(
                        'RECENTLY UPDATED',
                        style: TextStyle(
                          color: Color(0xFF38CDBB),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        data.brandName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 9),
                      Text(
                        data.genericName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _OfficialCatalogHome._mutedText,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              data.presentation,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              data.companyName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFFB8C4D3),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Container(
                  width: 80,
                  height: 106,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(21),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: const Icon(
                    Icons.medication_liquid_outlined,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductUpdateCard extends StatelessWidget {
  const _ProductUpdateCard({required this.product});

  final ProductSummary product;

  @override
  Widget build(BuildContext context) {
    final _ProductDisplayData data = _ProductDisplayData.fromProduct(product);
    const Color accent = Color(0xFF8C7CFF);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _OfficialCatalogHome._surfaceSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.medication_outlined,
              color: accent,
              size: 27,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'OFFICIAL PRODUCT',
                  style: TextStyle(
                    color: accent,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  data.brandName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.genericName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _OfficialCatalogHome._mutedText,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '${data.companyName} / ${data.presentation}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFB8C4D3),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right_rounded, color: Color(0xFF718197)),
        ],
      ),
    );
  }
}

class _CatalogStateCard extends StatelessWidget {
  const _CatalogStateCard({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _OfficialCatalogHome._surfaceSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(icon, color: accent, size: 26),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: _OfficialCatalogHome._mutedText,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          if (actionLabel != null && onAction != null) ...<Widget>[
            const SizedBox(width: 10),
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

final class _ProductDisplayData {
  const _ProductDisplayData({
    required this.brandName,
    required this.genericName,
    required this.companyName,
    required this.presentation,
    required this.searchableText,
  });

  final String brandName;
  final String genericName;
  final String companyName;
  final String presentation;
  final String searchableText;

  static _ProductDisplayData fromProduct(ProductSummary product) {
    final String brandName = _fallback(
      product.translations.resolve(ContentLocale.english)?.brandName,
      'Unnamed product',
    );
    final String genericName = _fallback(
      product.genericDrug?.translations.resolve(ContentLocale.english)?.name,
      'Generic name not recorded',
    );
    final String companyName = _fallback(
      product.company.companyName,
      'Company not recorded',
    );
    final ProductMarket? market = product.iraqMarket;
    final List<String> presentationParts = <String>[
      if (_hasText(market?.strength)) market!.strength,
      if (_hasText(market?.dosageForm)) market!.dosageForm,
    ];
    final String presentation = presentationParts.isEmpty
        ? 'Presentation not recorded'
        : presentationParts.join(' / ');
    final String searchableText = <String>[
      brandName,
      genericName,
      companyName,
      if (_hasText(market?.dosageForm)) market!.dosageForm,
      if (_hasText(market?.strength)) market!.strength,
    ].join(' ').toLowerCase();

    return _ProductDisplayData(
      brandName: brandName,
      genericName: genericName,
      companyName: companyName,
      presentation: presentation,
      searchableText: searchableText,
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

class _DecorativeOrb extends StatelessWidget {
  const _DecorativeOrb({required this.size, required this.colors});

  final double size;
  final List<Color> colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[
            colors.first.withValues(alpha: 0.34),
            colors.last.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}
