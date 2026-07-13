import 'package:flutter/material.dart';

/// JSON アセット内のアイコン名から [IconData] に変換する。
///
/// 未知の名前や `null` の場合は `null` を返す。
IconData? kaidoIconFromName(String? iconName) {
  switch (iconName) {
    case 'route':
      return Icons.route;
    case 'location_city':
      return Icons.location_city;
    case 'landscape':
      return Icons.landscape;
    case 'image':
      return Icons.image;
    case 'home':
      return Icons.home;
    case 'home_work':
      return Icons.home_work;
    case 'hotel':
      return Icons.hotel;
    case 'business_center':
      return Icons.business_center;
    case 'announcement':
      return Icons.announcement;
    case 'door_sliding':
      return Icons.door_sliding;
    case 'fork_right':
      return Icons.fork_right;
    case 'deck':
      return Icons.deck;
    case 'night_shelter':
      return Icons.night_shelter;
    case 'terrain':
      return Icons.terrain;
    case 'security':
      return Icons.security;
    case 'directions_walk':
      return Icons.directions_walk;
    case 'brightness_7':
      return Icons.brightness_7;
    case 'north':
      return Icons.north;
    case 'history_edu':
      return Icons.history_edu;
    case 'navigation':
      return Icons.navigation;
    case 'place':
      return Icons.place;
    case 'settings':
      return Icons.settings;
    case 'battery_saver':
      return Icons.battery_saver;
    case 'notifications':
      return Icons.notifications;
    case 'update':
      return Icons.update;
    case 'brightness_6':
      return Icons.brightness_6;
    case 'photo_camera':
      return Icons.photo_camera;
    default:
      return null;
  }
}
