import 'package:flutter/material.dart';

/// Required NLM attribution notice for screens that use RxTerms or ICD-10-CM
/// APIs. Per NLM Terms of Service, products using NLM data must include this
/// attribution and must not imply NLM endorsement.
class NlmAttribution extends StatelessWidget {
  const NlmAttribution({super.key});

  static const attributionText =
      'This product uses publicly available data courtesy of the U.S. '
      'National Library of Medicine (NLM), National Institutes of Health, '
      'Department of Health and Human Services; NLM is not responsible for '
      'the product and does not endorse or recommend this or any other '
      'product.';

  static const medicalDisclaimer =
      'NLM does not provide specific medical advice. Consult with a '
      'qualified physician for medical advice.';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        'Source: U.S. National Library of Medicine. $medicalDisclaimer',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontSize: 10,
            ),
      ),
    );
  }
}
