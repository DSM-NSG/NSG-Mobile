import 'package:flutter/material.dart';
import 'package:nsg_mobile/constants/color.dart';
import 'package:nsg_mobile/constants/text_style.dart';
import 'package:nsg_mobile/features/major/data/dummy/major_dummy_data.dart';

class TrendingTopicsCard extends StatelessWidget {
  const TrendingTopicsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final left = majorTrendingTopics.sublist(0, 5);
    final right = majorTrendingTopics.sublist(5, 10);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NsgColor.black50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: left.map((t) => _TopicItem(topic: t)).toList(),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: right.map((t) => _TopicItem(topic: t)).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicItem extends StatelessWidget {
  final ({int rank, String name}) topic;

  const _TopicItem({required this.topic});

  @override
  Widget build(BuildContext context) {
    final isTop3 = topic.rank <= 3;
    final color = isTop3 ? NsgColor.orange400 : NsgColor.black800;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        '${topic.rank}. ${topic.name}',
        style: NsgTextStyle.body3.copyWith(color: color),
      ),
    );
  }
}
