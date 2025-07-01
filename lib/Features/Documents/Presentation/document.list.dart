import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Presentation/Components/buildState.view.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Core/Presentation/route/route.generator.dart';
import 'package:online_reservation/Features/Documents/Data/Model/category.model.dart';
import 'package:online_reservation/Features/Documents/Data/Model/document.model.dart';
import 'package:online_reservation/Features/Documents/Domain/category.repository.dart';
import 'package:online_reservation/Features/Documents/Domain/document.repository.dart';
import 'package:online_reservation/Features/Documents/Presentation/document.form.dart';
import 'package:online_reservation/Features/Profile/Domain/profile.repository.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentListScreen extends StatefulWidget {
  static const String screenId = "/documents";
  static const String title = "Community Documents";
  const DocumentListScreen({super.key});

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> {
  void _initData() async {
    final task = [
      context.read<ProfileProvider>().getProfile(),
      context.read<DocumentProvider>().getDocuments(),
      context.read<CategoryProvider>().getCategories(),
    ];
    await Future.wait(task);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Future<void> _openDocument(String documentUrl) async {
    // final documentUrl = widget.profile.idDocument;
    final uri = Uri.parse(documentUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri,
          mode: LaunchMode.platformDefault); // Opens browser or app
    } else {
      throw 'Could not launch $documentUrl';
    }
  }

  Future<void> _handleCreateEdit(
      {Document? document, Category? category}) async {
    final result = await Navigator.pushNamed(
        context, RouteGenerator.documentEditScreen,
        arguments:
            DocumentEditScreenConfig(category: category, document: document));

    if (result != null) {
      if (mounted) {
        final provider = context.read<DocumentProvider>();
        await provider.getDocuments();
      }
    }
  }

  Map<String, List<Document>> groupDocumentsByCategory(List<Document> docs) {
    final Map<String, List<Document>> grouped = {};

    for (var doc in docs) {
      final categoryName = doc.category.parent == null
          ? doc.category.name
          : doc.category.parent
              .toString(); // Use parent ID as key for subcategories

      if (!grouped.containsKey(categoryName)) {
        grouped[categoryName] = [];
      }

      grouped[categoryName]!.add(doc);
    }
    print(grouped);
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      currentRoute: DocumentListScreen.screenId,
      title: const Text(DocumentListScreen.title),
      desktopBody: body(),
      mobileBody: body(),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _initData(),
        ),
      ],
    );
  }

  Widget body() {
    return Consumer2<DocumentProvider, CategoryProvider>(
      builder: (context, documentProvider, categoryProvider, child) {
        final grouped = groupDocumentsByCategory(documentProvider.documents);
        if (documentProvider.isLoading || categoryProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (documentProvider.error != null) return _buildErrorState();
        if (documentProvider.documents.isEmpty) return _buildEmptyState();
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Expanded(
            child: buildCategoryWithDocuments(
                categoryProvider.categories, documentProvider.documents),
          ),
        );
      },
    );
  }

  Widget listView(Map<String, List<Document>> grouped) {
    final isOfficer = context.read<ProfileProvider>().user?.isOfficer ?? false;
    return ListView(
      children: grouped.entries.map((entry) {
        final categoryName = entry.key;
        final docs = entry.value;

        return ExpansionTile(
          title: Text(categoryName),
          children: docs
              .map(
                (doc) => ListTile(
                  title: Text(doc.title),
                  subtitle:
                      Text(doc.documentUrl?.split('/').last ?? "Empty File"),
                  onTap: doc.documentUrl != null && !isOfficer
                      ? () => _openDocument(doc.documentUrl!)
                      : () => _handleCreateEdit(
                          category: doc.category, document: doc),
                ),
              )
              .toList(),
        );
      }).toList(),
    );
  }

  Widget buildCategoryList(List<Category> categories) {
    // Only top-level categories (parent == null)
    final topLevelCategories =
        categories.where((c) => c.parent == null).toList();

    return ListView(
      children: topLevelCategories.map((cat) {
        if (cat.subcategories.isEmpty) {
          return ListTile(
            title: Text(cat.name),
            onTap: () {
              // Handle category tap
            },
          );
        }

        return ExpansionTile(
          title: Text(cat.name),
          children: cat.subcategories.map((sub) {
            return ListTile(
              title: Text(sub.name),
              onTap: () {
                // Handle subcategory tap
              },
            );
          }).toList(),
        );
      }).toList(),
    );
  }

  Widget buildCategoryWithDocuments(
    List<Category> categories,
    List<Document> documents,
  ) {
    final topLevelCategories =
        categories.where((c) => c.parent == null).toList();

    return ListView(
      children: topLevelCategories.map((category) {
        return buildCategoryTile(category, documents);
      }).toList(),
    );
  }

  Widget buildCategoryTile(Category category, List<Document> allDocuments) {
    final docsForCategory =
        allDocuments.where((doc) => doc.category.id == category.id).toList();
    final isOfficer = context.read<ProfileProvider>().user?.isOfficer ?? false;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Theme(
          data: ThemeData().copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16.0),
            childrenPadding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            leading: const Icon(Icons.folder_open, color: Colors.green),
            title: Text(category.name),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Documents directly under this category
              ...docsForCategory.map((doc) => ListTile(
                    title: Text(doc.title),
                    leading: const Icon(Icons.picture_as_pdf),
                    onTap: doc.documentUrl != null && !isOfficer
                        ? () => _openDocument(doc.documentUrl!)
                        : () => _handleCreateEdit(
                            category: doc.category, document: doc),
                  )),
              if(isOfficer)
              addFileButton(category),
              // Subcategories
              ...category.subcategories
                  .map((sub) => buildCategoryTile(sub, allDocuments)),
            ],
          ),
        ),
      ),
    );
  }

  Padding addFileButton(Category category) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton.icon(
        onPressed: () {
          _handleCreateEdit(category: category);
        },
        icon: const Icon(Icons.upload_file),
        label: const Text("Add File"),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return GenericEmptyState(
      title: 'No Documents Found',
      description:
          'When new document requests are created, they will appear here',
      icon: Icons.assignment_outlined,
      actionButton: ElevatedButton(
        onPressed: () {},
        // () =>
        // Navigator.of(context).pushNamed(RouteGenerator.documentFormScreen),
        child: const Text('Create New Issue'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return GenericEmptyState(
      title: 'No Documents Available',
      description:
          'When new document requests are created, they will appear here',
      icon: Icons.assignment_outlined,
      actionButton: ElevatedButton(
        onPressed: () {},
        // () =>
        // Navigator.of(context).pushNamed(RouteGenerator.documentFormScreen),
        child: const Text('Create New Issue'),
      ),
    );
  }
}
