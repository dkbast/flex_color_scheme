import 'package:flutter/material.dart';

enum HeaderCardCommand {
  /// No command to send.
  none,

  /// Send command to open the card.
  open,

  /// Send command to close the card.
  close,
}

/// A [Card] with a [ListTile] header that can be toggled via its trailing
/// widget to open and reveal more content provided via [child] in the card.
///
/// The open reveal is animated.
///
/// The ListTile and its revealed child are wrapped in a Card widget. The
/// [HeaderCard] is primarily designed to be placed on [Scaffold] using
/// its themed background color.
///
/// The header and background color of the [Card] get a slight primary color
/// blend added to its default surface color.
/// It always avoids the same color as the scaffold background, for both the
/// list tile heading and the card itself.
///
/// The widget is kept alive with [AutomaticKeepAliveClientMixin] so it does
/// not get dismissed and closed in scroll views. This "may" be a bit expensive
/// memory usage wise if this widget is used a lot in large lists. This widget
/// is intended for a limited amount of containers enabling showing and hiding
/// their content and keeping their open/close state alive. If you need one that
/// is more memory efficient, consider removing the
/// AutomaticKeepAliveClientMixin.
///
/// This is a Flutter "Universal" Widget that only depends on the SDK and
/// can be dropped into any application.
class HeaderCard extends StatefulWidget {
  const HeaderCard({
    Key? key,
    this.leading,
    this.title,
    this.subtitle,
    this.margin = EdgeInsets.zero,
    this.headerPadding,
    this.enabled = true,
    this.initialOpen = true,
    this.command,
    this.onChange,
    this.duration = const Duration(milliseconds: 200),
    this.color,
    this.boldTitle = true,
    this.child,
  }) : super(key: key);

  /// A widget to display before the title.
  ///
  /// Typically an [Icon] or a [CircleAvatar] widget.
  final Widget? leading;

  /// The primary content of the list tile.
  ///
  /// Typically a [Text] widget.
  ///
  /// This should not wrap. To enforce the single line limit, use
  /// [Text.maxLines].
  final Widget? title;

  /// Additional content displayed below the title.
  ///
  /// Typically a [Text] widget.
  final Widget? subtitle;

  /// The margins around the entire reveal list tile card.
  ///
  /// Defaults to [EdgeInsets.zero].
  final EdgeInsetsGeometry margin;

  /// The internal padding of the ListTile used as header.
  ///
  /// Insets the header [ListTile]'s contents:
  /// its [leading], [title], [subtitle].
  ///
  /// If null, `EdgeInsets.symmetric(horizontal: 16.0)` is used.
  final EdgeInsetsGeometry? headerPadding;

  /// Whether this list tile and card operation is interactive.
  final bool enabled;

  /// Initial state of the Card.
  ///
  /// Defaults to true;
  final bool initialOpen;

  /// Command to control if Card should Open or Close.
  final HeaderCardCommand? command;

  /// Callback called if the open/close state was changed.
  final ValueChanged<bool>? onChange;

  /// The duration of the show and hide animation of child.
  final Duration duration;

  /// Define this color to override that automatic adaptive background color.
  final Color? color;

  /// Make the title bold.
  ///
  /// The title Widget will be made bold if it is a [Text] widget,
  /// regardless of used style it has.
  final bool boldTitle;

  /// The child to be revealed.
  final Widget? child;

  @override
  _HeaderCardState createState() => _HeaderCardState();
}

class _HeaderCardState extends State<HeaderCard>
    with AutomaticKeepAliveClientMixin {
  late bool _open;

  // Must override wantKeepAlive, when using AutomaticKeepAliveClientMixin.
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _open = widget.initialOpen;
  }

  @override
  void didUpdateWidget(covariant HeaderCard oldWidget) {
    if (widget.command == HeaderCardCommand.open && !_open) {
      // setState(() {
      _open = true;
      // });
    }
    if (widget.command == HeaderCardCommand.close && _open) {
      // setState(() {
      _open = false;
      // });
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    // Must call super when using AutomaticKeepAliveClientMixin.
    super.build(context);

    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    // Dark mode needs stronger blends to be visible.
    final int blendFactor = isDark ? 3 : 2;

    // Make card slightly more colored than card background is
    Color cardColor = Color.alphaBlend(
        scheme.primary.withAlpha(2 * blendFactor), theme.cardColor);

    // Compute a header color with fixed primary blend, make it a stronger tint.
    Color headerColor =
        Color.alphaBlend(scheme.primary.withAlpha(7 * blendFactor), cardColor);

    // If card or its header color, is equal to scaffold background, we will
    // adjust both and make them more primary tinted.
    if (cardColor == theme.scaffoldBackgroundColor ||
        headerColor == theme.scaffoldBackgroundColor) {
      cardColor = Color.alphaBlend(
          scheme.primary.withAlpha(4 * blendFactor), cardColor);
      headerColor = Color.alphaBlend(
          scheme.primary.withAlpha(4 * blendFactor), headerColor);
    }
    // If it was header color that was equal, the same adjustment on card, may
    // have caused card body to become equal to scaffold background, let's
    // check for it and adjust only it once again if it happened. Very unlikely
    // that this happens, but it is possible.
    if (cardColor == theme.scaffoldBackgroundColor) {
      cardColor = Color.alphaBlend(
          scheme.primary.withAlpha(2 * blendFactor), cardColor);
    }

    // Force title widget for Card header to use opinionated bold style,
    // if we have a title, boldTitle is true and title was a Text.
    Widget? _title = widget.title;
    if (_title != null && _title is Text && widget.boldTitle) {
      final Text textTitle = _title;
      final TextStyle? _style = _title.style;
      final String _text = textTitle.data ?? '';
      _title = Text(
        _text,
        style: _style?.copyWith(fontWeight: FontWeight.bold) ??
            const TextStyle(fontWeight: FontWeight.bold),
      );
    }

    // If in rare occasion we had passed a background card color, we just
    // use that as color. This is intended to be an exception when we need
    // to present something in the card that must be on a certain color.
    // Like primary text theme, text must be on primary color.
    if (widget.color != null) cardColor = widget.color!;

    return Card(
      margin: widget.margin,
      color: cardColor,
      child: Column(
        children: <Widget>[
          Theme(
            data: theme.copyWith(cardColor: headerColor),
            child: Material(
              type: MaterialType.card,
              child: ListTile(
                contentPadding: widget.headerPadding,
                leading: widget.leading,
                title: _title,
                trailing: ExpandIcon(
                  size: 32,
                  isExpanded: _open,
                  padding: EdgeInsets.zero,
                  onPressed: (_) {
                    setState(() {
                      _open = !_open;
                    });
                    widget.onChange?.call(_open);
                  },
                ),
                onTap: () {
                  setState(() {
                    _open = !_open;
                  });
                  widget.onChange?.call(_open);
                },
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: widget.duration,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: child,
              );
            },
            child: (_open && widget.child != null)
                ? widget.child
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}