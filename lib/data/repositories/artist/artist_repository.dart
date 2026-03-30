import 'package:w10_firebase_part_2/model/comment/comment.dart';
import 'package:w10_firebase_part_2/model/songs/song.dart';

import '../../../model/artist/artist.dart';

abstract class ArtistRepository {
  Future<List<Artist>> fetchArtists({bool forceFetch = false});

  Future<Artist?> fetchArtistById(String id);
  Future<List<Song>> fetchSongsByArtist(String artistId);
  Future<List<Comment>> fetchCommentByArtist(String artistId);
  Future<void> postComment(String artistId, Comment comment);
}
