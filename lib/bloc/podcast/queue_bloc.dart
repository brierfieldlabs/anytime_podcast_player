// Copyright 2020 Ben Hills and the project contributors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:anytime/bloc/bloc.dart';
import 'package:anytime/entities/podcast.dart';
import 'package:anytime/services/audio/audio_player_service.dart';
import 'package:anytime/services/podcast/podcast_service.dart';
import 'package:anytime/state/queue_event_state.dart';
import 'package:rxdart/rxdart.dart';

/// Handles interaction with the Queue via an [AudioPlayerService].
class QueueBloc extends Bloc {
  final AudioPlayerService audioPlayerService;
  final PodcastService podcastService;
  final PublishSubject<QueueEvent> _queueEvent = PublishSubject<QueueEvent>();
  final Set<String> _queuedEpisodeKeys = <String>{};

  QueueBloc({
    required this.audioPlayerService,
    required this.podcastService,
  }) {
    _handleQueueEvents();
  }

  void _handleQueueEvents() {
    _queueEvent.listen((QueueEvent event) async {
      if (event is QueueAddEvent) {
        var e = event.episode;
        if (e != null) {
          await audioPlayerService.addUpNextEpisode(e);
        }
      } else if (event is QueueAddLatestEpisodeEvent) {
        var e = event.podcast;
        if (e != null) {
          await audioPlayerService.addUpNextLatestEpisode(podcast: e);
        }
      } else if (event is QueueAddNextUnplayedEpisodeEvent) {
        var e = event.podcast;
        if (e != null) {
          await audioPlayerService.addUpNextUnplayedEpisode(podcast: e);
        }
      } else if (event is QueueAddAllUnplayedEpisodesEvent) {
        final podcast = event.podcast;
        if (podcast != null && podcast.guid != null) {
          final unfinished = await podcastService.repository.findEpisodesByPodcastGuid(
            podcast.guid!,
            filter: PodcastEpisodeFilter.notPlayed,
            sort: PodcastEpisodeSort.earliestFirst,
          );
          // Append oldest first. Do not reorder existing Up Next entries or queue duplicates.
          for (final episode in unfinished) {
            if (episode.guid != audioPlayerService.nowPlaying?.guid &&
                !_queuedEpisodeKeys.contains('${episode.pguid}:${episode.guid}')) {
              await audioPlayerService.addUpNextEpisode(episode);
              _queuedEpisodeKeys.add('${episode.pguid}:${episode.guid}');
            }
          }
        }
      } else if (event is QueueRemoveEvent) {
        var e = event.episode;
        if (e != null) {
          await audioPlayerService.removeUpNextEpisode(e);
        }
      } else if (event is QueueMoveEvent) {
        var e = event.episode;
        if (e != null) {
          await audioPlayerService.moveUpNextEpisode(e, event.oldIndex, event.newIndex);
        }
      } else if (event is QueueClearEvent) {
        await audioPlayerService.clearUpNext();
      }
    });

    audioPlayerService.queueState!.doOnData((state) {
      _queuedEpisodeKeys
        ..clear()
        ..addAll(state.queue.map((episode) => '${episode.pguid}:${episode.guid}'));
    }).debounceTime(const Duration(seconds: 2)).listen((event) {
      podcastService.saveQueue(event.queue).then((value) {
        /// Queue saved.
      });
    });
  }

  Function(QueueEvent) get queueEvent => _queueEvent.sink.add;

  Stream<QueueListState>? get queue => audioPlayerService.queueState;

  @override
  void dispose() {
    _queueEvent.close();

    super.dispose();
  }
}
