import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:w10_firebase_part_2/model/comment/comment.dart';
import 'package:w10_firebase_part_2/model/songs/song.dart';
import 'package:w10_firebase_part_2/ui/screens/artists_details/view_model/artist_detail_view_model.dart';
import 'package:w10_firebase_part_2/ui/screens/library/view_model/library_item_data.dart';
import 'package:w10_firebase_part_2/ui/screens/library/widgets/library_item_tile.dart';
import 'package:w10_firebase_part_2/ui/theme/theme.dart';
import 'package:w10_firebase_part_2/ui/utils/async_value.dart';
import 'package:w10_firebase_part_2/ui/widgets/comment/comment_tile.dart';

class ArtistDetailsContent extends StatefulWidget {
  const ArtistDetailsContent({super.key});

  @override
  State<ArtistDetailsContent> createState() => _ArtistDetailsContentState();
}

class _ArtistDetailsContentState extends State<ArtistDetailsContent> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment(ArtistDetailViewModel mv) async {
    final comment = _commentController.text.trim();

    if (comment.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Comment field must be filled')));
      return;
    }

    await mv.addComment(comment);
    _commentController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final ArtistDetailViewModel mv = context.watch<ArtistDetailViewModel>();
    final artist = mv.artist;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(artist.imageUrl.toString()),
            ),
            SizedBox(height: 12),
            Text(artist.name, style: AppTextStyles.heading),
            Text(
              artist.genre,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Songs",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  _buildSongs(mv),
                  SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Comments", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(height: 8),
                  _buildCommentsSection(mv),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Write a comment...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () => _submitComment(mv),
                    child: Text('Post'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildSongs(ArtistDetailViewModel mv) {
  final AsyncValue<List<Song>> songsValue = mv.songsValue;

  switch (songsValue.state) {
    case AsyncValueState.loading:
      return Center(child: CircularProgressIndicator());
    case AsyncValueState.error:
      return Text(songsValue.error.toString());
    case AsyncValueState.success:
      final songs = songsValue.data!;
      if (songs.isEmpty) {
        return Text("No songs available", style: TextStyle(color: Colors.grey));
      }
      return Column(
        children: songs
            .map(
              (songs) => LibraryItemTile(
                data: LibraryItemData(song: songs, artist: mv.artist),
                isPlaying: false,
                onTap: () {},
                onLike: () {},
              ),
            )
            .toList(),
      );
  }
}

Widget _buildCommentsSection(ArtistDetailViewModel mv) {
  final AsyncValue<List<Comment>> commentsValue = mv.commentsValue;

  switch (commentsValue.state) {
    case AsyncValueState.loading:
      return Center(child: CircularProgressIndicator());
    case AsyncValueState.error:
      return Text(
        'Failed to load comments',
        style: TextStyle(color: Colors.red),
      );
    case AsyncValueState.success:
      final comments = commentsValue.data!;
      if (comments.isEmpty) {
        return Text(
          'No comments yet. Be the first!',
          style: TextStyle(color: Colors.grey),
        );
      }
      return Column(
        children: comments.map((c) => CommentTile(comment: c)).toList(),
      );
  }
}
