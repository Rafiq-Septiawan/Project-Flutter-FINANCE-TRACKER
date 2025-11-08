import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction_model.dart';

class TransactionCard extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  const TransactionCard({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final isIncome = transaction.type == 'income';
    final statusColor = isIncome ? Colors.green : Colors.red;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon/Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: statusColor.withValues(alpha: 0.1),
                child: transaction.category?.icon != null
                    ? Text(
                        transaction.category!.icon!,
                        style: const TextStyle(fontSize: 24),
                      )
                    : Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: statusColor,
                      ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.category?.name ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('dd MMM yyyy').format(transaction.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (transaction.description != null &&
                        transaction.description!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          transaction.description!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
              // Amount & Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    currencyFormat.format(transaction.amount),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  if (onEdit != null || onDelete != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (onEdit != null)
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            color: Colors.blue,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: onEdit,
                          ),
                        if (onDelete != null)
                          IconButton(
                            icon: const Icon(Icons.delete, size: 18),
                            color: Colors.red,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: onDelete,
                          ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Compact version untuk list sederhana
class TransactionCardCompact extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback? onTap;

  const TransactionCardCompact({
    super.key,
    required this.transaction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final isIncome = transaction.type == 'income';
    final statusColor = isIncome ? Colors.green : Colors.red;

    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: statusColor.withValues(alpha: 0.1),
        child: transaction.category?.icon != null
            ? Text(transaction.category!.icon!,
                style: const TextStyle(fontSize: 20))
            : Icon(
                isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: statusColor,
                size: 20,
              ),
      ),
      title: Text(
        transaction.category?.name ?? 'Unknown',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(DateFormat('dd MMM yyyy').format(transaction.date)),
      trailing: Text(
        currencyFormat.format(transaction.amount),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: statusColor,
          fontSize: 14,
        ),
      ),
    );
  }
}

// Summary card untuk dashboard
class TransactionSummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const TransactionSummaryCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                currencyFormat.format(amount),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
