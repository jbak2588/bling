import 'package:bling_app/features/marketplace/models/ai_verification_rule_model.dart';
import 'package:bling_app/features/marketplace/screens/ai_final_report_screen.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bling_app/core/utils/upload_helpers.dart';

class AiEvidenceSuggestionScreen extends StatefulWidget {
  final String productId;
  final String categoryId;
  final String ruleId;
  final AiVerificationRule rule;
  final List<String> initialImageUrls;
  final String confirmedProductName;
  final String? userPrice;
  final String? userDescription;
  final String? categoryName;
  final String? subCategoryName;
  final List<String> missingEvidenceKeys;
  final Map<String, dynamic> foundEvidence;

  const AiEvidenceSuggestionScreen({
    super.key,
    required this.productId,
    required this.categoryId,
    required this.ruleId,
    required this.rule,
    required this.initialImageUrls,
    required this.confirmedProductName,
    this.userPrice,
    this.userDescription,
    this.categoryName,
    this.subCategoryName,
    required this.missingEvidenceKeys,
    required this.foundEvidence,
  });

  @override
  State<AiEvidenceSuggestionScreen> createState() =>
      _AiEvidenceSuggestionScreenState();
}

class _AiEvidenceSuggestionScreenState
    extends State<AiEvidenceSuggestionScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _submitting = false;
  final Map<String, XFile> _pickedImages = {};
  final Set<String> _skippedShots = {};
  late Map<String, dynamic> _foundEvidence;

  @override
  void initState() {
    super.initState();
    _foundEvidence = Map<String, dynamic>.from(widget.foundEvidence);
  }

  // [작업 70] 1. 카메라/갤러리 선택 팝업
  // [작업 71/72] 1. 카메라/갤러리/"기존 사진" 선택 팝업
  Future<void> _pick(String key) async {
    final result = await showModalBottomSheet<dynamic>(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: Text('ai_flow.common.take_photo'.tr()), // "사진 찍기"
            onTap: () => Navigator.pop(context, ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: Text('ai_flow.common.pick_gallery'.tr()), // "갤러리에서 선택"
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          // [작업 71] "기존 사진에서 선택" 옵션 추가
          if (widget.initialImageUrls.isNotEmpty) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.collections_bookmark_outlined),
              title:
                  Text('ai_flow.common.pick_from_initial'.tr()), // "기존 사진에서 선택"
              onTap: () {
                Navigator.pop(context); // 1차 팝업 닫기
                _showInitialImagePicker(context, key); // 2차 팝업 열기
              },
            ),
          ],
        ],
      ),
    );

    // 사용자가 '카메라' 또는 '갤러리'를 선택한 경우
    if (result != null && result is ImageSource) {
      await _pickImageInternal(result, key);
    }
  }

  // [작업 71/72] 2. 기존 사진 목록(캐러셀)을 보여주고 선택하게 하는 2차 팝업
  Future<void> _showInitialImagePicker(BuildContext context, String key) async {
    final int? selectedIndex = await showModalBottomSheet<int>(
      context: context,
      builder: (context) {
        return Container(
          height: 160,
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'ai_flow.evidence.pick_initial_title'
                      .tr(), // "이 증거로 사용할 사진을 선택하세요"
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.initialImageUrls.length,
                  itemBuilder: (context, index) {
                    final imageUrl = widget.initialImageUrls[index];
                    return InkWell(
                      onTap: () => Navigator.pop(context, index), // 탭하면 인덱스 반환
                      child: Container(
                        width: 90,
                        margin: EdgeInsets.only(
                          left: index == 0 ? 16 : 8,
                          right: index == widget.initialImageUrls.length - 1
                              ? 16
                              : 0,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black26, width: 0.5),
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(imageUrl, fit: BoxFit.cover),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.6),
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  '#${index + 1}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selectedIndex != null) {
      // 사용자가 기존 이미지 중 하나를 선택함
      setState(() {
        _foundEvidence[key] = selectedIndex; // "N번째 사진에서 확인됨"으로 상태 변경
        _pickedImages.remove(key); // 새로 찍은 사진이 있다면 제거
        _skippedShots.remove(key); // 스킵 상태였다면 해제
      });
    }
  }

  // [작업 71/72] 3. 실제 이미지 선택 로직
  Future<void> _pickImageInternal(ImageSource source, String key) async {
    try {
      final XFile? img = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
      );
      if (img != null) {
        setState(() {
          _pickedImages[key] = img;
          _skippedShots.remove(key);
        });
      }
    } catch (e) {
      debugPrint('Image pick failed ($source): $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(tr('marketplace.error', namedArgs: {'error': e.toString()})),
      ));
    }
  }

  void _skip(String key) {
    setState(() {
      _pickedImages.remove(key);
      _skippedShots.add(key);
    });
  }

  Future<void> _continue() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated.');

      final Map<String, String> guided = {};
      final Map<String, XFile> takenShots = {};
      for (final entry in _pickedImages.entries) {
        final key = entry.key;
        final file = entry.value;
        if (!_skippedShots.contains(key)) {
          final url = await uploadProductImage(file, user.uid);
          guided[key] = url;
          takenShots[key] = file;
        }
      }

      // [작업 27 수정] 'Skipped' 목록 재계산
      // Recompute skipped keys defensively: use the original missingEvidenceKeys
      // and remove any keys for which we actually uploaded a guided/taken shot.
      final List<String> finalSkippedKeys = widget.missingEvidenceKeys
          .where((key) => !takenShots.containsKey(key))
          .toList();
      // Call the Cloud Function in the same region as the deployed functions
      // (server uses 'asia-southeast2' via setGlobalOptions). Use the
      // regioned instance to avoid firebase_functions/not-found errors.
      final HttpsCallable callable =
          FirebaseFunctions.instanceFor(region: 'asia-southeast2')
              .httpsCallable('generatefinalreport');

      final result = await callable.call(<String, dynamic>{
        'imageUrls': {
          'initial': widget.initialImageUrls,
          'guided': guided,
        },
        'ruleId': widget.ruleId,
        'confirmedProductName': widget.confirmedProductName,
        'categoryName': widget.categoryName,
        'subCategoryName': widget.subCategoryName,
        'userPrice': widget.userPrice,
        'userDescription': widget.userDescription,
        // Use the recalculated list to avoid bugs where _skippedShots was out-of-sync.
        'skippedKeys': finalSkippedKeys,
        'locale': context.locale.languageCode,
      });

      final reportRaw = (result.data as Map<dynamic, dynamic>?)?['report'];
      final report = (reportRaw != null && reportRaw is Map)
          ? Map<String, dynamic>.from(reportRaw)
          : null;
      if (report == null) throw Exception('AI did not return a valid report.');

      if (!mounted) return;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => AiFinalReportScreen(
          productId: widget.productId,
          categoryId: widget.categoryId,
          finalReport: report,
          rule: widget.rule,
          initialImages: widget.initialImageUrls,
          takenShots: takenShots,
          confirmedProductName: widget.confirmedProductName,
          userPrice: widget.userPrice,
          userDescription: widget.userDescription,
        ),
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'marketplace.error'.tr(namedArgs: {'error': e.toString()}))));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  String _getShotName(RequiredShot? shot, String fallbackKey) {
    if (shot == null) return fallbackKey;
    final lang = context.locale.languageCode;
    if (lang == 'en') {
      if (shot.nameEn.isNotEmpty) return shot.nameEn;
      if (shot.nameKo.isNotEmpty) return shot.nameKo;
      if (shot.nameId.isNotEmpty) return shot.nameId;
      return fallbackKey;
    }
    if (lang == 'ko') {
      if (shot.nameKo.isNotEmpty) return shot.nameKo;
      if (shot.nameEn.isNotEmpty) return shot.nameEn;
      if (shot.nameId.isNotEmpty) return shot.nameId;
      return fallbackKey;
    }
    if (lang == 'id') {
      if (shot.nameId.isNotEmpty) return shot.nameId;
      if (shot.nameEn.isNotEmpty) return shot.nameEn;
      if (shot.nameKo.isNotEmpty) return shot.nameKo;
      return fallbackKey;
    }
    if (shot.nameEn.isNotEmpty) return shot.nameEn;
    if (shot.nameKo.isNotEmpty) return shot.nameKo;
    if (shot.nameId.isNotEmpty) return shot.nameId;
    return fallbackKey;
  }

  String _getShotDesc(RequiredShot? shot) {
    if (shot == null) return 'ai_flow.guided_camera.guide'.tr();
    final lang = context.locale.languageCode;
    if (lang == 'en') {
      if (shot.descEn.isNotEmpty) return shot.descEn;
      if (shot.descKo.isNotEmpty) return shot.descKo;
      if (shot.descId.isNotEmpty) return shot.descId;
      return 'ai_flow.guided_camera.guide'.tr();
    }
    if (lang == 'ko') {
      if (shot.descKo.isNotEmpty) return shot.descKo;
      if (shot.descEn.isNotEmpty) return shot.descEn;
      if (shot.descId.isNotEmpty) return shot.descId;
      return 'ai_flow.guided_camera.guide'.tr();
    }
    if (lang == 'id') {
      if (shot.descId.isNotEmpty) return shot.descId;
      if (shot.descEn.isNotEmpty) return shot.descEn;
      if (shot.descKo.isNotEmpty) return shot.descKo;
      return 'ai_flow.guided_camera.guide'.tr();
    }
    if (shot.descEn.isNotEmpty) return shot.descEn;
    if (shot.descKo.isNotEmpty) return shot.descKo;
    if (shot.descId.isNotEmpty) return shot.descId;
    return 'ai_flow.guided_camera.guide'.tr();
  }

  @override
  Widget build(BuildContext context) {
    final suggested = widget.rule.suggestedShots;
    // Prefer server-provided missingEvidenceKeys and foundEvidence to determine
    // which suggested shots to show. This ensures shots removed server-side
    // (e.g., universal shots trimmed by the AI) do not reappear from the
    // local rule definition.
    final List<String> serverMissing = widget.missingEvidenceKeys;
    final Set<String> foundKeys =
        _foundEvidence.keys.map((k) => k.toString()).toSet();
    // Start with server missing keys in order, then include any found keys
    // not already present. If neither provides a key, fall back to rule order.
    final List<String> keys = [];
    keys.addAll(serverMissing);
    for (final k in foundKeys) {
      if (!keys.contains(k)) keys.add(k);
    }
    // If server returned nothing, fall back to the rule's suggested order.
    if (keys.isEmpty) {
      keys.addAll(suggested.keys.toList());
    }
    return Scaffold(
      appBar: AppBar(title: Text('ai_flow.evidence.title'.tr())),
      body: _submitting
          ? Center(child: Text('ai_flow.final_report.loading'.tr()))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.initialImageUrls.isNotEmpty)
                  _buildInitialImagesHeader(context),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'ai_flow.evidence.suggestion_title'.tr(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: keys.length,
                    itemBuilder: (context, index) {
                      final k = keys[index];
                      final shotInfo = suggested[k];
                      final bool isFound = _foundEvidence.containsKey(k);
                      final bool skipped = _skippedShots.contains(k);
                      final XFile? picked = _pickedImages[k];

                      final Widget subtitleWidget = picked != null
                          ? Text(tr('ai_flow.common.added_photo',
                              args: [picked.name]))
                          : skipped
                              ? Text('ai_flow.common.skipped'.tr())
                              : isFound
                                  ? Text(tr(
                                      'ai_flow.common.verified_from_initial',
                                      args: [
                                          ((_foundEvidence[k] as int? ?? 0) + 1)
                                              .toString()
                                        ]))
                                  : Text(_getShotDesc(shotInfo));

                      final Widget trailingWidget;
                      if (isFound && picked == null) {
                        trailingWidget = TextButton(
                            onPressed: () => _pick(k),
                            child: Text('ai_flow.common.retake'.tr()));
                      } else if (skipped) {
                        trailingWidget = TextButton(
                            onPressed: () => _pick(k),
                            child: Text('ai_flow.common.add_photo'.tr()));
                      } else if (picked != null) {
                        trailingWidget = TextButton(
                            onPressed: () => _pick(k),
                            child: Text('ai_flow.common.retake'.tr()));
                      } else {
                        trailingWidget = Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                                onPressed: () => _pick(k),
                                child: Text('ai_flow.common.add_photo'.tr())),
                            const SizedBox(width: 8),
                            TextButton(
                                onPressed: () => _skip(k),
                                child: Text('ai_flow.common.skip'.tr())),
                          ],
                        );
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        color: skipped
                            ? Colors.grey[200]
                            : (picked != null || isFound)
                                ? Colors.green[50]
                                : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              picked != null || skipped
                                  ? Icons.check_circle
                                  : isFound
                                      ? Icons.check_circle_outline
                                      : Icons.add_a_photo_outlined,
                              color: picked != null || isFound
                                  ? Colors.green
                                  : skipped
                                      ? Colors.grey
                                      : Theme.of(context).colorScheme.primary,
                            ),
                            title: Text(_getShotName(shotInfo, k)),
                            subtitle: subtitleWidget,
                            trailing: trailingWidget,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: _submitting ? null : _continue,
          child: _submitting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text('ai_flow.guided_camera.next_button'.tr()),
        ),
      ),
    );
  }

  // [작업 68] 초기 이미지 썸네일을 보여주는 헤더 위젯
  Widget _buildInitialImagesHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      color: Theme.of(context)
          .colorScheme
          .surfaceContainerHighest
          .withAlpha((0.3 * 255).round()),
      height: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'ai_flow.evidence.initial_images_title'.tr(),
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.initialImageUrls.length,
              itemBuilder: (context, index) {
                final imageUrl = widget.initialImageUrls[index];
                return Container(
                  width: 80,
                  margin: EdgeInsets.only(
                    left: index == 0 ? 16 : 8,
                    right: index == widget.initialImageUrls.length - 1 ? 16 : 0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black26, width: 0.5),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          // TODO: Add shimmer loading
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha((0.6 * 255).round()),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8),
                            ),
                          ),
                          child: Text(
                            '#${index + 1}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
