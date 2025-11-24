///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsKo = Translations; // ignore: unused_element
class Translations with BaseTranslations<AppLocale, Translations> {
	/// Returns the current translations of the given [context].
	///
	/// Usage:
	/// final t = Translations.of(context);
	static Translations of(BuildContext context) => InheritedLocaleData.of<AppLocale, Translations>(context).translations;

	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	Translations({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.ko,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <ko>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsLoginKo login = TranslationsLoginKo.internal(_root);
	late final TranslationsMainKo main = TranslationsMainKo.internal(_root);
	late final TranslationsSearchKo search = TranslationsSearchKo.internal(_root);
	late final TranslationsDrawerKo drawer = TranslationsDrawerKo.internal(_root);
	late final TranslationsMarketplaceKo marketplace = TranslationsMarketplaceKo.internal(_root);
	late final TranslationsAiFlowKo aiFlow = TranslationsAiFlowKo.internal(_root);
	late final TranslationsRegistrationFlowKo registrationFlow = TranslationsRegistrationFlowKo.internal(_root);
	late final TranslationsMyBlingKo myBling = TranslationsMyBlingKo.internal(_root);
	late final TranslationsProfileViewKo profileView = TranslationsProfileViewKo.internal(_root);
	late final TranslationsSettingsKo settings = TranslationsSettingsKo.internal(_root);
	late final TranslationsFriendRequestsKo friendRequests = TranslationsFriendRequestsKo.internal(_root);
	late final TranslationsSentFriendRequestsKo sentFriendRequests = TranslationsSentFriendRequestsKo.internal(_root);
	late final TranslationsBlockedUsersKo blockedUsers = TranslationsBlockedUsersKo.internal(_root);
	late final TranslationsRejectedUsersKo rejectedUsers = TranslationsRejectedUsersKo.internal(_root);
	late final TranslationsPromptKo prompt = TranslationsPromptKo.internal(_root);
	late final TranslationsLocationKo location = TranslationsLocationKo.internal(_root);
	late final TranslationsProfileEditKo profileEdit = TranslationsProfileEditKo.internal(_root);
	late final TranslationsMainFeedKo mainFeed = TranslationsMainFeedKo.internal(_root);
	late final TranslationsPostCardKo postCard = TranslationsPostCardKo.internal(_root);
	late final TranslationsTimeKo time = TranslationsTimeKo.internal(_root);
	late final TranslationsProductCardKo productCard = TranslationsProductCardKo.internal(_root);
	late final TranslationsLocalNewsFeedKo localNewsFeed = TranslationsLocalNewsFeedKo.internal(_root);
	late final TranslationsCategoriesKo categories = TranslationsCategoriesKo.internal(_root);
	late final TranslationsLocalNewsCreateKo localNewsCreate = TranslationsLocalNewsCreateKo.internal(_root);
	late final TranslationsLocalNewsDetailKo localNewsDetail = TranslationsLocalNewsDetailKo.internal(_root);
	late final TranslationsLocalNewsEditKo localNewsEdit = TranslationsLocalNewsEditKo.internal(_root);
	late final TranslationsCommentInputFieldKo commentInputField = TranslationsCommentInputFieldKo.internal(_root);
	late final TranslationsCommentListViewKo commentListView = TranslationsCommentListViewKo.internal(_root);
	late final TranslationsCommonKo common = TranslationsCommonKo.internal(_root);
	late final TranslationsReportDialogKo reportDialog = TranslationsReportDialogKo.internal(_root);
	late final TranslationsReplyDeleteKo replyDelete = TranslationsReplyDeleteKo.internal(_root);
	late final TranslationsReportReasonsKo reportReasons = TranslationsReportReasonsKo.internal(_root);
	late final TranslationsDeleteConfirmKo deleteConfirm = TranslationsDeleteConfirmKo.internal(_root);
	late final TranslationsReplyInputFieldKo replyInputField = TranslationsReplyInputFieldKo.internal(_root);
	late final TranslationsChatListKo chatList = TranslationsChatListKo.internal(_root);
	late final TranslationsChatRoomKo chatRoom = TranslationsChatRoomKo.internal(_root);
	late final TranslationsJobsKo jobs = TranslationsJobsKo.internal(_root);
	late final TranslationsFindFriendKo findFriend = TranslationsFindFriendKo.internal(_root);
	late final TranslationsInterestsKo interests = TranslationsInterestsKo.internal(_root);
	late final TranslationsFriendDetailKo friendDetail = TranslationsFriendDetailKo.internal(_root);
	late final TranslationsLocationFilterKo locationFilter = TranslationsLocationFilterKo.internal(_root);
	late final TranslationsClubsKo clubs = TranslationsClubsKo.internal(_root);
	late final TranslationsFindfriendKo findfriend = TranslationsFindfriendKo.internal(_root);
	late final TranslationsAuctionsKo auctions = TranslationsAuctionsKo.internal(_root);
	late final TranslationsLocalStoresKo localStores = TranslationsLocalStoresKo.internal(_root);
	late final TranslationsPomKo pom = TranslationsPomKo.internal(_root);
	late final TranslationsRealEstateKo realEstate = TranslationsRealEstateKo.internal(_root);
	late final TranslationsLostAndFoundKo lostAndFound = TranslationsLostAndFoundKo.internal(_root);
	late final TranslationsCommunityKo community = TranslationsCommunityKo.internal(_root);
	late final TranslationsSharedKo shared = TranslationsSharedKo.internal(_root);
	late final TranslationsLinkPreviewKo linkPreview = TranslationsLinkPreviewKo.internal(_root);

	/// ko: '카테고리 선택'
	String get selectCategory => '카테고리 선택';

	/// ko: '동네'
	String get addressNeighborhood => '동네';

	/// ko: '상세 주소'
	String get addressDetailHint => '상세 주소';

	late final TranslationsLocalNewsTagResultKo localNewsTagResult = TranslationsLocalNewsTagResultKo.internal(_root);
	late final TranslationsAdminKo admin = TranslationsAdminKo.internal(_root);
	late final TranslationsTagsKo tags = TranslationsTagsKo.internal(_root);
	late final TranslationsBoardsKo boards = TranslationsBoardsKo.internal(_root);

	/// ko: '위치를 설정하지 못했습니다.'
	String get locationSettingError => '위치를 설정하지 못했습니다.';

	/// ko: '필수 입력 항목입니다.'
	String get signupFailRequired => '필수 입력 항목입니다.';

	late final TranslationsSignupKo signup = TranslationsSignupKo.internal(_root);

	/// ko: '회원가입에 실패했습니다.'
	String get signupFailDefault => '회원가입에 실패했습니다.';

	/// ko: '비밀번호가 너무 약합니다.'
	String get signupFailWeakPassword => '비밀번호가 너무 약합니다.';

	/// ko: '이미 사용 중인 이메일입니다.'
	String get signupFailEmailInUse => '이미 사용 중인 이메일입니다.';

	/// ko: '이메일 형식이 올바르지 않습니다.'
	String get signupFailInvalidEmail => '이메일 형식이 올바르지 않습니다.';

	/// ko: '알 수 없는 오류가 발생했습니다.'
	String get signupFailUnknown => '알 수 없는 오류가 발생했습니다.';

	/// ko: '카테고리 없음'
	String get categoryEmpty => '카테고리 없음';

	late final TranslationsUserKo user = TranslationsUserKo.internal(_root);
}

// Path: login
class TranslationsLoginKo {
	TranslationsLoginKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '로그인'
	String get title => '로그인';

	/// ko: '블링에서 쉽게 사고팔기!'
	String get subtitle => '블링에서 쉽게 사고팔기!';

	/// ko: '이메일'
	String get emailHint => '이메일';

	/// ko: '비밀번호'
	String get passwordHint => '비밀번호';

	late final TranslationsLoginButtonsKo buttons = TranslationsLoginButtonsKo.internal(_root);
	late final TranslationsLoginLinksKo links = TranslationsLoginLinksKo.internal(_root);
	late final TranslationsLoginAlertsKo alerts = TranslationsLoginAlertsKo.internal(_root);
}

// Path: main
class TranslationsMainKo {
	TranslationsMainKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsMainAppBarKo appBar = TranslationsMainAppBarKo.internal(_root);
	late final TranslationsMainTabsKo tabs = TranslationsMainTabsKo.internal(_root);
	late final TranslationsMainBottomNavKo bottomNav = TranslationsMainBottomNavKo.internal(_root);
	late final TranslationsMainErrorsKo errors = TranslationsMainErrorsKo.internal(_root);

	/// ko: '내 동네'
	String get myTown => '내 동네';

	late final TranslationsMainMapViewKo mapView = TranslationsMainMapViewKo.internal(_root);
	late final TranslationsMainSearchKo search = TranslationsMainSearchKo.internal(_root);
}

// Path: search
class TranslationsSearchKo {
	TranslationsSearchKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: ''{keyword}' 검색 결과'
	String get resultsTitle => '\'{keyword}\' 검색 결과';

	late final TranslationsSearchEmptyKo empty = TranslationsSearchEmptyKo.internal(_root);

	/// ko: '검색어 입력'
	String get prompt => '검색어 입력';

	late final TranslationsSearchSheetKo sheet = TranslationsSearchSheetKo.internal(_root);

	/// ko: '결과'
	String get results => '결과';
}

// Path: drawer
class TranslationsDrawerKo {
	TranslationsDrawerKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '프로필 수정'
	String get editProfile => '프로필 수정';

	/// ko: '북마크'
	String get bookmarks => '북마크';

	/// ko: '샘플 데이터 업로드'
	String get uploadSampleData => '샘플 데이터 업로드';

	/// ko: '로그아웃'
	String get logout => '로그아웃';

	late final TranslationsDrawerTrustDashboardKo trustDashboard = TranslationsDrawerTrustDashboardKo.internal(_root);

	/// ko: '데이터 수정 실행'
	String get runDataFix => '데이터 수정 실행';
}

// Path: marketplace
class TranslationsMarketplaceKo {
	TranslationsMarketplaceKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '오류: {error}'
	String get error => '오류: {error}';

	/// ko: '등록된 상품이 없습니다. + 버튼을 눌러 첫 상품을 올려보세요!'
	String get empty => '등록된 상품이 없습니다.\n+ 버튼을 눌러 첫 상품을 올려보세요!';

	late final TranslationsMarketplaceRegistrationKo registration = TranslationsMarketplaceRegistrationKo.internal(_root);
	late final TranslationsMarketplaceEditKo edit = TranslationsMarketplaceEditKo.internal(_root);
	late final TranslationsMarketplaceDetailKo detail = TranslationsMarketplaceDetailKo.internal(_root);
	late final TranslationsMarketplaceDialogKo dialog = TranslationsMarketplaceDialogKo.internal(_root);
	late final TranslationsMarketplaceErrorsKo errors = TranslationsMarketplaceErrorsKo.internal(_root);
	late final TranslationsMarketplaceConditionKo condition = TranslationsMarketplaceConditionKo.internal(_root);
	late final TranslationsMarketplaceReservationKo reservation = TranslationsMarketplaceReservationKo.internal(_root);
	late final TranslationsMarketplaceStatusKo status = TranslationsMarketplaceStatusKo.internal(_root);
	late final TranslationsMarketplaceAiKo ai = TranslationsMarketplaceAiKo.internal(_root);
	late final TranslationsMarketplaceTakeoverKo takeover = TranslationsMarketplaceTakeoverKo.internal(_root);

	/// ko: 'AI 인증'
	String get aiBadge => 'AI 인증';

	/// ko: '동네를 먼저 설정하면 중고거래 상품을 볼 수 있어요!'
	String get setLocationPrompt => '동네를 먼저 설정하면 중고거래 상품을 볼 수 있어요!';
}

// Path: aiFlow
class TranslationsAiFlowKo {
	TranslationsAiFlowKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsAiFlowCommonKo common = TranslationsAiFlowCommonKo.internal(_root);
	late final TranslationsAiFlowCtaKo cta = TranslationsAiFlowCtaKo.internal(_root);
	late final TranslationsAiFlowCategorySelectionKo categorySelection = TranslationsAiFlowCategorySelectionKo.internal(_root);
	late final TranslationsAiFlowGalleryUploadKo galleryUpload = TranslationsAiFlowGalleryUploadKo.internal(_root);
	late final TranslationsAiFlowPredictionKo prediction = TranslationsAiFlowPredictionKo.internal(_root);
	late final TranslationsAiFlowGuidedCameraKo guidedCamera = TranslationsAiFlowGuidedCameraKo.internal(_root);
	late final TranslationsAiFlowFinalReportKo finalReport = TranslationsAiFlowFinalReportKo.internal(_root);
	late final TranslationsAiFlowEvidenceKo evidence = TranslationsAiFlowEvidenceKo.internal(_root);
	late final TranslationsAiFlowErrorKo error = TranslationsAiFlowErrorKo.internal(_root);
}

// Path: registrationFlow
class TranslationsRegistrationFlowKo {
	TranslationsRegistrationFlowKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '판매할 상품 유형 선택'
	String get title => '판매할 상품 유형 선택';

	/// ko: '새 상품·일반 중고 등록'
	String get newItemTitle => '새 상품·일반 중고 등록';

	/// ko: '안 쓰는 새 상품과 일반 중고 상품을 빠르게 등록해요.'
	String get newItemDesc => '안 쓰는 새 상품과 일반 중고 상품을 빠르게 등록해요.';

	/// ko: '중고 상품 (AI 인증)'
	String get usedItemTitle => '중고 상품 (AI 인증)';

	/// ko: 'AI가 상품을 분석해 신뢰를 높이고 판매를 도와줍니다.'
	String get usedItemDesc => 'AI가 상품을 분석해 신뢰를 높이고 판매를 도와줍니다.';
}

// Path: myBling
class TranslationsMyBlingKo {
	TranslationsMyBlingKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '나의 블링'
	String get title => '나의 블링';

	/// ko: '프로필 편집'
	String get editProfile => '프로필 편집';

	/// ko: '설정'
	String get settings => '설정';

	/// ko: '게시글'
	String get posts => '게시글';

	/// ko: '팔로워'
	String get followers => '팔로워';

	/// ko: '이웃'
	String get neighbors => '이웃';

	/// ko: '친구'
	String get friends => '친구';

	late final TranslationsMyBlingStatsKo stats = TranslationsMyBlingStatsKo.internal(_root);
	late final TranslationsMyBlingTabsKo tabs = TranslationsMyBlingTabsKo.internal(_root);

	/// ko: '받은 친구 요청'
	String get friendRequests => '받은 친구 요청';

	/// ko: '보낸 친구 요청'
	String get sentFriendRequests => '보낸 친구 요청';
}

// Path: profileView
class TranslationsProfileViewKo {
	TranslationsProfileViewKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '프로필'
	String get title => '프로필';

	late final TranslationsProfileViewTabsKo tabs = TranslationsProfileViewTabsKo.internal(_root);

	/// ko: '아직 게시글이 없습니다.'
	String get noPosts => '아직 게시글이 없습니다.';

	/// ko: '등록된 관심사가 없습니다.'
	String get noInterests => '등록된 관심사가 없습니다.';
}

// Path: settings
class TranslationsSettingsKo {
	TranslationsSettingsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '설정'
	String get title => '설정';

	/// ko: '계정 및 개인정보'
	String get accountPrivacy => '계정 및 개인정보';

	late final TranslationsSettingsNotificationsKo notifications = TranslationsSettingsNotificationsKo.internal(_root);

	/// ko: '앱 정보'
	String get appInfo => '앱 정보';
}

// Path: friendRequests
class TranslationsFriendRequestsKo {
	TranslationsFriendRequestsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '받은 친구 요청'
	String get title => '받은 친구 요청';

	/// ko: '받은 친구 요청이 없습니다.'
	String get noRequests => '받은 친구 요청이 없습니다.';

	/// ko: '친구 요청을 수락했습니다.'
	String get acceptSuccess => '친구 요청을 수락했습니다.';

	/// ko: '친구 요청을 거절했습니다.'
	String get rejectSuccess => '친구 요청을 거절했습니다.';

	/// ko: '오류가 발생했습니다: {error}'
	String get error => '오류가 발생했습니다: {error}';

	late final TranslationsFriendRequestsTooltipKo tooltip = TranslationsFriendRequestsTooltipKo.internal(_root);

	/// ko: '이제 친구가 되었어요! 대화를 시작해 보세요.'
	String get defaultChatMessage => '이제 친구가 되었어요! 대화를 시작해 보세요.';
}

// Path: sentFriendRequests
class TranslationsSentFriendRequestsKo {
	TranslationsSentFriendRequestsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '보낸 친구 요청'
	String get title => '보낸 친구 요청';

	/// ko: '보낸 친구 요청이 없습니다.'
	String get noRequests => '보낸 친구 요청이 없습니다.';

	/// ko: '상태: {status}'
	String get statusLabel => '상태: {status}';

	late final TranslationsSentFriendRequestsStatusKo status = TranslationsSentFriendRequestsStatusKo.internal(_root);
}

// Path: blockedUsers
class TranslationsBlockedUsersKo {
	TranslationsBlockedUsersKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '차단한 사용자'
	String get title => '차단한 사용자';

	/// ko: '아직 아무도 차단하지 않았습니다.'
	String get noBlockedUsers => '아직 아무도 차단하지 않았습니다.';

	/// ko: '차단 해제'
	String get unblock => '차단 해제';

	late final TranslationsBlockedUsersUnblockDialogKo unblockDialog = TranslationsBlockedUsersUnblockDialogKo.internal(_root);

	/// ko: '{nickname} 님의 차단을 해제했습니다.'
	String get unblockSuccess => '{nickname} 님의 차단을 해제했습니다.';

	/// ko: '차단 해제에 실패했습니다: {error}'
	String get unblockFailure => '차단 해제에 실패했습니다: {error}';

	/// ko: '알 수 없는 사용자'
	String get unknownUser => '알 수 없는 사용자';

	/// ko: '차단한 사용자가 없습니다.'
	String get empty => '차단한 사용자가 없습니다.';
}

// Path: rejectedUsers
class TranslationsRejectedUsersKo {
	TranslationsRejectedUsersKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '거절한 사용자 관리'
	String get title => '거절한 사용자 관리';

	/// ko: '거절한 친구 요청이 없습니다.'
	String get noRejectedUsers => '거절한 친구 요청이 없습니다.';

	/// ko: '거절 취소'
	String get unreject => '거절 취소';

	late final TranslationsRejectedUsersUnrejectDialogKo unrejectDialog = TranslationsRejectedUsersUnrejectDialogKo.internal(_root);

	/// ko: '{nickname} 님에 대한 거절 취소가 완료되었습니다.'
	String get unrejectSuccess => '{nickname} 님에 대한 거절 취소가 완료되었습니다.';

	/// ko: '거절 취소에 실패했습니다: {error}'
	String get unrejectFailure => '거절 취소에 실패했습니다: {error}';
}

// Path: prompt
class TranslationsPromptKo {
	TranslationsPromptKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '블링에 오신 것을 환영합니다!'
	String get title => '블링에 오신 것을 환영합니다!';

	/// ko: '내 주변 소식과 중고거래를 보려면 먼저 동네를 설정해 주세요.'
	String get subtitle => '내 주변 소식과 중고거래를 보려면 먼저 동네를 설정해 주세요.';

	/// ko: '내 동네 설정하기'
	String get button => '내 동네 설정하기';
}

// Path: location
class TranslationsLocationKo {
	TranslationsLocationKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '동네 설정'
	String get title => '동네 설정';

	/// ko: '동네 이름으로 검색 (예: Serpong)'
	String get searchHint => '동네 이름으로 검색 (예: Serpong)';

	/// ko: '현재 위치 사용'
	String get gpsButton => '현재 위치 사용';

	/// ko: '동네가 설정되었습니다.'
	String get success => '동네가 설정되었습니다.';

	/// ko: '동네 설정에 실패했습니다: {error}'
	String get error => '동네 설정에 실패했습니다: {error}';

	/// ko: '동네 이름을 입력해 주세요.'
	String get empty => '동네 이름을 입력해 주세요.';

	/// ko: '내 동네를 찾으려면 위치 권한이 필요합니다.'
	String get permissionDenied => '내 동네를 찾으려면 위치 권한이 필요합니다.';

	/// ko: 'RT'
	String get rtLabel => 'RT';

	/// ko: 'RW'
	String get rwLabel => 'RW';

	/// ko: '예: 003'
	String get rtHint => '예: 003';

	/// ko: '예: 007'
	String get rwHint => '예: 007';

	/// ko: 'RT를 입력해 주세요.'
	String get rtRequired => 'RT를 입력해 주세요.';

	/// ko: 'RW를 입력해 주세요.'
	String get rwRequired => 'RW를 입력해 주세요.';

	/// ko: 'RT/RW 정보는 공개되지 않으며, 신뢰도 및 동네 기능 향상을 위해서만 사용됩니다.'
	String get rtRwInfo => 'RT/RW 정보는 공개되지 않으며, 신뢰도 및 동네 기능 향상을 위해서만 사용됩니다.';

	/// ko: '이 위치 저장'
	String get saveThisLocation => '이 위치 저장';

	/// ko: '직접 선택'
	String get manualSelect => '직접 선택';

	/// ko: 'GPS로 다시 불러오기'
	String get refreshFromGps => 'GPS로 다시 불러오기';
}

// Path: profileEdit
class TranslationsProfileEditKo {
	TranslationsProfileEditKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '프로필 설정'
	String get title => '프로필 설정';

	/// ko: '닉네임'
	String get nicknameHint => '닉네임';

	/// ko: '전화번호'
	String get phoneHint => '전화번호';

	/// ko: '소개글'
	String get bioHint => '소개글';

	/// ko: '위치'
	String get locationTitle => '위치';

	/// ko: '변경'
	String get changeLocation => '변경';

	/// ko: '미설정'
	String get locationNotSet => '미설정';

	late final TranslationsProfileEditInterestsKo interests = TranslationsProfileEditInterestsKo.internal(_root);
	late final TranslationsProfileEditPrivacyKo privacy = TranslationsProfileEditPrivacyKo.internal(_root);

	/// ko: '변경 사항 저장'
	String get saveButton => '변경 사항 저장';

	/// ko: '프로필이 성공적으로 업데이트되었습니다.'
	String get successMessage => '프로필이 성공적으로 업데이트되었습니다.';

	late final TranslationsProfileEditErrorsKo errors = TranslationsProfileEditErrorsKo.internal(_root);
}

// Path: mainFeed
class TranslationsMainFeedKo {
	TranslationsMainFeedKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '오류가 발생했습니다: {error}'
	String get error => '오류가 발생했습니다: {error}';

	/// ko: '새 게시글이 없습니다.'
	String get empty => '새 게시글이 없습니다.';
}

// Path: postCard
class TranslationsPostCardKo {
	TranslationsPostCardKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '위치 미설정'
	String get locationNotSet => '위치 미설정';

	/// ko: '위치'
	String get location => '위치';

	/// ko: '작성자를 찾을 수 없습니다.'
	String get authorNotFound => '작성자를 찾을 수 없습니다.';
}

// Path: time
class TranslationsTimeKo {
	TranslationsTimeKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '방금 전'
	String get now => '방금 전';

	/// ko: '{minutes}분 전'
	String get minutesAgo => '{minutes}분 전';

	/// ko: '{hours}시간 전'
	String get hoursAgo => '{hours}시간 전';

	/// ko: '{days}일 전'
	String get daysAgo => '{days}일 전';

	/// ko: 'yy.MM.dd'
	String get dateFormat => 'yy.MM.dd';

	/// ko: 'MMM d'
	String get dateFormatLong => 'MMM d';
}

// Path: productCard
class TranslationsProductCardKo {
	TranslationsProductCardKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '$'
	String get currency => '\$';
}

// Path: localNewsFeed
class TranslationsLocalNewsFeedKo {
	TranslationsLocalNewsFeedKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '동네 소식을 보려면 동네를 설정해 주세요!'
	String get setLocationPrompt => '동네 소식을 보려면 동네를 설정해 주세요!';

	/// ko: '전체'
	String get allCategory => '전체';

	/// ko: '표시할 게시글이 없습니다.'
	String get empty => '표시할 게시글이 없습니다.';

	/// ko: '오류가 발생했습니다: {error}'
	String get error => '오류가 발생했습니다: {error}';
}

// Path: categories
class TranslationsCategoriesKo {
	TranslationsCategoriesKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsCategoriesPostKo post = TranslationsCategoriesPostKo.internal(_root);
	late final TranslationsCategoriesAuctionKo auction = TranslationsCategoriesAuctionKo.internal(_root);
}

// Path: localNewsCreate
class TranslationsLocalNewsCreateKo {
	TranslationsLocalNewsCreateKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '새 글 만들기'
	String get appBarTitle => '새 글 만들기';

	/// ko: '새 글 만들기'
	String get title => '새 글 만들기';

	late final TranslationsLocalNewsCreateFormKo form = TranslationsLocalNewsCreateFormKo.internal(_root);
	late final TranslationsLocalNewsCreateLabelsKo labels = TranslationsLocalNewsCreateLabelsKo.internal(_root);
	late final TranslationsLocalNewsCreateHintsKo hints = TranslationsLocalNewsCreateHintsKo.internal(_root);
	late final TranslationsLocalNewsCreateValidationKo validation = TranslationsLocalNewsCreateValidationKo.internal(_root);
	late final TranslationsLocalNewsCreateButtonsKo buttons = TranslationsLocalNewsCreateButtonsKo.internal(_root);
	late final TranslationsLocalNewsCreateAlertsKo alerts = TranslationsLocalNewsCreateAlertsKo.internal(_root);

	/// ko: '게시글이 등록되었습니다.'
	String get success => '게시글이 등록되었습니다.';

	/// ko: '게시글 등록에 실패했습니다: {error}'
	String get fail => '게시글 등록에 실패했습니다: {error}';
}

// Path: localNewsDetail
class TranslationsLocalNewsDetailKo {
	TranslationsLocalNewsDetailKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '게시글'
	String get appBarTitle => '게시글';

	late final TranslationsLocalNewsDetailMenuKo menu = TranslationsLocalNewsDetailMenuKo.internal(_root);
	late final TranslationsLocalNewsDetailStatsKo stats = TranslationsLocalNewsDetailStatsKo.internal(_root);
	late final TranslationsLocalNewsDetailButtonsKo buttons = TranslationsLocalNewsDetailButtonsKo.internal(_root);

	/// ko: '이 게시글을 삭제하시겠습니까?'
	String get confirmDelete => '이 게시글을 삭제하시겠습니까?';

	/// ko: '게시글이 삭제되었습니다.'
	String get deleted => '게시글이 삭제되었습니다.';
}

// Path: localNewsEdit
class TranslationsLocalNewsEditKo {
	TranslationsLocalNewsEditKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '게시글 수정'
	String get appBarTitle => '게시글 수정';

	late final TranslationsLocalNewsEditButtonsKo buttons = TranslationsLocalNewsEditButtonsKo.internal(_root);
	late final TranslationsLocalNewsEditAlertsKo alerts = TranslationsLocalNewsEditAlertsKo.internal(_root);
}

// Path: commentInputField
class TranslationsCommentInputFieldKo {
	TranslationsCommentInputFieldKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '비밀'
	String get secretCommentLabel => '비밀';

	/// ko: '댓글을 입력하세요...'
	String get hintText => '댓글을 입력하세요...';

	/// ko: '{nickname}님께 답글 쓰는 중...'
	String get replyHintText => '{nickname}님께 답글 쓰는 중...';

	late final TranslationsCommentInputFieldButtonKo button = TranslationsCommentInputFieldButtonKo.internal(_root);
}

// Path: commentListView
class TranslationsCommentListViewKo {
	TranslationsCommentListViewKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '아직 댓글이 없습니다. 첫 댓글을 남겨보세요!'
	String get empty => '아직 댓글이 없습니다. 첫 댓글을 남겨보세요!';

	/// ko: '답글'
	String get reply => '답글';

	/// ko: '삭제'
	String get delete => '삭제';

	/// ko: '[삭제된 댓글입니다]'
	String get deleted => '[삭제된 댓글입니다]';

	/// ko: '이 댓글은 작성자와 글 작성자만 볼 수 있는 비밀 댓글입니다.'
	String get secret => '이 댓글은 작성자와 글 작성자만 볼 수 있는 비밀 댓글입니다.';
}

// Path: common
class TranslationsCommonKo {
	TranslationsCommonKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '취소'
	String get cancel => '취소';

	/// ko: '확인'
	String get confirm => '확인';

	/// ko: '삭제'
	String get delete => '삭제';

	/// ko: '완료'
	String get done => '완료';

	/// ko: '지우기'
	String get clear => '지우기';

	/// ko: '신고'
	String get report => '신고';

	/// ko: '더 보기'
	String get moreOptions => '더 보기';

	/// ko: '전체 보기'
	String get viewAll => '전체 보기';

	/// ko: '새 글'
	String get kNew => '새 글';

	/// ko: '업데이트됨'
	String get updated => '업데이트됨';

	/// ko: '댓글'
	String get comments => '댓글';

	/// ko: '스폰서'
	String get sponsored => '스폰서';

	/// ko: '필터'
	String get filter => '필터';

	/// ko: '초기화'
	String get reset => '초기화';

	/// ko: '적용'
	String get apply => '적용';

	/// ko: '인증됨'
	String get verified => '인증됨';

	/// ko: '북마크'
	String get bookmark => '북마크';

	late final TranslationsCommonSortKo sort = TranslationsCommonSortKo.internal(_root);

	/// ko: '오류가 발생했습니다.'
	String get error => '오류가 발생했습니다.';

	/// ko: '공유에 실패했습니다. 다시 시도해 주세요.'
	String get shareError => '공유에 실패했습니다. 다시 시도해 주세요.';

	/// ko: '수정'
	String get edit => '수정';

	/// ko: '등록'
	String get submit => '등록';

	/// ko: '로그인이 필요합니다.'
	String get loginRequired => '로그인이 필요합니다.';

	/// ko: '알 수 없는 사용자입니다.'
	String get unknownUser => '알 수 없는 사용자입니다.';
}

// Path: reportDialog
class TranslationsReportDialogKo {
	TranslationsReportDialogKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '게시글 신고'
	String get title => '게시글 신고';

	/// ko: '댓글 신고'
	String get titleComment => '댓글 신고';

	/// ko: '답글 신고'
	String get titleReply => '답글 신고';

	/// ko: '내가 쓴 댓글은 신고할 수 없습니다.'
	String get cannotReportSelfComment => '내가 쓴 댓글은 신고할 수 없습니다.';

	/// ko: '내가 쓴 답글은 신고할 수 없습니다.'
	String get cannotReportSelfReply => '내가 쓴 답글은 신고할 수 없습니다.';

	/// ko: '신고가 접수되었습니다. 감사합니다.'
	String get success => '신고가 접수되었습니다. 감사합니다.';

	/// ko: '신고 접수에 실패했습니다: {error}'
	String get fail => '신고 접수에 실패했습니다: {error}';

	/// ko: '내가 쓴 게시글은 신고할 수 없습니다.'
	String get cannotReportSelf => '내가 쓴 게시글은 신고할 수 없습니다.';
}

// Path: replyDelete
class TranslationsReplyDeleteKo {
	TranslationsReplyDeleteKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '답글 삭제에 실패했습니다: {error}'
	String get fail => '답글 삭제에 실패했습니다: {error}';
}

// Path: reportReasons
class TranslationsReportReasonsKo {
	TranslationsReportReasonsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '스팸 또는 오해의 소지가 있음'
	String get spam => '스팸 또는 오해의 소지가 있음';

	/// ko: '괴롭힘 또는 혐오 발언'
	String get abuse => '괴롭힘 또는 혐오 발언';

	/// ko: '성적으로 부적절함'
	String get inappropriate => '성적으로 부적절함';

	/// ko: '불법적인 내용'
	String get illegal => '불법적인 내용';

	/// ko: '기타'
	String get etc => '기타';
}

// Path: deleteConfirm
class TranslationsDeleteConfirmKo {
	TranslationsDeleteConfirmKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '댓글 삭제'
	String get title => '댓글 삭제';

	/// ko: '이 댓글을 삭제하시겠습니까?'
	String get content => '이 댓글을 삭제하시겠습니까?';

	/// ko: '댓글 삭제에 실패했습니다: {error}'
	String get failure => '댓글 삭제에 실패했습니다: {error}';
}

// Path: replyInputField
class TranslationsReplyInputFieldKo {
	TranslationsReplyInputFieldKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '답글을 입력하세요'
	String get hintText => '답글을 입력하세요';

	late final TranslationsReplyInputFieldButtonKo button = TranslationsReplyInputFieldButtonKo.internal(_root);

	/// ko: '답글 추가에 실패했습니다: {error}'
	String get failure => '답글 추가에 실패했습니다: {error}';
}

// Path: chatList
class TranslationsChatListKo {
	TranslationsChatListKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '채팅'
	String get appBarTitle => '채팅';

	/// ko: '아직 대화가 없습니다.'
	String get empty => '아직 대화가 없습니다.';
}

// Path: chatRoom
class TranslationsChatRoomKo {
	TranslationsChatRoomKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '대화를 시작해 보세요'
	String get startConversation => '대화를 시작해 보세요';

	/// ko: '안녕하세요! 👋'
	String get icebreaker1 => '안녕하세요! 👋';

	/// ko: '주말에는 보통 뭐 하세요?'
	String get icebreaker2 => '주말에는 보통 뭐 하세요?';

	/// ko: '근처에 좋아하는 장소가 있나요?'
	String get icebreaker3 => '근처에 좋아하는 장소가 있나요?';

	/// ko: '안전상의 이유로, 24시간 동안 미디어 전송이 제한됩니다.'
	String get mediaBlocked => '안전상의 이유로, 24시간 동안 미디어 전송이 제한됩니다.';

	/// ko: '이미지'
	String get imageMessage => '이미지';

	/// ko: '보호 모드: 링크 숨김'
	String get linkHidden => '보호 모드: 링크 숨김';

	/// ko: '보호 모드: 연락처 숨김'
	String get contactHidden => '보호 모드: 연락처 숨김';
}

// Path: jobs
class TranslationsJobsKo {
	TranslationsJobsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '일자리 글을 보려면 위치를 설정해 주세요!'
	String get setLocationPrompt => '일자리 글을 보려면 위치를 설정해 주세요!';

	late final TranslationsJobsScreenKo screen = TranslationsJobsScreenKo.internal(_root);
	late final TranslationsJobsTabsKo tabs = TranslationsJobsTabsKo.internal(_root);
	late final TranslationsJobsSelectTypeKo selectType = TranslationsJobsSelectTypeKo.internal(_root);
	late final TranslationsJobsFormKo form = TranslationsJobsFormKo.internal(_root);
	late final TranslationsJobsCategoriesKo categories = TranslationsJobsCategoriesKo.internal(_root);
	late final TranslationsJobsSalaryTypesKo salaryTypes = TranslationsJobsSalaryTypesKo.internal(_root);
	late final TranslationsJobsWorkPeriodsKo workPeriods = TranslationsJobsWorkPeriodsKo.internal(_root);
	late final TranslationsJobsDetailKo detail = TranslationsJobsDetailKo.internal(_root);
	late final TranslationsJobsCardKo card = TranslationsJobsCardKo.internal(_root);
}

// Path: findFriend
class TranslationsFindFriendKo {
	TranslationsFindFriendKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '친구 찾기'
	String get title => '친구 찾기';

	late final TranslationsFindFriendTabsKo tabs = TranslationsFindFriendTabsKo.internal(_root);

	/// ko: '친구찾기 프로필 수정'
	String get editTitle => '친구찾기 프로필 수정';

	/// ko: '프로필 수정'
	String get editProfileTitle => '프로필 수정';

	/// ko: '저장'
	String get save => '저장';

	/// ko: '프로필 이미지 (최대 6장)'
	String get profileImagesLabel => '프로필 이미지 (최대 6장)';

	/// ko: '소개'
	String get bioLabel => '소개';

	/// ko: '다른 사람들에게 자신을 소개해 주세요.'
	String get bioHint => '다른 사람들에게 자신을 소개해 주세요.';

	/// ko: '소개글을 입력해 주세요.'
	String get bioValidator => '소개글을 입력해 주세요.';

	/// ko: '나이'
	String get ageLabel => '나이';

	/// ko: '나이를 입력해 주세요.'
	String get ageHint => '나이를 입력해 주세요.';

	/// ko: '성별'
	String get genderLabel => '성별';

	/// ko: '남성'
	String get genderMale => '남성';

	/// ko: '여성'
	String get genderFemale => '여성';

	/// ko: '성별을 선택해 주세요'
	String get genderHint => '성별을 선택해 주세요';

	/// ko: '관심사'
	String get interestsLabel => '관심사';

	/// ko: '선호 친구 나이'
	String get preferredAgeLabel => '선호 친구 나이';

	/// ko: '세'
	String get preferredAgeUnit => '세';

	/// ko: '선호 친구 성별'
	String get preferredGenderLabel => '선호 친구 성별';

	/// ko: '모두'
	String get preferredGenderAll => '모두';

	/// ko: '프로필 목록에 표시'
	String get showProfileLabel => '프로필 목록에 표시';

	/// ko: '끄면 다른 사람이 나를 찾을 수 없습니다.'
	String get showProfileSubtitle => '끄면 다른 사람이 나를 찾을 수 없습니다.';

	/// ko: '프로필이 저장되었습니다!'
	String get saveSuccess => '프로필이 저장되었습니다!';

	/// ko: '프로필 저장에 실패했습니다:'
	String get saveFailed => '프로필 저장에 실패했습니다:';

	/// ko: '로그인이 필요합니다.'
	String get loginRequired => '로그인이 필요합니다.';

	/// ko: '근처에 친구 프로필이 없습니다.'
	String get noFriendsFound => '근처에 친구 프로필이 없습니다.';

	/// ko: '새로운 친구를 만나려면, 먼저 프로필을 만들어 주세요!'
	String get promptTitle => '새로운 친구를 만나려면,\n먼저 프로필을 만들어 주세요!';

	/// ko: '내 프로필 만들기'
	String get promptButton => '내 프로필 만들기';

	/// ko: '오늘 새 대화를 시작할 수 있는 한도({limit})에 도달했습니다.'
	String get chatLimitReached => '오늘 새 대화를 시작할 수 있는 한도({limit})에 도달했습니다.';

	/// ko: '확인 중...'
	String get chatChecking => '확인 중...';

	/// ko: '아직 표시할 프로필이 없습니다.'
	String get empty => '아직 표시할 프로필이 없습니다.';
}

// Path: interests
class TranslationsInterestsKo {
	TranslationsInterestsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '관심사'
	String get title => '관심사';

	/// ko: '최대 10개까지 선택할 수 있습니다.'
	String get limitInfo => '최대 10개까지 선택할 수 있습니다.';

	/// ko: '관심사는 최대 10개까지 선택 가능합니다.'
	String get limitReached => '관심사는 최대 10개까지 선택 가능합니다.';

	/// ko: '🎨 창의/예술'
	String get categoryCreative => '🎨 창의/예술';

	/// ko: '🏃 운동 & 활동'
	String get categorySports => '🏃 운동 & 활동';

	/// ko: '🍸 음식 & 음료'
	String get categoryFoodDrink => '🍸 음식 & 음료';

	/// ko: '🍿 엔터테인먼트'
	String get categoryEntertainment => '🍿 엔터테인먼트';

	/// ko: '📚 자기계발'
	String get categoryGrowth => '📚 자기계발';

	/// ko: '🌴 라이프스타일'
	String get categoryLifestyle => '🌴 라이프스타일';

	late final TranslationsInterestsItemsKo items = TranslationsInterestsItemsKo.internal(_root);
}

// Path: friendDetail
class TranslationsFriendDetailKo {
	TranslationsFriendDetailKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '친구 요청'
	String get request => '친구 요청';

	/// ko: '요청됨'
	String get requestSent => '요청됨';

	/// ko: '이미 친구입니다'
	String get alreadyFriends => '이미 친구입니다';

	/// ko: '요청에 실패했습니다:'
	String get requestFailed => '요청에 실패했습니다:';

	/// ko: '채팅을 시작할 수 없습니다.'
	String get chatError => '채팅을 시작할 수 없습니다.';

	/// ko: '채팅 시작'
	String get startChat => '채팅 시작';

	/// ko: '차단'
	String get block => '차단';

	/// ko: '신고'
	String get report => '신고';

	/// ko: '로그인이 필요합니다.'
	String get loginRequired => '로그인이 필요합니다.';

	/// ko: '차단이 해제되었습니다.'
	String get unblocked => '차단이 해제되었습니다.';

	/// ko: '사용자가 차단되었습니다.'
	String get blocked => '사용자가 차단되었습니다.';

	/// ko: '차단 해제'
	String get unblock => '차단 해제';
}

// Path: locationFilter
class TranslationsLocationFilterKo {
	TranslationsLocationFilterKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '위치 필터'
	String get title => '위치 필터';

	/// ko: '주(Provinsi)'
	String get provinsi => '주(Provinsi)';

	/// ko: '카부파텐(Kabupaten)'
	String get kabupaten => '카부파텐(Kabupaten)';

	/// ko: '코타(Kota)'
	String get kota => '코타(Kota)';

	/// ko: '케카마탄(Kecamatan)'
	String get kecamatan => '케카마탄(Kecamatan)';

	/// ko: 'Kelurahan'
	String get kelurahan => 'Kelurahan';

	/// ko: '필터 적용'
	String get apply => '필터 적용';

	/// ko: '전체'
	String get all => '전체';

	/// ko: '초기화'
	String get reset => '초기화';
}

// Path: clubs
class TranslationsClubsKo {
	TranslationsClubsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsClubsTabsKo tabs = TranslationsClubsTabsKo.internal(_root);
	late final TranslationsClubsSectionsKo sections = TranslationsClubsSectionsKo.internal(_root);
	late final TranslationsClubsScreenKo screen = TranslationsClubsScreenKo.internal(_root);
	late final TranslationsClubsPostListKo postList = TranslationsClubsPostListKo.internal(_root);
	late final TranslationsClubsMemberCardKo memberCard = TranslationsClubsMemberCardKo.internal(_root);
	late final TranslationsClubsPostCardKo postCard = TranslationsClubsPostCardKo.internal(_root);
	late final TranslationsClubsCardKo card = TranslationsClubsCardKo.internal(_root);
	late final TranslationsClubsPostDetailKo postDetail = TranslationsClubsPostDetailKo.internal(_root);
	late final TranslationsClubsDetailKo detail = TranslationsClubsDetailKo.internal(_root);
	late final TranslationsClubsMemberListKo memberList = TranslationsClubsMemberListKo.internal(_root);
	late final TranslationsClubsCreatePostKo createPost = TranslationsClubsCreatePostKo.internal(_root);
	late final TranslationsClubsCreateClubKo createClub = TranslationsClubsCreateClubKo.internal(_root);
	late final TranslationsClubsEditClubKo editClub = TranslationsClubsEditClubKo.internal(_root);
	late final TranslationsClubsCreateKo create = TranslationsClubsCreateKo.internal(_root);
	late final TranslationsClubsRepositoryKo repository = TranslationsClubsRepositoryKo.internal(_root);
	late final TranslationsClubsProposalKo proposal = TranslationsClubsProposalKo.internal(_root);

	/// ko: '표시할 클럽이 없습니다.'
	String get empty => '표시할 클럽이 없습니다.';
}

// Path: findfriend
class TranslationsFindfriendKo {
	TranslationsFindfriendKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsFindfriendFormKo form = TranslationsFindfriendFormKo.internal(_root);
}

// Path: auctions
class TranslationsAuctionsKo {
	TranslationsAuctionsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsAuctionsCardKo card = TranslationsAuctionsCardKo.internal(_root);
	late final TranslationsAuctionsErrorsKo errors = TranslationsAuctionsErrorsKo.internal(_root);

	/// ko: '등록된 경매가 없습니다.'
	String get empty => '등록된 경매가 없습니다.';

	late final TranslationsAuctionsFilterKo filter = TranslationsAuctionsFilterKo.internal(_root);
	late final TranslationsAuctionsCreateKo create = TranslationsAuctionsCreateKo.internal(_root);
	late final TranslationsAuctionsEditKo edit = TranslationsAuctionsEditKo.internal(_root);
	late final TranslationsAuctionsFormKo form = TranslationsAuctionsFormKo.internal(_root);
	late final TranslationsAuctionsDeleteKo delete = TranslationsAuctionsDeleteKo.internal(_root);
	late final TranslationsAuctionsDetailKo detail = TranslationsAuctionsDetailKo.internal(_root);
}

// Path: localStores
class TranslationsLocalStoresKo {
	TranslationsLocalStoresKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '근처 가게를 보려면 위치를 설정해 주세요.'
	String get setLocationPrompt => '근처 가게를 보려면 위치를 설정해 주세요.';

	/// ko: '아직 등록된 가게가 없습니다.'
	String get empty => '아직 등록된 가게가 없습니다.';

	/// ko: '오류가 발생했습니다: {error}'
	String get error => '오류가 발생했습니다: {error}';

	late final TranslationsLocalStoresCreateKo create = TranslationsLocalStoresCreateKo.internal(_root);
	late final TranslationsLocalStoresEditKo edit = TranslationsLocalStoresEditKo.internal(_root);
	late final TranslationsLocalStoresFormKo form = TranslationsLocalStoresFormKo.internal(_root);
	late final TranslationsLocalStoresCategoriesKo categories = TranslationsLocalStoresCategoriesKo.internal(_root);
	late final TranslationsLocalStoresDetailKo detail = TranslationsLocalStoresDetailKo.internal(_root);

	/// ko: '위치 정보 없음'
	String get noLocation => '위치 정보 없음';
}

// Path: pom
class TranslationsPomKo {
	TranslationsPomKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: 'POM'
	String get title => 'POM';

	late final TranslationsPomSearchKo search = TranslationsPomSearchKo.internal(_root);
	late final TranslationsPomTabsKo tabs = TranslationsPomTabsKo.internal(_root);

	/// ko: '더 보기'
	String get more => '더 보기';

	/// ko: '접기'
	String get less => '접기';

	/// ko: '{}개의 좋아요'
	String get likesCount => '{}개의 좋아요';

	/// ko: '{} 신고'
	String get report => '{} 신고';

	/// ko: '{} 차단'
	String get block => '{} 차단';

	/// ko: '아직 인기 POM이 없습니다.'
	String get emptyPopular => '아직 인기 POM이 없습니다.';

	/// ko: '아직 업로드한 POM이 없습니다.'
	String get emptyMine => '아직 업로드한 POM이 없습니다.';

	/// ko: '최신 POM을 보려면 '전체' 탭을 확인하세요.'
	String get emptyHintPopular => '최신 POM을 보려면 \'전체\' 탭을 확인하세요.';

	/// ko: '+ 버튼을 눌러 첫 POM을 업로드하세요.'
	String get emptyCtaMine => '+ 버튼을 눌러 첫 POM을 업로드하세요.';

	/// ko: '공유'
	String get share => '공유';

	/// ko: '등록된 POM이 없습니다.'
	String get empty => '등록된 POM이 없습니다.';

	late final TranslationsPomErrorsKo errors = TranslationsPomErrorsKo.internal(_root);
	late final TranslationsPomCommentsKo comments = TranslationsPomCommentsKo.internal(_root);
	late final TranslationsPomCreateKo create = TranslationsPomCreateKo.internal(_root);
}

// Path: realEstate
class TranslationsRealEstateKo {
	TranslationsRealEstateKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '부동산'
	String get title => '부동산';

	late final TranslationsRealEstateTabsKo tabs = TranslationsRealEstateTabsKo.internal(_root);

	/// ko: '근처 매물을 보려면 위치를 설정해 주세요.'
	String get setLocationPrompt => '근처 매물을 보려면 위치를 설정해 주세요.';

	/// ko: '등록된 매물이 없습니다.'
	String get empty => '등록된 매물이 없습니다.';

	/// ko: '오류가 발생했습니다: {error}'
	String get error => '오류가 발생했습니다: {error}';

	late final TranslationsRealEstateCreateKo create = TranslationsRealEstateCreateKo.internal(_root);
	late final TranslationsRealEstateEditKo edit = TranslationsRealEstateEditKo.internal(_root);
	late final TranslationsRealEstateFormKo form = TranslationsRealEstateFormKo.internal(_root);
	late final TranslationsRealEstateCategoriesKo categories = TranslationsRealEstateCategoriesKo.internal(_root);
	late final TranslationsRealEstateDetailKo detail = TranslationsRealEstateDetailKo.internal(_root);
}

// Path: lostAndFound
class TranslationsLostAndFoundKo {
	TranslationsLostAndFoundKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '분실 · 습득'
	String get title => '분실 · 습득';

	late final TranslationsLostAndFoundTabsKo tabs = TranslationsLostAndFoundTabsKo.internal(_root);

	/// ko: '등록된 글이 없습니다.'
	String get empty => '등록된 글이 없습니다.';

	/// ko: '근처 신고를 보려면 위치를 설정해 주세요.'
	String get setLocationPrompt => '근처 신고를 보려면 위치를 설정해 주세요.';

	late final TranslationsLostAndFoundCreateKo create = TranslationsLostAndFoundCreateKo.internal(_root);
	late final TranslationsLostAndFoundEditKo edit = TranslationsLostAndFoundEditKo.internal(_root);
	late final TranslationsLostAndFoundFormKo form = TranslationsLostAndFoundFormKo.internal(_root);
	late final TranslationsLostAndFoundCategoriesKo categories = TranslationsLostAndFoundCategoriesKo.internal(_root);
	late final TranslationsLostAndFoundDetailKo detail = TranslationsLostAndFoundDetailKo.internal(_root);
}

// Path: community
class TranslationsCommunityKo {
	TranslationsCommunityKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '커뮤니티'
	String get title => '커뮤니티';

	/// ko: '아직 게시물이 없습니다.'
	String get empty => '아직 게시물이 없습니다.';

	/// ko: '오류가 발생했습니다: {error}'
	String get error => '오류가 발생했습니다: {error}';

	late final TranslationsCommunityCreateKo create = TranslationsCommunityCreateKo.internal(_root);
	late final TranslationsCommunityEditKo edit = TranslationsCommunityEditKo.internal(_root);
	late final TranslationsCommunityPostKo post = TranslationsCommunityPostKo.internal(_root);
}

// Path: shared
class TranslationsSharedKo {
	TranslationsSharedKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsSharedTagInputKo tagInput = TranslationsSharedTagInputKo.internal(_root);
}

// Path: linkPreview
class TranslationsLinkPreviewKo {
	TranslationsLinkPreviewKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '미리보기를 불러올 수 없습니다'
	String get errorTitle => '미리보기를 불러올 수 없습니다';

	/// ko: '링크를 다시 확인하시거나 나중에 다시 시도해 주세요.'
	String get errorBody => '링크를 다시 확인하시거나 나중에 다시 시도해 주세요.';
}

// Path: localNewsTagResult
class TranslationsLocalNewsTagResultKo {
	TranslationsLocalNewsTagResultKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '검색 중 오류가 발생했습니다: {error}'
	String get error => '검색 중 오류가 발생했습니다: {error}';

	/// ko: ''#{tag}' 태그로 작성된 글이 없습니다.'
	String get empty => '\'#{tag}\' 태그로 작성된 글이 없습니다.';
}

// Path: admin
class TranslationsAdminKo {
	TranslationsAdminKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsAdminScreenKo screen = TranslationsAdminScreenKo.internal(_root);
	late final TranslationsAdminMenuKo menu = TranslationsAdminMenuKo.internal(_root);
	late final TranslationsAdminAiApprovalKo aiApproval = TranslationsAdminAiApprovalKo.internal(_root);
	late final TranslationsAdminReportsKo reports = TranslationsAdminReportsKo.internal(_root);
	late final TranslationsAdminReportListKo reportList = TranslationsAdminReportListKo.internal(_root);
	late final TranslationsAdminReportDetailKo reportDetail = TranslationsAdminReportDetailKo.internal(_root);
}

// Path: tags
class TranslationsTagsKo {
	TranslationsTagsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsTagsLocalNewsKo localNews = TranslationsTagsLocalNewsKo.internal(_root);
}

// Path: boards
class TranslationsBoardsKo {
	TranslationsBoardsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsBoardsPopupKo popup = TranslationsBoardsPopupKo.internal(_root);

	/// ko: '게시판'
	String get defaultTitle => '게시판';

	/// ko: '동네 채팅방이 곧 오픈됩니다'
	String get chatRoomComingSoon => '동네 채팅방이 곧 오픈됩니다';

	/// ko: '채팅방'
	String get chatRoomTitle => '채팅방';

	/// ko: '아직 게시글이 없습니다.'
	String get emptyFeed => '아직 게시글이 없습니다.';

	/// ko: '채팅방이 생성되었습니다.'
	String get chatRoomCreated => '채팅방이 생성되었습니다.';
}

// Path: signup
class TranslationsSignupKo {
	TranslationsSignupKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsSignupAlertsKo alerts = TranslationsSignupAlertsKo.internal(_root);

	/// ko: '회원가입'
	String get title => '회원가입';

	/// ko: '우리 동네 커뮤니티에 함께하세요!'
	String get subtitle => '우리 동네 커뮤니티에 함께하세요!';

	/// ko: '닉네임'
	String get nicknameHint => '닉네임';

	/// ko: '이메일 주소'
	String get emailHint => '이메일 주소';

	/// ko: '비밀번호'
	String get passwordHint => '비밀번호';

	/// ko: '비밀번호 확인'
	String get passwordConfirmHint => '비밀번호 확인';

	/// ko: '동네 위치'
	String get locationHint => '동네 위치';

	/// ko: '내 위치는 동네 글을 보여주는 데만 사용되며 다른 사람에게 공개되지 않습니다.'
	String get locationNotice => '내 위치는 동네 글을 보여주는 데만 사용되며 다른 사람에게 공개되지 않습니다.';

	late final TranslationsSignupButtonsKo buttons = TranslationsSignupButtonsKo.internal(_root);
}

// Path: user
class TranslationsUserKo {
	TranslationsUserKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '로그인되지 않았습니다.'
	String get notLoggedIn => '로그인되지 않았습니다.';
}

// Path: login.buttons
class TranslationsLoginButtonsKo {
	TranslationsLoginButtonsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '로그인'
	String get login => '로그인';

	/// ko: 'Google로 계속'
	String get google => 'Google로 계속';

	/// ko: 'Apple로 계속'
	String get apple => 'Apple로 계속';
}

// Path: login.links
class TranslationsLoginLinksKo {
	TranslationsLoginLinksKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '비밀번호 찾기'
	String get findPassword => '비밀번호 찾기';

	/// ko: '계정이 없나요?'
	String get askForAccount => '계정이 없나요?';

	/// ko: '회원가입'
	String get signUp => '회원가입';
}

// Path: login.alerts
class TranslationsLoginAlertsKo {
	TranslationsLoginAlertsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '잘못된 이메일 형식입니다.'
	String get invalidEmail => '잘못된 이메일 형식입니다.';

	/// ko: '사용자를 찾을 수 없거나 비밀번호가 틀렸습니다.'
	String get userNotFound => '사용자를 찾을 수 없거나 비밀번호가 틀렸습니다.';

	/// ko: '비밀번호가 틀렸습니다.'
	String get wrongPassword => '비밀번호가 틀렸습니다.';

	/// ko: '오류가 발생했습니다. 다시 시도해 주세요.'
	String get unknownError => '오류가 발생했습니다. 다시 시도해 주세요.';
}

// Path: main.appBar
class TranslationsMainAppBarKo {
	TranslationsMainAppBarKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '위치 미설정'
	String get locationNotSet => '위치 미설정';

	/// ko: '위치 오류'
	String get locationError => '위치 오류';

	/// ko: '불러오는 중...'
	String get locationLoading => '불러오는 중...';
}

// Path: main.tabs
class TranslationsMainTabsKo {
	TranslationsMainTabsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '새 글'
	String get newFeed => '새 글';

	/// ko: '동네 소식'
	String get localNews => '동네 소식';

	/// ko: '중고거래'
	String get marketplace => '중고거래';

	/// ko: '친구찾기'
	String get findFriends => '친구찾기';

	/// ko: '모임'
	String get clubs => '모임';

	/// ko: '일자리'
	String get jobs => '일자리';

	/// ko: '동네가게'
	String get localStores => '동네가게';

	/// ko: '경매'
	String get auction => '경매';

	/// ko: 'POM'
	String get pom => 'POM';

	/// ko: '분실·습득'
	String get lostAndFound => '분실·습득';

	/// ko: '부동산'
	String get realEstate => '부동산';
}

// Path: main.bottomNav
class TranslationsMainBottomNavKo {
	TranslationsMainBottomNavKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '홈'
	String get home => '홈';

	/// ko: '동네게시판'
	String get board => '동네게시판';

	/// ko: '검색'
	String get search => '검색';

	/// ko: '채팅'
	String get chat => '채팅';

	/// ko: '내 블링'
	String get myBling => '내 블링';
}

// Path: main.errors
class TranslationsMainErrorsKo {
	TranslationsMainErrorsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '로그인이 필요합니다.'
	String get loginRequired => '로그인이 필요합니다.';

	/// ko: '사용자를 찾을 수 없습니다.'
	String get userNotFound => '사용자를 찾을 수 없습니다.';

	/// ko: '오류가 발생했습니다.'
	String get unknown => '오류가 발생했습니다.';
}

// Path: main.mapView
class TranslationsMainMapViewKo {
	TranslationsMainMapViewKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '지도 보기'
	String get showMap => '지도 보기';

	/// ko: '목록 보기'
	String get showList => '목록 보기';
}

// Path: main.search
class TranslationsMainSearchKo {
	TranslationsMainSearchKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '검색'
	String get placeholder => '검색';

	/// ko: '이웃, 소식, 중고거래, 일자리 검색…'
	String get chipPlaceholder => '이웃, 소식, 중고거래, 일자리 검색…';

	late final TranslationsMainSearchHintKo hint = TranslationsMainSearchHintKo.internal(_root);
}

// Path: search.empty
class TranslationsSearchEmptyKo {
	TranslationsSearchEmptyKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: ''{keyword}' 검색 결과가 없습니다.'
	String get message => '\'{keyword}\' 검색 결과가 없습니다.';

	/// ko: '철자를 확인하거나 다른 검색어로 시도해 주세요.'
	String get checkSpelling => '철자를 확인하거나 다른 검색어로 시도해 주세요.';

	/// ko: '전국 검색'
	String get expandToNational => '전국 검색';
}

// Path: search.sheet
class TranslationsSearchSheetKo {
	TranslationsSearchSheetKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '동네 소식 검색'
	String get localNews => '동네 소식 검색';

	/// ko: '제목·내용·태그로 검색'
	String get localNewsDesc => '제목·내용·태그로 검색';

	/// ko: '일자리 검색'
	String get jobs => '일자리 검색';

	/// ko: '직무·회사·태그로 검색'
	String get jobsDesc => '직무·회사·태그로 검색';

	/// ko: '분실·습득 검색'
	String get lostAndFound => '분실·습득 검색';

	/// ko: '물건 이름·장소로 검색'
	String get lostAndFoundDesc => '물건 이름·장소로 검색';

	/// ko: '중고거래 검색'
	String get marketplace => '중고거래 검색';

	/// ko: '상품명·카테고리·태그 검색'
	String get marketplaceDesc => '상품명·카테고리·태그 검색';

	/// ko: '동네 가게 검색'
	String get localStores => '동네 가게 검색';

	/// ko: '가게명·업종·키워드 검색'
	String get localStoresDesc => '가게명·업종·키워드 검색';

	/// ko: '모임 검색'
	String get clubs => '모임 검색';

	/// ko: '모임명·관심사 검색'
	String get clubsDesc => '모임명·관심사 검색';

	/// ko: '친구찾기 검색'
	String get findFriends => '친구찾기 검색';

	/// ko: '닉네임·관심사 검색'
	String get findFriendsDesc => '닉네임·관심사 검색';

	/// ko: '부동산 검색'
	String get realEstate => '부동산 검색';

	/// ko: '제목·지역·태그 검색'
	String get realEstateDesc => '제목·지역·태그 검색';

	/// ko: '경매 검색'
	String get auction => '경매 검색';

	/// ko: '상품명·태그 검색'
	String get auctionDesc => '상품명·태그 검색';

	/// ko: 'POM 검색'
	String get pom => 'POM 검색';

	/// ko: '제목·해시태그 검색'
	String get pomDesc => '제목·해시태그 검색';

	/// ko: '준비 중'
	String get comingSoon => '준비 중';
}

// Path: drawer.trustDashboard
class TranslationsDrawerTrustDashboardKo {
	TranslationsDrawerTrustDashboardKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '신뢰 인증 현황'
	String get title => '신뢰 인증 현황';

	/// ko: '동네 인증(케루라한)'
	String get kelurahanAuth => '동네 인증(케루라한)';

	/// ko: '상세 주소 인증(RT/RW)'
	String get rtRwAuth => '상세 주소 인증(RT/RW)';

	/// ko: '전화 인증'
	String get phoneAuth => '전화 인증';

	/// ko: '프로필 완료'
	String get profileComplete => '프로필 완료';

	/// ko: '피드 감사'
	String get feedThanks => '피드 감사';

	/// ko: '중고거래 감사'
	String get marketThanks => '중고거래 감사';

	/// ko: '신고'
	String get reports => '신고';

	/// ko: '자세히'
	String get breakdownButton => '자세히';

	/// ko: '신뢰 점수 내역'
	String get breakdownModalTitle => '신뢰 점수 내역';

	/// ko: '확인'
	String get breakdownClose => '확인';

	late final TranslationsDrawerTrustDashboardBreakdownKo breakdown = TranslationsDrawerTrustDashboardBreakdownKo.internal(_root);
}

// Path: marketplace.registration
class TranslationsMarketplaceRegistrationKo {
	TranslationsMarketplaceRegistrationKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '새 상품 등록'
	String get title => '새 상품 등록';

	/// ko: '저장'
	String get done => '저장';

	/// ko: '상품명'
	String get titleHint => '상품명';

	/// ko: '가격 (Rp)'
	String get priceHint => '가격 (Rp)';

	/// ko: '가격 제안 허용'
	String get negotiable => '가격 제안 허용';

	/// ko: '동네'
	String get addressHint => '동네';

	/// ko: '만날 장소'
	String get addressDetailHint => '만날 장소';

	/// ko: '상세 설명'
	String get descriptionHint => '상세 설명';

	/// ko: '등록 완료!'
	String get success => '등록 완료!';

	/// ko: '태그 추가 (스페이스로 확정)'
	String get tagsHint => '태그 추가 (스페이스로 확정)';

	/// ko: '실패'
	String get fail => '실패';
}

// Path: marketplace.edit
class TranslationsMarketplaceEditKo {
	TranslationsMarketplaceEditKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '게시글 수정'
	String get title => '게시글 수정';

	/// ko: '수정 완료'
	String get done => '수정 완료';

	/// ko: '상품명 수정'
	String get titleHint => '상품명 수정';

	/// ko: '위치 수정'
	String get addressHint => '위치 수정';

	/// ko: '가격 수정 (Rp)'
	String get priceHint => '가격 수정 (Rp)';

	/// ko: '가격 제안 수정'
	String get negotiable => '가격 제안 수정';

	/// ko: '설명 수정'
	String get descriptionHint => '설명 수정';

	/// ko: '태그 추가 (스페이스로 확정)'
	String get tagsHint => '태그 추가 (스페이스로 확정)';

	/// ko: '상품이 성공적으로 수정되었습니다.'
	String get success => '상품이 성공적으로 수정되었습니다.';

	/// ko: '상품 수정에 실패했습니다: {error}'
	String get fail => '상품 수정에 실패했습니다: {error}';

	/// ko: '위치 초기화'
	String get resetLocation => '위치 초기화';

	/// ko: '변경사항 저장'
	String get save => '변경사항 저장';
}

// Path: marketplace.detail
class TranslationsMarketplaceDetailKo {
	TranslationsMarketplaceDetailKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '가격 제안하기'
	String get makeOffer => '가격 제안하기';

	/// ko: '고정가'
	String get fixedPrice => '고정가';

	/// ko: '상품 설명'
	String get description => '상품 설명';

	/// ko: '판매자 정보'
	String get sellerInfo => '판매자 정보';

	/// ko: '채팅'
	String get chat => '채팅';

	/// ko: '관심 상품'
	String get favorite => '관심 상품';

	/// ko: '관심 해제'
	String get unfavorite => '관심 해제';

	/// ko: '공유'
	String get share => '공유';

	/// ko: '수정'
	String get edit => '수정';

	/// ko: '삭제'
	String get delete => '삭제';

	/// ko: '카테고리'
	String get category => '카테고리';

	/// ko: '카테고리: -'
	String get categoryError => '카테고리: -';

	/// ko: '카테고리 없음'
	String get categoryNone => '카테고리 없음';

	/// ko: '조회'
	String get views => '조회';

	/// ko: '좋아요'
	String get likes => '좋아요';

	/// ko: '채팅'
	String get chats => '채팅';

	/// ko: '판매자 정보를 찾을 수 없습니다.'
	String get noSeller => '판매자 정보를 찾을 수 없습니다.';

	/// ko: '위치 정보를 찾을 수 없습니다.'
	String get noLocation => '위치 정보를 찾을 수 없습니다.';

	/// ko: '판매자'
	String get seller => '판매자';

	/// ko: '거래 장소'
	String get dealLocation => '거래 장소';
}

// Path: marketplace.dialog
class TranslationsMarketplaceDialogKo {
	TranslationsMarketplaceDialogKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '게시글 삭제'
	String get deleteTitle => '게시글 삭제';

	/// ko: '이 게시글을 정말 삭제하시겠습니까? 삭제 후에는 되돌릴 수 없습니다.'
	String get deleteContent => '이 게시글을 정말 삭제하시겠습니까? 삭제 후에는 되돌릴 수 없습니다.';

	/// ko: '취소'
	String get cancel => '취소';

	/// ko: '삭제'
	String get deleteConfirm => '삭제';

	/// ko: '게시글이 삭제되었습니다.'
	String get deleteSuccess => '게시글이 삭제되었습니다.';

	/// ko: '닫기'
	String get close => '닫기';
}

// Path: marketplace.errors
class TranslationsMarketplaceErrorsKo {
	TranslationsMarketplaceErrorsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '게시글 삭제에 실패했습니다: {error}'
	String get deleteError => '게시글 삭제에 실패했습니다: {error}';

	/// ko: '필수 입력 항목입니다.'
	String get requiredField => '필수 입력 항목입니다.';

	/// ko: '사진을 최소 1장 이상 추가해 주세요.'
	String get noPhoto => '사진을 최소 1장 이상 추가해 주세요.';

	/// ko: '카테고리를 선택해 주세요.'
	String get noCategory => '카테고리를 선택해 주세요.';

	/// ko: '로그인이 필요합니다.'
	String get loginRequired => '로그인이 필요합니다.';

	/// ko: '사용자 정보를 찾을 수 없습니다.'
	String get userNotFound => '사용자 정보를 찾을 수 없습니다.';
}

// Path: marketplace.condition
class TranslationsMarketplaceConditionKo {
	TranslationsMarketplaceConditionKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '상품 상태'
	String get label => '상품 상태';

	/// ko: '새 상품'
	String get kNew => '새 상품';

	/// ko: '중고'
	String get used => '중고';
}

// Path: marketplace.reservation
class TranslationsMarketplaceReservationKo {
	TranslationsMarketplaceReservationKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '10% 예약금 결제'
	String get title => '10% 예약금 결제';

	/// ko: 'AI 인증 상품을 예약하려면 {amount}의 10% 예약금을 먼저 결제해야 합니다. 현장 검증 후 거래가 취소되면 예약금은 환불됩니다.'
	String get content => 'AI 인증 상품을 예약하려면 {amount}의 10% 예약금을 먼저 결제해야 합니다. 현장 검증 후 거래가 취소되면 예약금은 환불됩니다.';

	/// ko: '결제 후 예약하기'
	String get confirm => '결제 후 예약하기';

	/// ko: 'AI 보증으로 예약하기'
	String get button => 'AI 보증으로 예약하기';

	/// ko: '예약이 완료되었습니다. 판매자와 일정을 조율해 주세요.'
	String get success => '예약이 완료되었습니다. 판매자와 일정을 조율해 주세요.';
}

// Path: marketplace.status
class TranslationsMarketplaceStatusKo {
	TranslationsMarketplaceStatusKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '예약됨'
	String get reserved => '예약됨';

	/// ko: '판매 완료'
	String get sold => '판매 완료';
}

// Path: marketplace.ai
class TranslationsMarketplaceAiKo {
	TranslationsMarketplaceAiKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: 'AI 인증 취소'
	String get cancelConfirm => 'AI 인증 취소';

	/// ko: 'AI 인증은 상품당 한 번만 취소할 수 있습니다. 다시 요청할 경우 비용이 발생할 수 있습니다.'
	String get cancelLimit => 'AI 인증은 상품당 한 번만 취소할 수 있습니다. 다시 요청할 경우 비용이 발생할 수 있습니다.';

	/// ko: '비용이 발생할 수 있음을 이해했습니다.'
	String get cancelAckCharge => '비용이 발생할 수 있음을 이해했습니다.';

	/// ko: 'AI 인증이 취소되었습니다. 이제 일반 상품으로 전환되었습니다.'
	String get cancelSuccess => 'AI 인증이 취소되었습니다. 이제 일반 상품으로 전환되었습니다.';

	/// ko: 'AI 인증 취소 중 오류가 발생했습니다: {0}'
	String get cancelError => 'AI 인증 취소 중 오류가 발생했습니다: {0}';
}

// Path: marketplace.takeover
class TranslationsMarketplaceTakeoverKo {
	TranslationsMarketplaceTakeoverKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '현장 수령 및 검증'
	String get button => '현장 수령 및 검증';

	/// ko: 'AI 현장 검증'
	String get title => 'AI 현장 검증';

	late final TranslationsMarketplaceTakeoverGuideKo guide = TranslationsMarketplaceTakeoverGuideKo.internal(_root);

	/// ko: '현장에서 사진 찍기'
	String get photoTitle => '현장에서 사진 찍기';

	/// ko: 'AI 유사도 검증 시작'
	String get buttonVerify => 'AI 유사도 검증 시작';

	late final TranslationsMarketplaceTakeoverErrorsKo errors = TranslationsMarketplaceTakeoverErrorsKo.internal(_root);
	late final TranslationsMarketplaceTakeoverDialogKo dialog = TranslationsMarketplaceTakeoverDialogKo.internal(_root);
	late final TranslationsMarketplaceTakeoverSuccessKo success = TranslationsMarketplaceTakeoverSuccessKo.internal(_root);
}

// Path: aiFlow.common
class TranslationsAiFlowCommonKo {
	TranslationsAiFlowCommonKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '오류가 발생했습니다: {error}'
	String get error => '오류가 발생했습니다: {error}';

	/// ko: '사진 추가'
	String get addPhoto => '사진 추가';

	/// ko: '건너뛰기'
	String get skip => '건너뛰기';

	/// ko: '사진이 추가되었습니다: {}'
	String get addedPhoto => '사진이 추가되었습니다: {}';

	/// ko: '건너뜀'
	String get skipped => '건너뜀';
}

// Path: aiFlow.cta
class TranslationsAiFlowCtaKo {
	TranslationsAiFlowCtaKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '🤖 AI 인증으로 신뢰도 높이기 (선택)'
	String get title => '🤖 AI 인증으로 신뢰도 높이기 (선택)';

	/// ko: 'AI 인증 뱃지를 얻으면 구매자 신뢰가 올라가고 더 빨리 팔릴 수 있어요. 시작하기 전에 상품 정보를 모두 입력해 주세요.'
	String get subtitle => 'AI 인증 뱃지를 얻으면 구매자 신뢰가 올라가고 더 빨리 팔릴 수 있어요. 시작하기 전에 상품 정보를 모두 입력해 주세요.';

	/// ko: 'AI 인증 시작하기'
	String get startButton => 'AI 인증 시작하기';

	/// ko: '상품명, 카테고리, 최소 1장의 이미지를 먼저 입력해 주세요.'
	String get missingRequiredFields => '상품명, 카테고리, 최소 1장의 이미지를 먼저 입력해 주세요.';
}

// Path: aiFlow.categorySelection
class TranslationsAiFlowCategorySelectionKo {
	TranslationsAiFlowCategorySelectionKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: 'AI 인증: 카테고리 선택'
	String get title => 'AI 인증: 카테고리 선택';

	/// ko: '카테고리를 불러오지 못했습니다.'
	String get error => '카테고리를 불러오지 못했습니다.';

	/// ko: 'AI 인증 가능한 카테고리가 없습니다.'
	String get noCategories => 'AI 인증 가능한 카테고리가 없습니다.';
}

// Path: aiFlow.galleryUpload
class TranslationsAiFlowGalleryUploadKo {
	TranslationsAiFlowGalleryUploadKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: 'AI 인증: 사진 선택'
	String get title => 'AI 인증: 사진 선택';

	/// ko: 'AI 인증을 위해 최소 {count}장의 사진을 올려 주세요.'
	String get guide => 'AI 인증을 위해 최소 {count}장의 사진을 올려 주세요.';

	/// ko: '사진을 최소 {count}장 선택해야 합니다.'
	String get minPhotoError => '사진을 최소 {count}장 선택해야 합니다.';

	/// ko: 'AI 분석 요청'
	String get nextButton => 'AI 분석 요청';
}

// Path: aiFlow.prediction
class TranslationsAiFlowPredictionKo {
	TranslationsAiFlowPredictionKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: 'AI 분석 결과'
	String get title => 'AI 분석 결과';

	/// ko: 'AI가 예측한 상품명입니다.'
	String get guide => 'AI가 예측한 상품명입니다.';

	/// ko: '상품명 수정'
	String get editLabel => '상품명 수정';

	/// ko: '직접 수정'
	String get editButton => '직접 수정';

	/// ko: '변경 저장'
	String get saveButton => '변경 저장';

	/// ko: '상품명이 없습니다.'
	String get noName => '상품명이 없습니다.';

	/// ko: '상품을 인식하지 못했습니다. 다시 시도해 주세요.'
	String get error => '상품을 인식하지 못했습니다. 다시 시도해 주세요.';

	/// ko: '사용자 인증 정보가 없습니다. 분석을 시작할 수 없습니다.'
	String get authError => '사용자 인증 정보가 없습니다. 분석을 시작할 수 없습니다.';

	/// ko: '이 상품명이 맞나요?'
	String get question => '이 상품명이 맞나요?';

	/// ko: '네, 맞아요'
	String get confirmButton => '네, 맞아요';

	/// ko: '아니요, 다시 수정'
	String get rejectButton => '아니요, 다시 수정';

	/// ko: '분석 중 오류가 발생했습니다.'
	String get analysisError => '분석 중 오류가 발생했습니다.';

	/// ko: '다시 시도'
	String get retryButton => '다시 시도';

	/// ko: '뒤로'
	String get backButton => '뒤로';
}

// Path: aiFlow.guidedCamera
class TranslationsAiFlowGuidedCameraKo {
	TranslationsAiFlowGuidedCameraKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: 'AI 가이드: 부족한 증거 사진'
	String get title => 'AI 가이드: 부족한 증거 사진';

	/// ko: '신뢰도를 높이기 위해 아래 항목에 맞는 추가 사진을 찍어 주세요.'
	String get guide => '신뢰도를 높이기 위해 아래 항목에 맞는 추가 사진을 찍어 주세요.';

	/// ko: '사진 위치가 현재 위치와 다릅니다. 같은 장소에서 다시 촬영해 주세요.'
	String get locationMismatchError => '사진 위치가 현재 위치와 다릅니다. 같은 장소에서 다시 촬영해 주세요.';

	/// ko: '위치 권한이 거부되었습니다. 설정에서 위치 권한을 허용해 주세요.'
	String get locationPermissionError => '위치 권한이 거부되었습니다. 설정에서 위치 권한을 허용해 주세요.';

	/// ko: '사진에 위치 정보가 없습니다. 카메라 설정에서 위치 태그를 켜 주세요.'
	String get noLocationDataError => '사진에 위치 정보가 없습니다. 카메라 설정에서 위치 태그를 켜 주세요.';

	/// ko: '최종 보고서 생성'
	String get nextButton => '최종 보고서 생성';
}

// Path: aiFlow.finalReport
class TranslationsAiFlowFinalReportKo {
	TranslationsAiFlowFinalReportKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: 'AI 인증 보고서'
	String get title => 'AI 인증 보고서';

	/// ko: 'AI가 작성한 초안 기반으로 상품 정보를 정리했습니다. 내용을 수정한 뒤 등록을 마무리해 주세요.'
	String get guide => 'AI가 작성한 초안 기반으로 상품 정보를 정리했습니다. 내용을 수정한 뒤 등록을 마무리해 주세요.';

	/// ko: 'AI가 최종 보고서를 생성하는 중입니다...'
	String get loading => 'AI가 최종 보고서를 생성하는 중입니다...';

	/// ko: '보고서 생성에 실패했습니다.'
	String get error => '보고서 생성에 실패했습니다.';

	/// ko: '최종 보고서가 생성되었습니다.'
	String get success => '최종 보고서가 생성되었습니다.';

	/// ko: '판매 등록 완료'
	String get submitButton => '판매 등록 완료';

	/// ko: 'AI 추천 가격 ({})'
	String get suggestedPrice => 'AI 추천 가격 ({})';

	/// ko: '인증 요약'
	String get summary => '인증 요약';

	/// ko: '구매자 안내 (AI)'
	String get buyerNotes => '구매자 안내 (AI)';

	/// ko: '핵심 스펙'
	String get keySpecs => '핵심 스펙';

	/// ko: '상태 점검'
	String get condition => '상태 점검';

	/// ko: '구성품(쉼표로 구분)'
	String get includedItems => '구성품(쉼표로 구분)';

	/// ko: '최종 설명'
	String get finalDescription => '최종 설명';

	/// ko: 'AI 제안을 설명에 반영'
	String get applySuggestions => 'AI 제안을 설명에 반영';

	/// ko: '구성품'
	String get includedItemsLabel => '구성품';

	/// ko: '구매자 안내'
	String get buyerNotesLabel => '구매자 안내';

	/// ko: '건너뛴 증거 항목'
	String get skippedItems => '건너뛴 증거 항목';

	/// ko: '최종 보고서 생성에 실패했습니다: {error}'
	String get fail => '최종 보고서 생성에 실패했습니다: {error}';
}

// Path: aiFlow.evidence
class TranslationsAiFlowEvidenceKo {
	TranslationsAiFlowEvidenceKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '모든 추천 샷이 필요합니다.'
	String get allShotsRequired => '모든 추천 샷이 필요합니다.';

	/// ko: '증거 사진'
	String get title => '증거 사진';

	/// ko: '증거 제출'
	String get submitButton => '증거 제출';
}

// Path: aiFlow.error
class TranslationsAiFlowErrorKo {
	TranslationsAiFlowErrorKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: 'AI 보고서 생성에 실패했습니다: {error}'
	String get reportGeneration => 'AI 보고서 생성에 실패했습니다: {error}';
}

// Path: myBling.stats
class TranslationsMyBlingStatsKo {
	TranslationsMyBlingStatsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '게시글'
	String get posts => '게시글';

	/// ko: '팔로워'
	String get followers => '팔로워';

	/// ko: '이웃'
	String get neighbors => '이웃';

	/// ko: '친구'
	String get friends => '친구';
}

// Path: myBling.tabs
class TranslationsMyBlingTabsKo {
	TranslationsMyBlingTabsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '내 게시글'
	String get posts => '내 게시글';

	/// ko: '내 상품'
	String get products => '내 상품';

	/// ko: '북마크'
	String get bookmarks => '북마크';

	/// ko: '친구'
	String get friends => '친구';
}

// Path: profileView.tabs
class TranslationsProfileViewTabsKo {
	TranslationsProfileViewTabsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '게시글'
	String get posts => '게시글';

	/// ko: '관심사'
	String get interests => '관심사';
}

// Path: settings.notifications
class TranslationsSettingsNotificationsKo {
	TranslationsSettingsNotificationsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '알림 설정을 불러오지 못했습니다.'
	String get loadError => '알림 설정을 불러오지 못했습니다.';

	/// ko: '알림 설정이 저장되었습니다.'
	String get saveSuccess => '알림 설정이 저장되었습니다.';

	/// ko: '알림 설정 저장에 실패했습니다.'
	String get saveError => '알림 설정 저장에 실패했습니다.';

	/// ko: '알림 범위'
	String get scopeTitle => '알림 범위';

	/// ko: '알림을 받을 범위를 선택하세요 (내 동네만, 인근 지역 등).'
	String get scopeDescription => '알림을 받을 범위를 선택하세요 (내 동네만, 인근 지역 등).';

	/// ko: '알림 범위'
	String get scopeLabel => '알림 범위';

	/// ko: '알림 주제'
	String get tagsTitle => '알림 주제';

	/// ko: '어떤 주제의 알림을 받을지 선택하세요 (소식, 일자리, 중고거래 등).'
	String get tagsDescription => '어떤 주제의 알림을 받을지 선택하세요 (소식, 일자리, 중고거래 등).';
}

// Path: friendRequests.tooltip
class TranslationsFriendRequestsTooltipKo {
	TranslationsFriendRequestsTooltipKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '수락'
	String get accept => '수락';

	/// ko: '거절'
	String get reject => '거절';
}

// Path: sentFriendRequests.status
class TranslationsSentFriendRequestsStatusKo {
	TranslationsSentFriendRequestsStatusKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '대기 중'
	String get pending => '대기 중';

	/// ko: '수락됨'
	String get accepted => '수락됨';

	/// ko: '거절됨'
	String get rejected => '거절됨';
}

// Path: blockedUsers.unblockDialog
class TranslationsBlockedUsersUnblockDialogKo {
	TranslationsBlockedUsersUnblockDialogKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '{nickname} 님의 차단을 해제할까요?'
	String get title => '{nickname} 님의 차단을 해제할까요?';

	/// ko: '차단을 해제하면 이 사용자가 다시 친구찾기 목록에 나타날 수 있습니다.'
	String get content => '차단을 해제하면 이 사용자가 다시 친구찾기 목록에 나타날 수 있습니다.';
}

// Path: rejectedUsers.unrejectDialog
class TranslationsRejectedUsersUnrejectDialogKo {
	TranslationsRejectedUsersUnrejectDialogKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '{nickname} 님에 대한 거절을 취소할까요?'
	String get title => '{nickname} 님에 대한 거절을 취소할까요?';

	/// ko: '거절을 취소하면 상대방의 친구찾기 목록에 다시 나타날 수 있습니다.'
	String get content => '거절을 취소하면 상대방의 친구찾기 목록에 다시 나타날 수 있습니다.';
}

// Path: profileEdit.interests
class TranslationsProfileEditInterestsKo {
	TranslationsProfileEditInterestsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '관심사'
	String get title => '관심사';

	/// ko: '여러 개를 입력하려면 쉼표와 엔터를 사용하세요'
	String get hint => '여러 개를 입력하려면 쉼표와 엔터를 사용하세요';
}

// Path: profileEdit.privacy
class TranslationsProfileEditPrivacyKo {
	TranslationsProfileEditPrivacyKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '개인정보 설정'
	String get title => '개인정보 설정';

	/// ko: '지도에 내 위치 표시'
	String get showLocation => '지도에 내 위치 표시';

	/// ko: '친구 요청 허용'
	String get allowRequests => '친구 요청 허용';
}

// Path: profileEdit.errors
class TranslationsProfileEditErrorsKo {
	TranslationsProfileEditErrorsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '로그인된 사용자가 없습니다.'
	String get noUser => '로그인된 사용자가 없습니다.';

	/// ko: '프로필 업데이트에 실패했습니다: {error}'
	String get updateFailed => '프로필 업데이트에 실패했습니다: {error}';
}

// Path: categories.post
class TranslationsCategoriesPostKo {
	TranslationsCategoriesPostKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsCategoriesPostJalanPerbaikinKo jalanPerbaikin = TranslationsCategoriesPostJalanPerbaikinKo.internal(_root);
	late final TranslationsCategoriesPostDailyLifeKo dailyLife = TranslationsCategoriesPostDailyLifeKo.internal(_root);
	late final TranslationsCategoriesPostHelpShareKo helpShare = TranslationsCategoriesPostHelpShareKo.internal(_root);
	late final TranslationsCategoriesPostIncidentReportKo incidentReport = TranslationsCategoriesPostIncidentReportKo.internal(_root);
	late final TranslationsCategoriesPostLocalNewsKo localNews = TranslationsCategoriesPostLocalNewsKo.internal(_root);
	late final TranslationsCategoriesPostNovemberKo november = TranslationsCategoriesPostNovemberKo.internal(_root);
	late final TranslationsCategoriesPostRainKo rain = TranslationsCategoriesPostRainKo.internal(_root);
	late final TranslationsCategoriesPostDailyQuestionKo dailyQuestion = TranslationsCategoriesPostDailyQuestionKo.internal(_root);
	late final TranslationsCategoriesPostStorePromoKo storePromo = TranslationsCategoriesPostStorePromoKo.internal(_root);
	late final TranslationsCategoriesPostEtcKo etc = TranslationsCategoriesPostEtcKo.internal(_root);
}

// Path: categories.auction
class TranslationsCategoriesAuctionKo {
	TranslationsCategoriesAuctionKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '전체'
	String get all => '전체';

	late final TranslationsCategoriesAuctionCollectiblesKo collectibles = TranslationsCategoriesAuctionCollectiblesKo.internal(_root);
	late final TranslationsCategoriesAuctionDigitalKo digital = TranslationsCategoriesAuctionDigitalKo.internal(_root);
	late final TranslationsCategoriesAuctionFashionKo fashion = TranslationsCategoriesAuctionFashionKo.internal(_root);
	late final TranslationsCategoriesAuctionVintageKo vintage = TranslationsCategoriesAuctionVintageKo.internal(_root);
	late final TranslationsCategoriesAuctionArtCraftKo artCraft = TranslationsCategoriesAuctionArtCraftKo.internal(_root);
	late final TranslationsCategoriesAuctionEtcKo etc = TranslationsCategoriesAuctionEtcKo.internal(_root);
}

// Path: localNewsCreate.form
class TranslationsLocalNewsCreateFormKo {
	TranslationsLocalNewsCreateFormKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '카테고리'
	String get categoryLabel => '카테고리';

	/// ko: '제목'
	String get titleLabel => '제목';

	/// ko: '내용 입력'
	String get contentLabel => '내용 입력';

	/// ko: '태그'
	String get tagsLabel => '태그';

	/// ko: '태그를 추가하세요 (스페이스를 눌러 확정)'
	String get tagsHint => '태그를 추가하세요 (스페이스를 눌러 확정)';

	/// ko: '추천 태그'
	String get recommendedTags => '추천 태그';
}

// Path: localNewsCreate.labels
class TranslationsLocalNewsCreateLabelsKo {
	TranslationsLocalNewsCreateLabelsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '제목'
	String get title => '제목';

	/// ko: '내용'
	String get body => '내용';

	/// ko: '태그'
	String get tags => '태그';

	/// ko: '추가 정보 (선택)'
	String get guidedTitle => '추가 정보 (선택)';

	/// ko: '이벤트/사건 위치'
	String get eventLocation => '이벤트/사건 위치';
}

// Path: localNewsCreate.hints
class TranslationsLocalNewsCreateHintsKo {
	TranslationsLocalNewsCreateHintsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '동네 소식을 공유하거나 궁금한 점을 남겨보세요...'
	String get body => '동네 소식을 공유하거나 궁금한 점을 남겨보세요...';

	/// ko: '(태그 1~3개 선택)'
	String get tagSelection => '(태그 1~3개 선택)';

	/// ko: '예: Jl. Sudirman 123'
	String get eventLocation => '예: Jl. Sudirman 123';
}

// Path: localNewsCreate.validation
class TranslationsLocalNewsCreateValidationKo {
	TranslationsLocalNewsCreateValidationKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '내용을 입력해 주세요.'
	String get bodyRequired => '내용을 입력해 주세요.';

	/// ko: '태그를 최소 1개 선택해 주세요.'
	String get tagRequired => '태그를 최소 1개 선택해 주세요.';

	/// ko: '태그는 최대 3개까지 선택할 수 있습니다.'
	String get tagMaxLimit => '태그는 최대 3개까지 선택할 수 있습니다.';

	/// ko: '이미지는 최대 5장까지 첨부할 수 있습니다.'
	String get imageMaxLimit => '이미지는 최대 5장까지 첨부할 수 있습니다.';

	/// ko: '제목을 입력해 주세요.'
	String get titleRequired => '제목을 입력해 주세요.';
}

// Path: localNewsCreate.buttons
class TranslationsLocalNewsCreateButtonsKo {
	TranslationsLocalNewsCreateButtonsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '이미지 추가'
	String get addImage => '이미지 추가';

	/// ko: '등록'
	String get submit => '등록';
}

// Path: localNewsCreate.alerts
class TranslationsLocalNewsCreateAlertsKo {
	TranslationsLocalNewsCreateAlertsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '내용을 입력해 주세요.'
	String get contentRequired => '내용을 입력해 주세요.';

	/// ko: '카테고리를 선택해 주세요.'
	String get categoryRequired => '카테고리를 선택해 주세요.';

	/// ko: '게시글이 등록되었습니다.'
	String get success => '게시글이 등록되었습니다.';

	/// ko: '업로드에 실패했습니다: {error}'
	String get failure => '업로드에 실패했습니다: {error}';

	/// ko: '게시글을 작성하려면 로그인이 필요합니다.'
	String get loginRequired => '게시글을 작성하려면 로그인이 필요합니다.';

	/// ko: '사용자 정보를 찾을 수 없습니다.'
	String get userNotFound => '사용자 정보를 찾을 수 없습니다.';
}

// Path: localNewsDetail.menu
class TranslationsLocalNewsDetailMenuKo {
	TranslationsLocalNewsDetailMenuKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '수정'
	String get edit => '수정';

	/// ko: '신고'
	String get report => '신고';

	/// ko: '공유'
	String get share => '공유';
}

// Path: localNewsDetail.stats
class TranslationsLocalNewsDetailStatsKo {
	TranslationsLocalNewsDetailStatsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '조회수'
	String get views => '조회수';

	/// ko: '댓글'
	String get comments => '댓글';

	/// ko: '좋아요'
	String get likes => '좋아요';

	/// ko: '고마워요'
	String get thanks => '고마워요';
}

// Path: localNewsDetail.buttons
class TranslationsLocalNewsDetailButtonsKo {
	TranslationsLocalNewsDetailButtonsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '댓글 달기'
	String get comment => '댓글 달기';
}

// Path: localNewsEdit.buttons
class TranslationsLocalNewsEditButtonsKo {
	TranslationsLocalNewsEditButtonsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '수정 완료'
	String get submit => '수정 완료';
}

// Path: localNewsEdit.alerts
class TranslationsLocalNewsEditAlertsKo {
	TranslationsLocalNewsEditAlertsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '게시글이 수정되었습니다.'
	String get success => '게시글이 수정되었습니다.';

	/// ko: '수정에 실패했습니다: {error}'
	String get failure => '수정에 실패했습니다: {error}';
}

// Path: commentInputField.button
class TranslationsCommentInputFieldButtonKo {
	TranslationsCommentInputFieldButtonKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '보내기'
	String get send => '보내기';
}

// Path: common.sort
class TranslationsCommonSortKo {
	TranslationsCommonSortKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '기본 순'
	String get kDefault => '기본 순';

	/// ko: '거리순'
	String get distance => '거리순';

	/// ko: '인기순'
	String get popular => '인기순';
}

// Path: replyInputField.button
class TranslationsReplyInputFieldButtonKo {
	TranslationsReplyInputFieldButtonKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '보내기'
	String get send => '보내기';
}

// Path: jobs.screen
class TranslationsJobsScreenKo {
	TranslationsJobsScreenKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '이 근처에 등록된 일자리 글이 없습니다.'
	String get empty => '이 근처에 등록된 일자리 글이 없습니다.';

	/// ko: '일자리 등록'
	String get createTooltip => '일자리 등록';
}

// Path: jobs.tabs
class TranslationsJobsTabsKo {
	TranslationsJobsTabsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '전체'
	String get all => '전체';

	/// ko: '단기 심부름'
	String get quickGig => '단기 심부름';

	/// ko: '알바/정규직'
	String get regular => '알바/정규직';
}

// Path: jobs.selectType
class TranslationsJobsSelectTypeKo {
	TranslationsJobsSelectTypeKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '일자리 유형 선택'
	String get title => '일자리 유형 선택';

	/// ko: '파트타임 / 정규직 공고'
	String get regularTitle => '파트타임 / 정규직 공고';

	/// ko: '카페, 식당, 사무실 등 일반 근무'
	String get regularDesc => '카페, 식당, 사무실 등 일반 근무';

	/// ko: '단기 심부름 / 간단 도움'
	String get quickGigTitle => '단기 심부름 / 간단 도움';

	/// ko: '오토바이 배달, 이사 도움, 청소 등'
	String get quickGigDesc => '오토바이 배달, 이사 도움, 청소 등';
}

// Path: jobs.form
class TranslationsJobsFormKo {
	TranslationsJobsFormKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '일자리 등록'
	String get title => '일자리 등록';

	/// ko: '공고 제목'
	String get titleHint => '공고 제목';

	/// ko: '모집하는 포지션을 설명해 주세요'
	String get descriptionPositionHint => '모집하는 포지션을 설명해 주세요';

	/// ko: '카테고리'
	String get categoryHint => '카테고리';

	/// ko: '카테고리를 선택해 주세요'
	String get categorySelectHint => '카테고리를 선택해 주세요';

	/// ko: '카테고리를 선택해 주세요.'
	String get categoryValidator => '카테고리를 선택해 주세요.';

	/// ko: '근무지'
	String get locationHint => '근무지';

	/// ko: '일자리 등록'
	String get submit => '일자리 등록';

	/// ko: '제목'
	String get titleLabel => '제목';

	/// ko: '제목을 입력해 주세요.'
	String get titleValidator => '제목을 입력해 주세요.';

	/// ko: '알바/정규직 공고 등록'
	String get titleRegular => '알바/정규직 공고 등록';

	/// ko: '단기 심부름 공고 등록'
	String get titleQuickGig => '단기 심부름 공고 등록';

	/// ko: '필수 항목을 모두 입력해 주세요.'
	String get validationError => '필수 항목을 모두 입력해 주세요.';

	/// ko: '일자리 공고가 저장되었습니다.'
	String get saveSuccess => '일자리 공고가 저장되었습니다.';

	/// ko: '일자리 공고 저장에 실패했습니다: {error}'
	String get saveError => '일자리 공고 저장에 실패했습니다: {error}';

	/// ko: '카테고리'
	String get categoryLabel => '카테고리';

	/// ko: '예: 오토바이 서류 배달 (ASAP)'
	String get titleHintQuickGig => '예: 오토바이 서류 배달 (ASAP)';

	/// ko: '급여 (IDR)'
	String get salaryLabel => '급여 (IDR)';

	/// ko: '급여 금액을 입력해 주세요'
	String get salaryHint => '급여 금액을 입력해 주세요';

	/// ko: '올바른 급여 금액을 입력해 주세요.'
	String get salaryValidator => '올바른 급여 금액을 입력해 주세요.';

	/// ko: '총 지급액 (IDR)'
	String get totalPayLabel => '총 지급액 (IDR)';

	/// ko: '제공할 총 금액을 입력해 주세요'
	String get totalPayHint => '제공할 총 금액을 입력해 주세요';

	/// ko: '올바른 금액을 입력해 주세요.'
	String get totalPayValidator => '올바른 금액을 입력해 주세요.';

	/// ko: '협의 가능'
	String get negotiable => '협의 가능';

	/// ko: '근무 기간'
	String get workPeriodLabel => '근무 기간';

	/// ko: '근무 기간을 선택해 주세요'
	String get workPeriodHint => '근무 기간을 선택해 주세요';

	/// ko: '근무지/위치'
	String get locationLabel => '근무지/위치';

	/// ko: '근무지를 입력해 주세요.'
	String get locationValidator => '근무지를 입력해 주세요.';

	/// ko: '이미지 (선택, 최대 10장)'
	String get imageLabel => '이미지 (선택, 최대 10장)';

	/// ko: '출발지, 도착지, 요청 사항 등 자세히 적어 주세요.'
	String get descriptionHintQuickGig => '출발지, 도착지, 요청 사항 등 자세히 적어 주세요.';

	/// ko: '급여 정보'
	String get salaryInfoTitle => '급여 정보';

	/// ko: '지급 형태'
	String get salaryTypeHint => '지급 형태';

	/// ko: '금액 (IDR)'
	String get salaryAmountLabel => '금액 (IDR)';

	/// ko: '급여 협의 가능'
	String get salaryNegotiable => '급여 협의 가능';

	/// ko: '근무 조건'
	String get workInfoTitle => '근무 조건';

	/// ko: '근무 기간'
	String get workPeriodTitle => '근무 기간';

	/// ko: '근무 요일/시간'
	String get workHoursLabel => '근무 요일/시간';

	/// ko: '예: 월–금, 09:00–18:00'
	String get workHoursHint => '예: 월–금, 09:00–18:00';

	/// ko: '사진 첨부 (선택, 최대 5장)'
	String get imageSectionTitle => '사진 첨부 (선택, 최대 5장)';

	/// ko: '상세 설명'
	String get descriptionLabel => '상세 설명';

	/// ko: '예: 주 3일, 오후 5–10시, 시급 협의 가능 등'
	String get descriptionHint => '예: 주 3일, 오후 5–10시, 시급 협의 가능 등';

	/// ko: '상세 설명을 입력해 주세요.'
	String get descriptionValidator => '상세 설명을 입력해 주세요.';

	/// ko: '일자리 공고가 등록되었습니다.'
	String get submitSuccess => '일자리 공고가 등록되었습니다.';

	/// ko: '일자리 공고 등록에 실패했습니다: {error}'
	String get submitFail => '일자리 공고 등록에 실패했습니다: {error}';
}

// Path: jobs.categories
class TranslationsJobsCategoriesKo {
	TranslationsJobsCategoriesKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '식당'
	String get restaurant => '식당';

	/// ko: '카페'
	String get cafe => '카페';

	/// ko: '매장/리테일'
	String get retail => '매장/리테일';

	/// ko: '배달'
	String get delivery => '배달';

	/// ko: '기타'
	String get etc => '기타';

	/// ko: '서비스'
	String get service => '서비스';

	/// ko: '영업/마케팅'
	String get salesMarketing => '영업/마케팅';

	/// ko: '배송/물류'
	String get deliveryLogistics => '배송/물류';

	/// ko: 'IT/기술'
	String get it => 'IT/기술';

	/// ko: '디자인'
	String get design => '디자인';

	/// ko: '교육'
	String get education => '교육';

	/// ko: '오토바이 배달'
	String get quickGigDelivery => '오토바이 배달';

	/// ko: '오토바이 태워주기 (오젝)'
	String get quickGigTransport => '오토바이 태워주기 (오젝)';

	/// ko: '이사/짐 나르기'
	String get quickGigMoving => '이사/짐 나르기';

	/// ko: '청소/가사 도움'
	String get quickGigCleaning => '청소/가사 도움';

	/// ko: '줄 서주기'
	String get quickGigQueuing => '줄 서주기';

	/// ko: '기타 심부름'
	String get quickGigEtc => '기타 심부름';
}

// Path: jobs.salaryTypes
class TranslationsJobsSalaryTypesKo {
	TranslationsJobsSalaryTypesKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '시급'
	String get hourly => '시급';

	/// ko: '일급'
	String get daily => '일급';

	/// ko: '주급'
	String get weekly => '주급';

	/// ko: '월급'
	String get monthly => '월급';

	/// ko: '총액'
	String get total => '총액';

	/// ko: '건당'
	String get perCase => '건당';

	/// ko: '기타'
	String get etc => '기타';

	/// ko: '연봉'
	String get yearly => '연봉';
}

// Path: jobs.workPeriods
class TranslationsJobsWorkPeriodsKo {
	TranslationsJobsWorkPeriodsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '단기'
	String get shortTerm => '단기';

	/// ko: '중기'
	String get midTerm => '중기';

	/// ko: '장기'
	String get longTerm => '장기';

	/// ko: '1회성'
	String get oneTime => '1회성';

	/// ko: '1주'
	String get k1Week => '1주';

	/// ko: '1개월'
	String get k1Month => '1개월';

	/// ko: '3개월'
	String get k3Months => '3개월';

	/// ko: '6개월 이상'
	String get k6MonthsPlus => '6개월 이상';

	/// ko: '협의 가능'
	String get negotiable => '협의 가능';

	/// ko: '기타'
	String get etc => '기타';
}

// Path: jobs.detail
class TranslationsJobsDetailKo {
	TranslationsJobsDetailKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '상세 정보'
	String get infoTitle => '상세 정보';

	/// ko: '지원하기'
	String get apply => '지원하기';

	/// ko: '작성자 정보가 없습니다'
	String get noAuthor => '작성자 정보가 없습니다';

	/// ko: '채팅을 시작할 수 없습니다: {error}'
	String get chatError => '채팅을 시작할 수 없습니다: {error}';
}

// Path: jobs.card
class TranslationsJobsCardKo {
	TranslationsJobsCardKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '위치 정보 없음'
	String get noLocation => '위치 정보 없음';

	/// ko: '분 전'
	String get minutesAgo => '분 전';
}

// Path: findFriend.tabs
class TranslationsFindFriendTabsKo {
	TranslationsFindFriendTabsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '친구'
	String get friends => '친구';

	/// ko: '그룹'
	String get groups => '그룹';

	/// ko: '클럽'
	String get clubs => '클럽';
}

// Path: interests.items
class TranslationsInterestsItemsKo {
	TranslationsInterestsItemsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '그림 그리기'
	String get drawing => '그림 그리기';

	/// ko: '악기 연주'
	String get instrument => '악기 연주';

	/// ko: '사진'
	String get photography => '사진';

	/// ko: '글쓰기'
	String get writing => '글쓰기';

	/// ko: '공예'
	String get crafting => '공예';

	/// ko: '가드닝'
	String get gardening => '가드닝';

	/// ko: '축구/풋살'
	String get soccer => '축구/풋살';

	/// ko: '등산'
	String get hiking => '등산';

	/// ko: '캠핑'
	String get camping => '캠핑';

	/// ko: '러닝/조깅'
	String get running => '러닝/조깅';

	/// ko: '자전거'
	String get biking => '자전거';

	/// ko: '골프'
	String get golf => '골프';

	/// ko: '운동/피트니스'
	String get workout => '운동/피트니스';

	/// ko: '맛집 탐방'
	String get foodie => '맛집 탐방';

	/// ko: '요리'
	String get cooking => '요리';

	/// ko: '베이킹'
	String get baking => '베이킹';

	/// ko: '커피'
	String get coffee => '커피';

	/// ko: '와인/주류'
	String get wine => '와인/주류';

	/// ko: '차'
	String get tea => '차';

	/// ko: '영화/드라마'
	String get movies => '영화/드라마';

	/// ko: '음악 감상'
	String get music => '음악 감상';

	/// ko: '콘서트/페스티벌'
	String get concerts => '콘서트/페스티벌';

	/// ko: '게임'
	String get gaming => '게임';

	/// ko: '독서'
	String get reading => '독서';

	/// ko: '투자'
	String get investing => '투자';

	/// ko: '언어 공부'
	String get language => '언어 공부';

	/// ko: '코딩'
	String get coding => '코딩';

	/// ko: '여행'
	String get travel => '여행';

	/// ko: '반려동물'
	String get pets => '반려동물';

	/// ko: '봉사활동'
	String get volunteering => '봉사활동';

	/// ko: '미니멀리즘'
	String get minimalism => '미니멀리즘';
}

// Path: clubs.tabs
class TranslationsClubsTabsKo {
	TranslationsClubsTabsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '제안'
	String get proposals => '제안';

	/// ko: '활동 중'
	String get activeClubs => '활동 중';

	/// ko: '내 클럽'
	String get myClubs => '내 클럽';

	/// ko: '클럽 탐색'
	String get exploreClubs => '클럽 탐색';
}

// Path: clubs.sections
class TranslationsClubsSectionsKo {
	TranslationsClubsSectionsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '공식 클럽'
	String get active => '공식 클럽';

	/// ko: '클럽 제안'
	String get proposals => '클럽 제안';
}

// Path: clubs.screen
class TranslationsClubsScreenKo {
	TranslationsClubsScreenKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '오류: {error}'
	String get error => '오류: {error}';

	/// ko: '아직 클럽이 없습니다.'
	String get empty => '아직 클럽이 없습니다.';
}

// Path: clubs.postList
class TranslationsClubsPostListKo {
	TranslationsClubsPostListKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '게시글이 없습니다. 첫 글을 남겨보세요!'
	String get empty => '게시글이 없습니다. 첫 글을 남겨보세요!';

	/// ko: '글쓰기'
	String get writeTooltip => '글쓰기';
}

// Path: clubs.memberCard
class TranslationsClubsMemberCardKo {
	TranslationsClubsMemberCardKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '{memberName}님을 제거할까요?'
	String get kickConfirmTitle => '{memberName}님을 제거할까요?';

	/// ko: '제거된 멤버는 더 이상 클럽 활동에 참여할 수 없습니다.'
	String get kickConfirmContent => '제거된 멤버는 더 이상 클럽 활동에 참여할 수 없습니다.';

	/// ko: '제거'
	String get kick => '제거';

	/// ko: '{memberName}님이 제거되었습니다.'
	String get kickedSuccess => '{memberName}님이 제거되었습니다.';

	/// ko: '멤버 제거 실패: {error}'
	String get kickFail => '멤버 제거 실패: {error}';
}

// Path: clubs.postCard
class TranslationsClubsPostCardKo {
	TranslationsClubsPostCardKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '게시글 삭제'
	String get deleteTitle => '게시글 삭제';

	/// ko: '이 게시글을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'
	String get deleteContent => '이 게시글을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.';

	/// ko: '게시글이 삭제되었습니다.'
	String get deleteSuccess => '게시글이 삭제되었습니다.';

	/// ko: '게시글 삭제 실패: {error}'
	String get deleteFail => '게시글 삭제 실패: {error}';

	/// ko: '탈퇴한 멤버'
	String get withdrawnMember => '탈퇴한 멤버';

	/// ko: '게시글 삭제'
	String get deleteTooltip => '게시글 삭제';

	/// ko: '사용자 정보 불러오는 중...'
	String get loadingUser => '사용자 정보 불러오는 중...';
}

// Path: clubs.card
class TranslationsClubsCardKo {
	TranslationsClubsCardKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '멤버 {count}명'
	String get membersCount => '멤버 {count}명';
}

// Path: clubs.postDetail
class TranslationsClubsPostDetailKo {
	TranslationsClubsPostDetailKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '댓글 추가 실패: {error}'
	String get commentFail => '댓글 추가 실패: {error}';

	/// ko: '{title} 게시판'
	String get appBarTitle => '{title} 게시판';

	/// ko: '댓글'
	String get commentsTitle => '댓글';

	/// ko: '댓글이 없습니다.'
	String get noComments => '댓글이 없습니다.';

	/// ko: '댓글 작성...'
	String get commentHint => '댓글 작성...';

	/// ko: '알 수 없는 사용자'
	String get unknownUser => '알 수 없는 사용자';
}

// Path: clubs.detail
class TranslationsClubsDetailKo {
	TranslationsClubsDetailKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '‘{title}’ 클럽에 가입했습니다!'
	String get joined => '‘{title}’ 클럽에 가입했습니다!';

	/// ko: '운영자 승인 대기 중입니다. 승인 후 활동할 수 있습니다.'
	String get pendingApproval => '운영자 승인 대기 중입니다. 승인 후 활동할 수 있습니다.';

	/// ko: '가입 요청 실패: {error}'
	String get joinFail => '가입 요청 실패: {error}';

	late final TranslationsClubsDetailTabsKo tabs = TranslationsClubsDetailTabsKo.internal(_root);

	/// ko: '채팅 참여'
	String get joinChat => '채팅 참여';

	/// ko: '클럽 가입'
	String get joinClub => '클럽 가입';

	/// ko: '운영자'
	String get owner => '운영자';

	late final TranslationsClubsDetailInfoKo info = TranslationsClubsDetailInfoKo.internal(_root);

	/// ko: '위치'
	String get location => '위치';

	/// ko: '클럽 탈퇴'
	String get leaveConfirmTitle => '클럽 탈퇴';

	/// ko: '{title} 클럽을 탈퇴하시겠습니까?'
	String get leaveConfirmContent => '{title} 클럽을 탈퇴하시겠습니까?';

	/// ko: '탈퇴'
	String get leave => '탈퇴';

	/// ko: '{title} 클럽에서 탈퇴했습니다.'
	String get leaveSuccess => '{title} 클럽에서 탈퇴했습니다.';

	/// ko: '탈퇴 실패: {error}'
	String get leaveFail => '탈퇴 실패: {error}';
}

// Path: clubs.memberList
class TranslationsClubsMemberListKo {
	TranslationsClubsMemberListKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '승인 대기 멤버'
	String get pendingMembers => '승인 대기 멤버';

	/// ko: '전체 멤버'
	String get allMembers => '전체 멤버';
}

// Path: clubs.createPost
class TranslationsClubsCreatePostKo {
	TranslationsClubsCreatePostKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '새 글'
	String get title => '새 글';

	/// ko: '등록'
	String get submit => '등록';

	/// ko: '글이 등록되었습니다.'
	String get success => '글이 등록되었습니다.';

	/// ko: '글 등록 실패: {error}'
	String get fail => '글 등록 실패: {error}';

	/// ko: '내용 입력...'
	String get bodyHint => '내용 입력...';
}

// Path: clubs.createClub
class TranslationsClubsCreateClubKo {
	TranslationsClubsCreateClubKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '관심사를 최소 1개 선택해 주세요.'
	String get selectAtLeastOneInterest => '관심사를 최소 1개 선택해 주세요.';

	/// ko: '클럽이 생성되었습니다!'
	String get success => '클럽이 생성되었습니다!';

	/// ko: '클럽 생성 실패: {error}'
	String get fail => '클럽 생성 실패: {error}';

	/// ko: '클럽 만들기'
	String get title => '클럽 만들기';

	/// ko: '클럽 이름'
	String get nameLabel => '클럽 이름';

	/// ko: '클럽 이름을 입력해 주세요.'
	String get nameError => '클럽 이름을 입력해 주세요.';

	/// ko: '클럽 설명'
	String get descriptionLabel => '클럽 설명';

	/// ko: '클럽 설명을 입력해 주세요.'
	String get descriptionError => '클럽 설명을 입력해 주세요.';

	/// ko: '태그 입력 후 스페이스로 추가'
	String get tagsHint => '태그 입력 후 스페이스로 추가';

	/// ko: '최대 3개의 관심사를 선택할 수 있습니다.'
	String get maxInterests => '최대 3개의 관심사를 선택할 수 있습니다.';

	/// ko: '비공개 클럽'
	String get privateClub => '비공개 클럽';

	/// ko: '초대받은 사람만 참여 가능'
	String get privateDescription => '초대받은 사람만 참여 가능';

	/// ko: '위치'
	String get locationLabel => '위치';
}

// Path: clubs.editClub
class TranslationsClubsEditClubKo {
	TranslationsClubsEditClubKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '클럽 정보 수정'
	String get title => '클럽 정보 수정';

	/// ko: '저장'
	String get save => '저장';

	/// ko: '클럽 정보가 업데이트되었습니다.'
	String get success => '클럽 정보가 업데이트되었습니다.';

	/// ko: '업데이트 실패: {error}'
	String get fail => '업데이트 실패: {error}';
}

// Path: clubs.create
class TranslationsClubsCreateKo {
	TranslationsClubsCreateKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '클럽 만들기'
	String get title => '클럽 만들기';
}

// Path: clubs.repository
class TranslationsClubsRepositoryKo {
	TranslationsClubsRepositoryKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '클럽 채팅방이 생성되었습니다.'
	String get chatCreated => '클럽 채팅방이 생성되었습니다.';
}

// Path: clubs.proposal
class TranslationsClubsProposalKo {
	TranslationsClubsProposalKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '클럽 제안 만들기'
	String get createTitle => '클럽 제안 만들기';

	/// ko: '커버 이미지를 선택해 주세요.'
	String get imageError => '커버 이미지를 선택해 주세요.';

	/// ko: '클럽 제안이 생성되었습니다.'
	String get createSuccess => '클럽 제안이 생성되었습니다.';

	/// ko: '클럽 제안 생성 실패: {error}'
	String get createFail => '클럽 제안 생성 실패: {error}';

	/// ko: '태그 입력 후 스페이스로 추가'
	String get tagsHint => '태그 입력 후 스페이스로 추가';

	/// ko: '목표 인원'
	String get targetMembers => '목표 인원';

	/// ko: '총 {count}명'
	String get targetMembersCount => '총 {count}명';

	/// ko: '아직 제안이 없습니다.'
	String get empty => '아직 제안이 없습니다.';

	/// ko: '{current} / {target}명'
	String get memberStatus => '{current} / {target}명';

	/// ko: '참여'
	String get join => '참여';

	/// ko: '나가기'
	String get leave => '나가기';

	/// ko: '멤버'
	String get members => '멤버';

	/// ko: '아직 참여자가 없습니다.'
	String get noMembers => '아직 참여자가 없습니다.';

	late final TranslationsClubsProposalDetailKo detail = TranslationsClubsProposalDetailKo.internal(_root);
}

// Path: findfriend.form
class TranslationsFindfriendFormKo {
	TranslationsFindfriendFormKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '친구 찾기 프로필 만들기'
	String get title => '친구 찾기 프로필 만들기';
}

// Path: auctions.card
class TranslationsAuctionsCardKo {
	TranslationsAuctionsCardKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '현재 입찰가'
	String get currentBid => '현재 입찰가';

	/// ko: '남은 시간'
	String get endTime => '남은 시간';

	/// ko: '종료됨'
	String get ended => '종료됨';

	/// ko: '최종 낙찰가'
	String get winningBid => '최종 낙찰가';

	/// ko: '낙찰자'
	String get winner => '낙찰자';

	/// ko: '아직 입찰자가 없습니다'
	String get noBidders => '아직 입찰자가 없습니다';

	/// ko: '알 수 없는 입찰자'
	String get unknownBidder => '알 수 없는 입찰자';

	/// ko: '{hours}:{minutes}:{seconds} 남음'
	String get timeLeft => '{hours}:{minutes}:{seconds} 남음';

	/// ko: '{days}일 {hours}:{minutes}:{seconds} 남음'
	String get timeLeftDays => '{days}일 {hours}:{minutes}:{seconds} 남음';
}

// Path: auctions.errors
class TranslationsAuctionsErrorsKo {
	TranslationsAuctionsErrorsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '경매 목록을 불러오지 못했습니다: {error}'
	String get fetchFailed => '경매 목록을 불러오지 못했습니다: {error}';

	/// ko: '경매를 찾을 수 없습니다.'
	String get notFound => '경매를 찾을 수 없습니다.';

	/// ko: '현재 입찰가보다 높은 금액을 입력해야 합니다.'
	String get lowerBid => '현재 입찰가보다 높은 금액을 입력해야 합니다.';

	/// ko: '이 경매는 이미 종료되었습니다.'
	String get alreadyEnded => '이 경매는 이미 종료되었습니다.';
}

// Path: auctions.filter
class TranslationsAuctionsFilterKo {
	TranslationsAuctionsFilterKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '필터'
	String get tooltip => '필터';

	/// ko: '필터 초기화'
	String get clearTooltip => '필터 초기화';
}

// Path: auctions.create
class TranslationsAuctionsCreateKo {
	TranslationsAuctionsCreateKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '경매 등록'
	String get tooltip => '경매 등록';

	/// ko: '경매 생성'
	String get title => '경매 생성';

	/// ko: '등록 방식'
	String get registrationType => '등록 방식';

	late final TranslationsAuctionsCreateTypeKo type = TranslationsAuctionsCreateTypeKo.internal(_root);

	/// ko: '경매가 생성되었습니다.'
	String get success => '경매가 생성되었습니다.';

	/// ko: '경매 생성 실패: {error}'
	String get fail => '경매 생성 실패: {error}';

	/// ko: '경매 시작'
	String get submitButton => '경매 시작';

	/// ko: '경매로 등록하시겠습니까?'
	String get confirmTitle => '경매로 등록하시겠습니까?';

	/// ko: '경매로 등록하면 일반 판매로 되돌릴 수 없습니다. 낙찰 시 5%의 수수료가 부과됩니다. 계속하시겠습니까?'
	String get confirmContent => '경매로 등록하면 일반 판매로 되돌릴 수 없습니다. 낙찰 시 5%의 수수료가 부과됩니다. 계속하시겠습니까?';

	late final TranslationsAuctionsCreateErrorsKo errors = TranslationsAuctionsCreateErrorsKo.internal(_root);
	late final TranslationsAuctionsCreateFormKo form = TranslationsAuctionsCreateFormKo.internal(_root);
}

// Path: auctions.edit
class TranslationsAuctionsEditKo {
	TranslationsAuctionsEditKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '경매 수정'
	String get tooltip => '경매 수정';

	/// ko: '경매 수정'
	String get title => '경매 수정';

	/// ko: '저장'
	String get save => '저장';

	/// ko: '경매가 수정되었습니다.'
	String get success => '경매가 수정되었습니다.';

	/// ko: '경매 수정 실패: {error}'
	String get fail => '경매 수정 실패: {error}';
}

// Path: auctions.form
class TranslationsAuctionsFormKo {
	TranslationsAuctionsFormKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '제목을 입력해 주세요.'
	String get titleRequired => '제목을 입력해 주세요.';

	/// ko: '설명을 입력해 주세요.'
	String get descriptionRequired => '설명을 입력해 주세요.';

	/// ko: '시작가를 입력해 주세요.'
	String get startPriceRequired => '시작가를 입력해 주세요.';

	/// ko: '카테고리를 선택해 주세요.'
	String get categoryRequired => '카테고리를 선택해 주세요.';
}

// Path: auctions.delete
class TranslationsAuctionsDeleteKo {
	TranslationsAuctionsDeleteKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '경매 삭제'
	String get tooltip => '경매 삭제';

	/// ko: '경매 삭제'
	String get confirmTitle => '경매 삭제';

	/// ko: '이 경매를 삭제하시겠습니까?'
	String get confirmContent => '이 경매를 삭제하시겠습니까?';

	/// ko: '경매가 삭제되었습니다.'
	String get success => '경매가 삭제되었습니다.';

	/// ko: '경매 삭제 실패: {error}'
	String get fail => '경매 삭제 실패: {error}';
}

// Path: auctions.detail
class TranslationsAuctionsDetailKo {
	TranslationsAuctionsDetailKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '현재 입찰가: {amount}'
	String get currentBid => '현재 입찰가: {amount}';

	/// ko: '위치'
	String get location => '위치';

	/// ko: '판매자'
	String get seller => '판매자';

	/// ko: '질문·답변'
	String get qnaTitle => '질문·답변';

	/// ko: '판매자에게 질문하세요...'
	String get qnaHint => '판매자에게 질문하세요...';

	/// ko: '종료 시간: {time}'
	String get endTime => '종료 시간: {time}';

	/// ko: '입찰 내역'
	String get bidsTitle => '입찰 내역';

	/// ko: '입찰 내역이 없습니다.'
	String get noBids => '입찰 내역이 없습니다.';

	/// ko: '알 수 없는 입찰자'
	String get unknownBidder => '알 수 없는 입찰자';

	/// ko: '입찰 금액 입력 (Rp)'
	String get bidAmountLabel => '입찰 금액 입력 (Rp)';

	/// ko: '입찰하기'
	String get placeBid => '입찰하기';

	/// ko: '입찰 성공!'
	String get bidSuccess => '입찰 성공!';

	/// ko: '입찰 실패: {error}'
	String get bidFail => '입찰 실패: {error}';

	late final TranslationsAuctionsDetailErrorsKo errors = TranslationsAuctionsDetailErrorsKo.internal(_root);
}

// Path: localStores.create
class TranslationsLocalStoresCreateKo {
	TranslationsLocalStoresCreateKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '내 가게 등록'
	String get tooltip => '내 가게 등록';

	/// ko: '새 가게 등록'
	String get title => '새 가게 등록';

	/// ko: '등록'
	String get submit => '등록';

	/// ko: '가게가 등록되었습니다.'
	String get success => '가게가 등록되었습니다.';

	/// ko: '가게 등록 실패: {error}'
	String get fail => '가게 등록 실패: {error}';
}

// Path: localStores.edit
class TranslationsLocalStoresEditKo {
	TranslationsLocalStoresEditKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '가게 정보 수정'
	String get title => '가게 정보 수정';

	/// ko: '저장'
	String get save => '저장';

	/// ko: '가게 정보가 수정되었습니다.'
	String get success => '가게 정보가 수정되었습니다.';

	/// ko: '가게 정보 수정 실패: {error}'
	String get fail => '가게 정보 수정 실패: {error}';

	/// ko: '가게 정보 수정'
	String get tooltip => '가게 정보 수정';
}

// Path: localStores.form
class TranslationsLocalStoresFormKo {
	TranslationsLocalStoresFormKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '가게 이름'
	String get nameLabel => '가게 이름';

	/// ko: '가게 이름을 입력해 주세요.'
	String get nameError => '가게 이름을 입력해 주세요.';

	/// ko: '가게 소개'
	String get descriptionLabel => '가게 소개';

	/// ko: '가게 소개를 입력해 주세요.'
	String get descriptionError => '가게 소개를 입력해 주세요.';

	/// ko: '연락처'
	String get contactLabel => '연락처';

	/// ko: '영업 시간'
	String get hoursLabel => '영업 시간';

	/// ko: '예: 09:00 - 18:00'
	String get hoursHint => '예: 09:00 - 18:00';

	/// ko: '사진 (최대 {count}장)'
	String get photoLabel => '사진 (최대 {count}장)';

	/// ko: '카테고리'
	String get categoryLabel => '카테고리';

	/// ko: '카테고리를 선택해 주세요.'
	String get categoryError => '카테고리를 선택해 주세요.';

	/// ko: '주요 상품/서비스'
	String get productsLabel => '주요 상품/서비스';

	/// ko: '쉼표로 구분 (예: 커트, 염색, 펌)'
	String get productsHint => '쉼표로 구분 (예: 커트, 염색, 펌)';

	/// ko: '이미지를 불러오지 못했습니다. 다시 시도하세요.'
	String get imageError => '이미지를 불러오지 못했습니다. 다시 시도하세요.';
}

// Path: localStores.categories
class TranslationsLocalStoresCategoriesKo {
	TranslationsLocalStoresCategoriesKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '전체'
	String get all => '전체';

	/// ko: '식당'
	String get food => '식당';

	/// ko: '카페'
	String get cafe => '카페';

	/// ko: '마사지'
	String get massage => '마사지';

	/// ko: '미용'
	String get beauty => '미용';

	/// ko: '네일'
	String get nail => '네일';

	/// ko: '자동차 정비'
	String get auto => '자동차 정비';

	/// ko: '키즈'
	String get kids => '키즈';

	/// ko: '병원/클리닉'
	String get hospital => '병원/클리닉';

	/// ko: '기타'
	String get etc => '기타';
}

// Path: localStores.detail
class TranslationsLocalStoresDetailKo {
	TranslationsLocalStoresDetailKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '가게 소개'
	String get description => '가게 소개';

	/// ko: '상품/서비스'
	String get products => '상품/서비스';

	/// ko: '가게 삭제'
	String get deleteTitle => '가게 삭제';

	/// ko: '이 가게를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'
	String get deleteContent => '이 가게를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.';

	/// ko: '가게 삭제'
	String get deleteTooltip => '가게 삭제';

	/// ko: '삭제'
	String get delete => '삭제';

	/// ko: '취소'
	String get cancel => '취소';

	/// ko: '가게가 삭제되었습니다.'
	String get deleteSuccess => '가게가 삭제되었습니다.';

	/// ko: '가게 삭제 실패: {error}'
	String get deleteFail => '가게 삭제 실패: {error}';

	/// ko: '문의'
	String get inquire => '문의';

	/// ko: '가게 주인 정보를 찾을 수 없습니다'
	String get noOwnerInfo => '가게 주인 정보를 찾을 수 없습니다';

	/// ko: '채팅을 시작할 수 없습니다: {error}'
	String get startChatFail => '채팅을 시작할 수 없습니다: {error}';

	/// ko: '리뷰'
	String get reviews => '리뷰';

	/// ko: '리뷰 작성'
	String get writeReview => '리뷰 작성';

	/// ko: '아직 리뷰가 없습니다.'
	String get noReviews => '아직 리뷰가 없습니다.';

	/// ko: '리뷰를 작성해 주세요.'
	String get reviewDialogContent => '리뷰를 작성해 주세요.';
}

// Path: pom.search
class TranslationsPomSearchKo {
	TranslationsPomSearchKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: 'POM, 태그, 사용자 검색'
	String get hint => 'POM, 태그, 사용자 검색';
}

// Path: pom.tabs
class TranslationsPomTabsKo {
	TranslationsPomTabsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '지역'
	String get local => '지역';

	/// ko: '전체'
	String get all => '전체';

	/// ko: '인기'
	String get popular => '인기';

	/// ko: '내 POM'
	String get myPoms => '내 POM';
}

// Path: pom.errors
class TranslationsPomErrorsKo {
	TranslationsPomErrorsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '오류가 발생했습니다: {error}'
	String get fetchFailed => '오류가 발생했습니다: {error}';

	/// ko: '이 영상은 재생할 수 없습니다. 소스가 차단되었거나 사용할 수 없습니다.'
	String get videoSource => '이 영상은 재생할 수 없습니다. 소스가 차단되었거나 사용할 수 없습니다.';
}

// Path: pom.comments
class TranslationsPomCommentsKo {
	TranslationsPomCommentsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '댓글'
	String get title => '댓글';

	/// ko: '{}개 댓글 모두 보기'
	String get viewAll => '{}개 댓글 모두 보기';

	/// ko: '아직 댓글이 없습니다.'
	String get empty => '아직 댓글이 없습니다.';

	/// ko: '댓글 작성...'
	String get placeholder => '댓글 작성...';

	/// ko: '댓글 작성 실패: {error}'
	String get fail => '댓글 작성 실패: {error}';
}

// Path: pom.create
class TranslationsPomCreateKo {
	TranslationsPomCreateKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '새 POM 업로드'
	String get title => '새 POM 업로드';

	/// ko: '사진'
	String get photo => '사진';

	/// ko: '동영상'
	String get video => '동영상';

	/// ko: '사진 업로드'
	String get titleImage => '사진 업로드';

	/// ko: '업로드'
	String get submit => '업로드';

	/// ko: 'POM이 업로드되었습니다.'
	String get success => 'POM이 업로드되었습니다.';

	/// ko: 'POM 업로드 실패: {error}'
	String get fail => 'POM 업로드 실패: {error}';

	late final TranslationsPomCreateFormKo form = TranslationsPomCreateFormKo.internal(_root);
}

// Path: realEstate.tabs
class TranslationsRealEstateTabsKo {
	TranslationsRealEstateTabsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '전체'
	String get all => '전체';

	/// ko: '임대'
	String get rent => '임대';

	/// ko: '매매'
	String get sale => '매매';

	/// ko: '내 매물'
	String get myListings => '내 매물';
}

// Path: realEstate.create
class TranslationsRealEstateCreateKo {
	TranslationsRealEstateCreateKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '매물 등록'
	String get tooltip => '매물 등록';

	/// ko: '새 매물 등록'
	String get title => '새 매물 등록';

	/// ko: '등록'
	String get submit => '등록';

	/// ko: '매물이 등록되었습니다.'
	String get success => '매물이 등록되었습니다.';

	/// ko: '매물 등록 실패: {error}'
	String get fail => '매물 등록 실패: {error}';
}

// Path: realEstate.edit
class TranslationsRealEstateEditKo {
	TranslationsRealEstateEditKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '매물 수정'
	String get title => '매물 수정';

	/// ko: '저장'
	String get save => '저장';

	/// ko: '매물이 수정되었습니다.'
	String get success => '매물이 수정되었습니다.';

	/// ko: '매물 수정 실패: {error}'
	String get fail => '매물 수정 실패: {error}';

	/// ko: '매물 수정'
	String get tooltip => '매물 수정';
}

// Path: realEstate.form
class TranslationsRealEstateFormKo {
	TranslationsRealEstateFormKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '제목'
	String get titleLabel => '제목';

	/// ko: '제목을 입력해 주세요.'
	String get titleError => '제목을 입력해 주세요.';

	/// ko: '설명'
	String get descriptionLabel => '설명';

	/// ko: '설명을 입력해 주세요.'
	String get descriptionError => '설명을 입력해 주세요.';

	/// ko: '가격 (IDR)'
	String get priceLabel => '가격 (IDR)';

	/// ko: '가격을 입력해 주세요.'
	String get priceError => '가격을 입력해 주세요.';

	/// ko: '유형'
	String get categoryLabel => '유형';

	/// ko: '유형을 선택해 주세요.'
	String get categoryError => '유형을 선택해 주세요.';

	/// ko: '위치'
	String get locationLabel => '위치';

	/// ko: '위치를 입력해 주세요.'
	String get locationError => '위치를 입력해 주세요.';

	/// ko: '방 개수'
	String get roomsLabel => '방 개수';

	/// ko: '욕실 개수'
	String get bathLabel => '욕실 개수';

	/// ko: '면적 (m²)'
	String get areaLabel => '면적 (m²)';

	/// ko: '사진 (최대 10장)'
	String get photoLabel => '사진 (최대 10장)';

	/// ko: '이미지를 불러올 수 없습니다.'
	String get imageError => '이미지를 불러올 수 없습니다.';
}

// Path: realEstate.categories
class TranslationsRealEstateCategoriesKo {
	TranslationsRealEstateCategoriesKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '주택'
	String get house => '주택';

	/// ko: '아파트'
	String get apartment => '아파트';

	/// ko: 'Kost'
	String get kost => 'Kost';

	/// ko: '빌라'
	String get villa => '빌라';

	/// ko: '사무실'
	String get office => '사무실';

	/// ko: '토지'
	String get land => '토지';

	/// ko: '상가'
	String get shophouse => '상가';

	/// ko: '창고'
	String get warehouse => '창고';

	/// ko: '기타'
	String get etc => '기타';
}

// Path: realEstate.detail
class TranslationsRealEstateDetailKo {
	TranslationsRealEstateDetailKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '가격'
	String get price => '가격';

	/// ko: '방'
	String get rooms => '방';

	/// ko: '욕실'
	String get bathrooms => '욕실';

	/// ko: '면적'
	String get area => '면적';

	/// ko: '위치'
	String get location => '위치';

	/// ko: '판매자에게 문의'
	String get contactSeller => '판매자에게 문의';

	/// ko: '채팅을 시작할 수 없습니다: {error}'
	String get contactFail => '채팅을 시작할 수 없습니다: {error}';

	/// ko: '삭제'
	String get delete => '삭제';

	/// ko: '이 매물을 삭제하시겠습니까?'
	String get deleteConfirm => '이 매물을 삭제하시겠습니까?';

	/// ko: '매물이 삭제되었습니다.'
	String get deleteSuccess => '매물이 삭제되었습니다.';

	/// ko: '매물 삭제 실패: {error}'
	String get deleteFail => '매물 삭제 실패: {error}';

	/// ko: '등록자'
	String get postedBy => '등록자';
}

// Path: lostAndFound.tabs
class TranslationsLostAndFoundTabsKo {
	TranslationsLostAndFoundTabsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '분실'
	String get lost => '분실';

	/// ko: '습득'
	String get found => '습득';

	/// ko: '내 글'
	String get myReports => '내 글';
}

// Path: lostAndFound.create
class TranslationsLostAndFoundCreateKo {
	TranslationsLostAndFoundCreateKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '글 등록'
	String get tooltip => '글 등록';

	/// ko: '새 글 등록'
	String get title => '새 글 등록';

	/// ko: '등록'
	String get submit => '등록';

	/// ko: '글이 등록되었습니다.'
	String get success => '글이 등록되었습니다.';

	/// ko: '등록 실패: {error}'
	String get fail => '등록 실패: {error}';
}

// Path: lostAndFound.edit
class TranslationsLostAndFoundEditKo {
	TranslationsLostAndFoundEditKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '글 수정'
	String get title => '글 수정';

	/// ko: '저장'
	String get save => '저장';

	/// ko: '글이 수정되었습니다.'
	String get success => '글이 수정되었습니다.';

	/// ko: '글 수정 실패: {error}'
	String get fail => '글 수정 실패: {error}';
}

// Path: lostAndFound.form
class TranslationsLostAndFoundFormKo {
	TranslationsLostAndFoundFormKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '제목'
	String get titleLabel => '제목';

	/// ko: '제목을 입력해 주세요.'
	String get titleError => '제목을 입력해 주세요.';

	/// ko: '상세 내용'
	String get descriptionLabel => '상세 내용';

	/// ko: '상세 내용을 입력해 주세요.'
	String get descriptionError => '상세 내용을 입력해 주세요.';

	/// ko: '유형'
	String get categoryLabel => '유형';

	/// ko: '유형을 선택해 주세요.'
	String get categoryError => '유형을 선택해 주세요.';

	/// ko: '위치'
	String get locationLabel => '위치';

	/// ko: '위치를 입력해 주세요.'
	String get locationError => '위치를 입력해 주세요.';

	/// ko: '사진 (최대 10장)'
	String get photoLabel => '사진 (최대 10장)';
}

// Path: lostAndFound.categories
class TranslationsLostAndFoundCategoriesKo {
	TranslationsLostAndFoundCategoriesKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '반려동물'
	String get pet => '반려동물';

	/// ko: '개인 소지품'
	String get item => '개인 소지품';

	/// ko: '사람'
	String get person => '사람';

	/// ko: '사기 피해'
	String get scam => '사기 피해';

	/// ko: '기타'
	String get etc => '기타';
}

// Path: lostAndFound.detail
class TranslationsLostAndFoundDetailKo {
	TranslationsLostAndFoundDetailKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '위치'
	String get location => '위치';

	/// ko: '문의하기'
	String get contact => '문의하기';

	/// ko: '채팅을 시작할 수 없습니다: {error}'
	String get contactFail => '채팅을 시작할 수 없습니다: {error}';

	/// ko: '삭제'
	String get delete => '삭제';

	/// ko: '이 글을 삭제하시겠습니까?'
	String get deleteConfirm => '이 글을 삭제하시겠습니까?';

	/// ko: '삭제되었습니다.'
	String get deleteSuccess => '삭제되었습니다.';

	/// ko: '삭제 실패: {error}'
	String get deleteFail => '삭제 실패: {error}';
}

// Path: community.create
class TranslationsCommunityCreateKo {
	TranslationsCommunityCreateKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '새 글'
	String get title => '새 글';

	/// ko: '등록'
	String get submit => '등록';

	/// ko: '게시글이 등록되었습니다.'
	String get success => '게시글이 등록되었습니다.';

	/// ko: '등록 실패: {error}'
	String get fail => '등록 실패: {error}';
}

// Path: community.edit
class TranslationsCommunityEditKo {
	TranslationsCommunityEditKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '게시글 수정'
	String get title => '게시글 수정';

	/// ko: '저장'
	String get save => '저장';

	/// ko: '게시글이 수정되었습니다.'
	String get success => '게시글이 수정되었습니다.';

	/// ko: '수정 실패: {error}'
	String get fail => '수정 실패: {error}';
}

// Path: community.post
class TranslationsCommunityPostKo {
	TranslationsCommunityPostKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '삭제'
	String get delete => '삭제';

	/// ko: '이 게시글을 삭제하시겠습니까?'
	String get deleteConfirm => '이 게시글을 삭제하시겠습니까?';

	/// ko: '삭제되었습니다.'
	String get deleteSuccess => '삭제되었습니다.';

	/// ko: '삭제 실패: {error}'
	String get deleteFail => '삭제 실패: {error}';
}

// Path: shared.tagInput
class TranslationsSharedTagInputKo {
	TranslationsSharedTagInputKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '태그를 입력하세요 (스페이스를 눌러 확정)'
	String get defaultHint => '태그를 입력하세요 (스페이스를 눌러 확정)';
}

// Path: admin.screen
class TranslationsAdminScreenKo {
	TranslationsAdminScreenKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '관리자 메뉴'
	String get title => '관리자 메뉴';
}

// Path: admin.menu
class TranslationsAdminMenuKo {
	TranslationsAdminMenuKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: 'AI 인증 관리'
	String get aiApproval => 'AI 인증 관리';

	/// ko: '신고 관리'
	String get reportManagement => '신고 관리';
}

// Path: admin.aiApproval
class TranslationsAdminAiApprovalKo {
	TranslationsAdminAiApprovalKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: 'AI 인증 대기 중인 상품이 없습니다.'
	String get empty => 'AI 인증 대기 중인 상품이 없습니다.';

	/// ko: '대기 중인 상품을 불러오는 중 오류가 발생했습니다.'
	String get error => '대기 중인 상품을 불러오는 중 오류가 발생했습니다.';

	/// ko: '요청 시간'
	String get requestedAt => '요청 시간';
}

// Path: admin.reports
class TranslationsAdminReportsKo {
	TranslationsAdminReportsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '신고 관리'
	String get title => '신고 관리';

	/// ko: '대기 중인 신고가 없습니다.'
	String get empty => '대기 중인 신고가 없습니다.';

	/// ko: '신고 목록을 불러오는 중 오류가 발생했습니다.'
	String get error => '신고 목록을 불러오는 중 오류가 발생했습니다.';

	/// ko: '생성 시간'
	String get createdAt => '생성 시간';
}

// Path: admin.reportList
class TranslationsAdminReportListKo {
	TranslationsAdminReportListKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '신고 관리'
	String get title => '신고 관리';

	/// ko: '대기 중인 신고가 없습니다.'
	String get empty => '대기 중인 신고가 없습니다.';

	/// ko: '신고 목록을 불러오는 중 오류가 발생했습니다.'
	String get error => '신고 목록을 불러오는 중 오류가 발생했습니다.';
}

// Path: admin.reportDetail
class TranslationsAdminReportDetailKo {
	TranslationsAdminReportDetailKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '신고 상세'
	String get title => '신고 상세';

	/// ko: '신고 상세를 불러오는 중 오류가 발생했습니다.'
	String get loadError => '신고 상세를 불러오는 중 오류가 발생했습니다.';

	/// ko: '신고 정보'
	String get sectionReportInfo => '신고 정보';

	/// ko: 'ID'
	String get idLabel => 'ID';

	/// ko: '신고된 게시글 ID'
	String get postIdLabel => '신고된 게시글 ID';

	/// ko: '신고자'
	String get reporter => '신고자';

	/// ko: '신고 대상 사용자'
	String get reportedUser => '신고 대상 사용자';

	/// ko: '사유'
	String get reason => '사유';

	/// ko: '신고 시간'
	String get reportedAt => '신고 시간';

	/// ko: '상태'
	String get currentStatus => '상태';

	/// ko: '신고된 내용'
	String get sectionContent => '신고된 내용';

	/// ko: '내용을 불러오는 중...'
	String get loadingContent => '내용을 불러오는 중...';

	/// ko: '신고된 내용을 불러오지 못했습니다.'
	String get contentLoadError => '신고된 내용을 불러오지 못했습니다.';

	/// ko: '내용 정보가 없거나 삭제되었습니다.'
	String get contentNotAvailable => '내용 정보가 없거나 삭제되었습니다.';

	/// ko: '작성자 ID'
	String get authorIdLabel => '작성자 ID';

	late final TranslationsAdminReportDetailContentKo content = TranslationsAdminReportDetailContentKo.internal(_root);

	/// ko: '원본 게시글 보기'
	String get viewOriginalPost => '원본 게시글 보기';

	/// ko: '조치'
	String get sectionActions => '조치';

	/// ko: '검토 완료로 표시'
	String get actionReviewed => '검토 완료로 표시';

	/// ko: '조치 완료로 표시(예: 삭제)'
	String get actionTaken => '조치 완료로 표시(예: 삭제)';

	/// ko: '신고 무시'
	String get actionDismissed => '신고 무시';

	/// ko: '신고 상태가 '{status}'(으)로 변경되었습니다.'
	String get statusUpdateSuccess => '신고 상태가 \'{status}\'(으)로 변경되었습니다.';

	/// ko: '상태를 업데이트하지 못했습니다: {error}'
	String get statusUpdateFail => '상태를 업데이트하지 못했습니다: {error}';

	/// ko: '원본 게시글을 찾을 수 없습니다.'
	String get originalPostNotFound => '원본 게시글을 찾을 수 없습니다.';

	/// ko: '원본 게시글을 열 수 없습니다.'
	String get couldNotOpenOriginalPost => '원본 게시글을 열 수 없습니다.';
}

// Path: tags.localNews
class TranslationsTagsLocalNewsKo {
	TranslationsTagsLocalNewsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsTagsLocalNewsKelurahanNoticeKo kelurahanNotice = TranslationsTagsLocalNewsKelurahanNoticeKo.internal(_root);
	late final TranslationsTagsLocalNewsKecamatanNoticeKo kecamatanNotice = TranslationsTagsLocalNewsKecamatanNoticeKo.internal(_root);
	late final TranslationsTagsLocalNewsPublicCampaignKo publicCampaign = TranslationsTagsLocalNewsPublicCampaignKo.internal(_root);
	late final TranslationsTagsLocalNewsSiskamlingKo siskamling = TranslationsTagsLocalNewsSiskamlingKo.internal(_root);
	late final TranslationsTagsLocalNewsPowerOutageKo powerOutage = TranslationsTagsLocalNewsPowerOutageKo.internal(_root);
	late final TranslationsTagsLocalNewsWaterOutageKo waterOutage = TranslationsTagsLocalNewsWaterOutageKo.internal(_root);
	late final TranslationsTagsLocalNewsWasteCollectionKo wasteCollection = TranslationsTagsLocalNewsWasteCollectionKo.internal(_root);
	late final TranslationsTagsLocalNewsRoadWorksKo roadWorks = TranslationsTagsLocalNewsRoadWorksKo.internal(_root);
	late final TranslationsTagsLocalNewsPublicFacilityKo publicFacility = TranslationsTagsLocalNewsPublicFacilityKo.internal(_root);
	late final TranslationsTagsLocalNewsWeatherWarningKo weatherWarning = TranslationsTagsLocalNewsWeatherWarningKo.internal(_root);
	late final TranslationsTagsLocalNewsFloodAlertKo floodAlert = TranslationsTagsLocalNewsFloodAlertKo.internal(_root);
	late final TranslationsTagsLocalNewsAirQualityKo airQuality = TranslationsTagsLocalNewsAirQualityKo.internal(_root);
	late final TranslationsTagsLocalNewsDiseaseAlertKo diseaseAlert = TranslationsTagsLocalNewsDiseaseAlertKo.internal(_root);
	late final TranslationsTagsLocalNewsSchoolNoticeKo schoolNotice = TranslationsTagsLocalNewsSchoolNoticeKo.internal(_root);
	late final TranslationsTagsLocalNewsPosyanduKo posyandu = TranslationsTagsLocalNewsPosyanduKo.internal(_root);
	late final TranslationsTagsLocalNewsHealthCampaignKo healthCampaign = TranslationsTagsLocalNewsHealthCampaignKo.internal(_root);
	late final TranslationsTagsLocalNewsTrafficControlKo trafficControl = TranslationsTagsLocalNewsTrafficControlKo.internal(_root);
	late final TranslationsTagsLocalNewsPublicTransportKo publicTransport = TranslationsTagsLocalNewsPublicTransportKo.internal(_root);
	late final TranslationsTagsLocalNewsParkingPolicyKo parkingPolicy = TranslationsTagsLocalNewsParkingPolicyKo.internal(_root);
	late final TranslationsTagsLocalNewsCommunityEventKo communityEvent = TranslationsTagsLocalNewsCommunityEventKo.internal(_root);
	late final TranslationsTagsLocalNewsWorshipEventKo worshipEvent = TranslationsTagsLocalNewsWorshipEventKo.internal(_root);
	late final TranslationsTagsLocalNewsIncidentReportKo incidentReport = TranslationsTagsLocalNewsIncidentReportKo.internal(_root);
}

// Path: boards.popup
class TranslationsBoardsPopupKo {
	TranslationsBoardsPopupKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '동네 게시판이 아직 활성화되지 않았습니다'
	String get inactiveTitle => '동네 게시판이 아직 활성화되지 않았습니다';

	/// ko: '동네 게시판을 열려면 먼저 동네 소식을 한 번 올려 주세요. 이웃들이 참여하면 게시판이 자동으로 열립니다.'
	String get inactiveBody => '동네 게시판을 열려면 먼저 동네 소식을 한 번 올려 주세요. 이웃들이 참여하면 게시판이 자동으로 열립니다.';

	/// ko: '동네 소식 쓰기'
	String get writePost => '동네 소식 쓰기';
}

// Path: signup.alerts
class TranslationsSignupAlertsKo {
	TranslationsSignupAlertsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '회원가입이 완료되었습니다! 이제 로그인해 주세요.'
	String get signupSuccessLoginNotice => '회원가입이 완료되었습니다! 이제 로그인해 주세요.';
}

// Path: signup.buttons
class TranslationsSignupButtonsKo {
	TranslationsSignupButtonsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '회원가입'
	String get signup => '회원가입';
}

// Path: main.search.hint
class TranslationsMainSearchHintKo {
	TranslationsMainSearchHintKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '{}에서 검색'
	String get globalSheet => '{}에서 검색';

	/// ko: '제목·내용·태그 검색'
	String get localNews => '제목·내용·태그 검색';

	/// ko: '직업·회사·도움요청 검색'
	String get jobs => '직업·회사·도움요청 검색';

	/// ko: '분실·습득물 검색'
	String get lostAndFound => '분실·습득물 검색';

	/// ko: '판매 상품 검색'
	String get marketplace => '판매 상품 검색';

	/// ko: '가게·서비스 검색'
	String get localStores => '가게·서비스 검색';

	/// ko: '닉네임·관심사 검색'
	String get findFriends => '닉네임·관심사 검색';

	/// ko: '모임·관심사·위치 검색'
	String get clubs => '모임·관심사·위치 검색';

	/// ko: '매물·지역·가격 검색'
	String get realEstate => '매물·지역·가격 검색';

	/// ko: '경매 물품·브랜드 검색'
	String get auction => '경매 물품·브랜드 검색';

	/// ko: 'POM·태그·사용자 검색'
	String get pom => 'POM·태그·사용자 검색';
}

// Path: drawer.trustDashboard.breakdown
class TranslationsDrawerTrustDashboardBreakdownKo {
	TranslationsDrawerTrustDashboardBreakdownKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '+50'
	String get kelurahanAuth => '+50';

	/// ko: '+50'
	String get rtRwAuth => '+50';

	/// ko: '+100'
	String get phoneAuth => '+100';

	/// ko: '+50'
	String get profileComplete => '+50';

	/// ko: '1회당 +10'
	String get feedThanks => '1회당 +10';

	/// ko: '1회당 +20'
	String get marketThanks => '1회당 +20';

	/// ko: '1회당 -50'
	String get reports => '1회당 -50';
}

// Path: marketplace.takeover.guide
class TranslationsMarketplaceTakeoverGuideKo {
	TranslationsMarketplaceTakeoverGuideKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: 'AI 현장 유사도 검증'
	String get title => 'AI 현장 유사도 검증';

	/// ko: '원래 AI 보고서와 실제 물건이 같은지 확인합니다. 물건의 핵심 특징이 잘 보이도록 3장 이상 촬영해 주세요.'
	String get subtitle => '원래 AI 보고서와 실제 물건이 같은지 확인합니다. 물건의 핵심 특징이 잘 보이도록 3장 이상 촬영해 주세요.';
}

// Path: marketplace.takeover.errors
class TranslationsMarketplaceTakeoverErrorsKo {
	TranslationsMarketplaceTakeoverErrorsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '현장 사진이 최소 1장은 있어야 검증을 진행할 수 있습니다.'
	String get noPhoto => '현장 사진이 최소 1장은 있어야 검증을 진행할 수 있습니다.';
}

// Path: marketplace.takeover.dialog
class TranslationsMarketplaceTakeoverDialogKo {
	TranslationsMarketplaceTakeoverDialogKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: 'AI 검증 성공'
	String get matchTitle => 'AI 검증 성공';

	/// ko: 'AI 검증 실패'
	String get noMatchTitle => 'AI 검증 실패';

	/// ko: '최종 인수 확정'
	String get finalize => '최종 인수 확정';

	/// ko: '거래 취소(환불 요청)'
	String get cancelDeal => '거래 취소(환불 요청)';
}

// Path: marketplace.takeover.success
class TranslationsMarketplaceTakeoverSuccessKo {
	TranslationsMarketplaceTakeoverSuccessKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '거래가 정상적으로 완료되었습니다.'
	String get finalized => '거래가 정상적으로 완료되었습니다.';

	/// ko: '거래가 취소되었습니다. 예약금은 환불됩니다.'
	String get cancelled => '거래가 취소되었습니다. 예약금은 환불됩니다.';
}

// Path: categories.post.jalanPerbaikin
class TranslationsCategoriesPostJalanPerbaikinKo {
	TranslationsCategoriesPostJalanPerbaikinKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsCategoriesPostJalanPerbaikinSearchKo search = TranslationsCategoriesPostJalanPerbaikinSearchKo.internal(_root);

	/// ko: '도로 보수'
	String get name => '도로 보수';
}

// Path: categories.post.dailyLife
class TranslationsCategoriesPostDailyLifeKo {
	TranslationsCategoriesPostDailyLifeKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '일상/질문'
	String get name => '일상/질문';

	/// ko: '일상을 공유하거나 궁금한 점을 물어보세요.'
	String get description => '일상을 공유하거나 궁금한 점을 물어보세요.';
}

// Path: categories.post.helpShare
class TranslationsCategoriesPostHelpShareKo {
	TranslationsCategoriesPostHelpShareKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '도움/나눔'
	String get name => '도움/나눔';

	/// ko: '도움이 필요하거나 나누고 싶은 것이 있을 때 올려 보세요.'
	String get description => '도움이 필요하거나 나누고 싶은 것이 있을 때 올려 보세요.';
}

// Path: categories.post.incidentReport
class TranslationsCategoriesPostIncidentReportKo {
	TranslationsCategoriesPostIncidentReportKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '사건/사고'
	String get name => '사건/사고';

	/// ko: '동네에서 일어난 사건·사고 소식을 공유하세요.'
	String get description => '동네에서 일어난 사건·사고 소식을 공유하세요.';
}

// Path: categories.post.localNews
class TranslationsCategoriesPostLocalNewsKo {
	TranslationsCategoriesPostLocalNewsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '동네 소식'
	String get name => '동네 소식';

	/// ko: '우리 동네 뉴스와 정보를 공유하세요.'
	String get description => '우리 동네 뉴스와 정보를 공유하세요.';
}

// Path: categories.post.november
class TranslationsCategoriesPostNovemberKo {
	TranslationsCategoriesPostNovemberKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '11월'
	String get name => '11월';
}

// Path: categories.post.rain
class TranslationsCategoriesPostRainKo {
	TranslationsCategoriesPostRainKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '비/날씨'
	String get name => '비/날씨';
}

// Path: categories.post.dailyQuestion
class TranslationsCategoriesPostDailyQuestionKo {
	TranslationsCategoriesPostDailyQuestionKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '질문 있어요'
	String get name => '질문 있어요';

	/// ko: '이웃에게 무엇이든 물어보세요.'
	String get description => '이웃에게 무엇이든 물어보세요.';
}

// Path: categories.post.storePromo
class TranslationsCategoriesPostStorePromoKo {
	TranslationsCategoriesPostStorePromoKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '가게 프로모션'
	String get name => '가게 프로모션';

	/// ko: '내 가게 할인이나 이벤트를 홍보하세요.'
	String get description => '내 가게 할인이나 이벤트를 홍보하세요.';
}

// Path: categories.post.etc
class TranslationsCategoriesPostEtcKo {
	TranslationsCategoriesPostEtcKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '기타'
	String get name => '기타';

	/// ko: '그 외 다양한 이야기를 자유롭게 나누세요.'
	String get description => '그 외 다양한 이야기를 자유롭게 나누세요.';
}

// Path: categories.auction.collectibles
class TranslationsCategoriesAuctionCollectiblesKo {
	TranslationsCategoriesAuctionCollectiblesKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '컬렉터블'
	String get name => '컬렉터블';

	/// ko: '피규어, 카드, 장난감 등 수집품.'
	String get description => '피규어, 카드, 장난감 등 수집품.';
}

// Path: categories.auction.digital
class TranslationsCategoriesAuctionDigitalKo {
	TranslationsCategoriesAuctionDigitalKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '디지털'
	String get name => '디지털';

	/// ko: '디지털 상품 및 자산.'
	String get description => '디지털 상품 및 자산.';
}

// Path: categories.auction.fashion
class TranslationsCategoriesAuctionFashionKo {
	TranslationsCategoriesAuctionFashionKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '패션'
	String get name => '패션';

	/// ko: '의류, 액세서리, 뷰티 제품.'
	String get description => '의류, 액세서리, 뷰티 제품.';
}

// Path: categories.auction.vintage
class TranslationsCategoriesAuctionVintageKo {
	TranslationsCategoriesAuctionVintageKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '빈티지'
	String get name => '빈티지';

	/// ko: '레트로·클래식 아이템.'
	String get description => '레트로·클래식 아이템.';
}

// Path: categories.auction.artCraft
class TranslationsCategoriesAuctionArtCraftKo {
	TranslationsCategoriesAuctionArtCraftKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '아트 & 공예'
	String get name => '아트 & 공예';

	/// ko: '작품, 수공예품 등.'
	String get description => '작품, 수공예품 등.';
}

// Path: categories.auction.etc
class TranslationsCategoriesAuctionEtcKo {
	TranslationsCategoriesAuctionEtcKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '기타'
	String get name => '기타';

	/// ko: '그 외 모든 경매 상품.'
	String get description => '그 외 모든 경매 상품.';
}

// Path: clubs.detail.tabs
class TranslationsClubsDetailTabsKo {
	TranslationsClubsDetailTabsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '정보'
	String get info => '정보';

	/// ko: '게시판'
	String get board => '게시판';

	/// ko: '멤버'
	String get members => '멤버';
}

// Path: clubs.detail.info
class TranslationsClubsDetailInfoKo {
	TranslationsClubsDetailInfoKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '멤버'
	String get members => '멤버';

	/// ko: '위치'
	String get location => '위치';
}

// Path: clubs.proposal.detail
class TranslationsClubsProposalDetailKo {
	TranslationsClubsProposalDetailKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '제안에 참여했습니다!'
	String get joined => '제안에 참여했습니다!';

	/// ko: '제안에서 나갔습니다.'
	String get left => '제안에서 나갔습니다.';

	/// ko: '참여하려면 로그인하세요.'
	String get loginRequired => '참여하려면 로그인하세요.';

	/// ko: '오류가 발생했습니다: {error}'
	String get error => '오류가 발생했습니다: {error}';
}

// Path: auctions.create.type
class TranslationsAuctionsCreateTypeKo {
	TranslationsAuctionsCreateTypeKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '판매'
	String get sale => '판매';

	/// ko: '경매'
	String get auction => '경매';
}

// Path: auctions.create.errors
class TranslationsAuctionsCreateErrorsKo {
	TranslationsAuctionsCreateErrorsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '사진을 최소 1장 이상 추가해 주세요.'
	String get noPhoto => '사진을 최소 1장 이상 추가해 주세요.';
}

// Path: auctions.create.form
class TranslationsAuctionsCreateFormKo {
	TranslationsAuctionsCreateFormKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '사진 업로드 (최대 10장)'
	String get photoSectionTitle => '사진 업로드 (최대 10장)';

	/// ko: '제목'
	String get title => '제목';

	/// ko: '설명'
	String get description => '설명';

	/// ko: '시작가'
	String get startPrice => '시작가';

	/// ko: '카테고리'
	String get category => '카테고리';

	/// ko: '카테고리 선택'
	String get categoryHint => '카테고리 선택';

	/// ko: '태그 입력 후 스페이스로 추가'
	String get tagsHint => '태그 입력 후 스페이스로 추가';

	/// ko: '기간'
	String get duration => '기간';

	/// ko: '{days}일'
	String get durationOption => '{days}일';

	/// ko: '위치'
	String get location => '위치';
}

// Path: auctions.detail.errors
class TranslationsAuctionsDetailErrorsKo {
	TranslationsAuctionsDetailErrorsKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '로그인이 필요합니다.'
	String get loginRequired => '로그인이 필요합니다.';

	/// ko: '올바른 입찰 금액을 입력하세요.'
	String get invalidAmount => '올바른 입찰 금액을 입력하세요.';
}

// Path: pom.create.form
class TranslationsPomCreateFormKo {
	TranslationsPomCreateFormKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '제목'
	String get titleLabel => '제목';

	/// ko: '설명'
	String get descriptionLabel => '설명';
}

// Path: admin.reportDetail.content
class TranslationsAdminReportDetailContentKo {
	TranslationsAdminReportDetailContentKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '게시글: {title} {body}'
	String get post => '게시글: {title}\n\n{body}';

	/// ko: '댓글: {content}'
	String get comment => '댓글: {content}';

	/// ko: '답글: {content}'
	String get reply => '답글: {content}';
}

// Path: tags.localNews.kelurahanNotice
class TranslationsTagsLocalNewsKelurahanNoticeKo {
	TranslationsTagsLocalNewsKelurahanNoticeKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: 'Kelurahan 공지'
	String get name => 'Kelurahan 공지';

	/// ko: 'Kelurahan 동사무소에서 올리는 안내입니다.'
	String get desc => 'Kelurahan 동사무소에서 올리는 안내입니다.';
}

// Path: tags.localNews.kecamatanNotice
class TranslationsTagsLocalNewsKecamatanNoticeKo {
	TranslationsTagsLocalNewsKecamatanNoticeKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: 'Kecamatan 공지'
	String get name => 'Kecamatan 공지';

	/// ko: '구청/군청(Kecamatan)에서 올리는 안내입니다.'
	String get desc => '구청/군청(Kecamatan)에서 올리는 안내입니다.';
}

// Path: tags.localNews.publicCampaign
class TranslationsTagsLocalNewsPublicCampaignKo {
	TranslationsTagsLocalNewsPublicCampaignKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '공익 캠페인'
	String get name => '공익 캠페인';

	/// ko: '공익 정보와 정부 프로그램 안내입니다.'
	String get desc => '공익 정보와 정부 프로그램 안내입니다.';
}

// Path: tags.localNews.siskamling
class TranslationsTagsLocalNewsSiskamlingKo {
	TranslationsTagsLocalNewsSiskamlingKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '동네 방범'
	String get name => '동네 방범';

	/// ko: '주민 자율 방범·순찰 활동입니다.'
	String get desc => '주민 자율 방범·순찰 활동입니다.';
}

// Path: tags.localNews.powerOutage
class TranslationsTagsLocalNewsPowerOutageKo {
	TranslationsTagsLocalNewsPowerOutageKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '정전 정보'
	String get name => '정전 정보';

	/// ko: '내 동네 전기 끊김·정전 안내입니다.'
	String get desc => '내 동네 전기 끊김·정전 안내입니다.';
}

// Path: tags.localNews.waterOutage
class TranslationsTagsLocalNewsWaterOutageKo {
	TranslationsTagsLocalNewsWaterOutageKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '단수 정보'
	String get name => '단수 정보';

	/// ko: '수도 공급 중단 안내입니다.'
	String get desc => '수도 공급 중단 안내입니다.';
}

// Path: tags.localNews.wasteCollection
class TranslationsTagsLocalNewsWasteCollectionKo {
	TranslationsTagsLocalNewsWasteCollectionKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '쓰레기 수거'
	String get name => '쓰레기 수거';

	/// ko: '쓰레기 수거 일정이나 변경 안내입니다.'
	String get desc => '쓰레기 수거 일정이나 변경 안내입니다.';
}

// Path: tags.localNews.roadWorks
class TranslationsTagsLocalNewsRoadWorksKo {
	TranslationsTagsLocalNewsRoadWorksKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '도로 공사'
	String get name => '도로 공사';

	/// ko: '도로 공사 및 보수 작업 안내입니다.'
	String get desc => '도로 공사 및 보수 작업 안내입니다.';
}

// Path: tags.localNews.publicFacility
class TranslationsTagsLocalNewsPublicFacilityKo {
	TranslationsTagsLocalNewsPublicFacilityKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '공공시설'
	String get name => '공공시설';

	/// ko: '공원, 운동장 등 공공시설 관련 소식입니다.'
	String get desc => '공원, 운동장 등 공공시설 관련 소식입니다.';
}

// Path: tags.localNews.weatherWarning
class TranslationsTagsLocalNewsWeatherWarningKo {
	TranslationsTagsLocalNewsWeatherWarningKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '기상 특보'
	String get name => '기상 특보';

	/// ko: '내 동네 악천후·기상 특보 안내입니다.'
	String get desc => '내 동네 악천후·기상 특보 안내입니다.';
}

// Path: tags.localNews.floodAlert
class TranslationsTagsLocalNewsFloodAlertKo {
	TranslationsTagsLocalNewsFloodAlertKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '홍수 경보'
	String get name => '홍수 경보';

	/// ko: '홍수 위험 및 침수 지역 안내입니다.'
	String get desc => '홍수 위험 및 침수 지역 안내입니다.';
}

// Path: tags.localNews.airQuality
class TranslationsTagsLocalNewsAirQualityKo {
	TranslationsTagsLocalNewsAirQualityKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '대기질'
	String get name => '대기질';

	/// ko: '미세먼지 등 대기오염·AQI 정보입니다.'
	String get desc => '미세먼지 등 대기오염·AQI 정보입니다.';
}

// Path: tags.localNews.diseaseAlert
class TranslationsTagsLocalNewsDiseaseAlertKo {
	TranslationsTagsLocalNewsDiseaseAlertKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '질병 경보'
	String get name => '질병 경보';

	/// ko: '감염병 경보와 보건 관련 안내입니다.'
	String get desc => '감염병 경보와 보건 관련 안내입니다.';
}

// Path: tags.localNews.schoolNotice
class TranslationsTagsLocalNewsSchoolNoticeKo {
	TranslationsTagsLocalNewsSchoolNoticeKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '학교 공지'
	String get name => '학교 공지';

	/// ko: '주변 학교에서 올리는 안내입니다.'
	String get desc => '주변 학교에서 올리는 안내입니다.';
}

// Path: tags.localNews.posyandu
class TranslationsTagsLocalNewsPosyanduKo {
	TranslationsTagsLocalNewsPosyanduKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: 'Posyandu'
	String get name => 'Posyandu';

	/// ko: '지역 보건소, 영유아·산모 대상 활동 안내입니다.'
	String get desc => '지역 보건소, 영유아·산모 대상 활동 안내입니다.';
}

// Path: tags.localNews.healthCampaign
class TranslationsTagsLocalNewsHealthCampaignKo {
	TranslationsTagsLocalNewsHealthCampaignKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '보건 캠페인'
	String get name => '보건 캠페인';

	/// ko: '건강 캠페인 및 공중보건 안내입니다.'
	String get desc => '건강 캠페인 및 공중보건 안내입니다.';
}

// Path: tags.localNews.trafficControl
class TranslationsTagsLocalNewsTrafficControlKo {
	TranslationsTagsLocalNewsTrafficControlKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '교통 통제'
	String get name => '교통 통제';

	/// ko: '우회로, 도로 통제, 차단 정보입니다.'
	String get desc => '우회로, 도로 통제, 차단 정보입니다.';
}

// Path: tags.localNews.publicTransport
class TranslationsTagsLocalNewsPublicTransportKo {
	TranslationsTagsLocalNewsPublicTransportKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '대중교통'
	String get name => '대중교통';

	/// ko: '버스·기차 등 대중교통 관련 안내입니다.'
	String get desc => '버스·기차 등 대중교통 관련 안내입니다.';
}

// Path: tags.localNews.parkingPolicy
class TranslationsTagsLocalNewsParkingPolicyKo {
	TranslationsTagsLocalNewsParkingPolicyKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '주차 정책'
	String get name => '주차 정책';

	/// ko: '주차 정보 및 정책 변경 안내입니다.'
	String get desc => '주차 정보 및 정책 변경 안내입니다.';
}

// Path: tags.localNews.communityEvent
class TranslationsTagsLocalNewsCommunityEventKo {
	TranslationsTagsLocalNewsCommunityEventKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '지역 행사'
	String get name => '지역 행사';

	/// ko: '동네 축제, 모임, 행사 안내입니다.'
	String get desc => '동네 축제, 모임, 행사 안내입니다.';
}

// Path: tags.localNews.worshipEvent
class TranslationsTagsLocalNewsWorshipEventKo {
	TranslationsTagsLocalNewsWorshipEventKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '종교 행사'
	String get name => '종교 행사';

	/// ko: '모스크, 교회, 사원 등 종교 행사 안내입니다.'
	String get desc => '모스크, 교회, 사원 등 종교 행사 안내입니다.';
}

// Path: tags.localNews.incidentReport
class TranslationsTagsLocalNewsIncidentReportKo {
	TranslationsTagsLocalNewsIncidentReportKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: '사건·사고 제보'
	String get name => '사건·사고 제보';

	/// ko: '우리 동네에서 발생한 사건·사고 제보입니다.'
	String get desc => '우리 동네에서 발생한 사건·사고 제보입니다.';
}

// Path: categories.post.jalanPerbaikin.search
class TranslationsCategoriesPostJalanPerbaikinSearchKo {
	TranslationsCategoriesPostJalanPerbaikinSearchKo.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// ko: 'POM, 태그, 사용자 검색'
	String get hint => 'POM, 태그, 사용자 검색';
}

/// The flat map containing all translations for locale <ko>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
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
			'realEstate.title' => '부동산',
			'realEstate.tabs.all' => '전체',
			'realEstate.tabs.rent' => '임대',
			'realEstate.tabs.sale' => '매매',
			'realEstate.tabs.myListings' => '내 매물',
			'realEstate.setLocationPrompt' => '근처 매물을 보려면 위치를 설정해 주세요.',
			'realEstate.empty' => '등록된 매물이 없습니다.',
			'realEstate.error' => '오류가 발생했습니다: {error}',
			'realEstate.create.tooltip' => '매물 등록',
			'realEstate.create.title' => '새 매물 등록',
			'realEstate.create.submit' => '등록',
			'realEstate.create.success' => '매물이 등록되었습니다.',
			'realEstate.create.fail' => '매물 등록 실패: {error}',
			'realEstate.edit.title' => '매물 수정',
			'realEstate.edit.save' => '저장',
			'realEstate.edit.success' => '매물이 수정되었습니다.',
			'realEstate.edit.fail' => '매물 수정 실패: {error}',
			'realEstate.edit.tooltip' => '매물 수정',
			'realEstate.form.titleLabel' => '제목',
			'realEstate.form.titleError' => '제목을 입력해 주세요.',
			'realEstate.form.descriptionLabel' => '설명',
			'realEstate.form.descriptionError' => '설명을 입력해 주세요.',
			'realEstate.form.priceLabel' => '가격 (IDR)',
			'realEstate.form.priceError' => '가격을 입력해 주세요.',
			'realEstate.form.categoryLabel' => '유형',
			'realEstate.form.categoryError' => '유형을 선택해 주세요.',
			'realEstate.form.locationLabel' => '위치',
			'realEstate.form.locationError' => '위치를 입력해 주세요.',
			'realEstate.form.roomsLabel' => '방 개수',
			'realEstate.form.bathLabel' => '욕실 개수',
			'realEstate.form.areaLabel' => '면적 (m²)',
			'realEstate.form.photoLabel' => '사진 (최대 10장)',
			'realEstate.form.imageError' => '이미지를 불러올 수 없습니다.',
			'realEstate.categories.house' => '주택',
			'realEstate.categories.apartment' => '아파트',
			'realEstate.categories.kost' => 'Kost',
			'realEstate.categories.villa' => '빌라',
			'realEstate.categories.office' => '사무실',
			'realEstate.categories.land' => '토지',
			'realEstate.categories.shophouse' => '상가',
			'realEstate.categories.warehouse' => '창고',
			'realEstate.categories.etc' => '기타',
			'realEstate.detail.price' => '가격',
			'realEstate.detail.rooms' => '방',
			'realEstate.detail.bathrooms' => '욕실',
			'realEstate.detail.area' => '면적',
			'realEstate.detail.location' => '위치',
			'realEstate.detail.contactSeller' => '판매자에게 문의',
			'realEstate.detail.contactFail' => '채팅을 시작할 수 없습니다: {error}',
			'realEstate.detail.delete' => '삭제',
			'realEstate.detail.deleteConfirm' => '이 매물을 삭제하시겠습니까?',
			'realEstate.detail.deleteSuccess' => '매물이 삭제되었습니다.',
			'realEstate.detail.deleteFail' => '매물 삭제 실패: {error}',
			'realEstate.detail.postedBy' => '등록자',
			'lostAndFound.title' => '분실 · 습득',
			'lostAndFound.tabs.lost' => '분실',
			'lostAndFound.tabs.found' => '습득',
			'lostAndFound.tabs.myReports' => '내 글',
			'lostAndFound.empty' => '등록된 글이 없습니다.',
			'lostAndFound.setLocationPrompt' => '근처 신고를 보려면 위치를 설정해 주세요.',
			'lostAndFound.create.tooltip' => '글 등록',
			'lostAndFound.create.title' => '새 글 등록',
			'lostAndFound.create.submit' => '등록',
			'lostAndFound.create.success' => '글이 등록되었습니다.',
			'lostAndFound.create.fail' => '등록 실패: {error}',
			'lostAndFound.edit.title' => '글 수정',
			'lostAndFound.edit.save' => '저장',
			'lostAndFound.edit.success' => '글이 수정되었습니다.',
			'lostAndFound.edit.fail' => '글 수정 실패: {error}',
			'lostAndFound.form.titleLabel' => '제목',
			'lostAndFound.form.titleError' => '제목을 입력해 주세요.',
			'lostAndFound.form.descriptionLabel' => '상세 내용',
			'lostAndFound.form.descriptionError' => '상세 내용을 입력해 주세요.',
			'lostAndFound.form.categoryLabel' => '유형',
			'lostAndFound.form.categoryError' => '유형을 선택해 주세요.',
			'lostAndFound.form.locationLabel' => '위치',
			'lostAndFound.form.locationError' => '위치를 입력해 주세요.',
			'lostAndFound.form.photoLabel' => '사진 (최대 10장)',
			'lostAndFound.categories.pet' => '반려동물',
			'lostAndFound.categories.item' => '개인 소지품',
			'lostAndFound.categories.person' => '사람',
			'lostAndFound.categories.scam' => '사기 피해',
			_ => null,
		} ?? switch (path) {
			'lostAndFound.categories.etc' => '기타',
			'lostAndFound.detail.location' => '위치',
			'lostAndFound.detail.contact' => '문의하기',
			'lostAndFound.detail.contactFail' => '채팅을 시작할 수 없습니다: {error}',
			'lostAndFound.detail.delete' => '삭제',
			'lostAndFound.detail.deleteConfirm' => '이 글을 삭제하시겠습니까?',
			'lostAndFound.detail.deleteSuccess' => '삭제되었습니다.',
			'lostAndFound.detail.deleteFail' => '삭제 실패: {error}',
			'community.title' => '커뮤니티',
			'community.empty' => '아직 게시물이 없습니다.',
			'community.error' => '오류가 발생했습니다: {error}',
			'community.create.title' => '새 글',
			'community.create.submit' => '등록',
			'community.create.success' => '게시글이 등록되었습니다.',
			'community.create.fail' => '등록 실패: {error}',
			'community.edit.title' => '게시글 수정',
			'community.edit.save' => '저장',
			'community.edit.success' => '게시글이 수정되었습니다.',
			'community.edit.fail' => '수정 실패: {error}',
			'community.post.delete' => '삭제',
			'community.post.deleteConfirm' => '이 게시글을 삭제하시겠습니까?',
			'community.post.deleteSuccess' => '삭제되었습니다.',
			'community.post.deleteFail' => '삭제 실패: {error}',
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
			_ => null,
		};
	}
}
