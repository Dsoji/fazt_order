import 'dart:convert';

class FavouritesListResponse {
  List<FavouriteShop>? shops;

  FavouritesListResponse({this.shops});

  @override
  String toString() => 'FavouritesListResponse(shops: $shops)';

  factory FavouritesListResponse.fromMap(Map<String, dynamic> data) {
    return FavouritesListResponse(
      shops: (data['shops'] as List<dynamic>?)
          ?.map((e) => FavouriteShop.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() => {
        'shops': shops?.map((e) => e.toMap()).toList(),
      };

  factory FavouritesListResponse.fromJson(String data) {
    return FavouritesListResponse.fromMap(
        json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  FavouritesListResponse copyWith({
    List<FavouriteShop>? shops,
  }) {
    return FavouritesListResponse(
      shops: shops ?? this.shops,
    );
  }
}

class FavouriteShop {
  FavouriteShopLocation? location;
  bool? isDeleted;
  String? shopName;
  String? manager;
  String? phone;
  FavouriteStoreRef? store;
  int? numberOfFavorites;
  num? rating;
  num? deliveryFee;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? favoriteCount;
  String? id;

  FavouriteShop({
    this.location,
    this.isDeleted,
    this.shopName,
    this.manager,
    this.phone,
    this.store,
    this.numberOfFavorites,
    this.rating,
    this.deliveryFee,
    this.createdAt,
    this.updatedAt,
    this.favoriteCount,
    this.id,
  });

  @override
  String toString() {
    return 'FavouriteShop(location: $location, isDeleted: $isDeleted, shopName: $shopName, manager: $manager, phone: $phone, store: $store, numberOfFavorites: $numberOfFavorites, rating: $rating, deliveryFee: $deliveryFee, createdAt: $createdAt, updatedAt: $updatedAt, favoriteCount: $favoriteCount, id: $id)';
  }

  factory FavouriteShop.fromMap(Map<String, dynamic> data) {
    return FavouriteShop(
      location: data['location'] == null
          ? null
          : FavouriteShopLocation.fromMap(
              data['location'] as Map<String, dynamic>,
            ),
      isDeleted: data['isDeleted'] as bool?,
      shopName: data['shopName'] as String?,
      manager: data['manager'] as String?,
      phone: data['phone'] as String?,
      store: data['store'] == null
          ? null
          : FavouriteStoreRef.fromMap(
              data['store'] as Map<String, dynamic>,
            ),
      numberOfFavorites: (data['numberOfFavorites'] as num?)?.toInt(),
      rating: data['rating'] as num?,
      deliveryFee: data['deliveryFee'] as num?,
      createdAt: data['createdAt'] == null
          ? null
          : DateTime.tryParse(data['createdAt'] as String),
      updatedAt: data['updatedAt'] == null
          ? null
          : DateTime.tryParse(data['updatedAt'] as String),
      favoriteCount: (data['favoriteCount'] as num?)?.toInt(),
      id: data['id'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'location': location?.toMap(),
        'isDeleted': isDeleted,
        'shopName': shopName,
        'manager': manager,
        'phone': phone,
        'store': store?.toMap(),
        'numberOfFavorites': numberOfFavorites,
        'rating': rating,
        'deliveryFee': deliveryFee,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
        'favoriteCount': favoriteCount,
        'id': id,
      };

  factory FavouriteShop.fromJson(String data) {
    return FavouriteShop.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  FavouriteShop copyWith({
    FavouriteShopLocation? location,
    bool? isDeleted,
    String? shopName,
    String? manager,
    String? phone,
    FavouriteStoreRef? store,
    int? numberOfFavorites,
    num? rating,
    num? deliveryFee,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? favoriteCount,
    String? id,
  }) {
    return FavouriteShop(
      location: location ?? this.location,
      isDeleted: isDeleted ?? this.isDeleted,
      shopName: shopName ?? this.shopName,
      manager: manager ?? this.manager,
      phone: phone ?? this.phone,
      store: store ?? this.store,
      numberOfFavorites: numberOfFavorites ?? this.numberOfFavorites,
      rating: rating ?? this.rating,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      favoriteCount: favoriteCount ?? this.favoriteCount,
      id: id ?? this.id,
    );
  }
}

class FavouriteShopLocation {
  String? type;
  List<double>? coordinates; // [longitude, latitude]
  String? address;
  String? state;
  String? city;

  FavouriteShopLocation({
    this.type,
    this.coordinates,
    this.address,
    this.state,
    this.city,
  });

  @override
  String toString() {
    return 'FavouriteShopLocation(type: $type, coordinates: $coordinates, address: $address, state: $state, city: $city)';
  }

  factory FavouriteShopLocation.fromMap(Map<String, dynamic> data) {
    return FavouriteShopLocation(
      type: data['type'] as String?,
      coordinates: (data['coordinates'] as List<dynamic>?)
          ?.map((e) => (e as num).toDouble())
          .toList(),
      address: data['address'] as String?,
      state: data['state'] as String?,
      city: data['city'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'type': type,
        'coordinates': coordinates,
        'address': address,
        'state': state,
        'city': city,
      };

  factory FavouriteShopLocation.fromJson(String data) {
    return FavouriteShopLocation.fromMap(
        json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  FavouriteShopLocation copyWith({
    String? type,
    List<double>? coordinates,
    String? address,
    String? state,
    String? city,
  }) {
    return FavouriteShopLocation(
      type: type ?? this.type,
      coordinates: coordinates ?? this.coordinates,
      address: address ?? this.address,
      state: state ?? this.state,
      city: city ?? this.city,
    );
  }
}

class FavouriteStoreRef {
  String? storeDisplayImage;
  String? storeName;
  String? id;

  FavouriteStoreRef({this.storeDisplayImage, this.storeName, this.id});

  @override
  String toString() =>
      'FavouriteStoreRef(storeDisplayImage: $storeDisplayImage, storeName: $storeName, id: $id)';

  factory FavouriteStoreRef.fromMap(Map<String, dynamic> data) {
    return FavouriteStoreRef(
      storeDisplayImage: data['storeDisplayImage'] as String?,
      storeName: data['storeName'] as String?,
      id: data['id'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'storeDisplayImage': storeDisplayImage,
        'storeName': storeName,
        'id': id,
      };

  factory FavouriteStoreRef.fromJson(String data) {
    return FavouriteStoreRef.fromMap(json.decode(data) as Map<String, dynamic>);
  }

  String toJson() => json.encode(toMap());

  FavouriteStoreRef copyWith({
    String? storeDisplayImage,
    String? storeName,
    String? id,
  }) {
    return FavouriteStoreRef(
      storeDisplayImage: storeDisplayImage ?? this.storeDisplayImage,
      storeName: storeName ?? this.storeName,
      id: id ?? this.id,
    );
  }
}
