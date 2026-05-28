import 'package:flutter/material.dart';
import 'package:jalan_aman/models/report_models.dart';
import 'package:jalan_aman/theme/theme.dart';
import 'package:jalan_aman/utils/time_label.dart';

class CommentItem extends StatefulWidget {
  const CommentItem({
    super.key,
    required this.comment,
    required this.isMine,
    required this.onDelete,
    required this.onUpdate,
  });

  final ReportComment comment;
  final bool isMine;
  final VoidCallback onDelete;
  final ValueChanged<String> onUpdate;

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool _isEditing = false;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.comment.details);
  }

  @override
  void didUpdateWidget(covariant CommentItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.comment.details != widget.comment.details && !_isEditing) {
      _controller.text = widget.comment.details;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final initial = widget.comment.userName.isNotEmpty
        ? widget.comment.userName[0].toUpperCase()
        : '?';

    return InkWell(
      onLongPress: widget.isMine ? widget.onDelete : null,
      borderRadius: AppRadius.inputRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // avatar
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.22),
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // bubble
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(AppRadius.md),
                    bottomLeft: Radius.circular(AppRadius.md),
                    bottomRight: Radius.circular(AppRadius.md),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //name, time, edit icon
                    Row(
                      children: [
                        Text(
                          widget.comment.userName,
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          timeAgoLabel(widget.comment.createdAt),
                          style: AppTextStyles.caption,
                        ),
                        if (widget.isMine && !_isEditing) ...[
                          const Spacer(),
                          GestureDetector(
                            onTap: () => setState(() => _isEditing = true),
                            child: const Icon(
                              Icons.edit_outlined,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Content — comment text or edit field
                    if (_isEditing)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextField(
                            controller: _controller,
                            maxLines: 3,
                            autofocus: true,
                            style: AppTextStyles.bodyMedium,
                            decoration: const InputDecoration(
                              hintText: 'Update comment',
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => setState(() {
                                  _isEditing = false;
                                  _controller.text = widget.comment.details;
                                }),
                                child: const Text('Cancel'),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              FilledButton.tonal(
                                onPressed: () {
                                  final value = _controller.text.trim();
                                  if (value.isEmpty) return;
                                  widget.onUpdate(value);
                                  setState(() => _isEditing = false);
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                        ],
                      )
                    else
                      Text(
                        widget.comment.details,
                        style: AppTextStyles.bodyMedium,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
