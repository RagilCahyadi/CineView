import 'package:flutter/material.dart';
import 'package:cineview/data/models/dummy_data_actor.dart';

class TopActorSection extends StatelessWidget {
  const TopActorSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Top Popular Actor',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  Text(
                    'See all',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.play_circle_filled,
                    color: Colors.deepPurple.shade300,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: actors.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: _buildActorItem(actors[index]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActorItem(DummyDataActor actor) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.shade700,
            border: Border.all(color: Colors.grey.shade600, width: 2),
            image: DecorationImage(
              image: AssetImage(actor.image),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          actor.firstName,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),

        Text(
          actor.lastName,
          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
        ),
      ],
    );
  }
}
