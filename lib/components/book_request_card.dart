// lib/components/book_request_card.dart

import 'package:flutter/material.dart';
import 'package:myapp/models/book_request.dart';

class BookRequestCard extends StatelessWidget {
  final BookRequest br;

  const BookRequestCard({super.key, required this.br});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                br.imageUrl,
                width: 60,
                height: 80,
                fit: BoxFit.cover,
                 loadingBuilder: (context, child, progress) {
                  return progress == null ? child : const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.menu_book, size: 40, color: Colors.grey);
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    br.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '저자: ${br.authorName}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    br.content,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                   const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Chip(
                      label: Text('+${br.points}P'),
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
