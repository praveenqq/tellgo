// lib/screens/bundle_revised/bundle_revised.dart
//
// ✅ Integrated with new API endpoints
// - /Bundles/GetAllCategories for tabs
// - /Bundles/GetSubCategoryByCategoryId for countries/regions list
// - Shows 5 subcategories initially, "View More" shows 5 more

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/bundles_revised_bloc.dart';
import 'bloc/bundles_revised_event.dart';
import 'bloc/bundles_revised_state.dart';
import 'bundles_list_screen.dart';
import 'data/bundles_revised_repository.dart';
import 'data/models.dart';

/* -------------------------------------------------------------------------- */
/*                                   SCREEN                                   */
/* -------------------------------------------------------------------------- */

class BundlesStaticScreen extends StatefulWidget {
  const BundlesStaticScreen({super.key});

  @override
  State<BundlesStaticScreen> createState() => _BundlesStaticScreenState();
}

class _BundlesStaticScreenState extends State<BundlesStaticScreen> {
  // Tab colors for each category
  static const _tabColors = [
    Color(0xFF79C84E), // Local eSIMs - Green
    Color(0xFFF2A43A), // Regional eSIMs - Orange
    Color(0xFF5AA7D8), // Global eSIMs - Blue
  ];

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF6F3FF);

    return BlocProvider(
      create: (_) => BundlesRevisedBloc(BundlesRevisedRepository())
        ..add(const BundlesRevisedInit(categoryIndex: 0)),
      child: Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: BlocBuilder<BundlesRevisedBloc, BundlesRevisedState>(
                  builder: (context, state) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Category Tabs
                        _CategoryTabs(
                          categories: state.categories,
                          selectedIndex: state.selectedCategoryIndex,
                          tabColors: _tabColors,
                          onTap: (i) {
                            context.read<BundlesRevisedBloc>().add(
                                  BundlesRevisedSelectCategory(categoryIndex: i),
                                );
                          },
                        ),
                        const SizedBox(height: 14),
                        
                        // Loading state
                        if (state.isLoading && state.subCategories.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          )
                        // Error state
                        else if (state.error != null && state.subCategories.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: Text(
                              state.error!,
                              style: const TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          )
                        // Subcategories list
                        else
                          _SubCategoriesCard(subCategories: state.subCategories),
                        
                        const SizedBox(height: 16),
                        
                        // "View More" button
                        if (state.hasMoreToShow && !state.isLoading)
                        _ViewMoreButton(
                          onTap: () {
                              context.read<BundlesRevisedBloc>().add(
                                    const BundlesRevisedLoadMore(),
                                  );
                            },
                          ),
                        
                        // Loading indicator when loading more
                        if (state.isLoading && state.subCategories.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                               CATEGORY TABS                                */
/* -------------------------------------------------------------------------- */

class _CategoryTabs extends StatelessWidget {
  final List<BundleCategory> categories;
  final int selectedIndex;
  final List<Color> tabColors;
  final ValueChanged<int> onTap;

  const _CategoryTabs({
    required this.categories,
    required this.selectedIndex,
    required this.tabColors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Show loading placeholder if categories haven't loaded yet
    if (categories.isEmpty) {
      return Row(
        children: List.generate(3, (i) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == 2 ? 0 : 10),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'Loading...',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      );
    }

    return Row(
      children: List.generate(categories.length, (i) {
        final category = categories[i];
        final selected = i == selectedIndex;
        final bgColor = i < tabColors.length ? tabColors[i] : Colors.grey;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i == categories.length - 1 ? 0 : 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => onTap(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(selected ? 0.20 : 0.10),
                      blurRadius: selected ? 10 : 7,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    category.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                            SUBCATEGORIES LIST                              */
/* -------------------------------------------------------------------------- */

class _SubCategoriesCard extends StatelessWidget {
  final List<BundleSubCategory> subCategories;

  const _SubCategoriesCard({required this.subCategories});

  @override
  Widget build(BuildContext context) {
    debugPrint('🎨 _SubCategoriesCard - count: ${subCategories.length}');

    if (subCategories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Text(
          'No countries available for this category',
          style: TextStyle(color: Color(0xFF2C2440)),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Column(
      children: subCategories
          .map(
            (subCategory) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _SubCategoryPill(subCategory: subCategory),
            ),
          )
          .toList(),
    );
  }
}

class _SubCategoryPill extends StatelessWidget {
  final BundleSubCategory subCategory;

  const _SubCategoryPill({required this.subCategory});

  @override
  Widget build(BuildContext context) {
    const pillBg = Colors.white;
    const border = Color(0xFFB59AE6); // purple outline
    const nameColor = Color(0xFF2C2440);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BundlesListScreen(
              subCategoryId: subCategory.id,
              subCategoryName: subCategory.name,
              subCategoryLogo: subCategory.logo,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: pillBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border, width: 2),
        boxShadow: [
          AIMShadow.soft,
        ],
      ),
      child: Row(
        children: [
            // Flag/Logo
          Container(
            width: 34,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: const Color(0xFFF3EEFF),
            ),
              child: subCategory.logo.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                        subCategory.logo,
                      width: 34,
                      height: 24,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Text(
                          '🏳️',
                          style: TextStyle(fontSize: 18),
                        );
                      },
                    ),
                  )
                : const Text(
                    '🏳️',
                    style: TextStyle(fontSize: 18),
                  ),
          ),
          const SizedBox(width: 12),
            
            // Country/Region name
          Expanded(
            child: Text(
                subCategory.name,
              style: const TextStyle(
                color: nameColor,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
            
            // Lowest price (if available)
            if (subCategory.lowestPrice != null)
          Text(
                '\$${subCategory.lowestPrice!.toStringAsFixed(2)}',
            style: const TextStyle(
              color: nameColor,
              fontWeight: FontWeight.w800,
              fontSize: 14,
            ),
              )
            else
              const Icon(
                Icons.chevron_right,
                color: nameColor,
                size: 20,
          ),
        ],
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                 VIEW MORE                                  */
/* -------------------------------------------------------------------------- */

class _ViewMoreButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ViewMoreButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    const purple = Color(0xFF6B3FA6);

    return SizedBox(
      height: 46,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: purple,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'View More',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/*                                   SHADOW                                   */
/* -------------------------------------------------------------------------- */

class AIMShadow {
  static final soft = BoxShadow(
    color: Colors.black.withOpacity(0.08),
    blurRadius: 10,
    offset: const Offset(0, 6),
  );
}
