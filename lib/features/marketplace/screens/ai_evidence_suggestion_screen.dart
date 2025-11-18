import 'package:bling_app/features/marketplace/screens/ai_final_report_screen.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:bling_app/core/utils/popups/snackbars.dart'; // BArtSnackBar 가 정의된 곳
// [V3 PENDING] 'pending' 저장을 위해 Firestore와 UserModel 임포트
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bling_app/core/models/user_model.dart';
import 'package:bling_app/core/utils/logging/logger.dart'; // Logger 가 정의된 곳
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bling_app/core/utils/upload_helpers.dart';
import 'package:uuid/uuid.dart'; // [Task 108] For unique guided keys

class AiEvidenceSuggestionScreen extends StatefulWidget {
  final String productId;
  final String categoryId;
  final List<String> initialImageUrls;
  final String confirmedProductName;
  final String? userPrice;
  final String? userDescription;
  final String? categoryName;
  final String? subCategoryName;
  // [V3 REFACTOR] '룰 엔진' 종속성(ruleId, rule, missingKeys, foundEvidence) 제거
  // 'initialProductAnalysis'가 반환한 '단순 텍스트 제안' 목록을 받습니다.
  final List<String> suggestedShots;

  const AiEvidenceSuggestionScreen({
    super.key,
    required this.productId,
    required this.categoryId,
    required this.initialImageUrls,
    required this.confirmedProductName,
    this.userPrice,
    this.userDescription,
    this.categoryName,
    this.subCategoryName,
    required this.suggestedShots,
  });

  @override
  State<AiEvidenceSuggestionScreen> createState() =>
      _AiEvidenceSuggestionScreenState();
}

class _AiEvidenceSuggestionScreenState
    extends State<AiEvidenceSuggestionScreen> {
  final ImagePicker _picker = ImagePicker();
  final _uuid = const Uuid(); // [Task 108]
  bool _submitting = false;
  bool _isReportLoading = false;
  // [Task 108] 1:N 매칭을 위해 'XFile' -> 'List<XFile>'로 변경
  final Map<int, List<XFile>> _pickedImages = {};
  final Set<int> _skippedShots = {};
  // [V3 REFACTOR] 'foundEvidence' (초기 이미지에서 증거 찾기) 기능은
  // '룰 엔진'과 강하게 결합되어 있었으므로 V3 단순화에서 제거합니다.

  // [V3 PENDING] 'pending' 저장을 위해 현재 유저 모델 상태 추가
  UserModel? _currentUserModel;

  @override
  void initState() {
    super.initState();
    // 'pending' 저장 시 위치 정보가 필요하므로 유저 정보를 미리 로드합니다.
    _fetchUserModel();
  }

  Future<void> _fetchUserModel() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (userDoc.exists && mounted) {
      setState(() => _currentUserModel = UserModel.fromFirestore(userDoc));
    }
  }

  // [작업 70] 1. 카메라/갤러리 선택 팝업
  // [작업 71/72] 1. 카메라/갤러리/"기존 사진" 선택 팝업
  Future<void> _pick(int index) async {
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
            title: Text(
                'ai_flow.common.pick_gallery_multi'.tr()), // "갤러리에서 여러 장 선택"
            onTap: () => Navigator.pop(context, ImageSource.gallery),
          ),
          // [V3 REFACTOR] 'foundEvidence' 기능이 제거됨에 따라
          // "기존 사진에서 선택" UI 로직도 함께 제거합니다.
        ],
      ),
    );

    // 사용자가 '카메라' 또는 '갤러리'를 선택한 경우
    if (result != null && result is ImageSource) {
      await _pickImageInternal(result, index);
    }
  }

  // [작업 71/72] 2. 기존 사진 목록(캐러셀)을 보여주고 선택하게 하는 2차 팝업
  // [V3 REFACTOR] '룰 엔진'의 'foundEvidence' 기능이 제거됨에 따라
  // "기존 사진에서 선택" 팝업(_showInitialImagePicker)을 제거합니다.

  // [작업 71/72] 3. 실제 이미지 선택 로직
  Future<void> _pickImageInternal(ImageSource source, int startingIndex) async {
    try {
      if (source == ImageSource.camera) {
        // 1. 카메라로 1장 찍기
        final XFile? img = await _picker.pickImage(
          source: source,
          imageQuality: 80,
          maxWidth: 1024,
        );
        if (img != null && mounted) {
          setState(() {
            _pickedImages.putIfAbsent(startingIndex, () => []).add(img);
            _skippedShots.remove(startingIndex);
          });
        }
      } else if (source == ImageSource.gallery) {
        // 2. 갤러리에서 여러 장 가져오기
        final List<XFile> picked = await _picker.pickMultiImage(
          imageQuality: 80,
          maxWidth: 1024,
        );

        if (picked.isNotEmpty && mounted) {
          setState(() {
            _pickedImages.putIfAbsent(startingIndex, () => []).addAll(picked);
            _skippedShots.remove(startingIndex);
          });
        }
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

  void _skip(int index) {
    setState(() {
      _pickedImages.remove(index);
      _skippedShots.add(index);
    });
  }

  /// [V3 PENDING] AI가 'suspicious'로 판단한 항목을 'pending' 상태로 저장하는 함수
  /// (ai_final_report_screen.dart의 _submitProductSale 로직 기반)
  Future<void> _submitProductAsPending(
    Map<String, dynamic> finalAiReport,
    List<String> allImageUrls,
    User user,
  ) async {
    if (_currentUserModel == null) {
      await _fetchUserModel(); // 혹시 로드가 안됐으면 다시 시도
      if (_currentUserModel == null) {
        throw Exception('User data could not be loaded.');
      }
    }

    final int userSelectedPrice = int.tryParse(widget.userPrice ?? '0') ?? 0;

    // V3 스키마 기반의 가격 파싱 (ai_final_report_screen과 동일)
    int aiSuggestedPrice = 0;
    final dynamic priceMap = finalAiReport['priceAssessment'];
    if (priceMap is Map) {
      aiSuggestedPrice = (priceMap['suggestedMin'] as num?)?.toInt() ?? 0;
    }

    finalAiReport['user_selected_price'] = userSelectedPrice;
    finalAiReport['suggested_price'] = aiSuggestedPrice;
    finalAiReport['price_suggestion'] = aiSuggestedPrice;
    finalAiReport['ai_recommended_price'] = aiSuggestedPrice;

    final Map<String, dynamic> productData = {
      'id': widget.productId,
      'userId': user.uid,
      'title': widget.confirmedProductName,
      'description': widget.userDescription ?? '',
      'imageUrls': allImageUrls,
      'categoryId': widget.categoryId,
      'price': (userSelectedPrice > 0) ? userSelectedPrice : aiSuggestedPrice,
      'negotiable': false,
      'tags': const [],
      'locationName': _currentUserModel!.locationName,
      'locationParts': _currentUserModel!.locationParts,
      'geoPoint': _currentUserModel!.geoPoint,
      'status': 'pending', // [V3 PENDING] 핵심: 'pending'으로 설정
      'condition': 'used',
      'transactionPlace': null,
      'updatedAt': Timestamp.now(),
      'isAiVerified': false, // [V3 PENDING] 관리자 승인 전
      'aiVerificationStatus': 'pending_admin', // [V3 PENDING]
      'aiReport': finalAiReport,
      'aiVerificationData': finalAiReport,
      'isAiFreeTierUsed': true,
      'aiReportSourceDescription': widget.userDescription ?? '',
      'aiReportSourceImages': allImageUrls,
    };

    await FirebaseFirestore.instance
        .collection('products')
        .doc(widget.productId)
        .set(productData, SetOptions(merge: true));

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'productIds': FieldValue.arrayUnion([widget.productId])
    });
  }

  Future<void> _continue() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated.');

      final Map<String, String> guided = {};
      // [Task 108] 모든 선택된 사진들을 업로드하여 guided 맵에 추가
      for (final entry in _pickedImages.entries) {
        final List<XFile> photoList = entry.value;
        for (final XFile file in photoList) {
          final url = await uploadProductImage(file, user.uid);
          final String uniqueKey = 'guided_${_uuid.v4()}';
          guided[uniqueKey] = url;
        }
      }
      // Call the Cloud Function in the same region as the deployed functions
      // (server uses 'asia-southeast2' via setGlobalOptions). Use the
      // regioned instance to avoid firebase_functions/not-found errors.
      final HttpsCallable callable =
          FirebaseFunctions.instanceFor(region: 'asia-southeast2')
              .httpsCallable('generatefinalreport');

      // [V3 REFACTOR] 'generatefinalreport' V3 페이로드
      final payload = <String, dynamic>{
        'imageUrls': {
          'initial': widget.initialImageUrls,
          'guided': guided,
          // [V3 REFACTOR] 'found_evidence', 'ruleId', 'skippedKeys' 제거
        },
        'confirmedProductName': widget.confirmedProductName,
        'categoryName': widget.categoryName,
        'subCategoryName': widget.subCategoryName,
        'userPrice': widget.userPrice,
        'userDescription': widget.userDescription,
        'locale': context.locale.languageCode,
      };

      if (!mounted) return;
      setState(() => _isReportLoading = true);

      try {
        final result = await callable.call(payload);

        final reportRaw = (result.data as Map<dynamic, dynamic>?)?['report'];
        final report = (reportRaw != null && reportRaw is Map)
            ? Map<String, dynamic>.from(reportRaw)
            : null;

        // [V3 PENDING] "블라인드 제출" 로직
        final String trustVerdict =
            report?['trustVerdict'] as String? ?? 'clear';

        // [V3 REFACTOR] V3 '단순 엔진' 스키마(Task 62) 검증
        if (report == null ||
            report['itemSummary'] == null ||
            report['condition'] == null) {
          throw Exception('AI가 유효한 V3 리포트(itemSummary/condition)를 생성하지 못했습니다.');
        }

        if (!mounted) return;

        if (trustVerdict == 'suspicious' || trustVerdict == 'fraud') {
          // [V3 PENDING] AI가 "의심" 판정: "블라인드 제출" 실행
          Logger.info("AI Verdict: SUSPICIOUS. Submitting as 'pending'.");
          final allImageUrls = [...widget.initialImageUrls, ...guided.values];
          await _submitProductAsPending(report, allImageUrls, user);

          BArtSnackBar.showSuccessSnackBar(
            title: 'ai_flow.final_report.pending_title'
                .tr(), // [Task 86] 번역 키 추가 필요
            message: 'ai_flow.final_report.pending_message'
                .tr(), // [Task 86] 번역 키 추가 필요
          );
          // [Task 86] UX 개선: 이전 화면이 아닌 홈 화면으로 바로 이동
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else {
          // [V3 PENDING] AI가 "Clear" 판정: 기존 로직대로 최종 보고서 화면으로 이동
          Logger.info("AI Verdict: CLEAR. Navigating to AiFinalReportScreen.");
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => AiFinalReportScreen(
              productId: widget.productId,
              categoryId: widget.categoryId,
              finalReport: report,
              initialImageUrls: widget.initialImageUrls,
              guidedImageUrls: guided,
              confirmedProductName: widget.confirmedProductName,
              userPrice: widget.userPrice,
              userDescription: widget.userDescription,
            ),
          ));
        }
      } on FirebaseFunctionsException catch (e) {
        // Handle known Cloud Functions errors
        if (e.code == 'deadline-exceeded') {
          BArtSnackBar.showErrorSnackBar(
              title: '요청 시간 초과',
              message: 'AI 분석 시간이 초과되었습니다. 잠시 후 다시 시도해 주세요.');
        } else {
          BArtSnackBar.showErrorSnackBar(
              title: 'AI 리포트 생성 실패',
              message: e.message ?? '알 수 없는 오류가 발생했습니다.');
        }
        Logger.error('AI Final Report Error (_continue)',
            error: e, stackTrace: e.stackTrace);
      } catch (e, stackTrace) {
        Logger.error('AI Final Report Error (_continue)',
            error: e, stackTrace: stackTrace);

        // [Fix] Get.context가 null일 때 스낵바가 안 뜨는 문제 해결
        // 현재 위젯의 context를 직접 사용하여 확실하게 표시
        if (mounted) {
          final errorMessage = e.toString().replaceAll('Exception: ', '');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('오류: $errorMessage'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              action: SnackBarAction(
                  label: '확인', textColor: Colors.white, onPressed: () {}),
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isReportLoading = false);
      }
    } catch (e, stackTrace) {
      if (!mounted) return;

      // [작업 41] 에러를 디버그 콘솔에 상세히 출력합니다.
      debugPrint("======================================================");
      debugPrint("❌ AI Final Report Error (_continue):");
      debugPrint("Error: ${e.toString()}");
      debugPrint("StackTrace: ${stackTrace.toString()}");
      debugPrint("======================================================");

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'marketplace.error'.tr(namedArgs: {'error': e.toString()}))));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  // [V3 REFACTOR] '룰 엔진' 종속적인 _getShotName, _getShotDesc 헬퍼 함수 삭제
  // (총 60줄 이상 삭제)

  @override
  Widget build(BuildContext context) {
    // [V3 REFACTOR] '룰 엔진'에 의존한 복잡한 'keys' 목록 생성 로직 (약 20줄) 삭제.
    // V3는 'widget.suggestedShots' (List<String>)를 직접 사용합니다.
    final List<String> suggestions = widget.suggestedShots;
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
                    itemCount: suggestions.length,
                    itemBuilder: (context, index) {
                      // [V3 REFACTOR] '룰 키' 대신 '인덱스'와 '텍스트' 사용
                      final String suggestionText = suggestions[index];
                      final bool skipped = _skippedShots.contains(index);
                      final List<XFile> pickedList = _pickedImages[index] ?? [];

                      // [V3 UI FIX] Show number of added photos when multiple images present
                      final Widget? subtitleWidget;
                      if (pickedList.isNotEmpty) {
                        subtitleWidget = Text('ai_flow.common.added_photos'.tr(
                            namedArgs: {
                              'count': pickedList.length.toString()
                            }));
                      } else if (skipped) {
                        subtitleWidget = Text('ai_flow.common.skipped'.tr());
                      } else {
                        subtitleWidget = null; // [V3 UI FIX] 중복 안내 문구 제거
                      }

                      final Widget trailingWidget;
                      if (skipped) {
                        trailingWidget = TextButton(
                            onPressed: () => _pick(index),
                            child: Text('ai_flow.common.add_photo'.tr()));
                      } else if (pickedList.isNotEmpty) {
                        trailingWidget = TextButton(
                            onPressed: () => _pick(index),
                            child: Text('ai_flow.common.add_more'.tr()));
                      } else {
                        trailingWidget = Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextButton(
                                onPressed: () => _pick(index),
                                child: Text('ai_flow.common.add_photo'.tr())),
                            const SizedBox(width: 8),
                            TextButton(
                                onPressed: () => _skip(index),
                                child: Text('ai_flow.common.skip'.tr())),
                          ],
                        );
                      }

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 6),
                        // [V3 REFACTOR] 'isFound' 로직 제거
                        color: skipped
                            ? Colors.grey[200]
                            : (pickedList.isNotEmpty)
                                ? Colors.green[50]
                                : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8.0, horizontal: 16.0),
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            // [V3 REFACTOR] 'isFound' 로직 제거
                            leading: Icon(
                              pickedList.isNotEmpty
                                  ? Icons.check_circle
                                  : skipped
                                      ? Icons.check_circle
                                      : Icons.add_a_photo_outlined,
                              color: pickedList.isNotEmpty
                                  ? Colors.green
                                  : skipped
                                      ? Colors.grey
                                      : Theme.of(context).colorScheme.primary,
                            ),
                            // [V3 REFACTOR] '_getShotName' 제거, 'suggestionText' 직접 사용
                            title: Text(suggestionText),
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
          onPressed: (_submitting || _isReportLoading) ? null : _continue,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          ),
          child: (_submitting || _isReportLoading)
              ? Column(
                  // [Task 86] UI 개선: 텍스트 + 진행 바로 변경
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('ai_flow.final_report.loading'
                        .tr()), // "최종 보고서 생성 중..."
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context)
                              .colorScheme
                              .onPrimary
                              .withValues(alpha: 0.8)),
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .onPrimary
                          .withValues(alpha: 0.2),
                    ),
                  ],
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
