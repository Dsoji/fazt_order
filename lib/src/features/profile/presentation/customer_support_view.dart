import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/app_colors.dart';
import '../../../common/ui_helpers.dart';
import '../../../common/widgets/text_styles.dart';
import '../../order/chat_view.dart';

class CustomerSupportView extends StatelessWidget {
  const CustomerSupportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kcPrimaryNeutral950,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Customer Support",
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
              _buildListItem(
                icon: Iconsax.messages_2,
                title: "Chat",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ChatView()),
                  );
                },
              ),
              verticalSpaceTiny,
              SvgPicture.asset('asset/svgs/dotted_line.svg'),
              verticalSpaceTiny,
              _buildListItem(
                icon: Iconsax.sms,
                title: "Email",
                onTap: () {
                  // TODO: Implement Email support navigation
                },
              ),
              verticalSpaceTiny,
              SvgPicture.asset('asset/svgs/dotted_line.svg'),
              verticalSpaceTiny,
              _buildListItem(
                icon: Iconsax.instagram,
                title: "Instagram",
                onTap: () {
                  // TODO: Implement Instagram support navigation
                },
              ),
              verticalSpaceTiny,
              SvgPicture.asset('asset/svgs/dotted_line.svg'),
              verticalSpaceTiny,
              ListTile(
                leading: Padding(
                  padding: const EdgeInsets.only(left: 5.0),
                  child: SvgPicture.asset(
                    'asset/svgs/x.svg',
                    height: 20,
                    width: 20,
                  ),
                ),
                title: Text(
                  'X (Twitter)',
                  style: ktBodyRegularSize12.copyWith(
                    color: Colors.black,
                    fontSize: 14,
                    letterSpacing: 1,
                  ),
                ),
                onTap: () {
                  // TODO: Implement Instagram support navigation
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: kcPrimaryNeutral200,
        size: 24,
      ),
      title: Text(
        title,
        style: ktBodyRegularSize12.copyWith(
          color: Colors.black,
          fontSize: 14,
          letterSpacing: 1,
        ),
      ),
      onTap: onTap,
    );
  }
}
