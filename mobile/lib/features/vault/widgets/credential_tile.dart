import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/vault_repository.dart';
import '../../../core/theme/app_theme.dart';

class CredentialTile extends StatelessWidget {
  final Credential credential;
  final VoidCallback onTap;
  final Future<bool> Function() onDelete;
  final String? categoryName;

  const CredentialTile({
    super.key,
    required this.credential,
    required this.onTap,
    required this.onDelete,
    this.categoryName,
  });

  Future<void> _handleDismiss(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('DELETE RECORD'),
        content: Text(
          'Permanently delete "${credential.title}"?\nThis cannot be undone.',
          style: GoogleFonts.shareTechMono(color: context.cText, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCEL'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: kError,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    if (confirmed == true) await onDelete();
  }

  @override
  Widget build(BuildContext context) {
    final initial = credential.title.isNotEmpty
        ? credential.title[0].toUpperCase()
        : '?';

    return Dismissible(
      key: Key('cred-${credential.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await _handleDismiss(context);
        return false;
      },
      background: Container(
        color: kError.withValues(alpha: 0.15),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'DELETE',
              style: GoogleFonts.shareTechMono(
                  color: kError, fontSize: 11, letterSpacing: 2),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.delete_outline, color: kError, size: 18),
          ],
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: context.cCard,
            border: Border(
              left: const BorderSide(color: kPrimary, width: 3),
              top: BorderSide(color: kPrimary.withValues(alpha: 0.2), width: 1),
              right: BorderSide(color: kPrimary.withValues(alpha: 0.2), width: 1),
              bottom: BorderSide(color: kPrimary.withValues(alpha: 0.2), width: 1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Avatar
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    border: Border.all(color: kPrimary, width: 1),
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: GoogleFonts.shareTechMono(
                        color: kPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Title + username
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        credential.title,
                        style: GoogleFonts.shareTechMono(
                          color: context.cText,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (credential.username.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          credential.username,
                          style: GoogleFonts.shareTechMono(
                              color: context.cTextSub, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Category tag
                if (categoryName != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: kPrimary.withValues(alpha: 0.4), width: 1),
                    ),
                    child: Text(
                      categoryName!.toUpperCase(),
                      style: GoogleFonts.shareTechMono(
                          color: kPrimary, fontSize: 9, letterSpacing: 1),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],

                const Icon(Icons.chevron_right, color: kPrimary, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
