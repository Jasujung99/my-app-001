import 'package:flutter/material.dart';

class ContentCard extends StatelessWidget {
	final String title;
	final String? subtitle;
	final Widget? content;
	final VoidCallback? onTap;

	const ContentCard({
		super.key,
		required this.title,
		this.subtitle,
		this.content,
		this.onTap,
	});

	@override
	Widget build(BuildContext context) {
		final theme = Theme.of(context);

		return Card(
			elevation: 2.0,
			margin: const EdgeInsets.symmetric(vertical: 8.0),
			shape: RoundedRectangleBorder(
				borderRadius: BorderRadius.circular(12.0),
			),
			child: InkWell(
				onTap: onTap,
				borderRadius: BorderRadius.circular(12.0),
				child: Padding(
					padding: const EdgeInsets.all(16.0),
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Text(
								title,
								style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
							),
							if (subtitle != null) ...[
								const SizedBox(height: 4),
								Text(
									subtitle!,
									style: theme.textTheme.bodyMedium?.copyWith(
										color: theme.colorScheme.onSurfaceVariant,
									),
								),
							],
							if (content != null) ...[
								const SizedBox(height: 16),
								content!,
							],
						],
					),
				),
			),
		);
	}
}
