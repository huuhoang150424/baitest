import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/receipts/presentation/screens/create_receipt_screen.dart';
import '../../features/receipts/presentation/screens/receipt_detail_screen.dart';
import '../../features/receipts/presentation/screens/receipt_list_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/receipts',
  routes: [
    GoRoute(
      path: '/receipts',
      builder: (context, state) => const ReceiptListScreen(),
      routes: [
        GoRoute(
          path: 'create',
          builder: (context, state) => const CreateReceiptScreen(),
        ),
        GoRoute(
          path: ':id',
          builder: (context, state) {
            final idStr = state.pathParameters['id'] ?? '0';
            final id = int.tryParse(idStr) ?? 0;
            return ReceiptDetailScreen(receiptId: id);
          },
        ),
      ],
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Lỗi')),
    body: Center(
      child: Text('Không tìm thấy trang ${state.uri}'),
    ),
  ),
);
