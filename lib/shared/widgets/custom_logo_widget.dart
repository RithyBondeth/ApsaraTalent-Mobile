import 'package:apsaratalent_mobile/shared/constants/asset_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CustomLogoWidget extends StatelessWidget {
  final bool withoutTitle;
  final double width;
  final double height;
  const CustomLogoWidget({
    super.key,
    this.withoutTitle = false,
    this.width = 150,
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      withoutTitle
          ? AppAssetContant.logoWithoutTitle
          : AppAssetContant.logoForWhiteBg,
      height: height,
      width: width,
    );
  }
}
