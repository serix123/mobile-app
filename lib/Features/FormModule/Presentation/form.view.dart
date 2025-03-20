// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/intl.dart';
// import 'package:online_reservation/Core/Presentation/Components/formContainer.widget.dart';
// import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
// import 'package:online_reservation/Features/FormModule/Data/item.model.dart';
//
// class ScreenConfig{
//   FormMode mode;
//   ItemModel? initialData;
//   Function(ItemModel) onSubmit;
//   Function()? onDelete;
//
//   ScreenConfig({required this.mode,this.initialData,required this.onSubmit,this.onDelete });
// }
//
// class CrudFormScreen extends StatefulWidget {
//   static const String screenId = "/form";
//   final FormMode mode;
//   final ItemModel? initialData;
//   final Function(ItemModel) onSubmit;
//   final Function()? onDelete;
//
//   const CrudFormScreen({
//     super.key,
//     required this.mode,
//     this.initialData,
//     required this.onSubmit,
//     this.onDelete,
//   });
//
//   @override
//   _CrudFormScreenState createState() => _CrudFormScreenState();
// }
//
// class _CrudFormScreenState extends State<CrudFormScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late TextEditingController _nameController;
//   late TextEditingController _purposeController;
//   late TextEditingController _mobileController;
//   late DateTime _selectedDate;
//
//   @override
//   void initState() {
//     super.initState();
//     // Initialize controllers with initial data if in edit mode
//     _nameController = TextEditingController(text: widget.initialData?.title ?? '');
//     _purposeController = TextEditingController(text: widget.initialData?.description ?? '');
//     _mobileController = TextEditingController(text: widget.initialData?.email ?? '');
//     _selectedDate = widget.initialData?.date ?? DateTime.now();
//   }
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _purposeController.dispose();
//     _mobileController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }
//
//   void _submitForm() {
//     if (_formKey.currentState!.validate()) {
//       final newItem = ItemModel(
//         id: widget.initialData?.id ?? '',
//         title: _nameController.text,
//         description: _purposeController.text,
//         email: _mobileController.text,
//         date: _selectedDate,
//       );
//       widget.onSubmit(newItem);
//     }
//   }
//
//   Future<void> _confirmDelete() async {
//     return showDialog<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Confirm Delete'),
//           content: const Text('Are you sure you want to delete this item?'),
//           actions: <Widget>[
//             TextButton(
//               onPressed: () => Navigator.of(context).pop(),
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 widget.onDelete?.call();
//               },
//               child: const Text('Delete'),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ResponsiveLayout(
//       title: widget.mode == FormMode.create ? 'Create Item' : 'Edit Item',
//         desktopBody: FormContainer(
//           width: MediaQuery.of(context).size.width,
//           child: buildForm(context),
//         ),
//         mobileBody: FormContainer(
//           child: buildForm(context),
//         ), currentRoute: "",
//       );
//   }
//
//   Padding buildForm(BuildContext context) {
//     return Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: ListView(
//               children: <Widget>[
//                 TextFormField(
//                   controller: _nameController,
//                   decoration: const InputDecoration(labelText: 'Title'),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a title';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _purposeController,
//                   decoration: const InputDecoration(labelText: 'Description'),
//                   maxLines: 3,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a description';
//                     }
//                     return null;
//                   },
//                 ),
//                 TextFormField(
//                   controller: _mobileController,
//                   decoration: InputDecoration(
//                     labelText: 'Mobile Number',
//                     border: OutlineInputBorder(),
//                     prefix: Padding(
//                       padding: const EdgeInsets.only(right: 4.0),
//                       child: Text('+63'),
//                     ),
//                   ),
//                   keyboardType: TextInputType.phone,
//                   inputFormatters: [
//                     LengthLimitingTextInputFormatter(10), // Limit to 10 digits
//                     FilteringTextInputFormatter.digitsOnly,
//                   ],
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter mobile number';
//                     }
//                     if (value.length != 10) {
//                       return 'Must be 10 digits';
//                     }
//                     return null;
//                   },
//                   onSaved: (value) {
//                     // Combine prefix with entered number
//                     _mobileController.text = '+63$value';
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 Row(
//                   children: [
//                     Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
//                     TextButton(
//                       onPressed: () => _selectDate(context),
//                       child: const Text('Select Date'),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 32),
//                 if (widget.mode == FormMode.create)
//                   ElevatedButton(
//                     onPressed: _submitForm,
//                     child: const Text('Create Item'),
//                   ),
//                 if (widget.mode == FormMode.edit)
//                   Column(
//                     children: [
//                       ElevatedButton(
//                         onPressed: _submitForm,
//                         child: const Text('Update Item'),
//                       ),
//                       const SizedBox(height: 16),
//                       ElevatedButton(
//                         onPressed: _confirmDelete,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.red,
//                         ),
//                         child: const Text('Delete Item'),
//                       ),
//                     ],
//                   ),
//               ],
//             ),
//           ),
//         );
//   }
// }