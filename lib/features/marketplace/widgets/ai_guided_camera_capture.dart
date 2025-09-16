// lib/features/marketplace/widgets/ai_guided_camera_capture.dart

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:bling_app/features/marketplace/data/ai_verification_service.dart';
// import 'dart:io'; // for File
// import 'dart:convert'; // for base64Encode

// ✅ [개선] 분석 결과 화면을 import 합니다.
import 'package:bling_app/features/marketplace/screens/ai_inspection_result_screen.dart';



// 촬영 단계를 정의하는 Enum
enum CameraGuideStep {
  front, // 정면
  back, // 후면
  tag, // 태그
  damage, // 손상 부위
  completed, // 완료
}

class AiGuidedCameraCapture extends StatefulWidget {
  const AiGuidedCameraCapture({super.key});

  @override
  State<AiGuidedCameraCapture> createState() => _AiGuidedCameraCaptureState();
}

class _AiGuidedCameraCaptureState extends State<AiGuidedCameraCapture> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  CameraGuideStep _currentStep = CameraGuideStep.front;
  final List<XFile> _capturedImages = [];
  // final AiVerificationService _aiService = AiVerificationService(); // (unused)
  bool _isAnalyzing = false; // 로딩 상태를 위한 변수 추가
  bool _isTakingPicture = false; // ✅ 중복 촬영 방지를 위한 플래그 추가
  
  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      _controller = CameraController(_cameras![0], ResolutionPreset.high);
      await _controller!.initialize();
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  // 각 단계에 맞는 가이드 텍스트를 반환하는 함수
  String _getGuideText() {
    switch (_currentStep) {
      case CameraGuideStep.front:
        return '상품의 정면을 프레임에 맞춰 촬영해주세요.';
      case CameraGuideStep.back:
        return '상품의 후면을 촬영해주세요.';
      case CameraGuideStep.tag:
        return '브랜드나 사이즈 태그를 선명하게 촬영해주세요.';
      case CameraGuideStep.damage:
        return '손상된 부분이 있다면 가까이에서 촬영해주세요. (없으면 건너뛰기)';
      case CameraGuideStep.completed:
        return '촬영이 완료되었습니다.';
    }
  }

  // 다음 촬영 단계로 넘어가는 함수
  void _moveToNextStep() {
    if (_currentStep == CameraGuideStep.damage) {
      setState(() {
        _currentStep = CameraGuideStep.completed;
      });
      // 모든 사진 촬영 완료 후 로직 (예: AI 분석 요청)
      _submitForAnalysis();
    } else {
      setState(() {
        _currentStep = CameraGuideStep.values[_currentStep.index + 1];
      });
    }
  }

  // 사진 촬영 함수
  Future<void> _takePicture() async {
  // ✅ 중복 실행 방지
    if (_isTakingPicture || !_controller!.value.isInitialized) {
      return;
    }

    setState(() {
      _isTakingPicture = true; // 촬영 시작
    });

    try {
      // ✅ 사진 촬영이 완료될 때까지 여기서 기다립니다.
      final XFile file = await _controller!.takePicture();
      
      // ✅ 촬영된 파일이 유효한지 확인 후 리스트에 추가합니다.
      _capturedImages.add(file);
      debugPrint('[CAPTURE_SUCCESS] 사진 촬영 성공: ${file.path}');

      // ✅ 촬영 성공 후 다음 단계로 이동합니다.
      _moveToNextStep();

    } catch (e) {
      debugPrint('[CAPTURE_ERROR] 사진 촬영 에러: $e');
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사진 촬영에 실패했습니다: $e')),
        );
      }
    } finally {
      // ✅ 성공/실패 여부와 관계없이 촬영 상태를 해제합니다.
      if(mounted) {
        setState(() {
          _isTakingPicture = false;
        });
      }
    }
  }

  // 분석 제출 함수 수정: 촬영된 이미지를 결과 화면으로 전달
  void _submitForAnalysis() async {
    // ✅ 이미지 리스트가 비어있는지 다시 한번 최종 확인
    if (_capturedImages.isEmpty) {
      debugPrint('[SUBMIT_ERROR] 제출할 이미지가 없습니다.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('촬영된 사진이 없습니다. 다시 시도해주세요.')),
      );
      return;
    }

    setState(() { _isAnalyzing = true; });

    // ✅ 첫 번째 이미지만 분석 요청 (향후 확장 가능)
    AiVerificationResult? aiReport;
    try {
      // XFile → File 변환
      final file = File(_capturedImages.first.path);
      aiReport = await AiVerificationService.verifyFile(file);
    } catch (e) {
      debugPrint('[AI_ERROR] $e');
    }

    if (!mounted) return;

    setState(() { _isAnalyzing = false; });

    if (aiReport != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AiInspectionResultScreen(
            aiReport: aiReport!.toMap(),
            // ✅ [매우 중요] 촬영된 이미지 리스트를 결과 화면으로 전달합니다.
            capturedImages: _capturedImages,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('AI 분석에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

  // ✅ [신규] 썸네일 목록을 만드는 위젯
  Widget _buildThumbnailPreview() {
    if (_capturedImages.isEmpty) {
      return const SizedBox.shrink(); // 촬영된 사진이 없으면 아무것도 표시하지 않음
    }

    return Positioned(
      bottom: 120, // 촬영 버튼 위쪽에 위치
      left: 0,
      right: 0,
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        color: Colors.black.withValues(alpha: 0.3),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _capturedImages.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: Image.file(
                  File(_capturedImages[index].path),
                  width: 64,
                  height: 64,
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: const Text('AI 검수 촬영')),
      body: Stack(
        alignment: Alignment.center,
        children: [
          CameraPreview(_controller!),
          // 가이드 텍스트 및 오버레이
          Positioned(
            top: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _getGuideText(),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
          // 하단 버튼 영역
          Positioned(
            bottom: 30,
            child: Column(
              children: [
                if (_currentStep != CameraGuideStep.completed)
                  FloatingActionButton(
                    onPressed: _takePicture,
                    child: const Icon(Icons.camera_alt),
                  ),
                if (_currentStep == CameraGuideStep.damage)
                  TextButton(
                    onPressed: _moveToNextStep,
                    child: const Text('손상 부위 없음 (건너뛰기)',
                        style: TextStyle(color: Colors.white)),
                  )
              ],
            ),
          ),

            // ✅ [개선] 신규 추가된 썸네일 목록 위젯
          _buildThumbnailPreview(),

          // 하단 버튼 영역
          Positioned(
            bottom: 30,
            child: Column(
              children: [
                if (_currentStep != CameraGuideStep.completed)
                  FloatingActionButton(
                    onPressed: _isTakingPicture ? null : _takePicture,
                    child: _isTakingPicture 
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
                        : const Icon(Icons.camera_alt),
                  ),
                if (_currentStep == CameraGuideStep.damage)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextButton(
                      onPressed: _moveToNextStep,
                      child: const Text('손상 부위 없음 (건너뛰기)', style: TextStyle(color: Colors.white)),
                    ),
                  )
              ],
            ),
          ),


          if (_isAnalyzing)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 20),
                    Text(
                      'AI가 상품을 분석 중입니다...',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
