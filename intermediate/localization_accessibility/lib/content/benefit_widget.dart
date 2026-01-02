import 'package:flutter/material.dart';
import 'package:localization_accessibility/common.dart';
import 'package:localization_accessibility/content/benefit_table.dart';

class BenefitWidget extends StatelessWidget {
  const BenefitWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          AppLocalizations.of(context)!.benefitTitle,
          style: Theme.of(context).textTheme.headlineSmall,
          softWrap: true,
          overflow: TextOverflow.fade,
          textAlign: TextAlign.center,
        ),
        const Padding(padding: EdgeInsets.all(8.0), child: BenefitTable()),
      ],
    );
  }
}
