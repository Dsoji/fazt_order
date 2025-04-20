import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../common/app_colors.dart';
import '../../common/ui_helpers.dart';
import '../../common/widgets/text_styles.dart';

class AddressesView extends StatefulWidget {
  const AddressesView({Key? key}) : super(key: key);

  @override
  _AddressesViewState createState() => _AddressesViewState();
}

class _AddressesViewState extends State<AddressesView> {
  // Sample list of addresses (replace with provider or API data)
  final List<Map<String, String>> _addresses = [
    {
      'title': 'Computer Village',
      'details': '12, Oritshe street, Ikeja, Lagos State',
    },
  ];

  void _deleteAddress(int index) async {
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
      setState(() {
        _addresses.removeAt(index);
      });
    }
  }

  void _showAddAddressBottomSheet() {
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
                setState(() {
                  _addresses.add({
                    'title': newTitle,
                    'details': newDetails,
                  });
                });
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              onTap: _showAddAddressBottomSheet,
              child: TextField(
                enabled: false, // Disable direct input, use tap to show bottom sheet
                decoration: InputDecoration(
                  hintText: "Add new address",
                  hintStyle: TextStyle(
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
              itemCount: _addresses.length,
              itemBuilder: (context, index) {
                final address = _addresses[index];
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
                        onTap: () => _deleteAddress(index),
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

class AddAddressBottomSheet extends StatefulWidget {
  final Function(String, String) onAddressSelected;

  const AddAddressBottomSheet({Key? key, required this.onAddressSelected}) : super(key: key);

  @override
  _AddAddressBottomSheetState createState() => _AddAddressBottomSheetState();
}

class _AddAddressBottomSheetState extends State<AddAddressBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
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
  List<Map<String, String>> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _filteredSuggestions = _suggestions;
    _searchController.addListener(_filterSuggestions);
  }

  void _filterSuggestions() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSuggestions = _suggestions
          .where((address) =>
      address['title']!.toLowerCase().contains(query) ||
          address['details']!.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      child: SingleChildScrollView( // Added SingleChildScrollView to prevent overflow
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
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search address",
                hintStyle: TextStyle(
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                suffixIcon: const Icon(
                  Iconsax.search_normal,
                  color: Colors.grey,
                  size: 20,
                ),
              ),
            ),
            verticalSpaceSmall,
            // Use Current Location
            GestureDetector(
              onTap: () {
                // TODO: Implement current location functionality
                widget.onAddressSelected("Current Location", "Fetched location details");
              },
              child: Row(
                children: [
                  const Icon(
                    Iconsax.location,
                    color: Colors.grey,
                    size: 20,
                  ),
                  horizontalSpaceSmall,
                  Text(
                    "Use your current location",
                    style: ktBodyRegularSize12.copyWith(
                      color: kcPrimaryNeutral500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            verticalSpaceMedium,
            // Suggestions List
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredSuggestions.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final address = _filteredSuggestions[index];
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
                    widget.onAddressSelected(address['title']!, address['details']!);
                  },
                );
              },
            ),
            verticalSpaceMedium,
          ],
        ),
      ),
    );
  }
}

class EnterAddressBottomSheet extends StatefulWidget {
  final String initialTitle;
  final String initialDetails;
  final Function(String, String) onSave;

  const EnterAddressBottomSheet({
    Key? key,
    required this.initialTitle,
    required this.initialDetails,
    required this.onSave,
  }) : super(key: key);

  @override
  _EnterAddressBottomSheetState createState() => _EnterAddressBottomSheetState();
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
          style: const TextStyle(color: kcPrimaryNeutral200, letterSpacing: 1, fontSize: 12),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}