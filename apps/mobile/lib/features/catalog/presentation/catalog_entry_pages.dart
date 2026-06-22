import 'package:flutter/material.dart';
import 'package:pharmaconnect_design_system/pharmaconnect_design_system.dart';

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

class _OfficialCatalogHome extends StatelessWidget {
  const _OfficialCatalogHome();

  static const Color _background = Color(0xFF0B111B);
  static const Color _surface = Color(0xFF151E2C);
  static const Color _surfaceSoft = Color(0xFF1B2636);
  static const Color _mutedText = Color(0xFF93A3B8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
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
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _CatalogHeader(),
                      SizedBox(height: PharmaConnectSpacing.large),
                      _CatalogSearchBar(),
                      SizedBox(height: PharmaConnectSpacing.large),
                      _SectionHeading(
                        title: 'Explore catalog',
                        trailing: 'Official sources',
                      ),
                      SizedBox(height: 14),
                      _QuickActionStrip(),
                      SizedBox(height: 28),
                      _CategoryChips(),
                      SizedBox(height: 28),
                      _SectionHeading(
                        title: 'Catalog updates',
                        trailing: 'View all',
                      ),
                      SizedBox(height: 14),
                      _FeaturedUpdateCard(),
                      SizedBox(height: 14),
                      _CompactUpdateCard(
                        icon: Icons.science_outlined,
                        accent: Color(0xFF8C7CFF),
                        eyebrow: 'DRUG INFORMATION',
                        title: 'Updated prescribing guidance',
                        subtitle:
                            'New clinical and safety information is available.',
                        meta: 'Updated today',
                      ),
                      SizedBox(height: 14),
                      _CompactUpdateCard(
                        icon: Icons.apartment_rounded,
                        accent: Color(0xFF20C8B7),
                        eyebrow: 'COMPANY HIGHLIGHT',
                        title: 'Official company catalog highlights',
                        subtitle:
                            'Browse newly verified catalog contributions.',
                        meta: '12 catalog updates',
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
  const _CatalogSearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 18),
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
      child: const Row(
        children: <Widget>[
          Icon(Icons.search_rounded, color: Color(0xFF7F91A8), size: 25),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Search drugs, generics, companies...',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _OfficialCatalogHome._mutedText,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(width: 8),
          Icon(Icons.tune_rounded, color: Color(0xFF2BC7B5), size: 22),
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
  const _CategoryChips();

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
          final bool selected = index == 0;
          return Container(
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
              _labels[index],
              style: TextStyle(
                color: selected
                    ? Colors.white
                    : _OfficialCatalogHome._mutedText,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FeaturedUpdateCard extends StatelessWidget {
  const _FeaturedUpdateCard();

  @override
  Widget build(BuildContext context) {
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
                        'RECENTLY PUBLISHED',
                        style: TextStyle(
                          color: Color(0xFF38CDBB),
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'New official products are now available',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 9),
                      const Text(
                        'Review verified product information published this week.',
                        style: TextStyle(
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
                            child: const Text(
                              '18 new products',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Color(0xFF3DD3C1),
                            size: 19,
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

class _CompactUpdateCard extends StatelessWidget {
  const _CompactUpdateCard({
    required this.icon,
    required this.accent,
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.meta,
  });

  final IconData icon;
  final Color accent;
  final String eyebrow;
  final String title;
  final String subtitle;
  final String meta;

  @override
  Widget build(BuildContext context) {
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
            child: Icon(icon, color: accent, size: 27),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  eyebrow,
                  style: TextStyle(
                    color: accent,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  title,
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
                  subtitle,
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
                  meta,
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
