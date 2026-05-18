// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry/testing.dart';
import 'package:otel_orb/otel_orb.dart';
import 'package:test/test.dart';

void main() {
  late TestHarness harness;
  late InMemorySpanExporter spans;

  setUpAll(() async {
    harness = await maybeInitializeOtelForTest(
      serviceName: 'otel_orb-test',
    );
    spans = harness.spans;
  });

  setUp(() => harness.clear());

  Map<String, Object> attrsOf(Span s) =>
      {for (final a in s.attributes.toList()) a.key: a.value};

  test('events.ingest records counters + idempotency', () async {
    await tracedOrb<String>(
      operation: 'events.ingest',
      invoke: () async => const OrbCallResult(
        value: 'ok',
        result: OrbResult(
          eventName: 'api_call',
          externalCustomerId: 'cust_42',
          idempotencyKey: 'idem_abc',
          eventsIngested: 248,
          eventsValidationFailures: 1,
          eventsDuplicate: 1,
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('orb events.ingest')!);
    expect(a['orb.event.name'], 'api_call');
    expect(a['orb.event.idempotency_key'], 'idem_abc');
    expect(a['orb.events.ingested'], 248);
    expect(a['orb.events.validation_failures'], 1);
    expect(a['orb.events.duplicate'], 1);
  });

  test('subscriptions.create records plan + status', () async {
    await tracedOrb<String>(
      operation: 'subscriptions.create',
      invoke: () async => const OrbCallResult(
        value: 'ok',
        result: OrbResult(
          subscriptionId: 'sub_1',
          subscriptionStatus: 'active',
          planExternalId: 'pro_monthly_2026',
          statusCode: 201,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('orb subscriptions.create')!);
    expect(a['orb.subscription.status'], 'active');
    expect(a['orb.plan.external_id'], 'pro_monthly_2026');
  });

  test('invoices.issue records status + total + credit balance', () async {
    await tracedOrb<String>(
      operation: 'invoices.issue',
      invoke: () async => const OrbCallResult(
        value: 'ok',
        result: OrbResult(
          invoiceId: 'inv_1',
          invoiceStatus: 'issued',
          amountCents: 850000,
          currency: 'USD',
          creditBalanceCents: 25000,
          statusCode: 200,
        ),
      ),
    );
    final a = attrsOf(spans.findSpanByName('orb invoices.issue')!);
    expect(a['orb.invoice.status'], 'issued');
    expect(a['orb.amount.cents'], 850000);
    expect(a['orb.credit_balance.cents'], 25000);
  });

  test('HTTP 400 sets span error', () async {
    await tracedOrb<String>(
      operation: 'events.ingest',
      invoke: () async => const OrbCallResult(
        value: 'ok',
        result: OrbResult(statusCode: 400),
      ),
    );
    expect(
      spans.findSpanByName('orb events.ingest')!.status,
      SpanStatusCode.Error,
    );
  });

  test('suppression skips spans', () async {
    await runWithoutOrbInstrumentationAsync(() async {
      await tracedOrb<String>(
        operation: 'customers.usage',
        invoke: () async => const OrbCallResult(value: 'v'),
      );
    });
    expect(spans.findSpansStartingWith('orb '), isEmpty);
  });
}
