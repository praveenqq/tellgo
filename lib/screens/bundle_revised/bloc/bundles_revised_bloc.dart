// lib/screens/bundle_revised/bloc/bundles_revised_bloc.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../data/bundles_revised_repository.dart';
import '../data/models.dart';
import 'bundles_revised_event.dart';
import 'bundles_revised_state.dart';

class BundlesRevisedBloc
    extends Bloc<BundlesRevisedEvent, BundlesRevisedState> {
  final BundlesRevisedRepository repo;

  static const int _initialDisplayCount = 5;
  static const int _loadMoreCount = 5;

  BundlesRevisedBloc(this.repo) : super(const BundlesRevisedState()) {
    on<BundlesRevisedInit>(_onInit);
    on<BundlesRevisedSelectCategory>(_onSelectCategory);
    on<BundlesRevisedLoadMore>(_onLoadMore);
    on<BundlesRevisedShowAll>(_onShowAll);
  }

  Future<void> _onInit(
    BundlesRevisedInit e,
    Emitter<BundlesRevisedState> emit,
  ) async {
    debugPrint('🚀 BundlesRevisedInit - categoryIndex: ${e.categoryIndex}');
    
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // Step 1: Fetch all categories
      final categories = await repo.getAllCategories();
      debugPrint('✅ Loaded ${categories.length} categories');

      if (categories.isEmpty) {
        emit(state.copyWith(
          isLoading: false,
          categories: categories,
          error: 'No categories available',
        ));
        return;
      }

      // Step 2: Select the initial category
      final categoryIndex = e.categoryIndex.clamp(0, categories.length - 1);
      final selectedCategory = categories[categoryIndex];
      debugPrint('📌 Selected category: ${selectedCategory.name} (id: ${selectedCategory.id})');

      // Step 3: Fetch subcategories for the selected category
      final subCategories = await repo.getSubCategoriesByCategoryId(selectedCategory.id);
      debugPrint('✅ Loaded ${subCategories.length} subcategories for ${selectedCategory.name}');

      // Cache subcategories
      final updatedCache = Map<int, List<BundleSubCategory>>.from(state.subCategoriesCache);
      updatedCache[selectedCategory.id] = subCategories;

      // Set initial display count
      final updatedDisplayCount = Map<int, int>.from(state.displayCountCache);
      updatedDisplayCount[selectedCategory.id] = _initialDisplayCount;

      // Show first 5 subcategories
      final visibleSubCategories = subCategories.take(_initialDisplayCount).toList();

      emit(state.copyWith(
        isLoading: false,
        categories: categories,
        selectedCategoryIndex: categoryIndex,
        subCategoriesCache: updatedCache,
        subCategories: visibleSubCategories,
        displayCountCache: updatedDisplayCount,
      ));
    } catch (err) {
      debugPrint('❌ BundlesRevisedInit Error: $err');
      _handleError(err, emit);
    }
  }

  Future<void> _onSelectCategory(
    BundlesRevisedSelectCategory e,
    Emitter<BundlesRevisedState> emit,
  ) async {
    debugPrint('🔄 BundlesRevisedSelectCategory - categoryIndex: ${e.categoryIndex}');
    
    if (state.selectedCategoryIndex == e.categoryIndex) {
      debugPrint('   Already selected, skipping');
      return;
    }

    if (e.categoryIndex < 0 || e.categoryIndex >= state.categories.length) {
      debugPrint('   Invalid category index');
      return;
    }

    final selectedCategory = state.categories[e.categoryIndex];
    debugPrint('📌 Switching to category: ${selectedCategory.name} (id: ${selectedCategory.id})');

    // Check if we have cached subcategories for this category
    final cached = state.subCategoriesCache[selectedCategory.id];
    if (cached != null && cached.isNotEmpty) {
      debugPrint('   Using cached data: ${cached.length} subcategories');
      
      // Reset display count to initial
      final updatedDisplayCount = Map<int, int>.from(state.displayCountCache);
      updatedDisplayCount[selectedCategory.id] = _initialDisplayCount;
      
      final visibleSubCategories = cached.take(_initialDisplayCount).toList();
      
      emit(state.copyWith(
          selectedCategoryIndex: e.categoryIndex,
        subCategories: visibleSubCategories,
        displayCountCache: updatedDisplayCount,
          error: null,
      ));
      return;
    }

    debugPrint('   No cache, loading from API...');
    emit(state.copyWith(
        isLoading: true,
        error: null,
        selectedCategoryIndex: e.categoryIndex,
      subCategories: const [],
    ));

    try {
      final subCategories = await repo.getSubCategoriesByCategoryId(selectedCategory.id);
      debugPrint('✅ Loaded ${subCategories.length} subcategories');

      final updatedCache = Map<int, List<BundleSubCategory>>.from(state.subCategoriesCache);
      updatedCache[selectedCategory.id] = subCategories;

      final updatedDisplayCount = Map<int, int>.from(state.displayCountCache);
      updatedDisplayCount[selectedCategory.id] = _initialDisplayCount;

      final visibleSubCategories = subCategories.take(_initialDisplayCount).toList();

      emit(state.copyWith(
          isLoading: false,
        subCategoriesCache: updatedCache,
        subCategories: visibleSubCategories,
        displayCountCache: updatedDisplayCount,
      ));
    } catch (err) {
      debugPrint('❌ BundlesRevisedSelectCategory Error: $err');
      _handleError(err, emit);
    }
  }

  Future<void> _onLoadMore(
    BundlesRevisedLoadMore e,
    Emitter<BundlesRevisedState> emit,
  ) async {
    final category = state.selectedCategory;
    if (category == null) {
      debugPrint('📜 LoadMore skipped - no category selected');
      return;
    }

    final cached = state.subCategoriesCache[category.id] ?? [];
    final currentDisplayCount = state.displayCountCache[category.id] ?? _initialDisplayCount;

    debugPrint('📜 LoadMore - category: ${category.name}, cached: ${cached.length}, displayCount: $currentDisplayCount');

    if (cached.length <= currentDisplayCount) {
      debugPrint('   No more subcategories to show');
      return;
    }

    // Show 5 more from cache
    final newDisplayCount = currentDisplayCount + _loadMoreCount;
    final visibleSubCategories = cached.take(newDisplayCount).toList();

    final updatedDisplayCount = Map<int, int>.from(state.displayCountCache);
    updatedDisplayCount[category.id] = newDisplayCount;

    debugPrint('   Showing ${visibleSubCategories.length} subcategories (displayCount: $newDisplayCount)');

    emit(state.copyWith(
      subCategories: visibleSubCategories,
      displayCountCache: updatedDisplayCount,
    ));
    }

  Future<void> _onShowAll(
    BundlesRevisedShowAll e,
    Emitter<BundlesRevisedState> emit,
  ) async {
    // Show ALL cached subcategories at once (no pagination)
    final category = state.selectedCategory;
    if (category == null) {
      debugPrint('📜 ShowAll skipped - no category selected');
      return;
    }

    final cached = state.subCategoriesCache[category.id] ?? [];
    debugPrint('📜 ShowAll - category: ${category.name}, total: ${cached.length}');

    // Set display count to the full list length so hasMoreToShow becomes false
    final updatedDisplayCount = Map<int, int>.from(state.displayCountCache);
    updatedDisplayCount[category.id] = cached.length;

    emit(state.copyWith(
      subCategories: List.of(cached),
      displayCountCache: updatedDisplayCount,
    ));
  }

  void _handleError(dynamic err, Emitter<BundlesRevisedState> emit) {
    String errorMessage;
    if (err is DioException) {
      debugPrint('   Status: ${err.response?.statusCode}');
      debugPrint('   Message: ${err.message}');
      
      if (err.type == DioExceptionType.connectionTimeout ||
          err.type == DioExceptionType.receiveTimeout ||
          err.type == DioExceptionType.sendTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (err.response?.statusCode == 401) {
        errorMessage = 'Authentication failed. Please login again.';
      } else if (err.response?.statusCode != null && err.response!.statusCode! >= 500) {
        errorMessage = 'Server error. Please try again later.';
      } else {
        final responseData = err.response?.data;
        String? message;
        if (responseData is Map) {
          message = responseData['message'] as String?;
        }
        errorMessage = message ?? err.message ?? 'Failed to load data. Please try again.';
      }
    } else {
      errorMessage = 'Failed to load data. Please try again.';
    }
    
    emit(state.copyWith(
      isLoading: false,
      error: errorMessage,
    ));
  }
}
