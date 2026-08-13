import 'dart:typed_data';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pharmaconnect_catalog/pharmaconnect_catalog.dart';
import 'package:pharmaconnect_design_system/pharmaconnect_design_system.dart';

import 'doctor_catalog_pages.dart';

const ProductListRequest _officialCatalogHomeRequest = ProductListRequest();
const double _wideCompanyCatalogBreakpoint = 760;

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

String _formatDateInput(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';

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

bool _hasCatalogText(String? value) => value != null && value.trim().isNotEmpty;

class MobileOfficialCatalogEntryPage extends StatelessWidget {
  const MobileOfficialCatalogEntryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const DoctorCatalogHomePage();
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
      backgroundColor: PharmaConnectColors.canvas,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final bool isWide =
                constraints.maxWidth >= _wideCompanyCatalogBreakpoint;
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
                      _CompanyCatalogHeader(isWide: isWide),
                      const SizedBox(height: PharmaConnectSpacing.large),
                      _CompanyWorkflowOverview(
                        products: products,
                        isWide: isWide,
                      ),
                      const SizedBox(height: PharmaConnectSpacing.xLarge),
                      _CompanyWorkflowHeading(products: products),
                      const SizedBox(height: PharmaConnectSpacing.medium),
                      _CompanyProductWorkflowSection(
                        products: products,
                        isWide: isWide,
                        onRetry: () =>
                            ref.invalidate(companyProductListProvider(null)),
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

class _CompanyCatalogHeader extends StatelessWidget {
  const _CompanyCatalogHeader({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
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
        ),
        const SizedBox(width: PharmaConnectSpacing.compact),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Pharamty',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: isWide
                    ? PharmaConnectTypography.featureTitle
                    : PharmaConnectTypography.cardTitle,
              ),
              const Text(
                'Company catalog workspace',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: PharmaConnectTypography.supporting,
              ),
            ],
          ),
        ),
        Semantics(
          label: 'Official catalog workflow',
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isWide
                  ? PharmaConnectSpacing.compact
                  : PharmaConnectSpacing.small,
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
                  Icons.account_tree_outlined,
                  color: PharmaConnectColors.linkFocus,
                  size: 18,
                ),
                if (isWide) ...<Widget>[
                  const SizedBox(width: PharmaConnectSpacing.small),
                  Text(
                    'Official workflow',
                    style: PharmaConnectTypography.label.copyWith(
                      color: PharmaConnectColors.linkFocus,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CompanyWorkflowOverview extends StatelessWidget {
  const _CompanyWorkflowOverview({
    required this.products,
    required this.isWide,
  });

  final AsyncValue<List<ProductSummary>> products;
  final bool isWide;

  void _openCreateDraft(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => const _CreateDraftSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<ProductSummary>? productList = products.hasValue
        ? products.requireValue
        : null;
    final int editableCount =
        productList
            ?.where((ProductSummary value) => value.status.isCompanyEditable)
            .length ??
        0;
    final int reviewCount =
        productList
            ?.where(
              (ProductSummary value) =>
                  value.status == ProductLifecycleStatus.submitted,
            )
            .length ??
        0;
    final int publishedCount =
        productList
            ?.where(
              (ProductSummary value) =>
                  value.status == ProductLifecycleStatus.published,
            )
            .length ??
        0;

    final Widget introduction = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Official product workflow',
          style: PharmaConnectTypography.pageTitle,
        ),
        const SizedBox(height: PharmaConnectSpacing.small),
        const Text(
          'Prepare and submit official catalog records. Company-page publication remains a separate workflow.',
          style: PharmaConnectTypography.body,
        ),
        const SizedBox(height: PharmaConnectSpacing.large),
        FilledButton.icon(
          key: const Key('company-create-draft-button'),
          onPressed: () => _openCreateDraft(context),
          icon: const Icon(Icons.add_outlined),
          label: const Text('Create product draft'),
        ),
      ],
    );

    final Widget metrics = Wrap(
      spacing: PharmaConnectSpacing.small,
      runSpacing: PharmaConnectSpacing.small,
      children: <Widget>[
        _CompanyWorkflowMetric(
          label: 'Editable',
          value: productList == null ? '—' : '$editableCount',
          color: PharmaConnectColors.linkFocus,
        ),
        _CompanyWorkflowMetric(
          label: 'In review',
          value: productList == null ? '—' : '$reviewCount',
          color: PharmaConnectColors.warning,
        ),
        _CompanyWorkflowMetric(
          label: 'Published',
          value: productList == null ? '—' : '$publishedCount',
          color: PharmaConnectColors.success,
        ),
      ],
    );

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
                Expanded(flex: 5, child: introduction),
                const SizedBox(width: PharmaConnectSpacing.xLarge),
                Expanded(flex: 4, child: metrics),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                introduction,
                const SizedBox(height: PharmaConnectSpacing.large),
                metrics,
              ],
            ),
    );
  }
}

class _CompanyWorkflowMetric extends StatelessWidget {
  const _CompanyWorkflowMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 112),
      padding: const EdgeInsets.all(PharmaConnectSpacing.medium),
      decoration: BoxDecoration(
        color: PharmaConnectColors.elevatedSurface,
        borderRadius: BorderRadius.circular(PharmaConnectRadii.card),
        border: Border.all(color: PharmaConnectColors.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            value,
            style: PharmaConnectTypography.featureTitle.copyWith(color: color),
          ),
          const SizedBox(height: PharmaConnectSpacing.xSmall),
          Text(label, style: PharmaConnectTypography.auxiliary),
        ],
      ),
    );
  }
}

class _CompanyWorkflowHeading extends StatelessWidget {
  const _CompanyWorkflowHeading({required this.products});

  final AsyncValue<List<ProductSummary>> products;

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
                'Company products',
                style: PharmaConnectTypography.sectionTitle,
              ),
              SizedBox(height: PharmaConnectSpacing.xSmall),
              Text(
                'Draft, review, and publication status for official catalog records.',
                style: PharmaConnectTypography.supporting,
              ),
            ],
          ),
        ),
        if (products.hasValue)
          Text(
            '${products.requireValue.length} records',
            style: PharmaConnectTypography.label.copyWith(
              color: PharmaConnectColors.linkFocus,
            ),
          ),
      ],
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
  String? _selectedGenericDrugId;
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
              genericDrugId: _selectedGenericDrugId,
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
    final AsyncValue<List<GenericDrug>> genericDrugs = ref.watch(
      catalogGenericDrugsProvider,
    );
    final bool isLoading =
        companyAccess.isLoading ||
        drugClasses.isLoading ||
        genericDrugs.isLoading;
    final bool hasError =
        companyAccess.hasError || drugClasses.hasError || genericDrugs.hasError;
    final CatalogCompanyAccess? access = companyAccess.hasValue
        ? companyAccess.requireValue
        : null;
    final List<DrugClass> classes = drugClasses.hasValue
        ? drugClasses.requireValue
        : const <DrugClass>[];
    final List<GenericDrug> generics = genericDrugs.hasValue
        ? genericDrugs.requireValue
        : const <GenericDrug>[];
    if (classes.isNotEmpty &&
        (_selectedDrugClassId == null ||
            !classes.any(
              (DrugClass value) => value.id == _selectedDrugClassId,
            ))) {
      _selectedDrugClassId = classes.first.id;
    }
    if (generics.isNotEmpty &&
        (_selectedGenericDrugId == null ||
            !generics.any(
              (GenericDrug value) => value.id == _selectedGenericDrugId,
            ))) {
      _selectedGenericDrugId = generics.first.id;
    }
    final bool requiresGeneric = _category != ProductCategory.dietarySupplement;
    final bool canSubmit =
        access != null &&
        access.canManageDrafts &&
        classes.isNotEmpty &&
        (!requiresGeneric || _selectedGenericDrugId != null) &&
        _brandNameController.text.trim().isNotEmpty &&
        !_isSubmitting;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 720),
          padding: const EdgeInsets.fromLTRB(
            PharmaConnectSpacing.large,
            PharmaConnectSpacing.medium,
            PharmaConnectSpacing.large,
            PharmaConnectSpacing.xLarge,
          ),
          decoration: const BoxDecoration(
            color: PharmaConnectColors.canvas,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(PharmaConnectRadii.dialog),
            ),
            border: Border(
              top: BorderSide(color: PharmaConnectColors.strongBorder),
              left: BorderSide(color: PharmaConnectColors.strongBorder),
              right: BorderSide(color: PharmaConnectColors.strongBorder),
            ),
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
                        color: PharmaConnectColors.strongBorder,
                        borderRadius: BorderRadius.circular(
                          PharmaConnectRadii.pill,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Create product draft',
                    style: PharmaConnectTypography.featureTitle,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Enter only the fields required by the current catalog draft command.',
                    style: PharmaConnectTypography.supporting,
                  ),
                  const SizedBox(height: 20),
                  if (isLoading)
                    const _CompanyCatalogStatePanel(
                      icon: Icons.sync_outlined,
                      presentation:
                          PharmaConnectSemanticStatusMapper.unresolved,
                      title: 'Loading draft fields',
                      subtitle: 'Fetching company and taxonomy data.',
                      showProgress: true,
                    )
                  else if (hasError)
                    const _CompanyCatalogStatePanel(
                      icon: Icons.error_outline,
                      presentation: PharmaConnectSemanticStatusMapper.error,
                      title: 'Draft fields could not load',
                      subtitle: 'Required provider data could not be loaded.',
                    )
                  else if (access == null || !access.canManageDrafts)
                    const _CompanyCatalogStatePanel(
                      icon: Icons.lock_outline,
                      presentation: PharmaConnectSemanticStatusMapper.neutral,
                      title: 'Draft creation restricted',
                      subtitle:
                          'This account cannot manage company catalog drafts.',
                    )
                  else if (classes.isEmpty)
                    const _CompanyCatalogStatePanel(
                      icon: Icons.category_outlined,
                      presentation: PharmaConnectSemanticStatusMapper.warning,
                      title: 'No drug classes configured',
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
                      label: 'Generic drug',
                      value: _selectedGenericDrugId,
                      items: generics
                          .map((GenericDrug value) => value.id)
                          .toList(),
                      itemLabel: (String value) {
                        final GenericDrug generic = generics.firstWhere(
                          (GenericDrug candidate) => candidate.id == value,
                        );
                        return _taxonomyName(
                          generic.translations,
                          generic.code,
                        );
                      },
                      onChanged: (String? value) {
                        setState(() {
                          _selectedGenericDrugId = value;
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    _DraftDropdown<String>(
                      label: 'Drug class',
                      value: _selectedDrugClassId,
                      items: classes
                          .map((DrugClass value) => value.id)
                          .toList(),
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
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: PharmaConnectColors.elevatedSurface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PharmaConnectRadii.control),
          borderSide: const BorderSide(color: PharmaConnectColors.subtleBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PharmaConnectRadii.control),
          borderSide: const BorderSide(
            color: PharmaConnectColors.linkFocus,
            width: PharmaConnectBorders.focus,
          ),
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
      dropdownColor: PharmaConnectColors.elevatedSurface,
      iconEnabledColor: PharmaConnectColors.linkFocus,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: PharmaConnectColors.elevatedSurface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PharmaConnectRadii.control),
          borderSide: const BorderSide(color: PharmaConnectColors.subtleBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PharmaConnectRadii.control),
          borderSide: const BorderSide(
            color: PharmaConnectColors.linkFocus,
            width: PharmaConnectBorders.focus,
          ),
        ),
      ),
    );
  }
}

class _CompanyProductWorkflowSection extends StatelessWidget {
  const _CompanyProductWorkflowSection({
    required this.products,
    required this.isWide,
    required this.onRetry,
  });

  final AsyncValue<List<ProductSummary>> products;
  final bool isWide;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (products.hasError) {
      return _CompanyCatalogStatePanel(
        icon: Icons.error_outline,
        presentation: PharmaConnectSemanticStatusMapper.error,
        title: 'Company catalog could not load',
        subtitle: 'The workflow records are temporarily unavailable.',
        actionLabel: 'Retry',
        onAction: onRetry,
      );
    }

    if (products.isLoading) {
      return const _CompanyCatalogStatePanel(
        icon: Icons.sync_outlined,
        presentation: PharmaConnectSemanticStatusMapper.unresolved,
        title: 'Loading company catalog',
        subtitle: 'Retrieving workflow records for the current company.',
        showProgress: true,
      );
    }

    final List<ProductSummary> productList = products.requireValue;
    if (productList.isEmpty) {
      return const _CompanyCatalogStatePanel(
        icon: Icons.description_outlined,
        presentation: PharmaConnectSemanticStatusMapper.neutral,
        title: 'No company products yet',
        subtitle:
            'Create a product draft to begin the official catalog workflow.',
      );
    }

    if (!isWide) {
      return Column(
        key: const Key('company-catalog-list'),
        children: <Widget>[
          for (int index = 0; index < productList.length; index++) ...<Widget>[
            if (index > 0) const SizedBox(height: PharmaConnectSpacing.compact),
            _CompanyProductWorkflowCard(product: productList[index]),
          ],
        ],
      );
    }

    return GridView.builder(
      key: const Key('company-catalog-grid'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: productList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: PharmaConnectSpacing.medium,
        mainAxisSpacing: PharmaConnectSpacing.medium,
        mainAxisExtent: 218,
      ),
      itemBuilder: (BuildContext context, int index) =>
          _CompanyProductWorkflowCard(product: productList[index]),
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
    final PharmaConnectStatusPresentation statusPresentation =
        PharmaConnectSemanticStatusMapper.fromLifecycleValue(
          product.status.databaseValue,
        );

    return SizedBox(
      height: 218,
      child: Semantics(
        button: true,
        label: 'Open ${data.brandName} company workflow details',
        child: Material(
          color: PharmaConnectColors.surface,
          borderRadius: BorderRadius.circular(PharmaConnectRadii.card),
          child: InkWell(
            borderRadius: BorderRadius.circular(PharmaConnectRadii.card),
            onTap: () => showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (BuildContext context) =>
                  _CompanyProductDetailSheet(productId: product.id),
            ),
            child: Container(
              padding: const EdgeInsets.all(PharmaConnectSpacing.medium),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(PharmaConnectRadii.card),
                border: Border.all(color: PharmaConnectColors.subtleBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: PharmaConnectSpacing.xxxLarge,
                        height: PharmaConnectSpacing.xxxLarge,
                        decoration: BoxDecoration(
                          color: PharmaConnectColors.elevatedSurface,
                          borderRadius: BorderRadius.circular(
                            PharmaConnectRadii.control,
                          ),
                          border: Border.all(
                            color: PharmaConnectColors.subtleBorder,
                          ),
                        ),
                        child: const Icon(
                          Icons.description_outlined,
                          color: PharmaConnectColors.linkFocus,
                        ),
                      ),
                      const Spacer(),
                      _CompanyStatusBadge(
                        label: status,
                        presentation: statusPresentation,
                      ),
                    ],
                  ),
                  const SizedBox(height: PharmaConnectSpacing.medium),
                  Text(
                    data.brandName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: PharmaConnectTypography.cardTitle,
                  ),
                  const SizedBox(height: PharmaConnectSpacing.xSmall),
                  Text(
                    data.genericName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: PharmaConnectTypography.supporting,
                  ),
                  const Spacer(),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          _companyWorkflowCue(product.status),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: PharmaConnectTypography.auxiliary.copyWith(
                            color: statusPresentation.foreground,
                          ),
                        ),
                      ),
                      const SizedBox(width: PharmaConnectSpacing.small),
                      Text(
                        _formatShortDate(product.updatedAt),
                        style: PharmaConnectTypography.auxiliary,
                      ),
                      const SizedBox(width: PharmaConnectSpacing.small),
                      const Icon(
                        Icons.chevron_right_outlined,
                        color: PharmaConnectColors.secondaryText,
                        size: 20,
                      ),
                    ],
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

String _companyWorkflowCue(ProductLifecycleStatus status) {
  return switch (status) {
    ProductLifecycleStatus.draft => 'Complete required product information',
    ProductLifecycleStatus.changesRequested => 'Action required before review',
    ProductLifecycleStatus.submitted => 'Awaiting official catalog review',
    ProductLifecycleStatus.published => 'Published in the official catalog',
    ProductLifecycleStatus.hidden => 'Restricted from the official catalog',
    ProductLifecycleStatus.archived => 'Read-only workflow record',
  };
}

class _CompanyStatusBadge extends StatelessWidget {
  const _CompanyStatusBadge({required this.label, required this.presentation});

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
          style: PharmaConnectTypography.auxiliary.copyWith(
            color: presentation.foreground,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _CompanyCatalogStatePanel extends StatelessWidget {
  const _CompanyCatalogStatePanel({
    required this.icon,
    required this.presentation,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
    this.showProgress = false,
  });

  final IconData icon;
  final PharmaConnectStatusPresentation presentation;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool showProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('company-catalog-state-panel'),
      width: double.infinity,
      padding: const EdgeInsets.all(PharmaConnectSpacing.large),
      decoration: BoxDecoration(
        color: PharmaConnectColors.surface,
        borderRadius: BorderRadius.circular(PharmaConnectRadii.card),
        border: Border.all(color: presentation.border),
      ),
      child: Column(
        children: <Widget>[
          Icon(icon, color: presentation.foreground, size: 30),
          const SizedBox(height: PharmaConnectSpacing.compact),
          Text(
            title,
            textAlign: TextAlign.center,
            style: PharmaConnectTypography.cardTitle,
          ),
          const SizedBox(height: PharmaConnectSpacing.small),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: PharmaConnectTypography.supporting,
          ),
          if (showProgress) ...<Widget>[
            const SizedBox(height: PharmaConnectSpacing.medium),
            const LinearProgressIndicator(),
          ],
          if (actionLabel != null && onAction != null) ...<Widget>[
            const SizedBox(height: PharmaConnectSpacing.medium),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}

class _CompanyProductDetailSheet extends ConsumerStatefulWidget {
  const _CompanyProductDetailSheet({required this.productId});

  final String productId;

  @override
  ConsumerState<_CompanyProductDetailSheet> createState() =>
      _CompanyProductDetailSheetState();
}

class _CompanyProductDetailSheetState
    extends ConsumerState<_CompanyProductDetailSheet> {
  final TextEditingController _brandNameController = TextEditingController();
  final TextEditingController _strengthController = TextEditingController();
  final TextEditingController _dosageFormController = TextEditingController();
  final TextEditingController _routeController = TextEditingController();
  final TextEditingController _packSizeController = TextEditingController();
  final TextEditingController _registrationNumberController =
      TextEditingController();
  final TextEditingController _registrationAuthorityController =
      TextEditingController();
  final TextEditingController _registrationExpiresOnController =
      TextEditingController();
  final TextEditingController _storageConditionsController =
      TextEditingController();
  final TextEditingController _approvedIndicationsController =
      TextEditingController();
  final TextEditingController _usualAdultDoseController =
      TextEditingController();
  final TextEditingController _contraindicationsController =
      TextEditingController();
  final TextEditingController _commonAdverseEffectsController =
      TextEditingController();

  String? _loadedProductId;
  ProductCategory? _category;
  String? _drugClassId;
  String? _genericDrugId;
  IraqMarketStatus? _marketStatus;
  ProductRegistrationStatus? _registrationStatus;
  Set<String> _specialtyIds = const <String>{};
  bool _isSaving = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _brandNameController.dispose();
    _strengthController.dispose();
    _dosageFormController.dispose();
    _routeController.dispose();
    _packSizeController.dispose();
    _registrationNumberController.dispose();
    _registrationAuthorityController.dispose();
    _registrationExpiresOnController.dispose();
    _storageConditionsController.dispose();
    _approvedIndicationsController.dispose();
    _usualAdultDoseController.dispose();
    _contraindicationsController.dispose();
    _commonAdverseEffectsController.dispose();
    super.dispose();
  }

  void _hydrateProduct(ProductDetail product) {
    if (_loadedProductId == product.id) {
      return;
    }
    final ProductTranslation? translation = product.translations.resolve(
      ContentLocale.english,
    );
    final ProductMarket? market = product.iraqMarket;
    final ProductMarketTranslation? marketTranslation = market?.translations
        .resolve(ContentLocale.english);

    _loadedProductId = product.id;
    _category = product.category;
    _drugClassId = product.drugClass.id;
    _genericDrugId = product.genericDrug?.id;
    _marketStatus = market?.marketStatus ?? IraqMarketStatus.notMarketed;
    _registrationStatus =
        market?.registrationStatus ?? ProductRegistrationStatus.notRecorded;
    _specialtyIds = product.specialties
        .map((ProductSpecialty specialty) => specialty.id)
        .toSet();

    _brandNameController.text = translation?.brandName ?? '';
    _strengthController.text = market?.strength ?? '';
    _dosageFormController.text = market?.dosageForm ?? '';
    _routeController.text = market?.route ?? '';
    _packSizeController.text = market?.packSize ?? '';
    _registrationNumberController.text = market?.registrationNumber ?? '';
    _registrationAuthorityController.text = market?.registrationAuthority ?? '';
    _registrationExpiresOnController.text =
        market?.registrationExpiresOn == null
        ? ''
        : _formatDateInput(market!.registrationExpiresOn!);
    _storageConditionsController.text =
        marketTranslation?.storageConditions ?? '';
    _approvedIndicationsController.text =
        marketTranslation?.approvedIndications ?? '';
    _usualAdultDoseController.text = marketTranslation?.usualAdultDose ?? '';
    _contraindicationsController.text =
        marketTranslation?.contraindications ?? '';
    _commonAdverseEffectsController.text =
        marketTranslation?.commonAdverseEffects ?? '';
  }

  DateTime? _registrationExpiryFromInput() {
    final String raw = _registrationExpiresOnController.text.trim();
    if (raw.isEmpty) {
      return null;
    }
    return DateTime.tryParse(raw);
  }

  Future<void> _save(ProductDetail product) async {
    final ProductCategory category = _category ?? product.category;
    final String drugClassId = _drugClassId ?? product.drugClass.id;
    final String brandName = _brandNameController.text.trim();
    final DateTime? registrationExpiresOn = _registrationExpiryFromInput();
    if (_isSaving || !product.status.isCompanyEditable) {
      return;
    }
    if (brandName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('English brand name is required.')),
      );
      return;
    }
    if (_registrationExpiresOnController.text.trim().isNotEmpty &&
        registrationExpiresOn == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration expiry must use YYYY-MM-DD format.'),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await ref
          .read(companyCatalogMutationController.notifier)
          .upsertTranslation(
            productId: product.id,
            locale: ContentLocale.english,
            brandName: brandName,
          );
      await ref
          .read(companyCatalogMutationController.notifier)
          .updateDraft(
            UpdateProductDraftCommand(
              productId: product.id,
              category: category,
              drugClassId: drugClassId,
              genericDrugId: _genericDrugId,
            ),
          );
      await ref
          .read(companyCatalogMutationController.notifier)
          .upsertIraqMarket(
            ProductMarketCommand(
              productId: product.id,
              strength: _strengthController.text.trim(),
              dosageForm: _dosageFormController.text.trim(),
              route: _routeController.text.trim(),
              packSize: _packSizeController.text.trim(),
              marketStatus: _marketStatus ?? IraqMarketStatus.notMarketed,
              registrationStatus:
                  _registrationStatus ?? ProductRegistrationStatus.notRecorded,
              registrationNumber:
                  _registrationNumberController.text.trim().isEmpty
                  ? null
                  : _registrationNumberController.text.trim(),
              registrationAuthority:
                  _registrationAuthorityController.text.trim().isEmpty
                  ? null
                  : _registrationAuthorityController.text.trim(),
              registrationExpiresOn: registrationExpiresOn,
            ),
          );
      await ref
          .read(companyCatalogMutationController.notifier)
          .upsertMarketTranslation(
            ProductMarketTranslationCommand(
              productId: product.id,
              locale: ContentLocale.english,
              storageConditions: _storageConditionsController.text.trim(),
              approvedIndications: _approvedIndicationsController.text.trim(),
              usualAdultDose: _usualAdultDoseController.text.trim(),
              contraindications: _contraindicationsController.text.trim(),
              commonAdverseEffects: _commonAdverseEffectsController.text.trim(),
            ),
          );
      await ref
          .read(companyCatalogMutationController.notifier)
          .setSpecialties(product.id, _specialtyIds.toList(growable: false));

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product completion fields saved.')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Product completion fields could not be saved.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _submitForReview(ProductDetail product) async {
    if (!product.status.isCompanyEditable || _isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await ref
          .read(companyCatalogMutationController.notifier)
          .submitForReview(product.id);

      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product submitted for review.')),
      );
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product could not be submitted.')),
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
    final String productId = widget.productId.trim();
    final AsyncValue<ProductDetail>? detail = productId.isEmpty
        ? null
        : ref.watch(companyProductDetailProvider(productId));

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 960),
          padding: const EdgeInsets.fromLTRB(
            PharmaConnectSpacing.large,
            PharmaConnectSpacing.medium,
            PharmaConnectSpacing.large,
            PharmaConnectSpacing.xLarge,
          ),
          decoration: const BoxDecoration(
            color: PharmaConnectColors.canvas,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(PharmaConnectRadii.dialog),
            ),
            border: Border(
              top: BorderSide(color: PharmaConnectColors.strongBorder),
              left: BorderSide(color: PharmaConnectColors.strongBorder),
              right: BorderSide(color: PharmaConnectColors.strongBorder),
            ),
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
                        color: PharmaConnectColors.strongBorder,
                        borderRadius: BorderRadius.circular(
                          PharmaConnectRadii.pill,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Company product detail',
                    style: PharmaConnectTypography.featureTitle,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Workflow detail for the company catalog. Publication is separate.',
                    style: PharmaConnectTypography.supporting,
                  ),
                  const SizedBox(height: 20),
                  if (detail == null)
                    const _CompanyCatalogStatePanel(
                      icon: Icons.search_off_outlined,
                      presentation: PharmaConnectSemanticStatusMapper.neutral,
                      title: 'Product not found',
                      subtitle:
                          'This workflow product could not be opened safely.',
                    )
                  else
                    _CompanyProductDetailContent(
                      detail: detail,
                      onProductLoaded: _hydrateProduct,
                      brandNameController: _brandNameController,
                      strengthController: _strengthController,
                      dosageFormController: _dosageFormController,
                      routeController: _routeController,
                      packSizeController: _packSizeController,
                      registrationNumberController:
                          _registrationNumberController,
                      registrationAuthorityController:
                          _registrationAuthorityController,
                      registrationExpiresOnController:
                          _registrationExpiresOnController,
                      storageConditionsController: _storageConditionsController,
                      approvedIndicationsController:
                          _approvedIndicationsController,
                      usualAdultDoseController: _usualAdultDoseController,
                      contraindicationsController: _contraindicationsController,
                      commonAdverseEffectsController:
                          _commonAdverseEffectsController,
                      category: _category,
                      drugClassId: _drugClassId,
                      genericDrugId: _genericDrugId,
                      marketStatus: _marketStatus,
                      registrationStatus: _registrationStatus,
                      specialtyIds: _specialtyIds,
                      isSaving: _isSaving,
                      isSubmitting: _isSubmitting,
                      onCategoryChanged: (ProductCategory value) {
                        setState(() {
                          _category = value;
                        });
                      },
                      onDrugClassChanged: (String value) {
                        setState(() {
                          _drugClassId = value;
                        });
                      },
                      onGenericDrugChanged: (String? value) {
                        setState(() {
                          _genericDrugId = value;
                        });
                      },
                      onMarketStatusChanged: (IraqMarketStatus value) {
                        setState(() {
                          _marketStatus = value;
                        });
                      },
                      onRegistrationStatusChanged:
                          (ProductRegistrationStatus value) {
                            setState(() {
                              _registrationStatus = value;
                            });
                          },
                      onSpecialtyToggled: (String value, bool selected) {
                        setState(() {
                          final Set<String> next = Set<String>.of(
                            _specialtyIds,
                          );
                          if (selected) {
                            next.add(value);
                          } else {
                            next.remove(value);
                          }
                          _specialtyIds = next;
                        });
                      },
                      onSave: _save,
                      onSubmitForReview: _submitForReview,
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

class _CompanyProductDetailContent extends ConsumerWidget {
  const _CompanyProductDetailContent({
    required this.detail,
    required this.onProductLoaded,
    required this.brandNameController,
    required this.strengthController,
    required this.dosageFormController,
    required this.routeController,
    required this.packSizeController,
    required this.registrationNumberController,
    required this.registrationAuthorityController,
    required this.registrationExpiresOnController,
    required this.storageConditionsController,
    required this.approvedIndicationsController,
    required this.usualAdultDoseController,
    required this.contraindicationsController,
    required this.commonAdverseEffectsController,
    required this.category,
    required this.drugClassId,
    required this.genericDrugId,
    required this.marketStatus,
    required this.registrationStatus,
    required this.specialtyIds,
    required this.isSaving,
    required this.isSubmitting,
    required this.onCategoryChanged,
    required this.onDrugClassChanged,
    required this.onGenericDrugChanged,
    required this.onMarketStatusChanged,
    required this.onRegistrationStatusChanged,
    required this.onSpecialtyToggled,
    required this.onSave,
    required this.onSubmitForReview,
  });

  final AsyncValue<ProductDetail> detail;
  final ValueChanged<ProductDetail> onProductLoaded;
  final TextEditingController brandNameController;
  final TextEditingController strengthController;
  final TextEditingController dosageFormController;
  final TextEditingController routeController;
  final TextEditingController packSizeController;
  final TextEditingController registrationNumberController;
  final TextEditingController registrationAuthorityController;
  final TextEditingController registrationExpiresOnController;
  final TextEditingController storageConditionsController;
  final TextEditingController approvedIndicationsController;
  final TextEditingController usualAdultDoseController;
  final TextEditingController contraindicationsController;
  final TextEditingController commonAdverseEffectsController;
  final ProductCategory? category;
  final String? drugClassId;
  final String? genericDrugId;
  final IraqMarketStatus? marketStatus;
  final ProductRegistrationStatus? registrationStatus;
  final Set<String> specialtyIds;
  final bool isSaving;
  final bool isSubmitting;
  final ValueChanged<ProductCategory> onCategoryChanged;
  final ValueChanged<String> onDrugClassChanged;
  final ValueChanged<String?> onGenericDrugChanged;
  final ValueChanged<IraqMarketStatus> onMarketStatusChanged;
  final ValueChanged<ProductRegistrationStatus> onRegistrationStatusChanged;
  final void Function(String value, bool selected) onSpecialtyToggled;
  final Future<void> Function(ProductDetail product) onSave;
  final Future<void> Function(ProductDetail product) onSubmitForReview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (detail.isLoading) {
      return const _CompanyCatalogStatePanel(
        icon: Icons.sync_outlined,
        presentation: PharmaConnectSemanticStatusMapper.unresolved,
        title: 'Loading product detail',
        subtitle: 'Fetching company workflow product data for this session.',
        showProgress: true,
      );
    }

    if (detail.hasError) {
      return const _CompanyCatalogStatePanel(
        icon: Icons.error_outline,
        presentation: PharmaConnectSemanticStatusMapper.error,
        title: 'Product detail could not load',
        subtitle: 'Please try again or return to the company catalog.',
      );
    }

    if (!detail.hasValue) {
      return const _CompanyCatalogStatePanel(
        icon: Icons.search_off_outlined,
        presentation: PharmaConnectSemanticStatusMapper.neutral,
        title: 'Product not found',
        subtitle: 'This company workflow product is not ready to display.',
      );
    }

    final ProductDetail product = detail.requireValue;
    onProductLoaded(product);
    final _ProductDetailDisplayData data = _ProductDetailDisplayData.fromDetail(
      product,
    );
    final bool isCompanyEditable = product.status.isCompanyEditable;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _DetailHeroCard(data: data),
        const SizedBox(height: 14),
        _DetailInfoSection(
          title: 'Workflow status',
          icon: Icons.timeline_rounded,
          rows: <_DetailInfoRow>[
            _DetailInfoRow(
              'Lifecycle status',
              _readableCatalogValue(product.status.databaseValue),
            ),
            _DetailInfoRow('Updated', _formatShortDate(product.updatedAt)),
            if (product.lifecycle.submittedAt != null)
              _DetailInfoRow(
                'Submitted',
                _formatShortDate(product.lifecycle.submittedAt!),
              ),
            if (product.lifecycle.publishedAt != null)
              _DetailInfoRow(
                'Published',
                _formatShortDate(product.lifecycle.publishedAt!),
              ),
            if (_hasCatalogText(product.lifecycle.reviewReason))
              _DetailInfoRow('Review note', product.lifecycle.reviewReason!),
          ],
        ),
        const SizedBox(height: 14),
        _DetailInfoSection(
          title: 'Product basics',
          icon: Icons.medication_outlined,
          rows: <_DetailInfoRow>[
            _DetailInfoRow('Brand name', data.brandName),
            _DetailInfoRow('Generic name', data.genericName),
            _DetailInfoRow('Company', data.companyName),
            _DetailInfoRow('Category', data.category),
            _DetailInfoRow(
              'Drug class',
              _taxonomyName(
                product.drugClass.translations,
                product.drugClass.code,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (isCompanyEditable)
          _DraftEditShell(
            product: product,
            brandNameController: brandNameController,
            strengthController: strengthController,
            dosageFormController: dosageFormController,
            routeController: routeController,
            packSizeController: packSizeController,
            registrationNumberController: registrationNumberController,
            registrationAuthorityController: registrationAuthorityController,
            registrationExpiresOnController: registrationExpiresOnController,
            storageConditionsController: storageConditionsController,
            approvedIndicationsController: approvedIndicationsController,
            usualAdultDoseController: usualAdultDoseController,
            contraindicationsController: contraindicationsController,
            commonAdverseEffectsController: commonAdverseEffectsController,
            category: category ?? product.category,
            drugClassId: drugClassId ?? product.drugClass.id,
            genericDrugId: genericDrugId,
            marketStatus:
                marketStatus ??
                product.iraqMarket?.marketStatus ??
                IraqMarketStatus.notMarketed,
            registrationStatus:
                registrationStatus ??
                product.iraqMarket?.registrationStatus ??
                ProductRegistrationStatus.notRecorded,
            specialtyIds: specialtyIds,
            isSaving: isSaving,
            isSubmitting: isSubmitting,
            onCategoryChanged: onCategoryChanged,
            onDrugClassChanged: onDrugClassChanged,
            onGenericDrugChanged: onGenericDrugChanged,
            onMarketStatusChanged: onMarketStatusChanged,
            onRegistrationStatusChanged: onRegistrationStatusChanged,
            onSpecialtyToggled: onSpecialtyToggled,
            onSave: onSave,
            onSubmitForReview: onSubmitForReview,
          )
        else
          const _CompanyCatalogStatePanel(
            icon: Icons.lock_outline,
            presentation: PharmaConnectSemanticStatusMapper.neutral,
            title: 'Read-only workflow item',
            subtitle:
                'Only draft or changes-requested products can be edited in this phase.',
          ),
      ],
    );
  }
}

class _DraftEditShell extends ConsumerWidget {
  const _DraftEditShell({
    required this.product,
    required this.brandNameController,
    required this.strengthController,
    required this.dosageFormController,
    required this.routeController,
    required this.packSizeController,
    required this.registrationNumberController,
    required this.registrationAuthorityController,
    required this.registrationExpiresOnController,
    required this.storageConditionsController,
    required this.approvedIndicationsController,
    required this.usualAdultDoseController,
    required this.contraindicationsController,
    required this.commonAdverseEffectsController,
    required this.category,
    required this.drugClassId,
    required this.genericDrugId,
    required this.marketStatus,
    required this.registrationStatus,
    required this.specialtyIds,
    required this.isSaving,
    required this.isSubmitting,
    required this.onCategoryChanged,
    required this.onDrugClassChanged,
    required this.onGenericDrugChanged,
    required this.onMarketStatusChanged,
    required this.onRegistrationStatusChanged,
    required this.onSpecialtyToggled,
    required this.onSave,
    required this.onSubmitForReview,
  });

  final ProductDetail product;
  final TextEditingController brandNameController;
  final TextEditingController strengthController;
  final TextEditingController dosageFormController;
  final TextEditingController routeController;
  final TextEditingController packSizeController;
  final TextEditingController registrationNumberController;
  final TextEditingController registrationAuthorityController;
  final TextEditingController registrationExpiresOnController;
  final TextEditingController storageConditionsController;
  final TextEditingController approvedIndicationsController;
  final TextEditingController usualAdultDoseController;
  final TextEditingController contraindicationsController;
  final TextEditingController commonAdverseEffectsController;
  final ProductCategory category;
  final String drugClassId;
  final String? genericDrugId;
  final IraqMarketStatus marketStatus;
  final ProductRegistrationStatus registrationStatus;
  final Set<String> specialtyIds;
  final bool isSaving;
  final bool isSubmitting;
  final ValueChanged<ProductCategory> onCategoryChanged;
  final ValueChanged<String> onDrugClassChanged;
  final ValueChanged<String?> onGenericDrugChanged;
  final ValueChanged<IraqMarketStatus> onMarketStatusChanged;
  final ValueChanged<ProductRegistrationStatus> onRegistrationStatusChanged;
  final void Function(String value, bool selected) onSpecialtyToggled;
  final Future<void> Function(ProductDetail product) onSave;
  final Future<void> Function(ProductDetail product) onSubmitForReview;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<DrugClass>> drugClasses = ref.watch(
      catalogDrugClassesProvider,
    );
    final AsyncValue<List<GenericDrug>> genericDrugs = ref.watch(
      catalogGenericDrugsProvider,
    );
    final AsyncValue<List<ProductSpecialty>> specialties = ref.watch(
      catalogSpecialtiesProvider,
    );
    final AsyncValue<CatalogReadinessResult> readiness = ref.watch(
      companyProductReadinessProvider(
        CompanyProductReadinessRequest(
          productId: product.id,
          stage: CatalogReadinessStage.submission,
        ),
      ),
    );
    if (drugClasses.isLoading ||
        genericDrugs.isLoading ||
        specialties.isLoading) {
      return const _CompanyCatalogStatePanel(
        icon: Icons.sync_outlined,
        presentation: PharmaConnectSemanticStatusMapper.unresolved,
        title: 'Loading edit fields',
        subtitle: 'Fetching taxonomy choices for this workflow product.',
        showProgress: true,
      );
    }
    if (drugClasses.hasError || genericDrugs.hasError || specialties.hasError) {
      return const _CompanyCatalogStatePanel(
        icon: Icons.error_outline,
        presentation: PharmaConnectSemanticStatusMapper.error,
        title: 'Workflow edit could not load',
        subtitle:
            'Taxonomy choices are required to update this product safely.',
      );
    }

    final List<DrugClass> classes = drugClasses.requireValue;
    final List<GenericDrug> generics = genericDrugs.requireValue;
    final List<ProductSpecialty> activeSpecialties = specialties.requireValue
        .where((ProductSpecialty specialty) => specialty.isActive)
        .toList(growable: false);
    if (classes.isEmpty) {
      return const _CompanyCatalogStatePanel(
        icon: Icons.category_outlined,
        presentation: PharmaConnectSemanticStatusMapper.warning,
        title: 'Workflow edit restricted',
        subtitle: 'No provider-supplied drug classes are configured.',
      );
    }
    final bool hasSelectedDrugClass = classes.any(
      (DrugClass value) => value.id == drugClassId,
    );
    if (!hasSelectedDrugClass) {
      return const _CompanyCatalogStatePanel(
        icon: Icons.category_outlined,
        presentation: PharmaConnectSemanticStatusMapper.warning,
        title: 'Workflow edit restricted',
        subtitle:
            'The current drug class is missing from provider-supplied taxonomy choices.',
      );
    }
    final List<String> genericIds = <String>[
      '',
      ...generics.map((GenericDrug value) => value.id),
    ];
    final String selectedGenericId = genericDrugId ?? '';
    final String safeGenericId = genericIds.contains(selectedGenericId)
        ? selectedGenericId
        : '';
    final List<String> specialtyIdsList = activeSpecialties
        .map((ProductSpecialty specialty) => specialty.id)
        .toList(growable: false);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PharmaConnectSpacing.large),
      decoration: BoxDecoration(
        color: PharmaConnectColors.elevatedSurface,
        borderRadius: BorderRadius.circular(PharmaConnectRadii.dialog),
        border: Border.all(color: PharmaConnectColors.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _DetailSectionTitle(
            title: 'Product completion',
            icon: Icons.edit_note_rounded,
          ),
          const SizedBox(height: PharmaConnectSpacing.small),
          const Text(
            'Editable only for draft or changes-requested workflow products. Server validation remains authoritative.',
            style: PharmaConnectTypography.supporting,
          ),
          const SizedBox(height: 14),
          _CompletionSectionCard(
            title: 'Basics',
            icon: Icons.medication_liquid_outlined,
            children: <Widget>[
              _DraftTextField(
                controller: brandNameController,
                label: 'English brand name',
                onChanged: (_) {},
              ),
              const SizedBox(height: 14),
              _DraftDropdown<ProductCategory>(
                label: 'Product category',
                value: category,
                items: ProductCategory.values,
                itemLabel: (ProductCategory value) =>
                    _readableCatalogValue(value.databaseValue),
                onChanged: (ProductCategory? value) {
                  if (value != null) {
                    onCategoryChanged(value);
                  }
                },
              ),
              const SizedBox(height: 14),
              _DraftDropdown<String>(
                label: 'Drug class',
                value: drugClassId,
                items: classes.map((DrugClass value) => value.id).toList(),
                itemLabel: (String value) {
                  final DrugClass drugClass = classes.firstWhere(
                    (DrugClass candidate) => candidate.id == value,
                  );
                  return _taxonomyName(drugClass.translations, drugClass.code);
                },
                onChanged: (String? value) {
                  if (value != null) {
                    onDrugClassChanged(value);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 14),
          _CompletionSectionCard(
            title: 'Scientific and composition',
            icon: Icons.science_outlined,
            children: <Widget>[
              _DraftDropdown<String>(
                label: 'Generic/scientific product',
                value: safeGenericId,
                items: genericIds,
                itemLabel: (String value) {
                  if (value.isEmpty) {
                    return category == ProductCategory.dietarySupplement
                        ? 'No generic selected'
                        : 'Select generic/scientific product';
                  }
                  final GenericDrug generic = generics.firstWhere(
                    (GenericDrug candidate) => candidate.id == value,
                  );
                  return _taxonomyName(generic.translations, generic.code);
                },
                onChanged: (String? value) {
                  onGenericDrugChanged(
                    value == null || value.isEmpty ? null : value,
                  );
                },
              ),
              const SizedBox(height: 12),
              _CompositionPreview(
                generic: safeGenericId.isEmpty
                    ? null
                    : generics.firstWhere(
                        (GenericDrug value) => value.id == safeGenericId,
                      ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _CompletionSectionCard(
            title: 'Iraq market metadata',
            icon: Icons.public_rounded,
            children: <Widget>[
              _DraftTextField(
                controller: strengthController,
                label: 'Strength',
                onChanged: (_) {},
              ),
              const SizedBox(height: 14),
              _DraftTextField(
                controller: dosageFormController,
                label: 'Dosage form',
                onChanged: (_) {},
              ),
              const SizedBox(height: 14),
              _DraftTextField(
                controller: routeController,
                label: 'Route',
                onChanged: (_) {},
              ),
              const SizedBox(height: 14),
              _DraftTextField(
                controller: packSizeController,
                label: 'Package / presentation',
                onChanged: (_) {},
              ),
              const SizedBox(height: 14),
              _DraftDropdown<IraqMarketStatus>(
                label: 'Iraq market status metadata',
                value: marketStatus,
                items: IraqMarketStatus.values,
                itemLabel: (IraqMarketStatus value) =>
                    _readableCatalogValue(value.databaseValue),
                onChanged: (IraqMarketStatus? value) {
                  if (value != null) {
                    onMarketStatusChanged(value);
                  }
                },
              ),
              const SizedBox(height: 14),
              _DraftDropdown<ProductRegistrationStatus>(
                label: 'Registration status',
                value: registrationStatus,
                items: ProductRegistrationStatus.values,
                itemLabel: (ProductRegistrationStatus value) =>
                    _readableCatalogValue(value.databaseValue),
                onChanged: (ProductRegistrationStatus? value) {
                  if (value != null) {
                    onRegistrationStatusChanged(value);
                  }
                },
              ),
              const SizedBox(height: 14),
              _DraftTextField(
                controller: registrationNumberController,
                label: 'Registration number',
                onChanged: (_) {},
              ),
              const SizedBox(height: 14),
              _DraftTextField(
                controller: registrationAuthorityController,
                label: 'Registration authority',
                onChanged: (_) {},
              ),
              const SizedBox(height: 14),
              _DraftTextField(
                controller: registrationExpiresOnController,
                label: 'Registration expiry (YYYY-MM-DD)',
                onChanged: (_) {},
              ),
            ],
          ),
          const SizedBox(height: 14),
          _CompletionSectionCard(
            title: 'Clinical/catalog text',
            icon: Icons.fact_check_outlined,
            children: <Widget>[
              _CompletionTextArea(
                controller: storageConditionsController,
                label: 'Storage conditions',
              ),
              const SizedBox(height: 14),
              _CompletionTextArea(
                controller: approvedIndicationsController,
                label: 'Approved indications',
              ),
              const SizedBox(height: 14),
              _CompletionTextArea(
                controller: usualAdultDoseController,
                label: 'Usual adult dose',
              ),
              const SizedBox(height: 14),
              _CompletionTextArea(
                controller: contraindicationsController,
                label: 'Contraindications',
              ),
              const SizedBox(height: 14),
              _CompletionTextArea(
                controller: commonAdverseEffectsController,
                label: 'Warnings and adverse effects',
              ),
            ],
          ),
          const SizedBox(height: 14),
          _CompletionSectionCard(
            title: 'Specialties',
            icon: Icons.local_hospital_outlined,
            children: <Widget>[
              if (activeSpecialties.isEmpty)
                const Text(
                  'No active specialties are configured by taxonomy providers.',
                  style: PharmaConnectTypography.supporting,
                )
              else
                _SpecialtyChoices(
                  specialties: activeSpecialties,
                  selectedIds: specialtyIds.intersection(
                    specialtyIdsList.toSet(),
                  ),
                  onToggled: onSpecialtyToggled,
                ),
            ],
          ),
          const SizedBox(height: 14),
          _CompletionSectionCard(
            title: 'Product media and brochure',
            icon: Icons.perm_media_outlined,
            children: <Widget>[_CatalogMediaUploadSection(product: product)],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isSaving
                  ? null
                  : () {
                      onSave(product);
                    },
              child: Text(
                isSaving ? 'Saving changes...' : 'Save workflow changes',
              ),
            ),
          ),
          const SizedBox(height: 14),
          _SubmissionReadinessCard(
            readiness: readiness,
            isSubmitting: isSubmitting,
            onSubmit: () => onSubmitForReview(product),
          ),
        ],
      ),
    );
  }
}

class _CatalogMediaUploadSection extends ConsumerStatefulWidget {
  const _CatalogMediaUploadSection({required this.product});

  final ProductDetail product;

  @override
  ConsumerState<_CatalogMediaUploadSection> createState() =>
      _CatalogMediaUploadSectionState();
}

class _CatalogMediaUploadSectionState
    extends ConsumerState<_CatalogMediaUploadSection> {
  bool _isUploading = false;

  Future<void> _uploadImage(ProductMediaType type) async {
    final XFile? selected = await openFile(
      acceptedTypeGroups: const <XTypeGroup>[
        XTypeGroup(
          label: 'Catalog images',
          extensions: <String>['jpg', 'jpeg', 'png', 'webp'],
          mimeTypes: <String>['image/jpeg', 'image/png', 'image/webp'],
          uniformTypeIdentifiers: <String>[
            'public.jpeg',
            'public.png',
            'org.webmproject.webp',
          ],
        ),
      ],
    );
    if (selected == null) {
      return;
    }
    final String? mimeType = _imageMimeType(selected.name);
    await _upload(
      selected,
      mimeType: mimeType,
      operation: (CatalogUploadFile file) => ref
          .read(companyCatalogMutationController.notifier)
          .uploadProductMedia(
            productId: widget.product.id,
            type: type,
            file: file,
          ),
      successMessage: type == ProductMediaType.productImage
          ? 'Product image uploaded.'
          : 'Package image uploaded.',
    );
  }

  Future<void> _uploadBrochure() async {
    final XFile? selected = await openFile(
      acceptedTypeGroups: const <XTypeGroup>[
        XTypeGroup(
          label: 'PDF brochure',
          extensions: <String>['pdf'],
          mimeTypes: <String>['application/pdf'],
          uniformTypeIdentifiers: <String>['com.adobe.pdf'],
        ),
      ],
    );
    if (selected == null) {
      return;
    }
    await _upload(
      selected,
      mimeType: 'application/pdf',
      operation: (CatalogUploadFile file) => ref
          .read(companyCatalogMutationController.notifier)
          .uploadBrochure(
            productId: widget.product.id,
            locale: ContentLocale.english,
            title: _fileTitle(selected.name),
            file: file,
          ),
      successMessage: 'English brochure uploaded.',
    );
  }

  Future<void> _upload(
    XFile selected, {
    required String? mimeType,
    required Future<ProductDetail> Function(CatalogUploadFile file) operation,
    required String successMessage,
  }) async {
    if (_isUploading || mimeType == null) {
      _showMessage('The selected file could not be read safely.');
      return;
    }
    setState(() {
      _isUploading = true;
    });
    try {
      final Uint8List bytes = await selected.readAsBytes();
      await operation(
        CatalogUploadFile(
          fileName: selected.name,
          mimeType: mimeType,
          bytes: bytes,
        ),
      );
      if (mounted) {
        _showMessage(successMessage);
      }
    } catch (_) {
      if (mounted) {
        _showMessage(
          'The file could not be uploaded. Check its type and size.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final bool hasProductImage = widget.product.media.any(
      (ProductMediaMetadata item) => item.type == ProductMediaType.productImage,
    );
    final bool hasPackageImage = widget.product.media.any(
      (ProductMediaMetadata item) => item.type == ProductMediaType.packageImage,
    );
    final bool hasBrochure = widget.product.brochures.any(
      (ProductBrochureMetadata item) =>
          item.locale == ContentLocale.english && item.isCurrent,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _UploadStatusRow(
          label: 'Primary product image',
          isRecorded: hasProductImage,
          actionLabel: hasProductImage ? 'Replace image' : 'Upload image',
          onPressed: _isUploading
              ? null
              : () => _uploadImage(ProductMediaType.productImage),
        ),
        const SizedBox(height: 12),
        _UploadStatusRow(
          label: 'Primary package image',
          isRecorded: hasPackageImage,
          actionLabel: hasPackageImage ? 'Replace image' : 'Upload image',
          onPressed: _isUploading
              ? null
              : () => _uploadImage(ProductMediaType.packageImage),
        ),
        const SizedBox(height: 12),
        _UploadStatusRow(
          label: 'Current English PDF brochure',
          isRecorded: hasBrochure,
          actionLabel: hasBrochure ? 'Replace PDF' : 'Upload PDF',
          onPressed: _isUploading ? null : _uploadBrochure,
        ),
        if (_isUploading) ...<Widget>[
          const SizedBox(height: 14),
          const LinearProgressIndicator(),
          const SizedBox(height: 8),
          const Text(
            'Uploading securely...',
            style: PharmaConnectTypography.auxiliary,
          ),
        ],
        const SizedBox(height: 12),
        const Text(
          'Images: JPEG, PNG, or WebP up to 10 MiB. Brochure: PDF up to 25 MiB.',
          style: PharmaConnectTypography.auxiliary,
        ),
      ],
    );
  }
}

class _UploadStatusRow extends StatelessWidget {
  const _UploadStatusRow({
    required this.label,
    required this.isRecorded,
    required this.actionLabel,
    required this.onPressed,
  });

  final String label;
  final bool isRecorded;
  final String actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          isRecorded ? Icons.check_circle_outline : Icons.circle_outlined,
          color: isRecorded
              ? PharmaConnectColors.success
              : PharmaConnectColors.secondaryText,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(label, style: PharmaConnectTypography.supporting)),
        const SizedBox(width: 10),
        OutlinedButton(onPressed: onPressed, child: Text(actionLabel)),
      ],
    );
  }
}

String? _imageMimeType(String fileName) =>
    switch (fileName.split('.').last.toLowerCase()) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => null,
    };

String _fileTitle(String fileName) {
  final int extensionIndex = fileName.lastIndexOf('.');
  return extensionIndex > 0 ? fileName.substring(0, extensionIndex) : fileName;
}

class _CompletionSectionCard extends StatelessWidget {
  const _CompletionSectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PharmaConnectSpacing.medium),
      decoration: BoxDecoration(
        color: PharmaConnectColors.surface,
        borderRadius: BorderRadius.circular(PharmaConnectRadii.card),
        border: Border.all(color: PharmaConnectColors.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _DetailSectionTitle(title: title, icon: icon),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _CompletionTextArea extends StatelessWidget {
  const _CompletionTextArea({required this.controller, required this.label});

  final TextEditingController controller;
  final String label;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 2,
      maxLines: 4,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        filled: true,
        fillColor: PharmaConnectColors.elevatedSurface,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PharmaConnectRadii.control),
          borderSide: const BorderSide(color: PharmaConnectColors.subtleBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(PharmaConnectRadii.control),
          borderSide: const BorderSide(
            color: PharmaConnectColors.linkFocus,
            width: PharmaConnectBorders.focus,
          ),
        ),
      ),
    );
  }
}

class _CompositionPreview extends StatelessWidget {
  const _CompositionPreview({required this.generic});

  final GenericDrug? generic;

  @override
  Widget build(BuildContext context) {
    final List<String> ingredients =
        generic?.composition
            .map(
              (GenericCompositionEntry entry) => _taxonomyName(
                entry.ingredient.translations,
                entry.ingredient.code,
              ),
            )
            .where(_hasCatalogText)
            .toList(growable: false) ??
        const <String>[];

    if (generic == null) {
      return const Text(
        'Select a provider-supplied generic/scientific product to preview composition.',
        style: PharmaConnectTypography.supporting,
      );
    }

    if (ingredients.isEmpty) {
      return const Text(
        'This generic/scientific product has no active composition recorded.',
        style: PharmaConnectTypography.supporting,
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final String ingredient in ingredients)
          _DetailPill(label: ingredient),
      ],
    );
  }
}

class _SpecialtyChoices extends StatelessWidget {
  const _SpecialtyChoices({
    required this.specialties,
    required this.selectedIds,
    required this.onToggled,
  });

  final List<ProductSpecialty> specialties;
  final Set<String> selectedIds;
  final void Function(String value, bool selected) onToggled;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final ProductSpecialty specialty in specialties)
          FilterChip(
            selected: selectedIds.contains(specialty.id),
            label: Text(_taxonomyName(specialty.translations, specialty.code)),
            onSelected: (bool value) => onToggled(specialty.id, value),
            showCheckmark: false,
            backgroundColor: PharmaConnectColors.elevatedSurface,
            selectedColor: PharmaConnectColors.unresolvedContainer,
            side: BorderSide(
              color: selectedIds.contains(specialty.id)
                  ? PharmaConnectColors.unresolvedBorder
                  : PharmaConnectColors.subtleBorder,
            ),
            labelStyle: TextStyle(
              color: selectedIds.contains(specialty.id)
                  ? PharmaConnectColors.linkFocus
                  : PharmaConnectColors.secondaryText,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
      ],
    );
  }
}

class _SubmissionReadinessCard extends StatelessWidget {
  const _SubmissionReadinessCard({
    required this.readiness,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final AsyncValue<CatalogReadinessResult> readiness;
  final bool isSubmitting;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    if (readiness.hasError) {
      return const _CompanyCatalogStatePanel(
        icon: Icons.error_outline,
        presentation: PharmaConnectSemanticStatusMapper.error,
        title: 'Submission readiness could not load',
        subtitle: 'The submit action remains restricted until readiness loads.',
      );
    }

    if (readiness.isLoading) {
      return const _CompanyCatalogStatePanel(
        icon: Icons.sync_outlined,
        presentation: PharmaConnectSemanticStatusMapper.unresolved,
        title: 'Checking submission readiness',
        subtitle:
            'Provider readiness is advisory; submit validation remains authoritative.',
        showProgress: true,
      );
    }

    final CatalogReadinessResult result = readiness.requireValue;
    if (!result.isReady) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(PharmaConnectSpacing.large),
        decoration: BoxDecoration(
          color: PharmaConnectColors.warningContainer,
          borderRadius: BorderRadius.circular(PharmaConnectRadii.card),
          border: Border.all(color: PharmaConnectColors.warningBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _DetailSectionTitle(
              title: 'Not ready for review',
              icon: Icons.rule_rounded,
            ),
            const SizedBox(height: 12),
            Text(
              '${result.issues.length} completion ${result.issues.length == 1 ? 'item' : 'items'} require attention before submission.',
              style: PharmaConnectTypography.supporting,
            ),
            const SizedBox(height: 12),
            for (final CatalogReadinessIssue issue
                in result.issues) ...<Widget>[
              Text(
                _readableCatalogValue(issue.databaseValue),
                style: PharmaConnectTypography.body.copyWith(
                  color: PharmaConnectColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (issue != result.issues.last) const SizedBox(height: 8),
            ],
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PharmaConnectSpacing.large),
      decoration: BoxDecoration(
        color: PharmaConnectColors.successContainer,
        borderRadius: BorderRadius.circular(PharmaConnectRadii.card),
        border: Border.all(color: PharmaConnectColors.successBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const _DetailSectionTitle(
            title: 'Ready for review',
            icon: Icons.verified_outlined,
          ),
          const SizedBox(height: 12),
          const Text(
            'Readiness is advisory. The submit action will still use server-side validation.',
            style: PharmaConnectTypography.supporting,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isSubmitting ? null : onSubmit,
              child: Text(isSubmitting ? 'Submitting...' : 'Submit for review'),
            ),
          ),
        ],
      ),
    );
  }
}

class MobileOfficialCatalogProductDetailPage extends StatelessWidget {
  const MobileOfficialCatalogProductDetailPage({
    required this.productId,
    super.key,
  });

  final String productId;

  @override
  Widget build(BuildContext context) {
    return DoctorCatalogProductDetailPage(productId: productId);
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
        color: PharmaConnectColors.surface,
        borderRadius: BorderRadius.circular(PharmaConnectRadii.dialog),
        border: Border.all(color: PharmaConnectColors.subtleBorder),
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
                Text(
                  'COMPANY WORKFLOW PRODUCT',
                  style: PharmaConnectTypography.label.copyWith(
                    color: PharmaConnectColors.linkFocus,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  data.brandName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: PharmaConnectTypography.pageTitle,
                ),
                const SizedBox(height: 8),
                Text(
                  data.genericName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: PharmaConnectTypography.body,
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
        color: PharmaConnectColors.elevatedSurface,
        borderRadius: BorderRadius.circular(PharmaConnectRadii.pill),
        border: Border.all(color: PharmaConnectColors.strongBorder),
      ),
      child: Text(label, style: PharmaConnectTypography.label),
    );
  }
}

class _DetailInfoSection extends StatelessWidget {
  const _DetailInfoSection({
    required this.title,
    required this.icon,
    required this.rows,
  });

  final String title;
  final IconData icon;
  final List<_DetailInfoRow> rows;

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
      padding: const EdgeInsets.all(PharmaConnectSpacing.large),
      decoration: BoxDecoration(
        color: PharmaConnectColors.elevatedSurface,
        borderRadius: BorderRadius.circular(PharmaConnectRadii.card),
        border: Border.all(color: PharmaConnectColors.subtleBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _DetailSectionTitle(title: title, icon: icon),
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
            color: PharmaConnectColors.unresolvedContainer,
            borderRadius: BorderRadius.circular(PharmaConnectRadii.control),
            border: Border.all(color: PharmaConnectColors.unresolvedBorder),
          ),
          child: Icon(icon, color: PharmaConnectColors.linkFocus, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: PharmaConnectTypography.cardTitle)),
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
        Text(row.label, style: PharmaConnectTypography.auxiliary),
        const SizedBox(height: 4),
        Text(
          row.value,
          style: PharmaConnectTypography.body.copyWith(
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
