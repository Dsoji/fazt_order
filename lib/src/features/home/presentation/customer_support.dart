import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../common/app_colors.dart';
import '../../../common/ui_helpers.dart';
import '../../../common/widgets/text_styles.dart';

class CustomerSupportScreen extends StatelessWidget {
  const CustomerSupportScreen({super.key});

  static const _instagramUrl =
      'https://www.instagram.com/faztorder_?igsh=eTZwcnB1Y3puejg3&utm_source=qr';
  static const _xUrl = 'https://x.com/faztorder?s=21';
  static const _tiktokUrl =
      'https://www.tiktok.com/@faztorder?_r=1&_t=ZS-95qJlC8qFLZ';
  static const _whatsappUrl = 'https://wa.me/message/UA6TDMCE3RKFL1';

  Future<void> _open(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $url')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kcPrimaryNeutral950,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Customer Support',
          style: ktBodySemiBoldSize20.copyWith(
            fontSize: 20,
            color: Colors.black,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: kcPrimaryNeutral950,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
          decoration: BoxDecoration(
            color: kcWhite,
            borderRadius: BorderRadius.circular(25),
          ),
          child: ListView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _SocialTile(
                leading: const Icon(
                  Iconsax.instagram,
                  color: kcPrimaryNeutral200,
                  size: 24,
                ),
                title: 'Instagram',
                onTap: () => _open(context, _instagramUrl),
              ),
              verticalSpaceTiny,
              SvgPicture.asset('asset/svgs/dotted_line.svg'),
              verticalSpaceTiny,
              _SocialTile(
                leading: Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: SvgPicture.asset(
                    'asset/svgs/x.svg',
                    height: 20,
                    width: 20,
                  ),
                ),
                title: 'X (Twitter)',
                onTap: () => _open(context, _xUrl),
              ),
              verticalSpaceTiny,
              SvgPicture.asset('asset/svgs/dotted_line.svg'),
              verticalSpaceTiny,
              _SocialTile(
                leading: SvgPicture.asset(
                  'asset/svgs/tiktok.svg',
                  height: 22,
                  width: 22,
                  colorFilter: const ColorFilter.mode(
                    kcPrimaryNeutral200,
                    BlendMode.srcIn,
                  ),
                ),
                title: 'TikTok',
                onTap: () => _open(context, _tiktokUrl),
              ),
              verticalSpaceTiny,
              SvgPicture.asset('asset/svgs/dotted_line.svg'),
              verticalSpaceTiny,
              _SocialTile(
                leading: SvgPicture.asset(
                  'asset/svgs/whatsapp.svg',
                  height: 22,
                  width: 22,
                  colorFilter: const ColorFilter.mode(
                    kcPrimaryNeutral200,
                    BlendMode.srcIn,
                  ),
                ),
                title: 'WhatsApp',
                onTap: () => _open(context, _whatsappUrl),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialTile extends StatelessWidget {
  const _SocialTile({
    required this.leading,
    required this.title,
    required this.onTap,
  });

  final Widget leading;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 28,
        height: 28,
        child: Center(child: leading),
      ),
      title: Text(
        title,
        style: ktBodyRegularSize12.copyWith(
          color: Colors.black,
          fontSize: 14,
          letterSpacing: 1,
        ),
      ),
      trailing: const Icon(
        Iconsax.arrow_right_3,
        color: kcPrimaryNeutral200,
        size: 18,
      ),
      onTap: onTap,
    );
  }
}
