import 'package:equatable/equatable.dart';

import '../../../models/campaign.dart';
import '../../../models/character.dart';

abstract class CampaignState extends Equatable {
  const CampaignState();

  @override
  List<Object?> get props => [];
}

class CampaignLoading extends CampaignState {}

class CampaignLoaded extends CampaignState {
  final Campaign campaign;
  final List<Character> players;
  final List<Map<String, dynamic>> notes; // notes subcollection
  final List<Map<String, dynamic>> sessions; // sessions subcollection
  final bool isDungeonMaster;

  final bool isProcessing;
  final String? successMessage;
  final String? errorMessage;

  const CampaignLoaded({
    required this.campaign,
    required this.players,
    required this.notes,
    required this.sessions,
    required this.isDungeonMaster,
    this.isProcessing = false,
    this.successMessage,
    this.errorMessage,
  });

  CampaignLoaded copyWith({
    Campaign? campaign,
    List<Character>? players,
    List<Map<String, dynamic>>? notes,
    List<Map<String, dynamic>> sessions = const [],
    bool? isDungeonMaster,
    bool? isProcessing,
    String? successMessage,
    String? errorMessage,
    bool clearMessages = false,
  }) {
    return CampaignLoaded(
      campaign: campaign ?? this.campaign,
      players: players ?? this.players,
      notes: notes ?? this.notes,
      sessions: sessions ?? this.sessions,
      isDungeonMaster: isDungeonMaster ?? this.isDungeonMaster,
      isProcessing: isProcessing ?? this.isProcessing,
      successMessage:
          clearMessages ? null : (successMessage ?? this.successMessage),
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        campaign,
        players,
        notes,
        sessions,
        isDungeonMaster,
        isProcessing,
        successMessage,
        errorMessage
      ];
}

class CampaignFailure extends CampaignState {
  final String message;

  const CampaignFailure(this.message);

  @override
  List<Object?> get props => [message];
}
