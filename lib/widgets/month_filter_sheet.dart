import 'package:flutter/material.dart';

Future<({int year, int month})?> showMonthFilterSheet(
  BuildContext context, {
  required List<({int year, int month})> months,
}) {
  return showModalBottomSheet<({int year, int month})>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      if (months.isEmpty) {
        return const SafeArea(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('还没有任何记录'),
          ),
        );
      }
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  '选择月份',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 360),
                child: ListView(
                  shrinkWrap: true,
                  children: months
                      .map((m) => ListTile(
                            leading: const Icon(Icons.calendar_month_outlined),
                            title: Text('${m.year}年${m.month}月'),
                            onTap: () => Navigator.pop(ctx, m),
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
