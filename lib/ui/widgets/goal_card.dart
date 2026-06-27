import 'package:flutter/material.dart';
import '../../models/savings_goal.dart';
import 'package:intl/intl.dart';

class GoalCard extends StatelessWidget {
  final SavingsGoal goal;

  const GoalCard({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final double progress = goal.targetAmount > 0
        ? (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0)
        : 0.0;
        
    final currencyFormatter = NumberFormat.currency(locale: 'it_IT', symbol: '€');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  goal.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (goal.icon != null)
                  Text(
                    goal.icon!,
                    style: const TextStyle(fontSize: 24),
                  )
                else
                  const Icon(Icons.savings, color: Colors.amber),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade800,
              color: Colors.green,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${currencyFormatter.format(goal.currentAmount)} / ${currencyFormatter.format(goal.targetAmount)}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            if (goal.deadline != null) ...[
              const SizedBox(height: 8),
              Text(
                'Scadenza: ${DateFormat('dd MMM yyyy', 'it_IT').format(goal.deadline!)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
