import 'package:equatable/equatable.dart';
import 'package:tellgo_app/screens/bundle_revised/data/models.dart';

class BundlesRevisedState extends Equatable {
  final bool isLoading;
  final String? error;

  // Categories (tabs)
  final List<BundleCategory> categories;
  final int selectedCategoryIndex; // 0 = Local, 1 = Regional, 2 = Global

  // SubCategories (countries/regions) for the selected category
  final Map<int, List<BundleSubCategory>> subCategoriesCache; // categoryId -> subcategories
  final List<BundleSubCategory> subCategories; // Currently visible subcategories

  // Pagination for subcategories display
  final Map<int, int> displayCountCache; // categoryId -> how many to display

  const BundlesRevisedState({
    this.isLoading = false,
    this.error,
    this.categories = const [],
    this.selectedCategoryIndex = 0,
    this.subCategoriesCache = const {},
    this.subCategories = const [],
    this.displayCountCache = const {},
  });

  /// Get the currently selected category, or null if not loaded
  BundleCategory? get selectedCategory {
    if (categories.isEmpty || selectedCategoryIndex >= categories.length) {
      return null;
    }
    return categories[selectedCategoryIndex];
  }

  /// Check if there are more subcategories to show
  bool get hasMoreToShow {
    final category = selectedCategory;
    if (category == null) return false;
    
    final allSubCats = subCategoriesCache[category.id] ?? [];
    final displayCount = displayCountCache[category.id] ?? 5;
    return allSubCats.length > displayCount;
  }

  BundlesRevisedState copyWith({
    bool? isLoading,
    String? error,
    List<BundleCategory>? categories,
    int? selectedCategoryIndex,
    Map<int, List<BundleSubCategory>>? subCategoriesCache,
    List<BundleSubCategory>? subCategories,
    Map<int, int>? displayCountCache,
  }) {
    return BundlesRevisedState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      categories: categories ?? this.categories,
      selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,
      subCategoriesCache: subCategoriesCache ?? this.subCategoriesCache,
      subCategories: subCategories ?? this.subCategories,
      displayCountCache: displayCountCache ?? this.displayCountCache,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        error,
        categories,
        selectedCategoryIndex,
        subCategoriesCache,
        subCategories,
        displayCountCache,
      ];
}
