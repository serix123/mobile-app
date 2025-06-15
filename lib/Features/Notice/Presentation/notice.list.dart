import 'package:flutter/material.dart';
import 'package:online_reservation/Core/Presentation/route/route.generator.dart';
import 'package:online_reservation/Features/Notice/Data/Model/notice.model.dart';
import 'package:provider/provider.dart';
import 'package:online_reservation/Core/Presentation/Components/buildState.view.dart';
import 'package:online_reservation/Core/Presentation/Components/paginationControls.widget.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Features/Notice/Domain/notice.repository.dart';
import 'package:online_reservation/Features/Notice/Presentation/Widget/list.item.dart';
import 'package:online_reservation/Features/Notice/Presentation/Widget/search.widget.dart';
import 'package:online_reservation/Features/Profile/Domain/profile.repository.dart';

class NoticeListScreen extends StatefulWidget {
  static const String screenId = "/notices";
  static const String title = "Notices";
  const NoticeListScreen({super.key});

  @override
  State<NoticeListScreen> createState() => _NoticeListScreenState();
}

class _NoticeListScreenState extends State<NoticeListScreen> {
  void _initData() async {
    final task = [
      context.read<ProfileProvider>().getProfile(),
      context.read<NoticeProvider>().getNotices(),
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

  Future<void> _handleDelete(int noticeId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this issue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        if (mounted) {
          await context.read<NoticeProvider>().deleteNotice(noticeId);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Notice deleted successfully')),
          );
        }
        if (mounted) {
          await context.read<NoticeProvider>().getNotices();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Delete failed: $e')),
          );
        }
      }
    }
  }

  Future<void> _handleCreateEdit({Notice? notice}) async {
    final result = await Navigator.pushNamed(
        context, RouteGenerator.noticeEditScreen,
        arguments: notice);

    if (result != null) {
      if(mounted){
        final provider = context.read<NoticeProvider>();
        await provider.getNotices();
      }
    }
  }

  Future<void> _handleRead({required Notice notice}) async {
    final result = await Navigator.pushNamed(
        context, RouteGenerator.noticeViewScreen,
        arguments: notice);

    if (result != null) {
      if(mounted){
        final provider = context.read<NoticeProvider>();
        await provider.getNotices();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOfficer = context.read<ProfileProvider>().user?.isOfficer ?? false;
    return ResponsiveLayout(
      currentRoute: NoticeListScreen.screenId,
      title: const Text(NoticeListScreen.title),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _initData(),
        ),
        if(isOfficer)
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _handleCreateEdit(),
        )
      ],
      desktopBody: body(),
      mobileBody: body(),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Consumer<NoticeProvider>(
        builder: (context, provider, child) {
          return SearchFields(
            onSearch: (text) => provider.getNotices(query: text),
          );
        },
      ),
    );
  }

  Widget body() {
    return Column(
      children: [
        _searchBar(),
        _paginationControls(),
        Expanded(
          child: Consumer2<ProfileProvider, NoticeProvider>(
            builder: (context, profileProvider, provider, _) {
              if (profileProvider.isLoading || provider.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (provider.error != null) return _buildErrorState(provider);
              if (provider.notices.isEmpty) return _buildEmptyState(provider);

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: provider.notices.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final notice = provider.notices[index];
                  final isOfficer = profileProvider.user!.isOfficer;
                  if (isOfficer) {
                    return NoticeListItem(
                      notice: notice,
                      onTap: () => _handleRead(notice:notice),
                      onDelete: () => _handleDelete(notice.id!),
                      onEdit: () => _handleCreateEdit(notice:notice ),
                    );
                  } else {
                    return NoticeListItem(
                      notice: notice,
                      onTap: () => _handleRead(notice:notice),
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _paginationControls() {
    return Consumer<NoticeProvider>(
      builder: (context, provider, _) {
        return PaginationControls(
            hasNext: provider.hasNext,
            hasPrevious: provider.hasPrevious,
            onNext: provider.loadNextPage,
            onPrevious: provider.loadPreviousPage);
      },
    );
  }

  Widget _buildErrorState(NoticeProvider provider) {
    return GenericErrorState(
        errorMessage: provider.error ?? "Cannot retrieve medical notices",
        onRetry: () async => await provider.getNotices());
  }

  Widget _buildEmptyState(NoticeProvider provider) {
    return GenericEmptyState(
      title: 'No Records Found.',
      description: 'When new notices are created, they will appear here',
      icon: Icons.assignment_outlined,
      actionButton: ElevatedButton(
        onPressed: () async => await provider.getNotices(),
        child: const Text('Reload'),
      ),
    );
  }
}
