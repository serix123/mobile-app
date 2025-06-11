enum FormFieldMode {
  READ,
  CREATE,
  UPDATE,
}

/// Determines the mode of a form field based on the provided entity and an optional ID.
///
/// [entity]: The object representing the data for the form field.
///           If null, it typically indicates a CREATE mode.
/// [id]: An optional identifier for the entity. If [entity] is not null and [id] is also not null,
///       it typically indicates an UPDATE mode.
///
/// Returns [FormFieldMode.CREATE] if [entity] is null.
/// Returns [FormFieldMode.UPDATE] if [entity] is not null and [id] is not null.
/// Returns [FormFieldMode.READ] if [entity] is not null but [id] is null (e.g., viewing an incomplete record).
///
/// You might adjust the logic for [READ] mode based on your specific application's needs.
FormFieldMode getFormFieldMode({
  dynamic entity, // Use 'dynamic' or a base class/interface for flexibility
  String? id, // Assuming ID is a String, adjust as needed (e.g., int?)
}) {
  if (entity == null) {
    return FormFieldMode.CREATE;
  } else {
    // If entity exists, we check for an ID to differentiate between update and read
    if (id != null && id.isNotEmpty) {
      return FormFieldMode.UPDATE;
    } else {
      // Entity exists, but no ID. This could mean we're viewing an existing but unsaved record,
      // or a record without a primary key assigned yet. You might want to consider this 'READ'
      // or adjust based on your specific data model.
      return FormFieldMode.READ;
    }
  }
}

class RouteArguments {
  final dynamic data; // Can be any type
  final FormFieldMode mode;

  const RouteArguments({
    this.data,
    required this.mode,
  });
}