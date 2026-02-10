import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Call this from anywhere (e.g. the phone screen)
Future<void> showHowToActivateSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _HowToActivateSheet(),
  );
}

class _HowToActivateSheet extends StatefulWidget {
  const _HowToActivateSheet();

  @override
  State<_HowToActivateSheet> createState() => _HowToActivateSheetState();
}

class _HowToActivateSheetState extends State<_HowToActivateSheet> {
  bool isIOS = true;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final sx = (w / 390).clamp(0.80, 1.35);

        return SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: EdgeInsets.fromLTRB(12 * sx, 6 * sx, 12 * sx, 12 * sx),
              padding: EdgeInsets.fromLTRB(14 * sx, 14 * sx, 14 * sx, 10 * sx),
              decoration: BoxDecoration(
                color: const Color(0xFF1B0E37),
                borderRadius: BorderRadius.circular(16 * sx),
                border: Border.all(color: const Color(0xFF3A2E59)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .35),
                    blurRadius: 24 * sx,
                    offset: Offset(0, 10 * sx),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'How To Activate',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 18 * sx,
                          ),
                        ),
                      ),
                      InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () => Navigator.pop(context),
                        child: Padding(
                          padding: EdgeInsets.all(6 * sx),
                          child: Icon(
                            Icons.close,
                            color: Colors.white70,
                            size: 22 * sx,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6 * sx),
                  const Divider(color: Color(0xFF3A2E59), height: 1),
                  SizedBox(height: 12 * sx),

                  Container(
                    padding: EdgeInsets.all(4 * sx),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A1D55),
                      borderRadius: BorderRadius.circular(22 * sx),
                      border: Border.all(color: const Color(0xFF3A2E59)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _Segment(
                            label: 'iPhone',
                            selected: isIOS,
                            sx: sx,
                            onTap: () => setState(() => isIOS = true),
                          ),
                        ),
                        Expanded(
                          child: _Segment(
                            label: 'Android',
                            selected: !isIOS,
                            sx: sx,
                            onTap: () => setState(() => isIOS = false),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 12 * sx),

                  Flexible(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14 * sx),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF241445),
                          borderRadius: BorderRadius.circular(14 * sx),
                          border: Border.all(color: const Color(0xFF3A2E59)),
                        ),
                        child: _StepsScroll(sx: sx, isIOS: isIOS),
                      ),
                    ),
                  ),

                  SizedBox(height: 10 * sx),

                  SizedBox(
                    width: double.infinity,
                    height: 48 * sx,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C61C9),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10 * sx),
                        ),
                        textStyle: GoogleFonts.poppins(
                          fontWeight: FontWeight.w700,
                          fontSize: 14 * sx,
                        ),
                      ),
                      child: const Text('Done'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final double sx;
  final VoidCallback onTap;
  const _Segment({
    required this.label,
    required this.selected,
    required this.sx,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18 * sx),
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(vertical: 8 * sx),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18 * sx),
          gradient:
              selected
                  ? const LinearGradient(
                    colors: [Color(0xFF8A6BCF), Color(0xFF7A61C8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                  : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
            fontSize: 13 * sx,
          ),
        ),
      ),
    );
  }
}

class _StepsScroll extends StatelessWidget {
  final double sx;
  final bool isIOS;
  const _StepsScroll({required this.sx, required this.isIOS});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(14 * sx, 14 * sx, 14 * sx, 20 * sx),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _WarningCard(sx: sx),
          SizedBox(height: 14 * sx),
          _BilingualHeading(
            sx: sx,
            left: 'How to Add Your eSIM\nvia QR Code',
            right: 'كيفية إضافة شريحة الإلكترونية\nعبر رمز QR',
          ),
          SizedBox(height: 8 * sx),
          _SubNote(
            sx: sx,
            text:
                isIOS
                    ? '- For iPhone (iOS 13 and above):'
                    : '- For Android (Android 10 and above):',
          ),
          SizedBox(height: 10 * sx),
          _Muted(
            sx: sx,
            text:
                'You can scan the QR code to watch a video explaining how to activate the eSIM or follow the steps below.',
          ),
          SizedBox(height: 14 * sx),
          _QrBlock(sx: sx),
          SizedBox(height: 14 * sx),
          _StepRow(
            sx: sx,
            number: 1,
            left:
                'Go to Settings\n► Tap Cellular or Mobile Data\n► Or open “Camera App”, then Scan the QR Code provided by Tellgo to avoid the following step till “step 5”.',
            right:
                'انتقل إلى الإعدادات\n► اضغط على "البيانات الخلوية" أو "البيانات المحمولة"\n► أو افتح تطبيق الكاميرا لمسح رمز QR المقدم من Tellgo لتجاوز الخطوات حتى "الخطوة 5".',
            trailing: const _PhoneShot(),
          ),
          _StepRow(
            sx: sx,
            number: 2,
            left: 'Tap “Add eSIM”.',
            right: 'اضغط على "إضافة شريحة إلكترونية".',
            trailing: const _PhoneShot(),
          ),
          _StepRow(
            sx: sx,
            number: 3,
            left: 'Tap “Use QR Code”.',
            right: 'اضغط على "استخدام رمز QR".',
            trailing: const _PhoneShotWide(),
          ),
          _StepRow(
            sx: sx,
            number: 4,
            left: 'Scan the QR Code provided by Tellgo.',
            right: 'امسح رمز QR المقدم من Tellgo.',
            trailing: const _QrMini(),
          ),
          _StepRow(
            sx: sx,
            number: 5,
            left: 'Tap “Allow”.',
            right: 'اضغط على "السماح".',
            trailing: const _DialogShot(),
          ),
          _StepRow(
            sx: sx,
            number: 6,
            left: 'It will take from 1 to 3 minutes to activate.',
            right: 'سيستغرق التفعيل من دقيقة إلى ثلاث دقائق.',
            trailing: const _TwinActivateShots(),
          ),
          SizedBox(height: 16 * sx),
          _StepRow(
            sx: sx,
            number: 7,
            left: 'Choose a name for the eSIM (Travel, Tellgo or e.g.).',
            right: 'اختر اسماً للشريحة الإلكترونية (مثل سفر أو Tellgo).',
            trailing: const _PhoneShotWide(),
          ),
          _StepRow(
            sx: sx,
            number: 8,
            left: 'Select which line to use for data, calls, and iMessage.',
            right: 'حدد الخط الذي تريد استخدامه للبيانات والمكالمات والرسائل.',
            trailing: const _PhoneShot(),
          ),
          SizedBox(height: 8 * sx),
          _Muted(
            sx: sx,
            text:
                'You can see your Primary SIM and the added eSIM in Settings > Cellular > SIMs.',
          ),
          SizedBox(height: 18 * sx),
          _BilingualHeading(
            sx: sx,
            left: 'To turn on/off you SIM',
            right: 'لتشغيل/إيقاف تشغيل بطاقتك',
          ),
          SizedBox(height: 10 * sx),
          const _TwinToggleShots(),
          SizedBox(height: 18 * sx),
          _BilingualHeading(
            sx: sx,
            left: 'How to Add Your eSIM\nManually (No QR Code)',
            right: 'كيفية إضافة الشريحة الإلكترونية\nيدوياً (بدون رمز QR)',
          ),
          SizedBox(height: 10 * sx),
          _StepRow(
            sx: sx,
            number: 1,
            left: 'Go to Settings ► Tap Cellular or Mobile Data.',
            right:
                'اذهب إلى الإعدادات ► اضغط على البيانات الخلوية أو البيانات المحمولة.',
            trailing: const _PhoneShot(),
          ),
          _StepRow(
            sx: sx,
            number: 2,
            left: 'Tap “Add eSIM”.',
            right: 'اضغط على "إضافة شريحة إلكترونية".',
            trailing: const _PhoneShot(),
          ),
          _StepRow(
            sx: sx,
            number: 3,
            left: 'Tap “Use QR Code”.',
            right: 'اضغط على "استخدام رمز QR".',
            trailing: const _PhoneShotWide(),
          ),
          _StepRow(
            sx: sx,
            number: 4,
            left: 'Tap “Enter Details Manually”.',
            right: 'اضغط على "أدخل التفاصيل يدوياً".',
            trailing: const _DialogShot(),
          ),
          _StepRow(
            sx: sx,
            number: 5,
            left:
                'Fill in the information:\n• SM-DP+ Address\n• Activation Code\n• (Optional) Confirmation Code',
            right:
                'املأ المعلومات:\n• عنوان SM-DP+\n• رمز التفعيل\n• (اختياري) رمز التأكيد',
            trailing: const _PhoneShot(),
          ),
          _StepRow(
            sx: sx,
            number: 6,
            left: 'Tap Next, then follow prompts.',
            right: 'اضغط التالي ثم اتبع التعليمات.',
            trailing: const _DialogShot(),
          ),
          SizedBox(height: 6 * sx),
        ],
      ),
    );
  }
}

/* ------------------------------ small widgets ------------------------------ */

class _WarningCard extends StatelessWidget {
  final double sx;
  const _WarningCard({required this.sx});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12 * sx),
      decoration: BoxDecoration(
        color: const Color(0xFF2E1F63),
        borderRadius: BorderRadius.circular(12 * sx),
        border: Border.all(color: const Color(0xFF3A2E59)),
      ),
      child: Row(
        children: [
          Container(
            width: 40 * sx,
            height: 40 * sx,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE08A),
              borderRadius: BorderRadius.circular(10 * sx),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.warning_amber_rounded,
              color: const Color(0xFF1B0E37),
              size: 28 * sx,
            ),
          ),
          SizedBox(width: 12 * sx),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'WARNING! Make sure you have internet\non your device to activate your eSIM.',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 12 * sx,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 4 * sx),
                Text(
                  'تأكد من اتصال جهازك بالإنترنت لتفعيل الشريحة الإلكترونية',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 11 * sx,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BilingualHeading extends StatelessWidget {
  final String left, right;
  final double sx;
  const _BilingualHeading({
    required this.left,
    required this.right,
    required this.sx,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14 * sx,
              height: 1.25,
            ),
          ),
        ),
        SizedBox(width: 8 * sx),
        Expanded(
          child: Text(
            right,
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14 * sx,
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }
}

class _SubNote extends StatelessWidget {
  final double sx;
  final String text;
  const _SubNote({required this.sx, required this.text});
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 12 * sx,
      ),
    );
  }
}

class _Muted extends StatelessWidget {
  final double sx;
  final String text;
  const _Muted({required this.sx, required this.text});
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: Colors.white70,
        fontSize: 11.5 * sx,
        height: 1.35,
      ),
    );
  }
}

class _QrBlock extends StatelessWidget {
  final double sx;
  const _QrBlock({required this.sx});
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(14 * sx),
        decoration: BoxDecoration(
          color: const Color(0xFF2B1E5F),
          borderRadius: BorderRadius.circular(14 * sx),
          border: Border.all(color: const Color(0xFF3A2E59)),
        ),
        child: Icon(
          Icons.qr_code_2_rounded,
          size: 120 * sx,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final int number;
  final String left, right;
  final Widget trailing;
  final double sx;
  const _StepRow({
    required this.sx,
    required this.number,
    required this.left,
    required this.right,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10 * sx),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StepBadge(n: number, sx: sx),
          SizedBox(width: 10 * sx),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  left,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12 * sx,
                    height: 1.35,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6 * sx),
                Text(
                  right,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12 * sx,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10 * sx),
          trailing,
        ],
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  final int n;
  final double sx;
  const _StepBadge({required this.n, required this.sx});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24 * sx,
      height: 24 * sx,
      decoration: BoxDecoration(
        color: const Color(0xFF7C61C9),
        borderRadius: BorderRadius.circular(6 * sx),
      ),
      alignment: Alignment.center,
      child: Text(
        '$n',
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 12 * sx,
        ),
      ),
    );
  }
}

/* --------------------- simple placeholder “screenshots” -------------------- */

class _PhoneShot extends StatelessWidget {
  const _PhoneShot();
  @override
  Widget build(BuildContext context) {
    return _shotBox(90, 120);
  }
}

class _PhoneShotWide extends StatelessWidget {
  const _PhoneShotWide();
  @override
  Widget build(BuildContext context) {
    return _shotBox(120, 80);
  }
}

class _DialogShot extends StatelessWidget {
  const _DialogShot();
  @override
  Widget build(BuildContext context) {
    return _shotBox(110, 80);
  }
}

class _TwinActivateShots extends StatelessWidget {
  const _TwinActivateShots();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _shotBox(70, 110),
        const SizedBox(width: 8),
        _shotBox(70, 110),
      ],
    );
  }
}

class _TwinToggleShots extends StatelessWidget {
  const _TwinToggleShots();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _shotBox(90, 120),
        const SizedBox(width: 10),
        _shotBox(90, 120),
      ],
    );
  }
}

class _QrMini extends StatelessWidget {
  const _QrMini();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 84,
      decoration: BoxDecoration(
        color: const Color(0xFF2B1E5F),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF3A2E59)),
      ),
      alignment: Alignment.center,
      child: const Icon(Icons.qr_code_2_rounded, color: Colors.white, size: 48),
    );
  }
}

Widget _shotBox(double w, double h) {
  return Container(
    width: w,
    height: h,
    decoration: BoxDecoration(
      color: const Color(0xFF2B1E5F),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFF3A2E59)),
    ),
    alignment: Alignment.center,
    child: const Icon(Icons.image_rounded, color: Colors.white38),
  );
}
