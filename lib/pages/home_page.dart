import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/journal_provider.dart';
import '../../providers/challenge_provider.dart';
import '../../providers/dream_provider.dart';
import '../../config/theme.dart';
import 'journal/write_journal_page.dart';
import 'challenge/create_challenge_page.dart';
import 'dream/deposit_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final journalProvider = context.read<JournalProvider>();
    final challengeProvider = context.read<ChallengeProvider>();
    final dreamProvider = context.read<DreamProvider>();

    await Future.wait([
      journalProvider.loadTodayEntry(),
      journalProvider.loadStreakDays(),
      challengeProvider.loadChallenges(),
      dreamProvider.loadDreams(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(context),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _buildStreakCard(context),
                  const SizedBox(height: 16),
                  _buildJournalCard(context),
                  const SizedBox(height: 16),
                  _buildChallengesCard(context),
                  const SizedBox(height: 16),
                  _buildDreamCard(context),
                  const SizedBox(height: 16),
                  _buildQuickActions(context),
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyy年MM月dd日 EEEE', 'zh_CN').format(now);

    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          '今日',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.goldGradient,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 56),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  dateStr,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withOpacity(0.9),
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context) {
    return Consumer<JournalProvider>(
      builder: (context, provider, child) {
        final streakDays = provider.streakDays;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppTheme.sunsetGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentOrange.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.local_fire_department,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '连续行动',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$streakDays 天',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              if (streakDays > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '继续加油！',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildJournalCard(BuildContext context) {
    return Consumer<JournalProvider>(
      builder: (context, provider, child) {
        final hasTodayEntry = provider.hasTodayEntry;
        final todayEntry = provider.todayEntry;

        return Card(
          child: InkWell(
            onTap: () async {
              if (!hasTodayEntry) {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WriteJournalPage(),
                  ),
                );
                _loadData();
              }
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGoldLight.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.edit_note,
                          color: AppTheme.primaryGold,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '今日成功日记',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Spacer(),
                      if (hasTodayEntry)
                        const Icon(
                          Icons.check_circle,
                          color: AppTheme.successGreen,
                          size: 24,
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (hasTodayEntry && todayEntry != null) ...[
                    _buildSuccessItem(context, '1', todayEntry.success1),
                    const SizedBox(height: 8),
                    _buildSuccessItem(context, '2', todayEntry.success2),
                    const SizedBox(height: 8),
                    _buildSuccessItem(context, '3', todayEntry.success3),
                  ] else ...[
                    Text(
                      '记录今天的3个成功，让自己看到进步！',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const WriteJournalPage(),
                          ),
                        );
                        _loadData();
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('写日记'),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuccessItem(BuildContext context, String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.primaryGold,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }

  Widget _buildChallengesCard(BuildContext context) {
    return Consumer<ChallengeProvider>(
      builder: (context, provider, child) {
        final activeChallenges = provider.activeChallenges.take(3).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.progressBlue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.flag,
                        color: AppTheme.progressBlue,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '72小时挑战',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const Spacer(),
                    if (activeChallenges.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.progressBlue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${activeChallenges.length}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.progressBlue,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (activeChallenges.isEmpty)
                  Text(
                    '暂无进行中的挑战，创建一个72小时最小动作吧！',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else
                  ...activeChallenges.map((challenge) {
                    final timeRemaining = challenge.timeRemaining;
                    final hours = timeRemaining.inHours;
                    final minutes = timeRemaining.inMinutes % 60;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.progressBlue.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            challenge.title,
                            style: Theme.of(context).textTheme.titleMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            challenge.minimalAction,
                            style: Theme.of(context).textTheme.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 16,
                                color: hours < 24
                                    ? AppTheme.accentOrange
                                    : AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '剩余 ${hours}小时${minutes}分钟',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: hours < 24
                                          ? AppTheme.accentOrange
                                          : AppTheme.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDreamCard(BuildContext context) {
    return Consumer<DreamProvider>(
      builder: (context, provider, child) {
        final topDream = provider.topDream;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.accentPink.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.stars,
                        color: AppTheme.accentPink,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '当前梦想',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (topDream == null)
                  Text(
                    '还没有梦想？去创建一个吧！',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else ...[
                  Text(
                    topDream.title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: topDream.progress,
                      minHeight: 8,
                      backgroundColor: AppTheme.textLight.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.successGreen,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '¥${topDream.currentAmount.toStringAsFixed(0)} / ¥${topDream.targetAmount.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        '${(topDream.progress * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.successGreen,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => DepositDialog(dreamId: topDream.id),
                      );
                    },
                    icon: const Icon(Icons.savings),
                    label: const Text('存一笔'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '快捷操作',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                context,
                icon: Icons.edit,
                label: '写日记',
                color: AppTheme.primaryGold,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const WriteJournalPage(),
                    ),
                  );
                  _loadData();
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                context,
                icon: Icons.flag,
                label: '新挑战',
                color: AppTheme.progressBlue,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateChallengePage(),
                    ),
                  );
                  _loadData();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
