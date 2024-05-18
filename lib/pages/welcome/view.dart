import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'index.dart';

class WelcomePage extends GetView<WelcomeController> {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: SizedBox(
            width: 360.w,
            height: 780.w,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage("assets/images/banner2.jpg"),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          Positioned(
                            bottom: 90,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 500),
                              opacity: 1.0,
                              child: ElevatedButton(
                                onPressed: () {
                                  controller.handleSignIn();
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.white),
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.black),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(10),
                                    ),
                                  ),
                                  side: MaterialStateProperty.all(
                                    const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                child: const Text('Continue'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

            ),
          ),
      );
  }
}
