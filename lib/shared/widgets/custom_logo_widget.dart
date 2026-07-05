import 'package:apsaratalent_mobile/core/constants/asset_path_constant.dart';
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
          ? AppAssetPathContant.logoWithoutTitle
          : AppAssetPathContant.logoForWhiteBg,
      height: height,
      width: width,
    );
  }
}
