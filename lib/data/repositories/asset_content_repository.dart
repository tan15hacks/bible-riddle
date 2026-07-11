import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/campaign_section.dart';
import '../../domain/entities/riddle.dart';
import '../../domain/entities/testament.dart';
import '../../domain/repositories/content_repository.dart';

class AssetContentRepository implements ContentRepository {
  AssetContentRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;
  final List<Riddle> _riddles = [];
  final Map<String, CampaignSection> _sections = {};
  bool _loaded = false;

  @override
  Future<List<Riddle>> getRiddles({Testament? testament}) async {
    await _ensureLoaded();
    final items = testament == null
        ? _riddles
        : _riddles.where((riddle) => riddle.testament == testament).toList();
    return List.unmodifiable(items..sort(_sortRiddles));
  }

  @override
  Future<Riddle?> getRiddleById(String id) async {
    await _ensureLoaded();
    for (final riddle in _riddles) {
      if (riddle.id == id) return riddle;
    }
    return null;
  }

  @override
  Future<List<CampaignSection>> getSections(Testament testament) async {
    await _ensureLoaded();
    final ids = <String>{};
    for (final riddle in _riddles.where((item) => item.testament == testament)) {
      ids.add(riddle.sectionId);
    }
    final sections = ids.map((id) => _sections[id]).whereType<CampaignSection>().toList()
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
    return List.unmodifiable(sections);
  }

  @override
  Future<void> importRiddles(List<Riddle> riddles) async {
    _riddles
      ..clear()
      ..addAll(riddles)
      ..sort(_sortRiddles);
    _loaded = true;
  }

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final manifestText = await _bundle.loadString('assets/data/manifest.json');
    final manifest = jsonDecode(manifestText) as Map<String, dynamic>;
    final files = List<String>.from(manifest['files'] as List? ?? const ['assets/data/riddles_phase_a.json']);

    for (final file in files) {
      final contentText = await _bundle.loadString(file);
      final decoded = jsonDecode(contentText) as Map<String, dynamic>;
      final riddles = List<Map<String, dynamic>>.from(decoded['riddles'] as List);
      _riddles.addAll(riddles.map(Riddle.fromJson));
    }

    _riddles.sort(_sortRiddles);
    _backfillSectionsFromRiddles();
    _loaded = true;
  }

  void _backfillSectionsFromRiddles() {
    final seen = <String>{};
    for (final riddle in _riddles) {
      if (!seen.add(riddle.sectionId) || _sections.containsKey(riddle.sectionId)) continue;
      _sections[riddle.sectionId] = CampaignSection(
        id: riddle.sectionId,
        testament: riddle.testament,
        title: _titleFromSectionId(riddle.sectionId),
        description: '${riddle.testament.label} riddles',
        orderIndex: seen.length,
        requiredLevels: 0,
        iconKey: 'book',
      );
    }
  }

  String _titleFromSectionId(String sectionId) {
    return sectionId
        .split(RegExp(r'[-_]'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  int _sortRiddles(Riddle a, Riddle b) {
    final testamentCompare = a.testament.index.compareTo(b.testament.index);
    if (testamentCompare != 0) return testamentCompare;
    return a.sortOrder.compareTo(b.sortOrder);
  }
}
