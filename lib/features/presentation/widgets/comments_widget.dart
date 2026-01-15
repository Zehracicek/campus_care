import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:campus_care/core/providers/app_providers.dart';
import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/theme/app_theme.dart';
import 'package:campus_care/features/domain/entities/comment_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../controllers/auth_controller.dart';

class CommentsWidget extends ConsumerStatefulWidget {
  final String requestId;

  const CommentsWidget({super.key, required this.requestId});

  @override
  ConsumerState<CommentsWidget> createState() => _CommentsWidgetState();
}

class _CommentsWidgetState extends ConsumerState<CommentsWidget> {
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(commentControllerProvider.notifier)
          .loadComments(widget.requestId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentState = ref.watch(commentControllerProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Yorumlar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Comments List
          Expanded(
            child: commentState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : commentState.isError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          commentState.message ?? 'Bir hata oluştu',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  )
                : commentState.data?.comments.isEmpty ?? true
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Henüz yorum yok',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'İlk yorumu siz ekleyin',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: commentState.data!.comments.length,
                    separatorBuilder: (_, __) => const Divider(height: 24),
                    itemBuilder: (context, index) {
                      final comment = commentState.data!.comments[index];
                      return _buildCommentCard(comment);
                    },
                  ),
          ),

          // Comment Input
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Bir yorum yazın...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    onPressed: _isSubmitting ? null : _submitComment,
                    backgroundColor: AppTheme.primaryColor,
                    mini: true,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentCard(CommentEntity comment) {
    final authState = ref.watch(authControllerProvider).data ?? AuthData();
    final currentUser = authState.user;
    final isOwner = currentUser?.id == comment.userId;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isOwner ? Colors.blue[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                child: Icon(
                  Icons.person,
                  size: 18,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOwner ? 'Siz' : 'Kullanıcı',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      _formatDate(comment.createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment.text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Şimdi';
        }
        return '${difference.inMinutes} dakika önce';
      }
      return '${difference.inHours} saat önce';
    } else if (difference.inDays == 1) {
      return 'Dün ${DateFormat('HH:mm').format(date)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} gün önce';
    } else {
      return DateFormat('dd MMM yyyy, HH:mm').format(date);
    }
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      context.showErrorToast('Lütfen bir yorum yazın');
      return;
    }

    final authState = ref.read(authControllerProvider).data ?? AuthData();
    final user = authState.user;

    if (user == null) {
      context.showErrorToast('Kullanıcı bilgisi bulunamadı');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final comment = CommentEntity(
      id: '',
      requestId: widget.requestId,
      userId: user.id,
      text: text,
      createdAt: DateTime.now(),
    );

    final result = await ref
        .read(commentControllerProvider.notifier)
        .addComment(comment);

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      result.when(
        success: (_) {
          _commentController.clear();
          context.showSuccessToast('Yorum eklendi');
        },
        failure: (error) {
          context.showErrorToast(error.message);
        },
      );
    }
  }
}
