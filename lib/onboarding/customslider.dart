import 'package:flutter/material.dart';
import 'package:naseej/core/constant/color.dart';
import 'package:naseej/static.dart';

class CustomSliderOnBoarding extends StatelessWidget {
  final PageController pageController;
  final Function(int) onPageChanged;

  const CustomSliderOnBoarding({
    Key? key,
    required this.pageController,
    required this.onPageChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: pageController,
      onPageChanged: onPageChanged,
      itemCount: onBoardingList.length,
      itemBuilder: (context, i) => Column(
        children: [
          Image.asset(
            onBoardingList[i].image!,
            height: MediaQuery.of(context).size.width / 1.1,
            fit: BoxFit.fill,
          ),
          const SizedBox(height: 60),
          Text(
            onBoardingList[i].title!,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              color: AppColor.black,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            alignment: Alignment.center,
            child: Text(
              onBoardingList[i].body!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                height: 2,
                color: AppColor.grey,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}