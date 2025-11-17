// lib/screens/br_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:myapp/models/book_request.dart';
import 'package:myapp/models/reply.dart';
import 'package:myapp/services/auth_service.dart';
import 'package:myapp/services/firestore_service.dart';
import 'package:myapp/theme/app_theme.dart';
import 'package:myapp/widgets/status_pill.dart';
import 'package:intl/intl.dart';

class BRDetailScreen extends StatefulWidget {
  final String brId;

  const BRDetailScreen({super.key, required this.brId});

  @override
  State<BRDetailScreen> createState() => _BRDetailScreenState();
}

class _BRDetailScreenState extends State<BRDetailScreen> {
  final _firestoreService = FirestoreService();
  late final Future<BookRequest?> _brFuture;
  final _replyController = TextEditingController();
  bool _isReplying = false;

  @override
  void initState() {
    super.initState();
    _brFuture = _firestoreService.getBookRequestById(widget.brId);
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _postReply() async {
    if (_replyController.text.trim().isEmpty) return;

    setState(() => _isReplying = true);

    final authService = context.read<AuthService>();
    final user = authService.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('로그인이 필요합니다.')),
      );
      setState(() => _isReplying = false);
      return;
    }

    try {
      await _firestoreService.addReplyToBR(
        widget.brId,
        content: _replyController.text,
        authorId: user.uid,
        authorName: user.email ?? 'Unknown User',
      );
      _replyController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('댓글 등록에 실패했습니다: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isReplying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Book Request")),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: FutureBuilder<BookRequest?>(
                  future: _brFuture,
                  builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text('데이터를 불러오는 데 실패했습니다.'));
                }

                final br = snapshot.data!;
                final formattedDate = DateFormat('yyyy.MM.dd HH:mm').format(br.createdAt.toDate());

                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    Text(br.title, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Row(children: [
                      // 작성자 이름 클릭 시 프로필로 이동
                      InkWell(
                        onTap: () => context.go('/profile/${br.authorId}'),
                        child: Row(children: [
                          const Icon(Icons.person_outline, size: 16),
                          const SizedBox(width: 4),
                          Text(br.authorName, style: theme.textTheme.bodyMedium?.copyWith(decoration: TextDecoration.underline)),
                        ]),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.schedule, size: 16), const SizedBox(width: 4),
                      Text(formattedDate, style: theme.textTheme.bodyMedium),
                    ]),
                    const Divider(height: 32),
                    Text(br.content, style: theme.textTheme.bodyLarge?.copyWith(height: 1.6)),
                    const Divider(height: 48),
                    Text('댓글', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    _buildRepliesStream(),
                  ],
                );
              },
            ),
              ),
            ),
          ),
          _buildReplyInput(),
        ],
      ),
    );
  }

  Widget _buildRepliesStream() {
    return StreamBuilder<List<Reply>>(
      stream: _firestoreService.getRepliesStream(widget.brId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('댓글을 불러오는 중 오류가 발생했습니다.'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Padding(
            padding: EdgeInsets.symmetric(vertical: 24.0),
            child: Text('첫 번째 댓글을 남겨보세요.', style: TextStyle(color: Colors.grey)),
          ));
        }

        final replies = snapshot.data!;

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: replies.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final reply = replies[index];
            final formattedDate = DateFormat('yyyy.MM.dd HH:mm').format(reply.createdAt.toDate());
            return ListTile(
              // 댓글 작성자 이름 클릭 시 프로필로 이동
              title: InkWell(
                onTap: () => context.go('/profile/${reply.authorId}'),
                child: Text(reply.authorName, style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
              ),
              subtitle: Text(reply.content),
              trailing: Text(formattedDate, style: Theme.of(context).textTheme.bodySmall),
            );
          },
        );
      },
    );
  }

  Widget _buildReplyInput() {
    return Material(
      elevation: 8.0,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 8),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _replyController,
              decoration: const InputDecoration(
                hintText: '댓글을 입력하세요...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _postReply(),
            ),
          ),
          const SizedBox(width: 8),
          _isReplying
              ? const CircularProgressIndicator()
              : IconButton.filled(
                  icon: const Icon(Icons.send),
                  onPressed: _postReply,
                  tooltip: '댓글 게시',
                ),
        ]),
      ),
    );
  }
}
