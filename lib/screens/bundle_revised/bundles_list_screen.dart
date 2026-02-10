// lib/screens/bundle_revised/bundles_list_screen.dart
//
// Displays bundles for a specific subcategory (country/region)
// Navigates to bundle detail screen when a bundle is selected

import 'package:flutter/material.dart';
import 'package:tellgo_app/screens/bundle_revised/data/bundles_revised_repository.dart';
import 'package:tellgo_app/screens/bundle_revised/data/models.dart';
import 'package:tellgo_app/screens/bundles_details/bundle_detail.dart';

class BundlesListScreen extends StatefulWidget {
  final int subCategoryId;
  final String subCategoryName;
  final String subCategoryLogo;

  const BundlesListScreen({
    super.key,
    required this.subCategoryId,
    required this.subCategoryName,
    required this.subCategoryLogo,
  });

  @override
  State<BundlesListScreen> createState() => _BundlesListScreenState();
}

class _BundlesListScreenState extends State<BundlesListScreen> {
  final _repo = BundlesRevisedRepository();
  
  bool _isLoading = true;
  String? _error;
  List<BundleRevisedItem> _bundles = [];
  int _currentPage = 1;
  bool _hasMore = true;
  
  @override
  void initState() {
    super.initState();
    _loadBundles();
  }
  
  Future<void> _loadBundles({bool loadMore = false}) async {
    if (loadMore && !_hasMore) return;
    
    setState(() {
      if (!loadMore) _isLoading = true;
      _error = null;
    });
    
    try {
      final page = await _repo.getBundlesBySubCategoryId(
        subCategoryId: widget.subCategoryId,
        page: loadMore ? _currentPage + 1 : 1,
        pageSize: 10,
      );
      
      setState(() {
        if (loadMore) {
          _bundles.addAll(page.bundles);
        } else {
          _bundles = page.bundles;
        }
        _currentPage = page.page;
        _hasMore = page.hasNextPage;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load bundles. Please try again.';
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F3FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2C2440)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            // Country/Region flag
            if (widget.subCategoryLogo.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  widget.subCategoryLogo,
                  width: 28,
                  height: 20,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Text('🏳️'),
                ),
              ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                widget.subCategoryName,
                style: const TextStyle(
                  color: Color(0xFF2C2440),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: _buildBody(),
    );
  }
  
  Widget _buildBody() {
    if (_isLoading && _bundles.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_error != null && _bundles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadBundles,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    
    if (_bundles.isEmpty) {
      return const Center(
        child: Text(
          'No bundles available for this region',
          style: TextStyle(color: Color(0xFF2C2440), fontSize: 16),
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadBundles,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _bundles.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _bundles.length) {
            // Load more indicator
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: ElevatedButton(
                  onPressed: () => _loadBundles(loadMore: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B3FA6),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Load More'),
                ),
              ),
            );
          }
          
          final bundle = _bundles[index];
          return _BundleCard(
            bundle: bundle,
            onTap: () => _navigateToBundleDetail(bundle),
          );
        },
      ),
    );
  }
  
  void _navigateToBundleDetail(BundleRevisedItem bundle) {
    // Note: This screen is now bypassed - navigation goes directly from homepage to BundleDetailScreen
    // Keeping this for backward compatibility, navigating to the same subcategory detail screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BundleDetailScreen(
          subCategoryId: widget.subCategoryId,
          subCategoryName: widget.subCategoryName,
          subCategoryLogo: widget.subCategoryLogo,
        ),
      ),
    );
  }
}

/// Bundle Card Widget
class _BundleCard extends StatelessWidget {
  final BundleRevisedItem bundle;
  final VoidCallback onTap;

  const _BundleCard({
    required this.bundle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFB59AE6), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bundle name
              Text(
                bundle.subCategoryName.isNotEmpty 
                    ? bundle.subCategoryName 
                    : bundle.name,
                style: const TextStyle(
                  color: Color(0xFF2C2440),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              
              // Data, Validity, Speed row
              Row(
                children: [
                  _InfoChip(
                    icon: Icons.data_usage,
                    label: bundle.data.isNotEmpty ? bundle.data : 'N/A',
                  ),
                  const SizedBox(width: 12),
                  _InfoChip(
                    icon: Icons.schedule,
                    label: '${bundle.validity} Days',
                  ),
                  const SizedBox(width: 12),
                  if (bundle.speed != null && bundle.speed!.isNotEmpty)
                    _InfoChip(
                      icon: Icons.speed,
                      label: bundle.speed!,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Price row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Bundle type
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3EEFF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      bundle.bundleType,
                      style: const TextStyle(
                        color: Color(0xFF6B3FA6),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  // Price
                  Text(
                    bundle.displayPrice,
                    style: const TextStyle(
                      color: Color(0xFF6B3FA6),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF6B6B6B)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF6B6B6B),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}


