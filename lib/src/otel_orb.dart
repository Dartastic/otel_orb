// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_orb_suppression.dart';

const _tracerName = 'dartastic_otel_libs_orb';

Tracer _tracer() => OTel.tracerProvider().getTracer(_tracerName);

class OrbResult {
  const OrbResult({
    this.entityKind,
    this.entityId,
    this.customerId,
    this.externalCustomerId,
    this.subscriptionId,
    this.subscriptionStatus,
    this.planId,
    this.planExternalId,
    this.billableMetricId,
    this.eventName,
    this.idempotencyKey,
    this.eventsIngested,
    this.eventsValidationFailures,
    this.eventsDuplicate,
    this.invoiceId,
    this.invoiceStatus,
    this.amountCents,
    this.currency,
    this.creditBalanceCents,
    this.statusCode,
  });

  /// `customer` / `subscription` / `plan` / `price` / `billable_metric`
  /// / `event` / `invoice` / `credit_note` / `credit_grant` / `coupon`
  /// / `alert` / `dimensional_price_group`.
  final String? entityKind;

  final String? entityId;

  final String? customerId;

  /// Customer's own id (Orb's `external_customer_id`).
  final String? externalCustomerId;

  final String? subscriptionId;

  /// `active` / `ended` / `upcoming`.
  final String? subscriptionStatus;

  final String? planId;
  final String? planExternalId;

  final String? billableMetricId;

  /// User-defined event name.
  final String? eventName;

  /// Orb requires per-event idempotency_key.
  final String? idempotencyKey;

  /// Ingest API counters.
  final int? eventsIngested;
  final int? eventsValidationFailures;
  final int? eventsDuplicate;

  final String? invoiceId;

  /// `draft` / `issued` / `paid` / `synced` / `void`.
  final String? invoiceStatus;

  /// Invoice total in minor units.
  final int? amountCents;

  final String? currency;

  /// Customer credit balance in cents.
  final int? creditBalanceCents;

  final int? statusCode;
}

class OrbCallResult<T> {
  const OrbCallResult({required this.value, this.result});
  final T value;
  final OrbResult? result;
}

/// Wraps an Orb API call in a CLIENT span. [operation] is one of
/// `events.ingest`, `events.search`, `events.deprecate`,
/// `events.amend`, `customers.create`, `customers.update`,
/// `customers.usage`, `subscriptions.create`,
/// `subscriptions.cancel`, `subscriptions.update_fixed_fee_quantity`,
/// `plans.create`, `prices.create`, `billable_metrics.create`,
/// `invoices.list`, `invoices.issue`, `invoices.void`,
/// `credits.list`, `credits.add`, `alerts.create`.
Future<T> tracedOrb<T>({
  required String operation,
  required Future<OrbCallResult<T>> Function() invoke,
}) async {
  if (orbInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final m = <String, Object>{
    'rpc.system': 'orb',
    'rpc.method': operation,
    'orb.operation': operation,
  };

  final span = _tracer().startSpan(
    'orb $operation',
    kind: SpanKind.client,
    attributes: OTel.attributesFromMap(m),
  );
  try {
    final r = await invoke();
    if (r.result != null) {
      final extras = <Attribute<Object>>[];
      if (r.result!.entityKind != null) {
        extras.add(OTel.attributeString(
          'orb.entity.kind',
          r.result!.entityKind!,
        ));
      }
      if (r.result!.entityId != null) {
        extras.add(OTel.attributeString(
          'orb.entity.id',
          r.result!.entityId!,
        ));
      }
      if (r.result!.customerId != null) {
        extras.add(OTel.attributeString(
          'orb.customer.id',
          r.result!.customerId!,
        ));
      }
      if (r.result!.externalCustomerId != null) {
        extras.add(OTel.attributeString(
          'orb.customer.external_id',
          r.result!.externalCustomerId!,
        ));
      }
      if (r.result!.subscriptionId != null) {
        extras.add(OTel.attributeString(
          'orb.subscription.id',
          r.result!.subscriptionId!,
        ));
      }
      if (r.result!.subscriptionStatus != null) {
        extras.add(OTel.attributeString(
          'orb.subscription.status',
          r.result!.subscriptionStatus!,
        ));
      }
      if (r.result!.planId != null) {
        extras.add(OTel.attributeString(
          'orb.plan.id',
          r.result!.planId!,
        ));
      }
      if (r.result!.planExternalId != null) {
        extras.add(OTel.attributeString(
          'orb.plan.external_id',
          r.result!.planExternalId!,
        ));
      }
      if (r.result!.billableMetricId != null) {
        extras.add(OTel.attributeString(
          'orb.billable_metric.id',
          r.result!.billableMetricId!,
        ));
      }
      if (r.result!.eventName != null) {
        extras.add(OTel.attributeString(
          'orb.event.name',
          r.result!.eventName!,
        ));
      }
      if (r.result!.idempotencyKey != null) {
        extras.add(OTel.attributeString(
          'orb.event.idempotency_key',
          r.result!.idempotencyKey!,
        ));
      }
      if (r.result!.eventsIngested != null) {
        extras.add(OTel.attributeInt(
          'orb.events.ingested',
          r.result!.eventsIngested!,
        ));
      }
      if (r.result!.eventsValidationFailures != null) {
        extras.add(OTel.attributeInt(
          'orb.events.validation_failures',
          r.result!.eventsValidationFailures!,
        ));
      }
      if (r.result!.eventsDuplicate != null) {
        extras.add(OTel.attributeInt(
          'orb.events.duplicate',
          r.result!.eventsDuplicate!,
        ));
      }
      if (r.result!.invoiceId != null) {
        extras.add(OTel.attributeString(
          'orb.invoice.id',
          r.result!.invoiceId!,
        ));
      }
      if (r.result!.invoiceStatus != null) {
        extras.add(OTel.attributeString(
          'orb.invoice.status',
          r.result!.invoiceStatus!,
        ));
      }
      if (r.result!.amountCents != null) {
        extras.add(OTel.attributeInt(
          'orb.amount.cents',
          r.result!.amountCents!,
        ));
      }
      if (r.result!.currency != null) {
        extras.add(OTel.attributeString(
          'orb.currency',
          r.result!.currency!,
        ));
      }
      if (r.result!.creditBalanceCents != null) {
        extras.add(OTel.attributeInt(
          'orb.credit_balance.cents',
          r.result!.creditBalanceCents!,
        ));
      }
      if (r.result!.statusCode != null) {
        extras.add(OTel.attributeInt(
          'http.response.status_code',
          r.result!.statusCode!,
        ));
        if (r.result!.statusCode! >= 400) {
          span.setStatus(
            SpanStatusCode.Error,
            'Orb HTTP ${r.result!.statusCode}',
          );
        }
      }
      if (extras.isNotEmpty) span.addAttributes(OTel.attributes(extras));
    }
    return r.value;
  } catch (e, st) {
    span.addAttributes(OTel.attributes([
      OTel.attributeString(
        ErrorResource.errorType.key,
        e.runtimeType.toString(),
      ),
    ]));
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
