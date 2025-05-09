// Temporarily disabled notification service
// Will be restored once we find a compatible version of flutter_local_notifications

import 'package:flutter/material.dart';

/// Stub implementation of NotificationService while we fix the plugin compatibility issues
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  
  NotificationService._internal() {
    debugPrint('Notification service disabled temporarily');
  }
  
  /// Request notification permissions
  Future<bool> requestPermissions() async {
    debugPrint('Notification permissions requested (stub implementation)'); 
    return true; // Stub implementation always returns true
  }
  
  /// Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    debugPrint('Notification would show: $title - $body');
    // Stub implementation - doesn't actually show notifications
  }
  
  /// Show message notification
  Future<void> showMessageNotification({
    required int id,
    required String senderName,
    required String message,
    String? conversationId,
  }) async {
    debugPrint('Message notification would show: $senderName - $message');
    // Stub implementation - calls the showNotification method
    await showNotification(
      id: id,
      title: 'Nouveau message de $senderName',
      body: message,
      payload: conversationId != null ? 'chat:$conversationId' : null,
    );
  }
  
  /// Show nearby place notification
  Future<void> showNearbyPlaceNotification({
    required int id,
    required String placeName,
    required String userName,
    required double distance,
    String? placeId,
  }) async {
    final String formattedDistance = distance < 1.0
        ? '${(distance * 1000).toStringAsFixed(0)} m'
        : '${distance.toStringAsFixed(1)} km';
    
    debugPrint('Nearby place notification would show: $placeName - $userName - $formattedDistance');
    // Stub implementation - calls the showNotification method
    await showNotification(
      id: id,
      title: 'Lieu à proximité : $placeName',
      body: 'Ajouté par $userName à $formattedDistance de vous',
      payload: placeId != null ? 'place:$placeId' : null,
    );
  }
  
  /// Schedule notification for later
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    debugPrint('Notification would be scheduled for ${scheduledDate.toString()}: $title - $body');
    // Stub implementation - doesn't actually schedule notifications
  }
  
  /// Cancel a specific notification
  Future<void> cancelNotification(int id) async {
    debugPrint('Would cancel notification with id: $id');
    // Stub implementation - doesn't actually cancel notifications
  }
  
  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    debugPrint('Would cancel all notifications');
    // Stub implementation - doesn't actually cancel notifications
  }
}
