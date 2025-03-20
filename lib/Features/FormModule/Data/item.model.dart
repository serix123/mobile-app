// Enum to represent form mode
enum FormMode { create, edit }

// Generic data model (replace with your actual model)
class ItemModel {
  final String id;
  final String title;
  final String description;
  final String email;
  final DateTime date;

  ItemModel({
    this.id = '',
    required this.title,
    required this.description,
    required this.email,
    required this.date,
  });
}

class ScreenConfig{
  FormMode mode;
  ItemModel? initialData;
  Function(ItemModel) onSubmit;
  Function()? onDelete;

  ScreenConfig({required this.mode,this.initialData,required this.onSubmit,this.onDelete });
}