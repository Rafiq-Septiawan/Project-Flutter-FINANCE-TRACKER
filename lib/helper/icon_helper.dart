import 'package:flutter/material.dart';

IconData getMaterialIcon(String iconName) {
  const iconMap = {
    'restaurant': Icons.restaurant,
    'directions_car': Icons.directions_car,
    'shopping_cart': Icons.shopping_cart,
    'movie': Icons.movie,
    'receipt_long': Icons.receipt_long,
    'local_hospital': Icons.local_hospital,
    'school': Icons.school,
    'work': Icons.work,
    'card_giftcard': Icons.card_giftcard,
    'show_chart': Icons.show_chart,
    'account_balance_wallet': Icons.account_balance_wallet,
  };

  return iconMap[iconName] ?? Icons.category;
}
