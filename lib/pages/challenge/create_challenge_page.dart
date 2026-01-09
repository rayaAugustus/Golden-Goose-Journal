import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/challenge_provider.dart';
import '../../providers/dream_provider.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';

class CreateChallengePage extends StatefulWidget {
  const CreateChallengePage({super.key});

  @override
  State<CreateChallengePage> createState() => _CreateChallengePageState();
}

class _CreateChallengePageState extends State<CreateChallengePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _actionController = TextEditingController();

  String? _selectedDreamId;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _actionController.dispose();
    super.dispose();
  }

  void _useTemplate(Map<String, String> template) {
    _titleController.text = template['title']!;
    _actionController.text = template['action']!;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final provider = context.read<ChallengeProvider>();
    final success = await provider.createChallenge(
      title: _titleController.text.trim(),
      minimalAction: _actionController.text.trim(),
      dreamId: _selectedDreamId,
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ 挑战创建成功！72小时倒计时开始！'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('创建72小时挑战'),
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
              child: const Text('创建'),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 说明卡片
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.oceanGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        '72小时法则',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '任何想做的事，在72小时内必须推进一个可验证的最小动作。',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 挑战标题
            Text(
              '挑战标题',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              maxLength: AppConstants.maxChallengeTitle,
              decoration: const InputDecoration(
                hintText: '例如：开始学习Flutter',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入挑战标题';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // 最小动作
            Text(
              '最小可验证动作（MVA）',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _actionController,
              maxLength: AppConstants.maxMinimalAction,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '例如：完成Flutter官方教程第一章',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入最小动作';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // 关联梦想
            Text(
              '关联梦想（可选）',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Consumer<DreamProvider>(
              builder: (context, provider, child) {
                final dreams = provider.activeDreams;
                
                if (dreams.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '暂无梦想，可以先创建一个梦想',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                    ),
                  );
                }

                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    hintText: '选择一个梦想',
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      child: Text('不关联梦想'),
                    ),
                    ...dreams.map((dream) {
                      return DropdownMenuItem<String>(
                        value: dream.id,
                        child: Text(dream.title),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedDreamId = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            // 快捷模板
            Text(
              '快捷模板',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            ...AppConstants.challengeTemplates.map((template) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.progressBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline,
                      color: AppTheme.progressBlue,
                      size: 20,
                    ),
                  ),
                  title: Text(template['title']!),
                  subtitle: Text(
                    template['action']!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () => _useTemplate(template),
                ),
              );
            }),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
