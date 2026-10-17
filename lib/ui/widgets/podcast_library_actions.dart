// Copyright 2020 Ben Hills and the project contributors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:anytime/bloc/podcast/audio_bloc.dart';
import 'package:anytime/bloc/podcast/podcast_bloc.dart';
import 'package:anytime/bloc/podcast/queue_bloc.dart';
import 'package:anytime/bloc/settings/settings_bloc.dart';
import 'package:anytime/core/utils.dart';
import 'package:anytime/entities/downloadable.dart';
import 'package:anytime/entities/podcast.dart';
import 'package:anytime/l10n/L.dart';
import 'package:anytime/state/queue_event_state.dart';
import 'package:anytime/ui/podcast/now_playing.dart';
import 'package:anytime/ui/podcast/podcast_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// A single library-tile menu shared by the subscribed podcast list and grid.
Future<void> showPodcastLibraryActions(BuildContext context, Podcast podcast) async {
  if (podcast.id == null || podcast.guid == null) return;

  final podcastBloc = Provider.of<PodcastBloc>(context, listen: false);
  final audioBloc = Provider.of<AudioBloc>(context, listen: false);
  final queueBloc = Provider.of<QueueBloc>(context, listen: false);
  final settings = Provider.of<SettingsBloc>(context, listen: false).currentSettings;
  final l = L.of(context)!;

  final action = await showModalBottomSheet<String>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            leading: const Icon(Icons.playlist_add),
            title: Text(l.library_add_all_unfinished),
            onTap: () => Navigator.pop(sheetContext, 'queue'),
          ),
          ListTile(
            leading: const Icon(Icons.play_arrow),
            title: Text(l.library_play_oldest_unfinished),
            onTap: () => Navigator.pop(sheetContext, 'play'),
          ),
          ListTile(
            leading: const Icon(Icons.download),
            title: Text(l.library_download_unfinished),
            onTap: () => Navigator.pop(sheetContext, 'download'),
          ),
          ListTile(
            leading: const Icon(Icons.done_all),
            title: Text(l.mark_episodes_played_label),
            onTap: () => Navigator.pop(sheetContext, 'played'),
          ),
          ListTile(
            leading: const Icon(Icons.tune),
            title: Text(l.library_podcast_details),
            onTap: () => Navigator.pop(sheetContext, 'details'),
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: Text(l.share_podcast_option_label),
            onTap: () => Navigator.pop(sheetContext, 'share'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline),
            title: Text(l.unsubscribe_label),
            onTap: () => Navigator.pop(sheetContext, 'unsubscribe'),
          ),
        ],
      ),
    ),
  );

  if (action == null || !context.mounted) return;
  final service = podcastBloc.podcastService;

  switch (action) {
    case 'queue':
      queueBloc.queueEvent(QueueAddAllUnplayedEpisodesEvent(podcast: podcast));
      return;
    case 'play':
      audioBloc.playNextUnplayedEpisode(podcast);
      if (settings.autoOpenNowPlaying && context.mounted) {
        await Navigator.push<void>(
          context,
          MaterialPageRoute(builder: (_) => const NowPlaying(), settings: const RouteSettings(name: 'nowplaying')),
        );
      }
      return;
    case 'details':
      await Navigator.push<void>(
        context,
        MaterialPageRoute(
          settings: const RouteSettings(name: 'podcastdetails'),
          builder: (_) => PodcastDetails(podcast, podcastBloc),
        ),
      );
      podcastBloc.podcastEvent(PodcastEvent.reloadSubscriptions);
      return;
    case 'share':
      await sharePodcast(podcast: podcast);
      return;
    case 'download':
      final unfinished = await service.repository.findEpisodesByPodcastGuid(
        podcast.guid!,
        filter: PodcastEpisodeFilter.notPlayed,
        sort: PodcastEpisodeSort.earliestFirst,
      );
      final available = unfinished
          .where((episode) => episode.downloadState != DownloadState.downloaded
              && episode.downloadState != DownloadState.queued
              && episode.downloadState != DownloadState.downloading)
          .toList();
      if (available.isEmpty || !context.mounted) return;
      if (!await _confirm(
        context,
        l.library_confirm_download,
        l.semantic_unplayed_episodes_count(available.length),
      )) {
        return;
      }
      for (final episode in available) {
        await podcastBloc.downloadService.downloadEpisode(episode);
      }
      return;
    case 'played':
      final episodes = await service.repository.findEpisodesByPodcastGuid(podcast.guid!);
      final unfinished = episodes.where((episode) => !episode.played).toList();
      if (unfinished.isEmpty || !context.mounted) return;
      if (!await _confirm(
        context,
        l.library_confirm_mark_played,
        l.semantic_unplayed_episodes_count(unfinished.length),
      )) {
        return;
      }
      for (final episode in unfinished) {
        episode.played = true;
        episode.position = 0;
      }
      await service.saveEpisodes(unfinished);
      podcastBloc.podcastEvent(PodcastEvent.reloadSubscriptions);
      return;
    case 'unsubscribe':
      if (!await _confirm(context, l.unsubscribe_label, l.unsubscribe_message)) return;
      await service.unsubscribe(podcast);
      podcastBloc.podcastEvent(PodcastEvent.reloadSubscriptions);
      return;
  }
}

Future<bool> _confirm(BuildContext context, String title, String description) async {
  if (!context.mounted) return false;
  final l = L.of(context)!;
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(description),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(l.cancel_button_label)),
        TextButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(l.ok_button_label)),
      ],
    ),
  );
  return result ?? false;
}
