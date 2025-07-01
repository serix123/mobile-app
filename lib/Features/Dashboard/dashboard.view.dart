import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:online_reservation/Core/Presentation/Components/FormFieldMode.dart';
import 'package:online_reservation/Core/Presentation/Components/responsiveLayout.widget.dart';
import 'package:online_reservation/Core/Presentation/route/route.generator.dart';
import 'package:online_reservation/Features/Documents/Domain/document.repository.dart';
import 'package:online_reservation/Features/Events/Domain/event.repository.dart';
import 'package:online_reservation/Features/Issue/Domain/issue.repository.dart';
import 'package:online_reservation/Features/Notice/Domain/notice.repository.dart';
import 'package:online_reservation/Features/Profile/Domain/profile.repository.dart';
import 'package:online_reservation/Features/Resident/Domain/resident.repository.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  static const String screenId = "/dashboard";
  static const String title = "Dashboard";
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  void _initData() async {
    final task = [
      context.read<ProfileProvider>().getProfile(),
      context.read<EventProvider>().getUpcomingEvents(),
      context.read<DocumentProvider>().getDocuments(),
      context.read<NoticeProvider>().getNotices(),
      context.read<ResidentProvider>().getResidentSummary(),
      context.read<IssueProvider>().getIssuesSummary()
    ];
    await Future.wait(task);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initData();
    });
  }

  void _handleEventCreate() async {
    final result =
        await Navigator.pushNamed(context, RouteGenerator.eventEditScreen);

    if (result != null) {
      if (mounted) {
        final task = [
          context.read<ProfileProvider>().getProfile(),
          context.read<EventProvider>().getUpcomingEvents(),
        ];
        await Future.wait(task);
      }
    }
  }

  void _handleIssueCreate() async {
    final result = await Navigator.of(context).pushNamed(
      RouteGenerator.issueFormScreen,
      arguments: const RouteArguments(mode: FormFieldMode.CREATE, data: null),
    );

    if (result == true) {
      if (mounted) {
        final task = [
          context.read<ProfileProvider>().getProfile(),
          context.read<IssueProvider>().getIssues(),
        ];
        await Future.wait(task);
      }
    }
  }

  void _handleNoticeCreate() async {
    final result = await Navigator.pushNamed(
        context, RouteGenerator.noticeEditScreen,
        arguments: null);

    if (result != null) {
      if (mounted) {
        final task = [
          context.read<ProfileProvider>().getProfile(),
          context.read<NoticeProvider>().getNotices(),
        ];
        await Future.wait(task);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      currentRoute: DashboardScreen.screenId,
      title: const Text(DashboardScreen.title),
      desktopBody: _body(),
      mobileBody: _mobileBody(),
    );
  }

  Widget _body() {
    return Consumer6<ProfileProvider, IssueProvider, EventProvider,
        DocumentProvider, NoticeProvider, ResidentProvider>(
      builder: (context, profileProvider, issueProvider, eventProvider,
          documentProvider, noticeProvider, residentProvider, child) {
        if (profileProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (issueProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (eventProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (documentProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (noticeProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (residentProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final isResident = profileProvider.user!.isResident ?? true;
        final isGuard = profileProvider.user!.isGuard ?? true;
        final fullName = profileProvider.user!.fullName;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (isResident)
                buildGreetingHeader(fullName)
              else
                buildTotalUsersCard(residentProvider.residentCount),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _buildUpcomingEvents()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildRecentNotices()),
                ],
              ),
              const SizedBox(height: 16),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                        child:
                            _buildIssueStatusSummary(isResident: isResident)),
                    const SizedBox(width: 16),
                    Expanded(child: _buildRecentDocuments()),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (!isGuard)
                _buildQuickActions(isOfficer: profileProvider.user!.isOfficer),
            ],
          ),
        );
      },
    );
  }

  Widget _mobileBody() {
    return Consumer6<ProfileProvider, IssueProvider, EventProvider,
        DocumentProvider, NoticeProvider, ResidentProvider>(
      builder: (context, profileProvider, issueProvider, eventProvider,
          documentProvider, noticeProvider, residentProvider, child) {
        if (profileProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (issueProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (eventProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (documentProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (noticeProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (residentProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final isResident = profileProvider.user!.isResident ?? true;
        final isGuard = profileProvider.user!.isGuard ?? true;
        final fullName = profileProvider.user!.fullName;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (isResident)
                buildGreetingHeader(fullName)
              else
                buildTotalUsersCard(residentProvider.residentCount),
              const SizedBox(height: 16),
              if (!isGuard)
                _buildQuickActions(isOfficer: profileProvider.user!.isOfficer),
              const SizedBox(height: 16),
              _buildUpcomingEvents(),
              const SizedBox(height: 16),
              _buildRecentNotices(),
              const SizedBox(height: 16),
              _buildIssueStatusSummary(isResident: isResident),
              const SizedBox(height: 16),
              _buildRecentDocuments(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCards({int openIssues = 0}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _summaryCard('Upcoming Events', '5'),
        _summaryCard('Open Issues', '$openIssues'),
        _summaryCard('Documents', '20'),
        _summaryCard('Active Notices', '4'),
      ],
    );
  }

  Widget buildTotalUsersCard(int totalUsers) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        child: Row(
          children: [
            // Icon or avatar on the left
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.blue[100],
              child: const Icon(Icons.group, color: Colors.blue, size: 36),
            ),
            const SizedBox(width: 24),
            // Text on the right
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Users',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$totalUsers registered users',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Including residents and staff members',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGreetingHeader(String? userName) {
    final now = DateTime.now();
    final greeting = _getGreetingForTime(now);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$greeting, ${userName ?? 'Resident'}!',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Today is ${DateFormat('EEEE, MMMM d, yyyy').format(now)}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  String _getGreetingForTime(DateTime time) {
    final hour = time.hour;
    if (hour < 12) return 'Good morning';
    if (hour < 18) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _summaryCard(String title, String count) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(count,
                  style: const TextStyle(
                      fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingEvents() {
    return Consumer<EventProvider>(
      builder: (context, eventProvider, child) {
        final event = eventProvider.upcomingEvents;
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Upcoming Events',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(),
                if (event.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          const Icon(Icons.info_outline,
                              size: 48, color: Colors.grey),
                          const SizedBox(height: 8),
                          Text(
                            'No Upcoming Events yet.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  ListTile(
                    leading: const Icon(Icons.event),
                    title: Text(
                      event[0].name,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      DateFormat('MMM d, yyyy · h:mm a').format(event[0].date),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.event),
                    title: Text(
                      event[1].name,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      DateFormat('MMM d, yyyy · h:mm a').format(event[1].date),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecentNotices() {
    return Consumer<NoticeProvider>(builder: (context, noticeProvider, child) {
      final notice = noticeProvider.notices;

      return Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Latest Notices',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              if (notice.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        const Icon(Icons.info_outline,
                            size: 48, color: Colors.grey),
                        const SizedBox(height: 8),
                        Text(
                          'No recent notices available.',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                ListTile(
                  leading: const Icon(Icons.campaign),
                  title: Text(
                    notice[0].title,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    'Posted: ${DateFormat('MMM d, yyyy · h:mm a').format(notice[0].createdDate ?? DateTime.now().toLocal())}',
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                if (notice.length > 1)
                  ListTile(
                    leading: const Icon(Icons.campaign),
                    title: Text(
                      notice[1].title,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      'Posted: ${DateFormat('MMM d, yyyy · h:mm a').format(notice[1].createdDate ?? DateTime.now().toLocal())}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
              ]
            ],
          ),
        ),
      );
    });
  }

  Widget _buildIssueStatusSummary({bool isResident = false}) {
    return Consumer<IssueProvider>(
      builder: (context, issueProvider, child) {
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Issue Status Summary',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(),
                if (isResident)
                  _statusRow('Draft', issueProvider.draftCount, Colors.blue),
                _statusRow('Open', issueProvider.openCount, Colors.red),
                _statusRow('In Progress', issueProvider.inProgressCount,
                    Colors.orange),
                _statusRow(
                    'Resolved', issueProvider.resolvedCount, Colors.green),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _statusRow(String status, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          CircleAvatar(radius: 12, backgroundColor: color),
          const SizedBox(width: 8),
          Expanded(child: Text(status)),
          Text(count.toString(),
              style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildRecentDocuments() {
    return Consumer<DocumentProvider>(
      builder: (context, documentProvider, child) {
        final document = documentProvider.documents;
        return Card(
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Recent Documents',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(),
                if (document.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Column(
                        children: [
                          const Icon(Icons.info_outline,
                              size: 48, color: Colors.grey),
                          const SizedBox(height: 8),
                          Text(
                            'No recent documents uploaded.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                else ...[
                  ListTile(
                    leading: const Icon(Icons.insert_drive_file),
                    title: Text(
                      document[0].title,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      'Uploaded: ${DateFormat('MMM d, yyyy · h:mm a').format(document[0].createdAt)}',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                  if (document.length > 1)
                    ListTile(
                      leading: const Icon(Icons.insert_drive_file),
                      title: Text(
                        document[1].title,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        'Uploaded: ${DateFormat('MMM d, yyyy · h:mm a').format(document[1].createdAt)}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions({bool isOfficer = false}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            if (isOfficer) ...[
              _quickActionButton(
                Icons.add,
                'Create Event',
                _handleEventCreate,
              ),
              _quickActionButton(
                  Icons.campaign, 'Post Notice', _handleNoticeCreate),
            ] else ...[
              _quickActionButton(
                Icons.report,
                'Report Issue',
                _handleIssueCreate,
              )
            ],
          ],
        ),
      ),
    );
  }

  Widget _quickActionButton(
      IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
