import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Features/MedicalInventory/Data/Model/category.model.dart';
import 'package:online_reservation/Features/MedicalInventory/Data/Model/inventory.model.dart';
import 'package:online_reservation/Features/MedicalInventory/Data/Model/supplier.model.dart';
import 'package:online_reservation/Features/MedicalInventory/Domain/category.repository.dart';
import 'package:online_reservation/Features/MedicalInventory/Domain/inventory.repository.dart';
import 'package:online_reservation/Features/MedicalInventory/Domain/supplier.repository.dart';
import 'package:online_reservation/Utils/utils.dart';
import 'package:provider/provider.dart';

class InventoryItemScreen extends StatefulWidget {
  static const String screenId = "/inventory";
  static const String title = "Inventory Item";
  final Medicine? medicine;

  const InventoryItemScreen({super.key, this.medicine});

  @override
  _InventoryItemScreenState createState() => _InventoryItemScreenState();
}

class _InventoryItemScreenState extends State<InventoryItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _quantityController;
  MedicineUnit? _selectedUnit;
  Category? _selectedCategory;
  Supplier? _selectedSupplier;
  int? _selectedCategoryId;
  int? _selectedSupplierId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.wait([
        Provider.of<CategoryProvider>(context, listen: false).getCategories(),
        Provider.of<SupplierProvider>(context, listen: false).getSuppliers()
      ]);
    });
    final medicine = widget.medicine;
    _nameController = TextEditingController(text: medicine?.name ?? '');
    _descriptionController =
        TextEditingController(text: medicine?.description ?? '');
    _quantityController =
        TextEditingController(text: medicine?.quantity.toString() ?? '0');
    _selectedUnit = medicine?.quantityUnit;
    _selectedCategory = medicine?.category;
    _selectedSupplier = medicine?.supplier;
    _selectedCategoryId = medicine?.category.id;
    _selectedSupplierId = medicine?.supplier.id;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _saveMedicine() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<InventoryProvider>(context, listen: false);
    final medicine = Medicine(
      id: widget.medicine?.id ?? 0,
      name: _nameController.text,
      description: _descriptionController.text,
      quantity: int.parse(_quantityController.text),
      quantityUnit: _selectedUnit!,
      category: _selectedCategory!,
      supplier: _selectedSupplier!,
      lastRestockDate: widget.medicine?.lastRestockDate,
    );

    try {
      if (widget.medicine == null) {
        await provider.createMedicine(medicine);
      } else {
        await provider.updateMedicine(medicine);
      }
      await provider.getMedicines();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
    Navigator.pop(context);
  }

  Future<void> _deleteMedicine() async {
    if (widget.medicine == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this medicine?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await Provider.of<InventoryProvider>(context, listen: false)
            .deleteMedicine(widget.medicine!.id);
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<InventoryProvider>(context);
    final isEditing = widget.medicine != null;

    return ResponsiveLayout(
      mobileBody: body(isEditing),
      desktopBody: body(isEditing),
      title: const Text(InventoryItemScreen.title),
      currentRoute: InventoryItemScreen.screenId,
      actions: [
        if (isEditing)
          IconButton(
            icon: const Icon(Icons.delete),
            color: Colors.red,
            onPressed: _deleteMedicine,
            tooltip: "Delete Item",
          ),
      ],
    );
  }

  Widget body(bool isEditing) {
    return Consumer3<InventoryProvider, CategoryProvider, SupplierProvider>(
      builder: (context, inventoryProvider, categoryProvider, supplierProvider,
          child) {
        if (categoryProvider.isLoading || supplierProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name*'),
                  validator: (value) =>
                      value?.isEmpty ?? true ? 'Required field' : null,
                ),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 3,
                ),
                TextFormField(
                  controller: _quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity*'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value?.isEmpty ?? true) return 'Required field';
                    if (int.tryParse(value!) == null) return 'Invalid number';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<MedicineUnit>(
                  value: _selectedUnit,
                  items: MedicineUnit.values.map((unit) {
                    return DropdownMenuItem(
                      value: unit,
                      child: Text(unit.displayName),
                    );
                  }).toList(),
                  decoration: const InputDecoration(labelText: 'Unit*'),
                  validator: (value) => value == null ? 'Required field' : null,
                  onChanged: (value) => setState(() => _selectedUnit = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _selectedCategoryId,
                  items: categoryProvider.categories
                      .map<DropdownMenuItem<int>>((Category category) {
                    return DropdownMenuItem<int>(
                      value: category.id,
                      child: Text(category.name),
                    );
                  }).toList(),
                  decoration: const InputDecoration(labelText: 'Category*'),
                  validator: (value) => value == null ? 'Required field' : null,
                  onChanged: (value) => setState(() {
                    _selectedCategoryId = value;
                    _selectedCategory = categoryProvider.categories
                        .firstWhere((cat) => cat.id == value);
                  }),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  value: _selectedSupplierId,
                  items: supplierProvider.suppliers
                      .map<DropdownMenuItem<int>>((Supplier supplier) {
                    return DropdownMenuItem<int>(
                      value: supplier.id,
                      child: Text(supplier.name),
                    );
                  }).toList(),
                  decoration: const InputDecoration(labelText: 'Supplier*'),
                  validator: (value) => value == null ? 'Required field' : null,
                  onChanged: (value) => setState(() {
                    _selectedSupplierId = value;
                    _selectedSupplier = supplierProvider.suppliers
                        .firstWhere((sup) => sup.id == value);
                  }),
                ),
                if (isEditing && widget.medicine?.lastRestockDate != null) ...[
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Last Restock Date'),
                    subtitle: Text(
                        Utils.formatDateISO(widget.medicine!.lastRestockDate!)),
                  ),
                ],
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _saveMedicine,
                  child: Text(isEditing ? 'Update Medicine' : 'Add Medicine'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
