import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:trvlez_mobile/features/properties/domain/entities/property.dart';
import 'package:trvlez_mobile/features/properties/presentation/widgets/property_card.dart';

void main() {
  group('PropertyCard Widget', () {
    const property = Property(
      id: 'prop-99',
      name: 'Hilltop Sanctuary Resort',
      city: 'Ooty',
      stateRegion: 'Tamil Nadu',
      countryCode: 'India',
      propertyType: 'resort',
      shortDescription: 'Peaceful getaway',
      longDescription: 'Peaceful getaway nestled in the hills of Ooty',
      heroImageUrl: 'https://example.com/sanctuary.jpg',
      amenities: ['wifi', 'spa', 'mountain view'],
    );

    testWidgets('renders recommended card without hardcoded fake data', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertyCard(
              property: property,
              isHorizontal: false,
              onTap: () {},
            ),
          ),
        ),
      );

      // Verify name and location
      expect(find.text('Hilltop Sanctuary Resort'), findsOneWidget);
      expect(find.text('Ooty, Tamil Nadu, India'), findsOneWidget);

      // Verify no fake hardcoded price or ratings
      expect(find.text('\$199'), findsNothing);
      expect(find.text('4N/5D'), findsNothing);
      expect(find.text('355 reviews'), findsNothing);
    });

    testWidgets(
      'renders popular card with property type badge and without fake data',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PropertyCard(
                property: property,
                isHorizontal: true,
                onTap: () {},
              ),
            ),
          ),
        );

        // Verify name and location
        expect(find.text('Hilltop Sanctuary Resort'), findsOneWidget);
        expect(find.text('Ooty, Tamil Nadu, India'), findsOneWidget);

        // Verify property type badge
        expect(find.text('RESORT'), findsOneWidget);

        // Verify no fake hardcoded price or ratings
        expect(find.text('\$199'), findsNothing);
        expect(find.text('4N/5D'), findsNothing);
        expect(find.text('355 reviews'), findsNothing);
      },
    );

    testWidgets('renders price per night on horizontal card when present', (
      tester,
    ) async {
      const propertyWithPrice = Property(
        id: 'prop-price',
        name: 'Sunny Bay Villa',
        city: 'Goa',
        countryCode: 'IN',
        shortDescription: 'Cozy villa',
        longDescription: 'Cozy villa near beach',
        heroImageUrl: '',
        pricePerNight: 249.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertyCard(
              property: propertyWithPrice,
              isHorizontal: true,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('£249'), findsOneWidget);
      expect(find.text('/night'), findsOneWidget);
    });

    testWidgets('renders price per night on recommended card when present', (
      tester,
    ) async {
      const propertyWithPrice = Property(
        id: 'prop-price',
        name: 'Sunny Bay Villa',
        city: 'Goa',
        countryCode: 'IN',
        shortDescription: 'Cozy villa',
        longDescription: 'Cozy villa near beach',
        heroImageUrl: '',
        pricePerNight: 249.0,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PropertyCard(
              property: propertyWithPrice,
              isHorizontal: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('£249'), findsOneWidget);
      expect(find.text('/night'), findsOneWidget);
    });
  });
}
