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
class TranslationsEn extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsEn({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.en,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <en>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsEn _root = this; // ignore: unused_field

	@override 
	TranslationsEn $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsEn(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsLoginEn login = _TranslationsLoginEn._(_root);
	@override late final _TranslationsMainEn main = _TranslationsMainEn._(_root);
	@override late final _TranslationsSearchEn search = _TranslationsSearchEn._(_root);
	@override late final _TranslationsDrawerEn drawer = _TranslationsDrawerEn._(_root);
	@override late final _TranslationsMarketplaceEn marketplace = _TranslationsMarketplaceEn._(_root);
	@override late final _TranslationsAiFlowEn aiFlow = _TranslationsAiFlowEn._(_root);
	@override late final _TranslationsRegistrationFlowEn registrationFlow = _TranslationsRegistrationFlowEn._(_root);
	@override late final _TranslationsMyBlingEn myBling = _TranslationsMyBlingEn._(_root);
	@override late final _TranslationsProfileViewEn profileView = _TranslationsProfileViewEn._(_root);
	@override late final _TranslationsSettingsEn settings = _TranslationsSettingsEn._(_root);
	@override late final _TranslationsFriendRequestsEn friendRequests = _TranslationsFriendRequestsEn._(_root);
	@override late final _TranslationsSentFriendRequestsEn sentFriendRequests = _TranslationsSentFriendRequestsEn._(_root);
	@override late final _TranslationsBlockedUsersEn blockedUsers = _TranslationsBlockedUsersEn._(_root);
	@override late final _TranslationsRejectedUsersEn rejectedUsers = _TranslationsRejectedUsersEn._(_root);
	@override late final _TranslationsPromptEn prompt = _TranslationsPromptEn._(_root);
	@override late final _TranslationsLocationEn location = _TranslationsLocationEn._(_root);
	@override late final _TranslationsProfileEditEn profileEdit = _TranslationsProfileEditEn._(_root);
	@override late final _TranslationsMainFeedEn mainFeed = _TranslationsMainFeedEn._(_root);
	@override late final _TranslationsPostCardEn postCard = _TranslationsPostCardEn._(_root);
	@override late final _TranslationsTimeEn time = _TranslationsTimeEn._(_root);
	@override late final _TranslationsProductCardEn productCard = _TranslationsProductCardEn._(_root);
	@override late final _TranslationsLocalNewsFeedEn localNewsFeed = _TranslationsLocalNewsFeedEn._(_root);
	@override late final _TranslationsCategoriesEn categories = _TranslationsCategoriesEn._(_root);
	@override late final _TranslationsLocalNewsCreateEn localNewsCreate = _TranslationsLocalNewsCreateEn._(_root);
	@override late final _TranslationsLocalNewsDetailEn localNewsDetail = _TranslationsLocalNewsDetailEn._(_root);
	@override late final _TranslationsLocalNewsEditEn localNewsEdit = _TranslationsLocalNewsEditEn._(_root);
	@override late final _TranslationsCommentInputFieldEn commentInputField = _TranslationsCommentInputFieldEn._(_root);
	@override late final _TranslationsCommentListViewEn commentListView = _TranslationsCommentListViewEn._(_root);
	@override late final _TranslationsCommonEn common = _TranslationsCommonEn._(_root);
	@override late final _TranslationsReportDialogEn reportDialog = _TranslationsReportDialogEn._(_root);
	@override late final _TranslationsReplyDeleteEn replyDelete = _TranslationsReplyDeleteEn._(_root);
	@override late final _TranslationsReportReasonsEn reportReasons = _TranslationsReportReasonsEn._(_root);
	@override late final _TranslationsDeleteConfirmEn deleteConfirm = _TranslationsDeleteConfirmEn._(_root);
	@override late final _TranslationsReplyInputFieldEn replyInputField = _TranslationsReplyInputFieldEn._(_root);
	@override late final _TranslationsChatListEn chatList = _TranslationsChatListEn._(_root);
	@override late final _TranslationsChatRoomEn chatRoom = _TranslationsChatRoomEn._(_root);
	@override late final _TranslationsJobsEn jobs = _TranslationsJobsEn._(_root);
	@override late final _TranslationsFindFriendEn findFriend = _TranslationsFindFriendEn._(_root);
	@override late final _TranslationsInterestsEn interests = _TranslationsInterestsEn._(_root);
	@override late final _TranslationsFriendDetailEn friendDetail = _TranslationsFriendDetailEn._(_root);
	@override late final _TranslationsLocationFilterEn locationFilter = _TranslationsLocationFilterEn._(_root);
	@override late final _TranslationsClubsEn clubs = _TranslationsClubsEn._(_root);
	@override late final _TranslationsFindfriendEn findfriend = _TranslationsFindfriendEn._(_root);
	@override late final _TranslationsAuctionsEn auctions = _TranslationsAuctionsEn._(_root);
	@override late final _TranslationsLocalStoresEn localStores = _TranslationsLocalStoresEn._(_root);
	@override late final _TranslationsPomEn pom = _TranslationsPomEn._(_root);
	@override late final _TranslationsRealEstateEn realEstate = _TranslationsRealEstateEn._(_root);
	@override late final _TranslationsLostAndFoundEn lostAndFound = _TranslationsLostAndFoundEn._(_root);
	@override late final _TranslationsCommunityEn community = _TranslationsCommunityEn._(_root);
	@override late final _TranslationsSharedEn shared = _TranslationsSharedEn._(_root);
	@override late final _TranslationsLinkPreviewEn linkPreview = _TranslationsLinkPreviewEn._(_root);
	@override String get selectCategory => 'Select category';
	@override String get addressNeighborhood => 'Neighborhood';
	@override String get addressDetailHint => 'Address details';
	@override late final _TranslationsLocalNewsTagResultEn localNewsTagResult = _TranslationsLocalNewsTagResultEn._(_root);
	@override late final _TranslationsAdminEn admin = _TranslationsAdminEn._(_root);
	@override late final _TranslationsTagsEn tags = _TranslationsTagsEn._(_root);
	@override late final _TranslationsBoardsEn boards = _TranslationsBoardsEn._(_root);
	@override String get locationSettingError => 'Failed to set location.';
	@override String get signupFailRequired => 'This field is required.';
	@override String get signupFailPasswordMismatch => 'Passwords do not match.';
	@override late final _TranslationsSignupEn signup = _TranslationsSignupEn._(_root);
	@override String get signupFailDefault => 'Sign up failed.';
	@override String get signupFailWeakPassword => 'Password is too weak.';
	@override String get signupFailEmailInUse => 'Email is already in use.';
	@override String get signupFailInvalidEmail => 'Invalid email format.';
	@override String get signupFailUnknown => 'An unknown error occurred.';
	@override String get categoryEmpty => 'No Category';
	@override late final _TranslationsUserEn user = _TranslationsUserEn._(_root);
}

// Path: login
class _TranslationsLoginEn extends TranslationsLoginId {
	_TranslationsLoginEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Log In';
	@override String get subtitle => 'Buy and sell lightly with Bling!';
	@override String get emailHint => 'Email Address';
	@override String get passwordHint => 'Password';
	@override late final _TranslationsLoginButtonsEn buttons = _TranslationsLoginButtonsEn._(_root);
	@override late final _TranslationsLoginLinksEn links = _TranslationsLoginLinksEn._(_root);
	@override late final _TranslationsLoginAlertsEn alerts = _TranslationsLoginAlertsEn._(_root);
}

// Path: main
class _TranslationsMainEn extends TranslationsMainId {
	_TranslationsMainEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsMainAppBarEn appBar = _TranslationsMainAppBarEn._(_root);
	@override late final _TranslationsMainTabsEn tabs = _TranslationsMainTabsEn._(_root);
	@override late final _TranslationsMainBottomNavEn bottomNav = _TranslationsMainBottomNavEn._(_root);
	@override late final _TranslationsMainErrorsEn errors = _TranslationsMainErrorsEn._(_root);
	@override String get myTown => 'My Town';
	@override late final _TranslationsMainMapViewEn mapView = _TranslationsMainMapViewEn._(_root);
	@override late final _TranslationsMainSearchEn search = _TranslationsMainSearchEn._(_root);
}

// Path: search
class _TranslationsSearchEn extends TranslationsSearchId {
	_TranslationsSearchEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get resultsTitle => 'Results for \'{keyword}\'';
	@override late final _TranslationsSearchEmptyEn empty = _TranslationsSearchEmptyEn._(_root);
	@override String get prompt => 'Type a keyword';
	@override late final _TranslationsSearchSheetEn sheet = _TranslationsSearchSheetEn._(_root);
	@override String get results => 'results';
}

// Path: drawer
class _TranslationsDrawerEn extends TranslationsDrawerId {
	_TranslationsDrawerEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get editProfile => 'Edit Profile';
	@override String get bookmarks => 'Bookmarks';
	@override String get uploadSampleData => 'Upload Sample Data';
	@override String get logout => 'Log Out';
	@override late final _TranslationsDrawerTrustDashboardEn trustDashboard = _TranslationsDrawerTrustDashboardEn._(_root);
	@override String get runDataFix => 'Run Data Fix';
}

// Path: marketplace
class _TranslationsMarketplaceEn extends TranslationsMarketplaceId {
	_TranslationsMarketplaceEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get error => 'An error occurred: {error}';
	@override String get empty => 'No products yet.\nTap the + button to add your first one!';
	@override late final _TranslationsMarketplaceRegistrationEn registration = _TranslationsMarketplaceRegistrationEn._(_root);
	@override late final _TranslationsMarketplaceEditEn edit = _TranslationsMarketplaceEditEn._(_root);
	@override late final _TranslationsMarketplaceDetailEn detail = _TranslationsMarketplaceDetailEn._(_root);
	@override late final _TranslationsMarketplaceDialogEn dialog = _TranslationsMarketplaceDialogEn._(_root);
	@override late final _TranslationsMarketplaceErrorsEn errors = _TranslationsMarketplaceErrorsEn._(_root);
	@override late final _TranslationsMarketplaceConditionEn condition = _TranslationsMarketplaceConditionEn._(_root);
	@override late final _TranslationsMarketplaceReservationEn reservation = _TranslationsMarketplaceReservationEn._(_root);
	@override late final _TranslationsMarketplaceStatusEn status = _TranslationsMarketplaceStatusEn._(_root);
	@override late final _TranslationsMarketplaceAiEn ai = _TranslationsMarketplaceAiEn._(_root);
	@override late final _TranslationsMarketplaceTakeoverEn takeover = _TranslationsMarketplaceTakeoverEn._(_root);
	@override String get aiBadge => 'AI verified';
	@override String get setLocationPrompt => 'Set your neighborhood first to see preloved items!';
}

// Path: aiFlow
class _TranslationsAiFlowEn extends TranslationsAiFlowId {
	_TranslationsAiFlowEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsAiFlowCommonEn common = _TranslationsAiFlowCommonEn._(_root);
	@override late final _TranslationsAiFlowCtaEn cta = _TranslationsAiFlowCtaEn._(_root);
	@override late final _TranslationsAiFlowCategorySelectionEn categorySelection = _TranslationsAiFlowCategorySelectionEn._(_root);
	@override late final _TranslationsAiFlowGalleryUploadEn galleryUpload = _TranslationsAiFlowGalleryUploadEn._(_root);
	@override late final _TranslationsAiFlowPredictionEn prediction = _TranslationsAiFlowPredictionEn._(_root);
	@override late final _TranslationsAiFlowGuidedCameraEn guidedCamera = _TranslationsAiFlowGuidedCameraEn._(_root);
	@override late final _TranslationsAiFlowFinalReportEn finalReport = _TranslationsAiFlowFinalReportEn._(_root);
	@override late final _TranslationsAiFlowEvidenceEn evidence = _TranslationsAiFlowEvidenceEn._(_root);
	@override late final _TranslationsAiFlowErrorEn error = _TranslationsAiFlowErrorEn._(_root);
}

// Path: registrationFlow
class _TranslationsRegistrationFlowEn extends TranslationsRegistrationFlowId {
	_TranslationsRegistrationFlowEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Choose Item Type to Sell';
	@override String get newItemTitle => 'Register New and Used Items';
	@override String get newItemDesc => 'Quickly register unused items and general used items.';
	@override String get usedItemTitle => 'Used Items (AI Verification)';
	@override String get usedItemDesc => 'AI analyzes your item to build trust and help you sell.';
}

// Path: myBling
class _TranslationsMyBlingEn extends TranslationsMyBlingId {
	_TranslationsMyBlingEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'My Bling';
	@override String get editProfile => 'Edit Profile';
	@override String get settings => 'Settings';
	@override String get posts => 'Posts';
	@override String get followers => 'Followers';
	@override String get neighbors => 'Neighbors';
	@override String get friends => 'Friends';
	@override late final _TranslationsMyBlingStatsEn stats = _TranslationsMyBlingStatsEn._(_root);
	@override late final _TranslationsMyBlingTabsEn tabs = _TranslationsMyBlingTabsEn._(_root);
	@override String get friendRequests => 'Received Friend Requests';
	@override String get sentFriendRequests => 'Sent Requests';
}

// Path: profileView
class _TranslationsProfileViewEn extends TranslationsProfileViewId {
	_TranslationsProfileViewEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Profile';
	@override late final _TranslationsProfileViewTabsEn tabs = _TranslationsProfileViewTabsEn._(_root);
	@override String get noPosts => 'No posts yet.';
	@override String get noInterests => 'No interests set.';
}

// Path: settings
class _TranslationsSettingsEn extends TranslationsSettingsId {
	_TranslationsSettingsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Settings';
	@override String get accountPrivacy => 'Account & Privacy';
	@override late final _TranslationsSettingsNotificationsEn notifications = _TranslationsSettingsNotificationsEn._(_root);
	@override String get appInfo => 'App Info';
}

// Path: friendRequests
class _TranslationsFriendRequestsEn extends TranslationsFriendRequestsId {
	_TranslationsFriendRequestsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Received Friend Requests';
	@override String get noRequests => 'No friend requests received.';
	@override String get acceptSuccess => 'Friend request accepted.';
	@override String get rejectSuccess => 'Friend request rejected.';
	@override String get error => 'An error occurred: {error}';
	@override late final _TranslationsFriendRequestsTooltipEn tooltip = _TranslationsFriendRequestsTooltipEn._(_root);
	@override String get defaultChatMessage => 'You’re now friends! Start a conversation.';
}

// Path: sentFriendRequests
class _TranslationsSentFriendRequestsEn extends TranslationsSentFriendRequestsId {
	_TranslationsSentFriendRequestsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Sent Friend Requests';
	@override String get noRequests => 'No friend requests sent.';
	@override String get statusLabel => 'Status: {status}';
	@override late final _TranslationsSentFriendRequestsStatusEn status = _TranslationsSentFriendRequestsStatusEn._(_root);
}

// Path: blockedUsers
class _TranslationsBlockedUsersEn extends TranslationsBlockedUsersId {
	_TranslationsBlockedUsersEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Blocked Users';
	@override String get noBlockedUsers => 'You haven’t blocked anyone.';
	@override String get unblock => 'Unblock';
	@override late final _TranslationsBlockedUsersUnblockDialogEn unblockDialog = _TranslationsBlockedUsersUnblockDialogEn._(_root);
	@override String get unblockSuccess => 'Unblocked {nickname}.';
	@override String get unblockFailure => 'Failed to unblock: {error}';
	@override String get unknownUser => 'Unknown user';
	@override String get empty => 'No blocked users.';
}

// Path: rejectedUsers
class _TranslationsRejectedUsersEn extends TranslationsRejectedUsersId {
	_TranslationsRejectedUsersEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Manage Rejected Users';
	@override String get noRejectedUsers => 'No friend requests you rejected.';
	@override String get unreject => 'Undo Reject';
	@override late final _TranslationsRejectedUsersUnrejectDialogEn unrejectDialog = _TranslationsRejectedUsersUnrejectDialogEn._(_root);
	@override String get unrejectSuccess => 'Undo reject for {nickname} completed.';
	@override String get unrejectFailure => 'Failed to undo reject: {error}';
}

// Path: prompt
class _TranslationsPromptEn extends TranslationsPromptId {
	_TranslationsPromptEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Welcome to Bling!';
	@override String get subtitle => 'To see nearby news and items, please set your neighborhood first.';
	@override String get button => 'Set My Neighborhood';
}

// Path: location
class _TranslationsLocationEn extends TranslationsLocationId {
	_TranslationsLocationEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Set Neighborhood';
	@override String get searchHint => 'Search by neighborhood, e.g., Serpong';
	@override String get gpsButton => 'Use current location';
	@override String get success => 'Neighborhood set.';
	@override String get error => 'Failed to set neighborhood: {error}';
	@override String get empty => 'Please enter a neighborhood name.';
	@override String get permissionDenied => 'Location permission is required to find your neighborhood.';
	@override String get rtLabel => 'RT';
	@override String get rwLabel => 'RW';
	@override String get rtHint => 'e.g. 003';
	@override String get rwHint => 'e.g. 007';
	@override String get rtRequired => 'Please enter RT.';
	@override String get rwRequired => 'Please enter RW.';
	@override String get rtRwInfo => 'Your RT/RW won’t be public. It’s only used to improve trust and local features.';
	@override String get saveThisLocation => 'Save this location';
	@override String get manualSelect => 'Select manually';
	@override String get refreshFromGps => 'Refresh from GPS';
}

// Path: profileEdit
class _TranslationsProfileEditEn extends TranslationsProfileEditId {
	_TranslationsProfileEditEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Profile Settings';
	@override String get nicknameHint => 'Nickname';
	@override String get phoneHint => 'Phone Number';
	@override String get bioHint => 'Bio';
	@override String get locationTitle => 'Location';
	@override String get changeLocation => 'Change';
	@override String get locationNotSet => 'Not set';
	@override late final _TranslationsProfileEditInterestsEn interests = _TranslationsProfileEditInterestsEn._(_root);
	@override late final _TranslationsProfileEditPrivacyEn privacy = _TranslationsProfileEditPrivacyEn._(_root);
	@override String get saveButton => 'Save Changes';
	@override String get successMessage => 'Profile updated successfully.';
	@override late final _TranslationsProfileEditErrorsEn errors = _TranslationsProfileEditErrorsEn._(_root);
}

// Path: mainFeed
class _TranslationsMainFeedEn extends TranslationsMainFeedId {
	_TranslationsMainFeedEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get error => 'An error occurred: {error}';
	@override String get empty => 'No new posts.';
}

// Path: postCard
class _TranslationsPostCardEn extends TranslationsPostCardId {
	_TranslationsPostCardEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get locationNotSet => 'Location not set';
	@override String get location => 'Location';
	@override String get authorNotFound => 'Author not found';
}

// Path: time
class _TranslationsTimeEn extends TranslationsTimeId {
	_TranslationsTimeEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get now => 'Just now';
	@override String get minutesAgo => '{minutes} minutes ago';
	@override String get hoursAgo => '{hours} hours ago';
	@override String get daysAgo => '{days} days ago';
	@override String get dateFormat => 'yy.MM.dd';
	@override String get dateFormatLong => 'MMM d';
}

// Path: productCard
class _TranslationsProductCardEn extends TranslationsProductCardId {
	_TranslationsProductCardEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get currency => '\$';
}

// Path: localNewsFeed
class _TranslationsLocalNewsFeedEn extends TranslationsLocalNewsFeedId {
	_TranslationsLocalNewsFeedEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get setLocationPrompt => 'Set your neighborhood to see local stories!';
	@override String get allCategory => 'All';
	@override String get empty => 'No posts to show.';
	@override String get error => 'An error occurred: {error}';
}

// Path: categories
class _TranslationsCategoriesEn extends TranslationsCategoriesId {
	_TranslationsCategoriesEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsCategoriesPostEn post = _TranslationsCategoriesPostEn._(_root);
	@override late final _TranslationsCategoriesAuctionEn auction = _TranslationsCategoriesAuctionEn._(_root);
}

// Path: localNewsCreate
class _TranslationsLocalNewsCreateEn extends TranslationsLocalNewsCreateId {
	_TranslationsLocalNewsCreateEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get appBarTitle => 'Create New Post';
	@override String get title => 'Create New Post';
	@override late final _TranslationsLocalNewsCreateFormEn form = _TranslationsLocalNewsCreateFormEn._(_root);
	@override late final _TranslationsLocalNewsCreateLabelsEn labels = _TranslationsLocalNewsCreateLabelsEn._(_root);
	@override late final _TranslationsLocalNewsCreateHintsEn hints = _TranslationsLocalNewsCreateHintsEn._(_root);
	@override late final _TranslationsLocalNewsCreateValidationEn validation = _TranslationsLocalNewsCreateValidationEn._(_root);
	@override late final _TranslationsLocalNewsCreateButtonsEn buttons = _TranslationsLocalNewsCreateButtonsEn._(_root);
	@override late final _TranslationsLocalNewsCreateAlertsEn alerts = _TranslationsLocalNewsCreateAlertsEn._(_root);
	@override String get success => 'Post created successfully.';
	@override String get fail => 'Failed to create post: {error}';
}

// Path: localNewsDetail
class _TranslationsLocalNewsDetailEn extends TranslationsLocalNewsDetailId {
	_TranslationsLocalNewsDetailEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get appBarTitle => 'Post';
	@override late final _TranslationsLocalNewsDetailMenuEn menu = _TranslationsLocalNewsDetailMenuEn._(_root);
	@override late final _TranslationsLocalNewsDetailStatsEn stats = _TranslationsLocalNewsDetailStatsEn._(_root);
	@override late final _TranslationsLocalNewsDetailButtonsEn buttons = _TranslationsLocalNewsDetailButtonsEn._(_root);
	@override String get confirmDelete => 'Are you sure you want to delete this post?';
	@override String get deleted => 'Post deleted.';
}

// Path: localNewsEdit
class _TranslationsLocalNewsEditEn extends TranslationsLocalNewsEditId {
	_TranslationsLocalNewsEditEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get appBarTitle => 'Edit Post';
	@override late final _TranslationsLocalNewsEditButtonsEn buttons = _TranslationsLocalNewsEditButtonsEn._(_root);
	@override late final _TranslationsLocalNewsEditAlertsEn alerts = _TranslationsLocalNewsEditAlertsEn._(_root);
}

// Path: commentInputField
class _TranslationsCommentInputFieldEn extends TranslationsCommentInputFieldId {
	_TranslationsCommentInputFieldEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get secretCommentLabel => 'Secret';
	@override String get hintText => 'Enter a comment...';
	@override String get replyHintText => 'Replying to {nickname}...';
	@override late final _TranslationsCommentInputFieldButtonEn button = _TranslationsCommentInputFieldButtonEn._(_root);
}

// Path: commentListView
class _TranslationsCommentListViewEn extends TranslationsCommentListViewId {
	_TranslationsCommentListViewEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get empty => 'No comments yet. Be the first!';
	@override String get reply => 'Reply';
	@override String get delete => 'Delete';
	@override String get deleted => '[This comment has been deleted]';
	@override String get secret => 'This is a secret comment only visible to the author and post owner.';
}

// Path: common
class _TranslationsCommonEn extends TranslationsCommonId {
	_TranslationsCommonEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get cancel => 'Cancel';
	@override String get confirm => 'Confirm';
	@override String get delete => 'Delete';
	@override String get done => 'Done';
	@override String get clear => 'Clear';
	@override String get report => 'Report';
	@override String get moreOptions => 'More options';
	@override String get viewAll => 'View all';
	@override String get kNew => 'New';
	@override String get updated => 'Updated';
	@override String get comments => 'Comments';
	@override String get sponsored => 'Sponsored';
	@override String get filter => 'Filter';
	@override String get reset => 'Reset';
	@override String get apply => 'Apply';
	@override String get verified => 'Verified';
	@override String get bookmark => 'Bookmark';
	@override late final _TranslationsCommonSortEn sort = _TranslationsCommonSortEn._(_root);
	@override String get error => 'An error occurred.';
	@override String get shareError => 'Failed to share. Please try again.';
	@override String get edit => 'Edit';
	@override String get submit => 'Submit';
	@override String get loginRequired => 'Login is required.';
	@override String get unknownUser => 'Unknown user.';
}

// Path: reportDialog
class _TranslationsReportDialogEn extends TranslationsReportDialogId {
	_TranslationsReportDialogEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Report Post';
	@override String get titleComment => 'Report Comment';
	@override String get titleReply => 'Report Reply';
	@override String get cannotReportSelfComment => 'You cannot report your own comment.';
	@override String get cannotReportSelfReply => 'You cannot report your own reply.';
	@override String get success => 'Report submitted. Thank you.';
	@override String get fail => 'Failed to submit report: {error}';
	@override String get cannotReportSelf => 'You cannot report your own post.';
}

// Path: replyDelete
class _TranslationsReplyDeleteEn extends TranslationsReplyDeleteId {
	_TranslationsReplyDeleteEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get fail => 'Failed to delete reply: {error}';
}

// Path: reportReasons
class _TranslationsReportReasonsEn extends TranslationsReportReasonsId {
	_TranslationsReportReasonsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get spam => 'Spam or misleading';
	@override String get abuse => 'Harassment or hateful speech';
	@override String get inappropriate => 'Sexually inappropriate';
	@override String get illegal => 'Illegal content';
	@override String get etc => 'Other';
}

// Path: deleteConfirm
class _TranslationsDeleteConfirmEn extends TranslationsDeleteConfirmId {
	_TranslationsDeleteConfirmEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Delete Comment';
	@override String get content => 'Are you sure you want to delete this comment?';
	@override String get failure => 'Failed to delete comment: {error}';
}

// Path: replyInputField
class _TranslationsReplyInputFieldEn extends TranslationsReplyInputFieldId {
	_TranslationsReplyInputFieldEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get hintText => 'Enter a reply';
	@override late final _TranslationsReplyInputFieldButtonEn button = _TranslationsReplyInputFieldButtonEn._(_root);
	@override String get failure => 'Failed to add reply: {error}';
}

// Path: chatList
class _TranslationsChatListEn extends TranslationsChatListId {
	_TranslationsChatListEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get appBarTitle => 'Chats';
	@override String get empty => 'No conversations yet.';
}

// Path: chatRoom
class _TranslationsChatRoomEn extends TranslationsChatRoomId {
	_TranslationsChatRoomEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get startConversation => 'Start a conversation';
	@override String get icebreaker1 => 'Hi there! 👋';
	@override String get icebreaker2 => 'What do you usually do on weekends?';
	@override String get icebreaker3 => 'Any favorite spots nearby?';
	@override String get mediaBlocked => 'For safety, media sending is restricted for 24 hours.';
	@override String get imageMessage => 'Image';
	@override String get linkHidden => 'Protection mode: link hidden';
	@override String get contactHidden => 'Protection mode: contact hidden';
}

// Path: jobs
class _TranslationsJobsEn extends TranslationsJobsId {
	_TranslationsJobsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get setLocationPrompt => 'Set your location to see job posts!';
	@override late final _TranslationsJobsScreenEn screen = _TranslationsJobsScreenEn._(_root);
	@override late final _TranslationsJobsTabsEn tabs = _TranslationsJobsTabsEn._(_root);
	@override late final _TranslationsJobsSelectTypeEn selectType = _TranslationsJobsSelectTypeEn._(_root);
	@override late final _TranslationsJobsFormEn form = _TranslationsJobsFormEn._(_root);
	@override late final _TranslationsJobsCategoriesEn categories = _TranslationsJobsCategoriesEn._(_root);
	@override late final _TranslationsJobsSalaryTypesEn salaryTypes = _TranslationsJobsSalaryTypesEn._(_root);
	@override late final _TranslationsJobsWorkPeriodsEn workPeriods = _TranslationsJobsWorkPeriodsEn._(_root);
	@override late final _TranslationsJobsDetailEn detail = _TranslationsJobsDetailEn._(_root);
	@override late final _TranslationsJobsCardEn card = _TranslationsJobsCardEn._(_root);
}

// Path: findFriend
class _TranslationsFindFriendEn extends TranslationsFindFriendId {
	_TranslationsFindFriendEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Find Friends';
	@override late final _TranslationsFindFriendTabsEn tabs = _TranslationsFindFriendTabsEn._(_root);
	@override String get editTitle => 'Edit FindFriend Profile';
	@override String get editProfileTitle => 'Edit Profile';
	@override String get save => 'Save';
	@override String get profileImagesLabel => 'Profile Images (Max 6)';
	@override String get bioLabel => 'Bio';
	@override String get bioHint => 'Introduce yourself to others.';
	@override String get bioValidator => 'Please enter your bio.';
	@override String get ageLabel => 'Age';
	@override String get ageHint => 'Enter your age.';
	@override String get genderLabel => 'Gender';
	@override String get genderMale => 'Male';
	@override String get genderFemale => 'Female';
	@override String get genderHint => 'Select your gender';
	@override String get interestsLabel => 'Interests';
	@override String get preferredAgeLabel => 'Preferred Friend Age';
	@override String get preferredAgeUnit => 'yrs';
	@override String get preferredGenderLabel => 'Preferred Friend Gender';
	@override String get preferredGenderAll => 'All';
	@override String get showProfileLabel => 'Show my profile in the list';
	@override String get showProfileSubtitle => 'If off, others cannot find you.';
	@override String get saveSuccess => 'Profile saved!';
	@override String get saveFailed => 'Failed to save profile:';
	@override String get loginRequired => 'Login is required.';
	@override String get noFriendsFound => 'No nearby friends found.';
	@override String get promptTitle => 'To meet new friends,\nplease create your profile first!';
	@override String get promptButton => 'Create My Profile';
	@override String get chatLimitReached => 'You have reached your daily limit ({limit}) for starting new chats.';
	@override String get chatChecking => 'Checking...';
	@override String get empty => 'No profiles to show yet.';
}

// Path: interests
class _TranslationsInterestsEn extends TranslationsInterestsId {
	_TranslationsInterestsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Interests';
	@override String get limitInfo => 'You can select up to 10.';
	@override String get limitReached => 'You can select up to 10 interests.';
	@override String get categoryCreative => '🎨 Creative';
	@override String get categorySports => '🏃 Sports & Activities';
	@override String get categoryFoodDrink => '🍸 Food & Drinks';
	@override String get categoryEntertainment => '🍿 Entertainment';
	@override String get categoryGrowth => '📚 Self-development';
	@override String get categoryLifestyle => '🌴 Lifestyle';
	@override late final _TranslationsInterestsItemsEn items = _TranslationsInterestsItemsEn._(_root);
}

// Path: friendDetail
class _TranslationsFriendDetailEn extends TranslationsFriendDetailId {
	_TranslationsFriendDetailEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get request => 'Send Request';
	@override String get requestSent => 'Sent';
	@override String get alreadyFriends => 'Already Friends';
	@override String get requestFailed => 'Request failed:';
	@override String get chatError => 'Could not start chat.';
	@override String get startChat => 'Start Chat';
	@override String get block => 'Block';
	@override String get report => 'Report';
	@override String get loginRequired => 'Login is required.';
	@override String get unblocked => 'User has been unblocked.';
	@override String get blocked => 'User has been blocked.';
	@override String get unblock => 'Unblock';
}

// Path: locationFilter
class _TranslationsLocationFilterEn extends TranslationsLocationFilterId {
	_TranslationsLocationFilterEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Location Filter';
	@override String get provinsi => 'Provinsi';
	@override String get kabupaten => 'Kabupaten';
	@override String get kota => 'Kota';
	@override String get kecamatan => 'Kecamatan';
	@override String get kelurahan => 'Kelurahan';
	@override String get apply => 'Apply Filter';
	@override String get all => 'All';
	@override String get reset => 'Reset';
}

// Path: clubs
class _TranslationsClubsEn extends TranslationsClubsId {
	_TranslationsClubsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsClubsTabsEn tabs = _TranslationsClubsTabsEn._(_root);
	@override late final _TranslationsClubsSectionsEn sections = _TranslationsClubsSectionsEn._(_root);
	@override late final _TranslationsClubsScreenEn screen = _TranslationsClubsScreenEn._(_root);
	@override late final _TranslationsClubsPostListEn postList = _TranslationsClubsPostListEn._(_root);
	@override late final _TranslationsClubsMemberCardEn memberCard = _TranslationsClubsMemberCardEn._(_root);
	@override late final _TranslationsClubsPostCardEn postCard = _TranslationsClubsPostCardEn._(_root);
	@override late final _TranslationsClubsCardEn card = _TranslationsClubsCardEn._(_root);
	@override late final _TranslationsClubsPostDetailEn postDetail = _TranslationsClubsPostDetailEn._(_root);
	@override late final _TranslationsClubsDetailEn detail = _TranslationsClubsDetailEn._(_root);
	@override late final _TranslationsClubsMemberListEn memberList = _TranslationsClubsMemberListEn._(_root);
	@override late final _TranslationsClubsCreatePostEn createPost = _TranslationsClubsCreatePostEn._(_root);
	@override late final _TranslationsClubsCreateClubEn createClub = _TranslationsClubsCreateClubEn._(_root);
	@override late final _TranslationsClubsEditClubEn editClub = _TranslationsClubsEditClubEn._(_root);
	@override late final _TranslationsClubsCreateEn create = _TranslationsClubsCreateEn._(_root);
	@override late final _TranslationsClubsRepositoryEn repository = _TranslationsClubsRepositoryEn._(_root);
	@override late final _TranslationsClubsProposalEn proposal = _TranslationsClubsProposalEn._(_root);
	@override String get empty => 'No clubs to display.';
}

// Path: findfriend
class _TranslationsFindfriendEn extends TranslationsFindfriendId {
	_TranslationsFindfriendEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsFindfriendFormEn form = _TranslationsFindfriendFormEn._(_root);
}

// Path: auctions
class _TranslationsAuctionsEn extends TranslationsAuctionsId {
	_TranslationsAuctionsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsAuctionsCardEn card = _TranslationsAuctionsCardEn._(_root);
	@override late final _TranslationsAuctionsErrorsEn errors = _TranslationsAuctionsErrorsEn._(_root);
	@override String get empty => 'No auctions.';
	@override late final _TranslationsAuctionsFilterEn filter = _TranslationsAuctionsFilterEn._(_root);
	@override late final _TranslationsAuctionsCreateEn create = _TranslationsAuctionsCreateEn._(_root);
	@override late final _TranslationsAuctionsEditEn edit = _TranslationsAuctionsEditEn._(_root);
	@override late final _TranslationsAuctionsFormEn form = _TranslationsAuctionsFormEn._(_root);
	@override late final _TranslationsAuctionsDeleteEn delete = _TranslationsAuctionsDeleteEn._(_root);
	@override late final _TranslationsAuctionsDetailEn detail = _TranslationsAuctionsDetailEn._(_root);
}

// Path: localStores
class _TranslationsLocalStoresEn extends TranslationsLocalStoresId {
	_TranslationsLocalStoresEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get setLocationPrompt => 'Set your location to see nearby stores.';
	@override String get empty => 'No stores yet.';
	@override String get error => 'An error occurred: {error}';
	@override late final _TranslationsLocalStoresCreateEn create = _TranslationsLocalStoresCreateEn._(_root);
	@override late final _TranslationsLocalStoresEditEn edit = _TranslationsLocalStoresEditEn._(_root);
	@override late final _TranslationsLocalStoresFormEn form = _TranslationsLocalStoresFormEn._(_root);
	@override late final _TranslationsLocalStoresCategoriesEn categories = _TranslationsLocalStoresCategoriesEn._(_root);
	@override late final _TranslationsLocalStoresDetailEn detail = _TranslationsLocalStoresDetailEn._(_root);
	@override String get noLocation => 'No location info';
}

// Path: pom
class _TranslationsPomEn extends TranslationsPomId {
	_TranslationsPomEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'POM';
	@override late final _TranslationsPomSearchEn search = _TranslationsPomSearchEn._(_root);
	@override late final _TranslationsPomTabsEn tabs = _TranslationsPomTabsEn._(_root);
	@override String get more => 'More';
	@override String get less => 'Less';
	@override String get likesCount => '{} likes';
	@override String get report => 'Report {}';
	@override String get block => 'Block {}';
	@override String get emptyPopular => 'No popular POMs yet.';
	@override String get emptyMine => 'You haven\'t uploaded any POMs yet.';
	@override String get emptyHintPopular => 'Try the All tab to see the latest POMs.';
	@override String get emptyCtaMine => 'Tap + to upload your first POM.';
	@override String get share => 'Share';
	@override String get empty => 'No POM uploaded.';
	@override late final _TranslationsPomErrorsEn errors = _TranslationsPomErrorsEn._(_root);
	@override late final _TranslationsPomCommentsEn comments = _TranslationsPomCommentsEn._(_root);
	@override late final _TranslationsPomCreateEn create = _TranslationsPomCreateEn._(_root);
}

// Path: realEstate
class _TranslationsRealEstateEn extends TranslationsRealEstateId {
	_TranslationsRealEstateEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get empty => 'No listings.';
	@override String get error => 'An error occurred: {error}';
	@override String get create => 'Add listing';
	@override String get locationUnknown => 'No location info';
	@override late final _TranslationsRealEstatePriceUnitsEn priceUnits = _TranslationsRealEstatePriceUnitsEn._(_root);
	@override late final _TranslationsRealEstatePriceUnitEn priceUnit = _TranslationsRealEstatePriceUnitEn._(_root);
	@override late final _TranslationsRealEstateFormEn form = _TranslationsRealEstateFormEn._(_root);
	@override late final _TranslationsRealEstateFilterEn filter = _TranslationsRealEstateFilterEn._(_root);
	@override late final _TranslationsRealEstateInfoEn info = _TranslationsRealEstateInfoEn._(_root);
	@override late final _TranslationsRealEstateDetailEn detail = _TranslationsRealEstateDetailEn._(_root);
	@override late final _TranslationsRealEstateEditEn edit = _TranslationsRealEstateEditEn._(_root);
	@override String get disclaimer => 'Bling is an online advertising/board platform and is not a real estate broker or agent. The truthfulness of listings, ownership/title status, price, and terms are the sole responsibility of the poster. Users must conduct their own checks and verify all information directly with the poster and relevant authorities before proceeding.';
}

// Path: lostAndFound
class _TranslationsLostAndFoundEn extends TranslationsLostAndFoundId {
	_TranslationsLostAndFoundEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get empty => 'No lost/found items yet.';
	@override String get error => 'An error occurred: {error}';
	@override String get create => 'Add lost/found item';
	@override late final _TranslationsLostAndFoundResolveEn resolve = _TranslationsLostAndFoundResolveEn._(_root);
	@override String get lost => 'Lost';
	@override String get found => 'Found';
	@override late final _TranslationsLostAndFoundTabsEn tabs = _TranslationsLostAndFoundTabsEn._(_root);
	@override late final _TranslationsLostAndFoundCardEn card = _TranslationsLostAndFoundCardEn._(_root);
	@override late final _TranslationsLostAndFoundFormEn form = _TranslationsLostAndFoundFormEn._(_root);
	@override late final _TranslationsLostAndFoundEditEn edit = _TranslationsLostAndFoundEditEn._(_root);
	@override late final _TranslationsLostAndFoundDetailEn detail = _TranslationsLostAndFoundDetailEn._(_root);
}

// Path: community
class _TranslationsCommunityEn extends TranslationsCommunityId {
	_TranslationsCommunityEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Community Screen';
}

// Path: shared
class _TranslationsSharedEn extends TranslationsSharedId {
	_TranslationsSharedEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsSharedTagInputEn tagInput = _TranslationsSharedTagInputEn._(_root);
}

// Path: linkPreview
class _TranslationsLinkPreviewEn extends TranslationsLinkPreviewId {
	_TranslationsLinkPreviewEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get errorTitle => 'Could not load preview';
	@override String get errorBody => 'Please check the link or try again later.';
}

// Path: localNewsTagResult
class _TranslationsLocalNewsTagResultEn extends TranslationsLocalNewsTagResultId {
	_TranslationsLocalNewsTagResultEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get error => 'An error occurred during search: {error}';
	@override String get empty => 'No posts found with \'#{tag}\'.';
}

// Path: admin
class _TranslationsAdminEn extends TranslationsAdminId {
	_TranslationsAdminEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsAdminScreenEn screen = _TranslationsAdminScreenEn._(_root);
	@override late final _TranslationsAdminMenuEn menu = _TranslationsAdminMenuEn._(_root);
	@override late final _TranslationsAdminAiApprovalEn aiApproval = _TranslationsAdminAiApprovalEn._(_root);
	@override late final _TranslationsAdminReportsEn reports = _TranslationsAdminReportsEn._(_root);
	@override late final _TranslationsAdminReportListEn reportList = _TranslationsAdminReportListEn._(_root);
	@override late final _TranslationsAdminReportDetailEn reportDetail = _TranslationsAdminReportDetailEn._(_root);
	@override late final _TranslationsAdminDataFixEn dataFix = _TranslationsAdminDataFixEn._(_root);
}

// Path: tags
class _TranslationsTagsEn extends TranslationsTagsId {
	_TranslationsTagsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsTagsLocalNewsEn localNews = _TranslationsTagsLocalNewsEn._(_root);
}

// Path: boards
class _TranslationsBoardsEn extends TranslationsBoardsId {
	_TranslationsBoardsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsBoardsPopupEn popup = _TranslationsBoardsPopupEn._(_root);
	@override String get defaultTitle => 'Board';
	@override String get chatRoomComingSoon => 'Chat room coming soon';
	@override String get chatRoomTitle => 'Chat Room';
	@override String get emptyFeed => 'No posts yet.';
	@override String get chatRoomCreated => 'Chat room created.';
}

// Path: signup
class _TranslationsSignupEn extends TranslationsSignupId {
	_TranslationsSignupEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsSignupAlertsEn alerts = _TranslationsSignupAlertsEn._(_root);
	@override String get title => 'Sign Up';
	@override String get subtitle => 'Join your neighborhood community!';
	@override String get nicknameHint => 'Nickname';
	@override String get emailHint => 'Email Address';
	@override String get passwordHint => 'Password';
	@override String get passwordConfirmHint => 'Confirm Password';
	@override String get locationHint => 'Location';
	@override String get locationNotice => 'Your location is used to show local posts and is not shared.';
	@override late final _TranslationsSignupButtonsEn buttons = _TranslationsSignupButtonsEn._(_root);
}

// Path: user
class _TranslationsUserEn extends TranslationsUserId {
	_TranslationsUserEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get notLoggedIn => 'Not logged in';
}

// Path: login.buttons
class _TranslationsLoginButtonsEn extends TranslationsLoginButtonsId {
	_TranslationsLoginButtonsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get login => 'Log In';
	@override String get google => 'Continue with Google';
	@override String get apple => 'Continue with Apple';
}

// Path: login.links
class _TranslationsLoginLinksEn extends TranslationsLoginLinksId {
	_TranslationsLoginLinksEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get findPassword => 'Forgot password?';
	@override String get askForAccount => 'Don’t have an account?';
	@override String get signUp => 'Sign up';
}

// Path: login.alerts
class _TranslationsLoginAlertsEn extends TranslationsLoginAlertsId {
	_TranslationsLoginAlertsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get invalidEmail => 'Invalid email format.';
	@override String get userNotFound => 'User not found or wrong password.';
	@override String get wrongPassword => 'Wrong password.';
	@override String get unknownError => 'An unknown error occurred. Please try again.';
}

// Path: main.appBar
class _TranslationsMainAppBarEn extends TranslationsMainAppBarId {
	_TranslationsMainAppBarEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get locationNotSet => 'Location not set';
	@override String get locationError => 'Location Error';
	@override String get locationLoading => 'Loading...';
}

// Path: main.tabs
class _TranslationsMainTabsEn extends TranslationsMainTabsId {
	_TranslationsMainTabsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get newFeed => 'New Feed';
	@override String get localNews => 'Local News';
	@override String get marketplace => 'Preloved';
	@override String get findFriends => 'Find Friends';
	@override String get clubs => 'Clubs';
	@override String get jobs => 'Jobs';
	@override String get localStores => 'Local Stores';
	@override String get auction => 'Auctions';
	@override String get pom => 'POM';
	@override String get lostAndFound => 'Lost & Found';
	@override String get realEstate => 'Real Estate';
}

// Path: main.bottomNav
class _TranslationsMainBottomNavEn extends TranslationsMainBottomNavId {
	_TranslationsMainBottomNavEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get home => 'Home';
	@override String get board => 'Neighborhood';
	@override String get search => 'Search';
	@override String get chat => 'Chat';
	@override String get myBling => 'My Bling';
}

// Path: main.errors
class _TranslationsMainErrorsEn extends TranslationsMainErrorsId {
	_TranslationsMainErrorsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get loginRequired => 'Login is required.';
	@override String get userNotFound => 'User not found.';
	@override String get unknown => 'An unknown error occurred.';
}

// Path: main.mapView
class _TranslationsMainMapViewEn extends TranslationsMainMapViewId {
	_TranslationsMainMapViewEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get showMap => 'Show map';
	@override String get showList => 'Show list';
}

// Path: main.search
class _TranslationsMainSearchEn extends TranslationsMainSearchId {
	_TranslationsMainSearchEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get placeholder => 'Search';
	@override String get chipPlaceholder => 'Search neighbors, news, preloved, jobs…';
	@override late final _TranslationsMainSearchHintEn hint = _TranslationsMainSearchHintEn._(_root);
}

// Path: search.empty
class _TranslationsSearchEmptyEn extends TranslationsSearchEmptyId {
	_TranslationsSearchEmptyEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get message => 'No results found for \'{keyword}\'.';
	@override String get checkSpelling => 'Check your spelling or try different keywords.';
	@override String get expandToNational => 'Search Nationally';
}

// Path: search.sheet
class _TranslationsSearchSheetEn extends TranslationsSearchSheetId {
	_TranslationsSearchSheetEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get localNews => 'Search Local News';
	@override String get localNewsDesc => 'Search by title, content, tags';
	@override String get jobs => 'Search Jobs';
	@override String get jobsDesc => 'Search by role, company, tags';
	@override String get lostAndFound => 'Search Lost & Found';
	@override String get lostAndFoundDesc => 'Search by item name, place';
	@override String get marketplace => 'Search Preloved';
	@override String get marketplaceDesc => 'Search by item name, category, tags';
	@override String get localStores => 'Search Local Stores';
	@override String get localStoresDesc => 'Search by store name, business type, keywords';
	@override String get clubs => 'Search Clubs';
	@override String get clubsDesc => 'Search by club name, interests';
	@override String get findFriends => 'Search Find Friends';
	@override String get findFriendsDesc => 'Search by nickname, interests';
	@override String get realEstate => 'Search Real Estate';
	@override String get realEstateDesc => 'Search by listing title, area, tags';
	@override String get auction => 'Search Auctions';
	@override String get auctionDesc => 'Search by item name, tags';
	@override String get pom => 'Search POM';
	@override String get pomDesc => 'Search by title, hashtags';
	@override String get comingSoon => 'Coming soon';
}

// Path: drawer.trustDashboard
class _TranslationsDrawerTrustDashboardEn extends TranslationsDrawerTrustDashboardId {
	_TranslationsDrawerTrustDashboardEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'My Trust Verification Status';
	@override String get kelurahanAuth => 'Neighborhood Verification (Kelurahan)';
	@override String get rtRwAuth => 'Detailed Address Verification (RT/RW)';
	@override String get phoneAuth => 'Phone Verification';
	@override String get profileComplete => 'Profile Complete';
	@override String get feedThanks => 'Feed Thanks';
	@override String get marketThanks => 'Market Thanks';
	@override String get reports => 'Reports';
	@override String get breakdownButton => 'Details';
	@override String get breakdownModalTitle => 'Trust Score Breakdown';
	@override String get breakdownClose => 'OK';
	@override late final _TranslationsDrawerTrustDashboardBreakdownEn breakdown = _TranslationsDrawerTrustDashboardBreakdownEn._(_root);
}

// Path: marketplace.registration
class _TranslationsMarketplaceRegistrationEn extends TranslationsMarketplaceRegistrationId {
	_TranslationsMarketplaceRegistrationEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'New Post';
	@override String get done => 'Save';
	@override String get titleHint => 'Item Name';
	@override String get priceHint => 'Price (Rp)';
	@override String get negotiable => 'Allow Offers';
	@override String get addressHint => 'Neighborhood';
	@override String get addressDetailHint => 'Meeting Place';
	@override String get descriptionHint => 'Detailed Description';
	@override String get success => 'Product registered successfully!';
	@override String get tagsHint => 'Add tags (press space to confirm)';
	@override String get fail => 'fail';
}

// Path: marketplace.edit
class _TranslationsMarketplaceEditEn extends TranslationsMarketplaceEditId {
	_TranslationsMarketplaceEditEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Edit Post';
	@override String get done => 'Update Done';
	@override String get titleHint => 'Edit Item Name';
	@override String get addressHint => 'Edit Location';
	@override String get priceHint => 'Edit Price (Rp)';
	@override String get negotiable => 'Edit Negotiable';
	@override String get descriptionHint => 'Edit Description';
	@override String get tagsHint => 'Add tags (press space to confirm)';
	@override String get success => 'Product registered successfully!';
	@override String get fail => 'Failed to update product: {error}';
	@override String get resetLocation => 'Reset location';
	@override String get save => 'Save changes';
}

// Path: marketplace.detail
class _TranslationsMarketplaceDetailEn extends TranslationsMarketplaceDetailId {
	_TranslationsMarketplaceDetailEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get makeOffer => 'Make an offer';
	@override String get fixedPrice => 'Fixed price';
	@override String get description => 'Product Description';
	@override String get sellerInfo => 'Seller Info';
	@override String get chat => 'Chat';
	@override String get favorite => 'Favorite';
	@override String get unfavorite => 'Unfavorite';
	@override String get share => 'Share';
	@override String get edit => 'Edit';
	@override String get delete => 'Delete';
	@override String get category => 'Category';
	@override String get categoryError => 'Category: -';
	@override String get categoryNone => 'No category';
	@override String get views => 'Views';
	@override String get likes => 'Likes';
	@override String get chats => 'Chats';
	@override String get noSeller => 'Seller info unavailable';
	@override String get noLocation => 'Location info unavailable';
	@override String get seller => 'Seller';
	@override String get dealLocation => 'Deal location';
}

// Path: marketplace.dialog
class _TranslationsMarketplaceDialogEn extends TranslationsMarketplaceDialogId {
	_TranslationsMarketplaceDialogEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get deleteTitle => 'Delete Post';
	@override String get deleteContent => 'Are you sure you want to delete this post? This action cannot be undone.';
	@override String get cancel => 'Cancel';
	@override String get deleteConfirm => 'Delete';
	@override String get deleteSuccess => 'Post deleted successfully.';
	@override String get close => 'close';
}

// Path: marketplace.errors
class _TranslationsMarketplaceErrorsEn extends TranslationsMarketplaceErrorsId {
	_TranslationsMarketplaceErrorsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get deleteError => 'Failed to delete post: {error}';
	@override String get requiredField => 'This field is required.';
	@override String get noPhoto => 'Please add at least one photo.';
	@override String get noCategory => 'Please select a category.';
	@override String get loginRequired => 'Login is required.';
	@override String get userNotFound => 'User information could not be found.';
}

// Path: marketplace.condition
class _TranslationsMarketplaceConditionEn extends TranslationsMarketplaceConditionId {
	_TranslationsMarketplaceConditionEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get label => 'Condition';
	@override String get kNew => 'New';
	@override String get used => 'Used';
}

// Path: marketplace.reservation
class _TranslationsMarketplaceReservationEn extends TranslationsMarketplaceReservationId {
	_TranslationsMarketplaceReservationEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => '10% deposit payment';
	@override String get content => 'To reserve an AI-verified product you must prepay a 10% deposit of {amount}. If the deal is cancelled after on-site verification, the deposit will be refunded.';
	@override String get confirm => 'Pay & Reserve';
	@override String get button => 'Reserve with AI Assurance';
	@override String get success => 'Reservation completed. Please arrange a meeting with the seller.';
}

// Path: marketplace.status
class _TranslationsMarketplaceStatusEn extends TranslationsMarketplaceStatusId {
	_TranslationsMarketplaceStatusEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get reserved => 'Reserved';
	@override String get sold => 'Sold';
}

// Path: marketplace.ai
class _TranslationsMarketplaceAiEn extends TranslationsMarketplaceAiId {
	_TranslationsMarketplaceAiEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get cancelConfirm => 'Cancel AI verification';
	@override String get cancelLimit => 'AI verification can only be canceled once per product. Re-requesting AI verification may incur charges.';
	@override String get cancelAckCharge => 'I understand I may be charged.';
	@override String get cancelSuccess => 'AI verification has been cancelled. The product is now a normal listing.';
	@override String get cancelError => 'Error cancelling AI verification: {0}';
}

// Path: marketplace.takeover
class _TranslationsMarketplaceTakeoverEn extends TranslationsMarketplaceTakeoverId {
	_TranslationsMarketplaceTakeoverEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get button => 'On-site pickup & verification';
	@override String get title => 'AI On-site Verification';
	@override late final _TranslationsMarketplaceTakeoverGuideEn guide = _TranslationsMarketplaceTakeoverGuideEn._(_root);
	@override String get photoTitle => 'Take on-site photos';
	@override String get buttonVerify => 'Start AI similarity verification';
	@override late final _TranslationsMarketplaceTakeoverErrorsEn errors = _TranslationsMarketplaceTakeoverErrorsEn._(_root);
	@override late final _TranslationsMarketplaceTakeoverDialogEn dialog = _TranslationsMarketplaceTakeoverDialogEn._(_root);
	@override late final _TranslationsMarketplaceTakeoverSuccessEn success = _TranslationsMarketplaceTakeoverSuccessEn._(_root);
}

// Path: aiFlow.common
class _TranslationsAiFlowCommonEn extends TranslationsAiFlowCommonId {
	_TranslationsAiFlowCommonEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get error => 'An error occurred: {error}';
	@override String get addPhoto => 'Add Photo';
	@override String get skip => 'Skip';
	@override String get addedPhoto => 'Photo added: {}';
	@override String get skipped => 'Skipped';
}

// Path: aiFlow.cta
class _TranslationsAiFlowCtaEn extends TranslationsAiFlowCtaId {
	_TranslationsAiFlowCtaEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => '🤖 Boost trust with AI verification (optional)';
	@override String get subtitle => 'Earn an AI verification badge to increase buyer trust and sell faster. Fill in all product info before starting.';
	@override String get startButton => 'Start AI verification';
	@override String get missingRequiredFields => 'Please enter item name, category, and at least one image.';
}

// Path: aiFlow.categorySelection
class _TranslationsAiFlowCategorySelectionEn extends TranslationsAiFlowCategorySelectionId {
	_TranslationsAiFlowCategorySelectionEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'AI Verification: Select Category';
	@override String get error => 'Failed to load categories.';
	@override String get noCategories => 'No categories available for verification.';
}

// Path: aiFlow.galleryUpload
class _TranslationsAiFlowGalleryUploadEn extends TranslationsAiFlowGalleryUploadId {
	_TranslationsAiFlowGalleryUploadEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'AI Verification: Select Photos';
	@override String get guide => 'Please upload at least {count} photos for verification.';
	@override String get minPhotoError => 'You must select at least {count} photos.';
	@override String get nextButton => 'Request AI Analysis';
}

// Path: aiFlow.prediction
class _TranslationsAiFlowPredictionEn extends TranslationsAiFlowPredictionId {
	_TranslationsAiFlowPredictionEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'AI Analysis Result';
	@override String get guide => 'This is the item name predicted by AI.';
	@override String get editLabel => 'Edit Item Name';
	@override String get editButton => 'Edit Manually';
	@override String get saveButton => 'Save Changes';
	@override String get noName => 'No Item Name';
	@override String get error => 'Couldn’t recognize the item. Please try again.';
	@override String get authError => 'Missing user auth info. Cannot start analysis.';
	@override String get question => 'Is this the right item?';
	@override String get confirmButton => 'Yes, it is';
	@override String get rejectButton => 'No, go back';
	@override String get analysisError => 'An error occurred during analysis.';
	@override String get retryButton => 'Try Again';
	@override String get backButton => 'Back';
}

// Path: aiFlow.guidedCamera
class _TranslationsAiFlowGuidedCameraEn extends TranslationsAiFlowGuidedCameraId {
	_TranslationsAiFlowGuidedCameraEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'AI guidance: missing evidence';
	@override String get guide => 'To improve trust, please add suggested photos for the items below.';
	@override String get locationMismatchError => 'The photo’s location doesn’t match your current location. Please shoot at the same place.';
	@override String get locationPermissionError => 'Location permission denied. Please enable it in settings.';
	@override String get noLocationDataError => 'No location data found in the photo. Please enable location tags in your camera settings.';
	@override String get nextButton => 'Generate final report';
}

// Path: aiFlow.finalReport
class _TranslationsAiFlowFinalReportEn extends TranslationsAiFlowFinalReportId {
	_TranslationsAiFlowFinalReportEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'AI Verification Report';
	@override String get guide => 'AI generated a draft listing. Edit the content and finish registration.';
	@override String get loading => 'AI is generating the final report...';
	@override String get error => 'Failed to generate the report.';
	@override String get success => 'Final report generated successfully.';
	@override String get submitButton => 'Register for Sale';
	@override String get suggestedPrice => 'AI suggested price ({})';
	@override String get summary => 'Verification summary';
	@override String get buyerNotes => 'Notes for buyer (AI)';
	@override String get keySpecs => 'Key specs';
	@override String get condition => 'Condition check';
	@override String get includedItems => 'Included items (comma-separated)';
	@override String get finalDescription => 'Final description';
	@override String get applySuggestions => 'Apply suggestions to description';
	@override String get includedItemsLabel => 'Included items';
	@override String get buyerNotesLabel => 'Buyer notes';
	@override String get skippedItems => 'Skipped evidence items';
	@override String get fail => 'Failed to generate final report: {error}';
}

// Path: aiFlow.evidence
class _TranslationsAiFlowEvidenceEn extends TranslationsAiFlowEvidenceId {
	_TranslationsAiFlowEvidenceEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get allShotsRequired => 'All suggested shots are required.';
	@override String get title => 'Evidence photos';
	@override String get submitButton => 'Submit evidence';
}

// Path: aiFlow.error
class _TranslationsAiFlowErrorEn extends TranslationsAiFlowErrorId {
	_TranslationsAiFlowErrorEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get reportGeneration => 'Failed to generate AI report: {error}';
}

// Path: myBling.stats
class _TranslationsMyBlingStatsEn extends TranslationsMyBlingStatsId {
	_TranslationsMyBlingStatsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get posts => 'Posts';
	@override String get followers => 'Followers';
	@override String get neighbors => 'Neighbors';
	@override String get friends => 'Friends';
}

// Path: myBling.tabs
class _TranslationsMyBlingTabsEn extends TranslationsMyBlingTabsId {
	_TranslationsMyBlingTabsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get posts => 'My Posts';
	@override String get products => 'My Products';
	@override String get bookmarks => 'Bookmarks';
	@override String get friends => 'Friends';
}

// Path: profileView.tabs
class _TranslationsProfileViewTabsEn extends TranslationsProfileViewTabsId {
	_TranslationsProfileViewTabsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get posts => 'Posts';
	@override String get interests => 'Interests';
}

// Path: settings.notifications
class _TranslationsSettingsNotificationsEn extends TranslationsSettingsNotificationsId {
	_TranslationsSettingsNotificationsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get loadError => 'Failed to load notification settings.';
	@override String get saveSuccess => 'Notification settings saved.';
	@override String get saveError => 'Failed to save notification settings.';
	@override String get scopeTitle => 'Notification range';
	@override String get scopeDescription => 'Choose how wide your notifications should be (only my neighborhood, nearby areas, etc.).';
	@override String get scopeLabel => 'Notification scope';
	@override String get tagsTitle => 'Notification topics';
	@override String get tagsDescription => 'Choose which topics you want to receive notifications about (news, jobs, marketplace, etc.).';
}

// Path: friendRequests.tooltip
class _TranslationsFriendRequestsTooltipEn extends TranslationsFriendRequestsTooltipId {
	_TranslationsFriendRequestsTooltipEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get accept => 'Accept';
	@override String get reject => 'Reject';
}

// Path: sentFriendRequests.status
class _TranslationsSentFriendRequestsStatusEn extends TranslationsSentFriendRequestsStatusId {
	_TranslationsSentFriendRequestsStatusEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get pending => 'Pending';
	@override String get accepted => 'Accepted';
	@override String get rejected => 'Rejected';
}

// Path: blockedUsers.unblockDialog
class _TranslationsBlockedUsersUnblockDialogEn extends TranslationsBlockedUsersUnblockDialogId {
	_TranslationsBlockedUsersUnblockDialogEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Unblock {nickname}?';
	@override String get content => 'After unblocking, this user may appear in your Find Friends list again.';
}

// Path: rejectedUsers.unrejectDialog
class _TranslationsRejectedUsersUnrejectDialogEn extends TranslationsRejectedUsersUnrejectDialogId {
	_TranslationsRejectedUsersUnrejectDialogEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Undo reject for {nickname}?';
	@override String get content => 'If undone, you may appear again in their Find Friends list.';
}

// Path: profileEdit.interests
class _TranslationsProfileEditInterestsEn extends TranslationsProfileEditInterestsId {
	_TranslationsProfileEditInterestsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Interests';
	@override String get hint => 'Use commas and Enter to add multiple';
}

// Path: profileEdit.privacy
class _TranslationsProfileEditPrivacyEn extends TranslationsProfileEditPrivacyId {
	_TranslationsProfileEditPrivacyEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Privacy Settings';
	@override String get showLocation => 'Show my location on the map';
	@override String get allowRequests => 'Allow friend requests';
}

// Path: profileEdit.errors
class _TranslationsProfileEditErrorsEn extends TranslationsProfileEditErrorsId {
	_TranslationsProfileEditErrorsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get noUser => 'No logged-in user.';
	@override String get updateFailed => 'Failed to update profile: {error}';
}

// Path: categories.post
class _TranslationsCategoriesPostEn extends TranslationsCategoriesPostId {
	_TranslationsCategoriesPostEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsCategoriesPostJalanPerbaikinEn jalanPerbaikin = _TranslationsCategoriesPostJalanPerbaikinEn._(_root);
	@override late final _TranslationsCategoriesPostDailyLifeEn dailyLife = _TranslationsCategoriesPostDailyLifeEn._(_root);
	@override late final _TranslationsCategoriesPostHelpShareEn helpShare = _TranslationsCategoriesPostHelpShareEn._(_root);
	@override late final _TranslationsCategoriesPostIncidentReportEn incidentReport = _TranslationsCategoriesPostIncidentReportEn._(_root);
	@override late final _TranslationsCategoriesPostLocalNewsEn localNews = _TranslationsCategoriesPostLocalNewsEn._(_root);
	@override late final _TranslationsCategoriesPostNovemberEn november = _TranslationsCategoriesPostNovemberEn._(_root);
	@override late final _TranslationsCategoriesPostRainEn rain = _TranslationsCategoriesPostRainEn._(_root);
	@override late final _TranslationsCategoriesPostDailyQuestionEn dailyQuestion = _TranslationsCategoriesPostDailyQuestionEn._(_root);
	@override late final _TranslationsCategoriesPostStorePromoEn storePromo = _TranslationsCategoriesPostStorePromoEn._(_root);
	@override late final _TranslationsCategoriesPostEtcEn etc = _TranslationsCategoriesPostEtcEn._(_root);
}

// Path: categories.auction
class _TranslationsCategoriesAuctionEn extends TranslationsCategoriesAuctionId {
	_TranslationsCategoriesAuctionEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get all => 'All';
	@override late final _TranslationsCategoriesAuctionCollectiblesEn collectibles = _TranslationsCategoriesAuctionCollectiblesEn._(_root);
	@override late final _TranslationsCategoriesAuctionDigitalEn digital = _TranslationsCategoriesAuctionDigitalEn._(_root);
	@override late final _TranslationsCategoriesAuctionFashionEn fashion = _TranslationsCategoriesAuctionFashionEn._(_root);
	@override late final _TranslationsCategoriesAuctionVintageEn vintage = _TranslationsCategoriesAuctionVintageEn._(_root);
	@override late final _TranslationsCategoriesAuctionArtCraftEn artCraft = _TranslationsCategoriesAuctionArtCraftEn._(_root);
	@override late final _TranslationsCategoriesAuctionEtcEn etc = _TranslationsCategoriesAuctionEtcEn._(_root);
}

// Path: localNewsCreate.form
class _TranslationsLocalNewsCreateFormEn extends TranslationsLocalNewsCreateFormId {
	_TranslationsLocalNewsCreateFormEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get categoryLabel => 'Category';
	@override String get titleLabel => 'Title';
	@override String get contentLabel => 'Enter content';
	@override String get tagsLabel => 'Tags';
	@override String get tagsHint => 'Add tags (press space to confirm)';
	@override String get recommendedTags => 'Recommended tags';
}

// Path: localNewsCreate.labels
class _TranslationsLocalNewsCreateLabelsEn extends TranslationsLocalNewsCreateLabelsId {
	_TranslationsLocalNewsCreateLabelsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Title';
	@override String get body => 'Content';
	@override String get tags => 'Tags';
	@override String get guidedTitle => 'Additional Info (Optional)';
	@override String get eventLocation => 'Event/Incident Location';
}

// Path: localNewsCreate.hints
class _TranslationsLocalNewsCreateHintsEn extends TranslationsLocalNewsCreateHintsId {
	_TranslationsLocalNewsCreateHintsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get body => 'Share your neighborhood news or ask questions...';
	@override String get tagSelection => '(Select 1-3 tags)';
	@override String get eventLocation => 'e.g., Jl. Sudirman 123';
}

// Path: localNewsCreate.validation
class _TranslationsLocalNewsCreateValidationEn extends TranslationsLocalNewsCreateValidationId {
	_TranslationsLocalNewsCreateValidationEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get bodyRequired => 'Please enter the content.';
	@override String get tagRequired => 'Please select at least one tag.';
	@override String get tagMaxLimit => 'You can select up to 3 tags.';
	@override String get imageMaxLimit => 'You can attach up to 5 images.';
	@override String get titleRequired => 'Please enter a title.';
}

// Path: localNewsCreate.buttons
class _TranslationsLocalNewsCreateButtonsEn extends TranslationsLocalNewsCreateButtonsId {
	_TranslationsLocalNewsCreateButtonsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get addImage => 'Add Image';
	@override String get submit => 'Submit';
}

// Path: localNewsCreate.alerts
class _TranslationsLocalNewsCreateAlertsEn extends TranslationsLocalNewsCreateAlertsId {
	_TranslationsLocalNewsCreateAlertsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get contentRequired => 'Please enter content.';
	@override String get categoryRequired => 'Please select a category.';
	@override String get success => 'Post created successfully.';
	@override String get failure => 'Upload failed: {error}';
	@override String get loginRequired => 'Login is required to create a post.';
	@override String get userNotFound => 'User information could not be found.';
}

// Path: localNewsDetail.menu
class _TranslationsLocalNewsDetailMenuEn extends TranslationsLocalNewsDetailMenuId {
	_TranslationsLocalNewsDetailMenuEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get edit => 'Edit';
	@override String get report => 'Report';
	@override String get share => 'Share';
}

// Path: localNewsDetail.stats
class _TranslationsLocalNewsDetailStatsEn extends TranslationsLocalNewsDetailStatsId {
	_TranslationsLocalNewsDetailStatsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get views => 'Views';
	@override String get comments => 'Comments';
	@override String get likes => 'Likes';
	@override String get thanks => 'Thanks';
}

// Path: localNewsDetail.buttons
class _TranslationsLocalNewsDetailButtonsEn extends TranslationsLocalNewsDetailButtonsId {
	_TranslationsLocalNewsDetailButtonsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get comment => 'Add a comment';
}

// Path: localNewsEdit.buttons
class _TranslationsLocalNewsEditButtonsEn extends TranslationsLocalNewsEditButtonsId {
	_TranslationsLocalNewsEditButtonsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get submit => 'Update';
}

// Path: localNewsEdit.alerts
class _TranslationsLocalNewsEditAlertsEn extends TranslationsLocalNewsEditAlertsId {
	_TranslationsLocalNewsEditAlertsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get success => 'Post updated successfully.';
	@override String get failure => 'Failed to update: {error}';
}

// Path: commentInputField.button
class _TranslationsCommentInputFieldButtonEn extends TranslationsCommentInputFieldButtonId {
	_TranslationsCommentInputFieldButtonEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get send => 'Send';
}

// Path: common.sort
class _TranslationsCommonSortEn extends TranslationsCommonSortId {
	_TranslationsCommonSortEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get kDefault => 'Default';
	@override String get distance => 'Distance';
	@override String get popular => 'Popular';
}

// Path: replyInputField.button
class _TranslationsReplyInputFieldButtonEn extends TranslationsReplyInputFieldButtonId {
	_TranslationsReplyInputFieldButtonEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get send => 'Send';
}

// Path: jobs.screen
class _TranslationsJobsScreenEn extends TranslationsJobsScreenId {
	_TranslationsJobsScreenEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get empty => 'No job postings found in this area.';
	@override String get createTooltip => 'Post a Job';
}

// Path: jobs.tabs
class _TranslationsJobsTabsEn extends TranslationsJobsTabsId {
	_TranslationsJobsTabsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get all => 'All';
	@override String get quickGig => 'Quick Gigs';
	@override String get regular => 'Part-time/Full-time';
}

// Path: jobs.selectType
class _TranslationsJobsSelectTypeEn extends TranslationsJobsSelectTypeId {
	_TranslationsJobsSelectTypeEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Select Job Type';
	@override String get regularTitle => 'Part-time / Full-time Job';
	@override String get regularDesc => 'Regular work like cafe, restaurant, office';
	@override String get quickGigTitle => 'Quick Gig / Simple Help';
	@override String get quickGigDesc => 'Motorcycle delivery, moving, cleaning, etc.';
}

// Path: jobs.form
class _TranslationsJobsFormEn extends TranslationsJobsFormId {
	_TranslationsJobsFormEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Post a Job';
	@override String get titleHint => 'Job title';
	@override String get descriptionPositionHint => 'Describe the position';
	@override String get categoryHint => 'Category';
	@override String get categorySelectHint => 'Select a category';
	@override String get categoryValidator => 'Please select a category.';
	@override String get locationHint => 'Location';
	@override String get submit => 'Post Job';
	@override String get titleLabel => 'Title';
	@override String get titleValidator => 'Please enter a title.';
	@override String get titleRegular => 'Post Part-time/Full-time Job';
	@override String get titleQuickGig => 'Post Quick Gig';
	@override String get validationError => 'Please fill in all required fields.';
	@override String get saveSuccess => 'Job posting saved successfully.';
	@override String get saveError => 'Failed to save job posting: {error}';
	@override String get categoryLabel => 'Category';
	@override String get titleHintQuickGig => 'e.g., Motorcycle document delivery (ASAP)';
	@override String get salaryLabel => 'Salary (IDR)';
	@override String get salaryHint => 'Enter the salary amount';
	@override String get salaryValidator => 'Please enter a valid salary.';
	@override String get totalPayLabel => 'Total Pay (IDR)';
	@override String get totalPayHint => 'Enter the total amount offered';
	@override String get totalPayValidator => 'Please enter a valid amount.';
	@override String get negotiable => 'Negotiable';
	@override String get workPeriodLabel => 'Work Period';
	@override String get workPeriodHint => 'Select work period';
	@override String get locationLabel => 'Location / Workplace';
	@override String get locationValidator => 'Please enter a location.';
	@override String get imageLabel => 'Images (Optional, max 10)';
	@override String get descriptionHintQuickGig => 'Please provide details (e.g., departure, destination, specific request).';
	@override String get salaryInfoTitle => 'Salary Info';
	@override String get salaryTypeHint => 'Type';
	@override String get salaryAmountLabel => 'Amount (IDR)';
	@override String get salaryNegotiable => 'Salary negotiable';
	@override String get workInfoTitle => 'Work Conditions';
	@override String get workPeriodTitle => 'Work Period';
	@override String get workHoursLabel => 'Days/Hours';
	@override String get workHoursHint => 'e.g. Mon-Fri, 09:00-18:00';
	@override String get imageSectionTitle => 'Attach Photos (optional, max 5)';
	@override String get descriptionLabel => 'Description';
	@override String get descriptionHint => 'e.g. Part-time, 3 days a week, 5-10pm. Salary negotiable.';
	@override String get descriptionValidator => 'Please enter a description.';
	@override String get submitFail => 'Failed to create job post: {error}';
	@override String get updateSuccess => 'Job updated successfully.';
	@override String get editTitle => 'Edit Job';
	@override String get update => 'Update';
	@override String get submitSuccess => 'Job post created.';
}

// Path: jobs.categories
class _TranslationsJobsCategoriesEn extends TranslationsJobsCategoriesId {
	_TranslationsJobsCategoriesEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get restaurant => 'Restaurant';
	@override String get cafe => 'Cafe';
	@override String get retail => 'Retail';
	@override String get delivery => 'Delivery';
	@override String get etc => 'Etc';
	@override String get service => 'Service';
	@override String get salesMarketing => 'Sales/Marketing';
	@override String get deliveryLogistics => 'Delivery/Logistics';
	@override String get it => 'IT/Tech';
	@override String get design => 'Design';
	@override String get education => 'Education';
	@override String get quickGigDelivery => 'Motorcycle Delivery';
	@override String get quickGigTransport => 'Motorcycle Ride (Ojek)';
	@override String get quickGigMoving => 'Moving Help';
	@override String get quickGigCleaning => 'Cleaning/Housework';
	@override String get quickGigQueuing => 'Wait in Line';
	@override String get quickGigEtc => 'Other Errands';
}

// Path: jobs.salaryTypes
class _TranslationsJobsSalaryTypesEn extends TranslationsJobsSalaryTypesId {
	_TranslationsJobsSalaryTypesEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get hourly => 'Hourly';
	@override String get daily => 'Daily';
	@override String get weekly => 'Weekly';
	@override String get monthly => 'Monthly';
	@override String get total => 'Total Pay';
	@override String get perCase => 'Per case';
	@override String get etc => 'Etc';
	@override String get yearly => 'Yearly';
}

// Path: jobs.workPeriods
class _TranslationsJobsWorkPeriodsEn extends TranslationsJobsWorkPeriodsId {
	_TranslationsJobsWorkPeriodsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get shortTerm => 'Short term';
	@override String get midTerm => 'Mid term';
	@override String get longTerm => 'Long term';
	@override String get oneTime => 'One-time';
	@override String get k1Week => '1 Week';
	@override String get k1Month => '1 Month';
	@override String get k3Months => '3 Months';
	@override String get k6MonthsPlus => '6 Months+';
	@override String get negotiable => 'Negotiable';
	@override String get etc => 'Etc';
}

// Path: jobs.detail
class _TranslationsJobsDetailEn extends TranslationsJobsDetailId {
	_TranslationsJobsDetailEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get infoTitle => 'Details';
	@override String get apply => 'Apply';
	@override String get noAuthor => 'No author info';
	@override String get chatError => 'Could not start chat: {error}';
}

// Path: jobs.card
class _TranslationsJobsCardEn extends TranslationsJobsCardId {
	_TranslationsJobsCardEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get noLocation => 'No location info';
	@override String get minutesAgo => 'minutes ago';
}

// Path: findFriend.tabs
class _TranslationsFindFriendTabsEn extends TranslationsFindFriendTabsId {
	_TranslationsFindFriendTabsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get friends => 'Friends';
	@override String get groups => 'Groups';
	@override String get clubs => 'Clubs';
}

// Path: interests.items
class _TranslationsInterestsItemsEn extends TranslationsInterestsItemsId {
	_TranslationsInterestsItemsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get drawing => 'Drawing';
	@override String get instrument => 'Playing instruments';
	@override String get photography => 'Photography';
	@override String get writing => 'Writing';
	@override String get crafting => 'Crafting';
	@override String get gardening => 'Gardening';
	@override String get soccer => 'Soccer/Futsal';
	@override String get hiking => 'Hiking';
	@override String get camping => 'Camping';
	@override String get running => 'Running/Jogging';
	@override String get biking => 'Cycling';
	@override String get golf => 'Golf';
	@override String get workout => 'Workout/Fitness';
	@override String get foodie => 'Foodie';
	@override String get cooking => 'Cooking';
	@override String get baking => 'Baking';
	@override String get coffee => 'Coffee';
	@override String get wine => 'Wine/Drinks';
	@override String get tea => 'Tea';
	@override String get movies => 'Movies/Drama';
	@override String get music => 'Listening to music';
	@override String get concerts => 'Concerts/Festivals';
	@override String get gaming => 'Gaming';
	@override String get reading => 'Reading';
	@override String get investing => 'Investing';
	@override String get language => 'Language learning';
	@override String get coding => 'Coding';
	@override String get travel => 'Travel';
	@override String get pets => 'Pets';
	@override String get volunteering => 'Volunteering';
	@override String get minimalism => 'Minimalism';
}

// Path: clubs.tabs
class _TranslationsClubsTabsEn extends TranslationsClubsTabsId {
	_TranslationsClubsTabsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get proposals => 'Proposals';
	@override String get activeClubs => 'Active Clubs';
	@override String get myClubs => 'My Clubs';
	@override String get exploreClubs => 'Explore Clubs';
}

// Path: clubs.sections
class _TranslationsClubsSectionsEn extends TranslationsClubsSectionsId {
	_TranslationsClubsSectionsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get active => 'Official clubs';
	@override String get proposals => 'Club proposals';
}

// Path: clubs.screen
class _TranslationsClubsScreenEn extends TranslationsClubsScreenId {
	_TranslationsClubsScreenEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get error => 'Error: {error}';
	@override String get empty => 'No clubs yet.';
}

// Path: clubs.postList
class _TranslationsClubsPostListEn extends TranslationsClubsPostListId {
	_TranslationsClubsPostListEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get empty => 'No posts yet. Be the first!';
	@override String get writeTooltip => 'Write';
}

// Path: clubs.memberCard
class _TranslationsClubsMemberCardEn extends TranslationsClubsMemberCardId {
	_TranslationsClubsMemberCardEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get kickConfirmTitle => 'Remove {memberName}?';
	@override String get kickConfirmContent => 'Removed members can no longer participate in club activities.';
	@override String get kick => 'Remove';
	@override String get kickedSuccess => 'Removed {memberName}.';
	@override String get kickFail => 'Failed to remove member: {error}';
}

// Path: clubs.postCard
class _TranslationsClubsPostCardEn extends TranslationsClubsPostCardId {
	_TranslationsClubsPostCardEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get deleteTitle => 'Delete Post';
	@override String get deleteContent => 'Are you sure you want to delete this post? This action cannot be undone.';
	@override String get deleteSuccess => 'Post deleted.';
	@override String get deleteFail => 'Failed to delete post: {error}';
	@override String get withdrawnMember => 'Member left';
	@override String get deleteTooltip => 'Delete post';
	@override String get loadingUser => 'Loading user info...';
}

// Path: clubs.card
class _TranslationsClubsCardEn extends TranslationsClubsCardId {
	_TranslationsClubsCardEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get membersCount => '{count} members';
}

// Path: clubs.postDetail
class _TranslationsClubsPostDetailEn extends TranslationsClubsPostDetailId {
	_TranslationsClubsPostDetailEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get commentFail => 'Failed to add comment: {error}';
	@override String get appBarTitle => '{title} Board';
	@override String get commentsTitle => 'Comments';
	@override String get noComments => 'No comments yet.';
	@override String get commentHint => 'Write a comment...';
	@override String get unknownUser => 'Unknown user';
}

// Path: clubs.detail
class _TranslationsClubsDetailEn extends TranslationsClubsDetailId {
	_TranslationsClubsDetailEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get joined => 'Joined club \'{title}\'!';
	@override String get pendingApproval => 'Waiting for owner approval. You can participate after approval.';
	@override String get joinFail => 'Failed to request join: {error}';
	@override late final _TranslationsClubsDetailTabsEn tabs = _TranslationsClubsDetailTabsEn._(_root);
	@override String get joinChat => 'Join chat';
	@override String get joinClub => 'Join Club';
	@override String get owner => 'Admin';
	@override late final _TranslationsClubsDetailInfoEn info = _TranslationsClubsDetailInfoEn._(_root);
	@override String get location => 'Location';
	@override String get leaveConfirmTitle => 'Leave club';
	@override String get leaveConfirmContent => 'Are you sure you want to leave {title}?';
	@override String get leave => 'Leave';
	@override String get leaveSuccess => 'You have left {title}';
	@override String get leaveFail => 'Failed to leave: {error}';
}

// Path: clubs.memberList
class _TranslationsClubsMemberListEn extends TranslationsClubsMemberListId {
	_TranslationsClubsMemberListEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get pendingMembers => 'Pending Members';
	@override String get allMembers => 'All Members';
}

// Path: clubs.createPost
class _TranslationsClubsCreatePostEn extends TranslationsClubsCreatePostId {
	_TranslationsClubsCreatePostEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'New Post';
	@override String get submit => 'Submit';
	@override String get success => 'Post submitted.';
	@override String get fail => 'Failed to submit post: {error}';
	@override String get bodyHint => 'Enter content...';
}

// Path: clubs.createClub
class _TranslationsClubsCreateClubEn extends TranslationsClubsCreateClubId {
	_TranslationsClubsCreateClubEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get selectAtLeastOneInterest => 'Select at least one interest.';
	@override String get success => 'Club created!';
	@override String get fail => 'Failed to create club: {error}';
	@override String get title => 'Create Club';
	@override String get nameLabel => 'Club Name';
	@override String get nameError => 'Please enter a club name.';
	@override String get descriptionLabel => 'Club Description';
	@override String get descriptionError => 'Please enter a club description.';
	@override String get tagsHint => 'Type a tag and press Space to add';
	@override String get maxInterests => 'You can select up to 3 interests.';
	@override String get privateClub => 'Private Club';
	@override String get privateDescription => 'Invitation only.';
	@override String get locationLabel => 'Location';
}

// Path: clubs.editClub
class _TranslationsClubsEditClubEn extends TranslationsClubsEditClubId {
	_TranslationsClubsEditClubEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Edit Club Info';
	@override String get save => 'Save';
	@override String get success => 'Club info updated.';
	@override String get fail => 'Failed to update club: {error}';
}

// Path: clubs.create
class _TranslationsClubsCreateEn extends TranslationsClubsCreateId {
	_TranslationsClubsCreateEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Create Club';
}

// Path: clubs.repository
class _TranslationsClubsRepositoryEn extends TranslationsClubsRepositoryId {
	_TranslationsClubsRepositoryEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get chatCreated => 'Club chat room created.';
}

// Path: clubs.proposal
class _TranslationsClubsProposalEn extends TranslationsClubsProposalId {
	_TranslationsClubsProposalEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get createTitle => 'Propose a Club';
	@override String get imageError => 'Please select a cover image.';
	@override String get createSuccess => 'Your club proposal has been created.';
	@override String get createFail => 'Failed to create proposal: {error}';
	@override String get tagsHint => 'Type a tag and press Space to add';
	@override String get targetMembers => 'Target members';
	@override String get targetMembersCount => 'Total {count} members';
	@override String get empty => 'No proposals yet.';
	@override String get memberStatus => '{current} / {target} members';
	@override String get join => 'Join';
	@override String get leave => 'Leave';
	@override String get members => 'Members';
	@override String get noMembers => 'No members yet.';
	@override late final _TranslationsClubsProposalDetailEn detail = _TranslationsClubsProposalDetailEn._(_root);
}

// Path: findfriend.form
class _TranslationsFindfriendFormEn extends TranslationsFindfriendFormId {
	_TranslationsFindfriendFormEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Create Find Friends Profile';
}

// Path: auctions.card
class _TranslationsAuctionsCardEn extends TranslationsAuctionsCardId {
	_TranslationsAuctionsCardEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get currentBid => 'Current bid';
	@override String get endTime => 'Time left';
	@override String get ended => 'Ended';
	@override String get winningBid => 'Winning bid';
	@override String get winner => 'Winner';
	@override String get noBidders => 'No bidders yet';
	@override String get unknownBidder => 'Unknown bidder';
	@override String get timeLeft => '{hours}:{minutes}:{seconds} left';
	@override String get timeLeftDays => '{days} days {hours}:{minutes}:{seconds} left';
}

// Path: auctions.errors
class _TranslationsAuctionsErrorsEn extends TranslationsAuctionsErrorsId {
	_TranslationsAuctionsErrorsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get fetchFailed => 'Failed to load auctions: {error}';
	@override String get notFound => 'Auction not found.';
	@override String get lowerBid => 'You must enter a higher bid than the current one.';
	@override String get alreadyEnded => 'This auction has already ended.';
}

// Path: auctions.filter
class _TranslationsAuctionsFilterEn extends TranslationsAuctionsFilterId {
	_TranslationsAuctionsFilterEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get tooltip => 'Filter';
	@override String get clearTooltip => 'Clear filter';
}

// Path: auctions.create
class _TranslationsAuctionsCreateEn extends TranslationsAuctionsCreateId {
	_TranslationsAuctionsCreateEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get tooltip => 'Create Auction';
	@override String get title => 'Create Auction';
	@override String get registrationType => 'Registration type';
	@override late final _TranslationsAuctionsCreateTypeEn type = _TranslationsAuctionsCreateTypeEn._(_root);
	@override String get success => 'Auction created.';
	@override String get fail => 'Failed to create auction: {error}';
	@override String get submitButton => 'Start Auction';
	@override String get confirmTitle => 'List as an auction?';
	@override String get confirmContent => 'Once listed as an auction, you can\'t switch back to a normal sale. A 5% fee will be charged upon a successful bid. Continue?';
	@override late final _TranslationsAuctionsCreateErrorsEn errors = _TranslationsAuctionsCreateErrorsEn._(_root);
	@override late final _TranslationsAuctionsCreateFormEn form = _TranslationsAuctionsCreateFormEn._(_root);
}

// Path: auctions.edit
class _TranslationsAuctionsEditEn extends TranslationsAuctionsEditId {
	_TranslationsAuctionsEditEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get tooltip => 'Edit auction';
	@override String get title => 'Edit Auction';
	@override String get save => 'Save';
	@override String get success => 'Auction updated.';
	@override String get fail => 'Failed to update auction: {error}';
}

// Path: auctions.form
class _TranslationsAuctionsFormEn extends TranslationsAuctionsFormId {
	_TranslationsAuctionsFormEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get titleRequired => 'Please enter a title.';
	@override String get descriptionRequired => 'Please enter a description.';
	@override String get startPriceRequired => 'Please enter a start price.';
	@override String get categoryRequired => 'Please select a category.';
}

// Path: auctions.delete
class _TranslationsAuctionsDeleteEn extends TranslationsAuctionsDeleteId {
	_TranslationsAuctionsDeleteEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get tooltip => 'Delete auction';
	@override String get confirmTitle => 'Delete auction';
	@override String get confirmContent => 'Are you sure you want to delete this auction?';
	@override String get success => 'Auction deleted.';
	@override String get fail => 'Failed to delete auction: {error}';
}

// Path: auctions.detail
class _TranslationsAuctionsDetailEn extends TranslationsAuctionsDetailId {
	_TranslationsAuctionsDetailEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get currentBid => 'Current bid: {amount}';
	@override String get location => 'Location';
	@override String get seller => 'Seller';
	@override String get qnaTitle => 'Q&A';
	@override String get qnaHint => 'Ask the seller...';
	@override String get endTime => 'End time: {time}';
	@override String get bidsTitle => 'Bids';
	@override String get noBids => 'No bids yet.';
	@override String get unknownBidder => 'Unknown bidder';
	@override String get bidAmountLabel => 'Enter bid (Rp)';
	@override String get placeBid => 'Bid';
	@override String get bidSuccess => 'Bid successful!';
	@override String get bidFail => 'Failed to bid: {error}';
	@override late final _TranslationsAuctionsDetailErrorsEn errors = _TranslationsAuctionsDetailErrorsEn._(_root);
}

// Path: localStores.create
class _TranslationsLocalStoresCreateEn extends TranslationsLocalStoresCreateId {
	_TranslationsLocalStoresCreateEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get tooltip => 'Register my store';
	@override String get title => 'Register New Store';
	@override String get submit => 'Register';
	@override String get success => 'Store registered.';
	@override String get fail => 'Failed to register store: {error}';
}

// Path: localStores.edit
class _TranslationsLocalStoresEditEn extends TranslationsLocalStoresEditId {
	_TranslationsLocalStoresEditEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Edit Store Info';
	@override String get save => 'Save';
	@override String get success => 'Store info updated.';
	@override String get fail => 'Failed to update store: {error}';
	@override String get tooltip => 'Edit store info';
}

// Path: localStores.form
class _TranslationsLocalStoresFormEn extends TranslationsLocalStoresFormId {
	_TranslationsLocalStoresFormEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get nameLabel => 'Store Name';
	@override String get nameError => 'Please enter a store name.';
	@override String get descriptionLabel => 'Store Description';
	@override String get descriptionError => 'Please enter a store description.';
	@override String get contactLabel => 'Contact';
	@override String get hoursLabel => 'Hours';
	@override String get hoursHint => 'e.g. 09:00 - 18:00';
	@override String get photoLabel => 'Photos (max {count})';
	@override String get categoryLabel => 'Category';
	@override String get categoryError => 'Please select a category.';
	@override String get productsLabel => 'Representative Products/Services';
	@override String get productsHint => 'Comma-separated, e.g. Haircut, Coloring, Perm';
	@override String get imageError => 'Failed to load image. Please try again.';
}

// Path: localStores.categories
class _TranslationsLocalStoresCategoriesEn extends TranslationsLocalStoresCategoriesId {
	_TranslationsLocalStoresCategoriesEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get all => 'All';
	@override String get food => 'Restaurant';
	@override String get cafe => 'Cafe';
	@override String get massage => 'Massage';
	@override String get beauty => 'Beauty';
	@override String get nail => 'Nail';
	@override String get auto => 'Auto Repair';
	@override String get kids => 'Kids';
	@override String get hospital => 'Hospital/Clinic';
	@override String get etc => 'Others';
}

// Path: localStores.detail
class _TranslationsLocalStoresDetailEn extends TranslationsLocalStoresDetailId {
	_TranslationsLocalStoresDetailEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get description => 'Store Description';
	@override String get products => 'Products/Services';
	@override String get deleteTitle => 'Delete Store';
	@override String get deleteContent => 'Are you sure you want to delete this store? This action cannot be undone.';
	@override String get deleteTooltip => 'Delete store';
	@override String get delete => 'Delete';
	@override String get cancel => 'Cancel';
	@override String get deleteSuccess => 'Store deleted.';
	@override String get deleteFail => 'Failed to delete store: {error}';
	@override String get inquire => 'Inquire';
	@override String get noOwnerInfo => 'No owner info';
	@override String get startChatFail => 'Could not start chat: {error}';
	@override String get reviews => 'Reviews';
	@override String get writeReview => 'Write a review';
	@override String get noReviews => 'No reviews yet.';
	@override String get reviewDialogContent => 'Please write your review.';
}

// Path: pom.search
class _TranslationsPomSearchEn extends TranslationsPomSearchId {
	_TranslationsPomSearchEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get hint => 'Search POMs, tags, users';
}

// Path: pom.tabs
class _TranslationsPomTabsEn extends TranslationsPomTabsId {
	_TranslationsPomTabsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get local => 'Local';
	@override String get all => 'All';
	@override String get popular => 'Popular';
	@override String get myPoms => 'My POMs';
}

// Path: pom.errors
class _TranslationsPomErrorsEn extends TranslationsPomErrorsId {
	_TranslationsPomErrorsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get fetchFailed => 'An error occurred: {error}';
	@override String get videoSource => 'Can\'t play this video. The source is unavailable or blocked.';
}

// Path: pom.comments
class _TranslationsPomCommentsEn extends TranslationsPomCommentsId {
	_TranslationsPomCommentsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Comments';
	@override String get viewAll => 'View all {} comments';
	@override String get empty => 'No comments yet.';
	@override String get placeholder => 'Write a comment...';
	@override String get fail => 'Failed to add comment: {error}';
}

// Path: pom.create
class _TranslationsPomCreateEn extends TranslationsPomCreateId {
	_TranslationsPomCreateEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Upload New POM';
	@override String get photo => 'Photo';
	@override String get video => 'Video';
	@override String get titleImage => 'Upload Photos';
	@override String get submit => 'Upload';
	@override String get success => 'POM uploaded.';
	@override String get fail => 'Failed to upload POM: {error}';
	@override late final _TranslationsPomCreateFormEn form = _TranslationsPomCreateFormEn._(_root);
}

// Path: realEstate.priceUnits
class _TranslationsRealEstatePriceUnitsEn extends TranslationsRealEstatePriceUnitsId {
	_TranslationsRealEstatePriceUnitsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get monthly => 'month';
	@override String get yearly => 'year';
}

// Path: realEstate.priceUnit
class _TranslationsRealEstatePriceUnitEn extends TranslationsRealEstatePriceUnitId {
	_TranslationsRealEstatePriceUnitEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get monthly => '/month';
}

// Path: realEstate.form
class _TranslationsRealEstateFormEn extends TranslationsRealEstateFormId {
	_TranslationsRealEstateFormEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Register Listing';
	@override String get submit => 'Register';
	@override String get imageRequired => 'Please attach at least one photo.';
	@override String get success => 'Listing created.';
	@override String get fail => 'Failed to create listing: {error}';
	@override late final _TranslationsRealEstateFormTypeEn type = _TranslationsRealEstateFormTypeEn._(_root);
	@override String get priceLabel => 'Price';
	@override String get priceRequired => 'Enter the price.';
	@override late final _TranslationsRealEstateFormPriceUnitEn priceUnit = _TranslationsRealEstateFormPriceUnitEn._(_root);
	@override String get titleLabel => 'Title';
	@override String get titleRequired => 'Enter a title.';
	@override String get descriptionLabel => 'Description';
	@override String get typeLabel => 'Room type';
	@override late final _TranslationsRealEstateFormRoomTypesEn roomTypes = _TranslationsRealEstateFormRoomTypesEn._(_root);
	@override String get listingType => 'Transaction type';
	@override String get listingTypeHint => 'Select transaction type';
	@override late final _TranslationsRealEstateFormListingTypesEn listingTypes = _TranslationsRealEstateFormListingTypesEn._(_root);
	@override String get publisherType => 'Publisher';
	@override late final _TranslationsRealEstateFormPublisherTypesEn publisherTypes = _TranslationsRealEstateFormPublisherTypesEn._(_root);
	@override String get area => 'Area';
	@override String get areaHint => 'e.g. 33';
	@override String get landArea => 'Land area';
	@override String get rooms => 'Rooms';
	@override String get bathrooms => 'Bathrooms';
	@override String get bedAbbr => 'Bed';
	@override String get bathAbbr => 'Bath';
	@override String get moveInDate => 'Move-in date';
	@override String get selectDate => 'Select date';
	@override String get clearDate => 'Clear date';
	@override String get amenities => 'Amenities';
	@override late final _TranslationsRealEstateFormAmenityEn amenity = _TranslationsRealEstateFormAmenityEn._(_root);
	@override String get details => 'Listing Details';
	@override String get maintenanceFee => 'Monthly maintenance fee';
	@override String get maintenanceFeeHint => 'Maintenance fee (per month, Rp)';
	@override String get deposit => 'Deposit';
	@override String get depositHint => 'Deposit (Rp)';
	@override String get floorInfo => 'Floor info';
	@override String get floorInfoHint => 'e.g., Floor 1 / 3 of 5';
}

// Path: realEstate.filter
class _TranslationsRealEstateFilterEn extends TranslationsRealEstateFilterId {
	_TranslationsRealEstateFilterEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsRealEstateFilterAmenitiesEn amenities = _TranslationsRealEstateFilterAmenitiesEn._(_root);
	@override String get title => 'Advanced filters';
	@override String get priceRange => 'Price range';
	@override String get areaRange => 'Area range (m²)';
	@override String get landAreaRange => 'Land area range (m²)';
	@override String get depositRange => 'Deposit range';
	@override String get floorInfo => 'Floor info';
	@override String get depositMin => 'Min deposit';
	@override String get depositMax => 'Max deposit';
	@override String get clearFloorInfo => 'Clear';
	@override String get furnishedStatus => 'Furnishing';
	@override String get rentPeriod => 'Rent period';
	@override String get selectFurnished => 'Select furnishing';
	@override String get furnishedHint => 'Select furnishing';
	@override String get selectRentPeriod => 'Select rent period';
	@override late final _TranslationsRealEstateFilterRentPeriodsEn rentPeriods = _TranslationsRealEstateFilterRentPeriodsEn._(_root);
	@override late final _TranslationsRealEstateFilterKosEn kos = _TranslationsRealEstateFilterKosEn._(_root);
	@override late final _TranslationsRealEstateFilterApartmentEn apartment = _TranslationsRealEstateFilterApartmentEn._(_root);
	@override late final _TranslationsRealEstateFilterHouseEn house = _TranslationsRealEstateFilterHouseEn._(_root);
	@override late final _TranslationsRealEstateFilterCommercialEn commercial = _TranslationsRealEstateFilterCommercialEn._(_root);
	@override String get propertyCondition => 'Property condition';
	@override late final _TranslationsRealEstateFilterPropertyConditionsEn propertyConditions = _TranslationsRealEstateFilterPropertyConditionsEn._(_root);
	@override late final _TranslationsRealEstateFilterFurnishedTypesEn furnishedTypes = _TranslationsRealEstateFilterFurnishedTypesEn._(_root);
}

// Path: realEstate.info
class _TranslationsRealEstateInfoEn extends TranslationsRealEstateInfoId {
	_TranslationsRealEstateInfoEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get bed => 'Bed';
	@override String get bath => 'Bath';
	@override String get anytime => 'Anytime';
	@override String get verifiedPublisher => 'Verified publisher';
}

// Path: realEstate.detail
class _TranslationsRealEstateDetailEn extends TranslationsRealEstateDetailId {
	_TranslationsRealEstateDetailEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get deleteTitle => 'Delete listing';
	@override String get deleteContent => 'Are you sure you want to delete this listing?';
	@override String get cancel => 'Cancel';
	@override String get deleteConfirm => 'Delete';
	@override String get deleteSuccess => 'Listing deleted.';
	@override String get deleteFail => 'Failed to delete listing: {error}';
	@override String get chatError => 'Could not start chat: {error}';
	@override String get location => 'Location';
	@override String get publisherInfo => 'Publisher Info';
	@override String get contact => 'Contact';
}

// Path: realEstate.edit
class _TranslationsRealEstateEditEn extends TranslationsRealEstateEditId {
	_TranslationsRealEstateEditEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Edit Listing';
	@override String get save => 'Save';
	@override String get success => 'Listing updated.';
	@override String get fail => 'Failed to update listing: {error}';
}

// Path: lostAndFound.resolve
class _TranslationsLostAndFoundResolveEn extends TranslationsLostAndFoundResolveId {
	_TranslationsLostAndFoundResolveEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get confirmTitle => 'Mark as resolved?';
	@override String get confirmBody => 'This will mark the item as resolved.';
	@override String get success => 'Marked as resolved.';
	@override String get badgeLost => 'Found!';
	@override String get badgeFound => 'Returned!';
}

// Path: lostAndFound.tabs
class _TranslationsLostAndFoundTabsEn extends TranslationsLostAndFoundTabsId {
	_TranslationsLostAndFoundTabsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get all => 'All';
	@override String get lost => 'Lost';
	@override String get found => 'Found';
}

// Path: lostAndFound.card
class _TranslationsLostAndFoundCardEn extends TranslationsLostAndFoundCardId {
	_TranslationsLostAndFoundCardEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get location => 'Location: {location}';
}

// Path: lostAndFound.form
class _TranslationsLostAndFoundFormEn extends TranslationsLostAndFoundFormId {
	_TranslationsLostAndFoundFormEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Register Lost/Found Item';
	@override String get submit => 'Register';
	@override late final _TranslationsLostAndFoundFormTypeEn type = _TranslationsLostAndFoundFormTypeEn._(_root);
	@override String get photoSectionTitle => 'Add photos (max 5)';
	@override String get imageRequired => 'Please attach at least one photo.';
	@override String get itemLabel => 'What is the item?';
	@override String get itemError => 'Please describe the item.';
	@override String get locationLabel => 'Where was it lost or found?';
	@override String get locationError => 'Please describe the location.';
	@override String get bountyTitle => 'Set bounty (optional)';
	@override String get bountyDesc => 'When enabled, a bounty tag will appear on your post.';
	@override String get bountyAmount => 'Bounty amount (IDR)';
	@override String get bountyAmountError => 'Enter a bounty amount to enable bounty.';
	@override String get success => 'Registered.';
	@override String get fail => 'Failed to register: {error}';
	@override String get tagsHint => 'Add tags (press space to confirm)';
}

// Path: lostAndFound.edit
class _TranslationsLostAndFoundEditEn extends TranslationsLostAndFoundEditId {
	_TranslationsLostAndFoundEditEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Edit Lost/Found Item';
	@override String get save => 'Save';
	@override String get success => 'Updated.';
	@override String get fail => 'Failed to update: {error}';
}

// Path: lostAndFound.detail
class _TranslationsLostAndFoundDetailEn extends TranslationsLostAndFoundDetailId {
	_TranslationsLostAndFoundDetailEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Lost & Found';
	@override String get location => 'Location';
	@override String get bounty => 'Bounty';
	@override String get registrant => 'Registrant';
	@override String get contact => 'Contact';
	@override String get resolved => 'Resolved';
	@override String get markAsResolved => 'Mark as Resolved';
	@override String get deleteTitle => 'Delete Post';
	@override String get deleteContent => 'Are you sure you want to delete this post? This action cannot be undone.';
	@override String get delete => 'Delete';
	@override String get cancel => 'Cancel';
	@override String get deleteSuccess => 'Post deleted.';
	@override String get deleteFail => 'Failed to delete post: {error}';
	@override String get editTooltip => 'Edit';
	@override String get deleteTooltip => 'Delete';
	@override String get noUser => 'User not found';
	@override String get chatError => 'Could not start chat: {error}';
}

// Path: shared.tagInput
class _TranslationsSharedTagInputEn extends TranslationsSharedTagInputId {
	_TranslationsSharedTagInputEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get defaultHint => 'Add tags (press space to confirm)';
}

// Path: admin.screen
class _TranslationsAdminScreenEn extends TranslationsAdminScreenId {
	_TranslationsAdminScreenEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Admin Menu';
}

// Path: admin.menu
class _TranslationsAdminMenuEn extends TranslationsAdminMenuId {
	_TranslationsAdminMenuEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get aiApproval => 'AI Verification Management';
	@override String get reportManagement => 'Report Management';
}

// Path: admin.aiApproval
class _TranslationsAdminAiApprovalEn extends TranslationsAdminAiApprovalId {
	_TranslationsAdminAiApprovalEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get empty => 'No products pending AI verification.';
	@override String get error => 'Error loading pending products.';
	@override String get requestedAt => 'Requested at';
}

// Path: admin.reports
class _TranslationsAdminReportsEn extends TranslationsAdminReportsId {
	_TranslationsAdminReportsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Report Management';
	@override String get empty => 'No pending reports.';
	@override String get error => 'Error loading reports.';
	@override String get createdAt => 'Created at';
}

// Path: admin.reportList
class _TranslationsAdminReportListEn extends TranslationsAdminReportListId {
	_TranslationsAdminReportListEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Report Management';
	@override String get empty => 'No pending reports.';
	@override String get error => 'Error loading reports.';
}

// Path: admin.reportDetail
class _TranslationsAdminReportDetailEn extends TranslationsAdminReportDetailId {
	_TranslationsAdminReportDetailEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'Report Details';
	@override String get loadError => 'Error loading report details.';
	@override String get sectionReportInfo => 'Report Information';
	@override String get idLabel => 'ID';
	@override String get postIdLabel => 'Reported Post ID';
	@override String get reporter => 'Reporter';
	@override String get reportedUser => 'Reported User';
	@override String get reason => 'Reason';
	@override String get reportedAt => 'Reported At';
	@override String get currentStatus => 'Status';
	@override String get sectionContent => 'Reported Content';
	@override String get loadingContent => 'Loading content...';
	@override String get contentLoadError => 'Failed to load reported content.';
	@override String get contentNotAvailable => 'Content information not available or deleted.';
	@override String get authorIdLabel => 'Author ID';
	@override late final _TranslationsAdminReportDetailContentEn content = _TranslationsAdminReportDetailContentEn._(_root);
	@override String get viewOriginalPost => 'View Original Post';
	@override String get sectionActions => 'Actions';
	@override String get actionReviewed => 'Mark as Reviewed';
	@override String get actionTaken => 'Mark Action Taken (e.g., Deleted)';
	@override String get actionDismissed => 'Dismiss Report';
	@override String get statusUpdateSuccess => 'Report status updated to \'{status}\'.';
	@override String get statusUpdateFail => 'Failed to update status: {error}';
	@override String get originalPostNotFound => 'Original post not found.';
	@override String get couldNotOpenOriginalPost => 'Could not open original post.';
}

// Path: admin.dataFix
class _TranslationsAdminDataFixEn extends TranslationsAdminDataFixId {
	_TranslationsAdminDataFixEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get logsLabel => 'Data Fix Logs';
}

// Path: tags.localNews
class _TranslationsTagsLocalNewsEn extends TranslationsTagsLocalNewsId {
	_TranslationsTagsLocalNewsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsTagsLocalNewsKelurahanNoticeEn kelurahanNotice = _TranslationsTagsLocalNewsKelurahanNoticeEn._(_root);
	@override late final _TranslationsTagsLocalNewsKecamatanNoticeEn kecamatanNotice = _TranslationsTagsLocalNewsKecamatanNoticeEn._(_root);
	@override late final _TranslationsTagsLocalNewsPublicCampaignEn publicCampaign = _TranslationsTagsLocalNewsPublicCampaignEn._(_root);
	@override late final _TranslationsTagsLocalNewsSiskamlingEn siskamling = _TranslationsTagsLocalNewsSiskamlingEn._(_root);
	@override late final _TranslationsTagsLocalNewsPowerOutageEn powerOutage = _TranslationsTagsLocalNewsPowerOutageEn._(_root);
	@override late final _TranslationsTagsLocalNewsWaterOutageEn waterOutage = _TranslationsTagsLocalNewsWaterOutageEn._(_root);
	@override late final _TranslationsTagsLocalNewsWasteCollectionEn wasteCollection = _TranslationsTagsLocalNewsWasteCollectionEn._(_root);
	@override late final _TranslationsTagsLocalNewsRoadWorksEn roadWorks = _TranslationsTagsLocalNewsRoadWorksEn._(_root);
	@override late final _TranslationsTagsLocalNewsPublicFacilityEn publicFacility = _TranslationsTagsLocalNewsPublicFacilityEn._(_root);
	@override late final _TranslationsTagsLocalNewsWeatherWarningEn weatherWarning = _TranslationsTagsLocalNewsWeatherWarningEn._(_root);
	@override late final _TranslationsTagsLocalNewsFloodAlertEn floodAlert = _TranslationsTagsLocalNewsFloodAlertEn._(_root);
	@override late final _TranslationsTagsLocalNewsAirQualityEn airQuality = _TranslationsTagsLocalNewsAirQualityEn._(_root);
	@override late final _TranslationsTagsLocalNewsDiseaseAlertEn diseaseAlert = _TranslationsTagsLocalNewsDiseaseAlertEn._(_root);
	@override late final _TranslationsTagsLocalNewsSchoolNoticeEn schoolNotice = _TranslationsTagsLocalNewsSchoolNoticeEn._(_root);
	@override late final _TranslationsTagsLocalNewsPosyanduEn posyandu = _TranslationsTagsLocalNewsPosyanduEn._(_root);
	@override late final _TranslationsTagsLocalNewsHealthCampaignEn healthCampaign = _TranslationsTagsLocalNewsHealthCampaignEn._(_root);
	@override late final _TranslationsTagsLocalNewsTrafficControlEn trafficControl = _TranslationsTagsLocalNewsTrafficControlEn._(_root);
	@override late final _TranslationsTagsLocalNewsPublicTransportEn publicTransport = _TranslationsTagsLocalNewsPublicTransportEn._(_root);
	@override late final _TranslationsTagsLocalNewsParkingPolicyEn parkingPolicy = _TranslationsTagsLocalNewsParkingPolicyEn._(_root);
	@override late final _TranslationsTagsLocalNewsCommunityEventEn communityEvent = _TranslationsTagsLocalNewsCommunityEventEn._(_root);
	@override late final _TranslationsTagsLocalNewsWorshipEventEn worshipEvent = _TranslationsTagsLocalNewsWorshipEventEn._(_root);
	@override late final _TranslationsTagsLocalNewsIncidentReportEn incidentReport = _TranslationsTagsLocalNewsIncidentReportEn._(_root);
}

// Path: boards.popup
class _TranslationsBoardsPopupEn extends TranslationsBoardsPopupId {
	_TranslationsBoardsPopupEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get inactiveTitle => 'Neighborhood board is inactive';
	@override String get inactiveBody => 'To activate your neighborhood board, create a local news post first. Once neighbors join in, the board will open automatically.';
	@override String get writePost => 'Write Local News';
}

// Path: signup.alerts
class _TranslationsSignupAlertsEn extends TranslationsSignupAlertsId {
	_TranslationsSignupAlertsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get signupSuccessLoginNotice => 'Sign up successful! Please log in.';
}

// Path: signup.buttons
class _TranslationsSignupButtonsEn extends TranslationsSignupButtonsId {
	_TranslationsSignupButtonsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get signup => 'Sign Up';
}

// Path: main.search.hint
class _TranslationsMainSearchHintEn extends TranslationsMainSearchHintId {
	_TranslationsMainSearchHintEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get globalSheet => 'Search in {}';
	@override String get localNews => 'Search news title, content, tags';
	@override String get jobs => 'Search jobs, company, \'Help Me\'';
	@override String get lostAndFound => 'Search lost or found items';
	@override String get marketplace => 'Search products for sale';
	@override String get localStores => 'Search local stores, services';
	@override String get findFriends => 'Search profile nickname, interests';
	@override String get clubs => 'Search clubs, interests, location';
	@override String get realEstate => 'Search properties, area, price';
	@override String get auction => 'Search auction items, brands';
	@override String get pom => 'Search POMs, tags, users';
}

// Path: drawer.trustDashboard.breakdown
class _TranslationsDrawerTrustDashboardBreakdownEn extends TranslationsDrawerTrustDashboardBreakdownId {
	_TranslationsDrawerTrustDashboardBreakdownEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get kelurahanAuth => '+50';
	@override String get rtRwAuth => '+50';
	@override String get phoneAuth => '+100';
	@override String get profileComplete => '+50';
	@override String get feedThanks => '+10 per';
	@override String get marketThanks => '+20 per';
	@override String get reports => '-50 per';
}

// Path: marketplace.takeover.guide
class _TranslationsMarketplaceTakeoverGuideEn extends TranslationsMarketplaceTakeoverGuideId {
	_TranslationsMarketplaceTakeoverGuideEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get title => 'AI on-site similarity verification';
	@override String get subtitle => 'Confirm that the original AI report matches the actual item. Take 3 or more photos that clearly show the item\'s key features.';
}

// Path: marketplace.takeover.errors
class _TranslationsMarketplaceTakeoverErrorsEn extends TranslationsMarketplaceTakeoverErrorsId {
	_TranslationsMarketplaceTakeoverErrorsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get noPhoto => 'At least 1 on-site photo is required for verification.';
}

// Path: marketplace.takeover.dialog
class _TranslationsMarketplaceTakeoverDialogEn extends TranslationsMarketplaceTakeoverDialogId {
	_TranslationsMarketplaceTakeoverDialogEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get matchTitle => 'AI verification success';
	@override String get noMatchTitle => 'AI verification failed';
	@override String get finalize => 'Confirm final takeover';
	@override String get cancelDeal => 'Cancel deal (request refund)';
}

// Path: marketplace.takeover.success
class _TranslationsMarketplaceTakeoverSuccessEn extends TranslationsMarketplaceTakeoverSuccessId {
	_TranslationsMarketplaceTakeoverSuccessEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get finalized => 'Deal completed successfully.';
	@override String get cancelled => 'Deal cancelled. Deposit will be refunded.';
}

// Path: categories.post.jalanPerbaikin
class _TranslationsCategoriesPostJalanPerbaikinEn extends TranslationsCategoriesPostJalanPerbaikinId {
	_TranslationsCategoriesPostJalanPerbaikinEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsCategoriesPostJalanPerbaikinSearchEn search = _TranslationsCategoriesPostJalanPerbaikinSearchEn._(_root);
	@override String get name => 'Road Repair';
}

// Path: categories.post.dailyLife
class _TranslationsCategoriesPostDailyLifeEn extends TranslationsCategoriesPostDailyLifeId {
	_TranslationsCategoriesPostDailyLifeEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Daily/Questions';
	@override String get description => 'Share daily life or ask questions.';
}

// Path: categories.post.helpShare
class _TranslationsCategoriesPostHelpShareEn extends TranslationsCategoriesPostHelpShareId {
	_TranslationsCategoriesPostHelpShareEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Help/Share';
	@override String get description => 'Need help or have something to share?';
}

// Path: categories.post.incidentReport
class _TranslationsCategoriesPostIncidentReportEn extends TranslationsCategoriesPostIncidentReportId {
	_TranslationsCategoriesPostIncidentReportEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Incidents';
	@override String get description => 'Share incident news in your neighborhood.';
}

// Path: categories.post.localNews
class _TranslationsCategoriesPostLocalNewsEn extends TranslationsCategoriesPostLocalNewsId {
	_TranslationsCategoriesPostLocalNewsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Local News';
	@override String get description => 'Share news and info about our neighborhood.';
}

// Path: categories.post.november
class _TranslationsCategoriesPostNovemberEn extends TranslationsCategoriesPostNovemberId {
	_TranslationsCategoriesPostNovemberEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'November';
}

// Path: categories.post.rain
class _TranslationsCategoriesPostRainEn extends TranslationsCategoriesPostRainId {
	_TranslationsCategoriesPostRainEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Rain';
}

// Path: categories.post.dailyQuestion
class _TranslationsCategoriesPostDailyQuestionEn extends TranslationsCategoriesPostDailyQuestionId {
	_TranslationsCategoriesPostDailyQuestionEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Have a Question';
	@override String get description => 'Ask your neighbors anything.';
}

// Path: categories.post.storePromo
class _TranslationsCategoriesPostStorePromoEn extends TranslationsCategoriesPostStorePromoId {
	_TranslationsCategoriesPostStorePromoEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Store Promo';
	@override String get description => 'Promote discounts or events at your store.';
}

// Path: categories.post.etc
class _TranslationsCategoriesPostEtcEn extends TranslationsCategoriesPostEtcId {
	_TranslationsCategoriesPostEtcEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Etc.';
	@override String get description => 'Share other stories freely.';
}

// Path: categories.auction.collectibles
class _TranslationsCategoriesAuctionCollectiblesEn extends TranslationsCategoriesAuctionCollectiblesId {
	_TranslationsCategoriesAuctionCollectiblesEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Collectibles';
	@override String get description => 'Toys, cards, figures, and more.';
}

// Path: categories.auction.digital
class _TranslationsCategoriesAuctionDigitalEn extends TranslationsCategoriesAuctionDigitalId {
	_TranslationsCategoriesAuctionDigitalEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Digital';
	@override String get description => 'Digital goods and assets.';
}

// Path: categories.auction.fashion
class _TranslationsCategoriesAuctionFashionEn extends TranslationsCategoriesAuctionFashionId {
	_TranslationsCategoriesAuctionFashionEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Fashion';
	@override String get description => 'Clothing, accessories, and beauty.';
}

// Path: categories.auction.vintage
class _TranslationsCategoriesAuctionVintageEn extends TranslationsCategoriesAuctionVintageId {
	_TranslationsCategoriesAuctionVintageEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Vintage';
	@override String get description => 'Retro and classic items.';
}

// Path: categories.auction.artCraft
class _TranslationsCategoriesAuctionArtCraftEn extends TranslationsCategoriesAuctionArtCraftId {
	_TranslationsCategoriesAuctionArtCraftEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Art & Craft';
	@override String get description => 'Artwork and handmade crafts.';
}

// Path: categories.auction.etc
class _TranslationsCategoriesAuctionEtcEn extends TranslationsCategoriesAuctionEtcId {
	_TranslationsCategoriesAuctionEtcEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Other';
	@override String get description => 'Other auction items.';
}

// Path: clubs.detail.tabs
class _TranslationsClubsDetailTabsEn extends TranslationsClubsDetailTabsId {
	_TranslationsClubsDetailTabsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get info => 'Info';
	@override String get board => 'Board';
	@override String get members => 'Members';
}

// Path: clubs.detail.info
class _TranslationsClubsDetailInfoEn extends TranslationsClubsDetailInfoId {
	_TranslationsClubsDetailInfoEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get members => 'Members';
	@override String get location => 'Location';
}

// Path: clubs.proposal.detail
class _TranslationsClubsProposalDetailEn extends TranslationsClubsProposalDetailId {
	_TranslationsClubsProposalDetailEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get joined => 'You joined the proposal!';
	@override String get left => 'You left the proposal.';
	@override String get loginRequired => 'Please log in to join.';
	@override String get error => 'An error occurred: {error}';
}

// Path: auctions.create.type
class _TranslationsAuctionsCreateTypeEn extends TranslationsAuctionsCreateTypeId {
	_TranslationsAuctionsCreateTypeEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get sale => 'Sale';
	@override String get auction => 'Auction';
}

// Path: auctions.create.errors
class _TranslationsAuctionsCreateErrorsEn extends TranslationsAuctionsCreateErrorsId {
	_TranslationsAuctionsCreateErrorsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get noPhoto => 'Please add at least one photo.';
}

// Path: auctions.create.form
class _TranslationsAuctionsCreateFormEn extends TranslationsAuctionsCreateFormId {
	_TranslationsAuctionsCreateFormEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get photoSectionTitle => 'Upload photos (max 10)';
	@override String get title => 'Title';
	@override String get description => 'Description';
	@override String get startPrice => 'Start price';
	@override String get category => 'Category';
	@override String get categoryHint => 'Select a category';
	@override String get tagsHint => 'Type a tag and press Space to add';
	@override String get duration => 'Duration';
	@override String get durationOption => '{days} days';
	@override String get location => 'Location';
}

// Path: auctions.detail.errors
class _TranslationsAuctionsDetailErrorsEn extends TranslationsAuctionsDetailErrorsId {
	_TranslationsAuctionsDetailErrorsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get loginRequired => 'Login required.';
	@override String get invalidAmount => 'Enter a valid bid amount.';
}

// Path: pom.create.form
class _TranslationsPomCreateFormEn extends TranslationsPomCreateFormId {
	_TranslationsPomCreateFormEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get titleLabel => 'Title';
	@override String get descriptionLabel => 'Description';
}

// Path: realEstate.form.type
class _TranslationsRealEstateFormTypeEn extends TranslationsRealEstateFormTypeId {
	_TranslationsRealEstateFormTypeEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get kos => 'Boarding house';
	@override String get kontrakan => 'Monthly rent';
	@override String get sewa => 'Lease';
}

// Path: realEstate.form.priceUnit
class _TranslationsRealEstateFormPriceUnitEn extends TranslationsRealEstateFormPriceUnitId {
	_TranslationsRealEstateFormPriceUnitEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get monthly => '/month';
	@override String get yearly => '/year';
}

// Path: realEstate.form.roomTypes
class _TranslationsRealEstateFormRoomTypesEn extends TranslationsRealEstateFormRoomTypesId {
	_TranslationsRealEstateFormRoomTypesEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get kos => 'Boarding house';
	@override String get kontrakan => 'Monthly rent';
	@override String get sewa => 'Lease';
	@override String get apartment => 'Apartment';
	@override String get house => 'House';
	@override String get ruko => 'Shophouse';
	@override String get gudang => 'Warehouse';
	@override String get kantor => 'Office';
	@override String get etc => 'Other';
}

// Path: realEstate.form.listingTypes
class _TranslationsRealEstateFormListingTypesEn extends TranslationsRealEstateFormListingTypesId {
	_TranslationsRealEstateFormListingTypesEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get rent => 'Rent';
	@override String get sale => 'Sale';
}

// Path: realEstate.form.publisherTypes
class _TranslationsRealEstateFormPublisherTypesEn extends TranslationsRealEstateFormPublisherTypesId {
	_TranslationsRealEstateFormPublisherTypesEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get individual => 'Individual';
	@override String get agent => 'Agent';
}

// Path: realEstate.form.amenity
class _TranslationsRealEstateFormAmenityEn extends TranslationsRealEstateFormAmenityId {
	_TranslationsRealEstateFormAmenityEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get wifi => 'Wi-Fi';
	@override String get ac => 'AC';
	@override String get parking => 'Parking';
	@override String get kitchen => 'Kitchen';
}

// Path: realEstate.filter.amenities
class _TranslationsRealEstateFilterAmenitiesEn extends TranslationsRealEstateFilterAmenitiesId {
	_TranslationsRealEstateFilterAmenitiesEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get ac => 'AC';
	@override String get bed => 'Bed';
	@override String get closet => 'Wardrobe';
	@override String get desk => 'Desk';
	@override String get wifi => 'Wi‑Fi';
	@override String get kitchen => 'Kitchen';
	@override String get livingRoom => 'Living room';
	@override String get refrigerator => 'Refrigerator';
	@override String get parkingMotorcycle => 'Motorcycle parking';
	@override String get parkingCar => 'Car parking';
	@override String get pool => 'Swimming pool';
	@override String get gym => 'Gym';
	@override String get security24h => '24h Security';
	@override String get atmCenter => 'ATM center';
	@override String get minimarket => 'Minimarket';
	@override String get mallAccess => 'Mall access';
	@override String get playground => 'Playground';
	@override String get carport => 'Carport';
	@override String get garden => 'Garden';
	@override String get pam => 'Piped water (PAM)';
	@override String get telephone => 'Telephone';
	@override String get waterHeater => 'Water heater';
	@override String get parkingArea => 'Parking area';
	@override String get electricity => 'Electricity (power)';
	@override String get containerAccess => 'Container access';
	@override late final _TranslationsRealEstateFilterAmenitiesKosRoomEn kosRoom = _TranslationsRealEstateFilterAmenitiesKosRoomEn._(_root);
	@override late final _TranslationsRealEstateFilterAmenitiesKosPublicEn kosPublic = _TranslationsRealEstateFilterAmenitiesKosPublicEn._(_root);
	@override late final _TranslationsRealEstateFilterAmenitiesApartmentEn apartment = _TranslationsRealEstateFilterAmenitiesApartmentEn._(_root);
	@override late final _TranslationsRealEstateFilterAmenitiesHouseEn house = _TranslationsRealEstateFilterAmenitiesHouseEn._(_root);
	@override late final _TranslationsRealEstateFilterAmenitiesCommercialEn commercial = _TranslationsRealEstateFilterAmenitiesCommercialEn._(_root);
}

// Path: realEstate.filter.rentPeriods
class _TranslationsRealEstateFilterRentPeriodsEn extends TranslationsRealEstateFilterRentPeriodsId {
	_TranslationsRealEstateFilterRentPeriodsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get daily => 'Daily';
	@override String get monthly => 'Monthly';
	@override String get yearly => 'Yearly';
}

// Path: realEstate.filter.kos
class _TranslationsRealEstateFilterKosEn extends TranslationsRealEstateFilterKosId {
	_TranslationsRealEstateFilterKosEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get bathroomType => 'Bathroom type';
	@override late final _TranslationsRealEstateFilterKosBathroomTypesEn bathroomTypes = _TranslationsRealEstateFilterKosBathroomTypesEn._(_root);
	@override String get maxOccupants => 'Max occupants';
	@override String get hintBathroomType => 'Select bathroom type';
	@override String get hintMaxOccupants => 'Select number of occupants';
	@override String get electricityIncluded => 'Electricity included';
	@override String get roomFacilities => 'Room facilities';
	@override String get publicFacilities => 'Shared facilities';
	@override String get occupant => 'Person(s)';
}

// Path: realEstate.filter.apartment
class _TranslationsRealEstateFilterApartmentEn extends TranslationsRealEstateFilterApartmentId {
	_TranslationsRealEstateFilterApartmentEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get facilities => 'Apartment facilities';
}

// Path: realEstate.filter.house
class _TranslationsRealEstateFilterHouseEn extends TranslationsRealEstateFilterHouseId {
	_TranslationsRealEstateFilterHouseEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get facilities => 'House facilities';
}

// Path: realEstate.filter.commercial
class _TranslationsRealEstateFilterCommercialEn extends TranslationsRealEstateFilterCommercialId {
	_TranslationsRealEstateFilterCommercialEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get facilities => 'Commercial facilities';
}

// Path: realEstate.filter.propertyConditions
class _TranslationsRealEstateFilterPropertyConditionsEn extends TranslationsRealEstateFilterPropertyConditionsId {
	_TranslationsRealEstateFilterPropertyConditionsEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get kNew => 'New';
	@override String get used => 'Used';
}

// Path: realEstate.filter.furnishedTypes
class _TranslationsRealEstateFilterFurnishedTypesEn extends TranslationsRealEstateFilterFurnishedTypesId {
	_TranslationsRealEstateFilterFurnishedTypesEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get furnished => 'Furnished';
	@override String get semiFurnished => 'Semi-furnished';
	@override String get unfurnished => 'Unfurnished';
}

// Path: lostAndFound.form.type
class _TranslationsLostAndFoundFormTypeEn extends TranslationsLostAndFoundFormTypeId {
	_TranslationsLostAndFoundFormTypeEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get lost => 'I lost it';
	@override String get found => 'I found it';
}

// Path: admin.reportDetail.content
class _TranslationsAdminReportDetailContentEn extends TranslationsAdminReportDetailContentId {
	_TranslationsAdminReportDetailContentEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get post => 'Post: {title}\n\n{body}';
	@override String get comment => 'Comment: {content}';
	@override String get reply => 'Reply: {content}';
}

// Path: tags.localNews.kelurahanNotice
class _TranslationsTagsLocalNewsKelurahanNoticeEn extends TranslationsTagsLocalNewsKelurahanNoticeId {
	_TranslationsTagsLocalNewsKelurahanNoticeEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Kelurahan notice';
	@override String get desc => 'Neighborhood office announcements.';
}

// Path: tags.localNews.kecamatanNotice
class _TranslationsTagsLocalNewsKecamatanNoticeEn extends TranslationsTagsLocalNewsKecamatanNoticeId {
	_TranslationsTagsLocalNewsKecamatanNoticeEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Kecamatan notice';
	@override String get desc => 'District office announcements.';
}

// Path: tags.localNews.publicCampaign
class _TranslationsTagsLocalNewsPublicCampaignEn extends TranslationsTagsLocalNewsPublicCampaignId {
	_TranslationsTagsLocalNewsPublicCampaignEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Public campaign';
	@override String get desc => 'Public information and government programs.';
}

// Path: tags.localNews.siskamling
class _TranslationsTagsLocalNewsSiskamlingEn extends TranslationsTagsLocalNewsSiskamlingId {
	_TranslationsTagsLocalNewsSiskamlingEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Neighborhood watch';
	@override String get desc => 'Community safety patrol activities.';
}

// Path: tags.localNews.powerOutage
class _TranslationsTagsLocalNewsPowerOutageEn extends TranslationsTagsLocalNewsPowerOutageId {
	_TranslationsTagsLocalNewsPowerOutageEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Power outage';
	@override String get desc => 'Information about electricity outages in your area.';
}

// Path: tags.localNews.waterOutage
class _TranslationsTagsLocalNewsWaterOutageEn extends TranslationsTagsLocalNewsWaterOutageId {
	_TranslationsTagsLocalNewsWaterOutageEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Water outage';
	@override String get desc => 'Information about water supply outages.';
}

// Path: tags.localNews.wasteCollection
class _TranslationsTagsLocalNewsWasteCollectionEn extends TranslationsTagsLocalNewsWasteCollectionId {
	_TranslationsTagsLocalNewsWasteCollectionEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Waste collection';
	@override String get desc => 'Garbage pickup schedules or notices.';
}

// Path: tags.localNews.roadWorks
class _TranslationsTagsLocalNewsRoadWorksEn extends TranslationsTagsLocalNewsRoadWorksId {
	_TranslationsTagsLocalNewsRoadWorksEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Road works';
	@override String get desc => 'Road construction and maintenance information.';
}

// Path: tags.localNews.publicFacility
class _TranslationsTagsLocalNewsPublicFacilityEn extends TranslationsTagsLocalNewsPublicFacilityId {
	_TranslationsTagsLocalNewsPublicFacilityEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Public facility';
	@override String get desc => 'Parks, fields, and public facility updates.';
}

// Path: tags.localNews.weatherWarning
class _TranslationsTagsLocalNewsWeatherWarningEn extends TranslationsTagsLocalNewsWeatherWarningId {
	_TranslationsTagsLocalNewsWeatherWarningEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Weather warning';
	@override String get desc => 'Severe weather alerts in your area.';
}

// Path: tags.localNews.floodAlert
class _TranslationsTagsLocalNewsFloodAlertEn extends TranslationsTagsLocalNewsFloodAlertId {
	_TranslationsTagsLocalNewsFloodAlertEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Flood alert';
	@override String get desc => 'Flood advisories and areas affected.';
}

// Path: tags.localNews.airQuality
class _TranslationsTagsLocalNewsAirQualityEn extends TranslationsTagsLocalNewsAirQualityId {
	_TranslationsTagsLocalNewsAirQualityEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Air quality';
	@override String get desc => 'Air pollution and AQI information.';
}

// Path: tags.localNews.diseaseAlert
class _TranslationsTagsLocalNewsDiseaseAlertEn extends TranslationsTagsLocalNewsDiseaseAlertId {
	_TranslationsTagsLocalNewsDiseaseAlertEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Disease alert';
	@override String get desc => 'Communicable disease alerts and public health info.';
}

// Path: tags.localNews.schoolNotice
class _TranslationsTagsLocalNewsSchoolNoticeEn extends TranslationsTagsLocalNewsSchoolNoticeId {
	_TranslationsTagsLocalNewsSchoolNoticeEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'School notice';
	@override String get desc => 'Notices from nearby schools.';
}

// Path: tags.localNews.posyandu
class _TranslationsTagsLocalNewsPosyanduEn extends TranslationsTagsLocalNewsPosyanduId {
	_TranslationsTagsLocalNewsPosyanduEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Posyandu';
	@override String get desc => 'Community health post activities.';
}

// Path: tags.localNews.healthCampaign
class _TranslationsTagsLocalNewsHealthCampaignEn extends TranslationsTagsLocalNewsHealthCampaignId {
	_TranslationsTagsLocalNewsHealthCampaignEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Health campaign';
	@override String get desc => 'Health campaign and public health guidance.';
}

// Path: tags.localNews.trafficControl
class _TranslationsTagsLocalNewsTrafficControlEn extends TranslationsTagsLocalNewsTrafficControlId {
	_TranslationsTagsLocalNewsTrafficControlEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Traffic control';
	@override String get desc => 'Traffic diversions, closures, and control info.';
}

// Path: tags.localNews.publicTransport
class _TranslationsTagsLocalNewsPublicTransportEn extends TranslationsTagsLocalNewsPublicTransportId {
	_TranslationsTagsLocalNewsPublicTransportEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Public transport';
	@override String get desc => 'Bus, train, and public transportation updates.';
}

// Path: tags.localNews.parkingPolicy
class _TranslationsTagsLocalNewsParkingPolicyEn extends TranslationsTagsLocalNewsParkingPolicyId {
	_TranslationsTagsLocalNewsParkingPolicyEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Parking policy';
	@override String get desc => 'Parking information and policy changes.';
}

// Path: tags.localNews.communityEvent
class _TranslationsTagsLocalNewsCommunityEventEn extends TranslationsTagsLocalNewsCommunityEventId {
	_TranslationsTagsLocalNewsCommunityEventEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Community event';
	@override String get desc => 'Local festivals, gatherings, and events.';
}

// Path: tags.localNews.worshipEvent
class _TranslationsTagsLocalNewsWorshipEventEn extends TranslationsTagsLocalNewsWorshipEventId {
	_TranslationsTagsLocalNewsWorshipEventEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Religious event';
	@override String get desc => 'Events at mosques, churches, temples, etc.';
}

// Path: tags.localNews.incidentReport
class _TranslationsTagsLocalNewsIncidentReportEn extends TranslationsTagsLocalNewsIncidentReportId {
	_TranslationsTagsLocalNewsIncidentReportEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get name => 'Incident report';
	@override String get desc => 'Reports of incidents and accidents in the neighborhood.';
}

// Path: categories.post.jalanPerbaikin.search
class _TranslationsCategoriesPostJalanPerbaikinSearchEn extends TranslationsCategoriesPostJalanPerbaikinSearchId {
	_TranslationsCategoriesPostJalanPerbaikinSearchEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get hint => 'Search POMs, tags, users';
}

// Path: realEstate.filter.amenities.kosRoom
class _TranslationsRealEstateFilterAmenitiesKosRoomEn extends TranslationsRealEstateFilterAmenitiesKosRoomId {
	_TranslationsRealEstateFilterAmenitiesKosRoomEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get ac => 'AC';
	@override String get bed => 'Bed';
	@override String get closet => 'Closet';
	@override String get desk => 'Desk';
	@override String get wifi => 'Wifi';
}

// Path: realEstate.filter.amenities.kosPublic
class _TranslationsRealEstateFilterAmenitiesKosPublicEn extends TranslationsRealEstateFilterAmenitiesKosPublicId {
	_TranslationsRealEstateFilterAmenitiesKosPublicEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get kitchen => 'Kitchen';
	@override String get livingRoom => 'Living Room';
	@override String get refrigerator => 'Refrigerator';
	@override String get parkingMotorcycle => 'Motorcycle Parking';
	@override String get parkingCar => 'Car Parking';
}

// Path: realEstate.filter.amenities.apartment
class _TranslationsRealEstateFilterAmenitiesApartmentEn extends TranslationsRealEstateFilterAmenitiesApartmentId {
	_TranslationsRealEstateFilterAmenitiesApartmentEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get pool => 'Swimming Pool';
	@override String get gym => 'Gym';
	@override String get security24h => '24h Security';
	@override String get atmCenter => 'ATM Center';
	@override String get minimarket => 'Minimarket';
	@override String get mallAccess => 'Mall Access';
	@override String get playground => 'Playground';
}

// Path: realEstate.filter.amenities.house
class _TranslationsRealEstateFilterAmenitiesHouseEn extends TranslationsRealEstateFilterAmenitiesHouseId {
	_TranslationsRealEstateFilterAmenitiesHouseEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get carport => 'Carport';
	@override String get garden => 'Garden';
	@override String get pam => 'PAM (Water)';
	@override String get telephone => 'Telephone';
	@override String get waterHeater => 'Water Heater';
}

// Path: realEstate.filter.amenities.commercial
class _TranslationsRealEstateFilterAmenitiesCommercialEn extends TranslationsRealEstateFilterAmenitiesCommercialId {
	_TranslationsRealEstateFilterAmenitiesCommercialEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get parkingArea => 'Parking Area';
	@override String get security24h => '24h Security';
	@override String get telephone => 'Telephone';
	@override String get electricity => 'Electricity';
	@override String get containerAccess => 'Container Access';
}

// Path: realEstate.filter.kos.bathroomTypes
class _TranslationsRealEstateFilterKosBathroomTypesEn extends TranslationsRealEstateFilterKosBathroomTypesId {
	_TranslationsRealEstateFilterKosBathroomTypesEn._(TranslationsEn root) : this._root = root, super.internal(root);

	final TranslationsEn _root; // ignore: unused_field

	// Translations
	@override String get inRoom => 'Inside room';
	@override String get outRoom => 'Outside room';
}

/// The flat map containing all translations for locale <en>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsEn {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'login.title' => 'Log In',
			'login.subtitle' => 'Buy and sell lightly with Bling!',
			'login.emailHint' => 'Email Address',
			'login.passwordHint' => 'Password',
			'login.buttons.login' => 'Log In',
			'login.buttons.google' => 'Continue with Google',
			'login.buttons.apple' => 'Continue with Apple',
			'login.links.findPassword' => 'Forgot password?',
			'login.links.askForAccount' => 'Don’t have an account?',
			'login.links.signUp' => 'Sign up',
			'login.alerts.invalidEmail' => 'Invalid email format.',
			'login.alerts.userNotFound' => 'User not found or wrong password.',
			'login.alerts.wrongPassword' => 'Wrong password.',
			'login.alerts.unknownError' => 'An unknown error occurred. Please try again.',
			'main.appBar.locationNotSet' => 'Location not set',
			'main.appBar.locationError' => 'Location Error',
			'main.appBar.locationLoading' => 'Loading...',
			'main.tabs.newFeed' => 'New Feed',
			'main.tabs.localNews' => 'Local News',
			'main.tabs.marketplace' => 'Preloved',
			'main.tabs.findFriends' => 'Find Friends',
			'main.tabs.clubs' => 'Clubs',
			'main.tabs.jobs' => 'Jobs',
			'main.tabs.localStores' => 'Local Stores',
			'main.tabs.auction' => 'Auctions',
			'main.tabs.pom' => 'POM',
			'main.tabs.lostAndFound' => 'Lost & Found',
			'main.tabs.realEstate' => 'Real Estate',
			'main.bottomNav.home' => 'Home',
			'main.bottomNav.board' => 'Neighborhood',
			'main.bottomNav.search' => 'Search',
			'main.bottomNav.chat' => 'Chat',
			'main.bottomNav.myBling' => 'My Bling',
			'main.errors.loginRequired' => 'Login is required.',
			'main.errors.userNotFound' => 'User not found.',
			'main.errors.unknown' => 'An unknown error occurred.',
			'main.myTown' => 'My Town',
			'main.mapView.showMap' => 'Show map',
			'main.mapView.showList' => 'Show list',
			'main.search.placeholder' => 'Search',
			'main.search.chipPlaceholder' => 'Search neighbors, news, preloved, jobs…',
			'main.search.hint.globalSheet' => 'Search in {}',
			'main.search.hint.localNews' => 'Search news title, content, tags',
			'main.search.hint.jobs' => 'Search jobs, company, \'Help Me\'',
			'main.search.hint.lostAndFound' => 'Search lost or found items',
			'main.search.hint.marketplace' => 'Search products for sale',
			'main.search.hint.localStores' => 'Search local stores, services',
			'main.search.hint.findFriends' => 'Search profile nickname, interests',
			'main.search.hint.clubs' => 'Search clubs, interests, location',
			'main.search.hint.realEstate' => 'Search properties, area, price',
			'main.search.hint.auction' => 'Search auction items, brands',
			'main.search.hint.pom' => 'Search POMs, tags, users',
			'search.resultsTitle' => 'Results for \'{keyword}\'',
			'search.empty.message' => 'No results found for \'{keyword}\'.',
			'search.empty.checkSpelling' => 'Check your spelling or try different keywords.',
			'search.empty.expandToNational' => 'Search Nationally',
			'search.prompt' => 'Type a keyword',
			'search.sheet.localNews' => 'Search Local News',
			'search.sheet.localNewsDesc' => 'Search by title, content, tags',
			'search.sheet.jobs' => 'Search Jobs',
			'search.sheet.jobsDesc' => 'Search by role, company, tags',
			'search.sheet.lostAndFound' => 'Search Lost & Found',
			'search.sheet.lostAndFoundDesc' => 'Search by item name, place',
			'search.sheet.marketplace' => 'Search Preloved',
			'search.sheet.marketplaceDesc' => 'Search by item name, category, tags',
			'search.sheet.localStores' => 'Search Local Stores',
			'search.sheet.localStoresDesc' => 'Search by store name, business type, keywords',
			'search.sheet.clubs' => 'Search Clubs',
			'search.sheet.clubsDesc' => 'Search by club name, interests',
			'search.sheet.findFriends' => 'Search Find Friends',
			'search.sheet.findFriendsDesc' => 'Search by nickname, interests',
			'search.sheet.realEstate' => 'Search Real Estate',
			'search.sheet.realEstateDesc' => 'Search by listing title, area, tags',
			'search.sheet.auction' => 'Search Auctions',
			'search.sheet.auctionDesc' => 'Search by item name, tags',
			'search.sheet.pom' => 'Search POM',
			'search.sheet.pomDesc' => 'Search by title, hashtags',
			'search.sheet.comingSoon' => 'Coming soon',
			'search.results' => 'results',
			'drawer.editProfile' => 'Edit Profile',
			'drawer.bookmarks' => 'Bookmarks',
			'drawer.uploadSampleData' => 'Upload Sample Data',
			'drawer.logout' => 'Log Out',
			'drawer.trustDashboard.title' => 'My Trust Verification Status',
			'drawer.trustDashboard.kelurahanAuth' => 'Neighborhood Verification (Kelurahan)',
			'drawer.trustDashboard.rtRwAuth' => 'Detailed Address Verification (RT/RW)',
			'drawer.trustDashboard.phoneAuth' => 'Phone Verification',
			'drawer.trustDashboard.profileComplete' => 'Profile Complete',
			'drawer.trustDashboard.feedThanks' => 'Feed Thanks',
			'drawer.trustDashboard.marketThanks' => 'Market Thanks',
			'drawer.trustDashboard.reports' => 'Reports',
			'drawer.trustDashboard.breakdownButton' => 'Details',
			'drawer.trustDashboard.breakdownModalTitle' => 'Trust Score Breakdown',
			'drawer.trustDashboard.breakdownClose' => 'OK',
			'drawer.trustDashboard.breakdown.kelurahanAuth' => '+50',
			'drawer.trustDashboard.breakdown.rtRwAuth' => '+50',
			'drawer.trustDashboard.breakdown.phoneAuth' => '+100',
			'drawer.trustDashboard.breakdown.profileComplete' => '+50',
			'drawer.trustDashboard.breakdown.feedThanks' => '+10 per',
			'drawer.trustDashboard.breakdown.marketThanks' => '+20 per',
			'drawer.trustDashboard.breakdown.reports' => '-50 per',
			'drawer.runDataFix' => 'Run Data Fix',
			'marketplace.error' => 'An error occurred: {error}',
			'marketplace.empty' => 'No products yet.\nTap the + button to add your first one!',
			'marketplace.registration.title' => 'New Post',
			'marketplace.registration.done' => 'Save',
			'marketplace.registration.titleHint' => 'Item Name',
			'marketplace.registration.priceHint' => 'Price (Rp)',
			'marketplace.registration.negotiable' => 'Allow Offers',
			'marketplace.registration.addressHint' => 'Neighborhood',
			'marketplace.registration.addressDetailHint' => 'Meeting Place',
			'marketplace.registration.descriptionHint' => 'Detailed Description',
			'marketplace.registration.success' => 'Product registered successfully!',
			'marketplace.registration.tagsHint' => 'Add tags (press space to confirm)',
			'marketplace.registration.fail' => 'fail',
			'marketplace.edit.title' => 'Edit Post',
			'marketplace.edit.done' => 'Update Done',
			'marketplace.edit.titleHint' => 'Edit Item Name',
			'marketplace.edit.addressHint' => 'Edit Location',
			'marketplace.edit.priceHint' => 'Edit Price (Rp)',
			'marketplace.edit.negotiable' => 'Edit Negotiable',
			'marketplace.edit.descriptionHint' => 'Edit Description',
			'marketplace.edit.tagsHint' => 'Add tags (press space to confirm)',
			'marketplace.edit.success' => 'Product registered successfully!',
			'marketplace.edit.fail' => 'Failed to update product: {error}',
			'marketplace.edit.resetLocation' => 'Reset location',
			'marketplace.edit.save' => 'Save changes',
			'marketplace.detail.makeOffer' => 'Make an offer',
			'marketplace.detail.fixedPrice' => 'Fixed price',
			'marketplace.detail.description' => 'Product Description',
			'marketplace.detail.sellerInfo' => 'Seller Info',
			'marketplace.detail.chat' => 'Chat',
			'marketplace.detail.favorite' => 'Favorite',
			'marketplace.detail.unfavorite' => 'Unfavorite',
			'marketplace.detail.share' => 'Share',
			'marketplace.detail.edit' => 'Edit',
			'marketplace.detail.delete' => 'Delete',
			'marketplace.detail.category' => 'Category',
			'marketplace.detail.categoryError' => 'Category: -',
			'marketplace.detail.categoryNone' => 'No category',
			'marketplace.detail.views' => 'Views',
			'marketplace.detail.likes' => 'Likes',
			'marketplace.detail.chats' => 'Chats',
			'marketplace.detail.noSeller' => 'Seller info unavailable',
			'marketplace.detail.noLocation' => 'Location info unavailable',
			'marketplace.detail.seller' => 'Seller',
			'marketplace.detail.dealLocation' => 'Deal location',
			'marketplace.dialog.deleteTitle' => 'Delete Post',
			'marketplace.dialog.deleteContent' => 'Are you sure you want to delete this post? This action cannot be undone.',
			'marketplace.dialog.cancel' => 'Cancel',
			'marketplace.dialog.deleteConfirm' => 'Delete',
			'marketplace.dialog.deleteSuccess' => 'Post deleted successfully.',
			'marketplace.dialog.close' => 'close',
			'marketplace.errors.deleteError' => 'Failed to delete post: {error}',
			'marketplace.errors.requiredField' => 'This field is required.',
			'marketplace.errors.noPhoto' => 'Please add at least one photo.',
			'marketplace.errors.noCategory' => 'Please select a category.',
			'marketplace.errors.loginRequired' => 'Login is required.',
			'marketplace.errors.userNotFound' => 'User information could not be found.',
			'marketplace.condition.label' => 'Condition',
			'marketplace.condition.kNew' => 'New',
			'marketplace.condition.used' => 'Used',
			'marketplace.reservation.title' => '10% deposit payment',
			'marketplace.reservation.content' => 'To reserve an AI-verified product you must prepay a 10% deposit of {amount}. If the deal is cancelled after on-site verification, the deposit will be refunded.',
			'marketplace.reservation.confirm' => 'Pay & Reserve',
			'marketplace.reservation.button' => 'Reserve with AI Assurance',
			'marketplace.reservation.success' => 'Reservation completed. Please arrange a meeting with the seller.',
			'marketplace.status.reserved' => 'Reserved',
			'marketplace.status.sold' => 'Sold',
			'marketplace.ai.cancelConfirm' => 'Cancel AI verification',
			'marketplace.ai.cancelLimit' => 'AI verification can only be canceled once per product. Re-requesting AI verification may incur charges.',
			'marketplace.ai.cancelAckCharge' => 'I understand I may be charged.',
			'marketplace.ai.cancelSuccess' => 'AI verification has been cancelled. The product is now a normal listing.',
			'marketplace.ai.cancelError' => 'Error cancelling AI verification: {0}',
			'marketplace.takeover.button' => 'On-site pickup & verification',
			'marketplace.takeover.title' => 'AI On-site Verification',
			'marketplace.takeover.guide.title' => 'AI on-site similarity verification',
			'marketplace.takeover.guide.subtitle' => 'Confirm that the original AI report matches the actual item. Take 3 or more photos that clearly show the item\'s key features.',
			'marketplace.takeover.photoTitle' => 'Take on-site photos',
			'marketplace.takeover.buttonVerify' => 'Start AI similarity verification',
			'marketplace.takeover.errors.noPhoto' => 'At least 1 on-site photo is required for verification.',
			'marketplace.takeover.dialog.matchTitle' => 'AI verification success',
			'marketplace.takeover.dialog.noMatchTitle' => 'AI verification failed',
			'marketplace.takeover.dialog.finalize' => 'Confirm final takeover',
			'marketplace.takeover.dialog.cancelDeal' => 'Cancel deal (request refund)',
			'marketplace.takeover.success.finalized' => 'Deal completed successfully.',
			'marketplace.takeover.success.cancelled' => 'Deal cancelled. Deposit will be refunded.',
			'marketplace.aiBadge' => 'AI verified',
			'marketplace.setLocationPrompt' => 'Set your neighborhood first to see preloved items!',
			'aiFlow.common.error' => 'An error occurred: {error}',
			'aiFlow.common.addPhoto' => 'Add Photo',
			'aiFlow.common.skip' => 'Skip',
			'aiFlow.common.addedPhoto' => 'Photo added: {}',
			'aiFlow.common.skipped' => 'Skipped',
			'aiFlow.cta.title' => '🤖 Boost trust with AI verification (optional)',
			'aiFlow.cta.subtitle' => 'Earn an AI verification badge to increase buyer trust and sell faster. Fill in all product info before starting.',
			'aiFlow.cta.startButton' => 'Start AI verification',
			'aiFlow.cta.missingRequiredFields' => 'Please enter item name, category, and at least one image.',
			'aiFlow.categorySelection.title' => 'AI Verification: Select Category',
			'aiFlow.categorySelection.error' => 'Failed to load categories.',
			'aiFlow.categorySelection.noCategories' => 'No categories available for verification.',
			'aiFlow.galleryUpload.title' => 'AI Verification: Select Photos',
			'aiFlow.galleryUpload.guide' => 'Please upload at least {count} photos for verification.',
			'aiFlow.galleryUpload.minPhotoError' => 'You must select at least {count} photos.',
			'aiFlow.galleryUpload.nextButton' => 'Request AI Analysis',
			'aiFlow.prediction.title' => 'AI Analysis Result',
			'aiFlow.prediction.guide' => 'This is the item name predicted by AI.',
			'aiFlow.prediction.editLabel' => 'Edit Item Name',
			'aiFlow.prediction.editButton' => 'Edit Manually',
			'aiFlow.prediction.saveButton' => 'Save Changes',
			'aiFlow.prediction.noName' => 'No Item Name',
			'aiFlow.prediction.error' => 'Couldn’t recognize the item. Please try again.',
			'aiFlow.prediction.authError' => 'Missing user auth info. Cannot start analysis.',
			'aiFlow.prediction.question' => 'Is this the right item?',
			'aiFlow.prediction.confirmButton' => 'Yes, it is',
			'aiFlow.prediction.rejectButton' => 'No, go back',
			'aiFlow.prediction.analysisError' => 'An error occurred during analysis.',
			'aiFlow.prediction.retryButton' => 'Try Again',
			'aiFlow.prediction.backButton' => 'Back',
			'aiFlow.guidedCamera.title' => 'AI guidance: missing evidence',
			'aiFlow.guidedCamera.guide' => 'To improve trust, please add suggested photos for the items below.',
			'aiFlow.guidedCamera.locationMismatchError' => 'The photo’s location doesn’t match your current location. Please shoot at the same place.',
			'aiFlow.guidedCamera.locationPermissionError' => 'Location permission denied. Please enable it in settings.',
			'aiFlow.guidedCamera.noLocationDataError' => 'No location data found in the photo. Please enable location tags in your camera settings.',
			'aiFlow.guidedCamera.nextButton' => 'Generate final report',
			'aiFlow.finalReport.title' => 'AI Verification Report',
			'aiFlow.finalReport.guide' => 'AI generated a draft listing. Edit the content and finish registration.',
			'aiFlow.finalReport.loading' => 'AI is generating the final report...',
			'aiFlow.finalReport.error' => 'Failed to generate the report.',
			'aiFlow.finalReport.success' => 'Final report generated successfully.',
			'aiFlow.finalReport.submitButton' => 'Register for Sale',
			'aiFlow.finalReport.suggestedPrice' => 'AI suggested price ({})',
			'aiFlow.finalReport.summary' => 'Verification summary',
			'aiFlow.finalReport.buyerNotes' => 'Notes for buyer (AI)',
			'aiFlow.finalReport.keySpecs' => 'Key specs',
			'aiFlow.finalReport.condition' => 'Condition check',
			'aiFlow.finalReport.includedItems' => 'Included items (comma-separated)',
			'aiFlow.finalReport.finalDescription' => 'Final description',
			'aiFlow.finalReport.applySuggestions' => 'Apply suggestions to description',
			'aiFlow.finalReport.includedItemsLabel' => 'Included items',
			'aiFlow.finalReport.buyerNotesLabel' => 'Buyer notes',
			'aiFlow.finalReport.skippedItems' => 'Skipped evidence items',
			'aiFlow.finalReport.fail' => 'Failed to generate final report: {error}',
			'aiFlow.evidence.allShotsRequired' => 'All suggested shots are required.',
			'aiFlow.evidence.title' => 'Evidence photos',
			'aiFlow.evidence.submitButton' => 'Submit evidence',
			'aiFlow.error.reportGeneration' => 'Failed to generate AI report: {error}',
			'registrationFlow.title' => 'Choose Item Type to Sell',
			'registrationFlow.newItemTitle' => 'Register New and Used Items',
			'registrationFlow.newItemDesc' => 'Quickly register unused items and general used items.',
			'registrationFlow.usedItemTitle' => 'Used Items (AI Verification)',
			'registrationFlow.usedItemDesc' => 'AI analyzes your item to build trust and help you sell.',
			'myBling.title' => 'My Bling',
			'myBling.editProfile' => 'Edit Profile',
			'myBling.settings' => 'Settings',
			'myBling.posts' => 'Posts',
			'myBling.followers' => 'Followers',
			'myBling.neighbors' => 'Neighbors',
			'myBling.friends' => 'Friends',
			'myBling.stats.posts' => 'Posts',
			'myBling.stats.followers' => 'Followers',
			'myBling.stats.neighbors' => 'Neighbors',
			'myBling.stats.friends' => 'Friends',
			'myBling.tabs.posts' => 'My Posts',
			'myBling.tabs.products' => 'My Products',
			'myBling.tabs.bookmarks' => 'Bookmarks',
			'myBling.tabs.friends' => 'Friends',
			'myBling.friendRequests' => 'Received Friend Requests',
			'myBling.sentFriendRequests' => 'Sent Requests',
			'profileView.title' => 'Profile',
			'profileView.tabs.posts' => 'Posts',
			'profileView.tabs.interests' => 'Interests',
			'profileView.noPosts' => 'No posts yet.',
			'profileView.noInterests' => 'No interests set.',
			'settings.title' => 'Settings',
			'settings.accountPrivacy' => 'Account & Privacy',
			'settings.notifications.loadError' => 'Failed to load notification settings.',
			'settings.notifications.saveSuccess' => 'Notification settings saved.',
			'settings.notifications.saveError' => 'Failed to save notification settings.',
			'settings.notifications.scopeTitle' => 'Notification range',
			'settings.notifications.scopeDescription' => 'Choose how wide your notifications should be (only my neighborhood, nearby areas, etc.).',
			'settings.notifications.scopeLabel' => 'Notification scope',
			'settings.notifications.tagsTitle' => 'Notification topics',
			'settings.notifications.tagsDescription' => 'Choose which topics you want to receive notifications about (news, jobs, marketplace, etc.).',
			'settings.appInfo' => 'App Info',
			'friendRequests.title' => 'Received Friend Requests',
			'friendRequests.noRequests' => 'No friend requests received.',
			'friendRequests.acceptSuccess' => 'Friend request accepted.',
			'friendRequests.rejectSuccess' => 'Friend request rejected.',
			'friendRequests.error' => 'An error occurred: {error}',
			'friendRequests.tooltip.accept' => 'Accept',
			'friendRequests.tooltip.reject' => 'Reject',
			'friendRequests.defaultChatMessage' => 'You’re now friends! Start a conversation.',
			'sentFriendRequests.title' => 'Sent Friend Requests',
			'sentFriendRequests.noRequests' => 'No friend requests sent.',
			'sentFriendRequests.statusLabel' => 'Status: {status}',
			'sentFriendRequests.status.pending' => 'Pending',
			'sentFriendRequests.status.accepted' => 'Accepted',
			'sentFriendRequests.status.rejected' => 'Rejected',
			'blockedUsers.title' => 'Blocked Users',
			'blockedUsers.noBlockedUsers' => 'You haven’t blocked anyone.',
			'blockedUsers.unblock' => 'Unblock',
			'blockedUsers.unblockDialog.title' => 'Unblock {nickname}?',
			'blockedUsers.unblockDialog.content' => 'After unblocking, this user may appear in your Find Friends list again.',
			'blockedUsers.unblockSuccess' => 'Unblocked {nickname}.',
			'blockedUsers.unblockFailure' => 'Failed to unblock: {error}',
			'blockedUsers.unknownUser' => 'Unknown user',
			'blockedUsers.empty' => 'No blocked users.',
			'rejectedUsers.title' => 'Manage Rejected Users',
			'rejectedUsers.noRejectedUsers' => 'No friend requests you rejected.',
			'rejectedUsers.unreject' => 'Undo Reject',
			'rejectedUsers.unrejectDialog.title' => 'Undo reject for {nickname}?',
			'rejectedUsers.unrejectDialog.content' => 'If undone, you may appear again in their Find Friends list.',
			'rejectedUsers.unrejectSuccess' => 'Undo reject for {nickname} completed.',
			'rejectedUsers.unrejectFailure' => 'Failed to undo reject: {error}',
			'prompt.title' => 'Welcome to Bling!',
			'prompt.subtitle' => 'To see nearby news and items, please set your neighborhood first.',
			'prompt.button' => 'Set My Neighborhood',
			'location.title' => 'Set Neighborhood',
			'location.searchHint' => 'Search by neighborhood, e.g., Serpong',
			'location.gpsButton' => 'Use current location',
			'location.success' => 'Neighborhood set.',
			'location.error' => 'Failed to set neighborhood: {error}',
			'location.empty' => 'Please enter a neighborhood name.',
			'location.permissionDenied' => 'Location permission is required to find your neighborhood.',
			'location.rtLabel' => 'RT',
			'location.rwLabel' => 'RW',
			'location.rtHint' => 'e.g. 003',
			'location.rwHint' => 'e.g. 007',
			'location.rtRequired' => 'Please enter RT.',
			'location.rwRequired' => 'Please enter RW.',
			'location.rtRwInfo' => 'Your RT/RW won’t be public. It’s only used to improve trust and local features.',
			'location.saveThisLocation' => 'Save this location',
			'location.manualSelect' => 'Select manually',
			'location.refreshFromGps' => 'Refresh from GPS',
			'profileEdit.title' => 'Profile Settings',
			'profileEdit.nicknameHint' => 'Nickname',
			'profileEdit.phoneHint' => 'Phone Number',
			'profileEdit.bioHint' => 'Bio',
			'profileEdit.locationTitle' => 'Location',
			'profileEdit.changeLocation' => 'Change',
			'profileEdit.locationNotSet' => 'Not set',
			'profileEdit.interests.title' => 'Interests',
			'profileEdit.interests.hint' => 'Use commas and Enter to add multiple',
			'profileEdit.privacy.title' => 'Privacy Settings',
			'profileEdit.privacy.showLocation' => 'Show my location on the map',
			'profileEdit.privacy.allowRequests' => 'Allow friend requests',
			'profileEdit.saveButton' => 'Save Changes',
			'profileEdit.successMessage' => 'Profile updated successfully.',
			'profileEdit.errors.noUser' => 'No logged-in user.',
			'profileEdit.errors.updateFailed' => 'Failed to update profile: {error}',
			'mainFeed.error' => 'An error occurred: {error}',
			'mainFeed.empty' => 'No new posts.',
			'postCard.locationNotSet' => 'Location not set',
			'postCard.location' => 'Location',
			'postCard.authorNotFound' => 'Author not found',
			'time.now' => 'Just now',
			'time.minutesAgo' => '{minutes} minutes ago',
			'time.hoursAgo' => '{hours} hours ago',
			'time.daysAgo' => '{days} days ago',
			'time.dateFormat' => 'yy.MM.dd',
			'time.dateFormatLong' => 'MMM d',
			'productCard.currency' => '\$',
			'localNewsFeed.setLocationPrompt' => 'Set your neighborhood to see local stories!',
			'localNewsFeed.allCategory' => 'All',
			'localNewsFeed.empty' => 'No posts to show.',
			'localNewsFeed.error' => 'An error occurred: {error}',
			'categories.post.jalanPerbaikin.search.hint' => 'Search POMs, tags, users',
			'categories.post.jalanPerbaikin.name' => 'Road Repair',
			'categories.post.dailyLife.name' => 'Daily/Questions',
			'categories.post.dailyLife.description' => 'Share daily life or ask questions.',
			'categories.post.helpShare.name' => 'Help/Share',
			'categories.post.helpShare.description' => 'Need help or have something to share?',
			'categories.post.incidentReport.name' => 'Incidents',
			'categories.post.incidentReport.description' => 'Share incident news in your neighborhood.',
			'categories.post.localNews.name' => 'Local News',
			'categories.post.localNews.description' => 'Share news and info about our neighborhood.',
			'categories.post.november.name' => 'November',
			'categories.post.rain.name' => 'Rain',
			'categories.post.dailyQuestion.name' => 'Have a Question',
			'categories.post.dailyQuestion.description' => 'Ask your neighbors anything.',
			'categories.post.storePromo.name' => 'Store Promo',
			'categories.post.storePromo.description' => 'Promote discounts or events at your store.',
			'categories.post.etc.name' => 'Etc.',
			'categories.post.etc.description' => 'Share other stories freely.',
			'categories.auction.all' => 'All',
			'categories.auction.collectibles.name' => 'Collectibles',
			'categories.auction.collectibles.description' => 'Toys, cards, figures, and more.',
			'categories.auction.digital.name' => 'Digital',
			'categories.auction.digital.description' => 'Digital goods and assets.',
			'categories.auction.fashion.name' => 'Fashion',
			'categories.auction.fashion.description' => 'Clothing, accessories, and beauty.',
			'categories.auction.vintage.name' => 'Vintage',
			'categories.auction.vintage.description' => 'Retro and classic items.',
			'categories.auction.artCraft.name' => 'Art & Craft',
			'categories.auction.artCraft.description' => 'Artwork and handmade crafts.',
			'categories.auction.etc.name' => 'Other',
			'categories.auction.etc.description' => 'Other auction items.',
			'localNewsCreate.appBarTitle' => 'Create New Post',
			'localNewsCreate.title' => 'Create New Post',
			'localNewsCreate.form.categoryLabel' => 'Category',
			'localNewsCreate.form.titleLabel' => 'Title',
			'localNewsCreate.form.contentLabel' => 'Enter content',
			'localNewsCreate.form.tagsLabel' => 'Tags',
			'localNewsCreate.form.tagsHint' => 'Add tags (press space to confirm)',
			'localNewsCreate.form.recommendedTags' => 'Recommended tags',
			'localNewsCreate.labels.title' => 'Title',
			'localNewsCreate.labels.body' => 'Content',
			'localNewsCreate.labels.tags' => 'Tags',
			'localNewsCreate.labels.guidedTitle' => 'Additional Info (Optional)',
			'localNewsCreate.labels.eventLocation' => 'Event/Incident Location',
			'localNewsCreate.hints.body' => 'Share your neighborhood news or ask questions...',
			'localNewsCreate.hints.tagSelection' => '(Select 1-3 tags)',
			'localNewsCreate.hints.eventLocation' => 'e.g., Jl. Sudirman 123',
			'localNewsCreate.validation.bodyRequired' => 'Please enter the content.',
			'localNewsCreate.validation.tagRequired' => 'Please select at least one tag.',
			'localNewsCreate.validation.tagMaxLimit' => 'You can select up to 3 tags.',
			'localNewsCreate.validation.imageMaxLimit' => 'You can attach up to 5 images.',
			'localNewsCreate.validation.titleRequired' => 'Please enter a title.',
			'localNewsCreate.buttons.addImage' => 'Add Image',
			'localNewsCreate.buttons.submit' => 'Submit',
			'localNewsCreate.alerts.contentRequired' => 'Please enter content.',
			'localNewsCreate.alerts.categoryRequired' => 'Please select a category.',
			'localNewsCreate.alerts.success' => 'Post created successfully.',
			'localNewsCreate.alerts.failure' => 'Upload failed: {error}',
			'localNewsCreate.alerts.loginRequired' => 'Login is required to create a post.',
			'localNewsCreate.alerts.userNotFound' => 'User information could not be found.',
			'localNewsCreate.success' => 'Post created successfully.',
			'localNewsCreate.fail' => 'Failed to create post: {error}',
			'localNewsDetail.appBarTitle' => 'Post',
			'localNewsDetail.menu.edit' => 'Edit',
			'localNewsDetail.menu.report' => 'Report',
			'localNewsDetail.menu.share' => 'Share',
			'localNewsDetail.stats.views' => 'Views',
			'localNewsDetail.stats.comments' => 'Comments',
			'localNewsDetail.stats.likes' => 'Likes',
			'localNewsDetail.stats.thanks' => 'Thanks',
			'localNewsDetail.buttons.comment' => 'Add a comment',
			'localNewsDetail.confirmDelete' => 'Are you sure you want to delete this post?',
			'localNewsDetail.deleted' => 'Post deleted.',
			'localNewsEdit.appBarTitle' => 'Edit Post',
			'localNewsEdit.buttons.submit' => 'Update',
			'localNewsEdit.alerts.success' => 'Post updated successfully.',
			'localNewsEdit.alerts.failure' => 'Failed to update: {error}',
			'commentInputField.secretCommentLabel' => 'Secret',
			'commentInputField.hintText' => 'Enter a comment...',
			'commentInputField.replyHintText' => 'Replying to {nickname}...',
			'commentInputField.button.send' => 'Send',
			'commentListView.empty' => 'No comments yet. Be the first!',
			'commentListView.reply' => 'Reply',
			'commentListView.delete' => 'Delete',
			'commentListView.deleted' => '[This comment has been deleted]',
			'commentListView.secret' => 'This is a secret comment only visible to the author and post owner.',
			'common.cancel' => 'Cancel',
			'common.confirm' => 'Confirm',
			'common.delete' => 'Delete',
			'common.done' => 'Done',
			'common.clear' => 'Clear',
			'common.report' => 'Report',
			'common.moreOptions' => 'More options',
			'common.viewAll' => 'View all',
			'common.kNew' => 'New',
			'common.updated' => 'Updated',
			'common.comments' => 'Comments',
			'common.sponsored' => 'Sponsored',
			'common.filter' => 'Filter',
			'common.reset' => 'Reset',
			'common.apply' => 'Apply',
			'common.verified' => 'Verified',
			'common.bookmark' => 'Bookmark',
			'common.sort.kDefault' => 'Default',
			'common.sort.distance' => 'Distance',
			'common.sort.popular' => 'Popular',
			'common.error' => 'An error occurred.',
			'common.shareError' => 'Failed to share. Please try again.',
			'common.edit' => 'Edit',
			'common.submit' => 'Submit',
			'common.loginRequired' => 'Login is required.',
			'common.unknownUser' => 'Unknown user.',
			'reportDialog.title' => 'Report Post',
			'reportDialog.titleComment' => 'Report Comment',
			'reportDialog.titleReply' => 'Report Reply',
			'reportDialog.cannotReportSelfComment' => 'You cannot report your own comment.',
			'reportDialog.cannotReportSelfReply' => 'You cannot report your own reply.',
			'reportDialog.success' => 'Report submitted. Thank you.',
			'reportDialog.fail' => 'Failed to submit report: {error}',
			'reportDialog.cannotReportSelf' => 'You cannot report your own post.',
			'replyDelete.fail' => 'Failed to delete reply: {error}',
			'reportReasons.spam' => 'Spam or misleading',
			'reportReasons.abuse' => 'Harassment or hateful speech',
			'reportReasons.inappropriate' => 'Sexually inappropriate',
			'reportReasons.illegal' => 'Illegal content',
			'reportReasons.etc' => 'Other',
			'deleteConfirm.title' => 'Delete Comment',
			'deleteConfirm.content' => 'Are you sure you want to delete this comment?',
			'deleteConfirm.failure' => 'Failed to delete comment: {error}',
			'replyInputField.hintText' => 'Enter a reply',
			'replyInputField.button.send' => 'Send',
			'replyInputField.failure' => 'Failed to add reply: {error}',
			'chatList.appBarTitle' => 'Chats',
			'chatList.empty' => 'No conversations yet.',
			'chatRoom.startConversation' => 'Start a conversation',
			'chatRoom.icebreaker1' => 'Hi there! 👋',
			'chatRoom.icebreaker2' => 'What do you usually do on weekends?',
			'chatRoom.icebreaker3' => 'Any favorite spots nearby?',
			'chatRoom.mediaBlocked' => 'For safety, media sending is restricted for 24 hours.',
			'chatRoom.imageMessage' => 'Image',
			'chatRoom.linkHidden' => 'Protection mode: link hidden',
			'chatRoom.contactHidden' => 'Protection mode: contact hidden',
			'jobs.setLocationPrompt' => 'Set your location to see job posts!',
			'jobs.screen.empty' => 'No job postings found in this area.',
			'jobs.screen.createTooltip' => 'Post a Job',
			_ => null,
		} ?? switch (path) {
			'jobs.tabs.all' => 'All',
			'jobs.tabs.quickGig' => 'Quick Gigs',
			'jobs.tabs.regular' => 'Part-time/Full-time',
			'jobs.selectType.title' => 'Select Job Type',
			'jobs.selectType.regularTitle' => 'Part-time / Full-time Job',
			'jobs.selectType.regularDesc' => 'Regular work like cafe, restaurant, office',
			'jobs.selectType.quickGigTitle' => 'Quick Gig / Simple Help',
			'jobs.selectType.quickGigDesc' => 'Motorcycle delivery, moving, cleaning, etc.',
			'jobs.form.title' => 'Post a Job',
			'jobs.form.titleHint' => 'Job title',
			'jobs.form.descriptionPositionHint' => 'Describe the position',
			'jobs.form.categoryHint' => 'Category',
			'jobs.form.categorySelectHint' => 'Select a category',
			'jobs.form.categoryValidator' => 'Please select a category.',
			'jobs.form.locationHint' => 'Location',
			'jobs.form.submit' => 'Post Job',
			'jobs.form.titleLabel' => 'Title',
			'jobs.form.titleValidator' => 'Please enter a title.',
			'jobs.form.titleRegular' => 'Post Part-time/Full-time Job',
			'jobs.form.titleQuickGig' => 'Post Quick Gig',
			'jobs.form.validationError' => 'Please fill in all required fields.',
			'jobs.form.saveSuccess' => 'Job posting saved successfully.',
			'jobs.form.saveError' => 'Failed to save job posting: {error}',
			'jobs.form.categoryLabel' => 'Category',
			'jobs.form.titleHintQuickGig' => 'e.g., Motorcycle document delivery (ASAP)',
			'jobs.form.salaryLabel' => 'Salary (IDR)',
			'jobs.form.salaryHint' => 'Enter the salary amount',
			'jobs.form.salaryValidator' => 'Please enter a valid salary.',
			'jobs.form.totalPayLabel' => 'Total Pay (IDR)',
			'jobs.form.totalPayHint' => 'Enter the total amount offered',
			'jobs.form.totalPayValidator' => 'Please enter a valid amount.',
			'jobs.form.negotiable' => 'Negotiable',
			'jobs.form.workPeriodLabel' => 'Work Period',
			'jobs.form.workPeriodHint' => 'Select work period',
			'jobs.form.locationLabel' => 'Location / Workplace',
			'jobs.form.locationValidator' => 'Please enter a location.',
			'jobs.form.imageLabel' => 'Images (Optional, max 10)',
			'jobs.form.descriptionHintQuickGig' => 'Please provide details (e.g., departure, destination, specific request).',
			'jobs.form.salaryInfoTitle' => 'Salary Info',
			'jobs.form.salaryTypeHint' => 'Type',
			'jobs.form.salaryAmountLabel' => 'Amount (IDR)',
			'jobs.form.salaryNegotiable' => 'Salary negotiable',
			'jobs.form.workInfoTitle' => 'Work Conditions',
			'jobs.form.workPeriodTitle' => 'Work Period',
			'jobs.form.workHoursLabel' => 'Days/Hours',
			'jobs.form.workHoursHint' => 'e.g. Mon-Fri, 09:00-18:00',
			'jobs.form.imageSectionTitle' => 'Attach Photos (optional, max 5)',
			'jobs.form.descriptionLabel' => 'Description',
			'jobs.form.descriptionHint' => 'e.g. Part-time, 3 days a week, 5-10pm. Salary negotiable.',
			'jobs.form.descriptionValidator' => 'Please enter a description.',
			'jobs.form.submitFail' => 'Failed to create job post: {error}',
			'jobs.form.updateSuccess' => 'Job updated successfully.',
			'jobs.form.editTitle' => 'Edit Job',
			'jobs.form.update' => 'Update',
			'jobs.form.submitSuccess' => 'Job post created.',
			'jobs.categories.restaurant' => 'Restaurant',
			'jobs.categories.cafe' => 'Cafe',
			'jobs.categories.retail' => 'Retail',
			'jobs.categories.delivery' => 'Delivery',
			'jobs.categories.etc' => 'Etc',
			'jobs.categories.service' => 'Service',
			'jobs.categories.salesMarketing' => 'Sales/Marketing',
			'jobs.categories.deliveryLogistics' => 'Delivery/Logistics',
			'jobs.categories.it' => 'IT/Tech',
			'jobs.categories.design' => 'Design',
			'jobs.categories.education' => 'Education',
			'jobs.categories.quickGigDelivery' => 'Motorcycle Delivery',
			'jobs.categories.quickGigTransport' => 'Motorcycle Ride (Ojek)',
			'jobs.categories.quickGigMoving' => 'Moving Help',
			'jobs.categories.quickGigCleaning' => 'Cleaning/Housework',
			'jobs.categories.quickGigQueuing' => 'Wait in Line',
			'jobs.categories.quickGigEtc' => 'Other Errands',
			'jobs.salaryTypes.hourly' => 'Hourly',
			'jobs.salaryTypes.daily' => 'Daily',
			'jobs.salaryTypes.weekly' => 'Weekly',
			'jobs.salaryTypes.monthly' => 'Monthly',
			'jobs.salaryTypes.total' => 'Total Pay',
			'jobs.salaryTypes.perCase' => 'Per case',
			'jobs.salaryTypes.etc' => 'Etc',
			'jobs.salaryTypes.yearly' => 'Yearly',
			'jobs.workPeriods.shortTerm' => 'Short term',
			'jobs.workPeriods.midTerm' => 'Mid term',
			'jobs.workPeriods.longTerm' => 'Long term',
			'jobs.workPeriods.oneTime' => 'One-time',
			'jobs.workPeriods.k1Week' => '1 Week',
			'jobs.workPeriods.k1Month' => '1 Month',
			'jobs.workPeriods.k3Months' => '3 Months',
			'jobs.workPeriods.k6MonthsPlus' => '6 Months+',
			'jobs.workPeriods.negotiable' => 'Negotiable',
			'jobs.workPeriods.etc' => 'Etc',
			'jobs.detail.infoTitle' => 'Details',
			'jobs.detail.apply' => 'Apply',
			'jobs.detail.noAuthor' => 'No author info',
			'jobs.detail.chatError' => 'Could not start chat: {error}',
			'jobs.card.noLocation' => 'No location info',
			'jobs.card.minutesAgo' => 'minutes ago',
			'findFriend.title' => 'Find Friends',
			'findFriend.tabs.friends' => 'Friends',
			'findFriend.tabs.groups' => 'Groups',
			'findFriend.tabs.clubs' => 'Clubs',
			'findFriend.editTitle' => 'Edit FindFriend Profile',
			'findFriend.editProfileTitle' => 'Edit Profile',
			'findFriend.save' => 'Save',
			'findFriend.profileImagesLabel' => 'Profile Images (Max 6)',
			'findFriend.bioLabel' => 'Bio',
			'findFriend.bioHint' => 'Introduce yourself to others.',
			'findFriend.bioValidator' => 'Please enter your bio.',
			'findFriend.ageLabel' => 'Age',
			'findFriend.ageHint' => 'Enter your age.',
			'findFriend.genderLabel' => 'Gender',
			'findFriend.genderMale' => 'Male',
			'findFriend.genderFemale' => 'Female',
			'findFriend.genderHint' => 'Select your gender',
			'findFriend.interestsLabel' => 'Interests',
			'findFriend.preferredAgeLabel' => 'Preferred Friend Age',
			'findFriend.preferredAgeUnit' => 'yrs',
			'findFriend.preferredGenderLabel' => 'Preferred Friend Gender',
			'findFriend.preferredGenderAll' => 'All',
			'findFriend.showProfileLabel' => 'Show my profile in the list',
			'findFriend.showProfileSubtitle' => 'If off, others cannot find you.',
			'findFriend.saveSuccess' => 'Profile saved!',
			'findFriend.saveFailed' => 'Failed to save profile:',
			'findFriend.loginRequired' => 'Login is required.',
			'findFriend.noFriendsFound' => 'No nearby friends found.',
			'findFriend.promptTitle' => 'To meet new friends,\nplease create your profile first!',
			'findFriend.promptButton' => 'Create My Profile',
			'findFriend.chatLimitReached' => 'You have reached your daily limit ({limit}) for starting new chats.',
			'findFriend.chatChecking' => 'Checking...',
			'findFriend.empty' => 'No profiles to show yet.',
			'interests.title' => 'Interests',
			'interests.limitInfo' => 'You can select up to 10.',
			'interests.limitReached' => 'You can select up to 10 interests.',
			'interests.categoryCreative' => '🎨 Creative',
			'interests.categorySports' => '🏃 Sports & Activities',
			'interests.categoryFoodDrink' => '🍸 Food & Drinks',
			'interests.categoryEntertainment' => '🍿 Entertainment',
			'interests.categoryGrowth' => '📚 Self-development',
			'interests.categoryLifestyle' => '🌴 Lifestyle',
			'interests.items.drawing' => 'Drawing',
			'interests.items.instrument' => 'Playing instruments',
			'interests.items.photography' => 'Photography',
			'interests.items.writing' => 'Writing',
			'interests.items.crafting' => 'Crafting',
			'interests.items.gardening' => 'Gardening',
			'interests.items.soccer' => 'Soccer/Futsal',
			'interests.items.hiking' => 'Hiking',
			'interests.items.camping' => 'Camping',
			'interests.items.running' => 'Running/Jogging',
			'interests.items.biking' => 'Cycling',
			'interests.items.golf' => 'Golf',
			'interests.items.workout' => 'Workout/Fitness',
			'interests.items.foodie' => 'Foodie',
			'interests.items.cooking' => 'Cooking',
			'interests.items.baking' => 'Baking',
			'interests.items.coffee' => 'Coffee',
			'interests.items.wine' => 'Wine/Drinks',
			'interests.items.tea' => 'Tea',
			'interests.items.movies' => 'Movies/Drama',
			'interests.items.music' => 'Listening to music',
			'interests.items.concerts' => 'Concerts/Festivals',
			'interests.items.gaming' => 'Gaming',
			'interests.items.reading' => 'Reading',
			'interests.items.investing' => 'Investing',
			'interests.items.language' => 'Language learning',
			'interests.items.coding' => 'Coding',
			'interests.items.travel' => 'Travel',
			'interests.items.pets' => 'Pets',
			'interests.items.volunteering' => 'Volunteering',
			'interests.items.minimalism' => 'Minimalism',
			'friendDetail.request' => 'Send Request',
			'friendDetail.requestSent' => 'Sent',
			'friendDetail.alreadyFriends' => 'Already Friends',
			'friendDetail.requestFailed' => 'Request failed:',
			'friendDetail.chatError' => 'Could not start chat.',
			'friendDetail.startChat' => 'Start Chat',
			'friendDetail.block' => 'Block',
			'friendDetail.report' => 'Report',
			'friendDetail.loginRequired' => 'Login is required.',
			'friendDetail.unblocked' => 'User has been unblocked.',
			'friendDetail.blocked' => 'User has been blocked.',
			'friendDetail.unblock' => 'Unblock',
			'locationFilter.title' => 'Location Filter',
			'locationFilter.provinsi' => 'Provinsi',
			'locationFilter.kabupaten' => 'Kabupaten',
			'locationFilter.kota' => 'Kota',
			'locationFilter.kecamatan' => 'Kecamatan',
			'locationFilter.kelurahan' => 'Kelurahan',
			'locationFilter.apply' => 'Apply Filter',
			'locationFilter.all' => 'All',
			'locationFilter.reset' => 'Reset',
			'clubs.tabs.proposals' => 'Proposals',
			'clubs.tabs.activeClubs' => 'Active Clubs',
			'clubs.tabs.myClubs' => 'My Clubs',
			'clubs.tabs.exploreClubs' => 'Explore Clubs',
			'clubs.sections.active' => 'Official clubs',
			'clubs.sections.proposals' => 'Club proposals',
			'clubs.screen.error' => 'Error: {error}',
			'clubs.screen.empty' => 'No clubs yet.',
			'clubs.postList.empty' => 'No posts yet. Be the first!',
			'clubs.postList.writeTooltip' => 'Write',
			'clubs.memberCard.kickConfirmTitle' => 'Remove {memberName}?',
			'clubs.memberCard.kickConfirmContent' => 'Removed members can no longer participate in club activities.',
			'clubs.memberCard.kick' => 'Remove',
			'clubs.memberCard.kickedSuccess' => 'Removed {memberName}.',
			'clubs.memberCard.kickFail' => 'Failed to remove member: {error}',
			'clubs.postCard.deleteTitle' => 'Delete Post',
			'clubs.postCard.deleteContent' => 'Are you sure you want to delete this post? This action cannot be undone.',
			'clubs.postCard.deleteSuccess' => 'Post deleted.',
			'clubs.postCard.deleteFail' => 'Failed to delete post: {error}',
			'clubs.postCard.withdrawnMember' => 'Member left',
			'clubs.postCard.deleteTooltip' => 'Delete post',
			'clubs.postCard.loadingUser' => 'Loading user info...',
			'clubs.card.membersCount' => '{count} members',
			'clubs.postDetail.commentFail' => 'Failed to add comment: {error}',
			'clubs.postDetail.appBarTitle' => '{title} Board',
			'clubs.postDetail.commentsTitle' => 'Comments',
			'clubs.postDetail.noComments' => 'No comments yet.',
			'clubs.postDetail.commentHint' => 'Write a comment...',
			'clubs.postDetail.unknownUser' => 'Unknown user',
			'clubs.detail.joined' => 'Joined club \'{title}\'!',
			'clubs.detail.pendingApproval' => 'Waiting for owner approval. You can participate after approval.',
			'clubs.detail.joinFail' => 'Failed to request join: {error}',
			'clubs.detail.tabs.info' => 'Info',
			'clubs.detail.tabs.board' => 'Board',
			'clubs.detail.tabs.members' => 'Members',
			'clubs.detail.joinChat' => 'Join chat',
			'clubs.detail.joinClub' => 'Join Club',
			'clubs.detail.owner' => 'Admin',
			'clubs.detail.info.members' => 'Members',
			'clubs.detail.info.location' => 'Location',
			'clubs.detail.location' => 'Location',
			'clubs.detail.leaveConfirmTitle' => 'Leave club',
			'clubs.detail.leaveConfirmContent' => 'Are you sure you want to leave {title}?',
			'clubs.detail.leave' => 'Leave',
			'clubs.detail.leaveSuccess' => 'You have left {title}',
			'clubs.detail.leaveFail' => 'Failed to leave: {error}',
			'clubs.memberList.pendingMembers' => 'Pending Members',
			'clubs.memberList.allMembers' => 'All Members',
			'clubs.createPost.title' => 'New Post',
			'clubs.createPost.submit' => 'Submit',
			'clubs.createPost.success' => 'Post submitted.',
			'clubs.createPost.fail' => 'Failed to submit post: {error}',
			'clubs.createPost.bodyHint' => 'Enter content...',
			'clubs.createClub.selectAtLeastOneInterest' => 'Select at least one interest.',
			'clubs.createClub.success' => 'Club created!',
			'clubs.createClub.fail' => 'Failed to create club: {error}',
			'clubs.createClub.title' => 'Create Club',
			'clubs.createClub.nameLabel' => 'Club Name',
			'clubs.createClub.nameError' => 'Please enter a club name.',
			'clubs.createClub.descriptionLabel' => 'Club Description',
			'clubs.createClub.descriptionError' => 'Please enter a club description.',
			'clubs.createClub.tagsHint' => 'Type a tag and press Space to add',
			'clubs.createClub.maxInterests' => 'You can select up to 3 interests.',
			'clubs.createClub.privateClub' => 'Private Club',
			'clubs.createClub.privateDescription' => 'Invitation only.',
			'clubs.createClub.locationLabel' => 'Location',
			'clubs.editClub.title' => 'Edit Club Info',
			'clubs.editClub.save' => 'Save',
			'clubs.editClub.success' => 'Club info updated.',
			'clubs.editClub.fail' => 'Failed to update club: {error}',
			'clubs.create.title' => 'Create Club',
			'clubs.repository.chatCreated' => 'Club chat room created.',
			'clubs.proposal.createTitle' => 'Propose a Club',
			'clubs.proposal.imageError' => 'Please select a cover image.',
			'clubs.proposal.createSuccess' => 'Your club proposal has been created.',
			'clubs.proposal.createFail' => 'Failed to create proposal: {error}',
			'clubs.proposal.tagsHint' => 'Type a tag and press Space to add',
			'clubs.proposal.targetMembers' => 'Target members',
			'clubs.proposal.targetMembersCount' => 'Total {count} members',
			'clubs.proposal.empty' => 'No proposals yet.',
			'clubs.proposal.memberStatus' => '{current} / {target} members',
			'clubs.proposal.join' => 'Join',
			'clubs.proposal.leave' => 'Leave',
			'clubs.proposal.members' => 'Members',
			'clubs.proposal.noMembers' => 'No members yet.',
			'clubs.proposal.detail.joined' => 'You joined the proposal!',
			'clubs.proposal.detail.left' => 'You left the proposal.',
			'clubs.proposal.detail.loginRequired' => 'Please log in to join.',
			'clubs.proposal.detail.error' => 'An error occurred: {error}',
			'clubs.empty' => 'No clubs to display.',
			'findfriend.form.title' => 'Create Find Friends Profile',
			'auctions.card.currentBid' => 'Current bid',
			'auctions.card.endTime' => 'Time left',
			'auctions.card.ended' => 'Ended',
			'auctions.card.winningBid' => 'Winning bid',
			'auctions.card.winner' => 'Winner',
			'auctions.card.noBidders' => 'No bidders yet',
			'auctions.card.unknownBidder' => 'Unknown bidder',
			'auctions.card.timeLeft' => '{hours}:{minutes}:{seconds} left',
			'auctions.card.timeLeftDays' => '{days} days {hours}:{minutes}:{seconds} left',
			'auctions.errors.fetchFailed' => 'Failed to load auctions: {error}',
			'auctions.errors.notFound' => 'Auction not found.',
			'auctions.errors.lowerBid' => 'You must enter a higher bid than the current one.',
			'auctions.errors.alreadyEnded' => 'This auction has already ended.',
			'auctions.empty' => 'No auctions.',
			'auctions.filter.tooltip' => 'Filter',
			'auctions.filter.clearTooltip' => 'Clear filter',
			'auctions.create.tooltip' => 'Create Auction',
			'auctions.create.title' => 'Create Auction',
			'auctions.create.registrationType' => 'Registration type',
			'auctions.create.type.sale' => 'Sale',
			'auctions.create.type.auction' => 'Auction',
			'auctions.create.success' => 'Auction created.',
			'auctions.create.fail' => 'Failed to create auction: {error}',
			'auctions.create.submitButton' => 'Start Auction',
			'auctions.create.confirmTitle' => 'List as an auction?',
			'auctions.create.confirmContent' => 'Once listed as an auction, you can\'t switch back to a normal sale. A 5% fee will be charged upon a successful bid. Continue?',
			'auctions.create.errors.noPhoto' => 'Please add at least one photo.',
			'auctions.create.form.photoSectionTitle' => 'Upload photos (max 10)',
			'auctions.create.form.title' => 'Title',
			'auctions.create.form.description' => 'Description',
			'auctions.create.form.startPrice' => 'Start price',
			'auctions.create.form.category' => 'Category',
			'auctions.create.form.categoryHint' => 'Select a category',
			'auctions.create.form.tagsHint' => 'Type a tag and press Space to add',
			'auctions.create.form.duration' => 'Duration',
			'auctions.create.form.durationOption' => '{days} days',
			'auctions.create.form.location' => 'Location',
			'auctions.edit.tooltip' => 'Edit auction',
			'auctions.edit.title' => 'Edit Auction',
			'auctions.edit.save' => 'Save',
			'auctions.edit.success' => 'Auction updated.',
			'auctions.edit.fail' => 'Failed to update auction: {error}',
			'auctions.form.titleRequired' => 'Please enter a title.',
			'auctions.form.descriptionRequired' => 'Please enter a description.',
			'auctions.form.startPriceRequired' => 'Please enter a start price.',
			'auctions.form.categoryRequired' => 'Please select a category.',
			'auctions.delete.tooltip' => 'Delete auction',
			'auctions.delete.confirmTitle' => 'Delete auction',
			'auctions.delete.confirmContent' => 'Are you sure you want to delete this auction?',
			'auctions.delete.success' => 'Auction deleted.',
			'auctions.delete.fail' => 'Failed to delete auction: {error}',
			'auctions.detail.currentBid' => 'Current bid: {amount}',
			'auctions.detail.location' => 'Location',
			'auctions.detail.seller' => 'Seller',
			'auctions.detail.qnaTitle' => 'Q&A',
			'auctions.detail.qnaHint' => 'Ask the seller...',
			'auctions.detail.endTime' => 'End time: {time}',
			'auctions.detail.bidsTitle' => 'Bids',
			'auctions.detail.noBids' => 'No bids yet.',
			'auctions.detail.unknownBidder' => 'Unknown bidder',
			'auctions.detail.bidAmountLabel' => 'Enter bid (Rp)',
			'auctions.detail.placeBid' => 'Bid',
			'auctions.detail.bidSuccess' => 'Bid successful!',
			'auctions.detail.bidFail' => 'Failed to bid: {error}',
			'auctions.detail.errors.loginRequired' => 'Login required.',
			'auctions.detail.errors.invalidAmount' => 'Enter a valid bid amount.',
			'localStores.setLocationPrompt' => 'Set your location to see nearby stores.',
			'localStores.empty' => 'No stores yet.',
			'localStores.error' => 'An error occurred: {error}',
			'localStores.create.tooltip' => 'Register my store',
			'localStores.create.title' => 'Register New Store',
			'localStores.create.submit' => 'Register',
			'localStores.create.success' => 'Store registered.',
			'localStores.create.fail' => 'Failed to register store: {error}',
			'localStores.edit.title' => 'Edit Store Info',
			'localStores.edit.save' => 'Save',
			'localStores.edit.success' => 'Store info updated.',
			'localStores.edit.fail' => 'Failed to update store: {error}',
			'localStores.edit.tooltip' => 'Edit store info',
			'localStores.form.nameLabel' => 'Store Name',
			'localStores.form.nameError' => 'Please enter a store name.',
			'localStores.form.descriptionLabel' => 'Store Description',
			'localStores.form.descriptionError' => 'Please enter a store description.',
			'localStores.form.contactLabel' => 'Contact',
			'localStores.form.hoursLabel' => 'Hours',
			'localStores.form.hoursHint' => 'e.g. 09:00 - 18:00',
			'localStores.form.photoLabel' => 'Photos (max {count})',
			'localStores.form.categoryLabel' => 'Category',
			'localStores.form.categoryError' => 'Please select a category.',
			'localStores.form.productsLabel' => 'Representative Products/Services',
			'localStores.form.productsHint' => 'Comma-separated, e.g. Haircut, Coloring, Perm',
			'localStores.form.imageError' => 'Failed to load image. Please try again.',
			'localStores.categories.all' => 'All',
			'localStores.categories.food' => 'Restaurant',
			'localStores.categories.cafe' => 'Cafe',
			'localStores.categories.massage' => 'Massage',
			'localStores.categories.beauty' => 'Beauty',
			'localStores.categories.nail' => 'Nail',
			'localStores.categories.auto' => 'Auto Repair',
			'localStores.categories.kids' => 'Kids',
			'localStores.categories.hospital' => 'Hospital/Clinic',
			'localStores.categories.etc' => 'Others',
			'localStores.detail.description' => 'Store Description',
			'localStores.detail.products' => 'Products/Services',
			'localStores.detail.deleteTitle' => 'Delete Store',
			'localStores.detail.deleteContent' => 'Are you sure you want to delete this store? This action cannot be undone.',
			'localStores.detail.deleteTooltip' => 'Delete store',
			'localStores.detail.delete' => 'Delete',
			'localStores.detail.cancel' => 'Cancel',
			'localStores.detail.deleteSuccess' => 'Store deleted.',
			'localStores.detail.deleteFail' => 'Failed to delete store: {error}',
			'localStores.detail.inquire' => 'Inquire',
			'localStores.detail.noOwnerInfo' => 'No owner info',
			'localStores.detail.startChatFail' => 'Could not start chat: {error}',
			'localStores.detail.reviews' => 'Reviews',
			'localStores.detail.writeReview' => 'Write a review',
			'localStores.detail.noReviews' => 'No reviews yet.',
			'localStores.detail.reviewDialogContent' => 'Please write your review.',
			'localStores.noLocation' => 'No location info',
			'pom.title' => 'POM',
			'pom.search.hint' => 'Search POMs, tags, users',
			'pom.tabs.local' => 'Local',
			'pom.tabs.all' => 'All',
			'pom.tabs.popular' => 'Popular',
			'pom.tabs.myPoms' => 'My POMs',
			'pom.more' => 'More',
			'pom.less' => 'Less',
			'pom.likesCount' => '{} likes',
			'pom.report' => 'Report {}',
			'pom.block' => 'Block {}',
			'pom.emptyPopular' => 'No popular POMs yet.',
			'pom.emptyMine' => 'You haven\'t uploaded any POMs yet.',
			'pom.emptyHintPopular' => 'Try the All tab to see the latest POMs.',
			'pom.emptyCtaMine' => 'Tap + to upload your first POM.',
			'pom.share' => 'Share',
			'pom.empty' => 'No POM uploaded.',
			'pom.errors.fetchFailed' => 'An error occurred: {error}',
			'pom.errors.videoSource' => 'Can\'t play this video. The source is unavailable or blocked.',
			'pom.comments.title' => 'Comments',
			'pom.comments.viewAll' => 'View all {} comments',
			'pom.comments.empty' => 'No comments yet.',
			'pom.comments.placeholder' => 'Write a comment...',
			'pom.comments.fail' => 'Failed to add comment: {error}',
			'pom.create.title' => 'Upload New POM',
			'pom.create.photo' => 'Photo',
			'pom.create.video' => 'Video',
			'pom.create.titleImage' => 'Upload Photos',
			'pom.create.submit' => 'Upload',
			'pom.create.success' => 'POM uploaded.',
			'pom.create.fail' => 'Failed to upload POM: {error}',
			'pom.create.form.titleLabel' => 'Title',
			'pom.create.form.descriptionLabel' => 'Description',
			'realEstate.empty' => 'No listings.',
			'realEstate.error' => 'An error occurred: {error}',
			'realEstate.create' => 'Add listing',
			'realEstate.locationUnknown' => 'No location info',
			'realEstate.priceUnits.monthly' => 'month',
			'realEstate.priceUnits.yearly' => 'year',
			'realEstate.priceUnit.monthly' => '/month',
			'realEstate.form.title' => 'Register Listing',
			'realEstate.form.submit' => 'Register',
			'realEstate.form.imageRequired' => 'Please attach at least one photo.',
			'realEstate.form.success' => 'Listing created.',
			'realEstate.form.fail' => 'Failed to create listing: {error}',
			'realEstate.form.type.kos' => 'Boarding house',
			'realEstate.form.type.kontrakan' => 'Monthly rent',
			'realEstate.form.type.sewa' => 'Lease',
			'realEstate.form.priceLabel' => 'Price',
			'realEstate.form.priceRequired' => 'Enter the price.',
			'realEstate.form.priceUnit.monthly' => '/month',
			'realEstate.form.priceUnit.yearly' => '/year',
			'realEstate.form.titleLabel' => 'Title',
			'realEstate.form.titleRequired' => 'Enter a title.',
			'realEstate.form.descriptionLabel' => 'Description',
			'realEstate.form.typeLabel' => 'Room type',
			'realEstate.form.roomTypes.kos' => 'Boarding house',
			'realEstate.form.roomTypes.kontrakan' => 'Monthly rent',
			'realEstate.form.roomTypes.sewa' => 'Lease',
			'realEstate.form.roomTypes.apartment' => 'Apartment',
			'realEstate.form.roomTypes.house' => 'House',
			'realEstate.form.roomTypes.ruko' => 'Shophouse',
			'realEstate.form.roomTypes.gudang' => 'Warehouse',
			'realEstate.form.roomTypes.kantor' => 'Office',
			'realEstate.form.roomTypes.etc' => 'Other',
			'realEstate.form.listingType' => 'Transaction type',
			'realEstate.form.listingTypeHint' => 'Select transaction type',
			'realEstate.form.listingTypes.rent' => 'Rent',
			'realEstate.form.listingTypes.sale' => 'Sale',
			'realEstate.form.publisherType' => 'Publisher',
			'realEstate.form.publisherTypes.individual' => 'Individual',
			'realEstate.form.publisherTypes.agent' => 'Agent',
			'realEstate.form.area' => 'Area',
			'realEstate.form.areaHint' => 'e.g. 33',
			'realEstate.form.landArea' => 'Land area',
			'realEstate.form.rooms' => 'Rooms',
			'realEstate.form.bathrooms' => 'Bathrooms',
			'realEstate.form.bedAbbr' => 'Bed',
			'realEstate.form.bathAbbr' => 'Bath',
			'realEstate.form.moveInDate' => 'Move-in date',
			'realEstate.form.selectDate' => 'Select date',
			'realEstate.form.clearDate' => 'Clear date',
			'realEstate.form.amenities' => 'Amenities',
			'realEstate.form.amenity.wifi' => 'Wi-Fi',
			'realEstate.form.amenity.ac' => 'AC',
			'realEstate.form.amenity.parking' => 'Parking',
			'realEstate.form.amenity.kitchen' => 'Kitchen',
			'realEstate.form.details' => 'Listing Details',
			'realEstate.form.maintenanceFee' => 'Monthly maintenance fee',
			'realEstate.form.maintenanceFeeHint' => 'Maintenance fee (per month, Rp)',
			'realEstate.form.deposit' => 'Deposit',
			'realEstate.form.depositHint' => 'Deposit (Rp)',
			'realEstate.form.floorInfo' => 'Floor info',
			'realEstate.form.floorInfoHint' => 'e.g., Floor 1 / 3 of 5',
			'realEstate.filter.amenities.ac' => 'AC',
			'realEstate.filter.amenities.bed' => 'Bed',
			'realEstate.filter.amenities.closet' => 'Wardrobe',
			'realEstate.filter.amenities.desk' => 'Desk',
			'realEstate.filter.amenities.wifi' => 'Wi‑Fi',
			'realEstate.filter.amenities.kitchen' => 'Kitchen',
			'realEstate.filter.amenities.livingRoom' => 'Living room',
			'realEstate.filter.amenities.refrigerator' => 'Refrigerator',
			'realEstate.filter.amenities.parkingMotorcycle' => 'Motorcycle parking',
			'realEstate.filter.amenities.parkingCar' => 'Car parking',
			'realEstate.filter.amenities.pool' => 'Swimming pool',
			'realEstate.filter.amenities.gym' => 'Gym',
			'realEstate.filter.amenities.security24h' => '24h Security',
			'realEstate.filter.amenities.atmCenter' => 'ATM center',
			'realEstate.filter.amenities.minimarket' => 'Minimarket',
			'realEstate.filter.amenities.mallAccess' => 'Mall access',
			'realEstate.filter.amenities.playground' => 'Playground',
			'realEstate.filter.amenities.carport' => 'Carport',
			_ => null,
		} ?? switch (path) {
			'realEstate.filter.amenities.garden' => 'Garden',
			'realEstate.filter.amenities.pam' => 'Piped water (PAM)',
			'realEstate.filter.amenities.telephone' => 'Telephone',
			'realEstate.filter.amenities.waterHeater' => 'Water heater',
			'realEstate.filter.amenities.parkingArea' => 'Parking area',
			'realEstate.filter.amenities.electricity' => 'Electricity (power)',
			'realEstate.filter.amenities.containerAccess' => 'Container access',
			'realEstate.filter.amenities.kosRoom.ac' => 'AC',
			'realEstate.filter.amenities.kosRoom.bed' => 'Bed',
			'realEstate.filter.amenities.kosRoom.closet' => 'Closet',
			'realEstate.filter.amenities.kosRoom.desk' => 'Desk',
			'realEstate.filter.amenities.kosRoom.wifi' => 'Wifi',
			'realEstate.filter.amenities.kosPublic.kitchen' => 'Kitchen',
			'realEstate.filter.amenities.kosPublic.livingRoom' => 'Living Room',
			'realEstate.filter.amenities.kosPublic.refrigerator' => 'Refrigerator',
			'realEstate.filter.amenities.kosPublic.parkingMotorcycle' => 'Motorcycle Parking',
			'realEstate.filter.amenities.kosPublic.parkingCar' => 'Car Parking',
			'realEstate.filter.amenities.apartment.pool' => 'Swimming Pool',
			'realEstate.filter.amenities.apartment.gym' => 'Gym',
			'realEstate.filter.amenities.apartment.security24h' => '24h Security',
			'realEstate.filter.amenities.apartment.atmCenter' => 'ATM Center',
			'realEstate.filter.amenities.apartment.minimarket' => 'Minimarket',
			'realEstate.filter.amenities.apartment.mallAccess' => 'Mall Access',
			'realEstate.filter.amenities.apartment.playground' => 'Playground',
			'realEstate.filter.amenities.house.carport' => 'Carport',
			'realEstate.filter.amenities.house.garden' => 'Garden',
			'realEstate.filter.amenities.house.pam' => 'PAM (Water)',
			'realEstate.filter.amenities.house.telephone' => 'Telephone',
			'realEstate.filter.amenities.house.waterHeater' => 'Water Heater',
			'realEstate.filter.amenities.commercial.parkingArea' => 'Parking Area',
			'realEstate.filter.amenities.commercial.security24h' => '24h Security',
			'realEstate.filter.amenities.commercial.telephone' => 'Telephone',
			'realEstate.filter.amenities.commercial.electricity' => 'Electricity',
			'realEstate.filter.amenities.commercial.containerAccess' => 'Container Access',
			'realEstate.filter.title' => 'Advanced filters',
			'realEstate.filter.priceRange' => 'Price range',
			'realEstate.filter.areaRange' => 'Area range (m²)',
			'realEstate.filter.landAreaRange' => 'Land area range (m²)',
			'realEstate.filter.depositRange' => 'Deposit range',
			'realEstate.filter.floorInfo' => 'Floor info',
			'realEstate.filter.depositMin' => 'Min deposit',
			'realEstate.filter.depositMax' => 'Max deposit',
			'realEstate.filter.clearFloorInfo' => 'Clear',
			'realEstate.filter.furnishedStatus' => 'Furnishing',
			'realEstate.filter.rentPeriod' => 'Rent period',
			'realEstate.filter.selectFurnished' => 'Select furnishing',
			'realEstate.filter.furnishedHint' => 'Select furnishing',
			'realEstate.filter.selectRentPeriod' => 'Select rent period',
			'realEstate.filter.rentPeriods.daily' => 'Daily',
			'realEstate.filter.rentPeriods.monthly' => 'Monthly',
			'realEstate.filter.rentPeriods.yearly' => 'Yearly',
			'realEstate.filter.kos.bathroomType' => 'Bathroom type',
			'realEstate.filter.kos.bathroomTypes.inRoom' => 'Inside room',
			'realEstate.filter.kos.bathroomTypes.outRoom' => 'Outside room',
			'realEstate.filter.kos.maxOccupants' => 'Max occupants',
			'realEstate.filter.kos.hintBathroomType' => 'Select bathroom type',
			'realEstate.filter.kos.hintMaxOccupants' => 'Select number of occupants',
			'realEstate.filter.kos.electricityIncluded' => 'Electricity included',
			'realEstate.filter.kos.roomFacilities' => 'Room facilities',
			'realEstate.filter.kos.publicFacilities' => 'Shared facilities',
			'realEstate.filter.kos.occupant' => 'Person(s)',
			'realEstate.filter.apartment.facilities' => 'Apartment facilities',
			'realEstate.filter.house.facilities' => 'House facilities',
			'realEstate.filter.commercial.facilities' => 'Commercial facilities',
			'realEstate.filter.propertyCondition' => 'Property condition',
			'realEstate.filter.propertyConditions.kNew' => 'New',
			'realEstate.filter.propertyConditions.used' => 'Used',
			'realEstate.filter.furnishedTypes.furnished' => 'Furnished',
			'realEstate.filter.furnishedTypes.semiFurnished' => 'Semi-furnished',
			'realEstate.filter.furnishedTypes.unfurnished' => 'Unfurnished',
			'realEstate.info.bed' => 'Bed',
			'realEstate.info.bath' => 'Bath',
			'realEstate.info.anytime' => 'Anytime',
			'realEstate.info.verifiedPublisher' => 'Verified publisher',
			'realEstate.detail.deleteTitle' => 'Delete listing',
			'realEstate.detail.deleteContent' => 'Are you sure you want to delete this listing?',
			'realEstate.detail.cancel' => 'Cancel',
			'realEstate.detail.deleteConfirm' => 'Delete',
			'realEstate.detail.deleteSuccess' => 'Listing deleted.',
			'realEstate.detail.deleteFail' => 'Failed to delete listing: {error}',
			'realEstate.detail.chatError' => 'Could not start chat: {error}',
			'realEstate.detail.location' => 'Location',
			'realEstate.detail.publisherInfo' => 'Publisher Info',
			'realEstate.detail.contact' => 'Contact',
			'realEstate.edit.title' => 'Edit Listing',
			'realEstate.edit.save' => 'Save',
			'realEstate.edit.success' => 'Listing updated.',
			'realEstate.edit.fail' => 'Failed to update listing: {error}',
			'realEstate.disclaimer' => 'Bling is an online advertising/board platform and is not a real estate broker or agent. The truthfulness of listings, ownership/title status, price, and terms are the sole responsibility of the poster. Users must conduct their own checks and verify all information directly with the poster and relevant authorities before proceeding.',
			'lostAndFound.empty' => 'No lost/found items yet.',
			'lostAndFound.error' => 'An error occurred: {error}',
			'lostAndFound.create' => 'Add lost/found item',
			'lostAndFound.resolve.confirmTitle' => 'Mark as resolved?',
			'lostAndFound.resolve.confirmBody' => 'This will mark the item as resolved.',
			'lostAndFound.resolve.success' => 'Marked as resolved.',
			'lostAndFound.resolve.badgeLost' => 'Found!',
			'lostAndFound.resolve.badgeFound' => 'Returned!',
			'lostAndFound.lost' => 'Lost',
			'lostAndFound.found' => 'Found',
			'lostAndFound.tabs.all' => 'All',
			'lostAndFound.tabs.lost' => 'Lost',
			'lostAndFound.tabs.found' => 'Found',
			'lostAndFound.card.location' => 'Location: {location}',
			'lostAndFound.form.title' => 'Register Lost/Found Item',
			'lostAndFound.form.submit' => 'Register',
			'lostAndFound.form.type.lost' => 'I lost it',
			'lostAndFound.form.type.found' => 'I found it',
			'lostAndFound.form.photoSectionTitle' => 'Add photos (max 5)',
			'lostAndFound.form.imageRequired' => 'Please attach at least one photo.',
			'lostAndFound.form.itemLabel' => 'What is the item?',
			'lostAndFound.form.itemError' => 'Please describe the item.',
			'lostAndFound.form.locationLabel' => 'Where was it lost or found?',
			'lostAndFound.form.locationError' => 'Please describe the location.',
			'lostAndFound.form.bountyTitle' => 'Set bounty (optional)',
			'lostAndFound.form.bountyDesc' => 'When enabled, a bounty tag will appear on your post.',
			'lostAndFound.form.bountyAmount' => 'Bounty amount (IDR)',
			'lostAndFound.form.bountyAmountError' => 'Enter a bounty amount to enable bounty.',
			'lostAndFound.form.success' => 'Registered.',
			'lostAndFound.form.fail' => 'Failed to register: {error}',
			'lostAndFound.form.tagsHint' => 'Add tags (press space to confirm)',
			'lostAndFound.edit.title' => 'Edit Lost/Found Item',
			'lostAndFound.edit.save' => 'Save',
			'lostAndFound.edit.success' => 'Updated.',
			'lostAndFound.edit.fail' => 'Failed to update: {error}',
			'lostAndFound.detail.title' => 'Lost & Found',
			'lostAndFound.detail.location' => 'Location',
			'lostAndFound.detail.bounty' => 'Bounty',
			'lostAndFound.detail.registrant' => 'Registrant',
			'lostAndFound.detail.contact' => 'Contact',
			'lostAndFound.detail.resolved' => 'Resolved',
			'lostAndFound.detail.markAsResolved' => 'Mark as Resolved',
			'lostAndFound.detail.deleteTitle' => 'Delete Post',
			'lostAndFound.detail.deleteContent' => 'Are you sure you want to delete this post? This action cannot be undone.',
			'lostAndFound.detail.delete' => 'Delete',
			'lostAndFound.detail.cancel' => 'Cancel',
			'lostAndFound.detail.deleteSuccess' => 'Post deleted.',
			'lostAndFound.detail.deleteFail' => 'Failed to delete post: {error}',
			'lostAndFound.detail.editTooltip' => 'Edit',
			'lostAndFound.detail.deleteTooltip' => 'Delete',
			'lostAndFound.detail.noUser' => 'User not found',
			'lostAndFound.detail.chatError' => 'Could not start chat: {error}',
			'community.title' => 'Community Screen',
			'shared.tagInput.defaultHint' => 'Add tags (press space to confirm)',
			'linkPreview.errorTitle' => 'Could not load preview',
			'linkPreview.errorBody' => 'Please check the link or try again later.',
			'selectCategory' => 'Select category',
			'addressNeighborhood' => 'Neighborhood',
			'addressDetailHint' => 'Address details',
			'localNewsTagResult.error' => 'An error occurred during search: {error}',
			'localNewsTagResult.empty' => 'No posts found with \'#{tag}\'.',
			'admin.screen.title' => 'Admin Menu',
			'admin.menu.aiApproval' => 'AI Verification Management',
			'admin.menu.reportManagement' => 'Report Management',
			'admin.aiApproval.empty' => 'No products pending AI verification.',
			'admin.aiApproval.error' => 'Error loading pending products.',
			'admin.aiApproval.requestedAt' => 'Requested at',
			'admin.reports.title' => 'Report Management',
			'admin.reports.empty' => 'No pending reports.',
			'admin.reports.error' => 'Error loading reports.',
			'admin.reports.createdAt' => 'Created at',
			'admin.reportList.title' => 'Report Management',
			'admin.reportList.empty' => 'No pending reports.',
			'admin.reportList.error' => 'Error loading reports.',
			'admin.reportDetail.title' => 'Report Details',
			'admin.reportDetail.loadError' => 'Error loading report details.',
			'admin.reportDetail.sectionReportInfo' => 'Report Information',
			'admin.reportDetail.idLabel' => 'ID',
			'admin.reportDetail.postIdLabel' => 'Reported Post ID',
			'admin.reportDetail.reporter' => 'Reporter',
			'admin.reportDetail.reportedUser' => 'Reported User',
			'admin.reportDetail.reason' => 'Reason',
			'admin.reportDetail.reportedAt' => 'Reported At',
			'admin.reportDetail.currentStatus' => 'Status',
			'admin.reportDetail.sectionContent' => 'Reported Content',
			'admin.reportDetail.loadingContent' => 'Loading content...',
			'admin.reportDetail.contentLoadError' => 'Failed to load reported content.',
			'admin.reportDetail.contentNotAvailable' => 'Content information not available or deleted.',
			'admin.reportDetail.authorIdLabel' => 'Author ID',
			'admin.reportDetail.content.post' => 'Post: {title}\n\n{body}',
			'admin.reportDetail.content.comment' => 'Comment: {content}',
			'admin.reportDetail.content.reply' => 'Reply: {content}',
			'admin.reportDetail.viewOriginalPost' => 'View Original Post',
			'admin.reportDetail.sectionActions' => 'Actions',
			'admin.reportDetail.actionReviewed' => 'Mark as Reviewed',
			'admin.reportDetail.actionTaken' => 'Mark Action Taken (e.g., Deleted)',
			'admin.reportDetail.actionDismissed' => 'Dismiss Report',
			'admin.reportDetail.statusUpdateSuccess' => 'Report status updated to \'{status}\'.',
			'admin.reportDetail.statusUpdateFail' => 'Failed to update status: {error}',
			'admin.reportDetail.originalPostNotFound' => 'Original post not found.',
			'admin.reportDetail.couldNotOpenOriginalPost' => 'Could not open original post.',
			'admin.dataFix.logsLabel' => 'Data Fix Logs',
			'tags.localNews.kelurahanNotice.name' => 'Kelurahan notice',
			'tags.localNews.kelurahanNotice.desc' => 'Neighborhood office announcements.',
			'tags.localNews.kecamatanNotice.name' => 'Kecamatan notice',
			'tags.localNews.kecamatanNotice.desc' => 'District office announcements.',
			'tags.localNews.publicCampaign.name' => 'Public campaign',
			'tags.localNews.publicCampaign.desc' => 'Public information and government programs.',
			'tags.localNews.siskamling.name' => 'Neighborhood watch',
			'tags.localNews.siskamling.desc' => 'Community safety patrol activities.',
			'tags.localNews.powerOutage.name' => 'Power outage',
			'tags.localNews.powerOutage.desc' => 'Information about electricity outages in your area.',
			'tags.localNews.waterOutage.name' => 'Water outage',
			'tags.localNews.waterOutage.desc' => 'Information about water supply outages.',
			'tags.localNews.wasteCollection.name' => 'Waste collection',
			'tags.localNews.wasteCollection.desc' => 'Garbage pickup schedules or notices.',
			'tags.localNews.roadWorks.name' => 'Road works',
			'tags.localNews.roadWorks.desc' => 'Road construction and maintenance information.',
			'tags.localNews.publicFacility.name' => 'Public facility',
			'tags.localNews.publicFacility.desc' => 'Parks, fields, and public facility updates.',
			'tags.localNews.weatherWarning.name' => 'Weather warning',
			'tags.localNews.weatherWarning.desc' => 'Severe weather alerts in your area.',
			'tags.localNews.floodAlert.name' => 'Flood alert',
			'tags.localNews.floodAlert.desc' => 'Flood advisories and areas affected.',
			'tags.localNews.airQuality.name' => 'Air quality',
			'tags.localNews.airQuality.desc' => 'Air pollution and AQI information.',
			'tags.localNews.diseaseAlert.name' => 'Disease alert',
			'tags.localNews.diseaseAlert.desc' => 'Communicable disease alerts and public health info.',
			'tags.localNews.schoolNotice.name' => 'School notice',
			'tags.localNews.schoolNotice.desc' => 'Notices from nearby schools.',
			'tags.localNews.posyandu.name' => 'Posyandu',
			'tags.localNews.posyandu.desc' => 'Community health post activities.',
			'tags.localNews.healthCampaign.name' => 'Health campaign',
			'tags.localNews.healthCampaign.desc' => 'Health campaign and public health guidance.',
			'tags.localNews.trafficControl.name' => 'Traffic control',
			'tags.localNews.trafficControl.desc' => 'Traffic diversions, closures, and control info.',
			'tags.localNews.publicTransport.name' => 'Public transport',
			'tags.localNews.publicTransport.desc' => 'Bus, train, and public transportation updates.',
			'tags.localNews.parkingPolicy.name' => 'Parking policy',
			'tags.localNews.parkingPolicy.desc' => 'Parking information and policy changes.',
			'tags.localNews.communityEvent.name' => 'Community event',
			'tags.localNews.communityEvent.desc' => 'Local festivals, gatherings, and events.',
			'tags.localNews.worshipEvent.name' => 'Religious event',
			'tags.localNews.worshipEvent.desc' => 'Events at mosques, churches, temples, etc.',
			'tags.localNews.incidentReport.name' => 'Incident report',
			'tags.localNews.incidentReport.desc' => 'Reports of incidents and accidents in the neighborhood.',
			'boards.popup.inactiveTitle' => 'Neighborhood board is inactive',
			'boards.popup.inactiveBody' => 'To activate your neighborhood board, create a local news post first. Once neighbors join in, the board will open automatically.',
			'boards.popup.writePost' => 'Write Local News',
			'boards.defaultTitle' => 'Board',
			'boards.chatRoomComingSoon' => 'Chat room coming soon',
			'boards.chatRoomTitle' => 'Chat Room',
			'boards.emptyFeed' => 'No posts yet.',
			'boards.chatRoomCreated' => 'Chat room created.',
			'locationSettingError' => 'Failed to set location.',
			'signupFailRequired' => 'This field is required.',
			'signupFailPasswordMismatch' => 'Passwords do not match.',
			'signup.alerts.signupSuccessLoginNotice' => 'Sign up successful! Please log in.',
			'signup.title' => 'Sign Up',
			'signup.subtitle' => 'Join your neighborhood community!',
			'signup.nicknameHint' => 'Nickname',
			'signup.emailHint' => 'Email Address',
			'signup.passwordHint' => 'Password',
			'signup.passwordConfirmHint' => 'Confirm Password',
			'signup.locationHint' => 'Location',
			'signup.locationNotice' => 'Your location is used to show local posts and is not shared.',
			'signup.buttons.signup' => 'Sign Up',
			'signupFailDefault' => 'Sign up failed.',
			'signupFailWeakPassword' => 'Password is too weak.',
			'signupFailEmailInUse' => 'Email is already in use.',
			'signupFailInvalidEmail' => 'Invalid email format.',
			'signupFailUnknown' => 'An unknown error occurred.',
			'categoryEmpty' => 'No Category',
			'user.notLoggedIn' => 'Not logged in',
			_ => null,
		};
	}
}
