// visits_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Core/Presentation/route/route.generator.dart';
import 'package:online_reservation/Features/FormModule/Data/item.model.dart';
import 'package:online_reservation/Features/Visitor/Presentation/visitor.view.dart';
import 'package:online_reservation/Features/Visitor/list.view.dart';
import 'package:online_reservation/Features/Visitor/Domain/visitor.repository.dart';

class VisitsListScreen extends StatefulWidget {
  static const String screenId = "/visitors";
  static const String title = "visit requests";
  const VisitsListScreen({super.key});

  @override
  State<VisitsListScreen> createState() => _VisitsListScreenState();
}

class _VisitsListScreenState extends State<VisitsListScreen> {
  @override
  void initState() {
    super.initState();
    // Load data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<VisitProvider>().loadVisitors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      currentRoute: VisitsListScreen.screenId,
      title: VisitsListScreen.title,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => context.read<VisitProvider>().loadVisitors(),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => Navigator.of(context).pushNamed(RouteGenerator.visitorFormScreen,
              arguments: VisitorScreenConfig(mode: FormMode.create, onSubmit: (visitor) => context.read<VisitProvider>().createVisitor(visitor))),
        )
      ],
      desktopBody: buildConsumer(),
      mobileBody: buildConsumer(),
    );
  }

  Consumer<VisitProvider> buildConsumer() {
    return Consumer<VisitProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${provider.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.loadVisitors(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (provider.visits.isEmpty) {
          return const Center(child: Text('No visit requests found'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: provider.visits.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final visit = provider.visits[index];
            return VisitorListItem(
              visitor: visit,
              onStatusChanged: (newStatus) async {
                try {
                  await provider.updateVisitStatus(visit.id, newStatus);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Status updated successfully'),
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating status: $e'),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}
