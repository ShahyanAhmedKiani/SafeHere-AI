import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme.dart';
import '../../../models/trusted_contact.dart';

class TrustedCirclePreview extends StatelessWidget {
  const TrustedCirclePreview({super.key, required this.contacts});
  final List<TrustedContact> contacts;

  Color _hexToColor(String hex) {
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 84,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ...contacts.take(8).map((c) => Padding(
                padding: const EdgeInsets.only(right: 14),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: _hexToColor(c.avatarColor),
                      child: Text(
                        c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                    const SizedBox(height: 6),
                    SizedBox(
                      width: 56,
                      child: Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
                    ),
                  ],
                ),
              )),
          Column(
            children: [
              InkWell(
                onTap: () => context.push('/circle/add'),
                borderRadius: BorderRadius.circular(26),
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.rose, style: BorderStyle.solid, width: 1.4),
                  ),
                  child: const Icon(Icons.add, color: AppColors.rose),
                ),
              ),
              const SizedBox(height: 6),
              const Text('Add', style: TextStyle(fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
