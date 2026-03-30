import 'package:flutter/material.dart';
import 'package:w10_firebase_part_2/data/repositories/artist/artist_repository.dart';
import 'package:w10_firebase_part_2/data/repositories/songs/song_repository.dart';
import 'package:w10_firebase_part_2/model/artist/artist.dart';
import 'package:w10_firebase_part_2/model/comment/comment.dart';
import 'package:w10_firebase_part_2/model/songs/song.dart';
import 'package:w10_firebase_part_2/ui/utils/async_value.dart';

class ArtistDetailViewModel extends ChangeNotifier {
  final ArtistRepository artistRepository;
  final SongRepository songRepository;
  final Artist artist;

  ArtistDetailViewModel({
    required this.artistRepository,
    required this.songRepository,
    required this.artist,
  }) {
    _init();
  }

  AsyncValue<List<Song>> songsValue = AsyncValue.loading();
  AsyncValue<List<Comment>> commentsValue = AsyncValue.loading();

  void _init() {
    fetchData();
  }

  Future<void> fetchData() async {
    songsValue = AsyncValue.loading();
    commentsValue = AsyncValue.loading();
    notifyListeners();

    try {
      final songs = await artistRepository.fetchSongsByArtist(artist.id);
      songsValue = AsyncValue.success(songs);
    } catch (e) {
      songsValue = AsyncValue.error(e);
    }
    try {
      final comments = await artistRepository.fetchCommentByArtist(artist.id);
      commentsValue = AsyncValue.success(comments);
    } catch (e) {
      commentsValue = AsyncValue.error(e);
    }
    notifyListeners();
  }

  Future<void> addComment(String text) async {
    if (text.trim().isEmpty) return;
    final Comment newComment = Comment(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      artistId: artist.id,
      text: text.trim(),
    );
    try {
      await artistRepository.postComment(artist.id, newComment);
      final current = commentsValue.data ?? [];
      commentsValue = AsyncValue.success([...current, newComment]);
      notifyListeners();
    } catch (e) {
      commentsValue = AsyncValue.error(e);
      notifyListeners();
    }
  }
}
