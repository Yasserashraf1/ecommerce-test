import 'package:flutter/material.dart';
import 'package:naseej/core/functions/checkinternet.dart';
import 'package:naseej/core/constant/color.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Widget that shows internet connection status
class InternetCheckerWidget extends StatefulWidget {
  final Widget child;
  final bool showOnlineMessage;

  const InternetCheckerWidget({
    Key? key,
    required this.child,
    this.showOnlineMessage = false,
  }) : super(key: key);

  @override
  State<InternetCheckerWidget> createState() => _InternetCheckerWidgetState();
}

class _InternetCheckerWidgetState extends State<InternetCheckerWidget> {
  bool _isOnline = true;
  bool _showBanner = false;

  @override
  void initState() {
    super.initState();
    _checkInitialConnection();
    _listenToConnectionChanges();
  }

  void _checkInitialConnection() async {
    bool isConnected = await InternetChecker().hasConnection();
    if (mounted) {
      setState(() {
        _isOnline = isConnected;
        _showBanner = !isConnected;
      });
    }
  }

  void _listenToConnectionChanges() {
    // FIXED: Handle List<ConnectivityResult> instead of single ConnectivityResult
    InternetChecker().connectivityStream.listen((List<ConnectivityResult> results) async {
      // Check if any result is not 'none'
      bool hasConnectivity = results.any((result) => result != ConnectivityResult.none);

      if (hasConnectivity) {
        // Verify actual internet access
        bool isConnected = await InternetChecker().checkInternet();

        if (mounted) {
          setState(() {
            if (_isOnline != isConnected) {
              _isOnline = isConnected;
              _showBanner = true;

              // Hide banner after 3 seconds if online
              if (isConnected && widget.showOnlineMessage) {
                Future.delayed(Duration(seconds: 3), () {
                  if (mounted) {
                    setState(() {
                      _showBanner = false;
                    });
                  }
                });
              }
            }
          });
        }
      } else {
        // No connectivity at all
        if (mounted) {
          setState(() {
            _isOnline = false;
            _showBanner = true;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,

        // Connection status banner
        if (_showBanner)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Material(
              elevation: 8,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isOnline
                        ? [AppColor.successColor, AppColor.successColor.withOpacity(0.8)]
                        : [AppColor.warningColor, AppColor.warningColor.withOpacity(0.8)],
                  ),
                ),
                child: SafeArea(
                  bottom: false,
                  child: Row(
                    children: [
                      Icon(
                        _isOnline ? Icons.wifi : Icons.wifi_off,
                        color: Colors.white,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _isOnline
                              ? 'Back online'
                              : 'No internet connection',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (!_isOnline)
                        TextButton(
                          onPressed: () async {
                            bool isConnected = await InternetChecker().checkInternet();
                            if (mounted) {
                              setState(() {
                                _isOnline = isConnected;
                                if (isConnected) {
                                  Future.delayed(Duration(seconds: 2), () {
                                    if (mounted) {
                                      setState(() {
                                        _showBanner = false;
                                      });
                                    }
                                  });
                                }
                              });
                            }
                          },
                          child: Text(
                            'Retry',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (_isOnline)
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _showBanner = false;
                            });
                          },
                          icon: Icon(Icons.close, color: Colors.white, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}