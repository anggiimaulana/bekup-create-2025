import 'dart:convert';

class Transcript {
  final List<Segments> segments;
  Transcript({required this.segments});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'segments': segments.map((x) => x.toMap()).toList(),
    };
  }

  factory Transcript.fromMap(Map<String, dynamic> map) {
    return Transcript(
      segments: List<Segments>.from(
        (map['segments'] as List).map<Segments>(
          (x) => Segments.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory Transcript.fromJson(String source) =>
      Transcript.fromMap(json.decode(source) as Map<String, dynamic>);
}

class Segments {
  final String speaker;
  final String timecode;
  final String caption;
  Segments({
    required this.speaker,
    required this.timecode,
    required this.caption,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'speaker': speaker,
      'timecode': timecode,
      'caption': caption,
    };
  }

  factory Segments.fromMap(Map<String, dynamic> map) {
    return Segments(
      speaker: map['speaker'] as String,
      timecode: map['timecode'] as String,
      caption: map['caption'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory Segments.fromJson(String source) =>
      Segments.fromMap(json.decode(source) as Map<String, dynamic>);
}
