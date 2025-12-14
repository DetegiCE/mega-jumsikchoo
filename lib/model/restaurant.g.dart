// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restaurant.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RestaurantImpl _$$RestaurantImplFromJson(Map<String, dynamic> json) =>
    _$RestaurantImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      phone: json['phone'] as String,
      address: json['address'] as String,
      roadAddress: json['roadAddress'] as String,
      x: json['x'] as String,
      y: json['y'] as String,
      url: json['url'] as String,
    );

Map<String, dynamic> _$$RestaurantImplToJson(_$RestaurantImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'category': instance.category,
      'phone': instance.phone,
      'address': instance.address,
      'roadAddress': instance.roadAddress,
      'x': instance.x,
      'y': instance.y,
      'url': instance.url,
    };
