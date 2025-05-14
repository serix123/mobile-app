import 'dart:async';

import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Presentation/Components/buildState.view.dart';
import 'package:online_reservation/Features/MedicalInventory/Data/Model/inventory.model.dart';
import 'package:online_reservation/Features/MedicalInventory/Domain/inventory.repository.dart';
import 'package:provider/provider.dart';

Future<List<Medicine>> showMedicineSelectionModal({
  required BuildContext context,
}) async {
  final selectedMedicines = await showModalBottomSheet<List<Medicine>>(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      List<int> selectedIds = [];
      Timer? _searchDebounce;
      return StatefulBuilder(
        builder: (context, setState) {

          return Consumer<InventoryProvider>(
            builder: (context, provider, child) {
              final medicines = provider.medicines;
              if (provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.error != null) {
                return GenericErrorState(
                  errorMessage: provider.error ?? "Cannot retrieve medicines",
                  onRetry: () async => await provider.getMedicines());
              }
              if (provider.medicines.isEmpty) {
                return GenericEmptyState(
                  title: 'No Medicines Found.',
                  description: 'When new medicines are available, they will appear here',
                  icon: Icons.assignment_outlined,
                  actionButton: ElevatedButton(
                    onPressed: () => provider.getMedicines(),
                    child: const Text('Reload'),
                  ),
                );
              }

              return Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Select Medicines',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),

                    // Search bar
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search medicines...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (query) {
                          _searchDebounce?.cancel();
                          _searchDebounce = Timer(const Duration(milliseconds: 500), () {
                            provider.getMedicines(query: query);
                          });
                        },
                      ),
                    ),

                    // Medicine list
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: medicines.length,
                        itemBuilder: (context, index) {
                          final medicine = medicines[index];
                          final isSelected = selectedIds.contains(medicine.id);

                          return CheckboxListTile(
                            value: isSelected,
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedIds.add(medicine.id);
                                } else {
                                  selectedIds.remove(medicine.id);
                                }
                              });
                            },
                            title: Text(medicine.name),
                            subtitle: Text(
                                'Stock: ${medicine.quantity} ${medicine.quantityUnit}'),
                            secondary: const Icon(Icons.medication),
                          );
                        },
                      ),
                    ),

                    // Done button
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton(
                        onPressed: () {
                          final selected = medicines
                              .where((m) => selectedIds.contains(m.id))
                              .toList();
                          Navigator.pop(context, selected);
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );

  return selectedMedicines ?? [];
}
