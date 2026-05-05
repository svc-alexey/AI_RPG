import 'package:ai_prg/src/app/aether_shell.dart';
import 'package:ai_prg/src/app/app_localizations.dart';
import 'package:ai_prg/src/features/chat/application/chat_controller.dart';
import 'package:ai_prg/src/features/map/presentation/map_screen.dart';
import 'package:ai_prg/src/features/settings/presentation/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const ChatAppBar({
    required this.campaignId,
    required this.wide,
    required this.scaffoldKey,
    required this.onMenu,
    required this.onHome,
    required this.onSave,
    super.key,
  });

  final String campaignId;
  final bool wide;
  final GlobalKey<ScaffoldState> scaffoldKey;
  final VoidCallback? onMenu;
  final VoidCallback onHome;
  final VoidCallback onSave;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final title = ref.watch(
      chatControllerProvider(campaignId).select((c) => c.campaign?.title),
    );
    final setting = ref.watch(
      chatControllerProvider(campaignId).select((c) => c.campaign?.setting),
    );
    final controller = ref.read(chatControllerProvider(campaignId).notifier);

    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            title ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.playfairDisplay(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              color: AetherPalette.textPrimary,
            ),
          ),
          if (setting != null)
            Text(
              l10n.settingLabel(setting),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AetherPalette.textDim,
                fontSize: 11,
              ),
            ),
        ],
      ),
      bottom: const PreferredSize(
        preferredSize: Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 1,
          color: AetherPalette.panelBorderSolid,
        ),
      ),
      leading: wide
          ? null
          : _ChatChromeIconButton(
              icon: Icons.menu_rounded,
              tooltip: l10n.menuTooltip,
              onPressed: onMenu ?? () {},
            ),
      actions: <Widget>[
        _ChatChromeIconButton(
          icon: Icons.map_outlined,
          tooltip: l10n.mapTooltip,
          onPressed: () {
            final campaign = controller.campaign;
            if (campaign == null) return;
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => MapScreen(
                  campaignId: campaign.id,
                  campaignTitle: campaign.title,
                ),
              ),
            );
          },
        ),
        _ChatChromeIconButton(
          icon: Icons.bookmark_add_outlined,
          tooltip: l10n.saveTooltip,
          onPressed: onSave,
        ),
        _ChatChromeIconButton(
          icon: Icons.tune_rounded,
          tooltip: l10n.settingsTooltip,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const SettingsScreen(),
              ),
            );
          },
        ),
        _ChatChromeIconButton(
          icon: Icons.home_outlined,
          tooltip: l10n.exitToMainMenu,
          onPressed: onHome,
        ),
      ],
    );
  }
}

class _ChatChromeIconButton extends StatefulWidget {
  const _ChatChromeIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;

  @override
  State<_ChatChromeIconButton> createState() => _ChatChromeIconButtonState();
}

class _ChatChromeIconButtonState extends State<_ChatChromeIconButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 2),
    child: Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onPressed,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _hover
                      ? AetherPalette.accent.withValues(alpha: 0.35)
                      : AetherPalette.panelBorderSolid,
                ),
                color: AetherPalette.backgroundElevated,
              ),
              child: Icon(
                widget.icon,
                size: 18,
                color: _hover
                    ? AetherPalette.accentHover
                    : AetherPalette.textMuted,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
