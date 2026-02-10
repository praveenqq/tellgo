import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tellgo_app/responsive.dart';
import 'package:tellgo_app/screens/phone/view/how_to_activate_sheet.dart';

/// Optional: pass along anything you want from checkout (e.g., order summary)
class EnterNumberArgs {
  final String? countryHint; // e.g., "Kuwait"
  final String? defaultDial; // e.g., "+965"
  const EnterNumberArgs({this.countryHint, this.defaultDial});
}

class EnterNumberView extends StatefulWidget {
  final EnterNumberArgs? args;
  const EnterNumberView({super.key, this.args});

  @override
  State<EnterNumberView> createState() => _EnterNumberViewState();
}

class _EnterNumberViewState extends State<EnterNumberView> {
  String _value = '';

  static const int _minDigits = 8;
  static const int _maxDigits = 15;

  @override
  void initState() {
    super.initState();
    if ((widget.args?.defaultDial ?? '').isNotEmpty) {
      final dial = widget.args!.defaultDial!;
      if (_isDialCode(dial)) _value = dial;
    }
  }

  int get _digitCount => _value.replaceAll(RegExp(r'\D'), '').length;
  bool get _canSubmit => _digitCount >= _minDigits;

  bool _isDialCode(String s) => RegExp(r'^\+\d{1,4}$').hasMatch(s);

  void _tap(String key) {
    setState(() {
      if (key == '⌫') {
        if (_value.isNotEmpty) _value = _value.substring(0, _value.length - 1);
        return;
      }
      if (key == '+') {
        if (_value.isEmpty) _value = '+';
        return;
      }
      if (RegExp(r'^\d$').hasMatch(key)) {
        final digits = _digitCount;
        if (digits < _maxDigits) _value += key;
      }
    });
  }

  void _clearAll() => setState(() => _value = '');

  String _pretty(String input) {
    final b = StringBuffer();
    final hasPlus = input.startsWith('+');
    int i = 0;
    for (final ch in input.split('')) {
      if (hasPlus && i == 0 && ch == '+') {
        b.write('+');
        i++;
        continue;
      }
      if (!RegExp(r'\d').hasMatch(ch)) continue;
      b.write(ch);
      i++;
      if (hasPlus) {
        if (i == 4 || i == 6 || i == 8 || i == 10 || i == 12) b.write(' ');
      } else {
        if (i % 4 == 0) b.write(' ');
      }
    }
    return b.toString().trimRight();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) {
            final w = box.maxWidth;
            final sx = R.sxScale(w);
            final isMobile = R.isMobile(w);
            final contentMax =
                isMobile ? (w - 32) : (w < 720 ? (w - 32) : 560.0);

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentMax),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(
                    16 * sx,
                    12 * sx,
                    16 * sx,
                    24 * sx,
                  ),
                  children: [
                    Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white70,
                            size: 18,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 18),
                      ],
                    ),
                    SizedBox(height: 4 * sx),
                    Center(
                      child: Text(
                        'Enter Your Mobile Number to Receive\nYour QR Code & Invoice',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18 * sx,
                          height: 1.15,
                        ),
                      ),
                    ),
                    SizedBox(height: 28 * sx),
                    Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 14 * sx,
                          vertical: 6,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFF72629E),
                              width: 2,
                            ),
                          ),
                        ),
                        child: Text(
                          _value.isEmpty
                              ? '— — — —     — — — —'
                              : _pretty(_value),
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 22 * sx,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 18 * sx),
                    Center(
                      child: Text(
                        'To complete your eSIM activation, please\nenter your current mobile number',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 12.5 * sx,
                          height: 1.35,
                        ),
                      ),
                    ),
                    SizedBox(height: 22 * sx),

                    _DialPad(sx: sx, onKey: _tap, onLongPressClear: _clearAll),

                    SizedBox(height: 24 * sx),
                    const Divider(
                      color: Color(0xFF3A2E59),
                      thickness: 1,
                      height: 1,
                    ),
                    SizedBox(height: 20 * sx),

                    _whatsAppBlock(sx),
                    SizedBox(height: 14 * sx),
                    _privacyBlock(sx),

                    SizedBox(height: 18 * sx),
                    Center(
                      child: SizedBox(
                        width: 220 * sx,
                        height: 40 * sx,
                        child: OutlinedButton(
                          onPressed: () => showHowToActivateSheet(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF7C61C9)),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            textStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5 * sx,
                            ),
                          ),
                          child: const Text('How to Activate'),
                        ),
                      ),
                    ),
                    SizedBox(height: 16 * sx),

                    SizedBox(
                      width: double.infinity,
                      height: 30 * sx,
                      child: ElevatedButton(
                        onPressed:
                            _canSubmit ? () => context.go('/pinpad') : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C61C9),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10 * sx),
                          ),
                          textStyle: GoogleFonts.poppins(
                            fontWeight: FontWeight.w600,
                            fontSize: 13 * sx,
                          ),
                        ),
                        child: const Text('Go to Payment'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _whatsAppBlock(double sx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'You will instantly receive via WhatApp',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13 * sx,
              ),
            ),
            SizedBox(width: 4 * sx),
            _waDot(),
            Text(
              ':',
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
        SizedBox(height: 8 * sx),
        _bullet('Your digital invoice', sx),
        _bullet('Your eSIM activation QR code', sx),
        _bullet('Step-by-step installation guide', sx),
      ],
    );
  }

  Widget _privacyBlock(double sx) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your privacy matters:',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 13 * sx,
          ),
        ),
        SizedBox(height: 8 * sx),
        _bullet('Your number will only be used to send your order details', sx),
      ],
    );
  }

  Widget _bullet(String text, double sx) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6 * sx),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6 * sx),
            width: 6 * sx,
            height: 6 * sx,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 8 * sx),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
                fontSize: 12 * sx,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _waDot() {
    return Container(
      width: 16,
      height: 16,
      margin: const EdgeInsets.only(right: 2),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF25D366),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.chat_bubble, size: 10, color: Colors.white),
    );
  }
}

/* -------------------------------- Dial Pad ------------------------------- */

class _DialPad extends StatelessWidget {
  final double sx;
  final void Function(String key) onKey;
  final VoidCallback onLongPressClear;
  const _DialPad({
    required this.sx,
    required this.onKey,
    required this.onLongPressClear,
  });

  Widget _btn({
    required Widget child,
    VoidCallback? onTap,
    VoidCallback? onLongPress,
  }) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 76 * sx,
        height: 76 * sx,
        decoration: BoxDecoration(
          color: const Color(0xFFBDBDBD),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .25),
              blurRadius: 10 * sx,
              offset: Offset(0, 6 * sx),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  Widget _textKey(String t) => Text(
    t,
    style: GoogleFonts.poppins(
      color: Colors.black87,
      fontWeight: FontWeight.w700,
      fontSize: 26 * sx,
    ),
  );

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['+', '0', '⌫'],
    ];

    return Column(
      children: [
        for (final r in rows)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (final k in r)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10 * sx),
                  child: _btn(
                    child:
                        k == '⌫'
                            ? const Icon(
                              Icons.backspace_outlined,
                              size: 28,
                              color: Colors.black87,
                            )
                            : _textKey(k),
                    onTap: () => onKey(k),
                    onLongPress:
                        k == '⌫'
                            ? onLongPressClear // long-press backspace => clear all
                            : (k == '0'
                                ? () => onKey('+')
                                : null), // long-press 0 => '+'
                  ),
                ),
            ],
          ),
      ],
    );
  }
}
