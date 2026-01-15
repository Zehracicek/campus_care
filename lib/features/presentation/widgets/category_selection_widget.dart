import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:campus_care/core/theme/app_theme.dart';
import 'package:campus_care/features/domain/entities/maintenance_category_entity.dart';
import 'package:flutter/material.dart';

class CategorySelectionWidget extends StatelessWidget {
  final List<MaintenanceCategoryEntity> categories;
  final String? selectedCategoryId;
  final Function(MaintenanceCategoryEntity) onCategorySelected;
  final bool isLoading;

  const CategorySelectionWidget({
    super.key,
    required this.categories,
    this.selectedCategoryId,
    required this.onCategorySelected,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.category, color: AppTheme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  'Kategori Seçin',
                  style: context.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Loading or Categories List
          if (isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (categories.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.category_outlined,
                      size: 64,
                      color: Colors.grey[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Kategori bulunamadı',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
            )
          else
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: categories.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final isSelected = category.id == selectedCategoryId;

                  return _CategoryCard(
                    category: category,
                    isSelected: isSelected,
                    onTap: () {
                      onCategorySelected(category);
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final MaintenanceCategoryEntity category;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: AppTheme.primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryColor.withValues(alpha: 0.1)
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconData(category.icon),
                  color: isSelected ? AppTheme.primaryColor : Colors.grey[700],
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: context.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppTheme.primaryColor : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.description,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tahmini ${category.estimatedHours} saat',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Selected indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: AppTheme.primaryColor,
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    final iconMap = {
      'electrical': Icons.electrical_services,
      'plumbing': Icons.plumbing,
      'hvac': Icons.ac_unit,
      'carpentry': Icons.carpenter,
      'painting': Icons.format_paint,
      'cleaning': Icons.cleaning_services,
      'it': Icons.computer,
      'security': Icons.security,
      'other': Icons.build,
    };

    return iconMap[iconName.toLowerCase()] ?? Icons.category;
  }
}
