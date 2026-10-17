// Copyright 2020 Ben Hills and the project contributors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.


import 'package:anytime/bloc/podcast/podcast_bloc.dart';
import 'package:anytime/bloc/settings/settings_bloc.dart';
import 'package:anytime/entities/podcast.dart';
import 'package:anytime/l10n/L.dart';
import 'package:anytime/ui/podcast/podcast_details.dart';
import 'package:anytime/ui/widgets/tile_image.dart';
import 'package:anytime/ui/widgets/podcast_library_actions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:provider/provider.dart';

class PodcastTile extends StatelessWidget {
  final Podcast podcast;

  const PodcastTile({
    super.key,
    required this.podcast,
  });

  @override
  Widget build(BuildContext context) {
    final podcastBloc = Provider.of<PodcastBloc>(context);
    final settingsBloc = Provider.of<SettingsBloc>(context);

    var semanticTitle = '${podcast.title}.';

    if (settingsBloc.currentSettings.layoutCount && podcast.episodeCount > 0) {
      final label = L.of(context)!.semantic_unplayed_episodes_count(podcast.episodeCount);
      semanticTitle = '$semanticTitle $label';
    }

    if (settingsBloc.currentSettings.layoutHighlight && podcast.newEpisodes > 0) {
      final label = L.of(context)!.semantic_new_episodes_count(podcast.newEpisodes);
      semanticTitle = '$semanticTitle $label';
    }

    return Semantics(
      customSemanticsActions: {
        if (podcast.id != null)
          CustomSemanticsAction(label: L.of(context)!.label_podcast_actions):
              () => showPodcastLibraryActions(context, podcast),
      },
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute<void>(
                settings: const RouteSettings(name: 'podcastdetails'),
                builder: (context) => PodcastDetails(podcast, podcastBloc)),
          ).then((v) {
            //TODO : Would be more efficient to just update the one podcast in the list.
            podcastBloc.podcastEvent(PodcastEvent.reloadSubscriptions);
          });
        },
        onLongPress: podcast.id == null ? null : () => showPodcastLibraryActions(context, podcast),
        minVerticalPadding: 9,
        leading: ExcludeSemantics(
          child: Hero(
            key: Key('tilehero${podcast.imageUrl}:${podcast.link}'),
            tag: '${podcast.imageUrl}:${podcast.link}',
            child: TileImage(
              url: podcast.imageUrl!,
              fontSize: 13.0,
              highlight: settingsBloc.currentSettings.layoutHighlight && podcast.newEpisodes > 0,
              count: settingsBloc.currentSettings.layoutCount ? podcast.episodeCount : 0,
              size: 60,
            ),
          ),
        ),
        title: Text(
          semanticsLabel: semanticTitle,
          podcast.title,
          maxLines: 1,
        ),

        /// A ListTile's density changes depending upon whether we have 2 or more lines of text. We
        /// manually add a newline character here to ensure the density is consistent whether the
        /// podcast subtitle spans 1 or more lines. Bit of a hack, but a simple solution.
        subtitle: Text(
          '${podcast.copyright ?? ''}\n',
          maxLines: 2,
        ),
        isThreeLine: false,
      ),
    );
  }
}
