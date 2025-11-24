///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:slang/generated.dart';
import 'strings.g.dart';

// Path: <root>
class TranslationsKo extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsKo({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ko,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ko>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsKo _root = this; // ignore: unused_field

	@override 
	TranslationsKo $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsKo(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsLoginKo login = _TranslationsLoginKo._(_root);
	@override late final _TranslationsMainKo main = _TranslationsMainKo._(_root);
	@override late final _TranslationsSearchKo search = _TranslationsSearchKo._(_root);
	@override late final _TranslationsDrawerKo drawer = _TranslationsDrawerKo._(_root);
	@override late final _TranslationsMarketplaceKo marketplace = _TranslationsMarketplaceKo._(_root);
	@override late final _TranslationsAiFlowKo aiFlow = _TranslationsAiFlowKo._(_root);
	@override late final _TranslationsRegistrationFlowKo registrationFlow = _TranslationsRegistrationFlowKo._(_root);
	@override late final _TranslationsMyBlingKo myBling = _TranslationsMyBlingKo._(_root);
	@override late final _TranslationsProfileViewKo profileView = _TranslationsProfileViewKo._(_root);
	@override late final _TranslationsSettingsKo settings = _TranslationsSettingsKo._(_root);
	@override late final _TranslationsFriendRequestsKo friendRequests = _TranslationsFriendRequestsKo._(_root);
	@override late final _TranslationsSentFriendRequestsKo sentFriendRequests = _TranslationsSentFriendRequestsKo._(_root);
	@override late final _TranslationsBlockedUsersKo blockedUsers = _TranslationsBlockedUsersKo._(_root);
	@override late final _TranslationsRejectedUsersKo rejectedUsers = _TranslationsRejectedUsersKo._(_root);
	@override late final _TranslationsPromptKo prompt = _TranslationsPromptKo._(_root);
	@override late final _TranslationsLocationKo location = _TranslationsLocationKo._(_root);
	@override late final _TranslationsProfileEditKo profileEdit = _TranslationsProfileEditKo._(_root);
	@override late final _TranslationsMainFeedKo mainFeed = _TranslationsMainFeedKo._(_root);
	@override late final _TranslationsPostCardKo postCard = _TranslationsPostCardKo._(_root);
	@override late final _TranslationsTimeKo time = _TranslationsTimeKo._(_root);
	@override late final _TranslationsProductCardKo productCard = _TranslationsProductCardKo._(_root);
	@override late final _TranslationsLocalNewsFeedKo localNewsFeed = _TranslationsLocalNewsFeedKo._(_root);
	@override late final _TranslationsCategoriesKo categories = _TranslationsCategoriesKo._(_root);
	@override late final _TranslationsLocalNewsCreateKo localNewsCreate = _TranslationsLocalNewsCreateKo._(_root);
	@override late final _TranslationsLocalNewsDetailKo localNewsDetail = _TranslationsLocalNewsDetailKo._(_root);
	@override late final _TranslationsLocalNewsEditKo localNewsEdit = _TranslationsLocalNewsEditKo._(_root);
	@override late final _TranslationsCommentInputFieldKo commentInputField = _TranslationsCommentInputFieldKo._(_root);
	@override late final _TranslationsCommentListViewKo commentListView = _TranslationsCommentListViewKo._(_root);
	@override late final _TranslationsCommonKo common = _TranslationsCommonKo._(_root);
	@override late final _TranslationsReportDialogKo reportDialog = _TranslationsReportDialogKo._(_root);
	@override late final _TranslationsReplyDeleteKo replyDelete = _TranslationsReplyDeleteKo._(_root);
	@override late final _TranslationsReportReasonsKo reportReasons = _TranslationsReportReasonsKo._(_root);
	@override late final _TranslationsDeleteConfirmKo deleteConfirm = _TranslationsDeleteConfirmKo._(_root);
	@override late final _TranslationsReplyInputFieldKo replyInputField = _TranslationsReplyInputFieldKo._(_root);
	@override late final _TranslationsChatListKo chatList = _TranslationsChatListKo._(_root);
	@override late final _TranslationsChatRoomKo chatRoom = _TranslationsChatRoomKo._(_root);
	@override late final _TranslationsJobsKo jobs = _TranslationsJobsKo._(_root);
	@override late final _TranslationsFindFriendKo findFriend = _TranslationsFindFriendKo._(_root);
	@override late final _TranslationsInterestsKo interests = _TranslationsInterestsKo._(_root);
	@override late final _TranslationsFriendDetailKo friendDetail = _TranslationsFriendDetailKo._(_root);
	@override late final _TranslationsLocationFilterKo locationFilter = _TranslationsLocationFilterKo._(_root);
	@override late final _TranslationsClubsKo clubs = _TranslationsClubsKo._(_root);
	@override late final _TranslationsFindfriendKo findfriend = _TranslationsFindfriendKo._(_root);
	@override late final _TranslationsAuctionsKo auctions = _TranslationsAuctionsKo._(_root);
	@override late final _TranslationsLocalStoresKo localStores = _TranslationsLocalStoresKo._(_root);
	@override late final _TranslationsPomKo pom = _TranslationsPomKo._(_root);
	@override late final _TranslationsRealEstateKo realEstate = _TranslationsRealEstateKo._(_root);
	@override late final _TranslationsLostAndFoundKo lostAndFound = _TranslationsLostAndFoundKo._(_root);
	@override late final _TranslationsCommunityKo community = _TranslationsCommunityKo._(_root);
	@override late final _TranslationsSharedKo shared = _TranslationsSharedKo._(_root);
	@override late final _TranslationsLinkPreviewKo linkPreview = _TranslationsLinkPreviewKo._(_root);
	@override String get selectCategory => '카테고리 선택';
	@override String get addressNeighborhood => '동네';
	@override String get addressDetailHint => '상세 주소';
	@override late final _TranslationsLocalNewsTagResultKo localNewsTagResult = _TranslationsLocalNewsTagResultKo._(_root);
	@override late final _TranslationsAdminKo admin = _TranslationsAdminKo._(_root);
	@override late final _TranslationsTagsKo tags = _TranslationsTagsKo._(_root);
	@override late final _TranslationsBoardsKo boards = _TranslationsBoardsKo._(_root);
	@override String get locationSettingError => '위치를 설정하지 못했습니다.';
	@override String get signupFailRequired => '필수 입력 항목입니다.';
	@override late final _TranslationsSignupKo signup = _TranslationsSignupKo._(_root);
	@override String get signupFailDefault => '회원가입에 실패했습니다.';
	@override String get signupFailWeakPassword => '비밀번호가 너무 약합니다.';
	@override String get signupFailEmailInUse => '이미 사용 중인 이메일입니다.';
	@override String get signupFailInvalidEmail => '이메일 형식이 올바르지 않습니다.';
	@override String get signupFailUnknown => '알 수 없는 오류가 발생했습니다.';
	@override String get categoryEmpty => '카테고리 없음';
	@override late final _TranslationsUserKo user = _TranslationsUserKo._(_root);
	@override String get signupFailPasswordMismatch => '비밀번호가 일치하지 않습니다.';
}

// Path: login
class _TranslationsLoginKo extends TranslationsLoginId {
	_TranslationsLoginKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '로그인';
	@override String get subtitle => '블링에서 쉽게 사고팔기!';
	@override String get emailHint => '이메일';
	@override String get passwordHint => '비밀번호';
	@override late final _TranslationsLoginButtonsKo buttons = _TranslationsLoginButtonsKo._(_root);
	@override late final _TranslationsLoginLinksKo links = _TranslationsLoginLinksKo._(_root);
	@override late final _TranslationsLoginAlertsKo alerts = _TranslationsLoginAlertsKo._(_root);
}

// Path: main
class _TranslationsMainKo extends TranslationsMainId {
	_TranslationsMainKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsMainAppBarKo appBar = _TranslationsMainAppBarKo._(_root);
	@override late final _TranslationsMainTabsKo tabs = _TranslationsMainTabsKo._(_root);
	@override late final _TranslationsMainBottomNavKo bottomNav = _TranslationsMainBottomNavKo._(_root);
	@override late final _TranslationsMainErrorsKo errors = _TranslationsMainErrorsKo._(_root);
	@override String get myTown => '내 동네';
	@override late final _TranslationsMainMapViewKo mapView = _TranslationsMainMapViewKo._(_root);
	@override late final _TranslationsMainSearchKo search = _TranslationsMainSearchKo._(_root);
}

// Path: search
class _TranslationsSearchKo extends TranslationsSearchId {
	_TranslationsSearchKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get resultsTitle => '\'{keyword}\' 검색 결과';
	@override late final _TranslationsSearchEmptyKo empty = _TranslationsSearchEmptyKo._(_root);
	@override String get prompt => '검색어 입력';
	@override late final _TranslationsSearchSheetKo sheet = _TranslationsSearchSheetKo._(_root);
	@override String get results => '결과';
}

// Path: drawer
class _TranslationsDrawerKo extends TranslationsDrawerId {
	_TranslationsDrawerKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get editProfile => '프로필 수정';
	@override String get bookmarks => '북마크';
	@override String get uploadSampleData => '샘플 데이터 업로드';
	@override String get logout => '로그아웃';
	@override late final _TranslationsDrawerTrustDashboardKo trustDashboard = _TranslationsDrawerTrustDashboardKo._(_root);
	@override String get runDataFix => '데이터 수정 실행';
}

// Path: marketplace
class _TranslationsMarketplaceKo extends TranslationsMarketplaceId {
	_TranslationsMarketplaceKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get error => '오류: {error}';
	@override String get empty => '등록된 상품이 없습니다.\n+ 버튼을 눌러 첫 상품을 올려보세요!';
	@override late final _TranslationsMarketplaceRegistrationKo registration = _TranslationsMarketplaceRegistrationKo._(_root);
	@override late final _TranslationsMarketplaceEditKo edit = _TranslationsMarketplaceEditKo._(_root);
	@override late final _TranslationsMarketplaceDetailKo detail = _TranslationsMarketplaceDetailKo._(_root);
	@override late final _TranslationsMarketplaceDialogKo dialog = _TranslationsMarketplaceDialogKo._(_root);
	@override late final _TranslationsMarketplaceErrorsKo errors = _TranslationsMarketplaceErrorsKo._(_root);
	@override late final _TranslationsMarketplaceConditionKo condition = _TranslationsMarketplaceConditionKo._(_root);
	@override late final _TranslationsMarketplaceReservationKo reservation = _TranslationsMarketplaceReservationKo._(_root);
	@override late final _TranslationsMarketplaceStatusKo status = _TranslationsMarketplaceStatusKo._(_root);
	@override late final _TranslationsMarketplaceAiKo ai = _TranslationsMarketplaceAiKo._(_root);
	@override late final _TranslationsMarketplaceTakeoverKo takeover = _TranslationsMarketplaceTakeoverKo._(_root);
	@override String get aiBadge => 'AI 인증';
	@override String get setLocationPrompt => '동네를 먼저 설정하면 중고거래 상품을 볼 수 있어요!';
}

// Path: aiFlow
class _TranslationsAiFlowKo extends TranslationsAiFlowId {
	_TranslationsAiFlowKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsAiFlowCommonKo common = _TranslationsAiFlowCommonKo._(_root);
	@override late final _TranslationsAiFlowCtaKo cta = _TranslationsAiFlowCtaKo._(_root);
	@override late final _TranslationsAiFlowCategorySelectionKo categorySelection = _TranslationsAiFlowCategorySelectionKo._(_root);
	@override late final _TranslationsAiFlowGalleryUploadKo galleryUpload = _TranslationsAiFlowGalleryUploadKo._(_root);
	@override late final _TranslationsAiFlowPredictionKo prediction = _TranslationsAiFlowPredictionKo._(_root);
	@override late final _TranslationsAiFlowGuidedCameraKo guidedCamera = _TranslationsAiFlowGuidedCameraKo._(_root);
	@override late final _TranslationsAiFlowFinalReportKo finalReport = _TranslationsAiFlowFinalReportKo._(_root);
	@override late final _TranslationsAiFlowEvidenceKo evidence = _TranslationsAiFlowEvidenceKo._(_root);
	@override late final _TranslationsAiFlowErrorKo error = _TranslationsAiFlowErrorKo._(_root);
}

// Path: registrationFlow
class _TranslationsRegistrationFlowKo extends TranslationsRegistrationFlowId {
	_TranslationsRegistrationFlowKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '판매할 상품 유형 선택';
	@override String get newItemTitle => '새 상품·일반 중고 등록';
	@override String get newItemDesc => '안 쓰는 새 상품과 일반 중고 상품을 빠르게 등록해요.';
	@override String get usedItemTitle => '중고 상품 (AI 인증)';
	@override String get usedItemDesc => 'AI가 상품을 분석해 신뢰를 높이고 판매를 도와줍니다.';
}

// Path: myBling
class _TranslationsMyBlingKo extends TranslationsMyBlingId {
	_TranslationsMyBlingKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '나의 블링';
	@override String get editProfile => '프로필 편집';
	@override String get settings => '설정';
	@override String get posts => '게시글';
	@override String get followers => '팔로워';
	@override String get neighbors => '이웃';
	@override String get friends => '친구';
	@override late final _TranslationsMyBlingStatsKo stats = _TranslationsMyBlingStatsKo._(_root);
	@override late final _TranslationsMyBlingTabsKo tabs = _TranslationsMyBlingTabsKo._(_root);
	@override String get friendRequests => '받은 친구 요청';
	@override String get sentFriendRequests => '보낸 친구 요청';
}

// Path: profileView
class _TranslationsProfileViewKo extends TranslationsProfileViewId {
	_TranslationsProfileViewKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '프로필';
	@override late final _TranslationsProfileViewTabsKo tabs = _TranslationsProfileViewTabsKo._(_root);
	@override String get noPosts => '아직 게시글이 없습니다.';
	@override String get noInterests => '등록된 관심사가 없습니다.';
}

// Path: settings
class _TranslationsSettingsKo extends TranslationsSettingsId {
	_TranslationsSettingsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '설정';
	@override String get accountPrivacy => '계정 및 개인정보';
	@override late final _TranslationsSettingsNotificationsKo notifications = _TranslationsSettingsNotificationsKo._(_root);
	@override String get appInfo => '앱 정보';
}

// Path: friendRequests
class _TranslationsFriendRequestsKo extends TranslationsFriendRequestsId {
	_TranslationsFriendRequestsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '받은 친구 요청';
	@override String get noRequests => '받은 친구 요청이 없습니다.';
	@override String get acceptSuccess => '친구 요청을 수락했습니다.';
	@override String get rejectSuccess => '친구 요청을 거절했습니다.';
	@override String get error => '오류가 발생했습니다: {error}';
	@override late final _TranslationsFriendRequestsTooltipKo tooltip = _TranslationsFriendRequestsTooltipKo._(_root);
	@override String get defaultChatMessage => '이제 친구가 되었어요! 대화를 시작해 보세요.';
}

// Path: sentFriendRequests
class _TranslationsSentFriendRequestsKo extends TranslationsSentFriendRequestsId {
	_TranslationsSentFriendRequestsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '보낸 친구 요청';
	@override String get noRequests => '보낸 친구 요청이 없습니다.';
	@override String get statusLabel => '상태: {status}';
	@override late final _TranslationsSentFriendRequestsStatusKo status = _TranslationsSentFriendRequestsStatusKo._(_root);
}

// Path: blockedUsers
class _TranslationsBlockedUsersKo extends TranslationsBlockedUsersId {
	_TranslationsBlockedUsersKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '차단한 사용자';
	@override String get noBlockedUsers => '아직 아무도 차단하지 않았습니다.';
	@override String get unblock => '차단 해제';
	@override late final _TranslationsBlockedUsersUnblockDialogKo unblockDialog = _TranslationsBlockedUsersUnblockDialogKo._(_root);
	@override String get unblockSuccess => '{nickname} 님의 차단을 해제했습니다.';
	@override String get unblockFailure => '차단 해제에 실패했습니다: {error}';
	@override String get unknownUser => '알 수 없는 사용자';
	@override String get empty => '차단한 사용자가 없습니다.';
}

// Path: rejectedUsers
class _TranslationsRejectedUsersKo extends TranslationsRejectedUsersId {
	_TranslationsRejectedUsersKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '거절한 사용자 관리';
	@override String get noRejectedUsers => '거절한 친구 요청이 없습니다.';
	@override String get unreject => '거절 취소';
	@override late final _TranslationsRejectedUsersUnrejectDialogKo unrejectDialog = _TranslationsRejectedUsersUnrejectDialogKo._(_root);
	@override String get unrejectSuccess => '{nickname} 님에 대한 거절 취소가 완료되었습니다.';
	@override String get unrejectFailure => '거절 취소에 실패했습니다: {error}';
}

// Path: prompt
class _TranslationsPromptKo extends TranslationsPromptId {
	_TranslationsPromptKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '블링에 오신 것을 환영합니다!';
	@override String get subtitle => '내 주변 소식과 중고거래를 보려면 먼저 동네를 설정해 주세요.';
	@override String get button => '내 동네 설정하기';
}

// Path: location
class _TranslationsLocationKo extends TranslationsLocationId {
	_TranslationsLocationKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '동네 설정';
	@override String get searchHint => '동네 이름으로 검색 (예: Serpong)';
	@override String get gpsButton => '현재 위치 사용';
	@override String get success => '동네가 설정되었습니다.';
	@override String get error => '동네 설정에 실패했습니다: {error}';
	@override String get empty => '동네 이름을 입력해 주세요.';
	@override String get permissionDenied => '내 동네를 찾으려면 위치 권한이 필요합니다.';
	@override String get rtLabel => 'RT';
	@override String get rwLabel => 'RW';
	@override String get rtHint => '예: 003';
	@override String get rwHint => '예: 007';
	@override String get rtRequired => 'RT를 입력해 주세요.';
	@override String get rwRequired => 'RW를 입력해 주세요.';
	@override String get rtRwInfo => 'RT/RW 정보는 공개되지 않으며, 신뢰도 및 동네 기능 향상을 위해서만 사용됩니다.';
	@override String get saveThisLocation => '이 위치 저장';
	@override String get manualSelect => '직접 선택';
	@override String get refreshFromGps => 'GPS로 다시 불러오기';
}

// Path: profileEdit
class _TranslationsProfileEditKo extends TranslationsProfileEditId {
	_TranslationsProfileEditKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '프로필 설정';
	@override String get nicknameHint => '닉네임';
	@override String get phoneHint => '전화번호';
	@override String get bioHint => '소개글';
	@override String get locationTitle => '위치';
	@override String get changeLocation => '변경';
	@override String get locationNotSet => '미설정';
	@override late final _TranslationsProfileEditInterestsKo interests = _TranslationsProfileEditInterestsKo._(_root);
	@override late final _TranslationsProfileEditPrivacyKo privacy = _TranslationsProfileEditPrivacyKo._(_root);
	@override String get saveButton => '변경 사항 저장';
	@override String get successMessage => '프로필이 성공적으로 업데이트되었습니다.';
	@override late final _TranslationsProfileEditErrorsKo errors = _TranslationsProfileEditErrorsKo._(_root);
}

// Path: mainFeed
class _TranslationsMainFeedKo extends TranslationsMainFeedId {
	_TranslationsMainFeedKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get error => '오류가 발생했습니다: {error}';
	@override String get empty => '새 게시글이 없습니다.';
}

// Path: postCard
class _TranslationsPostCardKo extends TranslationsPostCardId {
	_TranslationsPostCardKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get locationNotSet => '위치 미설정';
	@override String get location => '위치';
	@override String get authorNotFound => '작성자를 찾을 수 없습니다.';
}

// Path: time
class _TranslationsTimeKo extends TranslationsTimeId {
	_TranslationsTimeKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get now => '방금 전';
	@override String get minutesAgo => '{minutes}분 전';
	@override String get hoursAgo => '{hours}시간 전';
	@override String get daysAgo => '{days}일 전';
	@override String get dateFormat => 'yy.MM.dd';
	@override String get dateFormatLong => 'MMM d';
}

// Path: productCard
class _TranslationsProductCardKo extends TranslationsProductCardId {
	_TranslationsProductCardKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get currency => '\$';
}

// Path: localNewsFeed
class _TranslationsLocalNewsFeedKo extends TranslationsLocalNewsFeedId {
	_TranslationsLocalNewsFeedKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get setLocationPrompt => '동네 소식을 보려면 동네를 설정해 주세요!';
	@override String get allCategory => '전체';
	@override String get empty => '표시할 게시글이 없습니다.';
	@override String get error => '오류가 발생했습니다: {error}';
}

// Path: categories
class _TranslationsCategoriesKo extends TranslationsCategoriesId {
	_TranslationsCategoriesKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsCategoriesPostKo post = _TranslationsCategoriesPostKo._(_root);
	@override late final _TranslationsCategoriesAuctionKo auction = _TranslationsCategoriesAuctionKo._(_root);
}

// Path: localNewsCreate
class _TranslationsLocalNewsCreateKo extends TranslationsLocalNewsCreateId {
	_TranslationsLocalNewsCreateKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get appBarTitle => '새 글 만들기';
	@override String get title => '새 글 만들기';
	@override late final _TranslationsLocalNewsCreateFormKo form = _TranslationsLocalNewsCreateFormKo._(_root);
	@override late final _TranslationsLocalNewsCreateLabelsKo labels = _TranslationsLocalNewsCreateLabelsKo._(_root);
	@override late final _TranslationsLocalNewsCreateHintsKo hints = _TranslationsLocalNewsCreateHintsKo._(_root);
	@override late final _TranslationsLocalNewsCreateValidationKo validation = _TranslationsLocalNewsCreateValidationKo._(_root);
	@override late final _TranslationsLocalNewsCreateButtonsKo buttons = _TranslationsLocalNewsCreateButtonsKo._(_root);
	@override late final _TranslationsLocalNewsCreateAlertsKo alerts = _TranslationsLocalNewsCreateAlertsKo._(_root);
	@override String get success => '게시글이 등록되었습니다.';
	@override String get fail => '게시글 등록에 실패했습니다: {error}';
}

// Path: localNewsDetail
class _TranslationsLocalNewsDetailKo extends TranslationsLocalNewsDetailId {
	_TranslationsLocalNewsDetailKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get appBarTitle => '게시글';
	@override late final _TranslationsLocalNewsDetailMenuKo menu = _TranslationsLocalNewsDetailMenuKo._(_root);
	@override late final _TranslationsLocalNewsDetailStatsKo stats = _TranslationsLocalNewsDetailStatsKo._(_root);
	@override late final _TranslationsLocalNewsDetailButtonsKo buttons = _TranslationsLocalNewsDetailButtonsKo._(_root);
	@override String get confirmDelete => '이 게시글을 삭제하시겠습니까?';
	@override String get deleted => '게시글이 삭제되었습니다.';
}

// Path: localNewsEdit
class _TranslationsLocalNewsEditKo extends TranslationsLocalNewsEditId {
	_TranslationsLocalNewsEditKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get appBarTitle => '게시글 수정';
	@override late final _TranslationsLocalNewsEditButtonsKo buttons = _TranslationsLocalNewsEditButtonsKo._(_root);
	@override late final _TranslationsLocalNewsEditAlertsKo alerts = _TranslationsLocalNewsEditAlertsKo._(_root);
}

// Path: commentInputField
class _TranslationsCommentInputFieldKo extends TranslationsCommentInputFieldId {
	_TranslationsCommentInputFieldKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get secretCommentLabel => '비밀';
	@override String get hintText => '댓글을 입력하세요...';
	@override String get replyHintText => '{nickname}님께 답글 쓰는 중...';
	@override late final _TranslationsCommentInputFieldButtonKo button = _TranslationsCommentInputFieldButtonKo._(_root);
}

// Path: commentListView
class _TranslationsCommentListViewKo extends TranslationsCommentListViewId {
	_TranslationsCommentListViewKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get empty => '아직 댓글이 없습니다. 첫 댓글을 남겨보세요!';
	@override String get reply => '답글';
	@override String get delete => '삭제';
	@override String get deleted => '[삭제된 댓글입니다]';
	@override String get secret => '이 댓글은 작성자와 글 작성자만 볼 수 있는 비밀 댓글입니다.';
}

// Path: common
class _TranslationsCommonKo extends TranslationsCommonId {
	_TranslationsCommonKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get cancel => '취소';
	@override String get confirm => '확인';
	@override String get delete => '삭제';
	@override String get done => '완료';
	@override String get clear => '지우기';
	@override String get report => '신고';
	@override String get moreOptions => '더 보기';
	@override String get viewAll => '전체 보기';
	@override String get kNew => '새 글';
	@override String get updated => '업데이트됨';
	@override String get comments => '댓글';
	@override String get sponsored => '스폰서';
	@override String get filter => '필터';
	@override String get reset => '초기화';
	@override String get apply => '적용';
	@override String get verified => '인증됨';
	@override String get bookmark => '북마크';
	@override late final _TranslationsCommonSortKo sort = _TranslationsCommonSortKo._(_root);
	@override String get error => '오류가 발생했습니다.';
	@override String get shareError => '공유에 실패했습니다. 다시 시도해 주세요.';
	@override String get edit => '수정';
	@override String get submit => '등록';
	@override String get loginRequired => '로그인이 필요합니다.';
	@override String get unknownUser => '알 수 없는 사용자입니다.';
}

// Path: reportDialog
class _TranslationsReportDialogKo extends TranslationsReportDialogId {
	_TranslationsReportDialogKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '게시글 신고';
	@override String get titleComment => '댓글 신고';
	@override String get titleReply => '답글 신고';
	@override String get cannotReportSelfComment => '내가 쓴 댓글은 신고할 수 없습니다.';
	@override String get cannotReportSelfReply => '내가 쓴 답글은 신고할 수 없습니다.';
	@override String get success => '신고가 접수되었습니다. 감사합니다.';
	@override String get fail => '신고 접수에 실패했습니다: {error}';
	@override String get cannotReportSelf => '내가 쓴 게시글은 신고할 수 없습니다.';
}

// Path: replyDelete
class _TranslationsReplyDeleteKo extends TranslationsReplyDeleteId {
	_TranslationsReplyDeleteKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get fail => '답글 삭제에 실패했습니다: {error}';
}

// Path: reportReasons
class _TranslationsReportReasonsKo extends TranslationsReportReasonsId {
	_TranslationsReportReasonsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get spam => '스팸 또는 오해의 소지가 있음';
	@override String get abuse => '괴롭힘 또는 혐오 발언';
	@override String get inappropriate => '성적으로 부적절함';
	@override String get illegal => '불법적인 내용';
	@override String get etc => '기타';
}

// Path: deleteConfirm
class _TranslationsDeleteConfirmKo extends TranslationsDeleteConfirmId {
	_TranslationsDeleteConfirmKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '댓글 삭제';
	@override String get content => '이 댓글을 삭제하시겠습니까?';
	@override String get failure => '댓글 삭제에 실패했습니다: {error}';
}

// Path: replyInputField
class _TranslationsReplyInputFieldKo extends TranslationsReplyInputFieldId {
	_TranslationsReplyInputFieldKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get hintText => '답글을 입력하세요';
	@override late final _TranslationsReplyInputFieldButtonKo button = _TranslationsReplyInputFieldButtonKo._(_root);
	@override String get failure => '답글 추가에 실패했습니다: {error}';
}

// Path: chatList
class _TranslationsChatListKo extends TranslationsChatListId {
	_TranslationsChatListKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get appBarTitle => '채팅';
	@override String get empty => '아직 대화가 없습니다.';
}

// Path: chatRoom
class _TranslationsChatRoomKo extends TranslationsChatRoomId {
	_TranslationsChatRoomKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get startConversation => '대화를 시작해 보세요';
	@override String get icebreaker1 => '안녕하세요! 👋';
	@override String get icebreaker2 => '주말에는 보통 뭐 하세요?';
	@override String get icebreaker3 => '근처에 좋아하는 장소가 있나요?';
	@override String get mediaBlocked => '안전상의 이유로, 24시간 동안 미디어 전송이 제한됩니다.';
	@override String get imageMessage => '이미지';
	@override String get linkHidden => '보호 모드: 링크 숨김';
	@override String get contactHidden => '보호 모드: 연락처 숨김';
}

// Path: jobs
class _TranslationsJobsKo extends TranslationsJobsId {
	_TranslationsJobsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get setLocationPrompt => '일자리 글을 보려면 위치를 설정해 주세요!';
	@override late final _TranslationsJobsScreenKo screen = _TranslationsJobsScreenKo._(_root);
	@override late final _TranslationsJobsTabsKo tabs = _TranslationsJobsTabsKo._(_root);
	@override late final _TranslationsJobsSelectTypeKo selectType = _TranslationsJobsSelectTypeKo._(_root);
	@override late final _TranslationsJobsFormKo form = _TranslationsJobsFormKo._(_root);
	@override late final _TranslationsJobsCategoriesKo categories = _TranslationsJobsCategoriesKo._(_root);
	@override late final _TranslationsJobsSalaryTypesKo salaryTypes = _TranslationsJobsSalaryTypesKo._(_root);
	@override late final _TranslationsJobsWorkPeriodsKo workPeriods = _TranslationsJobsWorkPeriodsKo._(_root);
	@override late final _TranslationsJobsDetailKo detail = _TranslationsJobsDetailKo._(_root);
	@override late final _TranslationsJobsCardKo card = _TranslationsJobsCardKo._(_root);
}

// Path: findFriend
class _TranslationsFindFriendKo extends TranslationsFindFriendId {
	_TranslationsFindFriendKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '친구 찾기';
	@override late final _TranslationsFindFriendTabsKo tabs = _TranslationsFindFriendTabsKo._(_root);
	@override String get editTitle => '친구찾기 프로필 수정';
	@override String get editProfileTitle => '프로필 수정';
	@override String get save => '저장';
	@override String get profileImagesLabel => '프로필 이미지 (최대 6장)';
	@override String get bioLabel => '소개';
	@override String get bioHint => '다른 사람들에게 자신을 소개해 주세요.';
	@override String get bioValidator => '소개글을 입력해 주세요.';
	@override String get ageLabel => '나이';
	@override String get ageHint => '나이를 입력해 주세요.';
	@override String get genderLabel => '성별';
	@override String get genderMale => '남성';
	@override String get genderFemale => '여성';
	@override String get genderHint => '성별을 선택해 주세요';
	@override String get interestsLabel => '관심사';
	@override String get preferredAgeLabel => '선호 친구 나이';
	@override String get preferredAgeUnit => '세';
	@override String get preferredGenderLabel => '선호 친구 성별';
	@override String get preferredGenderAll => '모두';
	@override String get showProfileLabel => '프로필 목록에 표시';
	@override String get showProfileSubtitle => '끄면 다른 사람이 나를 찾을 수 없습니다.';
	@override String get saveSuccess => '프로필이 저장되었습니다!';
	@override String get saveFailed => '프로필 저장에 실패했습니다:';
	@override String get loginRequired => '로그인이 필요합니다.';
	@override String get noFriendsFound => '근처에 친구 프로필이 없습니다.';
	@override String get promptTitle => '새로운 친구를 만나려면,\n먼저 프로필을 만들어 주세요!';
	@override String get promptButton => '내 프로필 만들기';
	@override String get chatLimitReached => '오늘 새 대화를 시작할 수 있는 한도({limit})에 도달했습니다.';
	@override String get chatChecking => '확인 중...';
	@override String get empty => '아직 표시할 프로필이 없습니다.';
}

// Path: interests
class _TranslationsInterestsKo extends TranslationsInterestsId {
	_TranslationsInterestsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '관심사';
	@override String get limitInfo => '최대 10개까지 선택할 수 있습니다.';
	@override String get limitReached => '관심사는 최대 10개까지 선택 가능합니다.';
	@override String get categoryCreative => '🎨 창의/예술';
	@override String get categorySports => '🏃 운동 & 활동';
	@override String get categoryFoodDrink => '🍸 음식 & 음료';
	@override String get categoryEntertainment => '🍿 엔터테인먼트';
	@override String get categoryGrowth => '📚 자기계발';
	@override String get categoryLifestyle => '🌴 라이프스타일';
	@override late final _TranslationsInterestsItemsKo items = _TranslationsInterestsItemsKo._(_root);
}

// Path: friendDetail
class _TranslationsFriendDetailKo extends TranslationsFriendDetailId {
	_TranslationsFriendDetailKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get request => '친구 요청';
	@override String get requestSent => '요청됨';
	@override String get alreadyFriends => '이미 친구입니다';
	@override String get requestFailed => '요청에 실패했습니다:';
	@override String get chatError => '채팅을 시작할 수 없습니다.';
	@override String get startChat => '채팅 시작';
	@override String get block => '차단';
	@override String get report => '신고';
	@override String get loginRequired => '로그인이 필요합니다.';
	@override String get unblocked => '차단이 해제되었습니다.';
	@override String get blocked => '사용자가 차단되었습니다.';
	@override String get unblock => '차단 해제';
}

// Path: locationFilter
class _TranslationsLocationFilterKo extends TranslationsLocationFilterId {
	_TranslationsLocationFilterKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '위치 필터';
	@override String get provinsi => '주(Provinsi)';
	@override String get kabupaten => '카부파텐(Kabupaten)';
	@override String get kota => '코타(Kota)';
	@override String get kecamatan => '케카마탄(Kecamatan)';
	@override String get kelurahan => 'Kelurahan';
	@override String get apply => '필터 적용';
	@override String get all => '전체';
	@override String get reset => '초기화';
}

// Path: clubs
class _TranslationsClubsKo extends TranslationsClubsId {
	_TranslationsClubsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsClubsTabsKo tabs = _TranslationsClubsTabsKo._(_root);
	@override late final _TranslationsClubsSectionsKo sections = _TranslationsClubsSectionsKo._(_root);
	@override late final _TranslationsClubsScreenKo screen = _TranslationsClubsScreenKo._(_root);
	@override late final _TranslationsClubsPostListKo postList = _TranslationsClubsPostListKo._(_root);
	@override late final _TranslationsClubsMemberCardKo memberCard = _TranslationsClubsMemberCardKo._(_root);
	@override late final _TranslationsClubsPostCardKo postCard = _TranslationsClubsPostCardKo._(_root);
	@override late final _TranslationsClubsCardKo card = _TranslationsClubsCardKo._(_root);
	@override late final _TranslationsClubsPostDetailKo postDetail = _TranslationsClubsPostDetailKo._(_root);
	@override late final _TranslationsClubsDetailKo detail = _TranslationsClubsDetailKo._(_root);
	@override late final _TranslationsClubsMemberListKo memberList = _TranslationsClubsMemberListKo._(_root);
	@override late final _TranslationsClubsCreatePostKo createPost = _TranslationsClubsCreatePostKo._(_root);
	@override late final _TranslationsClubsCreateClubKo createClub = _TranslationsClubsCreateClubKo._(_root);
	@override late final _TranslationsClubsEditClubKo editClub = _TranslationsClubsEditClubKo._(_root);
	@override late final _TranslationsClubsCreateKo create = _TranslationsClubsCreateKo._(_root);
	@override late final _TranslationsClubsRepositoryKo repository = _TranslationsClubsRepositoryKo._(_root);
	@override late final _TranslationsClubsProposalKo proposal = _TranslationsClubsProposalKo._(_root);
	@override String get empty => '표시할 클럽이 없습니다.';
}

// Path: findfriend
class _TranslationsFindfriendKo extends TranslationsFindfriendId {
	_TranslationsFindfriendKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsFindfriendFormKo form = _TranslationsFindfriendFormKo._(_root);
}

// Path: auctions
class _TranslationsAuctionsKo extends TranslationsAuctionsId {
	_TranslationsAuctionsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsAuctionsCardKo card = _TranslationsAuctionsCardKo._(_root);
	@override late final _TranslationsAuctionsErrorsKo errors = _TranslationsAuctionsErrorsKo._(_root);
	@override String get empty => '등록된 경매가 없습니다.';
	@override late final _TranslationsAuctionsFilterKo filter = _TranslationsAuctionsFilterKo._(_root);
	@override late final _TranslationsAuctionsCreateKo create = _TranslationsAuctionsCreateKo._(_root);
	@override late final _TranslationsAuctionsEditKo edit = _TranslationsAuctionsEditKo._(_root);
	@override late final _TranslationsAuctionsFormKo form = _TranslationsAuctionsFormKo._(_root);
	@override late final _TranslationsAuctionsDeleteKo delete = _TranslationsAuctionsDeleteKo._(_root);
	@override late final _TranslationsAuctionsDetailKo detail = _TranslationsAuctionsDetailKo._(_root);
}

// Path: localStores
class _TranslationsLocalStoresKo extends TranslationsLocalStoresId {
	_TranslationsLocalStoresKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get setLocationPrompt => '근처 가게를 보려면 위치를 설정해 주세요.';
	@override String get empty => '아직 등록된 가게가 없습니다.';
	@override String get error => '오류가 발생했습니다: {error}';
	@override late final _TranslationsLocalStoresCreateKo create = _TranslationsLocalStoresCreateKo._(_root);
	@override late final _TranslationsLocalStoresEditKo edit = _TranslationsLocalStoresEditKo._(_root);
	@override late final _TranslationsLocalStoresFormKo form = _TranslationsLocalStoresFormKo._(_root);
	@override late final _TranslationsLocalStoresCategoriesKo categories = _TranslationsLocalStoresCategoriesKo._(_root);
	@override late final _TranslationsLocalStoresDetailKo detail = _TranslationsLocalStoresDetailKo._(_root);
	@override String get noLocation => '위치 정보 없음';
}

// Path: pom
class _TranslationsPomKo extends TranslationsPomId {
	_TranslationsPomKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => 'POM';
	@override late final _TranslationsPomSearchKo search = _TranslationsPomSearchKo._(_root);
	@override late final _TranslationsPomTabsKo tabs = _TranslationsPomTabsKo._(_root);
	@override String get more => '더 보기';
	@override String get less => '접기';
	@override String get likesCount => '{}개의 좋아요';
	@override String get report => '{} 신고';
	@override String get block => '{} 차단';
	@override String get emptyPopular => '아직 인기 POM이 없습니다.';
	@override String get emptyMine => '아직 업로드한 POM이 없습니다.';
	@override String get emptyHintPopular => '최신 POM을 보려면 \'전체\' 탭을 확인하세요.';
	@override String get emptyCtaMine => '+ 버튼을 눌러 첫 POM을 업로드하세요.';
	@override String get share => '공유';
	@override String get empty => '등록된 POM이 없습니다.';
	@override late final _TranslationsPomErrorsKo errors = _TranslationsPomErrorsKo._(_root);
	@override late final _TranslationsPomCommentsKo comments = _TranslationsPomCommentsKo._(_root);
	@override late final _TranslationsPomCreateKo create = _TranslationsPomCreateKo._(_root);
}

// Path: realEstate
class _TranslationsRealEstateKo extends TranslationsRealEstateId {
	_TranslationsRealEstateKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get create => '매물 등록';
	@override late final _TranslationsRealEstateFormKo form = _TranslationsRealEstateFormKo._(_root);
	@override late final _TranslationsRealEstateDetailKo detail = _TranslationsRealEstateDetailKo._(_root);
	@override String get locationUnknown => '위치 정보 없음';
	@override late final _TranslationsRealEstatePriceUnitsKo priceUnits = _TranslationsRealEstatePriceUnitsKo._(_root);
	@override late final _TranslationsRealEstateFilterKo filter = _TranslationsRealEstateFilterKo._(_root);
	@override late final _TranslationsRealEstateInfoKo info = _TranslationsRealEstateInfoKo._(_root);
	@override String get disclaimer => '블링은 온라인 광고 플랫폼이며 부동산 중개인이 아닙니다. 게시된 매물의 정보, 가격, 소유권, 진위 여부는 게시자에게 전적으로 책임이 있습니다. 사용자는 거래 전 반드시 게시자 및 관련 기관을 통해 정보를 직접 확인해야 합니다.';
	@override String get empty => '등록된 매물이 없습니다.';
	@override String get error => '오류가 발생했습니다: {error}';
	@override late final _TranslationsRealEstatePriceUnitKo priceUnit = _TranslationsRealEstatePriceUnitKo._(_root);
	@override late final _TranslationsRealEstateEditKo edit = _TranslationsRealEstateEditKo._(_root);
}

// Path: lostAndFound
class _TranslationsLostAndFoundKo extends TranslationsLostAndFoundId {
	_TranslationsLostAndFoundKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsLostAndFoundTabsKo tabs = _TranslationsLostAndFoundTabsKo._(_root);
	@override String get create => '분실물/습득물 등록';
	@override late final _TranslationsLostAndFoundFormKo form = _TranslationsLostAndFoundFormKo._(_root);
	@override late final _TranslationsLostAndFoundDetailKo detail = _TranslationsLostAndFoundDetailKo._(_root);
	@override String get lost => '분실';
	@override String get found => '습득';
	@override late final _TranslationsLostAndFoundCardKo card = _TranslationsLostAndFoundCardKo._(_root);
	@override String get empty => '등록된 글이 없습니다.';
	@override String get error => '오류가 발생했습니다: {error}';
	@override late final _TranslationsLostAndFoundResolveKo resolve = _TranslationsLostAndFoundResolveKo._(_root);
	@override late final _TranslationsLostAndFoundEditKo edit = _TranslationsLostAndFoundEditKo._(_root);
}

// Path: community
class _TranslationsCommunityKo extends TranslationsCommunityId {
	_TranslationsCommunityKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '커뮤니티';
}

// Path: shared
class _TranslationsSharedKo extends TranslationsSharedId {
	_TranslationsSharedKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsSharedTagInputKo tagInput = _TranslationsSharedTagInputKo._(_root);
}

// Path: linkPreview
class _TranslationsLinkPreviewKo extends TranslationsLinkPreviewId {
	_TranslationsLinkPreviewKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get errorTitle => '미리보기를 불러올 수 없습니다';
	@override String get errorBody => '링크를 다시 확인하시거나 나중에 다시 시도해 주세요.';
}

// Path: localNewsTagResult
class _TranslationsLocalNewsTagResultKo extends TranslationsLocalNewsTagResultId {
	_TranslationsLocalNewsTagResultKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get error => '검색 중 오류가 발생했습니다: {error}';
	@override String get empty => '\'#{tag}\' 태그로 작성된 글이 없습니다.';
}

// Path: admin
class _TranslationsAdminKo extends TranslationsAdminId {
	_TranslationsAdminKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsAdminScreenKo screen = _TranslationsAdminScreenKo._(_root);
	@override late final _TranslationsAdminMenuKo menu = _TranslationsAdminMenuKo._(_root);
	@override late final _TranslationsAdminAiApprovalKo aiApproval = _TranslationsAdminAiApprovalKo._(_root);
	@override late final _TranslationsAdminReportsKo reports = _TranslationsAdminReportsKo._(_root);
	@override late final _TranslationsAdminReportListKo reportList = _TranslationsAdminReportListKo._(_root);
	@override late final _TranslationsAdminReportDetailKo reportDetail = _TranslationsAdminReportDetailKo._(_root);
	@override late final _TranslationsAdminDataFixKo dataFix = _TranslationsAdminDataFixKo._(_root);
}

// Path: tags
class _TranslationsTagsKo extends TranslationsTagsId {
	_TranslationsTagsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsTagsLocalNewsKo localNews = _TranslationsTagsLocalNewsKo._(_root);
}

// Path: boards
class _TranslationsBoardsKo extends TranslationsBoardsId {
	_TranslationsBoardsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsBoardsPopupKo popup = _TranslationsBoardsPopupKo._(_root);
	@override String get defaultTitle => '게시판';
	@override String get chatRoomComingSoon => '동네 채팅방이 곧 오픈됩니다';
	@override String get chatRoomTitle => '채팅방';
	@override String get emptyFeed => '아직 게시글이 없습니다.';
	@override String get chatRoomCreated => '채팅방이 생성되었습니다.';
}

// Path: signup
class _TranslationsSignupKo extends TranslationsSignupId {
	_TranslationsSignupKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsSignupAlertsKo alerts = _TranslationsSignupAlertsKo._(_root);
	@override String get title => '회원가입';
	@override String get subtitle => '우리 동네 커뮤니티에 함께하세요!';
	@override String get nicknameHint => '닉네임';
	@override String get emailHint => '이메일 주소';
	@override String get passwordHint => '비밀번호';
	@override String get passwordConfirmHint => '비밀번호 확인';
	@override String get locationHint => '동네 위치';
	@override String get locationNotice => '내 위치는 동네 글을 보여주는 데만 사용되며 다른 사람에게 공개되지 않습니다.';
	@override late final _TranslationsSignupButtonsKo buttons = _TranslationsSignupButtonsKo._(_root);
}

// Path: user
class _TranslationsUserKo extends TranslationsUserId {
	_TranslationsUserKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get notLoggedIn => '로그인되지 않았습니다.';
}

// Path: login.buttons
class _TranslationsLoginButtonsKo extends TranslationsLoginButtonsId {
	_TranslationsLoginButtonsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get login => '로그인';
	@override String get google => 'Google로 계속';
	@override String get apple => 'Apple로 계속';
}

// Path: login.links
class _TranslationsLoginLinksKo extends TranslationsLoginLinksId {
	_TranslationsLoginLinksKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get findPassword => '비밀번호 찾기';
	@override String get askForAccount => '계정이 없나요?';
	@override String get signUp => '회원가입';
}

// Path: login.alerts
class _TranslationsLoginAlertsKo extends TranslationsLoginAlertsId {
	_TranslationsLoginAlertsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get invalidEmail => '잘못된 이메일 형식입니다.';
	@override String get userNotFound => '사용자를 찾을 수 없거나 비밀번호가 틀렸습니다.';
	@override String get wrongPassword => '비밀번호가 틀렸습니다.';
	@override String get unknownError => '오류가 발생했습니다. 다시 시도해 주세요.';
}

// Path: main.appBar
class _TranslationsMainAppBarKo extends TranslationsMainAppBarId {
	_TranslationsMainAppBarKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get locationNotSet => '위치 미설정';
	@override String get locationError => '위치 오류';
	@override String get locationLoading => '불러오는 중...';
}

// Path: main.tabs
class _TranslationsMainTabsKo extends TranslationsMainTabsId {
	_TranslationsMainTabsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get newFeed => '새 글';
	@override String get localNews => '동네 소식';
	@override String get marketplace => '중고거래';
	@override String get findFriends => '친구찾기';
	@override String get clubs => '모임';
	@override String get jobs => '일자리';
	@override String get localStores => '동네가게';
	@override String get auction => '경매';
	@override String get pom => 'POM';
	@override String get lostAndFound => '분실·습득';
	@override String get realEstate => '부동산';
}

// Path: main.bottomNav
class _TranslationsMainBottomNavKo extends TranslationsMainBottomNavId {
	_TranslationsMainBottomNavKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get home => '홈';
	@override String get board => '동네게시판';
	@override String get search => '검색';
	@override String get chat => '채팅';
	@override String get myBling => '내 블링';
}

// Path: main.errors
class _TranslationsMainErrorsKo extends TranslationsMainErrorsId {
	_TranslationsMainErrorsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get loginRequired => '로그인이 필요합니다.';
	@override String get userNotFound => '사용자를 찾을 수 없습니다.';
	@override String get unknown => '오류가 발생했습니다.';
}

// Path: main.mapView
class _TranslationsMainMapViewKo extends TranslationsMainMapViewId {
	_TranslationsMainMapViewKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get showMap => '지도 보기';
	@override String get showList => '목록 보기';
}

// Path: main.search
class _TranslationsMainSearchKo extends TranslationsMainSearchId {
	_TranslationsMainSearchKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get placeholder => '검색';
	@override String get chipPlaceholder => '이웃, 소식, 중고거래, 일자리 검색…';
	@override late final _TranslationsMainSearchHintKo hint = _TranslationsMainSearchHintKo._(_root);
}

// Path: search.empty
class _TranslationsSearchEmptyKo extends TranslationsSearchEmptyId {
	_TranslationsSearchEmptyKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get message => '\'{keyword}\' 검색 결과가 없습니다.';
	@override String get checkSpelling => '철자를 확인하거나 다른 검색어로 시도해 주세요.';
	@override String get expandToNational => '전국 검색';
}

// Path: search.sheet
class _TranslationsSearchSheetKo extends TranslationsSearchSheetId {
	_TranslationsSearchSheetKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get localNews => '동네 소식 검색';
	@override String get localNewsDesc => '제목·내용·태그로 검색';
	@override String get jobs => '일자리 검색';
	@override String get jobsDesc => '직무·회사·태그로 검색';
	@override String get lostAndFound => '분실·습득 검색';
	@override String get lostAndFoundDesc => '물건 이름·장소로 검색';
	@override String get marketplace => '중고거래 검색';
	@override String get marketplaceDesc => '상품명·카테고리·태그 검색';
	@override String get localStores => '동네 가게 검색';
	@override String get localStoresDesc => '가게명·업종·키워드 검색';
	@override String get clubs => '모임 검색';
	@override String get clubsDesc => '모임명·관심사 검색';
	@override String get findFriends => '친구찾기 검색';
	@override String get findFriendsDesc => '닉네임·관심사 검색';
	@override String get realEstate => '부동산 검색';
	@override String get realEstateDesc => '제목·지역·태그 검색';
	@override String get auction => '경매 검색';
	@override String get auctionDesc => '상품명·태그 검색';
	@override String get pom => 'POM 검색';
	@override String get pomDesc => '제목·해시태그 검색';
	@override String get comingSoon => '준비 중';
}

// Path: drawer.trustDashboard
class _TranslationsDrawerTrustDashboardKo extends TranslationsDrawerTrustDashboardId {
	_TranslationsDrawerTrustDashboardKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '신뢰 인증 현황';
	@override String get kelurahanAuth => '동네 인증(케루라한)';
	@override String get rtRwAuth => '상세 주소 인증(RT/RW)';
	@override String get phoneAuth => '전화 인증';
	@override String get profileComplete => '프로필 완료';
	@override String get feedThanks => '피드 감사';
	@override String get marketThanks => '중고거래 감사';
	@override String get reports => '신고';
	@override String get breakdownButton => '자세히';
	@override String get breakdownModalTitle => '신뢰 점수 내역';
	@override String get breakdownClose => '확인';
	@override late final _TranslationsDrawerTrustDashboardBreakdownKo breakdown = _TranslationsDrawerTrustDashboardBreakdownKo._(_root);
}

// Path: marketplace.registration
class _TranslationsMarketplaceRegistrationKo extends TranslationsMarketplaceRegistrationId {
	_TranslationsMarketplaceRegistrationKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '새 상품 등록';
	@override String get done => '저장';
	@override String get titleHint => '상품명';
	@override String get priceHint => '가격 (Rp)';
	@override String get negotiable => '가격 제안 허용';
	@override String get addressHint => '동네';
	@override String get addressDetailHint => '만날 장소';
	@override String get descriptionHint => '상세 설명';
	@override String get success => '등록 완료!';
	@override String get tagsHint => '태그 추가 (스페이스로 확정)';
	@override String get fail => '실패';
}

// Path: marketplace.edit
class _TranslationsMarketplaceEditKo extends TranslationsMarketplaceEditId {
	_TranslationsMarketplaceEditKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '게시글 수정';
	@override String get done => '수정 완료';
	@override String get titleHint => '상품명 수정';
	@override String get addressHint => '위치 수정';
	@override String get priceHint => '가격 수정 (Rp)';
	@override String get negotiable => '가격 제안 수정';
	@override String get descriptionHint => '설명 수정';
	@override String get tagsHint => '태그 추가 (스페이스로 확정)';
	@override String get success => '상품이 성공적으로 수정되었습니다.';
	@override String get fail => '상품 수정에 실패했습니다: {error}';
	@override String get resetLocation => '위치 초기화';
	@override String get save => '변경사항 저장';
}

// Path: marketplace.detail
class _TranslationsMarketplaceDetailKo extends TranslationsMarketplaceDetailId {
	_TranslationsMarketplaceDetailKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get makeOffer => '가격 제안하기';
	@override String get fixedPrice => '고정가';
	@override String get description => '상품 설명';
	@override String get sellerInfo => '판매자 정보';
	@override String get chat => '채팅';
	@override String get favorite => '관심 상품';
	@override String get unfavorite => '관심 해제';
	@override String get share => '공유';
	@override String get edit => '수정';
	@override String get delete => '삭제';
	@override String get category => '카테고리';
	@override String get categoryError => '카테고리: -';
	@override String get categoryNone => '카테고리 없음';
	@override String get views => '조회';
	@override String get likes => '좋아요';
	@override String get chats => '채팅';
	@override String get noSeller => '판매자 정보를 찾을 수 없습니다.';
	@override String get noLocation => '위치 정보를 찾을 수 없습니다.';
	@override String get seller => '판매자';
	@override String get dealLocation => '거래 장소';
}

// Path: marketplace.dialog
class _TranslationsMarketplaceDialogKo extends TranslationsMarketplaceDialogId {
	_TranslationsMarketplaceDialogKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get deleteTitle => '게시글 삭제';
	@override String get deleteContent => '이 게시글을 정말 삭제하시겠습니까? 삭제 후에는 되돌릴 수 없습니다.';
	@override String get cancel => '취소';
	@override String get deleteConfirm => '삭제';
	@override String get deleteSuccess => '게시글이 삭제되었습니다.';
	@override String get close => '닫기';
}

// Path: marketplace.errors
class _TranslationsMarketplaceErrorsKo extends TranslationsMarketplaceErrorsId {
	_TranslationsMarketplaceErrorsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get deleteError => '게시글 삭제에 실패했습니다: {error}';
	@override String get requiredField => '필수 입력 항목입니다.';
	@override String get noPhoto => '사진을 최소 1장 이상 추가해 주세요.';
	@override String get noCategory => '카테고리를 선택해 주세요.';
	@override String get loginRequired => '로그인이 필요합니다.';
	@override String get userNotFound => '사용자 정보를 찾을 수 없습니다.';
}

// Path: marketplace.condition
class _TranslationsMarketplaceConditionKo extends TranslationsMarketplaceConditionId {
	_TranslationsMarketplaceConditionKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get label => '상품 상태';
	@override String get kNew => '새 상품';
	@override String get used => '중고';
}

// Path: marketplace.reservation
class _TranslationsMarketplaceReservationKo extends TranslationsMarketplaceReservationId {
	_TranslationsMarketplaceReservationKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '10% 예약금 결제';
	@override String get content => 'AI 인증 상품을 예약하려면 {amount}의 10% 예약금을 먼저 결제해야 합니다. 현장 검증 후 거래가 취소되면 예약금은 환불됩니다.';
	@override String get confirm => '결제 후 예약하기';
	@override String get button => 'AI 보증으로 예약하기';
	@override String get success => '예약이 완료되었습니다. 판매자와 일정을 조율해 주세요.';
}

// Path: marketplace.status
class _TranslationsMarketplaceStatusKo extends TranslationsMarketplaceStatusId {
	_TranslationsMarketplaceStatusKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get reserved => '예약됨';
	@override String get sold => '판매 완료';
}

// Path: marketplace.ai
class _TranslationsMarketplaceAiKo extends TranslationsMarketplaceAiId {
	_TranslationsMarketplaceAiKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get cancelConfirm => 'AI 인증 취소';
	@override String get cancelLimit => 'AI 인증은 상품당 한 번만 취소할 수 있습니다. 다시 요청할 경우 비용이 발생할 수 있습니다.';
	@override String get cancelAckCharge => '비용이 발생할 수 있음을 이해했습니다.';
	@override String get cancelSuccess => 'AI 인증이 취소되었습니다. 이제 일반 상품으로 전환되었습니다.';
	@override String get cancelError => 'AI 인증 취소 중 오류가 발생했습니다: {0}';
}

// Path: marketplace.takeover
class _TranslationsMarketplaceTakeoverKo extends TranslationsMarketplaceTakeoverId {
	_TranslationsMarketplaceTakeoverKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get button => '현장 수령 및 검증';
	@override String get title => 'AI 현장 검증';
	@override late final _TranslationsMarketplaceTakeoverGuideKo guide = _TranslationsMarketplaceTakeoverGuideKo._(_root);
	@override String get photoTitle => '현장에서 사진 찍기';
	@override String get buttonVerify => 'AI 유사도 검증 시작';
	@override late final _TranslationsMarketplaceTakeoverErrorsKo errors = _TranslationsMarketplaceTakeoverErrorsKo._(_root);
	@override late final _TranslationsMarketplaceTakeoverDialogKo dialog = _TranslationsMarketplaceTakeoverDialogKo._(_root);
	@override late final _TranslationsMarketplaceTakeoverSuccessKo success = _TranslationsMarketplaceTakeoverSuccessKo._(_root);
}

// Path: aiFlow.common
class _TranslationsAiFlowCommonKo extends TranslationsAiFlowCommonId {
	_TranslationsAiFlowCommonKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get error => '오류가 발생했습니다: {error}';
	@override String get addPhoto => '사진 추가';
	@override String get skip => '건너뛰기';
	@override String get addedPhoto => '사진이 추가되었습니다: {}';
	@override String get skipped => '건너뜀';
}

// Path: aiFlow.cta
class _TranslationsAiFlowCtaKo extends TranslationsAiFlowCtaId {
	_TranslationsAiFlowCtaKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '🤖 AI 인증으로 신뢰도 높이기 (선택)';
	@override String get subtitle => 'AI 인증 뱃지를 얻으면 구매자 신뢰가 올라가고 더 빨리 팔릴 수 있어요. 시작하기 전에 상품 정보를 모두 입력해 주세요.';
	@override String get startButton => 'AI 인증 시작하기';
	@override String get missingRequiredFields => '상품명, 카테고리, 최소 1장의 이미지를 먼저 입력해 주세요.';
}

// Path: aiFlow.categorySelection
class _TranslationsAiFlowCategorySelectionKo extends TranslationsAiFlowCategorySelectionId {
	_TranslationsAiFlowCategorySelectionKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => 'AI 인증: 카테고리 선택';
	@override String get error => '카테고리를 불러오지 못했습니다.';
	@override String get noCategories => 'AI 인증 가능한 카테고리가 없습니다.';
}

// Path: aiFlow.galleryUpload
class _TranslationsAiFlowGalleryUploadKo extends TranslationsAiFlowGalleryUploadId {
	_TranslationsAiFlowGalleryUploadKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => 'AI 인증: 사진 선택';
	@override String get guide => 'AI 인증을 위해 최소 {count}장의 사진을 올려 주세요.';
	@override String get minPhotoError => '사진을 최소 {count}장 선택해야 합니다.';
	@override String get nextButton => 'AI 분석 요청';
}

// Path: aiFlow.prediction
class _TranslationsAiFlowPredictionKo extends TranslationsAiFlowPredictionId {
	_TranslationsAiFlowPredictionKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => 'AI 분석 결과';
	@override String get guide => 'AI가 예측한 상품명입니다.';
	@override String get editLabel => '상품명 수정';
	@override String get editButton => '직접 수정';
	@override String get saveButton => '변경 저장';
	@override String get noName => '상품명이 없습니다.';
	@override String get error => '상품을 인식하지 못했습니다. 다시 시도해 주세요.';
	@override String get authError => '사용자 인증 정보가 없습니다. 분석을 시작할 수 없습니다.';
	@override String get question => '이 상품명이 맞나요?';
	@override String get confirmButton => '네, 맞아요';
	@override String get rejectButton => '아니요, 다시 수정';
	@override String get analysisError => '분석 중 오류가 발생했습니다.';
	@override String get retryButton => '다시 시도';
	@override String get backButton => '뒤로';
}

// Path: aiFlow.guidedCamera
class _TranslationsAiFlowGuidedCameraKo extends TranslationsAiFlowGuidedCameraId {
	_TranslationsAiFlowGuidedCameraKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => 'AI 가이드: 부족한 증거 사진';
	@override String get guide => '신뢰도를 높이기 위해 아래 항목에 맞는 추가 사진을 찍어 주세요.';
	@override String get locationMismatchError => '사진 위치가 현재 위치와 다릅니다. 같은 장소에서 다시 촬영해 주세요.';
	@override String get locationPermissionError => '위치 권한이 거부되었습니다. 설정에서 위치 권한을 허용해 주세요.';
	@override String get noLocationDataError => '사진에 위치 정보가 없습니다. 카메라 설정에서 위치 태그를 켜 주세요.';
	@override String get nextButton => '최종 보고서 생성';
}

// Path: aiFlow.finalReport
class _TranslationsAiFlowFinalReportKo extends TranslationsAiFlowFinalReportId {
	_TranslationsAiFlowFinalReportKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => 'AI 인증 보고서';
	@override String get guide => 'AI가 작성한 초안 기반으로 상품 정보를 정리했습니다. 내용을 수정한 뒤 등록을 마무리해 주세요.';
	@override String get loading => 'AI가 최종 보고서를 생성하는 중입니다...';
	@override String get error => '보고서 생성에 실패했습니다.';
	@override String get success => '최종 보고서가 생성되었습니다.';
	@override String get submitButton => '판매 등록 완료';
	@override String get suggestedPrice => 'AI 추천 가격 ({})';
	@override String get summary => '인증 요약';
	@override String get buyerNotes => '구매자 안내 (AI)';
	@override String get keySpecs => '핵심 스펙';
	@override String get condition => '상태 점검';
	@override String get includedItems => '구성품(쉼표로 구분)';
	@override String get finalDescription => '최종 설명';
	@override String get applySuggestions => 'AI 제안을 설명에 반영';
	@override String get includedItemsLabel => '구성품';
	@override String get buyerNotesLabel => '구매자 안내';
	@override String get skippedItems => '건너뛴 증거 항목';
	@override String get fail => '최종 보고서 생성에 실패했습니다: {error}';
}

// Path: aiFlow.evidence
class _TranslationsAiFlowEvidenceKo extends TranslationsAiFlowEvidenceId {
	_TranslationsAiFlowEvidenceKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get allShotsRequired => '모든 추천 샷이 필요합니다.';
	@override String get title => '증거 사진';
	@override String get submitButton => '증거 제출';
}

// Path: aiFlow.error
class _TranslationsAiFlowErrorKo extends TranslationsAiFlowErrorId {
	_TranslationsAiFlowErrorKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get reportGeneration => 'AI 보고서 생성에 실패했습니다: {error}';
}

// Path: myBling.stats
class _TranslationsMyBlingStatsKo extends TranslationsMyBlingStatsId {
	_TranslationsMyBlingStatsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get posts => '게시글';
	@override String get followers => '팔로워';
	@override String get neighbors => '이웃';
	@override String get friends => '친구';
}

// Path: myBling.tabs
class _TranslationsMyBlingTabsKo extends TranslationsMyBlingTabsId {
	_TranslationsMyBlingTabsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get posts => '내 게시글';
	@override String get products => '내 상품';
	@override String get bookmarks => '북마크';
	@override String get friends => '친구';
}

// Path: profileView.tabs
class _TranslationsProfileViewTabsKo extends TranslationsProfileViewTabsId {
	_TranslationsProfileViewTabsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get posts => '게시글';
	@override String get interests => '관심사';
}

// Path: settings.notifications
class _TranslationsSettingsNotificationsKo extends TranslationsSettingsNotificationsId {
	_TranslationsSettingsNotificationsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get loadError => '알림 설정을 불러오지 못했습니다.';
	@override String get saveSuccess => '알림 설정이 저장되었습니다.';
	@override String get saveError => '알림 설정 저장에 실패했습니다.';
	@override String get scopeTitle => '알림 범위';
	@override String get scopeDescription => '알림을 받을 범위를 선택하세요 (내 동네만, 인근 지역 등).';
	@override String get scopeLabel => '알림 범위';
	@override String get tagsTitle => '알림 주제';
	@override String get tagsDescription => '어떤 주제의 알림을 받을지 선택하세요 (소식, 일자리, 중고거래 등).';
}

// Path: friendRequests.tooltip
class _TranslationsFriendRequestsTooltipKo extends TranslationsFriendRequestsTooltipId {
	_TranslationsFriendRequestsTooltipKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get accept => '수락';
	@override String get reject => '거절';
}

// Path: sentFriendRequests.status
class _TranslationsSentFriendRequestsStatusKo extends TranslationsSentFriendRequestsStatusId {
	_TranslationsSentFriendRequestsStatusKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get pending => '대기 중';
	@override String get accepted => '수락됨';
	@override String get rejected => '거절됨';
}

// Path: blockedUsers.unblockDialog
class _TranslationsBlockedUsersUnblockDialogKo extends TranslationsBlockedUsersUnblockDialogId {
	_TranslationsBlockedUsersUnblockDialogKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '{nickname} 님의 차단을 해제할까요?';
	@override String get content => '차단을 해제하면 이 사용자가 다시 친구찾기 목록에 나타날 수 있습니다.';
}

// Path: rejectedUsers.unrejectDialog
class _TranslationsRejectedUsersUnrejectDialogKo extends TranslationsRejectedUsersUnrejectDialogId {
	_TranslationsRejectedUsersUnrejectDialogKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '{nickname} 님에 대한 거절을 취소할까요?';
	@override String get content => '거절을 취소하면 상대방의 친구찾기 목록에 다시 나타날 수 있습니다.';
}

// Path: profileEdit.interests
class _TranslationsProfileEditInterestsKo extends TranslationsProfileEditInterestsId {
	_TranslationsProfileEditInterestsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '관심사';
	@override String get hint => '여러 개를 입력하려면 쉼표와 엔터를 사용하세요';
}

// Path: profileEdit.privacy
class _TranslationsProfileEditPrivacyKo extends TranslationsProfileEditPrivacyId {
	_TranslationsProfileEditPrivacyKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '개인정보 설정';
	@override String get showLocation => '지도에 내 위치 표시';
	@override String get allowRequests => '친구 요청 허용';
}

// Path: profileEdit.errors
class _TranslationsProfileEditErrorsKo extends TranslationsProfileEditErrorsId {
	_TranslationsProfileEditErrorsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get noUser => '로그인된 사용자가 없습니다.';
	@override String get updateFailed => '프로필 업데이트에 실패했습니다: {error}';
}

// Path: categories.post
class _TranslationsCategoriesPostKo extends TranslationsCategoriesPostId {
	_TranslationsCategoriesPostKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsCategoriesPostJalanPerbaikinKo jalanPerbaikin = _TranslationsCategoriesPostJalanPerbaikinKo._(_root);
	@override late final _TranslationsCategoriesPostDailyLifeKo dailyLife = _TranslationsCategoriesPostDailyLifeKo._(_root);
	@override late final _TranslationsCategoriesPostHelpShareKo helpShare = _TranslationsCategoriesPostHelpShareKo._(_root);
	@override late final _TranslationsCategoriesPostIncidentReportKo incidentReport = _TranslationsCategoriesPostIncidentReportKo._(_root);
	@override late final _TranslationsCategoriesPostLocalNewsKo localNews = _TranslationsCategoriesPostLocalNewsKo._(_root);
	@override late final _TranslationsCategoriesPostNovemberKo november = _TranslationsCategoriesPostNovemberKo._(_root);
	@override late final _TranslationsCategoriesPostRainKo rain = _TranslationsCategoriesPostRainKo._(_root);
	@override late final _TranslationsCategoriesPostDailyQuestionKo dailyQuestion = _TranslationsCategoriesPostDailyQuestionKo._(_root);
	@override late final _TranslationsCategoriesPostStorePromoKo storePromo = _TranslationsCategoriesPostStorePromoKo._(_root);
	@override late final _TranslationsCategoriesPostEtcKo etc = _TranslationsCategoriesPostEtcKo._(_root);
}

// Path: categories.auction
class _TranslationsCategoriesAuctionKo extends TranslationsCategoriesAuctionId {
	_TranslationsCategoriesAuctionKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get all => '전체';
	@override late final _TranslationsCategoriesAuctionCollectiblesKo collectibles = _TranslationsCategoriesAuctionCollectiblesKo._(_root);
	@override late final _TranslationsCategoriesAuctionDigitalKo digital = _TranslationsCategoriesAuctionDigitalKo._(_root);
	@override late final _TranslationsCategoriesAuctionFashionKo fashion = _TranslationsCategoriesAuctionFashionKo._(_root);
	@override late final _TranslationsCategoriesAuctionVintageKo vintage = _TranslationsCategoriesAuctionVintageKo._(_root);
	@override late final _TranslationsCategoriesAuctionArtCraftKo artCraft = _TranslationsCategoriesAuctionArtCraftKo._(_root);
	@override late final _TranslationsCategoriesAuctionEtcKo etc = _TranslationsCategoriesAuctionEtcKo._(_root);
}

// Path: localNewsCreate.form
class _TranslationsLocalNewsCreateFormKo extends TranslationsLocalNewsCreateFormId {
	_TranslationsLocalNewsCreateFormKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get categoryLabel => '카테고리';
	@override String get titleLabel => '제목';
	@override String get contentLabel => '내용 입력';
	@override String get tagsLabel => '태그';
	@override String get tagsHint => '태그를 추가하세요 (스페이스를 눌러 확정)';
	@override String get recommendedTags => '추천 태그';
}

// Path: localNewsCreate.labels
class _TranslationsLocalNewsCreateLabelsKo extends TranslationsLocalNewsCreateLabelsId {
	_TranslationsLocalNewsCreateLabelsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '제목';
	@override String get body => '내용';
	@override String get tags => '태그';
	@override String get guidedTitle => '추가 정보 (선택)';
	@override String get eventLocation => '이벤트/사건 위치';
}

// Path: localNewsCreate.hints
class _TranslationsLocalNewsCreateHintsKo extends TranslationsLocalNewsCreateHintsId {
	_TranslationsLocalNewsCreateHintsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get body => '동네 소식을 공유하거나 궁금한 점을 남겨보세요...';
	@override String get tagSelection => '(태그 1~3개 선택)';
	@override String get eventLocation => '예: Jl. Sudirman 123';
}

// Path: localNewsCreate.validation
class _TranslationsLocalNewsCreateValidationKo extends TranslationsLocalNewsCreateValidationId {
	_TranslationsLocalNewsCreateValidationKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get bodyRequired => '내용을 입력해 주세요.';
	@override String get tagRequired => '태그를 최소 1개 선택해 주세요.';
	@override String get tagMaxLimit => '태그는 최대 3개까지 선택할 수 있습니다.';
	@override String get imageMaxLimit => '이미지는 최대 5장까지 첨부할 수 있습니다.';
	@override String get titleRequired => '제목을 입력해 주세요.';
}

// Path: localNewsCreate.buttons
class _TranslationsLocalNewsCreateButtonsKo extends TranslationsLocalNewsCreateButtonsId {
	_TranslationsLocalNewsCreateButtonsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get addImage => '이미지 추가';
	@override String get submit => '등록';
}

// Path: localNewsCreate.alerts
class _TranslationsLocalNewsCreateAlertsKo extends TranslationsLocalNewsCreateAlertsId {
	_TranslationsLocalNewsCreateAlertsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get contentRequired => '내용을 입력해 주세요.';
	@override String get categoryRequired => '카테고리를 선택해 주세요.';
	@override String get success => '게시글이 등록되었습니다.';
	@override String get failure => '업로드에 실패했습니다: {error}';
	@override String get loginRequired => '게시글을 작성하려면 로그인이 필요합니다.';
	@override String get userNotFound => '사용자 정보를 찾을 수 없습니다.';
}

// Path: localNewsDetail.menu
class _TranslationsLocalNewsDetailMenuKo extends TranslationsLocalNewsDetailMenuId {
	_TranslationsLocalNewsDetailMenuKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get edit => '수정';
	@override String get report => '신고';
	@override String get share => '공유';
}

// Path: localNewsDetail.stats
class _TranslationsLocalNewsDetailStatsKo extends TranslationsLocalNewsDetailStatsId {
	_TranslationsLocalNewsDetailStatsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get views => '조회수';
	@override String get comments => '댓글';
	@override String get likes => '좋아요';
	@override String get thanks => '고마워요';
}

// Path: localNewsDetail.buttons
class _TranslationsLocalNewsDetailButtonsKo extends TranslationsLocalNewsDetailButtonsId {
	_TranslationsLocalNewsDetailButtonsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get comment => '댓글 달기';
}

// Path: localNewsEdit.buttons
class _TranslationsLocalNewsEditButtonsKo extends TranslationsLocalNewsEditButtonsId {
	_TranslationsLocalNewsEditButtonsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get submit => '수정 완료';
}

// Path: localNewsEdit.alerts
class _TranslationsLocalNewsEditAlertsKo extends TranslationsLocalNewsEditAlertsId {
	_TranslationsLocalNewsEditAlertsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get success => '게시글이 수정되었습니다.';
	@override String get failure => '수정에 실패했습니다: {error}';
}

// Path: commentInputField.button
class _TranslationsCommentInputFieldButtonKo extends TranslationsCommentInputFieldButtonId {
	_TranslationsCommentInputFieldButtonKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get send => '보내기';
}

// Path: common.sort
class _TranslationsCommonSortKo extends TranslationsCommonSortId {
	_TranslationsCommonSortKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get kDefault => '기본 순';
	@override String get distance => '거리순';
	@override String get popular => '인기순';
}

// Path: replyInputField.button
class _TranslationsReplyInputFieldButtonKo extends TranslationsReplyInputFieldButtonId {
	_TranslationsReplyInputFieldButtonKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get send => '보내기';
}

// Path: jobs.screen
class _TranslationsJobsScreenKo extends TranslationsJobsScreenId {
	_TranslationsJobsScreenKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get empty => '이 근처에 등록된 일자리 글이 없습니다.';
	@override String get createTooltip => '일자리 등록';
}

// Path: jobs.tabs
class _TranslationsJobsTabsKo extends TranslationsJobsTabsId {
	_TranslationsJobsTabsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get all => '전체';
	@override String get quickGig => '단기 심부름';
	@override String get regular => '알바/정규직';
}

// Path: jobs.selectType
class _TranslationsJobsSelectTypeKo extends TranslationsJobsSelectTypeId {
	_TranslationsJobsSelectTypeKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '일자리 유형 선택';
	@override String get regularTitle => '파트타임 / 정규직 공고';
	@override String get regularDesc => '카페, 식당, 사무실 등 일반 근무';
	@override String get quickGigTitle => '단기 심부름 / 간단 도움';
	@override String get quickGigDesc => '오토바이 배달, 이사 도움, 청소 등';
}

// Path: jobs.form
class _TranslationsJobsFormKo extends TranslationsJobsFormId {
	_TranslationsJobsFormKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '일자리 등록';
	@override String get titleHint => '공고 제목';
	@override String get descriptionPositionHint => '모집하는 포지션을 설명해 주세요';
	@override String get categoryHint => '카테고리';
	@override String get categorySelectHint => '카테고리를 선택해 주세요';
	@override String get categoryValidator => '카테고리를 선택해 주세요.';
	@override String get locationHint => '근무지';
	@override String get submit => '일자리 등록';
	@override String get titleLabel => '제목';
	@override String get titleValidator => '제목을 입력해 주세요.';
	@override String get titleRegular => '알바/정규직 공고 등록';
	@override String get titleQuickGig => '단기 심부름 공고 등록';
	@override String get validationError => '필수 항목을 모두 입력해 주세요.';
	@override String get saveSuccess => '일자리 공고가 저장되었습니다.';
	@override String get saveError => '일자리 공고 저장에 실패했습니다: {error}';
	@override String get categoryLabel => '카테고리';
	@override String get titleHintQuickGig => '예: 오토바이 서류 배달 (ASAP)';
	@override String get salaryLabel => '급여 (IDR)';
	@override String get salaryHint => '급여 금액을 입력해 주세요';
	@override String get salaryValidator => '올바른 급여 금액을 입력해 주세요.';
	@override String get totalPayLabel => '총 지급액 (IDR)';
	@override String get totalPayHint => '제공할 총 금액을 입력해 주세요';
	@override String get totalPayValidator => '올바른 금액을 입력해 주세요.';
	@override String get negotiable => '협의 가능';
	@override String get workPeriodLabel => '근무 기간';
	@override String get workPeriodHint => '근무 기간을 선택해 주세요';
	@override String get locationLabel => '근무지/위치';
	@override String get locationValidator => '근무지를 입력해 주세요.';
	@override String get imageLabel => '이미지 (선택, 최대 10장)';
	@override String get descriptionHintQuickGig => '출발지, 도착지, 요청 사항 등 자세히 적어 주세요.';
	@override String get salaryInfoTitle => '급여 정보';
	@override String get salaryTypeHint => '지급 형태';
	@override String get salaryAmountLabel => '금액 (IDR)';
	@override String get salaryNegotiable => '급여 협의 가능';
	@override String get workInfoTitle => '근무 조건';
	@override String get workPeriodTitle => '근무 기간';
	@override String get workHoursLabel => '근무 요일/시간';
	@override String get workHoursHint => '예: 월–금, 09:00–18:00';
	@override String get imageSectionTitle => '사진 첨부 (선택, 최대 5장)';
	@override String get descriptionLabel => '상세 설명';
	@override String get descriptionHint => '예: 주 3일, 오후 5–10시, 시급 협의 가능 등';
	@override String get descriptionValidator => '상세 설명을 입력해 주세요.';
	@override String get submitSuccess => '일자리 공고가 등록되었습니다.';
	@override String get submitFail => '일자리 공고 등록에 실패했습니다: {error}';
	@override String get updateSuccess => '일자리 공고가 성공적으로 업데이트되었습니다.';
	@override String get editTitle => '일자리 수정';
	@override String get update => '업데이트';
}

// Path: jobs.categories
class _TranslationsJobsCategoriesKo extends TranslationsJobsCategoriesId {
	_TranslationsJobsCategoriesKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get restaurant => '식당';
	@override String get cafe => '카페';
	@override String get retail => '매장/리테일';
	@override String get delivery => '배달';
	@override String get etc => '기타';
	@override String get service => '서비스';
	@override String get salesMarketing => '영업/마케팅';
	@override String get deliveryLogistics => '배송/물류';
	@override String get it => 'IT/기술';
	@override String get design => '디자인';
	@override String get education => '교육';
	@override String get quickGigDelivery => '오토바이 배달';
	@override String get quickGigTransport => '오토바이 태워주기 (오젝)';
	@override String get quickGigMoving => '이사/짐 나르기';
	@override String get quickGigCleaning => '청소/가사 도움';
	@override String get quickGigQueuing => '줄 서주기';
	@override String get quickGigEtc => '기타 심부름';
}

// Path: jobs.salaryTypes
class _TranslationsJobsSalaryTypesKo extends TranslationsJobsSalaryTypesId {
	_TranslationsJobsSalaryTypesKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get hourly => '시급';
	@override String get daily => '일급';
	@override String get weekly => '주급';
	@override String get monthly => '월급';
	@override String get total => '총액';
	@override String get perCase => '건당';
	@override String get etc => '기타';
	@override String get yearly => '연봉';
}

// Path: jobs.workPeriods
class _TranslationsJobsWorkPeriodsKo extends TranslationsJobsWorkPeriodsId {
	_TranslationsJobsWorkPeriodsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get shortTerm => '단기';
	@override String get midTerm => '중기';
	@override String get longTerm => '장기';
	@override String get oneTime => '1회성';
	@override String get k1Week => '1주';
	@override String get k1Month => '1개월';
	@override String get k3Months => '3개월';
	@override String get k6MonthsPlus => '6개월 이상';
	@override String get negotiable => '협의 가능';
	@override String get etc => '기타';
}

// Path: jobs.detail
class _TranslationsJobsDetailKo extends TranslationsJobsDetailId {
	_TranslationsJobsDetailKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get infoTitle => '상세 정보';
	@override String get apply => '지원하기';
	@override String get noAuthor => '작성자 정보가 없습니다';
	@override String get chatError => '채팅을 시작할 수 없습니다: {error}';
}

// Path: jobs.card
class _TranslationsJobsCardKo extends TranslationsJobsCardId {
	_TranslationsJobsCardKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get noLocation => '위치 정보 없음';
	@override String get minutesAgo => '분 전';
}

// Path: findFriend.tabs
class _TranslationsFindFriendTabsKo extends TranslationsFindFriendTabsId {
	_TranslationsFindFriendTabsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get friends => '친구';
	@override String get groups => '그룹';
	@override String get clubs => '클럽';
}

// Path: interests.items
class _TranslationsInterestsItemsKo extends TranslationsInterestsItemsId {
	_TranslationsInterestsItemsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get drawing => '그림 그리기';
	@override String get instrument => '악기 연주';
	@override String get photography => '사진';
	@override String get writing => '글쓰기';
	@override String get crafting => '공예';
	@override String get gardening => '가드닝';
	@override String get soccer => '축구/풋살';
	@override String get hiking => '등산';
	@override String get camping => '캠핑';
	@override String get running => '러닝/조깅';
	@override String get biking => '자전거';
	@override String get golf => '골프';
	@override String get workout => '운동/피트니스';
	@override String get foodie => '맛집 탐방';
	@override String get cooking => '요리';
	@override String get baking => '베이킹';
	@override String get coffee => '커피';
	@override String get wine => '와인/주류';
	@override String get tea => '차';
	@override String get movies => '영화/드라마';
	@override String get music => '음악 감상';
	@override String get concerts => '콘서트/페스티벌';
	@override String get gaming => '게임';
	@override String get reading => '독서';
	@override String get investing => '투자';
	@override String get language => '언어 공부';
	@override String get coding => '코딩';
	@override String get travel => '여행';
	@override String get pets => '반려동물';
	@override String get volunteering => '봉사활동';
	@override String get minimalism => '미니멀리즘';
}

// Path: clubs.tabs
class _TranslationsClubsTabsKo extends TranslationsClubsTabsId {
	_TranslationsClubsTabsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get proposals => '제안';
	@override String get activeClubs => '활동 중';
	@override String get myClubs => '내 클럽';
	@override String get exploreClubs => '클럽 탐색';
}

// Path: clubs.sections
class _TranslationsClubsSectionsKo extends TranslationsClubsSectionsId {
	_TranslationsClubsSectionsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get active => '공식 클럽';
	@override String get proposals => '클럽 제안';
}

// Path: clubs.screen
class _TranslationsClubsScreenKo extends TranslationsClubsScreenId {
	_TranslationsClubsScreenKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get error => '오류: {error}';
	@override String get empty => '아직 클럽이 없습니다.';
}

// Path: clubs.postList
class _TranslationsClubsPostListKo extends TranslationsClubsPostListId {
	_TranslationsClubsPostListKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get empty => '게시글이 없습니다. 첫 글을 남겨보세요!';
	@override String get writeTooltip => '글쓰기';
}

// Path: clubs.memberCard
class _TranslationsClubsMemberCardKo extends TranslationsClubsMemberCardId {
	_TranslationsClubsMemberCardKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get kickConfirmTitle => '{memberName}님을 제거할까요?';
	@override String get kickConfirmContent => '제거된 멤버는 더 이상 클럽 활동에 참여할 수 없습니다.';
	@override String get kick => '제거';
	@override String get kickedSuccess => '{memberName}님이 제거되었습니다.';
	@override String get kickFail => '멤버 제거 실패: {error}';
}

// Path: clubs.postCard
class _TranslationsClubsPostCardKo extends TranslationsClubsPostCardId {
	_TranslationsClubsPostCardKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get deleteTitle => '게시글 삭제';
	@override String get deleteContent => '이 게시글을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.';
	@override String get deleteSuccess => '게시글이 삭제되었습니다.';
	@override String get deleteFail => '게시글 삭제 실패: {error}';
	@override String get withdrawnMember => '탈퇴한 멤버';
	@override String get deleteTooltip => '게시글 삭제';
	@override String get loadingUser => '사용자 정보 불러오는 중...';
}

// Path: clubs.card
class _TranslationsClubsCardKo extends TranslationsClubsCardId {
	_TranslationsClubsCardKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get membersCount => '멤버 {count}명';
}

// Path: clubs.postDetail
class _TranslationsClubsPostDetailKo extends TranslationsClubsPostDetailId {
	_TranslationsClubsPostDetailKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get commentFail => '댓글 추가 실패: {error}';
	@override String get appBarTitle => '{title} 게시판';
	@override String get commentsTitle => '댓글';
	@override String get noComments => '댓글이 없습니다.';
	@override String get commentHint => '댓글 작성...';
	@override String get unknownUser => '알 수 없는 사용자';
}

// Path: clubs.detail
class _TranslationsClubsDetailKo extends TranslationsClubsDetailId {
	_TranslationsClubsDetailKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get joined => '‘{title}’ 클럽에 가입했습니다!';
	@override String get pendingApproval => '운영자 승인 대기 중입니다. 승인 후 활동할 수 있습니다.';
	@override String get joinFail => '가입 요청 실패: {error}';
	@override late final _TranslationsClubsDetailTabsKo tabs = _TranslationsClubsDetailTabsKo._(_root);
	@override String get joinChat => '채팅 참여';
	@override String get joinClub => '클럽 가입';
	@override String get owner => '운영자';
	@override late final _TranslationsClubsDetailInfoKo info = _TranslationsClubsDetailInfoKo._(_root);
	@override String get location => '위치';
	@override String get leaveConfirmTitle => '클럽 탈퇴';
	@override String get leaveConfirmContent => '{title} 클럽을 탈퇴하시겠습니까?';
	@override String get leave => '탈퇴';
	@override String get leaveSuccess => '{title} 클럽에서 탈퇴했습니다.';
	@override String get leaveFail => '탈퇴 실패: {error}';
}

// Path: clubs.memberList
class _TranslationsClubsMemberListKo extends TranslationsClubsMemberListId {
	_TranslationsClubsMemberListKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get pendingMembers => '승인 대기 멤버';
	@override String get allMembers => '전체 멤버';
}

// Path: clubs.createPost
class _TranslationsClubsCreatePostKo extends TranslationsClubsCreatePostId {
	_TranslationsClubsCreatePostKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '새 글';
	@override String get submit => '등록';
	@override String get success => '글이 등록되었습니다.';
	@override String get fail => '글 등록 실패: {error}';
	@override String get bodyHint => '내용 입력...';
}

// Path: clubs.createClub
class _TranslationsClubsCreateClubKo extends TranslationsClubsCreateClubId {
	_TranslationsClubsCreateClubKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get selectAtLeastOneInterest => '관심사를 최소 1개 선택해 주세요.';
	@override String get success => '클럽이 생성되었습니다!';
	@override String get fail => '클럽 생성 실패: {error}';
	@override String get title => '클럽 만들기';
	@override String get nameLabel => '클럽 이름';
	@override String get nameError => '클럽 이름을 입력해 주세요.';
	@override String get descriptionLabel => '클럽 설명';
	@override String get descriptionError => '클럽 설명을 입력해 주세요.';
	@override String get tagsHint => '태그 입력 후 스페이스로 추가';
	@override String get maxInterests => '최대 3개의 관심사를 선택할 수 있습니다.';
	@override String get privateClub => '비공개 클럽';
	@override String get privateDescription => '초대받은 사람만 참여 가능';
	@override String get locationLabel => '위치';
}

// Path: clubs.editClub
class _TranslationsClubsEditClubKo extends TranslationsClubsEditClubId {
	_TranslationsClubsEditClubKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '클럽 정보 수정';
	@override String get save => '저장';
	@override String get success => '클럽 정보가 업데이트되었습니다.';
	@override String get fail => '업데이트 실패: {error}';
}

// Path: clubs.create
class _TranslationsClubsCreateKo extends TranslationsClubsCreateId {
	_TranslationsClubsCreateKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '클럽 만들기';
}

// Path: clubs.repository
class _TranslationsClubsRepositoryKo extends TranslationsClubsRepositoryId {
	_TranslationsClubsRepositoryKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get chatCreated => '클럽 채팅방이 생성되었습니다.';
}

// Path: clubs.proposal
class _TranslationsClubsProposalKo extends TranslationsClubsProposalId {
	_TranslationsClubsProposalKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get createTitle => '클럽 제안 만들기';
	@override String get imageError => '커버 이미지를 선택해 주세요.';
	@override String get createSuccess => '클럽 제안이 생성되었습니다.';
	@override String get createFail => '클럽 제안 생성 실패: {error}';
	@override String get tagsHint => '태그 입력 후 스페이스로 추가';
	@override String get targetMembers => '목표 인원';
	@override String get targetMembersCount => '총 {count}명';
	@override String get empty => '아직 제안이 없습니다.';
	@override String get memberStatus => '{current} / {target}명';
	@override String get join => '참여';
	@override String get leave => '나가기';
	@override String get members => '멤버';
	@override String get noMembers => '아직 참여자가 없습니다.';
	@override late final _TranslationsClubsProposalDetailKo detail = _TranslationsClubsProposalDetailKo._(_root);
}

// Path: findfriend.form
class _TranslationsFindfriendFormKo extends TranslationsFindfriendFormId {
	_TranslationsFindfriendFormKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '친구 찾기 프로필 만들기';
}

// Path: auctions.card
class _TranslationsAuctionsCardKo extends TranslationsAuctionsCardId {
	_TranslationsAuctionsCardKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get currentBid => '현재 입찰가';
	@override String get endTime => '남은 시간';
	@override String get ended => '종료됨';
	@override String get winningBid => '최종 낙찰가';
	@override String get winner => '낙찰자';
	@override String get noBidders => '아직 입찰자가 없습니다';
	@override String get unknownBidder => '알 수 없는 입찰자';
	@override String get timeLeft => '{hours}:{minutes}:{seconds} 남음';
	@override String get timeLeftDays => '{days}일 {hours}:{minutes}:{seconds} 남음';
}

// Path: auctions.errors
class _TranslationsAuctionsErrorsKo extends TranslationsAuctionsErrorsId {
	_TranslationsAuctionsErrorsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get fetchFailed => '경매 목록을 불러오지 못했습니다: {error}';
	@override String get notFound => '경매를 찾을 수 없습니다.';
	@override String get lowerBid => '현재 입찰가보다 높은 금액을 입력해야 합니다.';
	@override String get alreadyEnded => '이 경매는 이미 종료되었습니다.';
}

// Path: auctions.filter
class _TranslationsAuctionsFilterKo extends TranslationsAuctionsFilterId {
	_TranslationsAuctionsFilterKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get tooltip => '필터';
	@override String get clearTooltip => '필터 초기화';
}

// Path: auctions.create
class _TranslationsAuctionsCreateKo extends TranslationsAuctionsCreateId {
	_TranslationsAuctionsCreateKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get tooltip => '경매 등록';
	@override String get title => '경매 생성';
	@override String get registrationType => '등록 방식';
	@override late final _TranslationsAuctionsCreateTypeKo type = _TranslationsAuctionsCreateTypeKo._(_root);
	@override String get success => '경매가 생성되었습니다.';
	@override String get fail => '경매 생성 실패: {error}';
	@override String get submitButton => '경매 시작';
	@override String get confirmTitle => '경매로 등록하시겠습니까?';
	@override String get confirmContent => '경매로 등록하면 일반 판매로 되돌릴 수 없습니다. 낙찰 시 5%의 수수료가 부과됩니다. 계속하시겠습니까?';
	@override late final _TranslationsAuctionsCreateErrorsKo errors = _TranslationsAuctionsCreateErrorsKo._(_root);
	@override late final _TranslationsAuctionsCreateFormKo form = _TranslationsAuctionsCreateFormKo._(_root);
}

// Path: auctions.edit
class _TranslationsAuctionsEditKo extends TranslationsAuctionsEditId {
	_TranslationsAuctionsEditKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get tooltip => '경매 수정';
	@override String get title => '경매 수정';
	@override String get save => '저장';
	@override String get success => '경매가 수정되었습니다.';
	@override String get fail => '경매 수정 실패: {error}';
}

// Path: auctions.form
class _TranslationsAuctionsFormKo extends TranslationsAuctionsFormId {
	_TranslationsAuctionsFormKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get titleRequired => '제목을 입력해 주세요.';
	@override String get descriptionRequired => '설명을 입력해 주세요.';
	@override String get startPriceRequired => '시작가를 입력해 주세요.';
	@override String get categoryRequired => '카테고리를 선택해 주세요.';
}

// Path: auctions.delete
class _TranslationsAuctionsDeleteKo extends TranslationsAuctionsDeleteId {
	_TranslationsAuctionsDeleteKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get tooltip => '경매 삭제';
	@override String get confirmTitle => '경매 삭제';
	@override String get confirmContent => '이 경매를 삭제하시겠습니까?';
	@override String get success => '경매가 삭제되었습니다.';
	@override String get fail => '경매 삭제 실패: {error}';
}

// Path: auctions.detail
class _TranslationsAuctionsDetailKo extends TranslationsAuctionsDetailId {
	_TranslationsAuctionsDetailKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get currentBid => '현재 입찰가: {amount}';
	@override String get location => '위치';
	@override String get seller => '판매자';
	@override String get qnaTitle => '질문·답변';
	@override String get qnaHint => '판매자에게 질문하세요...';
	@override String get endTime => '종료 시간: {time}';
	@override String get bidsTitle => '입찰 내역';
	@override String get noBids => '입찰 내역이 없습니다.';
	@override String get unknownBidder => '알 수 없는 입찰자';
	@override String get bidAmountLabel => '입찰 금액 입력 (Rp)';
	@override String get placeBid => '입찰하기';
	@override String get bidSuccess => '입찰 성공!';
	@override String get bidFail => '입찰 실패: {error}';
	@override late final _TranslationsAuctionsDetailErrorsKo errors = _TranslationsAuctionsDetailErrorsKo._(_root);
}

// Path: localStores.create
class _TranslationsLocalStoresCreateKo extends TranslationsLocalStoresCreateId {
	_TranslationsLocalStoresCreateKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get tooltip => '내 가게 등록';
	@override String get title => '새 가게 등록';
	@override String get submit => '등록';
	@override String get success => '가게가 등록되었습니다.';
	@override String get fail => '가게 등록 실패: {error}';
}

// Path: localStores.edit
class _TranslationsLocalStoresEditKo extends TranslationsLocalStoresEditId {
	_TranslationsLocalStoresEditKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '가게 정보 수정';
	@override String get save => '저장';
	@override String get success => '가게 정보가 수정되었습니다.';
	@override String get fail => '가게 정보 수정 실패: {error}';
	@override String get tooltip => '가게 정보 수정';
}

// Path: localStores.form
class _TranslationsLocalStoresFormKo extends TranslationsLocalStoresFormId {
	_TranslationsLocalStoresFormKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get nameLabel => '가게 이름';
	@override String get nameError => '가게 이름을 입력해 주세요.';
	@override String get descriptionLabel => '가게 소개';
	@override String get descriptionError => '가게 소개를 입력해 주세요.';
	@override String get contactLabel => '연락처';
	@override String get hoursLabel => '영업 시간';
	@override String get hoursHint => '예: 09:00 - 18:00';
	@override String get photoLabel => '사진 (최대 {count}장)';
	@override String get categoryLabel => '카테고리';
	@override String get categoryError => '카테고리를 선택해 주세요.';
	@override String get productsLabel => '주요 상품/서비스';
	@override String get productsHint => '쉼표로 구분 (예: 커트, 염색, 펌)';
	@override String get imageError => '이미지를 불러오지 못했습니다. 다시 시도하세요.';
}

// Path: localStores.categories
class _TranslationsLocalStoresCategoriesKo extends TranslationsLocalStoresCategoriesId {
	_TranslationsLocalStoresCategoriesKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get all => '전체';
	@override String get food => '식당';
	@override String get cafe => '카페';
	@override String get massage => '마사지';
	@override String get beauty => '미용';
	@override String get nail => '네일';
	@override String get auto => '자동차 정비';
	@override String get kids => '키즈';
	@override String get hospital => '병원/클리닉';
	@override String get etc => '기타';
}

// Path: localStores.detail
class _TranslationsLocalStoresDetailKo extends TranslationsLocalStoresDetailId {
	_TranslationsLocalStoresDetailKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get description => '가게 소개';
	@override String get products => '상품/서비스';
	@override String get deleteTitle => '가게 삭제';
	@override String get deleteContent => '이 가게를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.';
	@override String get deleteTooltip => '가게 삭제';
	@override String get delete => '삭제';
	@override String get cancel => '취소';
	@override String get deleteSuccess => '가게가 삭제되었습니다.';
	@override String get deleteFail => '가게 삭제 실패: {error}';
	@override String get inquire => '문의';
	@override String get noOwnerInfo => '가게 주인 정보를 찾을 수 없습니다';
	@override String get startChatFail => '채팅을 시작할 수 없습니다: {error}';
	@override String get reviews => '리뷰';
	@override String get writeReview => '리뷰 작성';
	@override String get noReviews => '아직 리뷰가 없습니다.';
	@override String get reviewDialogContent => '리뷰를 작성해 주세요.';
}

// Path: pom.search
class _TranslationsPomSearchKo extends TranslationsPomSearchId {
	_TranslationsPomSearchKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get hint => 'POM, 태그, 사용자 검색';
}

// Path: pom.tabs
class _TranslationsPomTabsKo extends TranslationsPomTabsId {
	_TranslationsPomTabsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get local => '지역';
	@override String get all => '전체';
	@override String get popular => '인기';
	@override String get myPoms => '내 POM';
}

// Path: pom.errors
class _TranslationsPomErrorsKo extends TranslationsPomErrorsId {
	_TranslationsPomErrorsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get fetchFailed => '오류가 발생했습니다: {error}';
	@override String get videoSource => '이 영상은 재생할 수 없습니다. 소스가 차단되었거나 사용할 수 없습니다.';
}

// Path: pom.comments
class _TranslationsPomCommentsKo extends TranslationsPomCommentsId {
	_TranslationsPomCommentsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '댓글';
	@override String get viewAll => '{}개 댓글 모두 보기';
	@override String get empty => '아직 댓글이 없습니다.';
	@override String get placeholder => '댓글 작성...';
	@override String get fail => '댓글 작성 실패: {error}';
}

// Path: pom.create
class _TranslationsPomCreateKo extends TranslationsPomCreateId {
	_TranslationsPomCreateKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '새 POM 업로드';
	@override String get photo => '사진';
	@override String get video => '동영상';
	@override String get titleImage => '사진 업로드';
	@override String get submit => '업로드';
	@override String get success => 'POM이 업로드되었습니다.';
	@override String get fail => 'POM 업로드 실패: {error}';
	@override late final _TranslationsPomCreateFormKo form = _TranslationsPomCreateFormKo._(_root);
}

// Path: realEstate.form
class _TranslationsRealEstateFormKo extends TranslationsRealEstateFormId {
	_TranslationsRealEstateFormKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '매물 등록';
	@override String get submit => '등록';
	@override String get imageRequired => '최소 한 장의 사진을 첨부해 주세요.';
	@override String get success => '매물이 등록되었습니다.';
	@override String get fail => '매물 등록에 실패했습니다: {error}';
	@override late final _TranslationsRealEstateFormTypeKo type = _TranslationsRealEstateFormTypeKo._(_root);
	@override String get priceRequired => '가격을 입력해 주세요.';
	@override late final _TranslationsRealEstateFormPriceUnitKo priceUnit = _TranslationsRealEstateFormPriceUnitKo._(_root);
	@override String get titleRequired => '제목을 입력해 주세요.';
	@override late final _TranslationsRealEstateFormRoomTypesKo roomTypes = _TranslationsRealEstateFormRoomTypesKo._(_root);
	@override String get listingType => '거래 형태';
	@override String get listingTypeHint => '거래 형태를 선택해 주세요';
	@override late final _TranslationsRealEstateFormListingTypesKo listingTypes = _TranslationsRealEstateFormListingTypesKo._(_root);
	@override String get publisherType => '게시자 유형';
	@override late final _TranslationsRealEstateFormPublisherTypesKo publisherTypes = _TranslationsRealEstateFormPublisherTypesKo._(_root);
	@override String get area => '면적';
	@override String get landArea => '대지 면적';
	@override String get rooms => '방';
	@override String get bathrooms => '욕실';
	@override String get bedAbbr => '침실';
	@override String get bathAbbr => '욕실';
	@override String get moveInDate => '입주 가능 날짜';
	@override String get selectDate => '날짜 선택';
	@override String get clearDate => '날짜 지우기';
	@override String get amenities => '편의시설';
	@override String get details => '매물 상세 정보';
	@override String get maintenanceFee => '월 유지비';
	@override String get maintenanceFeeHint => '월 유지비 (Rp)';
	@override String get deposit => '보증금';
	@override String get depositHint => '보증금 (Rp)';
	@override String get floorInfo => '층수 정보';
	@override String get floorInfoHint => '예: 5층 중 3층';
	@override String get priceLabel => '가격 (IDR)';
	@override String get titleLabel => '제목';
	@override String get descriptionLabel => '설명';
	@override String get typeLabel => '방 유형';
	@override String get areaHint => '예: 33';
	@override late final _TranslationsRealEstateFormAmenityKo amenity = _TranslationsRealEstateFormAmenityKo._(_root);
}

// Path: realEstate.detail
class _TranslationsRealEstateDetailKo extends TranslationsRealEstateDetailId {
	_TranslationsRealEstateDetailKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get deleteTitle => '매물 삭제';
	@override String get deleteContent => '이 매물을 삭제하시겠습니까?';
	@override String get cancel => '취소';
	@override String get publisherInfo => '게시자 정보';
	@override String get contact => '연락하기';
	@override String get deleteConfirm => '삭제';
	@override String get deleteSuccess => '매물이 삭제되었습니다.';
	@override String get deleteFail => '매물 삭제 실패: {error}';
	@override String get chatError => '채팅을 시작할 수 없습니다: {error}';
	@override String get location => '위치';
}

// Path: realEstate.priceUnits
class _TranslationsRealEstatePriceUnitsKo extends TranslationsRealEstatePriceUnitsId {
	_TranslationsRealEstatePriceUnitsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get monthly => '월';
	@override String get yearly => '년';
}

// Path: realEstate.filter
class _TranslationsRealEstateFilterKo extends TranslationsRealEstateFilterId {
	_TranslationsRealEstateFilterKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '고급 필터';
	@override String get priceRange => '가격 범위';
	@override String get areaRange => '면적 범위 (m²)';
	@override String get landAreaRange => '대지 면적 범위 (m²)';
	@override String get depositRange => '보증금 범위';
	@override String get floorInfo => '층수 정보';
	@override String get depositMin => '최소 보증금';
	@override String get depositMax => '최대 보증금';
	@override String get clearFloorInfo => '지우기';
	@override String get furnishedStatus => '가구 옵션';
	@override String get rentPeriod => '임대 기간';
	@override String get selectFurnished => '가구 옵션 선택';
	@override String get furnishedHint => '가구 옵션 선택';
	@override String get selectRentPeriod => '임대 기간 선택';
	@override late final _TranslationsRealEstateFilterRentPeriodsKo rentPeriods = _TranslationsRealEstateFilterRentPeriodsKo._(_root);
	@override String get propertyCondition => '매물 상태';
	@override late final _TranslationsRealEstateFilterPropertyConditionsKo propertyConditions = _TranslationsRealEstateFilterPropertyConditionsKo._(_root);
	@override late final _TranslationsRealEstateFilterFurnishedTypesKo furnishedTypes = _TranslationsRealEstateFilterFurnishedTypesKo._(_root);
	@override late final _TranslationsRealEstateFilterAmenitiesKo amenities = _TranslationsRealEstateFilterAmenitiesKo._(_root);
	@override late final _TranslationsRealEstateFilterKosKo kos = _TranslationsRealEstateFilterKosKo._(_root);
	@override late final _TranslationsRealEstateFilterApartmentKo apartment = _TranslationsRealEstateFilterApartmentKo._(_root);
	@override late final _TranslationsRealEstateFilterHouseKo house = _TranslationsRealEstateFilterHouseKo._(_root);
	@override late final _TranslationsRealEstateFilterCommercialKo commercial = _TranslationsRealEstateFilterCommercialKo._(_root);
}

// Path: realEstate.info
class _TranslationsRealEstateInfoKo extends TranslationsRealEstateInfoId {
	_TranslationsRealEstateInfoKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get bed => '침실';
	@override String get bath => '욕실';
	@override String get anytime => '언제든지';
	@override String get verifiedPublisher => '인증된 게시자';
}

// Path: realEstate.priceUnit
class _TranslationsRealEstatePriceUnitKo extends TranslationsRealEstatePriceUnitId {
	_TranslationsRealEstatePriceUnitKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get monthly => '/월';
}

// Path: realEstate.edit
class _TranslationsRealEstateEditKo extends TranslationsRealEstateEditId {
	_TranslationsRealEstateEditKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '매물 수정';
	@override String get save => '저장';
	@override String get success => '매물이 수정되었습니다.';
	@override String get fail => '매물 수정 실패: {error}';
}

// Path: lostAndFound.tabs
class _TranslationsLostAndFoundTabsKo extends TranslationsLostAndFoundTabsId {
	_TranslationsLostAndFoundTabsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get all => '전체';
	@override String get lost => 'Lost';
	@override String get found => 'Found';
}

// Path: lostAndFound.form
class _TranslationsLostAndFoundFormKo extends TranslationsLostAndFoundFormId {
	_TranslationsLostAndFoundFormKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '분실/습득물 등록';
	@override String get submit => '등록';
	@override late final _TranslationsLostAndFoundFormTypeKo type = _TranslationsLostAndFoundFormTypeKo._(_root);
	@override String get photoSectionTitle => '사진 추가 (최대 5장)';
	@override String get imageRequired => '최소 한 장의 사진을 첨부해 주세요.';
	@override String get itemLabel => '어떤 물건인가요?';
	@override String get itemError => '물건을 설명해 주세요.';
	@override String get bountyTitle => '보상금 설정 (선택)';
	@override String get bountyDesc => '보상금을 설정하면 게시물에 보상금 배지가 표시됩니다.';
	@override String get bountyAmount => '보상금 금액 (IDR)';
	@override String get bountyAmountError => '보상금을 활성화하려면 금액을 입력해 주세요.';
	@override String get success => '등록 완료.';
	@override String get fail => '등록 실패: {error}';
	@override String get tagsHint => '태그 추가 (스페이스로 확정)';
	@override String get locationLabel => '위치';
	@override String get locationError => '위치를 입력해 주세요.';
}

// Path: lostAndFound.detail
class _TranslationsLostAndFoundDetailKo extends TranslationsLostAndFoundDetailId {
	_TranslationsLostAndFoundDetailKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '분실 · 습득';
	@override String get bounty => '보상금';
	@override String get registrant => '등록자';
	@override String get resolved => '해결됨';
	@override String get markAsResolved => '해결로 표시';
	@override String get deleteTitle => '게시물 삭제';
	@override String get deleteContent => '이 게시물을 삭제하시겠습니까? 삭제는 되돌릴 수 없습니다.';
	@override String get cancel => '취소';
	@override String get editTooltip => '수정';
	@override String get deleteTooltip => '삭제';
	@override String get noUser => '사용자를 찾을 수 없습니다';
	@override String get chatError => '채팅을 시작할 수 없습니다: {error}';
	@override String get location => '위치';
	@override String get contact => '문의하기';
	@override String get delete => '삭제';
	@override String get deleteSuccess => '삭제되었습니다.';
	@override String get deleteFail => '삭제 실패: {error}';
}

// Path: lostAndFound.card
class _TranslationsLostAndFoundCardKo extends TranslationsLostAndFoundCardId {
	_TranslationsLostAndFoundCardKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get location => '위치: {location}';
}

// Path: lostAndFound.resolve
class _TranslationsLostAndFoundResolveKo extends TranslationsLostAndFoundResolveId {
	_TranslationsLostAndFoundResolveKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get confirmTitle => '해결로 표시하시겠습니까?';
	@override String get confirmBody => '이 항목을 해결된 것으로 표시합니다.';
	@override String get success => '해결 처리되었습니다.';
	@override String get badgeLost => '발견됨!';
	@override String get badgeFound => '반환됨!';
}

// Path: lostAndFound.edit
class _TranslationsLostAndFoundEditKo extends TranslationsLostAndFoundEditId {
	_TranslationsLostAndFoundEditKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '글 수정';
	@override String get save => '저장';
	@override String get success => '수정되었습니다.';
	@override String get fail => '수정 실패: {error}';
}

// Path: shared.tagInput
class _TranslationsSharedTagInputKo extends TranslationsSharedTagInputId {
	_TranslationsSharedTagInputKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get defaultHint => '태그를 입력하세요 (스페이스를 눌러 확정)';
}

// Path: admin.screen
class _TranslationsAdminScreenKo extends TranslationsAdminScreenId {
	_TranslationsAdminScreenKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '관리자 메뉴';
}

// Path: admin.menu
class _TranslationsAdminMenuKo extends TranslationsAdminMenuId {
	_TranslationsAdminMenuKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get aiApproval => 'AI 인증 관리';
	@override String get reportManagement => '신고 관리';
}

// Path: admin.aiApproval
class _TranslationsAdminAiApprovalKo extends TranslationsAdminAiApprovalId {
	_TranslationsAdminAiApprovalKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get empty => 'AI 인증 대기 중인 상품이 없습니다.';
	@override String get error => '대기 중인 상품을 불러오는 중 오류가 발생했습니다.';
	@override String get requestedAt => '요청 시간';
}

// Path: admin.reports
class _TranslationsAdminReportsKo extends TranslationsAdminReportsId {
	_TranslationsAdminReportsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '신고 관리';
	@override String get empty => '대기 중인 신고가 없습니다.';
	@override String get error => '신고 목록을 불러오는 중 오류가 발생했습니다.';
	@override String get createdAt => '생성 시간';
}

// Path: admin.reportList
class _TranslationsAdminReportListKo extends TranslationsAdminReportListId {
	_TranslationsAdminReportListKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '신고 관리';
	@override String get empty => '대기 중인 신고가 없습니다.';
	@override String get error => '신고 목록을 불러오는 중 오류가 발생했습니다.';
}

// Path: admin.reportDetail
class _TranslationsAdminReportDetailKo extends TranslationsAdminReportDetailId {
	_TranslationsAdminReportDetailKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => '신고 상세';
	@override String get loadError => '신고 상세를 불러오는 중 오류가 발생했습니다.';
	@override String get sectionReportInfo => '신고 정보';
	@override String get idLabel => 'ID';
	@override String get postIdLabel => '신고된 게시글 ID';
	@override String get reporter => '신고자';
	@override String get reportedUser => '신고 대상 사용자';
	@override String get reason => '사유';
	@override String get reportedAt => '신고 시간';
	@override String get currentStatus => '상태';
	@override String get sectionContent => '신고된 내용';
	@override String get loadingContent => '내용을 불러오는 중...';
	@override String get contentLoadError => '신고된 내용을 불러오지 못했습니다.';
	@override String get contentNotAvailable => '내용 정보가 없거나 삭제되었습니다.';
	@override String get authorIdLabel => '작성자 ID';
	@override late final _TranslationsAdminReportDetailContentKo content = _TranslationsAdminReportDetailContentKo._(_root);
	@override String get viewOriginalPost => '원본 게시글 보기';
	@override String get sectionActions => '조치';
	@override String get actionReviewed => '검토 완료로 표시';
	@override String get actionTaken => '조치 완료로 표시(예: 삭제)';
	@override String get actionDismissed => '신고 무시';
	@override String get statusUpdateSuccess => '신고 상태가 \'{status}\'(으)로 변경되었습니다.';
	@override String get statusUpdateFail => '상태를 업데이트하지 못했습니다: {error}';
	@override String get originalPostNotFound => '원본 게시글을 찾을 수 없습니다.';
	@override String get couldNotOpenOriginalPost => '원본 게시글을 열 수 없습니다.';
}

// Path: admin.dataFix
class _TranslationsAdminDataFixKo extends TranslationsAdminDataFixId {
	_TranslationsAdminDataFixKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get logsLabel => 'Data Fix Logs';
}

// Path: tags.localNews
class _TranslationsTagsLocalNewsKo extends TranslationsTagsLocalNewsId {
	_TranslationsTagsLocalNewsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsTagsLocalNewsKelurahanNoticeKo kelurahanNotice = _TranslationsTagsLocalNewsKelurahanNoticeKo._(_root);
	@override late final _TranslationsTagsLocalNewsKecamatanNoticeKo kecamatanNotice = _TranslationsTagsLocalNewsKecamatanNoticeKo._(_root);
	@override late final _TranslationsTagsLocalNewsPublicCampaignKo publicCampaign = _TranslationsTagsLocalNewsPublicCampaignKo._(_root);
	@override late final _TranslationsTagsLocalNewsSiskamlingKo siskamling = _TranslationsTagsLocalNewsSiskamlingKo._(_root);
	@override late final _TranslationsTagsLocalNewsPowerOutageKo powerOutage = _TranslationsTagsLocalNewsPowerOutageKo._(_root);
	@override late final _TranslationsTagsLocalNewsWaterOutageKo waterOutage = _TranslationsTagsLocalNewsWaterOutageKo._(_root);
	@override late final _TranslationsTagsLocalNewsWasteCollectionKo wasteCollection = _TranslationsTagsLocalNewsWasteCollectionKo._(_root);
	@override late final _TranslationsTagsLocalNewsRoadWorksKo roadWorks = _TranslationsTagsLocalNewsRoadWorksKo._(_root);
	@override late final _TranslationsTagsLocalNewsPublicFacilityKo publicFacility = _TranslationsTagsLocalNewsPublicFacilityKo._(_root);
	@override late final _TranslationsTagsLocalNewsWeatherWarningKo weatherWarning = _TranslationsTagsLocalNewsWeatherWarningKo._(_root);
	@override late final _TranslationsTagsLocalNewsFloodAlertKo floodAlert = _TranslationsTagsLocalNewsFloodAlertKo._(_root);
	@override late final _TranslationsTagsLocalNewsAirQualityKo airQuality = _TranslationsTagsLocalNewsAirQualityKo._(_root);
	@override late final _TranslationsTagsLocalNewsDiseaseAlertKo diseaseAlert = _TranslationsTagsLocalNewsDiseaseAlertKo._(_root);
	@override late final _TranslationsTagsLocalNewsSchoolNoticeKo schoolNotice = _TranslationsTagsLocalNewsSchoolNoticeKo._(_root);
	@override late final _TranslationsTagsLocalNewsPosyanduKo posyandu = _TranslationsTagsLocalNewsPosyanduKo._(_root);
	@override late final _TranslationsTagsLocalNewsHealthCampaignKo healthCampaign = _TranslationsTagsLocalNewsHealthCampaignKo._(_root);
	@override late final _TranslationsTagsLocalNewsTrafficControlKo trafficControl = _TranslationsTagsLocalNewsTrafficControlKo._(_root);
	@override late final _TranslationsTagsLocalNewsPublicTransportKo publicTransport = _TranslationsTagsLocalNewsPublicTransportKo._(_root);
	@override late final _TranslationsTagsLocalNewsParkingPolicyKo parkingPolicy = _TranslationsTagsLocalNewsParkingPolicyKo._(_root);
	@override late final _TranslationsTagsLocalNewsCommunityEventKo communityEvent = _TranslationsTagsLocalNewsCommunityEventKo._(_root);
	@override late final _TranslationsTagsLocalNewsWorshipEventKo worshipEvent = _TranslationsTagsLocalNewsWorshipEventKo._(_root);
	@override late final _TranslationsTagsLocalNewsIncidentReportKo incidentReport = _TranslationsTagsLocalNewsIncidentReportKo._(_root);
}

// Path: boards.popup
class _TranslationsBoardsPopupKo extends TranslationsBoardsPopupId {
	_TranslationsBoardsPopupKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get inactiveTitle => '동네 게시판이 아직 활성화되지 않았습니다';
	@override String get inactiveBody => '동네 게시판을 열려면 먼저 동네 소식을 한 번 올려 주세요. 이웃들이 참여하면 게시판이 자동으로 열립니다.';
	@override String get writePost => '동네 소식 쓰기';
}

// Path: signup.alerts
class _TranslationsSignupAlertsKo extends TranslationsSignupAlertsId {
	_TranslationsSignupAlertsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get signupSuccessLoginNotice => '회원가입이 완료되었습니다! 이제 로그인해 주세요.';
}

// Path: signup.buttons
class _TranslationsSignupButtonsKo extends TranslationsSignupButtonsId {
	_TranslationsSignupButtonsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get signup => '회원가입';
}

// Path: main.search.hint
class _TranslationsMainSearchHintKo extends TranslationsMainSearchHintId {
	_TranslationsMainSearchHintKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get globalSheet => '{}에서 검색';
	@override String get localNews => '제목·내용·태그 검색';
	@override String get jobs => '직업·회사·도움요청 검색';
	@override String get lostAndFound => '분실·습득물 검색';
	@override String get marketplace => '판매 상품 검색';
	@override String get localStores => '가게·서비스 검색';
	@override String get findFriends => '닉네임·관심사 검색';
	@override String get clubs => '모임·관심사·위치 검색';
	@override String get realEstate => '매물·지역·가격 검색';
	@override String get auction => '경매 물품·브랜드 검색';
	@override String get pom => 'POM·태그·사용자 검색';
}

// Path: drawer.trustDashboard.breakdown
class _TranslationsDrawerTrustDashboardBreakdownKo extends TranslationsDrawerTrustDashboardBreakdownId {
	_TranslationsDrawerTrustDashboardBreakdownKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get kelurahanAuth => '+50';
	@override String get rtRwAuth => '+50';
	@override String get phoneAuth => '+100';
	@override String get profileComplete => '+50';
	@override String get feedThanks => '1회당 +10';
	@override String get marketThanks => '1회당 +20';
	@override String get reports => '1회당 -50';
}

// Path: marketplace.takeover.guide
class _TranslationsMarketplaceTakeoverGuideKo extends TranslationsMarketplaceTakeoverGuideId {
	_TranslationsMarketplaceTakeoverGuideKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get title => 'AI 현장 유사도 검증';
	@override String get subtitle => '원래 AI 보고서와 실제 물건이 같은지 확인합니다. 물건의 핵심 특징이 잘 보이도록 3장 이상 촬영해 주세요.';
}

// Path: marketplace.takeover.errors
class _TranslationsMarketplaceTakeoverErrorsKo extends TranslationsMarketplaceTakeoverErrorsId {
	_TranslationsMarketplaceTakeoverErrorsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get noPhoto => '현장 사진이 최소 1장은 있어야 검증을 진행할 수 있습니다.';
}

// Path: marketplace.takeover.dialog
class _TranslationsMarketplaceTakeoverDialogKo extends TranslationsMarketplaceTakeoverDialogId {
	_TranslationsMarketplaceTakeoverDialogKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get matchTitle => 'AI 검증 성공';
	@override String get noMatchTitle => 'AI 검증 실패';
	@override String get finalize => '최종 인수 확정';
	@override String get cancelDeal => '거래 취소(환불 요청)';
}

// Path: marketplace.takeover.success
class _TranslationsMarketplaceTakeoverSuccessKo extends TranslationsMarketplaceTakeoverSuccessId {
	_TranslationsMarketplaceTakeoverSuccessKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get finalized => '거래가 정상적으로 완료되었습니다.';
	@override String get cancelled => '거래가 취소되었습니다. 예약금은 환불됩니다.';
}

// Path: categories.post.jalanPerbaikin
class _TranslationsCategoriesPostJalanPerbaikinKo extends TranslationsCategoriesPostJalanPerbaikinId {
	_TranslationsCategoriesPostJalanPerbaikinKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsCategoriesPostJalanPerbaikinSearchKo search = _TranslationsCategoriesPostJalanPerbaikinSearchKo._(_root);
	@override String get name => '도로 보수';
}

// Path: categories.post.dailyLife
class _TranslationsCategoriesPostDailyLifeKo extends TranslationsCategoriesPostDailyLifeId {
	_TranslationsCategoriesPostDailyLifeKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '일상/질문';
	@override String get description => '일상을 공유하거나 궁금한 점을 물어보세요.';
}

// Path: categories.post.helpShare
class _TranslationsCategoriesPostHelpShareKo extends TranslationsCategoriesPostHelpShareId {
	_TranslationsCategoriesPostHelpShareKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '도움/나눔';
	@override String get description => '도움이 필요하거나 나누고 싶은 것이 있을 때 올려 보세요.';
}

// Path: categories.post.incidentReport
class _TranslationsCategoriesPostIncidentReportKo extends TranslationsCategoriesPostIncidentReportId {
	_TranslationsCategoriesPostIncidentReportKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '사건/사고';
	@override String get description => '동네에서 일어난 사건·사고 소식을 공유하세요.';
}

// Path: categories.post.localNews
class _TranslationsCategoriesPostLocalNewsKo extends TranslationsCategoriesPostLocalNewsId {
	_TranslationsCategoriesPostLocalNewsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '동네 소식';
	@override String get description => '우리 동네 뉴스와 정보를 공유하세요.';
}

// Path: categories.post.november
class _TranslationsCategoriesPostNovemberKo extends TranslationsCategoriesPostNovemberId {
	_TranslationsCategoriesPostNovemberKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '11월';
}

// Path: categories.post.rain
class _TranslationsCategoriesPostRainKo extends TranslationsCategoriesPostRainId {
	_TranslationsCategoriesPostRainKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '비/날씨';
}

// Path: categories.post.dailyQuestion
class _TranslationsCategoriesPostDailyQuestionKo extends TranslationsCategoriesPostDailyQuestionId {
	_TranslationsCategoriesPostDailyQuestionKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '질문 있어요';
	@override String get description => '이웃에게 무엇이든 물어보세요.';
}

// Path: categories.post.storePromo
class _TranslationsCategoriesPostStorePromoKo extends TranslationsCategoriesPostStorePromoId {
	_TranslationsCategoriesPostStorePromoKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '가게 프로모션';
	@override String get description => '내 가게 할인이나 이벤트를 홍보하세요.';
}

// Path: categories.post.etc
class _TranslationsCategoriesPostEtcKo extends TranslationsCategoriesPostEtcId {
	_TranslationsCategoriesPostEtcKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '기타';
	@override String get description => '그 외 다양한 이야기를 자유롭게 나누세요.';
}

// Path: categories.auction.collectibles
class _TranslationsCategoriesAuctionCollectiblesKo extends TranslationsCategoriesAuctionCollectiblesId {
	_TranslationsCategoriesAuctionCollectiblesKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '컬렉터블';
	@override String get description => '피규어, 카드, 장난감 등 수집품.';
}

// Path: categories.auction.digital
class _TranslationsCategoriesAuctionDigitalKo extends TranslationsCategoriesAuctionDigitalId {
	_TranslationsCategoriesAuctionDigitalKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '디지털';
	@override String get description => '디지털 상품 및 자산.';
}

// Path: categories.auction.fashion
class _TranslationsCategoriesAuctionFashionKo extends TranslationsCategoriesAuctionFashionId {
	_TranslationsCategoriesAuctionFashionKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '패션';
	@override String get description => '의류, 액세서리, 뷰티 제품.';
}

// Path: categories.auction.vintage
class _TranslationsCategoriesAuctionVintageKo extends TranslationsCategoriesAuctionVintageId {
	_TranslationsCategoriesAuctionVintageKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '빈티지';
	@override String get description => '레트로·클래식 아이템.';
}

// Path: categories.auction.artCraft
class _TranslationsCategoriesAuctionArtCraftKo extends TranslationsCategoriesAuctionArtCraftId {
	_TranslationsCategoriesAuctionArtCraftKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '아트 & 공예';
	@override String get description => '작품, 수공예품 등.';
}

// Path: categories.auction.etc
class _TranslationsCategoriesAuctionEtcKo extends TranslationsCategoriesAuctionEtcId {
	_TranslationsCategoriesAuctionEtcKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '기타';
	@override String get description => '그 외 모든 경매 상품.';
}

// Path: clubs.detail.tabs
class _TranslationsClubsDetailTabsKo extends TranslationsClubsDetailTabsId {
	_TranslationsClubsDetailTabsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get info => '정보';
	@override String get board => '게시판';
	@override String get members => '멤버';
}

// Path: clubs.detail.info
class _TranslationsClubsDetailInfoKo extends TranslationsClubsDetailInfoId {
	_TranslationsClubsDetailInfoKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get members => '멤버';
	@override String get location => '위치';
}

// Path: clubs.proposal.detail
class _TranslationsClubsProposalDetailKo extends TranslationsClubsProposalDetailId {
	_TranslationsClubsProposalDetailKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get joined => '제안에 참여했습니다!';
	@override String get left => '제안에서 나갔습니다.';
	@override String get loginRequired => '참여하려면 로그인하세요.';
	@override String get error => '오류가 발생했습니다: {error}';
}

// Path: auctions.create.type
class _TranslationsAuctionsCreateTypeKo extends TranslationsAuctionsCreateTypeId {
	_TranslationsAuctionsCreateTypeKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get sale => '판매';
	@override String get auction => '경매';
}

// Path: auctions.create.errors
class _TranslationsAuctionsCreateErrorsKo extends TranslationsAuctionsCreateErrorsId {
	_TranslationsAuctionsCreateErrorsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get noPhoto => '사진을 최소 1장 이상 추가해 주세요.';
}

// Path: auctions.create.form
class _TranslationsAuctionsCreateFormKo extends TranslationsAuctionsCreateFormId {
	_TranslationsAuctionsCreateFormKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get photoSectionTitle => '사진 업로드 (최대 10장)';
	@override String get title => '제목';
	@override String get description => '설명';
	@override String get startPrice => '시작가';
	@override String get category => '카테고리';
	@override String get categoryHint => '카테고리 선택';
	@override String get tagsHint => '태그 입력 후 스페이스로 추가';
	@override String get duration => '기간';
	@override String get durationOption => '{days}일';
	@override String get location => '위치';
}

// Path: auctions.detail.errors
class _TranslationsAuctionsDetailErrorsKo extends TranslationsAuctionsDetailErrorsId {
	_TranslationsAuctionsDetailErrorsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get loginRequired => '로그인이 필요합니다.';
	@override String get invalidAmount => '올바른 입찰 금액을 입력하세요.';
}

// Path: pom.create.form
class _TranslationsPomCreateFormKo extends TranslationsPomCreateFormId {
	_TranslationsPomCreateFormKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get titleLabel => '제목';
	@override String get descriptionLabel => '설명';
}

// Path: realEstate.form.type
class _TranslationsRealEstateFormTypeKo extends TranslationsRealEstateFormTypeId {
	_TranslationsRealEstateFormTypeKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get kos => '하숙방(Kos)';
	@override String get kontrakan => '월세(Kontrakan)';
	@override String get sewa => '임대(Sewa)';
}

// Path: realEstate.form.priceUnit
class _TranslationsRealEstateFormPriceUnitKo extends TranslationsRealEstateFormPriceUnitId {
	_TranslationsRealEstateFormPriceUnitKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get monthly => '/월';
	@override String get yearly => '/년';
}

// Path: realEstate.form.roomTypes
class _TranslationsRealEstateFormRoomTypesKo extends TranslationsRealEstateFormRoomTypesId {
	_TranslationsRealEstateFormRoomTypesKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get kos => '하숙방(Kos)';
	@override String get kontrakan => '월세(Kontrakan)';
	@override String get sewa => '임대(Sewa)';
	@override String get apartment => '아파트';
	@override String get house => '주택';
	@override String get ruko => '상가(Ruko)';
	@override String get gudang => '창고';
	@override String get kantor => '사무실';
	@override String get etc => '기타';
}

// Path: realEstate.form.listingTypes
class _TranslationsRealEstateFormListingTypesKo extends TranslationsRealEstateFormListingTypesId {
	_TranslationsRealEstateFormListingTypesKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get rent => '임대';
	@override String get sale => '매매';
}

// Path: realEstate.form.publisherTypes
class _TranslationsRealEstateFormPublisherTypesKo extends TranslationsRealEstateFormPublisherTypesId {
	_TranslationsRealEstateFormPublisherTypesKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get individual => '개인';
	@override String get agent => '중개인';
}

// Path: realEstate.form.amenity
class _TranslationsRealEstateFormAmenityKo extends TranslationsRealEstateFormAmenityId {
	_TranslationsRealEstateFormAmenityKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get wifi => 'Wi‑Fi';
	@override String get ac => '에어컨';
	@override String get parking => '주차';
	@override String get kitchen => '주방';
}

// Path: realEstate.filter.rentPeriods
class _TranslationsRealEstateFilterRentPeriodsKo extends TranslationsRealEstateFilterRentPeriodsId {
	_TranslationsRealEstateFilterRentPeriodsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get daily => '일간';
	@override String get monthly => '월간';
	@override String get yearly => '연간';
}

// Path: realEstate.filter.propertyConditions
class _TranslationsRealEstateFilterPropertyConditionsKo extends TranslationsRealEstateFilterPropertyConditionsId {
	_TranslationsRealEstateFilterPropertyConditionsKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get kNew => '신규';
	@override String get used => '중고';
}

// Path: realEstate.filter.furnishedTypes
class _TranslationsRealEstateFilterFurnishedTypesKo extends TranslationsRealEstateFilterFurnishedTypesId {
	_TranslationsRealEstateFilterFurnishedTypesKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get furnished => '풀옵션';
	@override String get semiFurnished => '부분 옵션';
	@override String get unfurnished => '옵션 없음';
}

// Path: realEstate.filter.amenities
class _TranslationsRealEstateFilterAmenitiesKo extends TranslationsRealEstateFilterAmenitiesId {
	_TranslationsRealEstateFilterAmenitiesKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get ac => '에어컨';
	@override String get bed => '침대';
	@override String get closet => '옷장';
	@override String get desk => '책상';
	@override String get wifi => 'Wi‑Fi';
	@override String get kitchen => '주방';
	@override String get livingRoom => '거실';
	@override String get refrigerator => '냉장고';
	@override String get parkingMotorcycle => '오토바이 주차';
	@override String get parkingCar => '자동차 주차';
	@override String get pool => '수영장';
	@override String get gym => '헬스장';
	@override String get security24h => '24시간 보안';
	@override String get atmCenter => 'ATM';
	@override String get minimarket => '미니마트';
	@override String get mallAccess => '쇼핑몰 접근';
	@override String get playground => '놀이터';
	@override String get carport => '카포트';
	@override String get garden => '정원';
	@override String get pam => '상수도(PAM)';
	@override String get telephone => '전화';
	@override String get waterHeater => '온수기';
	@override String get parkingArea => '주차 공간';
	@override String get electricity => '전기';
	@override String get containerAccess => '컨테이너 출입';
	@override late final _TranslationsRealEstateFilterAmenitiesKosRoomKo kosRoom = _TranslationsRealEstateFilterAmenitiesKosRoomKo._(_root);
	@override late final _TranslationsRealEstateFilterAmenitiesKosPublicKo kosPublic = _TranslationsRealEstateFilterAmenitiesKosPublicKo._(_root);
	@override late final _TranslationsRealEstateFilterAmenitiesApartmentKo apartment = _TranslationsRealEstateFilterAmenitiesApartmentKo._(_root);
	@override late final _TranslationsRealEstateFilterAmenitiesHouseKo house = _TranslationsRealEstateFilterAmenitiesHouseKo._(_root);
	@override late final _TranslationsRealEstateFilterAmenitiesCommercialKo commercial = _TranslationsRealEstateFilterAmenitiesCommercialKo._(_root);
}

// Path: realEstate.filter.kos
class _TranslationsRealEstateFilterKosKo extends TranslationsRealEstateFilterKosId {
	_TranslationsRealEstateFilterKosKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get bathroomType => '욕실 유형';
	@override late final _TranslationsRealEstateFilterKosBathroomTypesKo bathroomTypes = _TranslationsRealEstateFilterKosBathroomTypesKo._(_root);
	@override String get maxOccupants => '최대 거주자 수';
	@override String get hintBathroomType => '욕실 유형 선택';
	@override String get hintMaxOccupants => '거주자 수 선택';
	@override String get electricityIncluded => '전기 포함';
	@override String get roomFacilities => '객실 시설';
	@override String get publicFacilities => '공용 시설';
	@override String get occupant => '명';
}

// Path: realEstate.filter.apartment
class _TranslationsRealEstateFilterApartmentKo extends TranslationsRealEstateFilterApartmentId {
	_TranslationsRealEstateFilterApartmentKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get facilities => '아파트 시설';
}

// Path: realEstate.filter.house
class _TranslationsRealEstateFilterHouseKo extends TranslationsRealEstateFilterHouseId {
	_TranslationsRealEstateFilterHouseKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get facilities => '주택 시설';
}

// Path: realEstate.filter.commercial
class _TranslationsRealEstateFilterCommercialKo extends TranslationsRealEstateFilterCommercialId {
	_TranslationsRealEstateFilterCommercialKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get facilities => '상업용 시설';
}

// Path: lostAndFound.form.type
class _TranslationsLostAndFoundFormTypeKo extends TranslationsLostAndFoundFormTypeId {
	_TranslationsLostAndFoundFormTypeKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get lost => '분실했습니다';
	@override String get found => '습득했습니다';
}

// Path: admin.reportDetail.content
class _TranslationsAdminReportDetailContentKo extends TranslationsAdminReportDetailContentId {
	_TranslationsAdminReportDetailContentKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get post => '게시글: {title}\n\n{body}';
	@override String get comment => '댓글: {content}';
	@override String get reply => '답글: {content}';
}

// Path: tags.localNews.kelurahanNotice
class _TranslationsTagsLocalNewsKelurahanNoticeKo extends TranslationsTagsLocalNewsKelurahanNoticeId {
	_TranslationsTagsLocalNewsKelurahanNoticeKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => 'Kelurahan 공지';
	@override String get desc => 'Kelurahan 동사무소에서 올리는 안내입니다.';
}

// Path: tags.localNews.kecamatanNotice
class _TranslationsTagsLocalNewsKecamatanNoticeKo extends TranslationsTagsLocalNewsKecamatanNoticeId {
	_TranslationsTagsLocalNewsKecamatanNoticeKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => 'Kecamatan 공지';
	@override String get desc => '구청/군청(Kecamatan)에서 올리는 안내입니다.';
}

// Path: tags.localNews.publicCampaign
class _TranslationsTagsLocalNewsPublicCampaignKo extends TranslationsTagsLocalNewsPublicCampaignId {
	_TranslationsTagsLocalNewsPublicCampaignKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '공익 캠페인';
	@override String get desc => '공익 정보와 정부 프로그램 안내입니다.';
}

// Path: tags.localNews.siskamling
class _TranslationsTagsLocalNewsSiskamlingKo extends TranslationsTagsLocalNewsSiskamlingId {
	_TranslationsTagsLocalNewsSiskamlingKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '동네 방범';
	@override String get desc => '주민 자율 방범·순찰 활동입니다.';
}

// Path: tags.localNews.powerOutage
class _TranslationsTagsLocalNewsPowerOutageKo extends TranslationsTagsLocalNewsPowerOutageId {
	_TranslationsTagsLocalNewsPowerOutageKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '정전 정보';
	@override String get desc => '내 동네 전기 끊김·정전 안내입니다.';
}

// Path: tags.localNews.waterOutage
class _TranslationsTagsLocalNewsWaterOutageKo extends TranslationsTagsLocalNewsWaterOutageId {
	_TranslationsTagsLocalNewsWaterOutageKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '단수 정보';
	@override String get desc => '수도 공급 중단 안내입니다.';
}

// Path: tags.localNews.wasteCollection
class _TranslationsTagsLocalNewsWasteCollectionKo extends TranslationsTagsLocalNewsWasteCollectionId {
	_TranslationsTagsLocalNewsWasteCollectionKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '쓰레기 수거';
	@override String get desc => '쓰레기 수거 일정이나 변경 안내입니다.';
}

// Path: tags.localNews.roadWorks
class _TranslationsTagsLocalNewsRoadWorksKo extends TranslationsTagsLocalNewsRoadWorksId {
	_TranslationsTagsLocalNewsRoadWorksKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '도로 공사';
	@override String get desc => '도로 공사 및 보수 작업 안내입니다.';
}

// Path: tags.localNews.publicFacility
class _TranslationsTagsLocalNewsPublicFacilityKo extends TranslationsTagsLocalNewsPublicFacilityId {
	_TranslationsTagsLocalNewsPublicFacilityKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '공공시설';
	@override String get desc => '공원, 운동장 등 공공시설 관련 소식입니다.';
}

// Path: tags.localNews.weatherWarning
class _TranslationsTagsLocalNewsWeatherWarningKo extends TranslationsTagsLocalNewsWeatherWarningId {
	_TranslationsTagsLocalNewsWeatherWarningKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '기상 특보';
	@override String get desc => '내 동네 악천후·기상 특보 안내입니다.';
}

// Path: tags.localNews.floodAlert
class _TranslationsTagsLocalNewsFloodAlertKo extends TranslationsTagsLocalNewsFloodAlertId {
	_TranslationsTagsLocalNewsFloodAlertKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '홍수 경보';
	@override String get desc => '홍수 위험 및 침수 지역 안내입니다.';
}

// Path: tags.localNews.airQuality
class _TranslationsTagsLocalNewsAirQualityKo extends TranslationsTagsLocalNewsAirQualityId {
	_TranslationsTagsLocalNewsAirQualityKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '대기질';
	@override String get desc => '미세먼지 등 대기오염·AQI 정보입니다.';
}

// Path: tags.localNews.diseaseAlert
class _TranslationsTagsLocalNewsDiseaseAlertKo extends TranslationsTagsLocalNewsDiseaseAlertId {
	_TranslationsTagsLocalNewsDiseaseAlertKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '질병 경보';
	@override String get desc => '감염병 경보와 보건 관련 안내입니다.';
}

// Path: tags.localNews.schoolNotice
class _TranslationsTagsLocalNewsSchoolNoticeKo extends TranslationsTagsLocalNewsSchoolNoticeId {
	_TranslationsTagsLocalNewsSchoolNoticeKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '학교 공지';
	@override String get desc => '주변 학교에서 올리는 안내입니다.';
}

// Path: tags.localNews.posyandu
class _TranslationsTagsLocalNewsPosyanduKo extends TranslationsTagsLocalNewsPosyanduId {
	_TranslationsTagsLocalNewsPosyanduKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => 'Posyandu';
	@override String get desc => '지역 보건소, 영유아·산모 대상 활동 안내입니다.';
}

// Path: tags.localNews.healthCampaign
class _TranslationsTagsLocalNewsHealthCampaignKo extends TranslationsTagsLocalNewsHealthCampaignId {
	_TranslationsTagsLocalNewsHealthCampaignKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '보건 캠페인';
	@override String get desc => '건강 캠페인 및 공중보건 안내입니다.';
}

// Path: tags.localNews.trafficControl
class _TranslationsTagsLocalNewsTrafficControlKo extends TranslationsTagsLocalNewsTrafficControlId {
	_TranslationsTagsLocalNewsTrafficControlKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '교통 통제';
	@override String get desc => '우회로, 도로 통제, 차단 정보입니다.';
}

// Path: tags.localNews.publicTransport
class _TranslationsTagsLocalNewsPublicTransportKo extends TranslationsTagsLocalNewsPublicTransportId {
	_TranslationsTagsLocalNewsPublicTransportKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '대중교통';
	@override String get desc => '버스·기차 등 대중교통 관련 안내입니다.';
}

// Path: tags.localNews.parkingPolicy
class _TranslationsTagsLocalNewsParkingPolicyKo extends TranslationsTagsLocalNewsParkingPolicyId {
	_TranslationsTagsLocalNewsParkingPolicyKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '주차 정책';
	@override String get desc => '주차 정보 및 정책 변경 안내입니다.';
}

// Path: tags.localNews.communityEvent
class _TranslationsTagsLocalNewsCommunityEventKo extends TranslationsTagsLocalNewsCommunityEventId {
	_TranslationsTagsLocalNewsCommunityEventKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '지역 행사';
	@override String get desc => '동네 축제, 모임, 행사 안내입니다.';
}

// Path: tags.localNews.worshipEvent
class _TranslationsTagsLocalNewsWorshipEventKo extends TranslationsTagsLocalNewsWorshipEventId {
	_TranslationsTagsLocalNewsWorshipEventKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '종교 행사';
	@override String get desc => '모스크, 교회, 사원 등 종교 행사 안내입니다.';
}

// Path: tags.localNews.incidentReport
class _TranslationsTagsLocalNewsIncidentReportKo extends TranslationsTagsLocalNewsIncidentReportId {
	_TranslationsTagsLocalNewsIncidentReportKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get name => '사건·사고 제보';
	@override String get desc => '우리 동네에서 발생한 사건·사고 제보입니다.';
}

// Path: categories.post.jalanPerbaikin.search
class _TranslationsCategoriesPostJalanPerbaikinSearchKo extends TranslationsCategoriesPostJalanPerbaikinSearchId {
	_TranslationsCategoriesPostJalanPerbaikinSearchKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get hint => 'POM, 태그, 사용자 검색';
}

// Path: realEstate.filter.amenities.kosRoom
class _TranslationsRealEstateFilterAmenitiesKosRoomKo extends TranslationsRealEstateFilterAmenitiesKosRoomId {
	_TranslationsRealEstateFilterAmenitiesKosRoomKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get ac => '에어컨';
	@override String get bed => '침대';
	@override String get closet => '옷장';
	@override String get desk => '책상';
	@override String get wifi => 'Wi‑Fi';
}

// Path: realEstate.filter.amenities.kosPublic
class _TranslationsRealEstateFilterAmenitiesKosPublicKo extends TranslationsRealEstateFilterAmenitiesKosPublicId {
	_TranslationsRealEstateFilterAmenitiesKosPublicKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get kitchen => '주방';
	@override String get livingRoom => '거실';
	@override String get refrigerator => '냉장고';
	@override String get parkingMotorcycle => '오토바이 주차';
	@override String get parkingCar => '자동차 주차';
}

// Path: realEstate.filter.amenities.apartment
class _TranslationsRealEstateFilterAmenitiesApartmentKo extends TranslationsRealEstateFilterAmenitiesApartmentId {
	_TranslationsRealEstateFilterAmenitiesApartmentKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get pool => '수영장';
	@override String get gym => '헬스장';
	@override String get security24h => '24시간 보안';
	@override String get atmCenter => 'ATM';
	@override String get minimarket => '미니마트';
	@override String get mallAccess => '쇼핑몰 접근';
	@override String get playground => '놀이터';
}

// Path: realEstate.filter.amenities.house
class _TranslationsRealEstateFilterAmenitiesHouseKo extends TranslationsRealEstateFilterAmenitiesHouseId {
	_TranslationsRealEstateFilterAmenitiesHouseKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get carport => '카포트';
	@override String get garden => '정원';
	@override String get pam => '상수도(PAM)';
	@override String get telephone => '전화';
	@override String get waterHeater => '온수기';
}

// Path: realEstate.filter.amenities.commercial
class _TranslationsRealEstateFilterAmenitiesCommercialKo extends TranslationsRealEstateFilterAmenitiesCommercialId {
	_TranslationsRealEstateFilterAmenitiesCommercialKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get parkingArea => '주차 공간';
	@override String get security24h => '24시간 보안';
	@override String get telephone => '전화';
	@override String get electricity => '전기';
	@override String get containerAccess => '컨테이너 출입';
}

// Path: realEstate.filter.kos.bathroomTypes
class _TranslationsRealEstateFilterKosBathroomTypesKo extends TranslationsRealEstateFilterKosBathroomTypesId {
	_TranslationsRealEstateFilterKosBathroomTypesKo._(TranslationsKo root) : this._root = root, super.internal(root);

	final TranslationsKo _root; // ignore: unused_field

	// Translations
	@override String get inRoom => '실내 욕실';
	@override String get outRoom => '실외 욕실';
}

/// The flat map containing all translations for locale <ko>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsKo {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'login.title' => '로그인',
			'login.subtitle' => '블링에서 쉽게 사고팔기!',
			'login.emailHint' => '이메일',
			'login.passwordHint' => '비밀번호',
			'login.buttons.login' => '로그인',
			'login.buttons.google' => 'Google로 계속',
			'login.buttons.apple' => 'Apple로 계속',
			'login.links.findPassword' => '비밀번호 찾기',
			'login.links.askForAccount' => '계정이 없나요?',
			'login.links.signUp' => '회원가입',
			'login.alerts.invalidEmail' => '잘못된 이메일 형식입니다.',
			'login.alerts.userNotFound' => '사용자를 찾을 수 없거나 비밀번호가 틀렸습니다.',
			'login.alerts.wrongPassword' => '비밀번호가 틀렸습니다.',
			'login.alerts.unknownError' => '오류가 발생했습니다. 다시 시도해 주세요.',
			'main.appBar.locationNotSet' => '위치 미설정',
			'main.appBar.locationError' => '위치 오류',
			'main.appBar.locationLoading' => '불러오는 중...',
			'main.tabs.newFeed' => '새 글',
			'main.tabs.localNews' => '동네 소식',
			'main.tabs.marketplace' => '중고거래',
			'main.tabs.findFriends' => '친구찾기',
			'main.tabs.clubs' => '모임',
			'main.tabs.jobs' => '일자리',
			'main.tabs.localStores' => '동네가게',
			'main.tabs.auction' => '경매',
			'main.tabs.pom' => 'POM',
			'main.tabs.lostAndFound' => '분실·습득',
			'main.tabs.realEstate' => '부동산',
			'main.bottomNav.home' => '홈',
			'main.bottomNav.board' => '동네게시판',
			'main.bottomNav.search' => '검색',
			'main.bottomNav.chat' => '채팅',
			'main.bottomNav.myBling' => '내 블링',
			'main.errors.loginRequired' => '로그인이 필요합니다.',
			'main.errors.userNotFound' => '사용자를 찾을 수 없습니다.',
			'main.errors.unknown' => '오류가 발생했습니다.',
			'main.myTown' => '내 동네',
			'main.mapView.showMap' => '지도 보기',
			'main.mapView.showList' => '목록 보기',
			'main.search.placeholder' => '검색',
			'main.search.chipPlaceholder' => '이웃, 소식, 중고거래, 일자리 검색…',
			'main.search.hint.globalSheet' => '{}에서 검색',
			'main.search.hint.localNews' => '제목·내용·태그 검색',
			'main.search.hint.jobs' => '직업·회사·도움요청 검색',
			'main.search.hint.lostAndFound' => '분실·습득물 검색',
			'main.search.hint.marketplace' => '판매 상품 검색',
			'main.search.hint.localStores' => '가게·서비스 검색',
			'main.search.hint.findFriends' => '닉네임·관심사 검색',
			'main.search.hint.clubs' => '모임·관심사·위치 검색',
			'main.search.hint.realEstate' => '매물·지역·가격 검색',
			'main.search.hint.auction' => '경매 물품·브랜드 검색',
			'main.search.hint.pom' => 'POM·태그·사용자 검색',
			'search.resultsTitle' => '\'{keyword}\' 검색 결과',
			'search.empty.message' => '\'{keyword}\' 검색 결과가 없습니다.',
			'search.empty.checkSpelling' => '철자를 확인하거나 다른 검색어로 시도해 주세요.',
			'search.empty.expandToNational' => '전국 검색',
			'search.prompt' => '검색어 입력',
			'search.sheet.localNews' => '동네 소식 검색',
			'search.sheet.localNewsDesc' => '제목·내용·태그로 검색',
			'search.sheet.jobs' => '일자리 검색',
			'search.sheet.jobsDesc' => '직무·회사·태그로 검색',
			'search.sheet.lostAndFound' => '분실·습득 검색',
			'search.sheet.lostAndFoundDesc' => '물건 이름·장소로 검색',
			'search.sheet.marketplace' => '중고거래 검색',
			'search.sheet.marketplaceDesc' => '상품명·카테고리·태그 검색',
			'search.sheet.localStores' => '동네 가게 검색',
			'search.sheet.localStoresDesc' => '가게명·업종·키워드 검색',
			'search.sheet.clubs' => '모임 검색',
			'search.sheet.clubsDesc' => '모임명·관심사 검색',
			'search.sheet.findFriends' => '친구찾기 검색',
			'search.sheet.findFriendsDesc' => '닉네임·관심사 검색',
			'search.sheet.realEstate' => '부동산 검색',
			'search.sheet.realEstateDesc' => '제목·지역·태그 검색',
			'search.sheet.auction' => '경매 검색',
			'search.sheet.auctionDesc' => '상품명·태그 검색',
			'search.sheet.pom' => 'POM 검색',
			'search.sheet.pomDesc' => '제목·해시태그 검색',
			'search.sheet.comingSoon' => '준비 중',
			'search.results' => '결과',
			'drawer.editProfile' => '프로필 수정',
			'drawer.bookmarks' => '북마크',
			'drawer.uploadSampleData' => '샘플 데이터 업로드',
			'drawer.logout' => '로그아웃',
			'drawer.trustDashboard.title' => '신뢰 인증 현황',
			'drawer.trustDashboard.kelurahanAuth' => '동네 인증(케루라한)',
			'drawer.trustDashboard.rtRwAuth' => '상세 주소 인증(RT/RW)',
			'drawer.trustDashboard.phoneAuth' => '전화 인증',
			'drawer.trustDashboard.profileComplete' => '프로필 완료',
			'drawer.trustDashboard.feedThanks' => '피드 감사',
			'drawer.trustDashboard.marketThanks' => '중고거래 감사',
			'drawer.trustDashboard.reports' => '신고',
			'drawer.trustDashboard.breakdownButton' => '자세히',
			'drawer.trustDashboard.breakdownModalTitle' => '신뢰 점수 내역',
			'drawer.trustDashboard.breakdownClose' => '확인',
			'drawer.trustDashboard.breakdown.kelurahanAuth' => '+50',
			'drawer.trustDashboard.breakdown.rtRwAuth' => '+50',
			'drawer.trustDashboard.breakdown.phoneAuth' => '+100',
			'drawer.trustDashboard.breakdown.profileComplete' => '+50',
			'drawer.trustDashboard.breakdown.feedThanks' => '1회당 +10',
			'drawer.trustDashboard.breakdown.marketThanks' => '1회당 +20',
			'drawer.trustDashboard.breakdown.reports' => '1회당 -50',
			'drawer.runDataFix' => '데이터 수정 실행',
			'marketplace.error' => '오류: {error}',
			'marketplace.empty' => '등록된 상품이 없습니다.\n+ 버튼을 눌러 첫 상품을 올려보세요!',
			'marketplace.registration.title' => '새 상품 등록',
			'marketplace.registration.done' => '저장',
			'marketplace.registration.titleHint' => '상품명',
			'marketplace.registration.priceHint' => '가격 (Rp)',
			'marketplace.registration.negotiable' => '가격 제안 허용',
			'marketplace.registration.addressHint' => '동네',
			'marketplace.registration.addressDetailHint' => '만날 장소',
			'marketplace.registration.descriptionHint' => '상세 설명',
			'marketplace.registration.success' => '등록 완료!',
			'marketplace.registration.tagsHint' => '태그 추가 (스페이스로 확정)',
			'marketplace.registration.fail' => '실패',
			'marketplace.edit.title' => '게시글 수정',
			'marketplace.edit.done' => '수정 완료',
			'marketplace.edit.titleHint' => '상품명 수정',
			'marketplace.edit.addressHint' => '위치 수정',
			'marketplace.edit.priceHint' => '가격 수정 (Rp)',
			'marketplace.edit.negotiable' => '가격 제안 수정',
			'marketplace.edit.descriptionHint' => '설명 수정',
			'marketplace.edit.tagsHint' => '태그 추가 (스페이스로 확정)',
			'marketplace.edit.success' => '상품이 성공적으로 수정되었습니다.',
			'marketplace.edit.fail' => '상품 수정에 실패했습니다: {error}',
			'marketplace.edit.resetLocation' => '위치 초기화',
			'marketplace.edit.save' => '변경사항 저장',
			'marketplace.detail.makeOffer' => '가격 제안하기',
			'marketplace.detail.fixedPrice' => '고정가',
			'marketplace.detail.description' => '상품 설명',
			'marketplace.detail.sellerInfo' => '판매자 정보',
			'marketplace.detail.chat' => '채팅',
			'marketplace.detail.favorite' => '관심 상품',
			'marketplace.detail.unfavorite' => '관심 해제',
			'marketplace.detail.share' => '공유',
			'marketplace.detail.edit' => '수정',
			'marketplace.detail.delete' => '삭제',
			'marketplace.detail.category' => '카테고리',
			'marketplace.detail.categoryError' => '카테고리: -',
			'marketplace.detail.categoryNone' => '카테고리 없음',
			'marketplace.detail.views' => '조회',
			'marketplace.detail.likes' => '좋아요',
			'marketplace.detail.chats' => '채팅',
			'marketplace.detail.noSeller' => '판매자 정보를 찾을 수 없습니다.',
			'marketplace.detail.noLocation' => '위치 정보를 찾을 수 없습니다.',
			'marketplace.detail.seller' => '판매자',
			'marketplace.detail.dealLocation' => '거래 장소',
			'marketplace.dialog.deleteTitle' => '게시글 삭제',
			'marketplace.dialog.deleteContent' => '이 게시글을 정말 삭제하시겠습니까? 삭제 후에는 되돌릴 수 없습니다.',
			'marketplace.dialog.cancel' => '취소',
			'marketplace.dialog.deleteConfirm' => '삭제',
			'marketplace.dialog.deleteSuccess' => '게시글이 삭제되었습니다.',
			'marketplace.dialog.close' => '닫기',
			'marketplace.errors.deleteError' => '게시글 삭제에 실패했습니다: {error}',
			'marketplace.errors.requiredField' => '필수 입력 항목입니다.',
			'marketplace.errors.noPhoto' => '사진을 최소 1장 이상 추가해 주세요.',
			'marketplace.errors.noCategory' => '카테고리를 선택해 주세요.',
			'marketplace.errors.loginRequired' => '로그인이 필요합니다.',
			'marketplace.errors.userNotFound' => '사용자 정보를 찾을 수 없습니다.',
			'marketplace.condition.label' => '상품 상태',
			'marketplace.condition.kNew' => '새 상품',
			'marketplace.condition.used' => '중고',
			'marketplace.reservation.title' => '10% 예약금 결제',
			'marketplace.reservation.content' => 'AI 인증 상품을 예약하려면 {amount}의 10% 예약금을 먼저 결제해야 합니다. 현장 검증 후 거래가 취소되면 예약금은 환불됩니다.',
			'marketplace.reservation.confirm' => '결제 후 예약하기',
			'marketplace.reservation.button' => 'AI 보증으로 예약하기',
			'marketplace.reservation.success' => '예약이 완료되었습니다. 판매자와 일정을 조율해 주세요.',
			'marketplace.status.reserved' => '예약됨',
			'marketplace.status.sold' => '판매 완료',
			'marketplace.ai.cancelConfirm' => 'AI 인증 취소',
			'marketplace.ai.cancelLimit' => 'AI 인증은 상품당 한 번만 취소할 수 있습니다. 다시 요청할 경우 비용이 발생할 수 있습니다.',
			'marketplace.ai.cancelAckCharge' => '비용이 발생할 수 있음을 이해했습니다.',
			'marketplace.ai.cancelSuccess' => 'AI 인증이 취소되었습니다. 이제 일반 상품으로 전환되었습니다.',
			'marketplace.ai.cancelError' => 'AI 인증 취소 중 오류가 발생했습니다: {0}',
			'marketplace.takeover.button' => '현장 수령 및 검증',
			'marketplace.takeover.title' => 'AI 현장 검증',
			'marketplace.takeover.guide.title' => 'AI 현장 유사도 검증',
			'marketplace.takeover.guide.subtitle' => '원래 AI 보고서와 실제 물건이 같은지 확인합니다. 물건의 핵심 특징이 잘 보이도록 3장 이상 촬영해 주세요.',
			'marketplace.takeover.photoTitle' => '현장에서 사진 찍기',
			'marketplace.takeover.buttonVerify' => 'AI 유사도 검증 시작',
			'marketplace.takeover.errors.noPhoto' => '현장 사진이 최소 1장은 있어야 검증을 진행할 수 있습니다.',
			'marketplace.takeover.dialog.matchTitle' => 'AI 검증 성공',
			'marketplace.takeover.dialog.noMatchTitle' => 'AI 검증 실패',
			'marketplace.takeover.dialog.finalize' => '최종 인수 확정',
			'marketplace.takeover.dialog.cancelDeal' => '거래 취소(환불 요청)',
			'marketplace.takeover.success.finalized' => '거래가 정상적으로 완료되었습니다.',
			'marketplace.takeover.success.cancelled' => '거래가 취소되었습니다. 예약금은 환불됩니다.',
			'marketplace.aiBadge' => 'AI 인증',
			'marketplace.setLocationPrompt' => '동네를 먼저 설정하면 중고거래 상품을 볼 수 있어요!',
			'aiFlow.common.error' => '오류가 발생했습니다: {error}',
			'aiFlow.common.addPhoto' => '사진 추가',
			'aiFlow.common.skip' => '건너뛰기',
			'aiFlow.common.addedPhoto' => '사진이 추가되었습니다: {}',
			'aiFlow.common.skipped' => '건너뜀',
			'aiFlow.cta.title' => '🤖 AI 인증으로 신뢰도 높이기 (선택)',
			'aiFlow.cta.subtitle' => 'AI 인증 뱃지를 얻으면 구매자 신뢰가 올라가고 더 빨리 팔릴 수 있어요. 시작하기 전에 상품 정보를 모두 입력해 주세요.',
			'aiFlow.cta.startButton' => 'AI 인증 시작하기',
			'aiFlow.cta.missingRequiredFields' => '상품명, 카테고리, 최소 1장의 이미지를 먼저 입력해 주세요.',
			'aiFlow.categorySelection.title' => 'AI 인증: 카테고리 선택',
			'aiFlow.categorySelection.error' => '카테고리를 불러오지 못했습니다.',
			'aiFlow.categorySelection.noCategories' => 'AI 인증 가능한 카테고리가 없습니다.',
			'aiFlow.galleryUpload.title' => 'AI 인증: 사진 선택',
			'aiFlow.galleryUpload.guide' => 'AI 인증을 위해 최소 {count}장의 사진을 올려 주세요.',
			'aiFlow.galleryUpload.minPhotoError' => '사진을 최소 {count}장 선택해야 합니다.',
			'aiFlow.galleryUpload.nextButton' => 'AI 분석 요청',
			'aiFlow.prediction.title' => 'AI 분석 결과',
			'aiFlow.prediction.guide' => 'AI가 예측한 상품명입니다.',
			'aiFlow.prediction.editLabel' => '상품명 수정',
			'aiFlow.prediction.editButton' => '직접 수정',
			'aiFlow.prediction.saveButton' => '변경 저장',
			'aiFlow.prediction.noName' => '상품명이 없습니다.',
			'aiFlow.prediction.error' => '상품을 인식하지 못했습니다. 다시 시도해 주세요.',
			'aiFlow.prediction.authError' => '사용자 인증 정보가 없습니다. 분석을 시작할 수 없습니다.',
			'aiFlow.prediction.question' => '이 상품명이 맞나요?',
			'aiFlow.prediction.confirmButton' => '네, 맞아요',
			'aiFlow.prediction.rejectButton' => '아니요, 다시 수정',
			'aiFlow.prediction.analysisError' => '분석 중 오류가 발생했습니다.',
			'aiFlow.prediction.retryButton' => '다시 시도',
			'aiFlow.prediction.backButton' => '뒤로',
			'aiFlow.guidedCamera.title' => 'AI 가이드: 부족한 증거 사진',
			'aiFlow.guidedCamera.guide' => '신뢰도를 높이기 위해 아래 항목에 맞는 추가 사진을 찍어 주세요.',
			'aiFlow.guidedCamera.locationMismatchError' => '사진 위치가 현재 위치와 다릅니다. 같은 장소에서 다시 촬영해 주세요.',
			'aiFlow.guidedCamera.locationPermissionError' => '위치 권한이 거부되었습니다. 설정에서 위치 권한을 허용해 주세요.',
			'aiFlow.guidedCamera.noLocationDataError' => '사진에 위치 정보가 없습니다. 카메라 설정에서 위치 태그를 켜 주세요.',
			'aiFlow.guidedCamera.nextButton' => '최종 보고서 생성',
			'aiFlow.finalReport.title' => 'AI 인증 보고서',
			'aiFlow.finalReport.guide' => 'AI가 작성한 초안 기반으로 상품 정보를 정리했습니다. 내용을 수정한 뒤 등록을 마무리해 주세요.',
			'aiFlow.finalReport.loading' => 'AI가 최종 보고서를 생성하는 중입니다...',
			'aiFlow.finalReport.error' => '보고서 생성에 실패했습니다.',
			'aiFlow.finalReport.success' => '최종 보고서가 생성되었습니다.',
			'aiFlow.finalReport.submitButton' => '판매 등록 완료',
			'aiFlow.finalReport.suggestedPrice' => 'AI 추천 가격 ({})',
			'aiFlow.finalReport.summary' => '인증 요약',
			'aiFlow.finalReport.buyerNotes' => '구매자 안내 (AI)',
			'aiFlow.finalReport.keySpecs' => '핵심 스펙',
			'aiFlow.finalReport.condition' => '상태 점검',
			'aiFlow.finalReport.includedItems' => '구성품(쉼표로 구분)',
			'aiFlow.finalReport.finalDescription' => '최종 설명',
			'aiFlow.finalReport.applySuggestions' => 'AI 제안을 설명에 반영',
			'aiFlow.finalReport.includedItemsLabel' => '구성품',
			'aiFlow.finalReport.buyerNotesLabel' => '구매자 안내',
			'aiFlow.finalReport.skippedItems' => '건너뛴 증거 항목',
			'aiFlow.finalReport.fail' => '최종 보고서 생성에 실패했습니다: {error}',
			'aiFlow.evidence.allShotsRequired' => '모든 추천 샷이 필요합니다.',
			'aiFlow.evidence.title' => '증거 사진',
			'aiFlow.evidence.submitButton' => '증거 제출',
			'aiFlow.error.reportGeneration' => 'AI 보고서 생성에 실패했습니다: {error}',
			'registrationFlow.title' => '판매할 상품 유형 선택',
			'registrationFlow.newItemTitle' => '새 상품·일반 중고 등록',
			'registrationFlow.newItemDesc' => '안 쓰는 새 상품과 일반 중고 상품을 빠르게 등록해요.',
			'registrationFlow.usedItemTitle' => '중고 상품 (AI 인증)',
			'registrationFlow.usedItemDesc' => 'AI가 상품을 분석해 신뢰를 높이고 판매를 도와줍니다.',
			'myBling.title' => '나의 블링',
			'myBling.editProfile' => '프로필 편집',
			'myBling.settings' => '설정',
			'myBling.posts' => '게시글',
			'myBling.followers' => '팔로워',
			'myBling.neighbors' => '이웃',
			'myBling.friends' => '친구',
			'myBling.stats.posts' => '게시글',
			'myBling.stats.followers' => '팔로워',
			'myBling.stats.neighbors' => '이웃',
			'myBling.stats.friends' => '친구',
			'myBling.tabs.posts' => '내 게시글',
			'myBling.tabs.products' => '내 상품',
			'myBling.tabs.bookmarks' => '북마크',
			'myBling.tabs.friends' => '친구',
			'myBling.friendRequests' => '받은 친구 요청',
			'myBling.sentFriendRequests' => '보낸 친구 요청',
			'profileView.title' => '프로필',
			'profileView.tabs.posts' => '게시글',
			'profileView.tabs.interests' => '관심사',
			'profileView.noPosts' => '아직 게시글이 없습니다.',
			'profileView.noInterests' => '등록된 관심사가 없습니다.',
			'settings.title' => '설정',
			'settings.accountPrivacy' => '계정 및 개인정보',
			'settings.notifications.loadError' => '알림 설정을 불러오지 못했습니다.',
			'settings.notifications.saveSuccess' => '알림 설정이 저장되었습니다.',
			'settings.notifications.saveError' => '알림 설정 저장에 실패했습니다.',
			'settings.notifications.scopeTitle' => '알림 범위',
			'settings.notifications.scopeDescription' => '알림을 받을 범위를 선택하세요 (내 동네만, 인근 지역 등).',
			'settings.notifications.scopeLabel' => '알림 범위',
			'settings.notifications.tagsTitle' => '알림 주제',
			'settings.notifications.tagsDescription' => '어떤 주제의 알림을 받을지 선택하세요 (소식, 일자리, 중고거래 등).',
			'settings.appInfo' => '앱 정보',
			'friendRequests.title' => '받은 친구 요청',
			'friendRequests.noRequests' => '받은 친구 요청이 없습니다.',
			'friendRequests.acceptSuccess' => '친구 요청을 수락했습니다.',
			'friendRequests.rejectSuccess' => '친구 요청을 거절했습니다.',
			'friendRequests.error' => '오류가 발생했습니다: {error}',
			'friendRequests.tooltip.accept' => '수락',
			'friendRequests.tooltip.reject' => '거절',
			'friendRequests.defaultChatMessage' => '이제 친구가 되었어요! 대화를 시작해 보세요.',
			'sentFriendRequests.title' => '보낸 친구 요청',
			'sentFriendRequests.noRequests' => '보낸 친구 요청이 없습니다.',
			'sentFriendRequests.statusLabel' => '상태: {status}',
			'sentFriendRequests.status.pending' => '대기 중',
			'sentFriendRequests.status.accepted' => '수락됨',
			'sentFriendRequests.status.rejected' => '거절됨',
			'blockedUsers.title' => '차단한 사용자',
			'blockedUsers.noBlockedUsers' => '아직 아무도 차단하지 않았습니다.',
			'blockedUsers.unblock' => '차단 해제',
			'blockedUsers.unblockDialog.title' => '{nickname} 님의 차단을 해제할까요?',
			'blockedUsers.unblockDialog.content' => '차단을 해제하면 이 사용자가 다시 친구찾기 목록에 나타날 수 있습니다.',
			'blockedUsers.unblockSuccess' => '{nickname} 님의 차단을 해제했습니다.',
			'blockedUsers.unblockFailure' => '차단 해제에 실패했습니다: {error}',
			'blockedUsers.unknownUser' => '알 수 없는 사용자',
			'blockedUsers.empty' => '차단한 사용자가 없습니다.',
			'rejectedUsers.title' => '거절한 사용자 관리',
			'rejectedUsers.noRejectedUsers' => '거절한 친구 요청이 없습니다.',
			'rejectedUsers.unreject' => '거절 취소',
			'rejectedUsers.unrejectDialog.title' => '{nickname} 님에 대한 거절을 취소할까요?',
			'rejectedUsers.unrejectDialog.content' => '거절을 취소하면 상대방의 친구찾기 목록에 다시 나타날 수 있습니다.',
			'rejectedUsers.unrejectSuccess' => '{nickname} 님에 대한 거절 취소가 완료되었습니다.',
			'rejectedUsers.unrejectFailure' => '거절 취소에 실패했습니다: {error}',
			'prompt.title' => '블링에 오신 것을 환영합니다!',
			'prompt.subtitle' => '내 주변 소식과 중고거래를 보려면 먼저 동네를 설정해 주세요.',
			'prompt.button' => '내 동네 설정하기',
			'location.title' => '동네 설정',
			'location.searchHint' => '동네 이름으로 검색 (예: Serpong)',
			'location.gpsButton' => '현재 위치 사용',
			'location.success' => '동네가 설정되었습니다.',
			'location.error' => '동네 설정에 실패했습니다: {error}',
			'location.empty' => '동네 이름을 입력해 주세요.',
			'location.permissionDenied' => '내 동네를 찾으려면 위치 권한이 필요합니다.',
			'location.rtLabel' => 'RT',
			'location.rwLabel' => 'RW',
			'location.rtHint' => '예: 003',
			'location.rwHint' => '예: 007',
			'location.rtRequired' => 'RT를 입력해 주세요.',
			'location.rwRequired' => 'RW를 입력해 주세요.',
			'location.rtRwInfo' => 'RT/RW 정보는 공개되지 않으며, 신뢰도 및 동네 기능 향상을 위해서만 사용됩니다.',
			'location.saveThisLocation' => '이 위치 저장',
			'location.manualSelect' => '직접 선택',
			'location.refreshFromGps' => 'GPS로 다시 불러오기',
			'profileEdit.title' => '프로필 설정',
			'profileEdit.nicknameHint' => '닉네임',
			'profileEdit.phoneHint' => '전화번호',
			'profileEdit.bioHint' => '소개글',
			'profileEdit.locationTitle' => '위치',
			'profileEdit.changeLocation' => '변경',
			'profileEdit.locationNotSet' => '미설정',
			'profileEdit.interests.title' => '관심사',
			'profileEdit.interests.hint' => '여러 개를 입력하려면 쉼표와 엔터를 사용하세요',
			'profileEdit.privacy.title' => '개인정보 설정',
			'profileEdit.privacy.showLocation' => '지도에 내 위치 표시',
			'profileEdit.privacy.allowRequests' => '친구 요청 허용',
			'profileEdit.saveButton' => '변경 사항 저장',
			'profileEdit.successMessage' => '프로필이 성공적으로 업데이트되었습니다.',
			'profileEdit.errors.noUser' => '로그인된 사용자가 없습니다.',
			'profileEdit.errors.updateFailed' => '프로필 업데이트에 실패했습니다: {error}',
			'mainFeed.error' => '오류가 발생했습니다: {error}',
			'mainFeed.empty' => '새 게시글이 없습니다.',
			'postCard.locationNotSet' => '위치 미설정',
			'postCard.location' => '위치',
			'postCard.authorNotFound' => '작성자를 찾을 수 없습니다.',
			'time.now' => '방금 전',
			'time.minutesAgo' => '{minutes}분 전',
			'time.hoursAgo' => '{hours}시간 전',
			'time.daysAgo' => '{days}일 전',
			'time.dateFormat' => 'yy.MM.dd',
			'time.dateFormatLong' => 'MMM d',
			'productCard.currency' => '\$',
			'localNewsFeed.setLocationPrompt' => '동네 소식을 보려면 동네를 설정해 주세요!',
			'localNewsFeed.allCategory' => '전체',
			'localNewsFeed.empty' => '표시할 게시글이 없습니다.',
			'localNewsFeed.error' => '오류가 발생했습니다: {error}',
			'categories.post.jalanPerbaikin.search.hint' => 'POM, 태그, 사용자 검색',
			'categories.post.jalanPerbaikin.name' => '도로 보수',
			'categories.post.dailyLife.name' => '일상/질문',
			'categories.post.dailyLife.description' => '일상을 공유하거나 궁금한 점을 물어보세요.',
			'categories.post.helpShare.name' => '도움/나눔',
			'categories.post.helpShare.description' => '도움이 필요하거나 나누고 싶은 것이 있을 때 올려 보세요.',
			'categories.post.incidentReport.name' => '사건/사고',
			'categories.post.incidentReport.description' => '동네에서 일어난 사건·사고 소식을 공유하세요.',
			'categories.post.localNews.name' => '동네 소식',
			'categories.post.localNews.description' => '우리 동네 뉴스와 정보를 공유하세요.',
			'categories.post.november.name' => '11월',
			'categories.post.rain.name' => '비/날씨',
			'categories.post.dailyQuestion.name' => '질문 있어요',
			'categories.post.dailyQuestion.description' => '이웃에게 무엇이든 물어보세요.',
			'categories.post.storePromo.name' => '가게 프로모션',
			'categories.post.storePromo.description' => '내 가게 할인이나 이벤트를 홍보하세요.',
			'categories.post.etc.name' => '기타',
			'categories.post.etc.description' => '그 외 다양한 이야기를 자유롭게 나누세요.',
			'categories.auction.all' => '전체',
			'categories.auction.collectibles.name' => '컬렉터블',
			'categories.auction.collectibles.description' => '피규어, 카드, 장난감 등 수집품.',
			'categories.auction.digital.name' => '디지털',
			'categories.auction.digital.description' => '디지털 상품 및 자산.',
			'categories.auction.fashion.name' => '패션',
			'categories.auction.fashion.description' => '의류, 액세서리, 뷰티 제품.',
			'categories.auction.vintage.name' => '빈티지',
			'categories.auction.vintage.description' => '레트로·클래식 아이템.',
			'categories.auction.artCraft.name' => '아트 & 공예',
			'categories.auction.artCraft.description' => '작품, 수공예품 등.',
			'categories.auction.etc.name' => '기타',
			'categories.auction.etc.description' => '그 외 모든 경매 상품.',
			'localNewsCreate.appBarTitle' => '새 글 만들기',
			'localNewsCreate.title' => '새 글 만들기',
			'localNewsCreate.form.categoryLabel' => '카테고리',
			'localNewsCreate.form.titleLabel' => '제목',
			'localNewsCreate.form.contentLabel' => '내용 입력',
			'localNewsCreate.form.tagsLabel' => '태그',
			'localNewsCreate.form.tagsHint' => '태그를 추가하세요 (스페이스를 눌러 확정)',
			'localNewsCreate.form.recommendedTags' => '추천 태그',
			'localNewsCreate.labels.title' => '제목',
			'localNewsCreate.labels.body' => '내용',
			'localNewsCreate.labels.tags' => '태그',
			'localNewsCreate.labels.guidedTitle' => '추가 정보 (선택)',
			'localNewsCreate.labels.eventLocation' => '이벤트/사건 위치',
			'localNewsCreate.hints.body' => '동네 소식을 공유하거나 궁금한 점을 남겨보세요...',
			'localNewsCreate.hints.tagSelection' => '(태그 1~3개 선택)',
			'localNewsCreate.hints.eventLocation' => '예: Jl. Sudirman 123',
			'localNewsCreate.validation.bodyRequired' => '내용을 입력해 주세요.',
			'localNewsCreate.validation.tagRequired' => '태그를 최소 1개 선택해 주세요.',
			'localNewsCreate.validation.tagMaxLimit' => '태그는 최대 3개까지 선택할 수 있습니다.',
			'localNewsCreate.validation.imageMaxLimit' => '이미지는 최대 5장까지 첨부할 수 있습니다.',
			'localNewsCreate.validation.titleRequired' => '제목을 입력해 주세요.',
			'localNewsCreate.buttons.addImage' => '이미지 추가',
			'localNewsCreate.buttons.submit' => '등록',
			'localNewsCreate.alerts.contentRequired' => '내용을 입력해 주세요.',
			'localNewsCreate.alerts.categoryRequired' => '카테고리를 선택해 주세요.',
			'localNewsCreate.alerts.success' => '게시글이 등록되었습니다.',
			'localNewsCreate.alerts.failure' => '업로드에 실패했습니다: {error}',
			'localNewsCreate.alerts.loginRequired' => '게시글을 작성하려면 로그인이 필요합니다.',
			'localNewsCreate.alerts.userNotFound' => '사용자 정보를 찾을 수 없습니다.',
			'localNewsCreate.success' => '게시글이 등록되었습니다.',
			'localNewsCreate.fail' => '게시글 등록에 실패했습니다: {error}',
			'localNewsDetail.appBarTitle' => '게시글',
			'localNewsDetail.menu.edit' => '수정',
			'localNewsDetail.menu.report' => '신고',
			'localNewsDetail.menu.share' => '공유',
			'localNewsDetail.stats.views' => '조회수',
			'localNewsDetail.stats.comments' => '댓글',
			'localNewsDetail.stats.likes' => '좋아요',
			'localNewsDetail.stats.thanks' => '고마워요',
			'localNewsDetail.buttons.comment' => '댓글 달기',
			'localNewsDetail.confirmDelete' => '이 게시글을 삭제하시겠습니까?',
			'localNewsDetail.deleted' => '게시글이 삭제되었습니다.',
			'localNewsEdit.appBarTitle' => '게시글 수정',
			'localNewsEdit.buttons.submit' => '수정 완료',
			'localNewsEdit.alerts.success' => '게시글이 수정되었습니다.',
			'localNewsEdit.alerts.failure' => '수정에 실패했습니다: {error}',
			'commentInputField.secretCommentLabel' => '비밀',
			'commentInputField.hintText' => '댓글을 입력하세요...',
			'commentInputField.replyHintText' => '{nickname}님께 답글 쓰는 중...',
			'commentInputField.button.send' => '보내기',
			'commentListView.empty' => '아직 댓글이 없습니다. 첫 댓글을 남겨보세요!',
			'commentListView.reply' => '답글',
			'commentListView.delete' => '삭제',
			'commentListView.deleted' => '[삭제된 댓글입니다]',
			'commentListView.secret' => '이 댓글은 작성자와 글 작성자만 볼 수 있는 비밀 댓글입니다.',
			'common.cancel' => '취소',
			'common.confirm' => '확인',
			'common.delete' => '삭제',
			'common.done' => '완료',
			'common.clear' => '지우기',
			'common.report' => '신고',
			'common.moreOptions' => '더 보기',
			'common.viewAll' => '전체 보기',
			'common.kNew' => '새 글',
			'common.updated' => '업데이트됨',
			'common.comments' => '댓글',
			'common.sponsored' => '스폰서',
			'common.filter' => '필터',
			'common.reset' => '초기화',
			'common.apply' => '적용',
			'common.verified' => '인증됨',
			'common.bookmark' => '북마크',
			'common.sort.kDefault' => '기본 순',
			'common.sort.distance' => '거리순',
			'common.sort.popular' => '인기순',
			'common.error' => '오류가 발생했습니다.',
			'common.shareError' => '공유에 실패했습니다. 다시 시도해 주세요.',
			'common.edit' => '수정',
			'common.submit' => '등록',
			'common.loginRequired' => '로그인이 필요합니다.',
			'common.unknownUser' => '알 수 없는 사용자입니다.',
			'reportDialog.title' => '게시글 신고',
			'reportDialog.titleComment' => '댓글 신고',
			'reportDialog.titleReply' => '답글 신고',
			'reportDialog.cannotReportSelfComment' => '내가 쓴 댓글은 신고할 수 없습니다.',
			'reportDialog.cannotReportSelfReply' => '내가 쓴 답글은 신고할 수 없습니다.',
			'reportDialog.success' => '신고가 접수되었습니다. 감사합니다.',
			'reportDialog.fail' => '신고 접수에 실패했습니다: {error}',
			'reportDialog.cannotReportSelf' => '내가 쓴 게시글은 신고할 수 없습니다.',
			'replyDelete.fail' => '답글 삭제에 실패했습니다: {error}',
			'reportReasons.spam' => '스팸 또는 오해의 소지가 있음',
			'reportReasons.abuse' => '괴롭힘 또는 혐오 발언',
			'reportReasons.inappropriate' => '성적으로 부적절함',
			'reportReasons.illegal' => '불법적인 내용',
			'reportReasons.etc' => '기타',
			'deleteConfirm.title' => '댓글 삭제',
			'deleteConfirm.content' => '이 댓글을 삭제하시겠습니까?',
			'deleteConfirm.failure' => '댓글 삭제에 실패했습니다: {error}',
			'replyInputField.hintText' => '답글을 입력하세요',
			'replyInputField.button.send' => '보내기',
			'replyInputField.failure' => '답글 추가에 실패했습니다: {error}',
			'chatList.appBarTitle' => '채팅',
			'chatList.empty' => '아직 대화가 없습니다.',
			'chatRoom.startConversation' => '대화를 시작해 보세요',
			'chatRoom.icebreaker1' => '안녕하세요! 👋',
			'chatRoom.icebreaker2' => '주말에는 보통 뭐 하세요?',
			'chatRoom.icebreaker3' => '근처에 좋아하는 장소가 있나요?',
			'chatRoom.mediaBlocked' => '안전상의 이유로, 24시간 동안 미디어 전송이 제한됩니다.',
			'chatRoom.imageMessage' => '이미지',
			'chatRoom.linkHidden' => '보호 모드: 링크 숨김',
			'chatRoom.contactHidden' => '보호 모드: 연락처 숨김',
			'jobs.setLocationPrompt' => '일자리 글을 보려면 위치를 설정해 주세요!',
			'jobs.screen.empty' => '이 근처에 등록된 일자리 글이 없습니다.',
			'jobs.screen.createTooltip' => '일자리 등록',
			_ => null,
		} ?? switch (path) {
			'jobs.tabs.all' => '전체',
			'jobs.tabs.quickGig' => '단기 심부름',
			'jobs.tabs.regular' => '알바/정규직',
			'jobs.selectType.title' => '일자리 유형 선택',
			'jobs.selectType.regularTitle' => '파트타임 / 정규직 공고',
			'jobs.selectType.regularDesc' => '카페, 식당, 사무실 등 일반 근무',
			'jobs.selectType.quickGigTitle' => '단기 심부름 / 간단 도움',
			'jobs.selectType.quickGigDesc' => '오토바이 배달, 이사 도움, 청소 등',
			'jobs.form.title' => '일자리 등록',
			'jobs.form.titleHint' => '공고 제목',
			'jobs.form.descriptionPositionHint' => '모집하는 포지션을 설명해 주세요',
			'jobs.form.categoryHint' => '카테고리',
			'jobs.form.categorySelectHint' => '카테고리를 선택해 주세요',
			'jobs.form.categoryValidator' => '카테고리를 선택해 주세요.',
			'jobs.form.locationHint' => '근무지',
			'jobs.form.submit' => '일자리 등록',
			'jobs.form.titleLabel' => '제목',
			'jobs.form.titleValidator' => '제목을 입력해 주세요.',
			'jobs.form.titleRegular' => '알바/정규직 공고 등록',
			'jobs.form.titleQuickGig' => '단기 심부름 공고 등록',
			'jobs.form.validationError' => '필수 항목을 모두 입력해 주세요.',
			'jobs.form.saveSuccess' => '일자리 공고가 저장되었습니다.',
			'jobs.form.saveError' => '일자리 공고 저장에 실패했습니다: {error}',
			'jobs.form.categoryLabel' => '카테고리',
			'jobs.form.titleHintQuickGig' => '예: 오토바이 서류 배달 (ASAP)',
			'jobs.form.salaryLabel' => '급여 (IDR)',
			'jobs.form.salaryHint' => '급여 금액을 입력해 주세요',
			'jobs.form.salaryValidator' => '올바른 급여 금액을 입력해 주세요.',
			'jobs.form.totalPayLabel' => '총 지급액 (IDR)',
			'jobs.form.totalPayHint' => '제공할 총 금액을 입력해 주세요',
			'jobs.form.totalPayValidator' => '올바른 금액을 입력해 주세요.',
			'jobs.form.negotiable' => '협의 가능',
			'jobs.form.workPeriodLabel' => '근무 기간',
			'jobs.form.workPeriodHint' => '근무 기간을 선택해 주세요',
			'jobs.form.locationLabel' => '근무지/위치',
			'jobs.form.locationValidator' => '근무지를 입력해 주세요.',
			'jobs.form.imageLabel' => '이미지 (선택, 최대 10장)',
			'jobs.form.descriptionHintQuickGig' => '출발지, 도착지, 요청 사항 등 자세히 적어 주세요.',
			'jobs.form.salaryInfoTitle' => '급여 정보',
			'jobs.form.salaryTypeHint' => '지급 형태',
			'jobs.form.salaryAmountLabel' => '금액 (IDR)',
			'jobs.form.salaryNegotiable' => '급여 협의 가능',
			'jobs.form.workInfoTitle' => '근무 조건',
			'jobs.form.workPeriodTitle' => '근무 기간',
			'jobs.form.workHoursLabel' => '근무 요일/시간',
			'jobs.form.workHoursHint' => '예: 월–금, 09:00–18:00',
			'jobs.form.imageSectionTitle' => '사진 첨부 (선택, 최대 5장)',
			'jobs.form.descriptionLabel' => '상세 설명',
			'jobs.form.descriptionHint' => '예: 주 3일, 오후 5–10시, 시급 협의 가능 등',
			'jobs.form.descriptionValidator' => '상세 설명을 입력해 주세요.',
			'jobs.form.submitSuccess' => '일자리 공고가 등록되었습니다.',
			'jobs.form.submitFail' => '일자리 공고 등록에 실패했습니다: {error}',
			'jobs.form.updateSuccess' => '일자리 공고가 성공적으로 업데이트되었습니다.',
			'jobs.form.editTitle' => '일자리 수정',
			'jobs.form.update' => '업데이트',
			'jobs.categories.restaurant' => '식당',
			'jobs.categories.cafe' => '카페',
			'jobs.categories.retail' => '매장/리테일',
			'jobs.categories.delivery' => '배달',
			'jobs.categories.etc' => '기타',
			'jobs.categories.service' => '서비스',
			'jobs.categories.salesMarketing' => '영업/마케팅',
			'jobs.categories.deliveryLogistics' => '배송/물류',
			'jobs.categories.it' => 'IT/기술',
			'jobs.categories.design' => '디자인',
			'jobs.categories.education' => '교육',
			'jobs.categories.quickGigDelivery' => '오토바이 배달',
			'jobs.categories.quickGigTransport' => '오토바이 태워주기 (오젝)',
			'jobs.categories.quickGigMoving' => '이사/짐 나르기',
			'jobs.categories.quickGigCleaning' => '청소/가사 도움',
			'jobs.categories.quickGigQueuing' => '줄 서주기',
			'jobs.categories.quickGigEtc' => '기타 심부름',
			'jobs.salaryTypes.hourly' => '시급',
			'jobs.salaryTypes.daily' => '일급',
			'jobs.salaryTypes.weekly' => '주급',
			'jobs.salaryTypes.monthly' => '월급',
			'jobs.salaryTypes.total' => '총액',
			'jobs.salaryTypes.perCase' => '건당',
			'jobs.salaryTypes.etc' => '기타',
			'jobs.salaryTypes.yearly' => '연봉',
			'jobs.workPeriods.shortTerm' => '단기',
			'jobs.workPeriods.midTerm' => '중기',
			'jobs.workPeriods.longTerm' => '장기',
			'jobs.workPeriods.oneTime' => '1회성',
			'jobs.workPeriods.k1Week' => '1주',
			'jobs.workPeriods.k1Month' => '1개월',
			'jobs.workPeriods.k3Months' => '3개월',
			'jobs.workPeriods.k6MonthsPlus' => '6개월 이상',
			'jobs.workPeriods.negotiable' => '협의 가능',
			'jobs.workPeriods.etc' => '기타',
			'jobs.detail.infoTitle' => '상세 정보',
			'jobs.detail.apply' => '지원하기',
			'jobs.detail.noAuthor' => '작성자 정보가 없습니다',
			'jobs.detail.chatError' => '채팅을 시작할 수 없습니다: {error}',
			'jobs.card.noLocation' => '위치 정보 없음',
			'jobs.card.minutesAgo' => '분 전',
			'findFriend.title' => '친구 찾기',
			'findFriend.tabs.friends' => '친구',
			'findFriend.tabs.groups' => '그룹',
			'findFriend.tabs.clubs' => '클럽',
			'findFriend.editTitle' => '친구찾기 프로필 수정',
			'findFriend.editProfileTitle' => '프로필 수정',
			'findFriend.save' => '저장',
			'findFriend.profileImagesLabel' => '프로필 이미지 (최대 6장)',
			'findFriend.bioLabel' => '소개',
			'findFriend.bioHint' => '다른 사람들에게 자신을 소개해 주세요.',
			'findFriend.bioValidator' => '소개글을 입력해 주세요.',
			'findFriend.ageLabel' => '나이',
			'findFriend.ageHint' => '나이를 입력해 주세요.',
			'findFriend.genderLabel' => '성별',
			'findFriend.genderMale' => '남성',
			'findFriend.genderFemale' => '여성',
			'findFriend.genderHint' => '성별을 선택해 주세요',
			'findFriend.interestsLabel' => '관심사',
			'findFriend.preferredAgeLabel' => '선호 친구 나이',
			'findFriend.preferredAgeUnit' => '세',
			'findFriend.preferredGenderLabel' => '선호 친구 성별',
			'findFriend.preferredGenderAll' => '모두',
			'findFriend.showProfileLabel' => '프로필 목록에 표시',
			'findFriend.showProfileSubtitle' => '끄면 다른 사람이 나를 찾을 수 없습니다.',
			'findFriend.saveSuccess' => '프로필이 저장되었습니다!',
			'findFriend.saveFailed' => '프로필 저장에 실패했습니다:',
			'findFriend.loginRequired' => '로그인이 필요합니다.',
			'findFriend.noFriendsFound' => '근처에 친구 프로필이 없습니다.',
			'findFriend.promptTitle' => '새로운 친구를 만나려면,\n먼저 프로필을 만들어 주세요!',
			'findFriend.promptButton' => '내 프로필 만들기',
			'findFriend.chatLimitReached' => '오늘 새 대화를 시작할 수 있는 한도({limit})에 도달했습니다.',
			'findFriend.chatChecking' => '확인 중...',
			'findFriend.empty' => '아직 표시할 프로필이 없습니다.',
			'interests.title' => '관심사',
			'interests.limitInfo' => '최대 10개까지 선택할 수 있습니다.',
			'interests.limitReached' => '관심사는 최대 10개까지 선택 가능합니다.',
			'interests.categoryCreative' => '🎨 창의/예술',
			'interests.categorySports' => '🏃 운동 & 활동',
			'interests.categoryFoodDrink' => '🍸 음식 & 음료',
			'interests.categoryEntertainment' => '🍿 엔터테인먼트',
			'interests.categoryGrowth' => '📚 자기계발',
			'interests.categoryLifestyle' => '🌴 라이프스타일',
			'interests.items.drawing' => '그림 그리기',
			'interests.items.instrument' => '악기 연주',
			'interests.items.photography' => '사진',
			'interests.items.writing' => '글쓰기',
			'interests.items.crafting' => '공예',
			'interests.items.gardening' => '가드닝',
			'interests.items.soccer' => '축구/풋살',
			'interests.items.hiking' => '등산',
			'interests.items.camping' => '캠핑',
			'interests.items.running' => '러닝/조깅',
			'interests.items.biking' => '자전거',
			'interests.items.golf' => '골프',
			'interests.items.workout' => '운동/피트니스',
			'interests.items.foodie' => '맛집 탐방',
			'interests.items.cooking' => '요리',
			'interests.items.baking' => '베이킹',
			'interests.items.coffee' => '커피',
			'interests.items.wine' => '와인/주류',
			'interests.items.tea' => '차',
			'interests.items.movies' => '영화/드라마',
			'interests.items.music' => '음악 감상',
			'interests.items.concerts' => '콘서트/페스티벌',
			'interests.items.gaming' => '게임',
			'interests.items.reading' => '독서',
			'interests.items.investing' => '투자',
			'interests.items.language' => '언어 공부',
			'interests.items.coding' => '코딩',
			'interests.items.travel' => '여행',
			'interests.items.pets' => '반려동물',
			'interests.items.volunteering' => '봉사활동',
			'interests.items.minimalism' => '미니멀리즘',
			'friendDetail.request' => '친구 요청',
			'friendDetail.requestSent' => '요청됨',
			'friendDetail.alreadyFriends' => '이미 친구입니다',
			'friendDetail.requestFailed' => '요청에 실패했습니다:',
			'friendDetail.chatError' => '채팅을 시작할 수 없습니다.',
			'friendDetail.startChat' => '채팅 시작',
			'friendDetail.block' => '차단',
			'friendDetail.report' => '신고',
			'friendDetail.loginRequired' => '로그인이 필요합니다.',
			'friendDetail.unblocked' => '차단이 해제되었습니다.',
			'friendDetail.blocked' => '사용자가 차단되었습니다.',
			'friendDetail.unblock' => '차단 해제',
			'locationFilter.title' => '위치 필터',
			'locationFilter.provinsi' => '주(Provinsi)',
			'locationFilter.kabupaten' => '카부파텐(Kabupaten)',
			'locationFilter.kota' => '코타(Kota)',
			'locationFilter.kecamatan' => '케카마탄(Kecamatan)',
			'locationFilter.kelurahan' => 'Kelurahan',
			'locationFilter.apply' => '필터 적용',
			'locationFilter.all' => '전체',
			'locationFilter.reset' => '초기화',
			'clubs.tabs.proposals' => '제안',
			'clubs.tabs.activeClubs' => '활동 중',
			'clubs.tabs.myClubs' => '내 클럽',
			'clubs.tabs.exploreClubs' => '클럽 탐색',
			'clubs.sections.active' => '공식 클럽',
			'clubs.sections.proposals' => '클럽 제안',
			'clubs.screen.error' => '오류: {error}',
			'clubs.screen.empty' => '아직 클럽이 없습니다.',
			'clubs.postList.empty' => '게시글이 없습니다. 첫 글을 남겨보세요!',
			'clubs.postList.writeTooltip' => '글쓰기',
			'clubs.memberCard.kickConfirmTitle' => '{memberName}님을 제거할까요?',
			'clubs.memberCard.kickConfirmContent' => '제거된 멤버는 더 이상 클럽 활동에 참여할 수 없습니다.',
			'clubs.memberCard.kick' => '제거',
			'clubs.memberCard.kickedSuccess' => '{memberName}님이 제거되었습니다.',
			'clubs.memberCard.kickFail' => '멤버 제거 실패: {error}',
			'clubs.postCard.deleteTitle' => '게시글 삭제',
			'clubs.postCard.deleteContent' => '이 게시글을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.',
			'clubs.postCard.deleteSuccess' => '게시글이 삭제되었습니다.',
			'clubs.postCard.deleteFail' => '게시글 삭제 실패: {error}',
			'clubs.postCard.withdrawnMember' => '탈퇴한 멤버',
			'clubs.postCard.deleteTooltip' => '게시글 삭제',
			'clubs.postCard.loadingUser' => '사용자 정보 불러오는 중...',
			'clubs.card.membersCount' => '멤버 {count}명',
			'clubs.postDetail.commentFail' => '댓글 추가 실패: {error}',
			'clubs.postDetail.appBarTitle' => '{title} 게시판',
			'clubs.postDetail.commentsTitle' => '댓글',
			'clubs.postDetail.noComments' => '댓글이 없습니다.',
			'clubs.postDetail.commentHint' => '댓글 작성...',
			'clubs.postDetail.unknownUser' => '알 수 없는 사용자',
			'clubs.detail.joined' => '‘{title}’ 클럽에 가입했습니다!',
			'clubs.detail.pendingApproval' => '운영자 승인 대기 중입니다. 승인 후 활동할 수 있습니다.',
			'clubs.detail.joinFail' => '가입 요청 실패: {error}',
			'clubs.detail.tabs.info' => '정보',
			'clubs.detail.tabs.board' => '게시판',
			'clubs.detail.tabs.members' => '멤버',
			'clubs.detail.joinChat' => '채팅 참여',
			'clubs.detail.joinClub' => '클럽 가입',
			'clubs.detail.owner' => '운영자',
			'clubs.detail.info.members' => '멤버',
			'clubs.detail.info.location' => '위치',
			'clubs.detail.location' => '위치',
			'clubs.detail.leaveConfirmTitle' => '클럽 탈퇴',
			'clubs.detail.leaveConfirmContent' => '{title} 클럽을 탈퇴하시겠습니까?',
			'clubs.detail.leave' => '탈퇴',
			'clubs.detail.leaveSuccess' => '{title} 클럽에서 탈퇴했습니다.',
			'clubs.detail.leaveFail' => '탈퇴 실패: {error}',
			'clubs.memberList.pendingMembers' => '승인 대기 멤버',
			'clubs.memberList.allMembers' => '전체 멤버',
			'clubs.createPost.title' => '새 글',
			'clubs.createPost.submit' => '등록',
			'clubs.createPost.success' => '글이 등록되었습니다.',
			'clubs.createPost.fail' => '글 등록 실패: {error}',
			'clubs.createPost.bodyHint' => '내용 입력...',
			'clubs.createClub.selectAtLeastOneInterest' => '관심사를 최소 1개 선택해 주세요.',
			'clubs.createClub.success' => '클럽이 생성되었습니다!',
			'clubs.createClub.fail' => '클럽 생성 실패: {error}',
			'clubs.createClub.title' => '클럽 만들기',
			'clubs.createClub.nameLabel' => '클럽 이름',
			'clubs.createClub.nameError' => '클럽 이름을 입력해 주세요.',
			'clubs.createClub.descriptionLabel' => '클럽 설명',
			'clubs.createClub.descriptionError' => '클럽 설명을 입력해 주세요.',
			'clubs.createClub.tagsHint' => '태그 입력 후 스페이스로 추가',
			'clubs.createClub.maxInterests' => '최대 3개의 관심사를 선택할 수 있습니다.',
			'clubs.createClub.privateClub' => '비공개 클럽',
			'clubs.createClub.privateDescription' => '초대받은 사람만 참여 가능',
			'clubs.createClub.locationLabel' => '위치',
			'clubs.editClub.title' => '클럽 정보 수정',
			'clubs.editClub.save' => '저장',
			'clubs.editClub.success' => '클럽 정보가 업데이트되었습니다.',
			'clubs.editClub.fail' => '업데이트 실패: {error}',
			'clubs.create.title' => '클럽 만들기',
			'clubs.repository.chatCreated' => '클럽 채팅방이 생성되었습니다.',
			'clubs.proposal.createTitle' => '클럽 제안 만들기',
			'clubs.proposal.imageError' => '커버 이미지를 선택해 주세요.',
			'clubs.proposal.createSuccess' => '클럽 제안이 생성되었습니다.',
			'clubs.proposal.createFail' => '클럽 제안 생성 실패: {error}',
			'clubs.proposal.tagsHint' => '태그 입력 후 스페이스로 추가',
			'clubs.proposal.targetMembers' => '목표 인원',
			'clubs.proposal.targetMembersCount' => '총 {count}명',
			'clubs.proposal.empty' => '아직 제안이 없습니다.',
			'clubs.proposal.memberStatus' => '{current} / {target}명',
			'clubs.proposal.join' => '참여',
			'clubs.proposal.leave' => '나가기',
			'clubs.proposal.members' => '멤버',
			'clubs.proposal.noMembers' => '아직 참여자가 없습니다.',
			'clubs.proposal.detail.joined' => '제안에 참여했습니다!',
			'clubs.proposal.detail.left' => '제안에서 나갔습니다.',
			'clubs.proposal.detail.loginRequired' => '참여하려면 로그인하세요.',
			'clubs.proposal.detail.error' => '오류가 발생했습니다: {error}',
			'clubs.empty' => '표시할 클럽이 없습니다.',
			'findfriend.form.title' => '친구 찾기 프로필 만들기',
			'auctions.card.currentBid' => '현재 입찰가',
			'auctions.card.endTime' => '남은 시간',
			'auctions.card.ended' => '종료됨',
			'auctions.card.winningBid' => '최종 낙찰가',
			'auctions.card.winner' => '낙찰자',
			'auctions.card.noBidders' => '아직 입찰자가 없습니다',
			'auctions.card.unknownBidder' => '알 수 없는 입찰자',
			'auctions.card.timeLeft' => '{hours}:{minutes}:{seconds} 남음',
			'auctions.card.timeLeftDays' => '{days}일 {hours}:{minutes}:{seconds} 남음',
			'auctions.errors.fetchFailed' => '경매 목록을 불러오지 못했습니다: {error}',
			'auctions.errors.notFound' => '경매를 찾을 수 없습니다.',
			'auctions.errors.lowerBid' => '현재 입찰가보다 높은 금액을 입력해야 합니다.',
			'auctions.errors.alreadyEnded' => '이 경매는 이미 종료되었습니다.',
			'auctions.empty' => '등록된 경매가 없습니다.',
			'auctions.filter.tooltip' => '필터',
			'auctions.filter.clearTooltip' => '필터 초기화',
			'auctions.create.tooltip' => '경매 등록',
			'auctions.create.title' => '경매 생성',
			'auctions.create.registrationType' => '등록 방식',
			'auctions.create.type.sale' => '판매',
			'auctions.create.type.auction' => '경매',
			'auctions.create.success' => '경매가 생성되었습니다.',
			'auctions.create.fail' => '경매 생성 실패: {error}',
			'auctions.create.submitButton' => '경매 시작',
			'auctions.create.confirmTitle' => '경매로 등록하시겠습니까?',
			'auctions.create.confirmContent' => '경매로 등록하면 일반 판매로 되돌릴 수 없습니다. 낙찰 시 5%의 수수료가 부과됩니다. 계속하시겠습니까?',
			'auctions.create.errors.noPhoto' => '사진을 최소 1장 이상 추가해 주세요.',
			'auctions.create.form.photoSectionTitle' => '사진 업로드 (최대 10장)',
			'auctions.create.form.title' => '제목',
			'auctions.create.form.description' => '설명',
			'auctions.create.form.startPrice' => '시작가',
			'auctions.create.form.category' => '카테고리',
			'auctions.create.form.categoryHint' => '카테고리 선택',
			'auctions.create.form.tagsHint' => '태그 입력 후 스페이스로 추가',
			'auctions.create.form.duration' => '기간',
			'auctions.create.form.durationOption' => '{days}일',
			'auctions.create.form.location' => '위치',
			'auctions.edit.tooltip' => '경매 수정',
			'auctions.edit.title' => '경매 수정',
			'auctions.edit.save' => '저장',
			'auctions.edit.success' => '경매가 수정되었습니다.',
			'auctions.edit.fail' => '경매 수정 실패: {error}',
			'auctions.form.titleRequired' => '제목을 입력해 주세요.',
			'auctions.form.descriptionRequired' => '설명을 입력해 주세요.',
			'auctions.form.startPriceRequired' => '시작가를 입력해 주세요.',
			'auctions.form.categoryRequired' => '카테고리를 선택해 주세요.',
			'auctions.delete.tooltip' => '경매 삭제',
			'auctions.delete.confirmTitle' => '경매 삭제',
			'auctions.delete.confirmContent' => '이 경매를 삭제하시겠습니까?',
			'auctions.delete.success' => '경매가 삭제되었습니다.',
			'auctions.delete.fail' => '경매 삭제 실패: {error}',
			'auctions.detail.currentBid' => '현재 입찰가: {amount}',
			'auctions.detail.location' => '위치',
			'auctions.detail.seller' => '판매자',
			'auctions.detail.qnaTitle' => '질문·답변',
			'auctions.detail.qnaHint' => '판매자에게 질문하세요...',
			'auctions.detail.endTime' => '종료 시간: {time}',
			'auctions.detail.bidsTitle' => '입찰 내역',
			'auctions.detail.noBids' => '입찰 내역이 없습니다.',
			'auctions.detail.unknownBidder' => '알 수 없는 입찰자',
			'auctions.detail.bidAmountLabel' => '입찰 금액 입력 (Rp)',
			'auctions.detail.placeBid' => '입찰하기',
			'auctions.detail.bidSuccess' => '입찰 성공!',
			'auctions.detail.bidFail' => '입찰 실패: {error}',
			'auctions.detail.errors.loginRequired' => '로그인이 필요합니다.',
			'auctions.detail.errors.invalidAmount' => '올바른 입찰 금액을 입력하세요.',
			'localStores.setLocationPrompt' => '근처 가게를 보려면 위치를 설정해 주세요.',
			'localStores.empty' => '아직 등록된 가게가 없습니다.',
			'localStores.error' => '오류가 발생했습니다: {error}',
			'localStores.create.tooltip' => '내 가게 등록',
			'localStores.create.title' => '새 가게 등록',
			'localStores.create.submit' => '등록',
			'localStores.create.success' => '가게가 등록되었습니다.',
			'localStores.create.fail' => '가게 등록 실패: {error}',
			'localStores.edit.title' => '가게 정보 수정',
			'localStores.edit.save' => '저장',
			'localStores.edit.success' => '가게 정보가 수정되었습니다.',
			'localStores.edit.fail' => '가게 정보 수정 실패: {error}',
			'localStores.edit.tooltip' => '가게 정보 수정',
			'localStores.form.nameLabel' => '가게 이름',
			'localStores.form.nameError' => '가게 이름을 입력해 주세요.',
			'localStores.form.descriptionLabel' => '가게 소개',
			'localStores.form.descriptionError' => '가게 소개를 입력해 주세요.',
			'localStores.form.contactLabel' => '연락처',
			'localStores.form.hoursLabel' => '영업 시간',
			'localStores.form.hoursHint' => '예: 09:00 - 18:00',
			'localStores.form.photoLabel' => '사진 (최대 {count}장)',
			'localStores.form.categoryLabel' => '카테고리',
			'localStores.form.categoryError' => '카테고리를 선택해 주세요.',
			'localStores.form.productsLabel' => '주요 상품/서비스',
			'localStores.form.productsHint' => '쉼표로 구분 (예: 커트, 염색, 펌)',
			'localStores.form.imageError' => '이미지를 불러오지 못했습니다. 다시 시도하세요.',
			'localStores.categories.all' => '전체',
			'localStores.categories.food' => '식당',
			'localStores.categories.cafe' => '카페',
			'localStores.categories.massage' => '마사지',
			'localStores.categories.beauty' => '미용',
			'localStores.categories.nail' => '네일',
			'localStores.categories.auto' => '자동차 정비',
			'localStores.categories.kids' => '키즈',
			'localStores.categories.hospital' => '병원/클리닉',
			'localStores.categories.etc' => '기타',
			'localStores.detail.description' => '가게 소개',
			'localStores.detail.products' => '상품/서비스',
			'localStores.detail.deleteTitle' => '가게 삭제',
			'localStores.detail.deleteContent' => '이 가게를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.',
			'localStores.detail.deleteTooltip' => '가게 삭제',
			'localStores.detail.delete' => '삭제',
			'localStores.detail.cancel' => '취소',
			'localStores.detail.deleteSuccess' => '가게가 삭제되었습니다.',
			'localStores.detail.deleteFail' => '가게 삭제 실패: {error}',
			'localStores.detail.inquire' => '문의',
			'localStores.detail.noOwnerInfo' => '가게 주인 정보를 찾을 수 없습니다',
			'localStores.detail.startChatFail' => '채팅을 시작할 수 없습니다: {error}',
			'localStores.detail.reviews' => '리뷰',
			'localStores.detail.writeReview' => '리뷰 작성',
			'localStores.detail.noReviews' => '아직 리뷰가 없습니다.',
			'localStores.detail.reviewDialogContent' => '리뷰를 작성해 주세요.',
			'localStores.noLocation' => '위치 정보 없음',
			'pom.title' => 'POM',
			'pom.search.hint' => 'POM, 태그, 사용자 검색',
			'pom.tabs.local' => '지역',
			'pom.tabs.all' => '전체',
			'pom.tabs.popular' => '인기',
			'pom.tabs.myPoms' => '내 POM',
			'pom.more' => '더 보기',
			'pom.less' => '접기',
			'pom.likesCount' => '{}개의 좋아요',
			'pom.report' => '{} 신고',
			'pom.block' => '{} 차단',
			'pom.emptyPopular' => '아직 인기 POM이 없습니다.',
			'pom.emptyMine' => '아직 업로드한 POM이 없습니다.',
			'pom.emptyHintPopular' => '최신 POM을 보려면 \'전체\' 탭을 확인하세요.',
			'pom.emptyCtaMine' => '+ 버튼을 눌러 첫 POM을 업로드하세요.',
			'pom.share' => '공유',
			'pom.empty' => '등록된 POM이 없습니다.',
			'pom.errors.fetchFailed' => '오류가 발생했습니다: {error}',
			'pom.errors.videoSource' => '이 영상은 재생할 수 없습니다. 소스가 차단되었거나 사용할 수 없습니다.',
			'pom.comments.title' => '댓글',
			'pom.comments.viewAll' => '{}개 댓글 모두 보기',
			'pom.comments.empty' => '아직 댓글이 없습니다.',
			'pom.comments.placeholder' => '댓글 작성...',
			'pom.comments.fail' => '댓글 작성 실패: {error}',
			'pom.create.title' => '새 POM 업로드',
			'pom.create.photo' => '사진',
			'pom.create.video' => '동영상',
			'pom.create.titleImage' => '사진 업로드',
			'pom.create.submit' => '업로드',
			'pom.create.success' => 'POM이 업로드되었습니다.',
			'pom.create.fail' => 'POM 업로드 실패: {error}',
			'pom.create.form.titleLabel' => '제목',
			'pom.create.form.descriptionLabel' => '설명',
			'realEstate.create' => '매물 등록',
			'realEstate.form.title' => '매물 등록',
			'realEstate.form.submit' => '등록',
			'realEstate.form.imageRequired' => '최소 한 장의 사진을 첨부해 주세요.',
			'realEstate.form.success' => '매물이 등록되었습니다.',
			'realEstate.form.fail' => '매물 등록에 실패했습니다: {error}',
			'realEstate.form.type.kos' => '하숙방(Kos)',
			'realEstate.form.type.kontrakan' => '월세(Kontrakan)',
			'realEstate.form.type.sewa' => '임대(Sewa)',
			'realEstate.form.priceRequired' => '가격을 입력해 주세요.',
			'realEstate.form.priceUnit.monthly' => '/월',
			'realEstate.form.priceUnit.yearly' => '/년',
			'realEstate.form.titleRequired' => '제목을 입력해 주세요.',
			'realEstate.form.roomTypes.kos' => '하숙방(Kos)',
			'realEstate.form.roomTypes.kontrakan' => '월세(Kontrakan)',
			'realEstate.form.roomTypes.sewa' => '임대(Sewa)',
			'realEstate.form.roomTypes.apartment' => '아파트',
			'realEstate.form.roomTypes.house' => '주택',
			'realEstate.form.roomTypes.ruko' => '상가(Ruko)',
			'realEstate.form.roomTypes.gudang' => '창고',
			'realEstate.form.roomTypes.kantor' => '사무실',
			'realEstate.form.roomTypes.etc' => '기타',
			'realEstate.form.listingType' => '거래 형태',
			'realEstate.form.listingTypeHint' => '거래 형태를 선택해 주세요',
			'realEstate.form.listingTypes.rent' => '임대',
			'realEstate.form.listingTypes.sale' => '매매',
			'realEstate.form.publisherType' => '게시자 유형',
			'realEstate.form.publisherTypes.individual' => '개인',
			'realEstate.form.publisherTypes.agent' => '중개인',
			'realEstate.form.area' => '면적',
			'realEstate.form.landArea' => '대지 면적',
			'realEstate.form.rooms' => '방',
			'realEstate.form.bathrooms' => '욕실',
			'realEstate.form.bedAbbr' => '침실',
			'realEstate.form.bathAbbr' => '욕실',
			'realEstate.form.moveInDate' => '입주 가능 날짜',
			'realEstate.form.selectDate' => '날짜 선택',
			'realEstate.form.clearDate' => '날짜 지우기',
			'realEstate.form.amenities' => '편의시설',
			'realEstate.form.details' => '매물 상세 정보',
			'realEstate.form.maintenanceFee' => '월 유지비',
			'realEstate.form.maintenanceFeeHint' => '월 유지비 (Rp)',
			'realEstate.form.deposit' => '보증금',
			'realEstate.form.depositHint' => '보증금 (Rp)',
			'realEstate.form.floorInfo' => '층수 정보',
			'realEstate.form.floorInfoHint' => '예: 5층 중 3층',
			'realEstate.form.priceLabel' => '가격 (IDR)',
			'realEstate.form.titleLabel' => '제목',
			'realEstate.form.descriptionLabel' => '설명',
			'realEstate.form.typeLabel' => '방 유형',
			'realEstate.form.areaHint' => '예: 33',
			'realEstate.form.amenity.wifi' => 'Wi‑Fi',
			'realEstate.form.amenity.ac' => '에어컨',
			'realEstate.form.amenity.parking' => '주차',
			'realEstate.form.amenity.kitchen' => '주방',
			'realEstate.detail.deleteTitle' => '매물 삭제',
			'realEstate.detail.deleteContent' => '이 매물을 삭제하시겠습니까?',
			'realEstate.detail.cancel' => '취소',
			'realEstate.detail.publisherInfo' => '게시자 정보',
			'realEstate.detail.contact' => '연락하기',
			'realEstate.detail.deleteConfirm' => '삭제',
			'realEstate.detail.deleteSuccess' => '매물이 삭제되었습니다.',
			'realEstate.detail.deleteFail' => '매물 삭제 실패: {error}',
			'realEstate.detail.chatError' => '채팅을 시작할 수 없습니다: {error}',
			'realEstate.detail.location' => '위치',
			'realEstate.locationUnknown' => '위치 정보 없음',
			'realEstate.priceUnits.monthly' => '월',
			'realEstate.priceUnits.yearly' => '년',
			'realEstate.filter.title' => '고급 필터',
			'realEstate.filter.priceRange' => '가격 범위',
			'realEstate.filter.areaRange' => '면적 범위 (m²)',
			'realEstate.filter.landAreaRange' => '대지 면적 범위 (m²)',
			'realEstate.filter.depositRange' => '보증금 범위',
			'realEstate.filter.floorInfo' => '층수 정보',
			'realEstate.filter.depositMin' => '최소 보증금',
			'realEstate.filter.depositMax' => '최대 보증금',
			'realEstate.filter.clearFloorInfo' => '지우기',
			'realEstate.filter.furnishedStatus' => '가구 옵션',
			'realEstate.filter.rentPeriod' => '임대 기간',
			_ => null,
		} ?? switch (path) {
			'realEstate.filter.selectFurnished' => '가구 옵션 선택',
			'realEstate.filter.furnishedHint' => '가구 옵션 선택',
			'realEstate.filter.selectRentPeriod' => '임대 기간 선택',
			'realEstate.filter.rentPeriods.daily' => '일간',
			'realEstate.filter.rentPeriods.monthly' => '월간',
			'realEstate.filter.rentPeriods.yearly' => '연간',
			'realEstate.filter.propertyCondition' => '매물 상태',
			'realEstate.filter.propertyConditions.kNew' => '신규',
			'realEstate.filter.propertyConditions.used' => '중고',
			'realEstate.filter.furnishedTypes.furnished' => '풀옵션',
			'realEstate.filter.furnishedTypes.semiFurnished' => '부분 옵션',
			'realEstate.filter.furnishedTypes.unfurnished' => '옵션 없음',
			'realEstate.filter.amenities.ac' => '에어컨',
			'realEstate.filter.amenities.bed' => '침대',
			'realEstate.filter.amenities.closet' => '옷장',
			'realEstate.filter.amenities.desk' => '책상',
			'realEstate.filter.amenities.wifi' => 'Wi‑Fi',
			'realEstate.filter.amenities.kitchen' => '주방',
			'realEstate.filter.amenities.livingRoom' => '거실',
			'realEstate.filter.amenities.refrigerator' => '냉장고',
			'realEstate.filter.amenities.parkingMotorcycle' => '오토바이 주차',
			'realEstate.filter.amenities.parkingCar' => '자동차 주차',
			'realEstate.filter.amenities.pool' => '수영장',
			'realEstate.filter.amenities.gym' => '헬스장',
			'realEstate.filter.amenities.security24h' => '24시간 보안',
			'realEstate.filter.amenities.atmCenter' => 'ATM',
			'realEstate.filter.amenities.minimarket' => '미니마트',
			'realEstate.filter.amenities.mallAccess' => '쇼핑몰 접근',
			'realEstate.filter.amenities.playground' => '놀이터',
			'realEstate.filter.amenities.carport' => '카포트',
			'realEstate.filter.amenities.garden' => '정원',
			'realEstate.filter.amenities.pam' => '상수도(PAM)',
			'realEstate.filter.amenities.telephone' => '전화',
			'realEstate.filter.amenities.waterHeater' => '온수기',
			'realEstate.filter.amenities.parkingArea' => '주차 공간',
			'realEstate.filter.amenities.electricity' => '전기',
			'realEstate.filter.amenities.containerAccess' => '컨테이너 출입',
			'realEstate.filter.amenities.kosRoom.ac' => '에어컨',
			'realEstate.filter.amenities.kosRoom.bed' => '침대',
			'realEstate.filter.amenities.kosRoom.closet' => '옷장',
			'realEstate.filter.amenities.kosRoom.desk' => '책상',
			'realEstate.filter.amenities.kosRoom.wifi' => 'Wi‑Fi',
			'realEstate.filter.amenities.kosPublic.kitchen' => '주방',
			'realEstate.filter.amenities.kosPublic.livingRoom' => '거실',
			'realEstate.filter.amenities.kosPublic.refrigerator' => '냉장고',
			'realEstate.filter.amenities.kosPublic.parkingMotorcycle' => '오토바이 주차',
			'realEstate.filter.amenities.kosPublic.parkingCar' => '자동차 주차',
			'realEstate.filter.amenities.apartment.pool' => '수영장',
			'realEstate.filter.amenities.apartment.gym' => '헬스장',
			'realEstate.filter.amenities.apartment.security24h' => '24시간 보안',
			'realEstate.filter.amenities.apartment.atmCenter' => 'ATM',
			'realEstate.filter.amenities.apartment.minimarket' => '미니마트',
			'realEstate.filter.amenities.apartment.mallAccess' => '쇼핑몰 접근',
			'realEstate.filter.amenities.apartment.playground' => '놀이터',
			'realEstate.filter.amenities.house.carport' => '카포트',
			'realEstate.filter.amenities.house.garden' => '정원',
			'realEstate.filter.amenities.house.pam' => '상수도(PAM)',
			'realEstate.filter.amenities.house.telephone' => '전화',
			'realEstate.filter.amenities.house.waterHeater' => '온수기',
			'realEstate.filter.amenities.commercial.parkingArea' => '주차 공간',
			'realEstate.filter.amenities.commercial.security24h' => '24시간 보안',
			'realEstate.filter.amenities.commercial.telephone' => '전화',
			'realEstate.filter.amenities.commercial.electricity' => '전기',
			'realEstate.filter.amenities.commercial.containerAccess' => '컨테이너 출입',
			'realEstate.filter.kos.bathroomType' => '욕실 유형',
			'realEstate.filter.kos.bathroomTypes.inRoom' => '실내 욕실',
			'realEstate.filter.kos.bathroomTypes.outRoom' => '실외 욕실',
			'realEstate.filter.kos.maxOccupants' => '최대 거주자 수',
			'realEstate.filter.kos.hintBathroomType' => '욕실 유형 선택',
			'realEstate.filter.kos.hintMaxOccupants' => '거주자 수 선택',
			'realEstate.filter.kos.electricityIncluded' => '전기 포함',
			'realEstate.filter.kos.roomFacilities' => '객실 시설',
			'realEstate.filter.kos.publicFacilities' => '공용 시설',
			'realEstate.filter.kos.occupant' => '명',
			'realEstate.filter.apartment.facilities' => '아파트 시설',
			'realEstate.filter.house.facilities' => '주택 시설',
			'realEstate.filter.commercial.facilities' => '상업용 시설',
			'realEstate.info.bed' => '침실',
			'realEstate.info.bath' => '욕실',
			'realEstate.info.anytime' => '언제든지',
			'realEstate.info.verifiedPublisher' => '인증된 게시자',
			'realEstate.disclaimer' => '블링은 온라인 광고 플랫폼이며 부동산 중개인이 아닙니다. 게시된 매물의 정보, 가격, 소유권, 진위 여부는 게시자에게 전적으로 책임이 있습니다. 사용자는 거래 전 반드시 게시자 및 관련 기관을 통해 정보를 직접 확인해야 합니다.',
			'realEstate.empty' => '등록된 매물이 없습니다.',
			'realEstate.error' => '오류가 발생했습니다: {error}',
			'realEstate.priceUnit.monthly' => '/월',
			'realEstate.edit.title' => '매물 수정',
			'realEstate.edit.save' => '저장',
			'realEstate.edit.success' => '매물이 수정되었습니다.',
			'realEstate.edit.fail' => '매물 수정 실패: {error}',
			'lostAndFound.tabs.all' => '전체',
			'lostAndFound.tabs.lost' => 'Lost',
			'lostAndFound.tabs.found' => 'Found',
			'lostAndFound.create' => '분실물/습득물 등록',
			'lostAndFound.form.title' => '분실/습득물 등록',
			'lostAndFound.form.submit' => '등록',
			'lostAndFound.form.type.lost' => '분실했습니다',
			'lostAndFound.form.type.found' => '습득했습니다',
			'lostAndFound.form.photoSectionTitle' => '사진 추가 (최대 5장)',
			'lostAndFound.form.imageRequired' => '최소 한 장의 사진을 첨부해 주세요.',
			'lostAndFound.form.itemLabel' => '어떤 물건인가요?',
			'lostAndFound.form.itemError' => '물건을 설명해 주세요.',
			'lostAndFound.form.bountyTitle' => '보상금 설정 (선택)',
			'lostAndFound.form.bountyDesc' => '보상금을 설정하면 게시물에 보상금 배지가 표시됩니다.',
			'lostAndFound.form.bountyAmount' => '보상금 금액 (IDR)',
			'lostAndFound.form.bountyAmountError' => '보상금을 활성화하려면 금액을 입력해 주세요.',
			'lostAndFound.form.success' => '등록 완료.',
			'lostAndFound.form.fail' => '등록 실패: {error}',
			'lostAndFound.form.tagsHint' => '태그 추가 (스페이스로 확정)',
			'lostAndFound.form.locationLabel' => '위치',
			'lostAndFound.form.locationError' => '위치를 입력해 주세요.',
			'lostAndFound.detail.title' => '분실 · 습득',
			'lostAndFound.detail.bounty' => '보상금',
			'lostAndFound.detail.registrant' => '등록자',
			'lostAndFound.detail.resolved' => '해결됨',
			'lostAndFound.detail.markAsResolved' => '해결로 표시',
			'lostAndFound.detail.deleteTitle' => '게시물 삭제',
			'lostAndFound.detail.deleteContent' => '이 게시물을 삭제하시겠습니까? 삭제는 되돌릴 수 없습니다.',
			'lostAndFound.detail.cancel' => '취소',
			'lostAndFound.detail.editTooltip' => '수정',
			'lostAndFound.detail.deleteTooltip' => '삭제',
			'lostAndFound.detail.noUser' => '사용자를 찾을 수 없습니다',
			'lostAndFound.detail.chatError' => '채팅을 시작할 수 없습니다: {error}',
			'lostAndFound.detail.location' => '위치',
			'lostAndFound.detail.contact' => '문의하기',
			'lostAndFound.detail.delete' => '삭제',
			'lostAndFound.detail.deleteSuccess' => '삭제되었습니다.',
			'lostAndFound.detail.deleteFail' => '삭제 실패: {error}',
			'lostAndFound.lost' => '분실',
			'lostAndFound.found' => '습득',
			'lostAndFound.card.location' => '위치: {location}',
			'lostAndFound.empty' => '등록된 글이 없습니다.',
			'lostAndFound.error' => '오류가 발생했습니다: {error}',
			'lostAndFound.resolve.confirmTitle' => '해결로 표시하시겠습니까?',
			'lostAndFound.resolve.confirmBody' => '이 항목을 해결된 것으로 표시합니다.',
			'lostAndFound.resolve.success' => '해결 처리되었습니다.',
			'lostAndFound.resolve.badgeLost' => '발견됨!',
			'lostAndFound.resolve.badgeFound' => '반환됨!',
			'lostAndFound.edit.title' => '글 수정',
			'lostAndFound.edit.save' => '저장',
			'lostAndFound.edit.success' => '수정되었습니다.',
			'lostAndFound.edit.fail' => '수정 실패: {error}',
			'community.title' => '커뮤니티',
			'shared.tagInput.defaultHint' => '태그를 입력하세요 (스페이스를 눌러 확정)',
			'linkPreview.errorTitle' => '미리보기를 불러올 수 없습니다',
			'linkPreview.errorBody' => '링크를 다시 확인하시거나 나중에 다시 시도해 주세요.',
			'selectCategory' => '카테고리 선택',
			'addressNeighborhood' => '동네',
			'addressDetailHint' => '상세 주소',
			'localNewsTagResult.error' => '검색 중 오류가 발생했습니다: {error}',
			'localNewsTagResult.empty' => '\'#{tag}\' 태그로 작성된 글이 없습니다.',
			'admin.screen.title' => '관리자 메뉴',
			'admin.menu.aiApproval' => 'AI 인증 관리',
			'admin.menu.reportManagement' => '신고 관리',
			'admin.aiApproval.empty' => 'AI 인증 대기 중인 상품이 없습니다.',
			'admin.aiApproval.error' => '대기 중인 상품을 불러오는 중 오류가 발생했습니다.',
			'admin.aiApproval.requestedAt' => '요청 시간',
			'admin.reports.title' => '신고 관리',
			'admin.reports.empty' => '대기 중인 신고가 없습니다.',
			'admin.reports.error' => '신고 목록을 불러오는 중 오류가 발생했습니다.',
			'admin.reports.createdAt' => '생성 시간',
			'admin.reportList.title' => '신고 관리',
			'admin.reportList.empty' => '대기 중인 신고가 없습니다.',
			'admin.reportList.error' => '신고 목록을 불러오는 중 오류가 발생했습니다.',
			'admin.reportDetail.title' => '신고 상세',
			'admin.reportDetail.loadError' => '신고 상세를 불러오는 중 오류가 발생했습니다.',
			'admin.reportDetail.sectionReportInfo' => '신고 정보',
			'admin.reportDetail.idLabel' => 'ID',
			'admin.reportDetail.postIdLabel' => '신고된 게시글 ID',
			'admin.reportDetail.reporter' => '신고자',
			'admin.reportDetail.reportedUser' => '신고 대상 사용자',
			'admin.reportDetail.reason' => '사유',
			'admin.reportDetail.reportedAt' => '신고 시간',
			'admin.reportDetail.currentStatus' => '상태',
			'admin.reportDetail.sectionContent' => '신고된 내용',
			'admin.reportDetail.loadingContent' => '내용을 불러오는 중...',
			'admin.reportDetail.contentLoadError' => '신고된 내용을 불러오지 못했습니다.',
			'admin.reportDetail.contentNotAvailable' => '내용 정보가 없거나 삭제되었습니다.',
			'admin.reportDetail.authorIdLabel' => '작성자 ID',
			'admin.reportDetail.content.post' => '게시글: {title}\n\n{body}',
			'admin.reportDetail.content.comment' => '댓글: {content}',
			'admin.reportDetail.content.reply' => '답글: {content}',
			'admin.reportDetail.viewOriginalPost' => '원본 게시글 보기',
			'admin.reportDetail.sectionActions' => '조치',
			'admin.reportDetail.actionReviewed' => '검토 완료로 표시',
			'admin.reportDetail.actionTaken' => '조치 완료로 표시(예: 삭제)',
			'admin.reportDetail.actionDismissed' => '신고 무시',
			'admin.reportDetail.statusUpdateSuccess' => '신고 상태가 \'{status}\'(으)로 변경되었습니다.',
			'admin.reportDetail.statusUpdateFail' => '상태를 업데이트하지 못했습니다: {error}',
			'admin.reportDetail.originalPostNotFound' => '원본 게시글을 찾을 수 없습니다.',
			'admin.reportDetail.couldNotOpenOriginalPost' => '원본 게시글을 열 수 없습니다.',
			'admin.dataFix.logsLabel' => 'Data Fix Logs',
			'tags.localNews.kelurahanNotice.name' => 'Kelurahan 공지',
			'tags.localNews.kelurahanNotice.desc' => 'Kelurahan 동사무소에서 올리는 안내입니다.',
			'tags.localNews.kecamatanNotice.name' => 'Kecamatan 공지',
			'tags.localNews.kecamatanNotice.desc' => '구청/군청(Kecamatan)에서 올리는 안내입니다.',
			'tags.localNews.publicCampaign.name' => '공익 캠페인',
			'tags.localNews.publicCampaign.desc' => '공익 정보와 정부 프로그램 안내입니다.',
			'tags.localNews.siskamling.name' => '동네 방범',
			'tags.localNews.siskamling.desc' => '주민 자율 방범·순찰 활동입니다.',
			'tags.localNews.powerOutage.name' => '정전 정보',
			'tags.localNews.powerOutage.desc' => '내 동네 전기 끊김·정전 안내입니다.',
			'tags.localNews.waterOutage.name' => '단수 정보',
			'tags.localNews.waterOutage.desc' => '수도 공급 중단 안내입니다.',
			'tags.localNews.wasteCollection.name' => '쓰레기 수거',
			'tags.localNews.wasteCollection.desc' => '쓰레기 수거 일정이나 변경 안내입니다.',
			'tags.localNews.roadWorks.name' => '도로 공사',
			'tags.localNews.roadWorks.desc' => '도로 공사 및 보수 작업 안내입니다.',
			'tags.localNews.publicFacility.name' => '공공시설',
			'tags.localNews.publicFacility.desc' => '공원, 운동장 등 공공시설 관련 소식입니다.',
			'tags.localNews.weatherWarning.name' => '기상 특보',
			'tags.localNews.weatherWarning.desc' => '내 동네 악천후·기상 특보 안내입니다.',
			'tags.localNews.floodAlert.name' => '홍수 경보',
			'tags.localNews.floodAlert.desc' => '홍수 위험 및 침수 지역 안내입니다.',
			'tags.localNews.airQuality.name' => '대기질',
			'tags.localNews.airQuality.desc' => '미세먼지 등 대기오염·AQI 정보입니다.',
			'tags.localNews.diseaseAlert.name' => '질병 경보',
			'tags.localNews.diseaseAlert.desc' => '감염병 경보와 보건 관련 안내입니다.',
			'tags.localNews.schoolNotice.name' => '학교 공지',
			'tags.localNews.schoolNotice.desc' => '주변 학교에서 올리는 안내입니다.',
			'tags.localNews.posyandu.name' => 'Posyandu',
			'tags.localNews.posyandu.desc' => '지역 보건소, 영유아·산모 대상 활동 안내입니다.',
			'tags.localNews.healthCampaign.name' => '보건 캠페인',
			'tags.localNews.healthCampaign.desc' => '건강 캠페인 및 공중보건 안내입니다.',
			'tags.localNews.trafficControl.name' => '교통 통제',
			'tags.localNews.trafficControl.desc' => '우회로, 도로 통제, 차단 정보입니다.',
			'tags.localNews.publicTransport.name' => '대중교통',
			'tags.localNews.publicTransport.desc' => '버스·기차 등 대중교통 관련 안내입니다.',
			'tags.localNews.parkingPolicy.name' => '주차 정책',
			'tags.localNews.parkingPolicy.desc' => '주차 정보 및 정책 변경 안내입니다.',
			'tags.localNews.communityEvent.name' => '지역 행사',
			'tags.localNews.communityEvent.desc' => '동네 축제, 모임, 행사 안내입니다.',
			'tags.localNews.worshipEvent.name' => '종교 행사',
			'tags.localNews.worshipEvent.desc' => '모스크, 교회, 사원 등 종교 행사 안내입니다.',
			'tags.localNews.incidentReport.name' => '사건·사고 제보',
			'tags.localNews.incidentReport.desc' => '우리 동네에서 발생한 사건·사고 제보입니다.',
			'boards.popup.inactiveTitle' => '동네 게시판이 아직 활성화되지 않았습니다',
			'boards.popup.inactiveBody' => '동네 게시판을 열려면 먼저 동네 소식을 한 번 올려 주세요. 이웃들이 참여하면 게시판이 자동으로 열립니다.',
			'boards.popup.writePost' => '동네 소식 쓰기',
			'boards.defaultTitle' => '게시판',
			'boards.chatRoomComingSoon' => '동네 채팅방이 곧 오픈됩니다',
			'boards.chatRoomTitle' => '채팅방',
			'boards.emptyFeed' => '아직 게시글이 없습니다.',
			'boards.chatRoomCreated' => '채팅방이 생성되었습니다.',
			'locationSettingError' => '위치를 설정하지 못했습니다.',
			'signupFailRequired' => '필수 입력 항목입니다.',
			'signup.alerts.signupSuccessLoginNotice' => '회원가입이 완료되었습니다! 이제 로그인해 주세요.',
			'signup.title' => '회원가입',
			'signup.subtitle' => '우리 동네 커뮤니티에 함께하세요!',
			'signup.nicknameHint' => '닉네임',
			'signup.emailHint' => '이메일 주소',
			'signup.passwordHint' => '비밀번호',
			'signup.passwordConfirmHint' => '비밀번호 확인',
			'signup.locationHint' => '동네 위치',
			'signup.locationNotice' => '내 위치는 동네 글을 보여주는 데만 사용되며 다른 사람에게 공개되지 않습니다.',
			'signup.buttons.signup' => '회원가입',
			'signupFailDefault' => '회원가입에 실패했습니다.',
			'signupFailWeakPassword' => '비밀번호가 너무 약합니다.',
			'signupFailEmailInUse' => '이미 사용 중인 이메일입니다.',
			'signupFailInvalidEmail' => '이메일 형식이 올바르지 않습니다.',
			'signupFailUnknown' => '알 수 없는 오류가 발생했습니다.',
			'categoryEmpty' => '카테고리 없음',
			'user.notLoggedIn' => '로그인되지 않았습니다.',
			'signupFailPasswordMismatch' => '비밀번호가 일치하지 않습니다.',
			_ => null,
		};
	}
}
