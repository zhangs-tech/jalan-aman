import 'package:flutter/material.dart';
import 'package:jalan_aman/theme/theme.dart';

class CommentInput extends StatefulWidget {
  const CommentInput({super.key, required this.onSend, this.isSending = false});

  final ValueChanged<String> onSend;
  final bool isSending;

  @override
  State<CommentInput> createState() => _CommentInputState();
}

class _CommentInputState extends State<CommentInput> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.base,
        AppSpacing.sm,
        AppSpacing.base,
        AppSpacing.base,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 3,
                style: AppTextStyles.bodyMedium,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(hintText: 'Add a comment...'),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              height: 44,
              child: FilledButton(
                onPressed: widget.isSending || !hasText
                    ? null
                    : () {
                        final text = _controller.text.trim();
                        widget.onSend(text);
                        _controller.clear();
                        setState(() {});
                      },
                child: widget.isSending
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
