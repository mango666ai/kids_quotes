import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/baby_profile.dart';
import '../utils/age_calculator.dart';

class HomeEntryCard extends StatelessWidget {
  final BabyProfile? profile;
  final VoidCallback onTap;

  const HomeEntryCard({super.key, required this.profile, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final hasProfile = profile != null;

    final age = hasProfile ? calcAge(profile!.birthday, today) : '';
    final dateText = DateFormat('yyyy年M月d日', 'zh').format(today);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFB088),
              Color(0xFFFF8C42),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF8C42).withOpacity(0.25),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: hasProfile
            ? _withProfile(profile!, age, dateText)
            : _withoutProfile(),
      ),
    );
  }

  Widget _withProfile(BabyProfile p, String age, String dateText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(p.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$age · $dateText',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Row(
          children: [
            Icon(Icons.edit_note_rounded, color: Colors.white, size: 28),
            SizedBox(width: 8),
            Text(
              '记录今天的童言',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _withoutProfile() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('👋', style: TextStyle(fontSize: 32)),
        SizedBox(height: 12),
        Text(
          '先告诉我宝宝是谁吧',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 6),
        Text(
          '点击进入设置 ›',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
      ],
    );
  }
}
