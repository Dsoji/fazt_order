import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:iconsax/iconsax.dart';

import '../../../common/app_colors.dart';
import '../../../common/ui_helpers.dart';
import '../../../common/widgets/text_styles.dart';
import '../data/controller/shop_controller.dart';

class AddressesView extends HookConsumerWidget {
  const AddressesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use useState hook for addresses
    final addresses = useState<List<Map<String, String>>>([
      {
        'title': 'Computer Village',
        'details': '12, Oritshe street, Ikeja, Lagos State',
      },
    ]);

    // Use useCallback for functions to prevent unnecessary rebuilds
    final deleteAddress = useCallback((int index) async {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Address'),
          content: const Text('Are you sure you want to delete this address?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        addresses.value = List.from(addresses.value)..removeAt(index);
      }
    }, []);
    final lat = useState('');
    final long = useState('');
    final city = useState('');
    final state = useState('');
    final formattedAddress = useState('');

    final showAddAddressBottomSheet = useCallback(() {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: kcPrimaryNeutral950,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => AddAddressBottomSheet(
          onAddressSelected: (title, details) {
            // Show the second bottom sheet for manual entry
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: kcPrimaryNeutral950,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => EnterAddressBottomSheet(
                initialTitle: title,
                initialDetails: details,
                onSave: (newTitle, newDetails) {
                  addresses.value = [
                    ...addresses.value,
                    {
                      'title': newTitle,
                      'details': newDetails,
                    },
                  ];
                },
              ),
            );
          },
        ),
      );
    }, []);

    return Scaffold(
      backgroundColor: kcPrimaryNeutral950,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          "Addresses",
          style: ktBodySemiBoldSize20.copyWith(
            fontSize: 20,
            color: Colors.black,
            letterSpacing: 1,
          ),
        ),
        backgroundColor: kcPrimaryNeutral950,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            GestureDetector(
              onTap: showAddAddressBottomSheet,
              child: TextField(
                enabled:
                    false, // Disable direct input, use tap to show bottom sheet
                decoration: InputDecoration(
                  hintText: "Add new address",
                  hintStyle: const TextStyle(
                    color: kcPrimaryNeutral800,
                    fontSize: 12,
                  ),
                  filled: true,
                  fillColor: kcPrimaryNeutral900,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: kcPrimaryNeutral800),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: kcPrimaryNeutral800),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: const BorderSide(color: kcPrimary400),
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  suffixIcon: const Icon(
                    Iconsax.search_normal,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
              ),
            ),
            verticalSpaceMedium,
            // Address List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: addresses.value.length,
              itemBuilder: (context, index) {
                final address = addresses.value[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Iconsax.location,
                        color: Colors.grey,
                        size: 20,
                      ),
                      horizontalSpaceSmall,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              address['title']!,
                              style: ktBodySemiBoldSize20.copyWith(
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            verticalSpaceTiny,
                            Text(
                              address['details']!,
                              style: ktBodyRegularSize12.copyWith(
                                color: kcPrimaryNeutral500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => deleteAddress(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: kcPrimaryRed900,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Iconsax.trash,
                            color: kcPrimaryRed200,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class AddAddressBottomSheet extends HookConsumerWidget {
  final Function(String, String) onAddressSelected;

  const AddAddressBottomSheet({super.key, required this.onAddressSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final places = useState<List<dynamic>>([]);
    final isLoading = useState(false);

    // Place Details
    final lat = useState('');
    final long = useState('');
    final city = useState('');
    final state = useState('');

    // For debouncing search input
    final debounceTimer = useRef<Timer?>(null);

    final String? apiKey = dotenv.env['MAP_KEY'];

    Future<void> searchPlaces(String query) async {
      if (query.isEmpty) {
        places.value = [];
        return;
      }

      isLoading.value = true;

      final url =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$query&key=$apiKey&types=geocode';
      try {
        final response = await http.get(Uri.parse(url));
        final json = jsonDecode(response.body);

        if (json['status'] == 'OK') {
          places.value = json['predictions'];
        } else {
          print('Error fetching places: ${json['status']}');
        }
      } catch (e) {
        print('Error: $e');
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> getPlaceDetails(String placeId) async {
      isLoading.value = true;

      final url =
          'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

      try {
        final response = await http.get(Uri.parse(url));
        final json = jsonDecode(response.body);

        if (json['status'] == 'OK') {
          final result = json['result'];
          final location = result['geometry']['location'];

          String? foundCity;
          String? foundState;

          for (var component in result['address_components']) {
            final List types = component['types'];
            if (types.contains('locality')) {
              foundCity = component['long_name'];
            }
            if (types.contains('administrative_area_level_1')) {
              foundState = component['long_name'];
            }
          }

          lat.value = location['lat'].toString();
          long.value = location['lng'].toString();
          city.value = foundCity ?? '';
          state.value = foundState ?? '';

          // Create a formatted address string
          final formattedAddress = result['formatted_address'] ?? '';
          final placeName = result['name'] ?? 'Selected Location';

          // Pass the selected address to the callback
          onAddressSelected(placeName, formattedAddress);

          // Close the bottom sheet
          Navigator.pop(context);

          print('Latitude: ${lat.value}');
          print('Longitude: ${long.value}');
          print('City: ${city.value}');
          print('State: ${state.value}');
        } else {
          print('Error fetching place details: ${json['status']}');
        }
      } catch (e) {
        print('Error: $e');
      } finally {
        isLoading.value = false;
      }
    }

    // Cleanup timer on dispose
    useEffect(() {
      return () {
        debounceTimer.value?.cancel();
      };
    }, []);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16.0,
        right: 16.0,
        top: 16.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Add new address",
                style: ktBodySemiBoldSize20.copyWith(
                  fontSize: 20,
                  color: Colors.black,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          verticalSpaceTiny,
          Text(
            "This let us show nearby restaurants, stores you can order from and address to deliver to.",
            style: ktBodyRegularSize12.copyWith(
              color: kcPrimaryNeutral500,
              fontSize: 12,
            ),
          ),
          verticalSpaceMedium,
          // Search Bar
          TextField(
            controller: searchController,
            onChanged: (text) {
              // Cancel the previous timer
              debounceTimer.value?.cancel();
              // Start a new timer
              debounceTimer.value =
                  Timer(const Duration(milliseconds: 400), () {
                searchPlaces(text);
              });
            },
            decoration: InputDecoration(
              hintText: "Search address",
              hintStyle: const TextStyle(
                color: kcPrimaryNeutral800,
                fontSize: 12,
              ),
              filled: true,
              fillColor: kcPrimaryNeutral900,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: kcPrimaryNeutral800),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: kcPrimaryNeutral800),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: const BorderSide(color: kcPrimary400),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: const Icon(
                Iconsax.search_normal,
                color: Colors.grey,
                size: 20,
              ),
            ),
          ),
          verticalSpaceSmall,
          // Places List
          if (places.value.isNotEmpty)
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: places.value.length,
                itemBuilder: (context, index) {
                  final place = places.value[index];
                  return ListTile(
                    leading: const Icon(
                      Iconsax.location,
                      color: Colors.grey,
                      size: 20,
                    ),
                    title: Text(
                      place['structured_formatting']?['main_text'] ??
                          place['description'],
                      style: ktBodySemiBoldSize20.copyWith(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      place['structured_formatting']?['secondary_text'] ?? '',
                      style: ktBodyRegularSize12.copyWith(
                        color: kcPrimaryNeutral500,
                        fontSize: 12,
                      ),
                    ),
                    onTap: () async {
                      getPlaceDetails(place['place_id']);
                      final result = await ref
                          .read(shopControllerProvider.notifier)
                          .addAddress(
                            searchController.text,
                            city.value,
                            state.value,
                            long.value,
                            lat.value,
                          );
                      if (result == true) {
                        Navigator.pop(context);
                      }
                    },
                  );
                },
              ),
            ),
          verticalSpaceMedium,
        ],
      ),
    );
  }
}

class EnterAddressBottomSheet extends StatefulWidget {
  final String initialTitle;
  final String initialDetails;
  final Function(String, String) onSave;

  const EnterAddressBottomSheet({
    super.key,
    required this.initialTitle,
    required this.initialDetails,
    required this.onSave,
  });

  @override
  _EnterAddressBottomSheetState createState() =>
      _EnterAddressBottomSheetState();
}

class _EnterAddressBottomSheetState extends State<EnterAddressBottomSheet> {
  late TextEditingController _titleController;
  late TextEditingController _detailsController;
  final List<Map<String, String>> _suggestions = [
    {
      'title': 'Computer Village',
      'details': '12, Oritshe street, Ikeja, Lagos State',
    },
    {
      'title': 'Community Secondary School',
      'details': '14, Ogbeni sare jeje street, Abeokuta, Ogun State',
    },
    {
      'title': 'Comfort Estate',
      'details': '12, okofor road, Akwa, Anambra State',
    },
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _detailsController = TextEditingController(text: widget.initialDetails);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  void _saveAddress() {
    widget.onSave(_titleController.text, _detailsController.text);
    Navigator.pop(context); // Close the second bottom sheet
    Navigator.pop(context); // Close the first bottom sheet
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16.0,
        right: 16.0,
        top: 16.0,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Enter Address",
                  style: ktBodySemiBoldSize20.copyWith(
                    fontSize: 20,
                    color: Colors.black,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            verticalSpaceTiny,
            Text(
              "Enter your address details below.",
              style: ktBodyRegularSize12.copyWith(
                color: kcPrimaryNeutral500,
                fontSize: 12,
              ),
            ),
            verticalSpaceMedium,
            // Title Field
            _buildTextField(
              label: "Title",
              controller: _titleController,
              hintText: "e.g. Computer Village",
            ),
            verticalSpaceMedium,
            // Details Field
            _buildTextField(
              label: "Details",
              controller: _detailsController,
              hintText: "e.g. 12, Oritshe street, Ikeja, Lagos State",
            ),
            verticalSpaceMedium,
            // Suggestions
            Text(
              "Suggestions",
              style: ktBodySemiBoldSize20.copyWith(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            verticalSpaceSmall,
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _suggestions.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final address = _suggestions[index];
                return ListTile(
                  leading: const Icon(
                    Iconsax.location,
                    color: Colors.grey,
                    size: 20,
                  ),
                  title: Text(
                    address['title']!,
                    style: ktBodySemiBoldSize20.copyWith(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    address['details']!,
                    style: ktBodyRegularSize12.copyWith(
                      color: kcPrimaryNeutral500,
                      fontSize: 12,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _titleController.text = address['title']!;
                      _detailsController.text = address['details']!;
                    });
                  },
                );
              },
            ),
            verticalSpaceMedium,
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveAddress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: kcPrimary400,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  "Save",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: kcWhite,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            verticalSpaceMedium,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: ktBodyRegularSize12.copyWith(
            color: kcPrimaryNeutral200,
            letterSpacing: 1,
          ),
        ),
        verticalSpaceTiny,
        TextField(
          controller: controller,
          style: const TextStyle(
              color: kcPrimaryNeutral200, letterSpacing: 1, fontSize: 12),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              color: kcPrimaryNeutral800,
              fontSize: 12,
            ),
            filled: true,
            fillColor: kcPrimaryNeutral900,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: kcPrimaryNeutral800),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: kcPrimaryNeutral800),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: kcPrimary400),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}
