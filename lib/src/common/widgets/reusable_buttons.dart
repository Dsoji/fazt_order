import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class FullButton extends StatelessWidget {
  final String text;
  final Color color;
  final double width;
  final double height;
  final Color textColor;
  final VoidCallback onPressed;
  final double fontSize;
  final bool isLoading;

  const FullButton({
    super.key,
    required this.text,
    required this.width,
    required this.height,
    required this.onPressed,
    required this.color,
    required this.textColor,
    this.fontSize = 16,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onPressed,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),
          color: isLoading ? color.withOpacity(0.7) : color,
        ),
        child: Center(
          child: isLoading
              ? const CupertinoActivityIndicator(radius: 12)
              : Text(
                  text,
                  style: TextStyle(
                    color: textColor,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}

class OutlinButton extends StatelessWidget {
  final String text;
  final Color color;
  final Color bgColor;
  final double width;
  final double height;
  final VoidCallback onPressed;
  final double fontSize;

  const OutlinButton({
    super.key,
    required this.text,
    required this.width,
    required this.height,
    required this.onPressed,
    required this.color,
    required this.bgColor,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: color)),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class OutlinIconButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final double width;
  final double height;
  final double radius;
  final double fontSize;
  final VoidCallback onPressed;

  const OutlinIconButton({
    super.key,
    required this.text,
    required this.width,
    required this.height,
    required this.onPressed,
    required this.color,
    required this.bgColor,
    required this.icon,
    this.fontSize = 16,
    this.radius = 15,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: color)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const Gap(4),
            Text(
              text,
              style: TextStyle(
                  color: color,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class ImgButton extends StatelessWidget {
  final double fontSize;
  final String text;
  final String image;
  final Color color;
  final Color bgColor;
  final double width;
  final double height;
  final VoidCallback onPressed;

  const ImgButton({
    super.key,
    required this.width,
    required this.height,
    required this.onPressed,
    required this.color,
    required this.image,
    required this.bgColor,
    this.fontSize = 16,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              height: 20,
              width: 20,
              image,
            ),
            const Gap(8),
            Text(
              text,
              style: TextStyle(
                  color: color,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

// class TextIconButton extends StatelessWidget {
//   final IconData icon;
//   final Color color;
//   final Color highcolor;
//   final double? width;
//   final double? height;
//   final String text;
//   final Function()? onPressed;

//   const TextIconButton(
//       {Key? key,
//       this.width,
//       required this.icon,
//       this.onPressed,
//       this.height,
//       required this.color,
//       required this.highcolor,
//       required this.text})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onPressed,
//       child: Container(
//         height: height,
//         width: width,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(4),
//           color: highcolor,
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Center(
//             child: Row(
//               children: [
//                 Icon(
//                   icon,
//                   color: color,
//                 ),
//                 const Gap(8),
//                 Text(
//                   text,
//                   style: TextStyle(
//                     color: color,
//                     fontSize: 15,
//                     fontFamily: 'Clash Grotesk Variable',
//                     fontWeight: FontWeight.w500,
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class TextOutlinIconButton extends StatelessWidget {
//   final IconData icon;
//   final Color color;
//   final Color highcolor;
//   final double? width;
//   final double? height;
//   final String text;
//   final Function()? onPressed;

//   const TextOutlinIconButton(
//       {Key? key,
//       this.width,
//       required this.icon,
//       this.onPressed,
//       this.height,
//       required this.color,
//       required this.highcolor,
//       required this.text})
//       : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       onTap: onPressed,
//       child: Container(
//         height: height,
//         width: width,
//         decoration: BoxDecoration(
//             color: highcolor,
//             borderRadius: BorderRadius.circular(15),
//             border: Border.all(color: color)),
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Center(
//             child: Row(
//               children: [
//                 Icon(
//                   icon,
//                   color: color,
//                 ),
//                 const Gap(8),
//                 Text(
//                   text,
//                   style: TextStyle(
//                     color: color,
//                     fontSize: 16,
//                     fontFamily: 'Clash Grotesk Variable',
//                     fontWeight: FontWeight.w500,
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class ImgBton extends StatelessWidget {
  final String image;
  final Color color;
  final Color bgColor;
  final double radius;
  final double width;
  final double height;
  final VoidCallback onPressed;

  const ImgBton(
      {super.key,
      required this.width,
      required this.height,
      required this.onPressed,
      required this.color,
      required this.image,
      required this.bgColor,
      this.radius = 4});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: color)),
        child: Center(
          child: Image.asset(
            height: 24,
            width: 24,
            image,
          ),
        ),
      ),
    );
  }
}
