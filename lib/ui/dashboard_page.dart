import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Golden Goose Journal'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _OverviewCard(),
          const SizedBox(height: 16),
          _ActionGrid(),
          const SizedBox(height: 16),
          _RecentNotes(),
        ],
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('本月概览', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            const Text('余额：¥0.00'),
            const Text('收入：¥0.00'),
            const Text('支出：¥0.00'),
            const SizedBox(height: 12),
            const LinearProgressIndicator(value: 0),
            const SizedBox(height: 8),
            const Text('目标进度：0%'),
          ],
        ),
      ),
    );
  }
}

class _ActionGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.edit_note,
            title: '记一笔',
            subtitle: '记录收入或支出',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.book,
            title: '写日记',
            subtitle: '记录情绪与行动',
          ),
        ),
      ],
    );
  }
}

class _RecentNotes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('最近日记'),
            SizedBox(height: 8),
            Text('暂无记录，开始写下今天的收获吧！'),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32),
            const SizedBox(height: 12),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
