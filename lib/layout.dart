/*
 Group Members

223000656 Magoro O
223000009 Sibei P
217010287 tsolo SE

222024787 Matamane TG

 */
import 'package:flutter/material.dart';

import 'package:login_form/reg.dart';

class Layout extends StatelessWidget {
  const Layout({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(

      builder: (context,dimensions){

        final width= dimensions.maxWidth /1.5;
        final height=dimensions.maxHeight /3;

        return  Center(
          child: SizedBox(
            width: width,
            height: height,
            child: const RegForm(),
          ),
        );
      },
    );
  }
}