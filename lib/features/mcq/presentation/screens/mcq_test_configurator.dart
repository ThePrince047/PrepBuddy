import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';

class McqTestConfigurator extends StatefulWidget {
  final String topic;

  const McqTestConfigurator({super.key, required this.topic});

  @override
  State<McqTestConfigurator> createState() => _McqTestConfiguratorState();
}

class _McqTestConfiguratorState extends State<McqTestConfigurator> {
  int _questionCount = 10;
  String _mode = 'Practice'; // Practice or Exam

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Test'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Topic: ${widget.topic}', style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 32),

            Text('Test Mode', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _buildModeOption('Practice', Icons.school, 'No time limit, immediate solutions', _mode == 'Practice'),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildModeOption('Exam', Icons.timer, 'Strict timer, results at the end', _mode == 'Exam'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Text('Number of Questions', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('$_questionCount', style: Theme.of(context).textTheme.displayMedium),
                  Expanded(
                    child: Slider(
                      value: _questionCount.toDouble(),
                      min: 5,
                      max: 50,
                      divisions: 9,
                      activeColor: context.colors.primary,
                      inactiveColor: context.colors.border,
                      onChanged: (val) {
                        setState(() {
                          _questionCount = val.toInt();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            ElevatedButton(
              onPressed: () {
                // Navigate to Active Test Engine
                context.push('/mcq/engine', extra: {
                  'topic': widget.topic,
                  'count': _questionCount,
                  'mode': _mode,
                });
              },
              child: const Text('Start Test Now'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeOption(String mode, IconData icon, String subtitle, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _mode = mode;
        });
      },
      child: GlassCard(
        padding: EdgeInsets.zero,
        borderRadius: 20,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? context.colors.primary : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: isSelected ? context.colors.primary : context.colors.textSecondary, size: 32),
              const SizedBox(height: 12),
              Text(
                mode,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : context.colors.textSecondary,
                    ),
              ),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.colors.textSecondary.withOpacity(0.7),
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
