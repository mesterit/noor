import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart' as flutter;
import 'package:webview_flutter/webview_flutter.dart';

import '../../common/config.dart';
import '../../common/constants.dart';
import '../../common/tools.dart';
import '../../generated/l10n.dart';
import '../../models/entities/user.dart';
import '../../models/user_model.dart';
import '../../screens/common/app_bar_mixin.dart';
import '../html/index.dart';
import 'webview_inapp.dart';

mixin WebviewMixin {
  /// Return true when overridden and the navigation in webview should stop.
  Future<bool> overrideWebNavigation(String url) async {
    /// open the normal web link
    var isHttp = 'http';
    if (url.startsWith(isHttp)) {
      return false;
    }

    if (url.startsWith('intent://') && url.contains('scheme=')) {
      final intentInfo = url.substring(url.indexOf('scheme='));
      final scheme = intentInfo.substring(
          intentInfo.indexOf('scheme=') + 7, intentInfo.indexOf(';'));
      final newUrl = url.replaceFirst('intent://', '$scheme://');
      await Tools.launchURL(
        newUrl,
        mode: LaunchMode.externalNonBrowserApplication,
      );
      return true;
    }

    /// open external app link
    await Tools.launchURL(
      url,
      mode: LaunchMode.externalNonBrowserApplication,
    );

    return true;
  }

  Future<NavigationDecision> getNavigationDelegate(
      NavigationRequest request) async {
    final url = request.url;
    printLog('[WebView] getNavigationDelegate: $url');
    final overridden = await overrideWebNavigation(url);

    if (overridden) {
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }
}

class WebView extends StatefulWidget {
  final String? url;
  final String? title;
  final AppBar? appBar;
  final bool enableForward;
  final bool enableBackward;
  final bool enableClose;
  final Function(String url)? onPageFinished;
  final Function? onClosed;
  final String script;
  final Map<String, String>? headers;
  final String? routeName;
  final bool hideNewAppBar;
  final bool showAppBar;
  final bool showLoading;

  const WebView({
    Key? key,
    this.title,
    required this.url,
    this.appBar,
    this.onPageFinished,
    this.onClosed,
    this.script = '',
    this.headers,
    this.enableForward = true,
    this.enableBackward = true,
    this.enableClose = true,
    this.routeName,
    this.hideNewAppBar = false,
    this.showAppBar = true,
    this.showLoading = true,
  })  : assert(
          !(!showAppBar && (enableForward || enableBackward || enableClose)),
          'Cannot hide app bar if one of the following options EnableForward or EnableBackward or EnableClose is enabled',
        ),
        super(key: key);

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> with WebviewMixin, AppBarMixin {
  int selectedIndex = 1;
  bool isLoading = true;
  String html = '';
  String get url {
    var value = widget.url ?? '';

    final uri = value.toUri();
    if (uri != null && uri.scheme.isEmpty) {
      value = 'https://$value';
    }

    if (kAdvanceConfig.alwaysClearWebViewCache) {
      value =
          value.addUrlQuery('dummy=${DateTime.now().millisecondsSinceEpoch}');
    }

    return value;
  }

  User? get user => Provider.of<UserModel>(context, listen: true).user;
  late final WebViewController controller;

  flutter.WebViewController? _controller;

  final Set<foundation.Factory<OneSequenceGestureRecognizer>>
      gestureRecognizers = {
    const foundation.Factory(EagerGestureRecognizer.new)
  };

  void onFinishLoading() {
    setState(() {
      selectedIndex = 0;
    });
    controller.runJavaScript(widget.script.isEmptyOrNull
        ? kAdvanceConfig.webViewScript
        : widget.script);
  }

  void onTapBackButton(BuildContext buildContext) async {
    var value = await _controller?.canGoBack() ?? false;
    if (value) {
      await _controller?.goBack();
    } else if (!widget.enableClose && Navigator.canPop(context)) {
      widget.onClosed?.call();
      Navigator.of(context).pop();
    } else {
      Tools.showSnackBar(
          ScaffoldMessenger.of(buildContext), S.of(context).noBackHistoryItem);
    }
  }

  void onTapForwardButton(BuildContext buildContext) async {
    if (await _controller?.canGoForward() ?? false) {
      await _controller?.goForward();
    } else {
      Tools.showSnackBar(ScaffoldMessenger.of(buildContext),
          S.of(context).noForwardHistoryItem);
    }
  }

  void onTapCloseButton() async {
    widget.onClosed?.call();
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    if (isMacOS || isWindow) {
      httpGet(url.toString().toUri()!).then((response) {
        setState(() {
          html = response.body;
        });
      });
    }

    // Fixme: webview refactor
    // if (isAndroid) flutter.WebView.platform = flutter.SurfaceAndroidWebView();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              onFinishLoading();
            }
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) => widget.onPageFinished?.call(url),
          onWebResourceError: (WebResourceError error) {},
          // onNavigationRequest: (NavigationRequest request) {},
        ),
      )
      ..loadRequest(Uri.parse(url.toString()));

    super.initState();
  }

  @override
  void dispose() {
    if (kAdvanceConfig.alwaysClearWebViewCache) {
      _controller?.clearCache();
    }
    if (kAdvanceConfig.alwaysClearWebViewCookie) {
      WebViewCookieManager().clearCookies();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isMacOS || isWindow) {
      return renderScaffold(
        routeName: widget.routeName ?? RouteList.webview,
        hideNewAppBar: widget.hideNewAppBar,
        secondAppBar: !widget.showAppBar
            ? null
            : widget.appBar ??
                AppBar(
                  backgroundColor: Theme.of(context).colorScheme.background,
                  elevation: 0.0,
                  centerTitle: true,
                  title: Text(
                    widget.title ?? '',
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontWeight: FontWeight.w600),
                  ),
                  actions: [
                    if (widget.enableClose)
                      IconButton(
                        onPressed: onTapCloseButton,
                        icon: const Icon(Icons.close, size: 20),
                      ),
                    const SizedBox(width: 10),
                  ],
                  leading: Builder(
                    builder: (buildContext) {
                      return Row(
                        children: [
                          if (widget.enableBackward)
                            IconButton(
                              icon: const Icon(Icons.arrow_back_ios, size: 20),
                              onPressed: () {
                                if (Navigator.canPop(context)) {
                                  Navigator.of(context).pop();
                                }
                              },
                            ),
                          if (widget.enableForward)
                            IconButton(
                              onPressed: () {},
                              icon:
                                  const Icon(Icons.arrow_forward_ios, size: 20),
                            ),
                        ],
                      );
                    },
                  ),
                ),
        child: SingleChildScrollView(
          child: HtmlWidget(html),
        ),
      );
    }

    /// is Mobile or Web
    if (!kIsWeb && kAdvanceConfig.inAppWebView) {
      return renderScaffold(
        routeName: widget.routeName ?? RouteList.webview,
        hideNewAppBar: widget.hideNewAppBar,
        child: WebViewInApp(
          url: url,
          overrideNavigation: overrideWebNavigation,
          title: widget.title,
          script: widget.script.isEmptyOrNull
              ? kAdvanceConfig.webViewScript
              : widget.script,
          headers: widget.headers,
          enableForward: widget.enableForward,
          enableBackward: widget.enableBackward,
          enableClose: widget.enableClose,
          onClosed: widget.onClosed,
          onUrlChanged: (String? url) {
            widget.onPageFinished?.call(url ?? '');
          },
          appBar: widget.appBar,
          showLoading: widget.showLoading,
        ),
      );
    }

    return renderScaffold(
      routeName: widget.routeName ?? RouteList.webview,
      hideNewAppBar: widget.hideNewAppBar,
      secondAppBar: !widget.showAppBar
          ? null
          : widget.appBar ??
              AppBar(
                backgroundColor: Theme.of(context).colorScheme.background,
                elevation: 0.0,
                centerTitle: true,
                title: Text(
                  widget.title ?? '',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                leadingWidth: 150,
                actions: [
                  if (widget.enableClose)
                    IconButton(
                      onPressed: onTapCloseButton,
                      icon: const Icon(Icons.close, size: 20),
                    ),
                  const SizedBox(width: 10),
                ],
                leading: Builder(
                  builder: (buildContext) {
                    return Row(
                      children: [
                        if (widget.enableBackward)
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, size: 20),
                            onPressed: () => onTapBackButton(buildContext),
                          ),
                        if (widget.enableForward)
                          IconButton(
                            onPressed: () => onTapForwardButton(buildContext),
                            icon: const Icon(Icons.arrow_forward_ios, size: 20),
                          ),
                      ],
                    );
                  },
                ),
              ),
      child: IndexedStack(
        index: selectedIndex,
        children: [
          Builder(builder: (BuildContext context) {
            return flutter.WebViewWidget(controller: controller);
          }),
          if (widget.showLoading)
            Center(
              child: kLoadingWidget(context),
            )
          else
            const SizedBox(),
        ],
      ),
    );
  }
}
