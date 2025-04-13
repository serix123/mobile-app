import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Domain/user.info.repository.dart';
import 'package:provider/provider.dart';

Widget AdminWrapper(Widget Function(BuildContext context, UserInfoProvider provider) child) {
  return Consumer<UserInfoProvider>(
    builder: (context, provider, _) {
      return child(context, provider);
    },
  );
}