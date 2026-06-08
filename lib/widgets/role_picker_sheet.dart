import 'package:flutter/material.dart';

import '../models/role.dart';
import 'new_role_dialog.dart';

/// Shows a bottom sheet listing roles. Returns the selected Role, or
/// returns a Role with id == null when user creates a new one (caller
/// should persist it).
Future<Role?> showRolePickerSheet(
  BuildContext context, {
  required List<Role> roles,
}) {
  return showModalBottomSheet<Role>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
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
                  '选择说话人',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              ...roles.map((r) => ListTile(
                    leading: Text(r.emoji,
                        style: const TextStyle(fontSize: 24)),
                    title: Text(r.name),
                    onTap: () => Navigator.pop(ctx, r),
                  )),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('新增角色'),
                onTap: () async {
                  final newRole = await showNewRoleDialog(context);
                  if (newRole != null && ctx.mounted) {
                    Navigator.pop(ctx, newRole);
                  }
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
