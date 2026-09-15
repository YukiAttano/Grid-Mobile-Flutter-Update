import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:grid_frontend/widgets/buttons/copy_account_details_button.dart';
import 'package:grid_frontend/widgets/buttons/grid_close_button.dart';
import 'package:grid_frontend/widgets/buttons/open_discord_button.dart';
import 'package:grid_frontend/widgets/grid/grid_button.dart';
import 'package:grid_frontend/widgets/layout/gap.dart';
import 'package:url_launcher/url_launcher.dart';

import '../styles/grid_colors.dart';
import '../styles/tokens.dart';
import '../utilities/error_report.dart';

Future<void> showAccountDeletionSupportDialog(BuildContext context, {required String details}) async {
  await showDialog(
    context: context,
    builder: (context) {
      return AccountDeletionSupportDialog(details: details);
    },
  );
}

/// Dialog shown when a default-homeserver (passkey) account asks to be deleted.
///
/// There is no option to delete these accounts within the app.
/// Therefore, the only practical option for the app is
/// to provide the user with all the information the team needs,
/// as well as a way to contact the team.
///
/// Copying is the primary action.
/// Opening Discord is secondary.
class AccountDeletionSupportDialog extends StatefulWidget {
  final String details;

  const AccountDeletionSupportDialog({super.key, required this.details});

  @override
  State<AccountDeletionSupportDialog> createState() => _AccountDeletionSupportDialogState();
}

class _AccountDeletionSupportDialogState extends State<AccountDeletionSupportDialog> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: context.gridColors.surface,
          borderRadius: BorderRadius.circular(GridTokens.rXl),
          border: Border.all(color: context.gridColors.hairline),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.gridColors.dangerSoft,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(GridTokens.rXl),
                  topRight: Radius.circular(GridTokens.rXl),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.gridColors.danger.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(GridTokens.rMd),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.support_agent,
                      color: context.gridColors.danger,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'We\'ll delete it for you',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: context.gridColors.text,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Passkey accounts can\'t be deleted in the app yet. Copy '
                    'the details below and send them to us on Discord — we\'ll '
                    'remove your account and confirm when it\'s done.',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.45,
                      color: context.gridColors.text2,
                    ),
                  ),
                  Gap.big,
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: context.gridColors.surface2,
                      borderRadius: BorderRadius.circular(GridTokens.rMd),
                      border: Border.all(color: context.gridColors.hairline),
                    ),
                    child: SelectableText(
                      widget.details,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        fontFamily: 'monospace',
                        color: context.gridColors.text2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                children: [
                  CopyAccountDetailsButton(
                    copied: _copied,
                    onPressed: _onCopy,
                  ),
                  Gap.small,
                  OpenDiscordButton(
                    onPressed: _openDiscord,
                  ),
                  Gap.smaller,
                  GridCloseButton(
                    onPressed: () => _onClose(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // TODO(Yuki): Add error handling, might throw PlatformException
  Future<void> _onCopy() async {
    await Clipboard.setData(ClipboardData(text: widget.details));
    if (!mounted) return;
    setState(() => _copied = true);
  }

  // TODO(Yuki): centralize all url launches in separate file with error handling
  Future<void> _openDiscord() async {
    final uri = Uri.parse(gridDiscordInvite);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _onClose(BuildContext context) => Navigator.of(context).pop();
}
