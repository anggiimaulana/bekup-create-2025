import 'package:flutter/material.dart';
import 'package:localization_accessibility/common.dart';

class CostWidget extends StatelessWidget {
  const CostWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)!.costTitle,
            style: Theme.of(context).textTheme.headlineSmall,
            softWrap: true,
            overflow: TextOverflow.fade,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            AppLocalizations.of(context)!.costSubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            softWrap: true,
            overflow: TextOverflow.fade,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
