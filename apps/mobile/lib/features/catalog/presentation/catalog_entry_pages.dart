import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmaconnect_catalog/pharmaconnect_catalog.dart';
import 'package:pharmaconnect_design_system/pharmaconnect_design_system.dart';

const ProductListRequest _officialCatalogHomeRequest = ProductListRequest();

String _officialProductDetailLocation(String productId) =>
    '/catalog/products/${Uri.encodeComponent(productId)}';

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

String _taxonomyName(
  LocalizedContent<TaxonomyTranslation> translations,
  String fallback,
) {
  final String? name = translations.resolve(ContentLocale.english)?.name;
  if (name == null || name.trim().isEmpty) {
    return fallback;
  }
  return name.trim();
}

class MobileOfficialCatalogEntryPage extends StatelessWidget {
  const MobileOfficialCatalogEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _OfficialCatalogHome();
  }
}

class MobileCompanyCatalogEntryPage extends ConsumerWidget {
  const MobileCompanyCatalogEntryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<ProductSummary>> products = ref.watch(
      companyProductListProvider(null),
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
                      const _CompanyCatalogHeader(),
                      const SizedBox(height: PharmaConnectSpacing.large),
                      const _CompanyDraftActionCard(),
                      const SizedBox(height: 24),
                      const _SectionHeading(
                        title: 'Company catalog workflow',
                        trailing: 'Internal list',
                      ),
                      const SizedBox(height: 14),
                      _CompanyProductWorkflowSection(products: products),
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

class _CompanyCatalogHeader extends StatelessWidget {
  const _CompanyCatalogHeader();

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
              colors: <Color>[Color(0xFF119E98), Color(0xFF735EDB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Icon(Icons.apartment_rounded, color: Colors.white),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Company catalog',
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
                'Manage official catalog workflow drafts',
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
      ],
    );
  }
}

class _CompanyDraftActionCard extends StatelessWidget {
  const _CompanyDraftActionCard();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (BuildContext context) => const _CreateDraftSheet(),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _OfficialCatalogHome._surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
        ),
        child: Row(
          children: <Widget>[
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFF35C9B7).withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Icon(
                Icons.add_circle_outline_rounded,
                color: Color(0xFF35C9B7),
                size: 27,
              ),
            ),
            const SizedBox(width: 15),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Create product draft',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Start a minimal official catalog workflow draft.',
                    style: TextStyle(
                      color: _OfficialCatalogHome._mutedText,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF718197)),
          ],
        ),
      ),
    );
  }
}

class _CreateDraftSheet extends ConsumerStatefulWidget {
  const _CreateDraftSheet();

  @override
  ConsumerState<_CreateDraftSheet> createState() => _CreateDraftSheetState();
}

class _CreateDraftSheetState extends ConsumerState<_CreateDraftSheet> {
  final TextEditingController _brandNameController = TextEditingController();
  ProductCategory _category = ProductCategory.prescriptionDrug;
  String? _selectedDrugClassId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _brandNameController.dispose();
    super.dispose();
  }

  Future<void> _submit(CatalogCompanyAccess companyAccess) async {
    final String brandName = _brandNameController.text.trim();
    final String? drugClassId = _selectedDrugClassId;
    if (brandName.isEmpty || drugClassId == null || _isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref
          .read(companyCatalogMutationController.notifier)
          .createDraft(
            CreateProductDraftCommand(
              companyId: companyAccess.companyId,
              category: _category,
              drugClassId: drugClassId,
              englishBrandName: brandName,
            ),
          );

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Product draft created.')));
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product draft could not be created.')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<CatalogCompanyAccess?> companyAccess = ref.watch(
      currentCatalogCompanyAccessProvider,
    );
    final AsyncValue<List<DrugClass>> drugClasses = ref.watch(
      catalogDrugClassesProvider,
    );
    final bool isLoading = companyAccess.isLoading || drugClasses.isLoading;
    final bool hasError = companyAccess.hasError || drugClasses.hasError;
    final CatalogCompanyAccess? access = companyAccess.hasValue
        ? companyAccess.requireValue
        : null;
    final List<DrugClass> classes = drugClasses.hasValue
        ? drugClasses.requireValue
        : const <DrugClass>[];
    if (classes.isNotEmpty &&
        (_selectedDrugClassId == null ||
            !classes.any(
              (DrugClass value) => value.id == _selectedDrugClassId,
            ))) {
      _selectedDrugClassId = classes.first.id;
    }
    final bool canSubmit =
        access != null &&
        access.canManageDrafts &&
        classes.isNotEmpty &&
        _brandNameController.text.trim().isNotEmpty &&
        !_isSubmitting;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        decoration: const BoxDecoration(
          color: _OfficialCatalogHome._background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Create product draft',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Enter only the fields required by the current catalog draft command.',
                  style: TextStyle(
                    color: _OfficialCatalogHome._mutedText,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 20),
                if (isLoading)
                  const _CatalogStateCard(
                    icon: Icons.sync_rounded,
                    accent: Color(0xFF35C9B7),
                    title: 'Loading draft fields',
                    subtitle: 'Fetching company and taxonomy data.',
                  )
                else if (hasError)
                  const _CatalogStateCard(
                    icon: Icons.error_outline_rounded,
                    accent: Color(0xFFFF9B8D),
                    title: 'Draft fields could not load',
                    subtitle: 'Required provider data is unavailable.',
                  )
                else if (access == null || !access.canManageDrafts)
                  const _CatalogStateCard(
                    icon: Icons.lock_outline_rounded,
                    accent: Color(0xFFFF9B8D),
                    title: 'Draft creation unavailable',
                    subtitle:
                        'This account cannot manage company catalog drafts.',
                  )
                else if (classes.isEmpty)
                  const _CatalogStateCard(
                    icon: Icons.category_outlined,
                    accent: Color(0xFF8C7CFF),
                    title: 'No drug classes available',
                    subtitle:
                        'A provider-supplied drug class is required before creating a draft.',
                  )
                else ...<Widget>[
                  _DraftTextField(
                    controller: _brandNameController,
                    label: 'English brand name',
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 14),
                  _DraftDropdown<ProductCategory>(
                    label: 'Product category',
                    value: _category,
                    items: ProductCategory.values,
                    itemLabel: (ProductCategory value) =>
                        _readableCatalogValue(value.databaseValue),
                    onChanged: (ProductCategory? value) {
                      if (value != null) {
                        setState(() {
                          _category = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  _DraftDropdown<String>(
                    label: 'Drug class',
                    value: _selectedDrugClassId,
                    items: classes.map((DrugClass value) => value.id).toList(),
                    itemLabel: (String value) {
                      final DrugClass drugClass = classes.firstWhere(
                        (DrugClass candidate) => candidate.id == value,
                      );
                      return _taxonomyName(
                        drugClass.translations,
                        drugClass.code,
                      );
                    },
                    onChanged: (String? value) {
                      setState(() {
                        _selectedDrugClassId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: canSubmit ? () => _submit(access) : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: PharmaConnectColors.primary,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.white.withValues(
                          alpha: 0.08,
                        ),
                        disabledForegroundColor: Colors.white.withValues(
                          alpha: 0.38,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        _isSubmitting ? 'Creating draft...' : 'Create draft',
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DraftTextField extends StatelessWidget {
  const _DraftTextField({
    required this.controller,
    required this.label,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      cursorColor: const Color(0xFF35C9B7),
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _OfficialCatalogHome._mutedText),
        filled: true,
        fillColor: _OfficialCatalogHome._surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF35C9B7)),
        ),
      ),
    );
  }
}

class _DraftDropdown<T> extends StatelessWidget {
  const _DraftDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T value) itemLabel;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items
          .map(
            (T item) => DropdownMenuItem<T>(
              value: item,
              child: Text(itemLabel(item), overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
      onChanged: onChanged,
      dropdownColor: _OfficialCatalogHome._surface,
      iconEnabledColor: const Color(0xFF35C9B7),
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: _OfficialCatalogHome._mutedText),
        filled: true,
        fillColor: _OfficialCatalogHome._surface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF35C9B7)),
        ),
      ),
    );
  }
}

class _CompanyProductWorkflowSection extends StatelessWidget {
  const _CompanyProductWorkflowSection({required this.products});

  final AsyncValue<List<ProductSummary>> products;

  @override
  Widget build(BuildContext context) {
    if (products.hasError) {
      return const _CatalogStateCard(
        icon: Icons.error_outline_rounded,
        accent: Color(0xFFFF9B8D),
        title: 'Company catalog could not load',
        subtitle: 'Please try again or return later.',
      );
    }

    if (products.isLoading) {
      return const _CatalogStateCard(
        icon: Icons.sync_rounded,
        accent: Color(0xFF35C9B7),
        title: 'Loading company catalog',
        subtitle: 'Fetching workflow products for this session.',
      );
    }

    final List<ProductSummary> productList = products.requireValue;
    if (productList.isEmpty) {
      return const _CatalogStateCard(
        icon: Icons.inventory_2_outlined,
        accent: Color(0xFF8C7CFF),
        title: 'No company products yet',
        subtitle: 'Drafts and submitted products will appear here.',
      );
    }

    return Column(
      children: <Widget>[
        for (int index = 0; index < productList.length; index++)
          Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : 14),
            child: _CompanyProductWorkflowCard(product: productList[index]),
          ),
      ],
    );
  }
}

class _CompanyProductWorkflowCard extends StatelessWidget {
  const _CompanyProductWorkflowCard({required this.product});

  final ProductSummary product;

  @override
  Widget build(BuildContext context) {
    final _ProductDisplayData data = _ProductDisplayData.fromProduct(product);
    final String status = _readableCatalogValue(product.status.databaseValue);

    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _OfficialCatalogHome._surfaceSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFF35C9B7).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: Color(0xFF35C9B7),
              size: 25,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        data.brandName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _WorkflowStatusPill(label: status),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  data.genericName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _OfficialCatalogHome._mutedText,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  'Updated ${_formatShortDate(product.updatedAt)}',
                  style: const TextStyle(
                    color: Color(0xFFB8C4D3),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
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

class _WorkflowStatusPill extends StatelessWidget {
  const _WorkflowStatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF8C7CFF).withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFC9C2FF),
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class MobileOfficialCatalogProductDetailPage extends ConsumerWidget {
  const MobileOfficialCatalogProductDetailPage({
    required this.productId,
    super.key,
  });

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String normalizedProductId = productId.trim();
    final AsyncValue<ProductDetail>? detail = normalizedProductId.isEmpty
        ? null
        : ref.watch(officialProductDetailProvider(normalizedProductId));

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
                      const _DetailTopBar(),
                      const SizedBox(height: PharmaConnectSpacing.large),
                      if (detail == null)
                        const _CatalogStateCard(
                          icon: Icons.search_off_rounded,
                          accent: Color(0xFFFF9B8D),
                          title: 'Product not found',
                          subtitle:
                              'This official catalog entry could not be opened safely.',
                        )
                      else
                        _OfficialProductDetailContent(detail: detail),
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

class _DetailTopBar extends StatelessWidget {
  const _DetailTopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () =>
              context.canPop() ? context.pop() : context.go('/catalog'),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _OfficialCatalogHome._surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Official product detail',
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
                'Official catalog information',
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
      ],
    );
  }
}

class _OfficialProductDetailContent extends StatelessWidget {
  const _OfficialProductDetailContent({required this.detail});

  final AsyncValue<ProductDetail> detail;

  @override
  Widget build(BuildContext context) {
    if (detail.hasError) {
      return const _CatalogStateCard(
        icon: Icons.error_outline_rounded,
        accent: Color(0xFFFF9B8D),
        title: 'Product detail could not load',
        subtitle: 'Please try again or return to the catalog.',
      );
    }

    if (detail.isLoading) {
      return const _CatalogStateCard(
        icon: Icons.sync_rounded,
        accent: Color(0xFF35C9B7),
        title: 'Loading product detail',
        subtitle: 'Fetching the official catalog entry for this session.',
      );
    }

    if (!detail.hasValue) {
      return const _CatalogStateCard(
        icon: Icons.search_off_rounded,
        accent: Color(0xFF8C7CFF),
        title: 'Product not found',
        subtitle: 'This official catalog entry is not ready to display.',
      );
    }

    final ProductDetail product = detail.requireValue;
    final _ProductDetailDisplayData data = _ProductDetailDisplayData.fromDetail(
      product,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _DetailHeroCard(data: data),
        const SizedBox(height: 18),
        _DetailInfoSection(
          title: 'Product basics',
          icon: Icons.medication_outlined,
          rows: <_DetailInfoRow>[
            _DetailInfoRow('Dosage form', data.dosageForm),
            _DetailInfoRow('Strength', data.strength),
            _DetailInfoRow('Route', data.route),
            _DetailInfoRow('Package', data.packSize),
          ],
        ),
        if (data.composition.isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          _DetailTextSection(
            title: 'Composition',
            icon: Icons.science_outlined,
            items: data.composition,
          ),
        ],
        if (data.marketRows.isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          _DetailInfoSection(
            title: 'Iraq market information',
            icon: Icons.verified_outlined,
            rows: data.marketRows,
          ),
        ],
        if (data.clinicalRows.isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          _DetailInfoSection(
            title: 'Clinical information',
            icon: Icons.health_and_safety_outlined,
            caption: 'Official catalog information',
            rows: data.clinicalRows,
          ),
        ],
        if (data.metadataRows.isNotEmpty) ...<Widget>[
          const SizedBox(height: 14),
          _DetailInfoSection(
            title: 'Media and brochure metadata',
            icon: Icons.perm_media_outlined,
            rows: data.metadataRows,
          ),
        ],
      ],
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

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => context.push(_officialProductDetailLocation(product.id)),
      child: Container(
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

    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: () => context.push(_officialProductDetailLocation(product.id)),
      child: Container(
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
      ),
    );
  }
}

class _DetailHeroCard extends StatelessWidget {
  const _DetailHeroCard({required this.data});

  final _ProductDetailDisplayData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _OfficialCatalogHome._surface,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Stack(
        children: <Widget>[
          const Positioned(
            right: -30,
            top: -44,
            child: _DecorativeOrb(
              size: 180,
              colors: <Color>[Color(0xFF176FCD), Color(0xFF16AFA1)],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'OFFICIAL CATALOG PRODUCT',
                  style: TextStyle(
                    color: Color(0xFF38CDBB),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.brandName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.genericName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _OfficialCatalogHome._mutedText,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: <Widget>[
                    _DetailPill(label: data.companyName),
                    _DetailPill(label: data.category),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailPill extends StatelessWidget {
  const _DetailPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DetailInfoSection extends StatelessWidget {
  const _DetailInfoSection({
    required this.title,
    required this.icon,
    required this.rows,
    this.caption,
  });

  final String title;
  final IconData icon;
  final List<_DetailInfoRow> rows;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    final List<_DetailInfoRow> visibleRows = rows
        .where((_DetailInfoRow row) => row.value.trim().isNotEmpty)
        .toList(growable: false);

    if (visibleRows.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _OfficialCatalogHome._surfaceSoft,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _DetailSectionTitle(title: title, icon: icon),
          if (caption != null) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              caption!,
              style: const TextStyle(
                color: Color(0xFF35C9B7),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
          const SizedBox(height: 14),
          for (int index = 0; index < visibleRows.length; index++) ...<Widget>[
            if (index > 0) const SizedBox(height: 12),
            _DetailRow(row: visibleRows[index]),
          ],
        ],
      ),
    );
  }
}

class _DetailTextSection extends StatelessWidget {
  const _DetailTextSection({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<String> items;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _DetailSectionTitle(title: title, icon: icon),
          const SizedBox(height: 14),
          for (final String item in items) ...<Widget>[
            Text(
              item,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                height: 1.4,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (item != items.last) const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _DetailSectionTitle extends StatelessWidget {
  const _DetailSectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF35C9B7).withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(icon, color: const Color(0xFF35C9B7), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.row});

  final _DetailInfoRow row;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          row.label,
          style: const TextStyle(
            color: _OfficialCatalogHome._mutedText,
            fontSize: 11,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          row.value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

final class _DetailInfoRow {
  const _DetailInfoRow(this.label, this.value);

  final String label;
  final String value;
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

final class _ProductDetailDisplayData {
  const _ProductDetailDisplayData({
    required this.brandName,
    required this.genericName,
    required this.companyName,
    required this.category,
    required this.dosageForm,
    required this.strength,
    required this.route,
    required this.packSize,
    required this.composition,
    required this.marketRows,
    required this.clinicalRows,
    required this.metadataRows,
  });

  final String brandName;
  final String genericName;
  final String companyName;
  final String category;
  final String dosageForm;
  final String strength;
  final String route;
  final String packSize;
  final List<String> composition;
  final List<_DetailInfoRow> marketRows;
  final List<_DetailInfoRow> clinicalRows;
  final List<_DetailInfoRow> metadataRows;

  static _ProductDetailDisplayData fromDetail(ProductDetail detail) {
    final ProductMarket? market = detail.iraqMarket;
    final ProductMarketTranslation? marketTranslation = market?.translations
        .resolve(ContentLocale.english);
    final List<String> composition =
        detail.genericDrug?.composition
            .map(
              (GenericCompositionEntry entry) => _fallback(
                entry.ingredient.translations
                    .resolve(ContentLocale.english)
                    ?.name,
                entry.ingredient.code,
              ),
            )
            .where(_hasText)
            .toList(growable: false) ??
        const <String>[];
    final List<_DetailInfoRow> marketRows = <_DetailInfoRow>[
      if (_hasText(market?.registrationStatus.databaseValue))
        _DetailInfoRow(
          'Registration status',
          _readableValue(market!.registrationStatus.databaseValue),
        ),
      if (_hasText(market?.registrationNumber))
        _DetailInfoRow('Registration number', market!.registrationNumber!),
      if (_hasText(market?.registrationAuthority))
        _DetailInfoRow(
          'Registration authority',
          market!.registrationAuthority!,
        ),
      if (_hasText(market?.marketStatus.databaseValue))
        _DetailInfoRow(
          'Market status metadata',
          _readableValue(market!.marketStatus.databaseValue),
        ),
    ];
    final List<_DetailInfoRow> clinicalRows = <_DetailInfoRow>[
      if (_hasText(marketTranslation?.approvedIndications))
        _DetailInfoRow('Indications', marketTranslation!.approvedIndications),
      if (_hasText(marketTranslation?.usualAdultDose))
        _DetailInfoRow('Dosing notes', marketTranslation!.usualAdultDose),
      if (_hasText(marketTranslation?.contraindications))
        _DetailInfoRow(
          'Contraindications',
          marketTranslation!.contraindications,
        ),
      if (_hasText(marketTranslation?.commonAdverseEffects))
        _DetailInfoRow(
          'Warnings and adverse effects',
          marketTranslation!.commonAdverseEffects,
        ),
    ];
    final List<_DetailInfoRow> metadataRows = <_DetailInfoRow>[
      if (detail.media.isNotEmpty)
        _DetailInfoRow(
          'Media metadata',
          '${detail.media.length} item(s) recorded',
        ),
      if (detail.brochures.isNotEmpty)
        _DetailInfoRow(
          'Brochure metadata',
          '${detail.brochures.length} document(s) recorded',
        ),
    ];

    return _ProductDetailDisplayData(
      brandName: _fallback(
        detail.translations.resolve(ContentLocale.english)?.brandName,
        'Unnamed product',
      ),
      genericName: _fallback(
        detail.genericDrug?.translations.resolve(ContentLocale.english)?.name,
        'Generic name not recorded',
      ),
      companyName: _fallback(
        detail.company.companyName,
        'Company not recorded',
      ),
      category: _readableValue(detail.category.databaseValue),
      dosageForm: _fallback(market?.dosageForm, 'Not recorded'),
      strength: _fallback(market?.strength, 'Not recorded'),
      route: _fallback(market?.route, 'Not recorded'),
      packSize: _fallback(market?.packSize, 'Not recorded'),
      composition: composition,
      marketRows: marketRows,
      clinicalRows: clinicalRows,
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

  static String _readableValue(String value) {
    return value
        .split('_')
        .where((String part) => part.isNotEmpty)
        .map((String part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }
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
