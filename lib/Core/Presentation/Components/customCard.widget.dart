import 'package:flutter/material.dart';


class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    required this.child,
  });
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
        clipBehavior: Clip.antiAliasWithSaveLayer,
        color: Colors.deepPurple[100],
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
          child: SingleChildScrollView(
            child: child,
          ),
        ));
  }
}
// class CustomFormView extends StatefulWidget {
//   const CustomFormView({super.key});
//
//   @override
//   State<CustomFormView> createState() => _CustomFormViewState();
// }
//
// class _CustomFormViewState extends State<CustomFormView> {
//   TextEditingController? _textEditingController1, _textEditingController2;
//   late String _email, _password;
//   late bool _pwVisible, _isLoading;
//
//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _textEditingController1 = TextEditingController();
//     _textEditingController2 = TextEditingController();
//     _pwVisible = true;
//     _isLoading = false;
//   }
//
//   @override
//   void dispose() {
//     // TODO: implement dispose
//     _textEditingController1?.dispose();
//     _textEditingController2?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final currentWidth = MediaQuery.of(context).size.width;
//     final currentHeight = MediaQuery.of(context).size.height;
//     return Scaffold(
//       body: SafeArea(
//           child: Container(
//         width: currentWidth,
//         height: currentHeight,
//         child: Padding(
//           padding: const EdgeInsetsDirectional.fromSTEB(30, 30, 30, 30),
//           child: CustomCard(
//             child: Column(
//               mainAxisSize: MainAxisSize.max,
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const Padding(
//                   padding: EdgeInsetsDirectional.fromSTEB(0, 20, 0, 20),
//                   child: Text(
//                     "Welcome",
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         color: kPurpleDark),
//                   ),
//                 ),
//                 Form(
//                   child: Column(
//                     children: [
//                       Padding(
//                         padding: const EdgeInsetsDirectional.fromSTEB(
//                             10, 40, 10, 10),
//                         child: CustomTextFormField(
//                           textEditingController: _textEditingController1,
//                           labelText: 'Email Address',
//                           hintText: "example@southville.edu.ph",
//                           suffixIcon: _textEditingController1!.text.isNotEmpty
//                               ? InkWell(
//                                   onTap: () async {
//                                     _textEditingController1?.clear();
//                                     // setState(() {});
//                                   },
//                                   child: const Icon(
//                                     Icons.clear,
//                                     color: kPurpleLight,
//                                     size: 22,
//                                   ),
//                                 )
//                               : null,
//                           onChanged: (value) =>
//                               {setState(() => _email = value)},
//                           validator: (val) {
//                             if (val == null || val.isEmpty) {
//                               return 'Field is required';
//                             }
//                             if (!RegExp(
//                                     r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
//                                 .hasMatch(val)) {
//                               return 'Has to be a valid email address.';
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                       Padding(
//                         padding: const EdgeInsetsDirectional.fromSTEB(
//                             10, 10, 10, 10),
//                         child: CustomTextFormField(
//                           textEditingController: _textEditingController2,
//                           obscureText: _pwVisible,
//                           labelText: 'Password',
//                           hintText: "**********",
//                           suffixIcon: InkWell(
//                             onTap: () {
//                               setState(() {
//                                 _pwVisible = !_pwVisible;
//                               });
//                             },
//                             child: Icon(
//                               _pwVisible
//                                   ? Icons.visibility_off_outlined
//                                   : Icons.visibility_outlined,
//                               color: kPurpleLight,
//                               size: 22,
//                             ),
//                           ),
//                           onChanged: (value) =>
//                               setState(() => _password = value),
//                           validator: (val) {
//                             if (val == null || val.isEmpty) {
//                               return 'Field is required';
//                             }
//                             return null;
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsetsDirectional.fromSTEB(10, 40, 10, 10),
//                   child: _isLoading
//                       ? CircularProgressIndicator()
//                       : TextButton(
//                           onPressed: () {},
//                           style: TextButton.styleFrom(
//                               backgroundColor: kBackgroundGrey,
//                               padding:
//                                   const EdgeInsets.symmetric(horizontal: 16)),
//                           child: const Text(
//                             "Log In",
//                             style: TextStyle(
//                                 fontSize: 16, fontWeight: FontWeight.bold),
//                           ),
//                         ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       )),
//     );
//   }
// }
