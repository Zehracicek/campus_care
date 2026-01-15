import 'package:campus_care/core/extensions/context_extension.dart';
import 'package:campus_care/core/providers/app_providers.dart';
import 'package:campus_care/core/resources/result.dart';
import 'package:campus_care/core/theme/app_theme.dart';
import 'package:campus_care/features/domain/entities/rating_entity.dart';
import 'package:campus_care/features/presentation/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class RatingsWidget extends ConsumerStatefulWidget {
  final String requestId;

  const RatingsWidget({super.key, required this.requestId});

  @override
  ConsumerState<RatingsWidget> createState() => _RatingsWidgetState();
}

class _RatingsWidgetState extends ConsumerState<RatingsWidget> {
  int _selectedRating = 0;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authControllerProvider).data ?? AuthData();
      final userId = authState.user?.id ?? '';
      ref
          .read(ratingControllerProvider.notifier)
          .loadRatings(widget.requestId, userId);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ratingState = ref.watch(ratingControllerProvider);
    final authState = ref.watch(authControllerProvider).data ?? AuthData();
    final currentUser = authState.user;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
                      'Değerlendirmeler',
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

          // Average Rating Summary
          if (ratingState.data != null && ratingState.data!.totalRatings > 0)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Row(
                children: [
                  Column(
                    children: [
                      Text(
                        ratingState.data!.averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < ratingState.data!.averageRating.round()
                                ? Icons.star
                                : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${ratingState.data!.totalRatings} değerlendirme',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: List.generate(5, (index) {
                        final starCount = 5 - index;
                        final ratingCount = ratingState.data!.ratings
                            .where((r) => r.rating == starCount)
                            .length;
                        final percentage = ratingState.data!.totalRatings > 0
                            ? (ratingCount /
                                      ratingState.data!.totalRatings *
                                      100)
                                  .round()
                            : 0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Text(
                                '$starCount',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                              const Icon(
                                Icons.star,
                                size: 14,
                                color: Colors.amber,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: percentage / 100,
                                  backgroundColor: Colors.grey[200],
                                  color: Colors.amber,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '$percentage%',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

          // Add/Edit Rating Form
          if (currentUser != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (ratingState.data?.userRating != null)
                    Text(
                      'Değerlendirmenizi Düzenleyin',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    )
                  else
                    Text(
                      'Değerlendirme Yapın',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      final starValue = index + 1;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRating = starValue;
                          });
                        },
                        child: Icon(
                          _selectedRating >= starValue ||
                                  (ratingState.data?.userRating != null &&
                                      _selectedRating == 0 &&
                                      ratingState.data!.userRating!.rating >=
                                          starValue)
                              ? Icons.star
                              : Icons.star_border,
                          size: 40,
                          color: Colors.amber,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _commentController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Yorumunuzu yazın (opsiyonel)',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isSubmitting
                              ? null
                              : () => _submitRating(currentUser.id),
                          icon: _isSubmitting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  ratingState.data?.userRating != null
                                      ? Icons.edit
                                      : Icons.send,
                                ),
                          label: Text(
                            ratingState.data?.userRating != null
                                ? 'Güncelle'
                                : 'Gönder',
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      if (ratingState.data?.userRating != null) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: _isSubmitting
                              ? null
                              : () => _deleteRating(
                                  ratingState.data!.userRating!.id,
                                  currentUser.id,
                                ),
                          icon: const Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

          // Ratings List
          Expanded(
            child: ratingState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : ratingState.isError
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
                          ratingState.error ?? 'Bir hata oluştu',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ratingState.data == null || ratingState.data!.ratings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star_border,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        const Text('Henüz değerlendirme yok'),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: ratingState.data!.ratings.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final rating = ratingState.data!.ratings[index];
                      return _RatingCard(rating: rating);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRating(String userId) async {
    final currentRating = _selectedRating > 0
        ? _selectedRating
        : ref.read(ratingControllerProvider).data?.userRating?.rating ?? 0;

    if (currentRating == 0) {
      context.showErrorToast('Lütfen bir yıldız seçin');
      return;
    }

    setState(() => _isSubmitting = true);

    final existingRating = ref.read(ratingControllerProvider).data?.userRating;

    Result<void> result;
    if (existingRating != null) {
      result = await ref
          .read(ratingControllerProvider.notifier)
          .updateRating(
            ratingId: existingRating.id,
            requestId: widget.requestId,
            userId: userId,
            rating: currentRating,
            comment: _commentController.text.trim().isEmpty
                ? null
                : _commentController.text.trim(),
          );
    } else {
      result = await ref
          .read(ratingControllerProvider.notifier)
          .addRating(
            requestId: widget.requestId,
            userId: userId,
            rating: currentRating,
            comment: _commentController.text.trim().isEmpty
                ? null
                : _commentController.text.trim(),
          );
    }

    setState(() => _isSubmitting = false);

    result.when(
      success: (_) {
        _commentController.clear();
        setState(() => _selectedRating = 0);
        context.showSuccessToast('Değerlendirme kaydedildi');
      },
      failure: (error) => context.showErrorToast(error.message),
    );
  }

  Future<void> _deleteRating(String ratingId, String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Değerlendirme Sil'),
        content: const Text(
          'Bu değerlendirmeyi silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);

    final result = await ref
        .read(ratingControllerProvider.notifier)
        .deleteRating(ratingId, widget.requestId, userId);

    setState(() => _isSubmitting = false);

    result.when(
      success: (_) {
        _commentController.clear();
        setState(() => _selectedRating = 0);
        context.showSuccessToast('Değerlendirme silindi');
      },
      failure: (error) => context.showErrorToast(error.message),
    );
  }
}

class _RatingCard extends ConsumerWidget {
  final RatingEntity rating;

  const _RatingCard({required this.rating});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue[100],
              child: const Icon(Icons.person, color: Colors.blue),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < rating.rating ? Icons.star : Icons.star_border,
                        size: 16,
                        color: Colors.amber,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(rating.createdAt),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (rating.comment != null && rating.comment!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(rating.comment!, style: const TextStyle(fontSize: 14)),
        ],
      ],
    );
  }
}
