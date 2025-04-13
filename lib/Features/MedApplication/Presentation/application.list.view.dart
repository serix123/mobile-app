import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Domain/user.info.repository.dart';
import 'package:online_reservation/Core/Presentation/Components/adminWrapper.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/adminWrapper.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Features/Authentication/Domain/auth.repository.dart';
import 'package:provider/provider.dart';

class ApplicationList extends StatelessWidget {
  static const String screenId = "/applications";
  static const String title = "Applications";
  const ApplicationList({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(mobileBody: _mobileBody(), desktopBody: _desktopBody(), title: _appBar());
  }

  Widget _appBar() {
    return AppBar(
      title: Text(title),
      actions: [],
    );
  }

  Widget _mobileBody() {
    return AdminWrapper(
      (context, provider) {
        return Placeholder();
      },
    );
  }

  Widget _desktopBody() {
    return AdminWrapper(
      (context, provider) {
        return Placeholder();
      },
    );
  }


}
