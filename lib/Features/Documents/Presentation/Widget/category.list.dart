import 'package:flutter/material.dart';
import 'package:online_reservation/Features/Documents/Data/Model/category.model.dart';

class CategoryListWidget extends StatelessWidget {
  final List<Category> categories;

  const CategoryListWidget({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Text("No categories yet.");
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return ListTile(
          leading: const Icon(Icons.category),
          title: Text(
            category.name ?? "Category Name",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }
}
