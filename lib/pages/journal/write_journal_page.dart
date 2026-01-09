import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/journal_provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../challenge/create_challenge_page.dart';

class WriteJournalPage extends StatefulWidget {
  const WriteJournalPage({super.key});

  @override
  State<WriteJournalPage> createState() => _WriteJournalPageState();
}

class _WriteJournalPageState extends State<WriteJournalPage> {
  final _formKey = GlobalKey<FormState>();
  final _success1Controller = TextEditingController();
  final _success2Controller = TextEditingController();
  final _success3Controller = TextEditingController();
  final _learnedController = TextEditingController();
  final _tomorrowController = TextEditingController();

  int? _selectedMood;
  final Set<String> _selectedTags = {};
  bool _isSubmitting = false;

  @override
  void dispose() {
    _success1Controller.dispose();
    _success2Controller.dispose();
    _success3Controller.dispose();
    _learnedController.dispose();
    _tomorrowController.dispose();
    super.dispose();
  }

  void _fillExample(TextEditingController controller) {
    final examples = AppConstants.journalExamples;
    examples.shuffle();
    controller.text = examples.first;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final provider = context.read<JournalProvider>();
    final success = await provider.createEntry(
      success1: _success1Controller.text.trim(),
      success2: _success2Controller.text.trim(),
      success3: _success3Controller.text.trim(),
      mood: _selectedMood,
      tags: _selectedTags.toList(),
      todayLearned: _learnedController.text.trim().isEmpty
          ? null
          : _learnedController.text.trim(),
      tomorrowAction: _tomorrowController.text.trim().isEmpty
          ? null
          : _tomorrowController.text.trim(),
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      // 显示完成弹窗
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final provider = context.read<JournalProvider>();
    final streakDays = provider.streakDays;
    final randomSuccess = provider.getRandomSuccess();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryGoldLight.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.celebration,
                color: AppTheme.primaryGold,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '太棒了！',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '连续第 $streakDays 天',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.primaryGold,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            if (randomSuccess != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '回顾过去的成功',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      randomSuccess,
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              '要不要为明天创建一个72小时最小动作？',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('稍后再说'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const CreateChallengePage(),
                ),
              );
            },
            child: const Text('创建挑战'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('写成功日记'),
        actions: [
          if (_isSubmitting)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _submit,
              child: const Text('完成'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 鼓励文案
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.goldGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppConstants.encouragementMessages[
                          DateTime.now().day % AppConstants.encouragementMessages.length],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 成功1
            _buildSuccessField(
              controller: _success1Controller,
              label: '成功 1',
              number: '1',
            ),
            const SizedBox(height: 16),

            // 成功2
            _buildSuccessField(
              controller: _success2Controller,
              label: '成功 2',
              number: '2',
            ),
            const SizedBox(height: 16),

            // 成功3
            _buildSuccessField(
              controller: _success3Controller,
              label: '成功 3',
              number: '3',
            ),
            const SizedBox(height: 24),

            // 心情
            Text(
              '今天的心情（可选）',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final mood = index + 1;
                final isSelected = _selectedMood == mood;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedMood = isSelected ? null : mood;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryGold
                          : AppTheme.backgroundLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryGold
                            : AppTheme.textLight.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _getMoodEmoji(mood),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // 标签
            Text(
              '标签（可选）',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: AppConstants.journalTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return FilterChip(
                  label: Text(tag),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    });
                  },
                  selectedColor: AppTheme.primaryGoldLight,
                  checkmarkColor: AppTheme.primaryGold,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 今日学到的
            Text(
              '今日学到的（可选）',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _learnedController,
              maxLength: AppConstants.maxLearnedLength,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '记录今天学到的新知识或感悟...',
              ),
            ),
            const SizedBox(height: 16),

            // 明天最重要一步
            Text(
              '明天最重要一步（可选）',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _tomorrowController,
              maxLength: AppConstants.maxTomorrowActionLength,
              maxLines: 2,
              decoration: const InputDecoration(
                hintText: '明天最想完成的一件事...',
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessField({
    required TextEditingController controller,
    required String label,
    required String number,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppTheme.primaryGold,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(
                  number,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: () => _fillExample(controller),
              icon: const Icon(Icons.auto_awesome, size: 16),
              label: const Text('示例'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLength: AppConstants.maxSuccessLength,
          decoration: const InputDecoration(
            hintText: '写下今天的一个成功...',
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return '请填写这个成功';
            }
            return null;
          },
        ),
      ],
    );
  }

  String _getMoodEmoji(int mood) {
    switch (mood) {
      case 1:
        return '😢';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '😊';
      case 5:
        return '😄';
      default:
        return '😐';
    }
  }
}
