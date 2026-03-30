import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w10_firebase_part_2/data/repositories/artist/artist_repository.dart';
import 'package:w10_firebase_part_2/data/repositories/songs/song_repository.dart';
import 'package:w10_firebase_part_2/model/artist/artist.dart';
import 'package:w10_firebase_part_2/ui/screens/artists_details/view_model/artist_detail_view_model.dart';
import 'package:w10_firebase_part_2/ui/screens/artists_details/widget/artist_details_content.dart';

class ArtistDetailsScreen extends StatelessWidget {
  final Artist artist;
  const ArtistDetailsScreen({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ArtistDetailViewModel(
        artistRepository: context.read<ArtistRepository>(),
        songRepository: context.read<SongRepository>(),
        artist: artist,
      ),
      child: ArtistDetailsContent(),
    );
  }
}
