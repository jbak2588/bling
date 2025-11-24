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
class TranslationsId extends Translations with BaseTranslations<AppLocale, Translations> {
	/// You can call this constructor and build your own translation instance of this locale.
	/// Constructing via the enum [AppLocale.build] is preferred.
	TranslationsId({Map<String, Node>? overrides, PluralResolver? cardinalResolver, PluralResolver? ordinalResolver, TranslationMetadata<AppLocale, Translations>? meta})
		: assert(overrides == null, 'Set "translation_overrides: true" in order to enable this feature.'),
		  $meta = meta ?? TranslationMetadata(
		    locale: AppLocale.id,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ),
		  super(cardinalResolver: cardinalResolver, ordinalResolver: ordinalResolver) {
		super.$meta.setFlatMapFunction($meta.getTranslation); // copy base translations to super.$meta
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <id>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	@override dynamic operator[](String key) => $meta.getTranslation(key) ?? super.$meta.getTranslation(key);

	late final TranslationsId _root = this; // ignore: unused_field

	@override 
	TranslationsId $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => TranslationsId(meta: meta ?? this.$meta);

	// Translations
	@override late final _TranslationsLoginId login = _TranslationsLoginId._(_root);
	@override late final _TranslationsMainId main = _TranslationsMainId._(_root);
	@override late final _TranslationsSearchId search = _TranslationsSearchId._(_root);
	@override late final _TranslationsDrawerId drawer = _TranslationsDrawerId._(_root);
	@override late final _TranslationsMarketplaceId marketplace = _TranslationsMarketplaceId._(_root);
	@override late final _TranslationsAiFlowId aiFlow = _TranslationsAiFlowId._(_root);
	@override late final _TranslationsRegistrationFlowId registrationFlow = _TranslationsRegistrationFlowId._(_root);
	@override late final _TranslationsMyBlingId myBling = _TranslationsMyBlingId._(_root);
	@override late final _TranslationsProfileViewId profileView = _TranslationsProfileViewId._(_root);
	@override late final _TranslationsSettingsId settings = _TranslationsSettingsId._(_root);
	@override late final _TranslationsFriendRequestsId friendRequests = _TranslationsFriendRequestsId._(_root);
	@override late final _TranslationsSentFriendRequestsId sentFriendRequests = _TranslationsSentFriendRequestsId._(_root);
	@override late final _TranslationsBlockedUsersId blockedUsers = _TranslationsBlockedUsersId._(_root);
	@override late final _TranslationsRejectedUsersId rejectedUsers = _TranslationsRejectedUsersId._(_root);
	@override late final _TranslationsPromptId prompt = _TranslationsPromptId._(_root);
	@override late final _TranslationsLocationId location = _TranslationsLocationId._(_root);
	@override late final _TranslationsProfileEditId profileEdit = _TranslationsProfileEditId._(_root);
	@override late final _TranslationsMainFeedId mainFeed = _TranslationsMainFeedId._(_root);
	@override late final _TranslationsPostCardId postCard = _TranslationsPostCardId._(_root);
	@override late final _TranslationsTimeId time = _TranslationsTimeId._(_root);
	@override late final _TranslationsProductCardId productCard = _TranslationsProductCardId._(_root);
	@override late final _TranslationsLocalNewsFeedId localNewsFeed = _TranslationsLocalNewsFeedId._(_root);
	@override late final _TranslationsCategoriesId categories = _TranslationsCategoriesId._(_root);
	@override late final _TranslationsLocalNewsCreateId localNewsCreate = _TranslationsLocalNewsCreateId._(_root);
	@override late final _TranslationsLocalNewsDetailId localNewsDetail = _TranslationsLocalNewsDetailId._(_root);
	@override late final _TranslationsLocalNewsEditId localNewsEdit = _TranslationsLocalNewsEditId._(_root);
	@override late final _TranslationsCommentInputFieldId commentInputField = _TranslationsCommentInputFieldId._(_root);
	@override late final _TranslationsCommentListViewId commentListView = _TranslationsCommentListViewId._(_root);
	@override late final _TranslationsCommonId common = _TranslationsCommonId._(_root);
	@override late final _TranslationsReportDialogId reportDialog = _TranslationsReportDialogId._(_root);
	@override late final _TranslationsReplyDeleteId replyDelete = _TranslationsReplyDeleteId._(_root);
	@override late final _TranslationsReportReasonsId reportReasons = _TranslationsReportReasonsId._(_root);
	@override late final _TranslationsDeleteConfirmId deleteConfirm = _TranslationsDeleteConfirmId._(_root);
	@override late final _TranslationsReplyInputFieldId replyInputField = _TranslationsReplyInputFieldId._(_root);
	@override late final _TranslationsChatListId chatList = _TranslationsChatListId._(_root);
	@override late final _TranslationsChatRoomId chatRoom = _TranslationsChatRoomId._(_root);
	@override late final _TranslationsJobsId jobs = _TranslationsJobsId._(_root);
}

// Path: login
class _TranslationsLoginId extends TranslationsLoginKo {
	_TranslationsLoginId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Masuk';
	@override String get subtitle => 'Beli dan jual dengan mudah di Bling!';
	@override String get emailHint => 'Alamat Email';
	@override String get passwordHint => 'Kata Sandi';
	@override late final _TranslationsLoginButtonsId buttons = _TranslationsLoginButtonsId._(_root);
	@override late final _TranslationsLoginLinksId links = _TranslationsLoginLinksId._(_root);
	@override late final _TranslationsLoginAlertsId alerts = _TranslationsLoginAlertsId._(_root);
}

// Path: main
class _TranslationsMainId extends TranslationsMainKo {
	_TranslationsMainId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsMainAppBarId appBar = _TranslationsMainAppBarId._(_root);
	@override late final _TranslationsMainTabsId tabs = _TranslationsMainTabsId._(_root);
	@override late final _TranslationsMainBottomNavId bottomNav = _TranslationsMainBottomNavId._(_root);
	@override late final _TranslationsMainErrorsId errors = _TranslationsMainErrorsId._(_root);
	@override String get myTown => 'Lingkungan Saya';
	@override late final _TranslationsMainMapViewId mapView = _TranslationsMainMapViewId._(_root);
	@override late final _TranslationsMainSearchId search = _TranslationsMainSearchId._(_root);
}

// Path: search
class _TranslationsSearchId extends TranslationsSearchKo {
	_TranslationsSearchId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get resultsTitle => 'Hasil untuk \'{keyword}\'';
	@override late final _TranslationsSearchEmptyId empty = _TranslationsSearchEmptyId._(_root);
	@override String get prompt => 'Ketik kata kunci';
	@override late final _TranslationsSearchSheetId sheet = _TranslationsSearchSheetId._(_root);
	@override String get results => 'hasil';
}

// Path: drawer
class _TranslationsDrawerId extends TranslationsDrawerKo {
	_TranslationsDrawerId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get editProfile => 'Edit Profil';
	@override String get bookmarks => 'Bookmark';
	@override String get uploadSampleData => 'Unggah Data Contoh';
	@override String get logout => 'Keluar';
	@override late final _TranslationsDrawerTrustDashboardId trustDashboard = _TranslationsDrawerTrustDashboardId._(_root);
	@override String get runDataFix => 'Jalankan Perbaikan Data';
}

// Path: marketplace
class _TranslationsMarketplaceId extends TranslationsMarketplaceKo {
	_TranslationsMarketplaceId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get error => 'Terjadi kesalahan: {error}';
	@override String get empty => 'Belum ada produk.\nKetuk tombol + untuk menambahkan barang pertama!';
	@override late final _TranslationsMarketplaceRegistrationId registration = _TranslationsMarketplaceRegistrationId._(_root);
	@override late final _TranslationsMarketplaceEditId edit = _TranslationsMarketplaceEditId._(_root);
	@override late final _TranslationsMarketplaceDetailId detail = _TranslationsMarketplaceDetailId._(_root);
	@override late final _TranslationsMarketplaceDialogId dialog = _TranslationsMarketplaceDialogId._(_root);
	@override late final _TranslationsMarketplaceErrorsId errors = _TranslationsMarketplaceErrorsId._(_root);
	@override late final _TranslationsMarketplaceConditionId condition = _TranslationsMarketplaceConditionId._(_root);
	@override late final _TranslationsMarketplaceReservationId reservation = _TranslationsMarketplaceReservationId._(_root);
	@override late final _TranslationsMarketplaceStatusId status = _TranslationsMarketplaceStatusId._(_root);
	@override late final _TranslationsMarketplaceAiId ai = _TranslationsMarketplaceAiId._(_root);
	@override late final _TranslationsMarketplaceTakeoverId takeover = _TranslationsMarketplaceTakeoverId._(_root);
	@override String get aiBadge => 'Diverifikasi AI';
	@override String get setLocationPrompt => 'Atur lingkungan Anda terlebih dahulu untuk melihat barang preloved!';
}

// Path: aiFlow
class _TranslationsAiFlowId extends TranslationsAiFlowKo {
	_TranslationsAiFlowId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsAiFlowCommonId common = _TranslationsAiFlowCommonId._(_root);
	@override late final _TranslationsAiFlowCtaId cta = _TranslationsAiFlowCtaId._(_root);
	@override late final _TranslationsAiFlowCategorySelectionId categorySelection = _TranslationsAiFlowCategorySelectionId._(_root);
	@override late final _TranslationsAiFlowGalleryUploadId galleryUpload = _TranslationsAiFlowGalleryUploadId._(_root);
	@override late final _TranslationsAiFlowPredictionId prediction = _TranslationsAiFlowPredictionId._(_root);
	@override late final _TranslationsAiFlowGuidedCameraId guidedCamera = _TranslationsAiFlowGuidedCameraId._(_root);
	@override late final _TranslationsAiFlowFinalReportId finalReport = _TranslationsAiFlowFinalReportId._(_root);
	@override late final _TranslationsAiFlowEvidenceId evidence = _TranslationsAiFlowEvidenceId._(_root);
	@override late final _TranslationsAiFlowErrorId error = _TranslationsAiFlowErrorId._(_root);
}

// Path: registrationFlow
class _TranslationsRegistrationFlowId extends TranslationsRegistrationFlowKo {
	_TranslationsRegistrationFlowId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pilih jenis barang yang akan dijual';
	@override String get newItemTitle => 'Daftar barang baru & bekas biasa';
	@override String get newItemDesc => 'Daftarkan barang baru yang tidak terpakai dan barang bekas biasa dengan cepat.';
	@override String get usedItemTitle => 'Barang bekas (Verifikasi AI)';
	@override String get usedItemDesc => 'AI menganalisis barang Anda untuk membangun kepercayaan dan membantu penjualan.';
}

// Path: myBling
class _TranslationsMyBlingId extends TranslationsMyBlingKo {
	_TranslationsMyBlingId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Bling Saya';
	@override String get editProfile => 'Edit profil';
	@override String get settings => 'Pengaturan';
	@override String get posts => 'Postingan';
	@override String get followers => 'Pengikut';
	@override String get neighbors => 'Tetangga';
	@override String get friends => 'Teman';
	@override late final _TranslationsMyBlingStatsId stats = _TranslationsMyBlingStatsId._(_root);
	@override late final _TranslationsMyBlingTabsId tabs = _TranslationsMyBlingTabsId._(_root);
	@override String get friendRequests => 'Permintaan pertemanan diterima';
	@override String get sentFriendRequests => 'Permintaan yang dikirim';
}

// Path: profileView
class _TranslationsProfileViewId extends TranslationsProfileViewKo {
	_TranslationsProfileViewId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Profil';
	@override late final _TranslationsProfileViewTabsId tabs = _TranslationsProfileViewTabsId._(_root);
	@override String get noPosts => 'Belum ada postingan.';
	@override String get noInterests => 'Belum ada minat yang disetel.';
}

// Path: settings
class _TranslationsSettingsId extends TranslationsSettingsKo {
	_TranslationsSettingsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pengaturan';
	@override String get accountPrivacy => 'Akun & Privasi';
	@override late final _TranslationsSettingsNotificationsId notifications = _TranslationsSettingsNotificationsId._(_root);
	@override String get appInfo => 'Info aplikasi';
}

// Path: friendRequests
class _TranslationsFriendRequestsId extends TranslationsFriendRequestsKo {
	_TranslationsFriendRequestsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Permintaan pertemanan diterima';
	@override String get noRequests => 'Belum ada permintaan pertemanan.';
	@override String get acceptSuccess => 'Permintaan pertemanan diterima.';
	@override String get rejectSuccess => 'Permintaan pertemanan ditolak.';
	@override String get error => 'Terjadi kesalahan: {error}';
	@override late final _TranslationsFriendRequestsTooltipId tooltip = _TranslationsFriendRequestsTooltipId._(_root);
	@override String get defaultChatMessage => 'Sekarang kalian sudah berteman! Mulai ngobrol, yuk.';
}

// Path: sentFriendRequests
class _TranslationsSentFriendRequestsId extends TranslationsSentFriendRequestsKo {
	_TranslationsSentFriendRequestsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Permintaan pertemanan terkirim';
	@override String get noRequests => 'Belum ada permintaan pertemanan yang dikirim.';
	@override String get statusLabel => 'Status: {status}';
	@override late final _TranslationsSentFriendRequestsStatusId status = _TranslationsSentFriendRequestsStatusId._(_root);
}

// Path: blockedUsers
class _TranslationsBlockedUsersId extends TranslationsBlockedUsersKo {
	_TranslationsBlockedUsersId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pengguna yang diblokir';
	@override String get noBlockedUsers => 'Anda belum memblokir siapa pun.';
	@override String get unblock => 'Buka blokir';
	@override late final _TranslationsBlockedUsersUnblockDialogId unblockDialog = _TranslationsBlockedUsersUnblockDialogId._(_root);
	@override String get unblockSuccess => 'Blokir untuk {nickname} telah dibuka.';
	@override String get unblockFailure => 'Gagal membuka blokir: {error}';
	@override String get unknownUser => 'Pengguna tidak dikenal';
	@override String get empty => 'Tidak ada pengguna yang diblokir.';
}

// Path: rejectedUsers
class _TranslationsRejectedUsersId extends TranslationsRejectedUsersKo {
	_TranslationsRejectedUsersId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Kelola pengguna yang ditolak';
	@override String get noRejectedUsers => 'Tidak ada permintaan pertemanan yang Anda tolak.';
	@override String get unreject => 'Batalkan penolakan';
	@override late final _TranslationsRejectedUsersUnrejectDialogId unrejectDialog = _TranslationsRejectedUsersUnrejectDialogId._(_root);
	@override String get unrejectSuccess => 'Penolakan untuk {nickname} telah dibatalkan.';
	@override String get unrejectFailure => 'Gagal membatalkan penolakan: {error}';
}

// Path: prompt
class _TranslationsPromptId extends TranslationsPromptKo {
	_TranslationsPromptId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Selamat datang di Bling!';
	@override String get subtitle => 'Untuk melihat berita dan barang di sekitar, atur lingkungan Anda terlebih dahulu.';
	@override String get button => 'Atur Lingkungan Saya';
}

// Path: location
class _TranslationsLocationId extends TranslationsLocationKo {
	_TranslationsLocationId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Atur Lingkungan';
	@override String get searchHint => 'Cari berdasarkan nama lingkungan, mis. Serpong';
	@override String get gpsButton => 'Gunakan lokasi saat ini';
	@override String get success => 'Lingkungan berhasil disetel.';
	@override String get error => 'Gagal menyetel lingkungan: {error}';
	@override String get empty => 'Silakan masukkan nama lingkungan.';
	@override String get permissionDenied => 'Izin lokasi diperlukan untuk menemukan lingkungan Anda.';
	@override String get rtLabel => 'RT';
	@override String get rwLabel => 'RW';
	@override String get rtHint => 'mis. 003';
	@override String get rwHint => 'mis. 007';
	@override String get rtRequired => 'Silakan masukkan RT.';
	@override String get rwRequired => 'Silakan masukkan RW.';
	@override String get rtRwInfo => 'RT/RW Anda tidak akan ditampilkan ke publik. Data ini hanya digunakan untuk meningkatkan kepercayaan dan fitur lokal.';
	@override String get saveThisLocation => 'Simpan lokasi ini';
	@override String get manualSelect => 'Pilih manual';
	@override String get refreshFromGps => 'Perbarui dari GPS';
}

// Path: profileEdit
class _TranslationsProfileEditId extends TranslationsProfileEditKo {
	_TranslationsProfileEditId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pengaturan profil';
	@override String get nicknameHint => 'Nama panggilan';
	@override String get phoneHint => 'Nomor telepon';
	@override String get bioHint => 'Bio';
	@override String get locationTitle => 'Lokasi';
	@override String get changeLocation => 'Ubah';
	@override String get locationNotSet => 'Belum disetel';
	@override late final _TranslationsProfileEditInterestsId interests = _TranslationsProfileEditInterestsId._(_root);
	@override late final _TranslationsProfileEditPrivacyId privacy = _TranslationsProfileEditPrivacyId._(_root);
	@override String get saveButton => 'Simpan perubahan';
	@override String get successMessage => 'Profil berhasil diperbarui.';
	@override late final _TranslationsProfileEditErrorsId errors = _TranslationsProfileEditErrorsId._(_root);
}

// Path: mainFeed
class _TranslationsMainFeedId extends TranslationsMainFeedKo {
	_TranslationsMainFeedId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get error => 'Terjadi kesalahan: {error}';
	@override String get empty => 'Belum ada postingan baru.';
}

// Path: postCard
class _TranslationsPostCardId extends TranslationsPostCardKo {
	_TranslationsPostCardId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get locationNotSet => 'Lokasi belum disetel';
	@override String get location => 'Lokasi';
	@override String get authorNotFound => 'Penulis tidak ditemukan';
}

// Path: time
class _TranslationsTimeId extends TranslationsTimeKo {
	_TranslationsTimeId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get now => 'Baru saja';
	@override String get minutesAgo => '{minutes} menit yang lalu';
	@override String get hoursAgo => '{hours} jam yang lalu';
	@override String get daysAgo => '{days} hari yang lalu';
	@override String get dateFormat => 'yy.MM.dd';
	@override String get dateFormatLong => 'd MMM';
}

// Path: productCard
class _TranslationsProductCardId extends TranslationsProductCardKo {
	_TranslationsProductCardId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get currency => '\$';
}

// Path: localNewsFeed
class _TranslationsLocalNewsFeedId extends TranslationsLocalNewsFeedKo {
	_TranslationsLocalNewsFeedId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get setLocationPrompt => 'Atur lingkungan Anda untuk melihat cerita lokal!';
	@override String get allCategory => 'Semua';
	@override String get empty => 'Tidak ada postingan untuk ditampilkan.';
	@override String get error => 'Terjadi kesalahan: {error}';
}

// Path: categories
class _TranslationsCategoriesId extends TranslationsCategoriesKo {
	_TranslationsCategoriesId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsCategoriesPostId post = _TranslationsCategoriesPostId._(_root);
	@override late final _TranslationsCategoriesAuctionId auction = _TranslationsCategoriesAuctionId._(_root);
}

// Path: localNewsCreate
class _TranslationsLocalNewsCreateId extends TranslationsLocalNewsCreateKo {
	_TranslationsLocalNewsCreateId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get appBarTitle => 'Buat postingan baru';
	@override String get title => 'Buat postingan baru';
	@override late final _TranslationsLocalNewsCreateFormId form = _TranslationsLocalNewsCreateFormId._(_root);
	@override late final _TranslationsLocalNewsCreateLabelsId labels = _TranslationsLocalNewsCreateLabelsId._(_root);
	@override late final _TranslationsLocalNewsCreateHintsId hints = _TranslationsLocalNewsCreateHintsId._(_root);
	@override late final _TranslationsLocalNewsCreateValidationId validation = _TranslationsLocalNewsCreateValidationId._(_root);
	@override late final _TranslationsLocalNewsCreateButtonsId buttons = _TranslationsLocalNewsCreateButtonsId._(_root);
	@override late final _TranslationsLocalNewsCreateAlertsId alerts = _TranslationsLocalNewsCreateAlertsId._(_root);
	@override String get success => 'Postingan berhasil dibuat.';
	@override String get fail => 'Gagal membuat postingan: {error}';
}

// Path: localNewsDetail
class _TranslationsLocalNewsDetailId extends TranslationsLocalNewsDetailKo {
	_TranslationsLocalNewsDetailId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get appBarTitle => 'Postingan';
	@override late final _TranslationsLocalNewsDetailMenuId menu = _TranslationsLocalNewsDetailMenuId._(_root);
	@override late final _TranslationsLocalNewsDetailStatsId stats = _TranslationsLocalNewsDetailStatsId._(_root);
	@override late final _TranslationsLocalNewsDetailButtonsId buttons = _TranslationsLocalNewsDetailButtonsId._(_root);
	@override String get confirmDelete => 'Yakin ingin menghapus postingan ini?';
	@override String get deleted => 'Postingan telah dihapus.';
}

// Path: localNewsEdit
class _TranslationsLocalNewsEditId extends TranslationsLocalNewsEditKo {
	_TranslationsLocalNewsEditId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get appBarTitle => 'Edit postingan';
	@override late final _TranslationsLocalNewsEditButtonsId buttons = _TranslationsLocalNewsEditButtonsId._(_root);
	@override late final _TranslationsLocalNewsEditAlertsId alerts = _TranslationsLocalNewsEditAlertsId._(_root);
}

// Path: commentInputField
class _TranslationsCommentInputFieldId extends TranslationsCommentInputFieldKo {
	_TranslationsCommentInputFieldId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get secretCommentLabel => 'Rahasia';
	@override String get hintText => 'Tulis komentar...';
	@override String get replyHintText => 'Membalas {nickname}...';
	@override late final _TranslationsCommentInputFieldButtonId button = _TranslationsCommentInputFieldButtonId._(_root);
}

// Path: commentListView
class _TranslationsCommentListViewId extends TranslationsCommentListViewKo {
	_TranslationsCommentListViewId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get empty => 'Belum ada komentar. Jadilah yang pertama!';
	@override String get reply => 'Balas';
	@override String get delete => 'Hapus';
	@override String get deleted => '[Komentar ini telah dihapus]';
	@override String get secret => 'Ini adalah komentar rahasia yang hanya bisa dilihat penulis dan pemilik postingan.';
}

// Path: common
class _TranslationsCommonId extends TranslationsCommonKo {
	_TranslationsCommonId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get cancel => 'Batal';
	@override String get confirm => 'OK';
	@override String get delete => 'Hapus';
	@override String get done => 'Selesai';
	@override String get clear => 'Bersihkan';
	@override String get report => 'Laporkan';
	@override String get moreOptions => 'Lainnya';
	@override String get viewAll => 'Lihat semua';
	@override String get kNew => 'Baru';
	@override String get updated => 'Diperbarui';
	@override String get comments => 'Komentar';
	@override String get sponsored => 'Sponsor';
	@override String get filter => 'Filter';
	@override String get reset => 'Reset';
	@override String get apply => 'Terapkan';
	@override String get verified => 'Terverifikasi';
	@override String get bookmark => 'Bookmark';
	@override late final _TranslationsCommonSortId sort = _TranslationsCommonSortId._(_root);
	@override String get error => 'Terjadi kesalahan.';
	@override String get shareError => 'Gagal membagikan. Silakan coba lagi.';
	@override String get edit => 'Edit';
	@override String get submit => 'Kirim';
	@override String get loginRequired => 'Login diperlukan.';
	@override String get unknownUser => 'Pengguna tidak dikenal.';
}

// Path: reportDialog
class _TranslationsReportDialogId extends TranslationsReportDialogKo {
	_TranslationsReportDialogId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Laporkan postingan';
	@override String get titleComment => 'Laporkan komentar';
	@override String get titleReply => 'Laporkan balasan';
	@override String get cannotReportSelfComment => 'Anda tidak dapat melaporkan komentar Anda sendiri.';
	@override String get cannotReportSelfReply => 'Anda tidak dapat melaporkan balasan Anda sendiri.';
	@override String get success => 'Laporan telah dikirim. Terima kasih.';
	@override String get fail => 'Gagal mengirim laporan: {error}';
	@override String get cannotReportSelf => 'Anda tidak dapat melaporkan postingan Anda sendiri.';
}

// Path: replyDelete
class _TranslationsReplyDeleteId extends TranslationsReplyDeleteKo {
	_TranslationsReplyDeleteId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get fail => 'Gagal menghapus balasan: {error}';
}

// Path: reportReasons
class _TranslationsReportReasonsId extends TranslationsReportReasonsKo {
	_TranslationsReportReasonsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get spam => 'Spam atau menyesatkan';
	@override String get abuse => 'Pelecehan atau ujaran kebencian';
	@override String get inappropriate => 'Tidak pantas secara seksual';
	@override String get illegal => 'Konten ilegal';
	@override String get etc => 'Lainnya';
}

// Path: deleteConfirm
class _TranslationsDeleteConfirmId extends TranslationsDeleteConfirmKo {
	_TranslationsDeleteConfirmId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Hapus komentar';
	@override String get content => 'Yakin ingin menghapus komentar ini?';
	@override String get failure => 'Gagal menghapus komentar: {error}';
}

// Path: replyInputField
class _TranslationsReplyInputFieldId extends TranslationsReplyInputFieldKo {
	_TranslationsReplyInputFieldId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get hintText => 'Tulis balasan';
	@override late final _TranslationsReplyInputFieldButtonId button = _TranslationsReplyInputFieldButtonId._(_root);
	@override String get failure => 'Gagal menambahkan balasan: {error}';
}

// Path: chatList
class _TranslationsChatListId extends TranslationsChatListKo {
	_TranslationsChatListId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get appBarTitle => 'Chat';
	@override String get empty => 'Belum ada percakapan.';
}

// Path: chatRoom
class _TranslationsChatRoomId extends TranslationsChatRoomKo {
	_TranslationsChatRoomId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get startConversation => 'Mulai percakapan';
	@override String get icebreaker1 => 'Halo! 👋';
	@override String get icebreaker2 => 'Biasanya kamu ngapain kalau weekend?';
	@override String get icebreaker3 => 'Ada tempat favorit di sekitar sini?';
	@override String get mediaBlocked => 'Demi keamanan, pengiriman media dibatasi selama 24 jam.';
	@override String get imageMessage => 'Gambar';
	@override String get linkHidden => 'Mode perlindungan: tautan disembunyikan';
	@override String get contactHidden => 'Mode perlindungan: kontak disembunyikan';
}

// Path: jobs
class _TranslationsJobsId extends TranslationsJobsKo {
	_TranslationsJobsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get setLocationPrompt => 'Atur lokasi Anda untuk melihat lowongan kerja!';
	@override late final _TranslationsJobsScreenId screen = _TranslationsJobsScreenId._(_root);
	@override late final _TranslationsJobsTabsId tabs = _TranslationsJobsTabsId._(_root);
	@override late final _TranslationsJobsSelectTypeId selectType = _TranslationsJobsSelectTypeId._(_root);
	@override late final _TranslationsJobsFormId form = _TranslationsJobsFormId._(_root);
	@override late final _TranslationsJobsCategoriesId categories = _TranslationsJobsCategoriesId._(_root);
	@override late final _TranslationsJobsSalaryTypesId salaryTypes = _TranslationsJobsSalaryTypesId._(_root);
	@override late final _TranslationsJobsWorkPeriodsId workPeriods = _TranslationsJobsWorkPeriodsId._(_root);
	@override late final _TranslationsJobsDetailId detail = _TranslationsJobsDetailId._(_root);
	@override late final _TranslationsJobsCardId card = _TranslationsJobsCardId._(_root);
	@override late final _TranslationsJobsFindFriendId findFriend = _TranslationsJobsFindFriendId._(_root);
	@override late final _TranslationsJobsInterestsId interests = _TranslationsJobsInterestsId._(_root);
	@override late final _TranslationsJobsFriendDetailId friendDetail = _TranslationsJobsFriendDetailId._(_root);
	@override late final _TranslationsJobsLocationFilterId locationFilter = _TranslationsJobsLocationFilterId._(_root);
	@override late final _TranslationsJobsClubsId clubs = _TranslationsJobsClubsId._(_root);
	@override late final _TranslationsJobsFindfriendId findfriend = _TranslationsJobsFindfriendId._(_root);
	@override late final _TranslationsJobsAuctionsId auctions = _TranslationsJobsAuctionsId._(_root);
	@override late final _TranslationsJobsLocalStoresId localStores = _TranslationsJobsLocalStoresId._(_root);
	@override late final _TranslationsJobsPomId pom = _TranslationsJobsPomId._(_root);
	@override late final _TranslationsJobsRealEstateId realEstate = _TranslationsJobsRealEstateId._(_root);
	@override late final _TranslationsJobsLostAndFoundId lostAndFound = _TranslationsJobsLostAndFoundId._(_root);
	@override late final _TranslationsJobsCommunityId community = _TranslationsJobsCommunityId._(_root);
	@override late final _TranslationsJobsSharedId shared = _TranslationsJobsSharedId._(_root);
	@override late final _TranslationsJobsLinkPreviewId linkPreview = _TranslationsJobsLinkPreviewId._(_root);
	@override String get selectCategory => 'Pilih kategori';
	@override String get addressNeighborhood => 'Lingkungan';
	@override String get addressDetailHint => 'Detail alamat';
	@override late final _TranslationsJobsLocalNewsTagResultId localNewsTagResult = _TranslationsJobsLocalNewsTagResultId._(_root);
	@override late final _TranslationsJobsAdminId admin = _TranslationsJobsAdminId._(_root);
	@override late final _TranslationsJobsTagsId tags = _TranslationsJobsTagsId._(_root);
	@override late final _TranslationsJobsBoardsId boards = _TranslationsJobsBoardsId._(_root);
	@override String get locationSettingError => 'Gagal menyetel lokasi.';
	@override String get signupFailRequired => 'Kolom ini wajib diisi.';
	@override late final _TranslationsJobsSignupId signup = _TranslationsJobsSignupId._(_root);
	@override String get signupFailDefault => 'Pendaftaran gagal.';
	@override String get signupFailWeakPassword => 'Kata sandi terlalu lemah.';
	@override String get signupFailEmailInUse => 'Email sudah digunakan.';
	@override String get signupFailInvalidEmail => 'Format email tidak valid.';
	@override String get signupFailUnknown => 'Terjadi kesalahan yang tidak diketahui.';
	@override String get categoryEmpty => 'Tidak ada kategori';
	@override late final _TranslationsJobsUserId user = _TranslationsJobsUserId._(_root);
}

// Path: login.buttons
class _TranslationsLoginButtonsId extends TranslationsLoginButtonsKo {
	_TranslationsLoginButtonsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get login => 'Masuk';
	@override String get google => 'Lanjut dengan Google';
	@override String get apple => 'Lanjut dengan Apple';
}

// Path: login.links
class _TranslationsLoginLinksId extends TranslationsLoginLinksKo {
	_TranslationsLoginLinksId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get findPassword => 'Lupa kata sandi?';
	@override String get askForAccount => 'Belum punya akun?';
	@override String get signUp => 'Daftar';
}

// Path: login.alerts
class _TranslationsLoginAlertsId extends TranslationsLoginAlertsKo {
	_TranslationsLoginAlertsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get invalidEmail => 'Format email tidak valid.';
	@override String get userNotFound => 'Pengguna tidak ditemukan atau kata sandi salah.';
	@override String get wrongPassword => 'Kata sandi salah.';
	@override String get unknownError => 'Terjadi kesalahan. Silakan coba lagi.';
}

// Path: main.appBar
class _TranslationsMainAppBarId extends TranslationsMainAppBarKo {
	_TranslationsMainAppBarId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get locationNotSet => 'Lokasi belum diatur';
	@override String get locationError => 'Kesalahan lokasi';
	@override String get locationLoading => 'Memuat...';
}

// Path: main.tabs
class _TranslationsMainTabsId extends TranslationsMainTabsKo {
	_TranslationsMainTabsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get newFeed => 'Feed Baru';
	@override String get localNews => 'Berita Lingkungan';
	@override String get marketplace => 'Preloved';
	@override String get findFriends => 'Cari Teman';
	@override String get clubs => 'Klub';
	@override String get jobs => 'Pekerjaan';
	@override String get localStores => 'Toko Sekitar';
	@override String get auction => 'Lelang';
	@override String get pom => 'POM';
	@override String get lostAndFound => 'Hilang & Temuan';
	@override String get realEstate => 'Properti';
}

// Path: main.bottomNav
class _TranslationsMainBottomNavId extends TranslationsMainBottomNavKo {
	_TranslationsMainBottomNavId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get home => 'Beranda';
	@override String get board => 'Lingkungan';
	@override String get search => 'Cari';
	@override String get chat => 'Chat';
	@override String get myBling => 'Bling Saya';
}

// Path: main.errors
class _TranslationsMainErrorsId extends TranslationsMainErrorsKo {
	_TranslationsMainErrorsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get loginRequired => 'Harus masuk terlebih dahulu.';
	@override String get userNotFound => 'Pengguna tidak ditemukan.';
	@override String get unknown => 'Terjadi kesalahan.';
}

// Path: main.mapView
class _TranslationsMainMapViewId extends TranslationsMainMapViewKo {
	_TranslationsMainMapViewId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get showMap => 'Lihat peta';
	@override String get showList => 'Lihat daftar';
}

// Path: main.search
class _TranslationsMainSearchId extends TranslationsMainSearchKo {
	_TranslationsMainSearchId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get placeholder => 'Cari';
	@override String get chipPlaceholder => 'Cari tetangga, berita, preloved, pekerjaan…';
	@override late final _TranslationsMainSearchHintId hint = _TranslationsMainSearchHintId._(_root);
}

// Path: search.empty
class _TranslationsSearchEmptyId extends TranslationsSearchEmptyKo {
	_TranslationsSearchEmptyId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get message => 'Tidak ada hasil untuk \'{keyword}\'.';
	@override String get checkSpelling => 'Periksa ejaan atau coba kata kunci lain.';
	@override String get expandToNational => 'Cari secara Nasional';
}

// Path: search.sheet
class _TranslationsSearchSheetId extends TranslationsSearchSheetKo {
	_TranslationsSearchSheetId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get localNews => 'Cari Berita Lingkungan';
	@override String get localNewsDesc => 'Cari berdasarkan judul, isi, tag';
	@override String get jobs => 'Cari Pekerjaan';
	@override String get jobsDesc => 'Cari berdasarkan posisi, perusahaan, tag';
	@override String get lostAndFound => 'Cari Hilang & Temuan';
	@override String get lostAndFoundDesc => 'Cari berdasarkan nama barang atau lokasi';
	@override String get marketplace => 'Cari Preloved';
	@override String get marketplaceDesc => 'Cari berdasarkan nama barang, kategori, tag';
	@override String get localStores => 'Cari Toko Sekitar';
	@override String get localStoresDesc => 'Cari berdasarkan nama toko, jenis usaha, kata kunci';
	@override String get clubs => 'Cari Klub';
	@override String get clubsDesc => 'Cari berdasarkan nama klub, minat';
	@override String get findFriends => 'Cari Teman';
	@override String get findFriendsDesc => 'Cari berdasarkan nama panggilan atau minat';
	@override String get realEstate => 'Cari Properti';
	@override String get realEstateDesc => 'Cari berdasarkan judul, area, tag';
	@override String get auction => 'Cari Lelang';
	@override String get auctionDesc => 'Cari berdasarkan nama barang atau tag';
	@override String get pom => 'Cari POM';
	@override String get pomDesc => 'Cari berdasarkan judul atau hashtag';
	@override String get comingSoon => 'Segera hadir';
}

// Path: drawer.trustDashboard
class _TranslationsDrawerTrustDashboardId extends TranslationsDrawerTrustDashboardKo {
	_TranslationsDrawerTrustDashboardId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Status Verifikasi Kepercayaan';
	@override String get kelurahanAuth => 'Verifikasi Kelurahan';
	@override String get rtRwAuth => 'Verifikasi Alamat (RT/RW)';
	@override String get phoneAuth => 'Verifikasi Nomor Telepon';
	@override String get profileComplete => 'Profil Lengkap';
	@override String get feedThanks => 'Terima Kasih Feed';
	@override String get marketThanks => 'Terima Kasih Marketplace';
	@override String get reports => 'Laporan';
	@override String get breakdownButton => 'Detail';
	@override String get breakdownModalTitle => 'Rincian Skor Kepercayaan';
	@override String get breakdownClose => 'OK';
	@override late final _TranslationsDrawerTrustDashboardBreakdownId breakdown = _TranslationsDrawerTrustDashboardBreakdownId._(_root);
}

// Path: marketplace.registration
class _TranslationsMarketplaceRegistrationId extends TranslationsMarketplaceRegistrationKo {
	_TranslationsMarketplaceRegistrationId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Posting Baru';
	@override String get done => 'Simpan';
	@override String get titleHint => 'Nama Barang';
	@override String get priceHint => 'Harga (Rp)';
	@override String get negotiable => 'Bisa Nego';
	@override String get addressHint => 'Lingkungan';
	@override String get addressDetailHint => 'Tempat Bertemu';
	@override String get descriptionHint => 'Deskripsi Lengkap';
	@override String get success => 'Produk berhasil diposting!';
	@override String get tagsHint => 'Tambah tag (tekan spasi untuk konfirmasi)';
	@override String get fail => 'gagal';
}

// Path: marketplace.edit
class _TranslationsMarketplaceEditId extends TranslationsMarketplaceEditKo {
	_TranslationsMarketplaceEditId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Edit Postingan';
	@override String get done => 'Selesai Update';
	@override String get titleHint => 'Edit nama barang';
	@override String get addressHint => 'Edit lokasi';
	@override String get priceHint => 'Edit harga (Rp)';
	@override String get negotiable => 'Edit bisa nego';
	@override String get descriptionHint => 'Edit deskripsi';
	@override String get tagsHint => 'Tambah tag (tekan spasi untuk konfirmasi)';
	@override String get success => 'Produk berhasil diperbarui.';
	@override String get fail => 'Gagal mengupdate produk: {error}';
	@override String get resetLocation => 'Reset lokasi';
	@override String get save => 'Simpan perubahan';
}

// Path: marketplace.detail
class _TranslationsMarketplaceDetailId extends TranslationsMarketplaceDetailKo {
	_TranslationsMarketplaceDetailId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get makeOffer => 'Ajukan penawaran';
	@override String get fixedPrice => 'Harga tetap';
	@override String get description => 'Deskripsi produk';
	@override String get sellerInfo => 'Info penjual';
	@override String get chat => 'Chat';
	@override String get favorite => 'Favorit';
	@override String get unfavorite => 'Hapus favorit';
	@override String get share => 'Bagikan';
	@override String get edit => 'Edit';
	@override String get delete => 'Hapus';
	@override String get category => 'Kategori';
	@override String get categoryError => 'Kategori: -';
	@override String get categoryNone => 'Tidak ada kategori';
	@override String get views => 'Dilihat';
	@override String get likes => 'Suka';
	@override String get chats => 'Chat';
	@override String get noSeller => 'Info penjual tidak tersedia.';
	@override String get noLocation => 'Info lokasi tidak tersedia.';
	@override String get seller => 'Penjual';
	@override String get dealLocation => 'Lokasi transaksi';
}

// Path: marketplace.dialog
class _TranslationsMarketplaceDialogId extends TranslationsMarketplaceDialogKo {
	_TranslationsMarketplaceDialogId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get deleteTitle => 'Hapus postingan';
	@override String get deleteContent => 'Apakah Anda yakin ingin menghapus postingan ini? Tindakan ini tidak bisa dibatalkan.';
	@override String get cancel => 'Batal';
	@override String get deleteConfirm => 'Hapus';
	@override String get deleteSuccess => 'Postingan berhasil dihapus.';
	@override String get close => 'Tutup';
}

// Path: marketplace.errors
class _TranslationsMarketplaceErrorsId extends TranslationsMarketplaceErrorsKo {
	_TranslationsMarketplaceErrorsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get deleteError => 'Gagal menghapus postingan: {error}';
	@override String get requiredField => 'Kolom ini wajib diisi.';
	@override String get noPhoto => 'Tambahkan minimal 1 foto.';
	@override String get noCategory => 'Silakan pilih kategori.';
	@override String get loginRequired => 'Login diperlukan.';
	@override String get userNotFound => 'Data pengguna tidak ditemukan.';
}

// Path: marketplace.condition
class _TranslationsMarketplaceConditionId extends TranslationsMarketplaceConditionKo {
	_TranslationsMarketplaceConditionId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get label => 'Kondisi';
	@override String get kNew => 'Baru';
	@override String get used => 'Bekas';
}

// Path: marketplace.reservation
class _TranslationsMarketplaceReservationId extends TranslationsMarketplaceReservationKo {
	_TranslationsMarketplaceReservationId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pembayaran deposit 10%';
	@override String get content => 'Untuk memesan produk yang sudah diverifikasi AI, Anda perlu membayar deposit 10% sebesar {amount}. Jika transaksi dibatalkan setelah verifikasi di tempat, deposit akan dikembalikan.';
	@override String get confirm => 'Bayar & Pesan';
	@override String get button => 'Pesan dengan Jaminan AI';
	@override String get success => 'Reservasi berhasil. Silakan atur janji temu dengan penjual.';
}

// Path: marketplace.status
class _TranslationsMarketplaceStatusId extends TranslationsMarketplaceStatusKo {
	_TranslationsMarketplaceStatusId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get reserved => 'Dipesan';
	@override String get sold => 'Terjual';
}

// Path: marketplace.ai
class _TranslationsMarketplaceAiId extends TranslationsMarketplaceAiKo {
	_TranslationsMarketplaceAiId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get cancelConfirm => 'Batalkan verifikasi AI';
	@override String get cancelLimit => 'Verifikasi AI hanya dapat dibatalkan satu kali per produk. Permintaan ulang verifikasi AI dapat dikenakan biaya.';
	@override String get cancelAckCharge => 'Saya mengerti mungkin akan dikenakan biaya.';
	@override String get cancelSuccess => 'Verifikasi AI telah dibatalkan. Produk ini sekarang menjadi listing biasa.';
	@override String get cancelError => 'Terjadi kesalahan saat membatalkan verifikasi AI: {0}';
}

// Path: marketplace.takeover
class _TranslationsMarketplaceTakeoverId extends TranslationsMarketplaceTakeoverKo {
	_TranslationsMarketplaceTakeoverId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get button => 'Ambil & verifikasi di tempat';
	@override String get title => 'Verifikasi AI di Lokasi';
	@override late final _TranslationsMarketplaceTakeoverGuideId guide = _TranslationsMarketplaceTakeoverGuideId._(_root);
	@override String get photoTitle => 'Ambil foto di lokasi';
	@override String get buttonVerify => 'Mulai verifikasi kesesuaian AI';
	@override late final _TranslationsMarketplaceTakeoverErrorsId errors = _TranslationsMarketplaceTakeoverErrorsId._(_root);
	@override late final _TranslationsMarketplaceTakeoverDialogId dialog = _TranslationsMarketplaceTakeoverDialogId._(_root);
	@override late final _TranslationsMarketplaceTakeoverSuccessId success = _TranslationsMarketplaceTakeoverSuccessId._(_root);
}

// Path: aiFlow.common
class _TranslationsAiFlowCommonId extends TranslationsAiFlowCommonKo {
	_TranslationsAiFlowCommonId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get error => 'Terjadi kesalahan: {error}';
	@override String get addPhoto => 'Tambah foto';
	@override String get skip => 'Lewati';
	@override String get addedPhoto => 'Foto ditambahkan: {}';
	@override String get skipped => 'Dilewati';
}

// Path: aiFlow.cta
class _TranslationsAiFlowCtaId extends TranslationsAiFlowCtaKo {
	_TranslationsAiFlowCtaId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => '🤖 Tingkatkan kepercayaan dengan verifikasi AI (opsional)';
	@override String get subtitle => 'Dapatkan badge verifikasi AI untuk meningkatkan kepercayaan pembeli dan jual lebih cepat. Lengkapi semua info produk sebelum mulai.';
	@override String get startButton => 'Mulai verifikasi AI';
	@override String get missingRequiredFields => 'Masukkan nama barang, kategori, dan minimal satu gambar terlebih dahulu.';
}

// Path: aiFlow.categorySelection
class _TranslationsAiFlowCategorySelectionId extends TranslationsAiFlowCategorySelectionKo {
	_TranslationsAiFlowCategorySelectionId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Verifikasi AI: Pilih kategori';
	@override String get error => 'Gagal memuat kategori.';
	@override String get noCategories => 'Tidak ada kategori yang tersedia untuk verifikasi.';
}

// Path: aiFlow.galleryUpload
class _TranslationsAiFlowGalleryUploadId extends TranslationsAiFlowGalleryUploadKo {
	_TranslationsAiFlowGalleryUploadId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Verifikasi AI: Pilih foto';
	@override String get guide => 'Unggah minimal {count} foto untuk verifikasi.';
	@override String get minPhotoError => 'Anda harus memilih minimal {count} foto.';
	@override String get nextButton => 'Minta analisis AI';
}

// Path: aiFlow.prediction
class _TranslationsAiFlowPredictionId extends TranslationsAiFlowPredictionKo {
	_TranslationsAiFlowPredictionId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Hasil analisis AI';
	@override String get guide => 'Ini adalah nama barang yang diprediksi AI.';
	@override String get editLabel => 'Edit nama barang';
	@override String get editButton => 'Edit manual';
	@override String get saveButton => 'Simpan perubahan';
	@override String get noName => 'Tidak ada nama barang.';
	@override String get error => 'Barang tidak dapat dikenali. Silakan coba lagi.';
	@override String get authError => 'Info autentikasi pengguna tidak ditemukan. Analisis tidak dapat dimulai.';
	@override String get question => 'Apakah nama barang ini sudah benar?';
	@override String get confirmButton => 'Ya, benar';
	@override String get rejectButton => 'Tidak, kembali';
	@override String get analysisError => 'Terjadi kesalahan saat analisis.';
	@override String get retryButton => 'Coba lagi';
	@override String get backButton => 'Kembali';
}

// Path: aiFlow.guidedCamera
class _TranslationsAiFlowGuidedCameraId extends TranslationsAiFlowGuidedCameraKo {
	_TranslationsAiFlowGuidedCameraId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Panduan AI: bukti foto yang kurang';
	@override String get guide => 'Untuk meningkatkan kepercayaan, tambahkan foto sesuai saran berikut.';
	@override String get locationMismatchError => 'Lokasi foto tidak sama dengan lokasi Anda sekarang. Harap ambil foto di tempat yang sama.';
	@override String get locationPermissionError => 'Izin lokasi ditolak. Aktifkan izin lokasi di pengaturan.';
	@override String get noLocationDataError => 'Tidak ada data lokasi di foto. Aktifkan tag lokasi di pengaturan kamera.';
	@override String get nextButton => 'Buat laporan akhir';
}

// Path: aiFlow.finalReport
class _TranslationsAiFlowFinalReportId extends TranslationsAiFlowFinalReportKo {
	_TranslationsAiFlowFinalReportId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Laporan Verifikasi AI';
	@override String get guide => 'AI membuat draft listing. Edit konten lalu selesaikan pendaftaran.';
	@override String get loading => 'AI sedang membuat laporan akhir...';
	@override String get error => 'Gagal membuat laporan.';
	@override String get success => 'Laporan akhir berhasil dibuat.';
	@override String get submitButton => 'Daftarkan untuk dijual';
	@override String get suggestedPrice => 'Harga yang disarankan AI ({})';
	@override String get summary => 'Ringkasan verifikasi';
	@override String get buyerNotes => 'Catatan untuk pembeli (AI)';
	@override String get keySpecs => 'Spesifikasi utama';
	@override String get condition => 'Pemeriksaan kondisi';
	@override String get includedItems => 'Barang termasuk (pisahkan dengan koma)';
	@override String get finalDescription => 'Deskripsi akhir';
	@override String get applySuggestions => 'Terapkan saran ke deskripsi';
	@override String get includedItemsLabel => 'Barang termasuk';
	@override String get buyerNotesLabel => 'Catatan pembeli';
	@override String get skippedItems => 'Item bukti yang dilewati';
	@override String get fail => 'Gagal membuat laporan akhir: {error}';
}

// Path: aiFlow.evidence
class _TranslationsAiFlowEvidenceId extends TranslationsAiFlowEvidenceKo {
	_TranslationsAiFlowEvidenceId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get allShotsRequired => 'Semua foto yang disarankan wajib diunggah.';
	@override String get title => 'Foto bukti';
	@override String get submitButton => 'Kirim bukti';
}

// Path: aiFlow.error
class _TranslationsAiFlowErrorId extends TranslationsAiFlowErrorKo {
	_TranslationsAiFlowErrorId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get reportGeneration => 'Gagal membuat laporan AI: {error}';
}

// Path: myBling.stats
class _TranslationsMyBlingStatsId extends TranslationsMyBlingStatsKo {
	_TranslationsMyBlingStatsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get posts => 'Postingan';
	@override String get followers => 'Pengikut';
	@override String get neighbors => 'Tetangga';
	@override String get friends => 'Teman';
}

// Path: myBling.tabs
class _TranslationsMyBlingTabsId extends TranslationsMyBlingTabsKo {
	_TranslationsMyBlingTabsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get posts => 'Postingan saya';
	@override String get products => 'Produk saya';
	@override String get bookmarks => 'Bookmark';
	@override String get friends => 'Teman';
}

// Path: profileView.tabs
class _TranslationsProfileViewTabsId extends TranslationsProfileViewTabsKo {
	_TranslationsProfileViewTabsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get posts => 'Postingan';
	@override String get interests => 'Minat';
}

// Path: settings.notifications
class _TranslationsSettingsNotificationsId extends TranslationsSettingsNotificationsKo {
	_TranslationsSettingsNotificationsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get loadError => 'Gagal memuat pengaturan notifikasi.';
	@override String get saveSuccess => 'Pengaturan notifikasi berhasil disimpan.';
	@override String get saveError => 'Gagal menyimpan pengaturan notifikasi.';
	@override String get scopeTitle => 'Jangkauan notifikasi';
	@override String get scopeDescription => 'Pilih seberapa luas notifikasi yang ingin diterima (hanya lingkungan saya, area sekitar, dll.).';
	@override String get scopeLabel => 'Jangkauan notifikasi';
	@override String get tagsTitle => 'Topik notifikasi';
	@override String get tagsDescription => 'Pilih topik apa saja yang ingin Anda terima (berita, kerja, marketplace, dll.).';
}

// Path: friendRequests.tooltip
class _TranslationsFriendRequestsTooltipId extends TranslationsFriendRequestsTooltipKo {
	_TranslationsFriendRequestsTooltipId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get accept => 'Terima';
	@override String get reject => 'Tolak';
}

// Path: sentFriendRequests.status
class _TranslationsSentFriendRequestsStatusId extends TranslationsSentFriendRequestsStatusKo {
	_TranslationsSentFriendRequestsStatusId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get pending => 'Menunggu';
	@override String get accepted => 'Diterima';
	@override String get rejected => 'Ditolak';
}

// Path: blockedUsers.unblockDialog
class _TranslationsBlockedUsersUnblockDialogId extends TranslationsBlockedUsersUnblockDialogKo {
	_TranslationsBlockedUsersUnblockDialogId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Buka blokir {nickname}?';
	@override String get content => 'Setelah dibuka blokirnya, pengguna ini bisa muncul lagi di daftar Find Friends Anda.';
}

// Path: rejectedUsers.unrejectDialog
class _TranslationsRejectedUsersUnrejectDialogId extends TranslationsRejectedUsersUnrejectDialogKo {
	_TranslationsRejectedUsersUnrejectDialogId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Batalkan penolakan untuk {nickname}?';
	@override String get content => 'Jika dibatalkan, Anda bisa muncul lagi di daftar Find Friends mereka.';
}

// Path: profileEdit.interests
class _TranslationsProfileEditInterestsId extends TranslationsProfileEditInterestsKo {
	_TranslationsProfileEditInterestsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Minat';
	@override String get hint => 'Gunakan koma dan Enter untuk menambahkan beberapa item';
}

// Path: profileEdit.privacy
class _TranslationsProfileEditPrivacyId extends TranslationsProfileEditPrivacyKo {
	_TranslationsProfileEditPrivacyId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pengaturan privasi';
	@override String get showLocation => 'Tampilkan lokasi saya di peta';
	@override String get allowRequests => 'Izinkan permintaan pertemanan';
}

// Path: profileEdit.errors
class _TranslationsProfileEditErrorsId extends TranslationsProfileEditErrorsKo {
	_TranslationsProfileEditErrorsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get noUser => 'Tidak ada pengguna yang login.';
	@override String get updateFailed => 'Gagal memperbarui profil: {error}';
}

// Path: categories.post
class _TranslationsCategoriesPostId extends TranslationsCategoriesPostKo {
	_TranslationsCategoriesPostId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsCategoriesPostJalanPerbaikinId jalanPerbaikin = _TranslationsCategoriesPostJalanPerbaikinId._(_root);
	@override late final _TranslationsCategoriesPostDailyLifeId dailyLife = _TranslationsCategoriesPostDailyLifeId._(_root);
	@override late final _TranslationsCategoriesPostHelpShareId helpShare = _TranslationsCategoriesPostHelpShareId._(_root);
	@override late final _TranslationsCategoriesPostIncidentReportId incidentReport = _TranslationsCategoriesPostIncidentReportId._(_root);
	@override late final _TranslationsCategoriesPostLocalNewsId localNews = _TranslationsCategoriesPostLocalNewsId._(_root);
	@override late final _TranslationsCategoriesPostNovemberId november = _TranslationsCategoriesPostNovemberId._(_root);
	@override late final _TranslationsCategoriesPostRainId rain = _TranslationsCategoriesPostRainId._(_root);
	@override late final _TranslationsCategoriesPostDailyQuestionId dailyQuestion = _TranslationsCategoriesPostDailyQuestionId._(_root);
	@override late final _TranslationsCategoriesPostStorePromoId storePromo = _TranslationsCategoriesPostStorePromoId._(_root);
	@override late final _TranslationsCategoriesPostEtcId etc = _TranslationsCategoriesPostEtcId._(_root);
}

// Path: categories.auction
class _TranslationsCategoriesAuctionId extends TranslationsCategoriesAuctionKo {
	_TranslationsCategoriesAuctionId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get all => 'Semua';
	@override late final _TranslationsCategoriesAuctionCollectiblesId collectibles = _TranslationsCategoriesAuctionCollectiblesId._(_root);
	@override late final _TranslationsCategoriesAuctionDigitalId digital = _TranslationsCategoriesAuctionDigitalId._(_root);
	@override late final _TranslationsCategoriesAuctionFashionId fashion = _TranslationsCategoriesAuctionFashionId._(_root);
	@override late final _TranslationsCategoriesAuctionVintageId vintage = _TranslationsCategoriesAuctionVintageId._(_root);
	@override late final _TranslationsCategoriesAuctionArtCraftId artCraft = _TranslationsCategoriesAuctionArtCraftId._(_root);
	@override late final _TranslationsCategoriesAuctionEtcId etc = _TranslationsCategoriesAuctionEtcId._(_root);
}

// Path: localNewsCreate.form
class _TranslationsLocalNewsCreateFormId extends TranslationsLocalNewsCreateFormKo {
	_TranslationsLocalNewsCreateFormId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get categoryLabel => 'Kategori';
	@override String get titleLabel => 'Judul';
	@override String get contentLabel => 'Tulis konten';
	@override String get tagsLabel => 'Tag';
	@override String get tagsHint => 'Tambahkan tag (tekan spasi untuk konfirmasi)';
	@override String get recommendedTags => 'Tag yang disarankan';
}

// Path: localNewsCreate.labels
class _TranslationsLocalNewsCreateLabelsId extends TranslationsLocalNewsCreateLabelsKo {
	_TranslationsLocalNewsCreateLabelsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Judul';
	@override String get body => 'Konten';
	@override String get tags => 'Tag';
	@override String get guidedTitle => 'Info tambahan (opsional)';
	@override String get eventLocation => 'Lokasi acara/kejadian';
}

// Path: localNewsCreate.hints
class _TranslationsLocalNewsCreateHintsId extends TranslationsLocalNewsCreateHintsKo {
	_TranslationsLocalNewsCreateHintsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get body => 'Bagikan berita lingkungan atau ajukan pertanyaan ke tetangga...';
	@override String get tagSelection => '(Pilih 1–3 tag)';
	@override String get eventLocation => 'mis. Jl. Sudirman 123';
}

// Path: localNewsCreate.validation
class _TranslationsLocalNewsCreateValidationId extends TranslationsLocalNewsCreateValidationKo {
	_TranslationsLocalNewsCreateValidationId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get bodyRequired => 'Silakan isi konten.';
	@override String get tagRequired => 'Silakan pilih minimal satu tag.';
	@override String get tagMaxLimit => 'Anda bisa memilih maksimal 3 tag.';
	@override String get imageMaxLimit => 'Anda bisa melampirkan maksimal 5 gambar.';
	@override String get titleRequired => 'Silakan masukkan judul.';
}

// Path: localNewsCreate.buttons
class _TranslationsLocalNewsCreateButtonsId extends TranslationsLocalNewsCreateButtonsKo {
	_TranslationsLocalNewsCreateButtonsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get addImage => 'Tambah gambar';
	@override String get submit => 'Kirim';
}

// Path: localNewsCreate.alerts
class _TranslationsLocalNewsCreateAlertsId extends TranslationsLocalNewsCreateAlertsKo {
	_TranslationsLocalNewsCreateAlertsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get contentRequired => 'Silakan isi konten.';
	@override String get categoryRequired => 'Silakan pilih kategori.';
	@override String get success => 'Postingan berhasil dibuat.';
	@override String get failure => 'Gagal mengunggah: {error}';
	@override String get loginRequired => 'Anda harus login untuk membuat postingan.';
	@override String get userNotFound => 'Info pengguna tidak ditemukan.';
}

// Path: localNewsDetail.menu
class _TranslationsLocalNewsDetailMenuId extends TranslationsLocalNewsDetailMenuKo {
	_TranslationsLocalNewsDetailMenuId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get edit => 'Edit';
	@override String get report => 'Laporkan';
	@override String get share => 'Bagikan';
}

// Path: localNewsDetail.stats
class _TranslationsLocalNewsDetailStatsId extends TranslationsLocalNewsDetailStatsKo {
	_TranslationsLocalNewsDetailStatsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get views => 'Dilihat';
	@override String get comments => 'Komentar';
	@override String get likes => 'Suka';
	@override String get thanks => 'Terima kasih';
}

// Path: localNewsDetail.buttons
class _TranslationsLocalNewsDetailButtonsId extends TranslationsLocalNewsDetailButtonsKo {
	_TranslationsLocalNewsDetailButtonsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get comment => 'Tambah komentar';
}

// Path: localNewsEdit.buttons
class _TranslationsLocalNewsEditButtonsId extends TranslationsLocalNewsEditButtonsKo {
	_TranslationsLocalNewsEditButtonsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get submit => 'Perbarui';
}

// Path: localNewsEdit.alerts
class _TranslationsLocalNewsEditAlertsId extends TranslationsLocalNewsEditAlertsKo {
	_TranslationsLocalNewsEditAlertsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get success => 'Postingan berhasil diperbarui.';
	@override String get failure => 'Gagal memperbarui: {error}';
}

// Path: commentInputField.button
class _TranslationsCommentInputFieldButtonId extends TranslationsCommentInputFieldButtonKo {
	_TranslationsCommentInputFieldButtonId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get send => 'Kirim';
}

// Path: common.sort
class _TranslationsCommonSortId extends TranslationsCommonSortKo {
	_TranslationsCommonSortId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get kDefault => 'Default';
	@override String get distance => 'Jarak';
	@override String get popular => 'Populer';
}

// Path: replyInputField.button
class _TranslationsReplyInputFieldButtonId extends TranslationsReplyInputFieldButtonKo {
	_TranslationsReplyInputFieldButtonId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get send => 'Kirim';
}

// Path: jobs.screen
class _TranslationsJobsScreenId extends TranslationsJobsScreenKo {
	_TranslationsJobsScreenId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get empty => 'Belum ada lowongan kerja di area ini.';
	@override String get createTooltip => 'Pasang lowongan';
}

// Path: jobs.tabs
class _TranslationsJobsTabsId extends TranslationsJobsTabsKo {
	_TranslationsJobsTabsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get all => 'Semua';
	@override String get quickGig => 'Gig singkat';
	@override String get regular => 'Paruh waktu/Penuh waktu';
}

// Path: jobs.selectType
class _TranslationsJobsSelectTypeId extends TranslationsJobsSelectTypeKo {
	_TranslationsJobsSelectTypeId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pilih jenis lowongan';
	@override String get regularTitle => 'Lowongan paruh waktu / penuh waktu';
	@override String get regularDesc => 'Pekerjaan reguler seperti kafe, restoran, kantor';
	@override String get quickGigTitle => 'Gig singkat / bantuan sederhana';
	@override String get quickGigDesc => 'Antar dokumen, pindahan, bersih-bersih, dan lain-lain';
}

// Path: jobs.form
class _TranslationsJobsFormId extends TranslationsJobsFormKo {
	_TranslationsJobsFormId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Pasang lowongan kerja';
	@override String get titleHint => 'Judul lowongan';
	@override String get descriptionPositionHint => 'Jelaskan posisi yang dicari';
	@override String get categoryHint => 'Kategori';
	@override String get categorySelectHint => 'Pilih kategori';
	@override String get categoryValidator => 'Silakan pilih kategori.';
	@override String get locationHint => 'Lokasi kerja';
	@override String get submit => 'Pasang lowongan';
	@override String get titleLabel => 'Judul';
	@override String get titleValidator => 'Silakan masukkan judul.';
	@override String get titleRegular => 'Pasang lowongan paruh waktu/penuh waktu';
	@override String get titleQuickGig => 'Pasang gig singkat';
	@override String get validationError => 'Silakan isi semua kolom wajib.';
	@override String get saveSuccess => 'Lowongan kerja berhasil disimpan.';
	@override String get saveError => 'Gagal menyimpan lowongan kerja: {error}';
	@override String get categoryLabel => 'Kategori';
	@override String get titleHintQuickGig => 'mis. Antar dokumen pakai motor (ASAP)';
	@override String get salaryLabel => 'Gaji (IDR)';
	@override String get salaryHint => 'Masukkan jumlah gaji';
	@override String get salaryValidator => 'Silakan masukkan jumlah gaji yang valid.';
	@override String get totalPayLabel => 'Total bayaran (IDR)';
	@override String get totalPayHint => 'Masukkan total bayaran yang ditawarkan';
	@override String get totalPayValidator => 'Silakan masukkan jumlah yang valid.';
	@override String get negotiable => 'Bisa nego';
	@override String get workPeriodLabel => 'Periode kerja';
	@override String get workPeriodHint => 'Pilih periode kerja';
	@override String get locationLabel => 'Lokasi / tempat kerja';
	@override String get locationValidator => 'Silakan masukkan lokasi.';
	@override String get imageLabel => 'Gambar (Opsional, maks 10)';
	@override String get descriptionHintQuickGig => 'Tulis detailnya (mis. titik jemput, tujuan, permintaan khusus).';
	@override String get salaryInfoTitle => 'Info gaji';
	@override String get salaryTypeHint => 'Jenis pembayaran';
	@override String get salaryAmountLabel => 'Nominal (IDR)';
	@override String get salaryNegotiable => 'Gaji bisa dinegosiasikan';
	@override String get workInfoTitle => 'Syarat kerja';
	@override String get workPeriodTitle => 'Periode kerja';
	@override String get workHoursLabel => 'Hari/Jam kerja';
	@override String get workHoursHint => 'mis. Senin–Jumat, 09.00–18.00';
	@override String get imageSectionTitle => 'Lampirkan foto (opsional, maks 5)';
	@override String get descriptionLabel => 'Deskripsi';
	@override String get descriptionHint => 'mis. Part-time 3 hari seminggu, jam 5–10 sore. Gaji bisa nego.';
	@override String get descriptionValidator => 'Silakan masukkan deskripsi.';
	@override String get submitSuccess => 'Lowongan kerja berhasil dipasang.';
	@override String get submitFail => 'Gagal memasang lowongan kerja: {error}';
}

// Path: jobs.categories
class _TranslationsJobsCategoriesId extends TranslationsJobsCategoriesKo {
	_TranslationsJobsCategoriesId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get restaurant => 'Restoran';
	@override String get cafe => 'Kafe';
	@override String get retail => 'Ritel/Toko';
	@override String get delivery => 'Kurir/Antar';
	@override String get etc => 'Lainnya';
	@override String get service => 'Jasa/Service';
	@override String get salesMarketing => 'Sales/Marketing';
	@override String get deliveryLogistics => 'Pengiriman/Logistik';
	@override String get it => 'IT/Teknologi';
	@override String get design => 'Desain';
	@override String get education => 'Pendidikan';
	@override String get quickGigDelivery => 'Antar barang pakai motor';
	@override String get quickGigTransport => 'Antar orang pakai motor (ojek)';
	@override String get quickGigMoving => 'Bantu pindahan';
	@override String get quickGigCleaning => 'Bersih-bersih/Rumah tangga';
	@override String get quickGigQueuing => 'Antri menggantikan';
	@override String get quickGigEtc => 'Jasa titip/bantuan lainnya';
}

// Path: jobs.salaryTypes
class _TranslationsJobsSalaryTypesId extends TranslationsJobsSalaryTypesKo {
	_TranslationsJobsSalaryTypesId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get hourly => 'Per jam';
	@override String get daily => 'Harian';
	@override String get weekly => 'Mingguan';
	@override String get monthly => 'Bulanan';
	@override String get total => 'Total';
	@override String get perCase => 'Per kasus';
	@override String get etc => 'Lainnya';
	@override String get yearly => 'Tahunan';
}

// Path: jobs.workPeriods
class _TranslationsJobsWorkPeriodsId extends TranslationsJobsWorkPeriodsKo {
	_TranslationsJobsWorkPeriodsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get shortTerm => 'Jangka pendek';
	@override String get midTerm => 'Jangka menengah';
	@override String get longTerm => 'Jangka panjang';
	@override String get oneTime => 'Satu kali';
	@override String get k1Week => '1 minggu';
	@override String get k1Month => '1 bulan';
	@override String get k3Months => '3 bulan';
	@override String get k6MonthsPlus => '6 bulan ke atas';
	@override String get negotiable => 'Bisa dinegosiasikan';
	@override String get etc => 'Lainnya';
}

// Path: jobs.detail
class _TranslationsJobsDetailId extends TranslationsJobsDetailKo {
	_TranslationsJobsDetailId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get infoTitle => 'Detail';
	@override String get apply => 'Lamar';
	@override String get noAuthor => 'Info pembuat tidak tersedia';
	@override String get chatError => 'Tidak dapat memulai chat: {error}';
}

// Path: jobs.card
class _TranslationsJobsCardId extends TranslationsJobsCardKo {
	_TranslationsJobsCardId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get noLocation => 'Lokasi tidak tersedia';
	@override String get minutesAgo => 'menit lalu';
}

// Path: jobs.findFriend
class _TranslationsJobsFindFriendId extends TranslationsJobsFindFriendKo {
	_TranslationsJobsFindFriendId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Cari Teman';
	@override late final _TranslationsJobsFindFriendTabsId tabs = _TranslationsJobsFindFriendTabsId._(_root);
	@override String get editTitle => 'Edit Profil Cari Teman';
	@override String get editProfileTitle => 'Edit Profil';
	@override String get save => 'Simpan';
	@override String get profileImagesLabel => 'Foto Profil (maks 6)';
	@override String get bioLabel => 'Bio';
	@override String get bioHint => 'Perkenalkan diri Anda kepada orang lain.';
	@override String get bioValidator => 'Silakan isi bio.';
	@override String get ageLabel => 'Usia';
	@override String get ageHint => 'Masukkan usia Anda.';
	@override String get genderLabel => 'Jenis kelamin';
	@override String get genderMale => 'Pria';
	@override String get genderFemale => 'Wanita';
	@override String get genderHint => 'Pilih jenis kelamin';
	@override String get interestsLabel => 'Minat';
	@override String get preferredAgeLabel => 'Usia teman yang diinginkan';
	@override String get preferredAgeUnit => 'thn';
	@override String get preferredGenderLabel => 'Jenis kelamin teman yang diinginkan';
	@override String get preferredGenderAll => 'Semua';
	@override String get showProfileLabel => 'Tampilkan profil saya di daftar';
	@override String get showProfileSubtitle => 'Jika dimatikan, orang lain tidak bisa menemukan Anda.';
	@override String get saveSuccess => 'Profil berhasil disimpan!';
	@override String get saveFailed => 'Gagal menyimpan profil:';
	@override String get loginRequired => 'Login diperlukan.';
	@override String get noFriendsFound => 'Belum ada teman terdekat yang ditemukan.';
	@override String get promptTitle => 'Untuk bertemu teman baru,\nbuat profil Anda terlebih dahulu!';
	@override String get promptButton => 'Buat Profil Saya';
	@override String get chatLimitReached => 'Anda telah mencapai batas harian ({limit}) untuk memulai chat baru.';
	@override String get chatChecking => 'Memeriksa...';
	@override String get empty => 'Belum ada profil untuk ditampilkan.';
}

// Path: jobs.interests
class _TranslationsJobsInterestsId extends TranslationsJobsInterestsKo {
	_TranslationsJobsInterestsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Minat';
	@override String get limitInfo => 'Anda bisa memilih hingga 10 minat.';
	@override String get limitReached => 'Anda hanya bisa memilih hingga 10 minat.';
	@override String get categoryCreative => '🎨 Kreatif';
	@override String get categorySports => '🏃 Olahraga & Aktivitas';
	@override String get categoryFoodDrink => '🍸 Makanan & Minuman';
	@override String get categoryEntertainment => '🍿 Hiburan';
	@override String get categoryGrowth => '📚 Pengembangan diri';
	@override String get categoryLifestyle => '🌴 Gaya hidup';
	@override late final _TranslationsJobsInterestsItemsId items = _TranslationsJobsInterestsItemsId._(_root);
}

// Path: jobs.friendDetail
class _TranslationsJobsFriendDetailId extends TranslationsJobsFriendDetailKo {
	_TranslationsJobsFriendDetailId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get request => 'Kirim permintaan';
	@override String get requestSent => 'Dikirim';
	@override String get alreadyFriends => 'Sudah berteman';
	@override String get requestFailed => 'Gagal mengirim permintaan:';
	@override String get chatError => 'Tidak dapat memulai chat.';
	@override String get startChat => 'Mulai chat';
	@override String get block => 'Blokir';
	@override String get report => 'Laporkan';
	@override String get loginRequired => 'Login diperlukan.';
	@override String get unblocked => 'Pengguna telah dibuka blokirnya.';
	@override String get blocked => 'Pengguna telah diblokir.';
	@override String get unblock => 'Buka blokir';
}

// Path: jobs.locationFilter
class _TranslationsJobsLocationFilterId extends TranslationsJobsLocationFilterKo {
	_TranslationsJobsLocationFilterId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Filter lokasi';
	@override String get provinsi => 'Provinsi';
	@override String get kabupaten => 'Kabupaten';
	@override String get kota => 'Kota';
	@override String get kecamatan => 'Kecamatan';
	@override String get kelurahan => 'Kelurahan';
	@override String get apply => 'Terapkan filter';
	@override String get all => 'Semua';
	@override String get reset => 'Reset';
}

// Path: jobs.clubs
class _TranslationsJobsClubsId extends TranslationsJobsClubsKo {
	_TranslationsJobsClubsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsJobsClubsTabsId tabs = _TranslationsJobsClubsTabsId._(_root);
	@override late final _TranslationsJobsClubsSectionsId sections = _TranslationsJobsClubsSectionsId._(_root);
	@override late final _TranslationsJobsClubsScreenId screen = _TranslationsJobsClubsScreenId._(_root);
	@override late final _TranslationsJobsClubsPostListId postList = _TranslationsJobsClubsPostListId._(_root);
	@override late final _TranslationsJobsClubsMemberCardId memberCard = _TranslationsJobsClubsMemberCardId._(_root);
	@override late final _TranslationsJobsClubsPostCardId postCard = _TranslationsJobsClubsPostCardId._(_root);
	@override late final _TranslationsJobsClubsCardId card = _TranslationsJobsClubsCardId._(_root);
	@override late final _TranslationsJobsClubsPostDetailId postDetail = _TranslationsJobsClubsPostDetailId._(_root);
	@override late final _TranslationsJobsClubsDetailId detail = _TranslationsJobsClubsDetailId._(_root);
	@override late final _TranslationsJobsClubsMemberListId memberList = _TranslationsJobsClubsMemberListId._(_root);
	@override late final _TranslationsJobsClubsCreatePostId createPost = _TranslationsJobsClubsCreatePostId._(_root);
	@override late final _TranslationsJobsClubsCreateClubId createClub = _TranslationsJobsClubsCreateClubId._(_root);
	@override late final _TranslationsJobsClubsEditClubId editClub = _TranslationsJobsClubsEditClubId._(_root);
	@override late final _TranslationsJobsClubsCreateId create = _TranslationsJobsClubsCreateId._(_root);
	@override late final _TranslationsJobsClubsRepositoryId repository = _TranslationsJobsClubsRepositoryId._(_root);
	@override late final _TranslationsJobsClubsProposalId proposal = _TranslationsJobsClubsProposalId._(_root);
	@override String get empty => 'Tidak ada klub untuk ditampilkan.';
}

// Path: jobs.findfriend
class _TranslationsJobsFindfriendId extends TranslationsJobsFindfriendKo {
	_TranslationsJobsFindfriendId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsJobsFindfriendFormId form = _TranslationsJobsFindfriendFormId._(_root);
}

// Path: jobs.auctions
class _TranslationsJobsAuctionsId extends TranslationsJobsAuctionsKo {
	_TranslationsJobsAuctionsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsJobsAuctionsCardId card = _TranslationsJobsAuctionsCardId._(_root);
	@override late final _TranslationsJobsAuctionsErrorsId errors = _TranslationsJobsAuctionsErrorsId._(_root);
	@override String get empty => 'Belum ada lelang.';
	@override late final _TranslationsJobsAuctionsFilterId filter = _TranslationsJobsAuctionsFilterId._(_root);
	@override late final _TranslationsJobsAuctionsCreateId create = _TranslationsJobsAuctionsCreateId._(_root);
	@override late final _TranslationsJobsAuctionsEditId edit = _TranslationsJobsAuctionsEditId._(_root);
	@override late final _TranslationsJobsAuctionsFormId form = _TranslationsJobsAuctionsFormId._(_root);
	@override late final _TranslationsJobsAuctionsDeleteId delete = _TranslationsJobsAuctionsDeleteId._(_root);
	@override late final _TranslationsJobsAuctionsDetailId detail = _TranslationsJobsAuctionsDetailId._(_root);
}

// Path: jobs.localStores
class _TranslationsJobsLocalStoresId extends TranslationsJobsLocalStoresKo {
	_TranslationsJobsLocalStoresId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get setLocationPrompt => 'Atur lokasi Anda untuk melihat toko terdekat.';
	@override String get empty => 'Belum ada toko.';
	@override String get error => 'Terjadi kesalahan: {error}';
	@override late final _TranslationsJobsLocalStoresCreateId create = _TranslationsJobsLocalStoresCreateId._(_root);
	@override late final _TranslationsJobsLocalStoresEditId edit = _TranslationsJobsLocalStoresEditId._(_root);
	@override late final _TranslationsJobsLocalStoresFormId form = _TranslationsJobsLocalStoresFormId._(_root);
	@override late final _TranslationsJobsLocalStoresCategoriesId categories = _TranslationsJobsLocalStoresCategoriesId._(_root);
	@override late final _TranslationsJobsLocalStoresDetailId detail = _TranslationsJobsLocalStoresDetailId._(_root);
	@override String get noLocation => 'Tidak ada info lokasi';
}

// Path: jobs.pom
class _TranslationsJobsPomId extends TranslationsJobsPomKo {
	_TranslationsJobsPomId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'POM';
	@override late final _TranslationsJobsPomSearchId search = _TranslationsJobsPomSearchId._(_root);
	@override late final _TranslationsJobsPomTabsId tabs = _TranslationsJobsPomTabsId._(_root);
	@override String get more => 'Lihat lebih banyak';
	@override String get less => 'Tutup';
	@override String get likesCount => '{} suka';
	@override String get report => 'Laporkan {}';
	@override String get block => 'Blokir {}';
	@override String get emptyPopular => 'Belum ada POM populer.';
	@override String get emptyMine => 'Anda belum mengunggah POM.';
	@override String get emptyHintPopular => 'Coba lihat tab \'Semua\' untuk POM terbaru.';
	@override String get emptyCtaMine => 'Tekan + untuk mengunggah POM pertama Anda.';
	@override String get share => 'Bagikan';
	@override String get empty => 'Belum ada POM.';
	@override late final _TranslationsJobsPomErrorsId errors = _TranslationsJobsPomErrorsId._(_root);
	@override late final _TranslationsJobsPomCommentsId comments = _TranslationsJobsPomCommentsId._(_root);
	@override late final _TranslationsJobsPomCreateId create = _TranslationsJobsPomCreateId._(_root);
}

// Path: jobs.realEstate
class _TranslationsJobsRealEstateId extends TranslationsJobsRealEstateKo {
	_TranslationsJobsRealEstateId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Properti';
	@override late final _TranslationsJobsRealEstateTabsId tabs = _TranslationsJobsRealEstateTabsId._(_root);
	@override String get setLocationPrompt => 'Atur lokasi Anda untuk melihat properti terdekat.';
	@override String get empty => 'Belum ada daftar properti.';
	@override String get error => 'Terjadi kesalahan: {error}';
	@override late final _TranslationsJobsRealEstateCreateId create = _TranslationsJobsRealEstateCreateId._(_root);
	@override late final _TranslationsJobsRealEstateEditId edit = _TranslationsJobsRealEstateEditId._(_root);
	@override late final _TranslationsJobsRealEstateFormId form = _TranslationsJobsRealEstateFormId._(_root);
	@override late final _TranslationsJobsRealEstateCategoriesId categories = _TranslationsJobsRealEstateCategoriesId._(_root);
	@override late final _TranslationsJobsRealEstateDetailId detail = _TranslationsJobsRealEstateDetailId._(_root);
}

// Path: jobs.lostAndFound
class _TranslationsJobsLostAndFoundId extends TranslationsJobsLostAndFoundKo {
	_TranslationsJobsLostAndFoundId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Hilang & Temuan';
	@override late final _TranslationsJobsLostAndFoundTabsId tabs = _TranslationsJobsLostAndFoundTabsId._(_root);
	@override String get empty => 'Belum ada laporan.';
	@override String get setLocationPrompt => 'Atur lokasi Anda untuk melihat laporan sekitar.';
	@override late final _TranslationsJobsLostAndFoundCreateId create = _TranslationsJobsLostAndFoundCreateId._(_root);
	@override late final _TranslationsJobsLostAndFoundEditId edit = _TranslationsJobsLostAndFoundEditId._(_root);
	@override late final _TranslationsJobsLostAndFoundFormId form = _TranslationsJobsLostAndFoundFormId._(_root);
	@override late final _TranslationsJobsLostAndFoundCategoriesId categories = _TranslationsJobsLostAndFoundCategoriesId._(_root);
	@override late final _TranslationsJobsLostAndFoundDetailId detail = _TranslationsJobsLostAndFoundDetailId._(_root);
}

// Path: jobs.community
class _TranslationsJobsCommunityId extends TranslationsJobsCommunityKo {
	_TranslationsJobsCommunityId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Komunitas';
	@override String get empty => 'Belum ada postingan.';
	@override String get error => 'Terjadi kesalahan: {error}';
	@override late final _TranslationsJobsCommunityCreateId create = _TranslationsJobsCommunityCreateId._(_root);
	@override late final _TranslationsJobsCommunityEditId edit = _TranslationsJobsCommunityEditId._(_root);
	@override late final _TranslationsJobsCommunityPostId post = _TranslationsJobsCommunityPostId._(_root);
}

// Path: jobs.shared
class _TranslationsJobsSharedId extends TranslationsJobsSharedKo {
	_TranslationsJobsSharedId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsJobsSharedTagInputId tagInput = _TranslationsJobsSharedTagInputId._(_root);
}

// Path: jobs.linkPreview
class _TranslationsJobsLinkPreviewId extends TranslationsJobsLinkPreviewKo {
	_TranslationsJobsLinkPreviewId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get errorTitle => 'Tidak dapat memuat pratinjau';
	@override String get errorBody => 'Periksa tautannya atau coba lagi nanti.';
}

// Path: jobs.localNewsTagResult
class _TranslationsJobsLocalNewsTagResultId extends TranslationsJobsLocalNewsTagResultKo {
	_TranslationsJobsLocalNewsTagResultId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get error => 'Terjadi kesalahan saat mencari: {error}';
	@override String get empty => 'Tidak ada postingan dengan tag \'#{tag}\'.';
}

// Path: jobs.admin
class _TranslationsJobsAdminId extends TranslationsJobsAdminKo {
	_TranslationsJobsAdminId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsJobsAdminScreenId screen = _TranslationsJobsAdminScreenId._(_root);
	@override late final _TranslationsJobsAdminMenuId menu = _TranslationsJobsAdminMenuId._(_root);
	@override late final _TranslationsJobsAdminAiApprovalId aiApproval = _TranslationsJobsAdminAiApprovalId._(_root);
	@override late final _TranslationsJobsAdminReportsId reports = _TranslationsJobsAdminReportsId._(_root);
	@override late final _TranslationsJobsAdminReportListId reportList = _TranslationsJobsAdminReportListId._(_root);
	@override late final _TranslationsJobsAdminReportDetailId reportDetail = _TranslationsJobsAdminReportDetailId._(_root);
}

// Path: jobs.tags
class _TranslationsJobsTagsId extends TranslationsJobsTagsKo {
	_TranslationsJobsTagsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsJobsTagsLocalNewsId localNews = _TranslationsJobsTagsLocalNewsId._(_root);
}

// Path: jobs.boards
class _TranslationsJobsBoardsId extends TranslationsJobsBoardsKo {
	_TranslationsJobsBoardsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsJobsBoardsPopupId popup = _TranslationsJobsBoardsPopupId._(_root);
	@override String get defaultTitle => 'Papan';
	@override String get chatRoomComingSoon => 'Ruang chat segera hadir';
	@override String get chatRoomTitle => 'Ruang Chat';
	@override String get emptyFeed => 'Belum ada postingan.';
	@override String get chatRoomCreated => 'Ruang chat telah dibuat.';
}

// Path: jobs.signup
class _TranslationsJobsSignupId extends TranslationsJobsSignupKo {
	_TranslationsJobsSignupId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsJobsSignupAlertsId alerts = _TranslationsJobsSignupAlertsId._(_root);
	@override String get title => 'Daftar';
	@override String get subtitle => 'Bergabunglah dengan komunitas lingkungan Anda!';
	@override String get nicknameHint => 'Nama panggilan';
	@override String get emailHint => 'Alamat email';
	@override String get passwordHint => 'Kata sandi';
	@override String get passwordConfirmHint => 'Konfirmasi kata sandi';
	@override String get locationHint => 'Lokasi';
	@override String get locationNotice => 'Lokasi Anda hanya digunakan untuk menampilkan postingan lokal dan tidak dibagikan.';
	@override late final _TranslationsJobsSignupButtonsId buttons = _TranslationsJobsSignupButtonsId._(_root);
}

// Path: jobs.user
class _TranslationsJobsUserId extends TranslationsJobsUserKo {
	_TranslationsJobsUserId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get notLoggedIn => 'Belum login.';
}

// Path: main.search.hint
class _TranslationsMainSearchHintId extends TranslationsMainSearchHintKo {
	_TranslationsMainSearchHintId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get globalSheet => 'Cari di {}';
	@override String get localNews => 'Cari judul, isi, tag';
	@override String get jobs => 'Cari pekerjaan, perusahaan, \'Bantu Saya\'';
	@override String get lostAndFound => 'Cari barang hilang/temuan';
	@override String get marketplace => 'Cari barang jual';
	@override String get localStores => 'Cari toko atau layanan';
	@override String get findFriends => 'Cari profil, minat';
	@override String get clubs => 'Cari klub, minat, lokasi';
	@override String get realEstate => 'Cari properti, area, harga';
	@override String get auction => 'Cari barang lelang, merek';
	@override String get pom => 'Cari POM, tag, pengguna';
}

// Path: drawer.trustDashboard.breakdown
class _TranslationsDrawerTrustDashboardBreakdownId extends TranslationsDrawerTrustDashboardBreakdownKo {
	_TranslationsDrawerTrustDashboardBreakdownId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

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
class _TranslationsMarketplaceTakeoverGuideId extends TranslationsMarketplaceTakeoverGuideKo {
	_TranslationsMarketplaceTakeoverGuideId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Verifikasi kesesuaian di lokasi dengan AI';
	@override String get subtitle => 'Pastikan barang di lokasi sama dengan yang ada di laporan AI. Ambil minimal 3 foto yang jelas menunjukkan ciri utama barang.';
}

// Path: marketplace.takeover.errors
class _TranslationsMarketplaceTakeoverErrorsId extends TranslationsMarketplaceTakeoverErrorsKo {
	_TranslationsMarketplaceTakeoverErrorsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get noPhoto => 'Minimal 1 foto di lokasi diperlukan untuk verifikasi.';
}

// Path: marketplace.takeover.dialog
class _TranslationsMarketplaceTakeoverDialogId extends TranslationsMarketplaceTakeoverDialogKo {
	_TranslationsMarketplaceTakeoverDialogId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get matchTitle => 'Verifikasi AI berhasil';
	@override String get noMatchTitle => 'Verifikasi AI gagal';
	@override String get finalize => 'Konfirmasi serah terima akhir';
	@override String get cancelDeal => 'Batalkan transaksi (minta refund)';
}

// Path: marketplace.takeover.success
class _TranslationsMarketplaceTakeoverSuccessId extends TranslationsMarketplaceTakeoverSuccessKo {
	_TranslationsMarketplaceTakeoverSuccessId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get finalized => 'Transaksi berhasil diselesaikan.';
	@override String get cancelled => 'Transaksi dibatalkan. Deposit akan dikembalikan.';
}

// Path: categories.post.jalanPerbaikin
class _TranslationsCategoriesPostJalanPerbaikinId extends TranslationsCategoriesPostJalanPerbaikinKo {
	_TranslationsCategoriesPostJalanPerbaikinId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsCategoriesPostJalanPerbaikinSearchId search = _TranslationsCategoriesPostJalanPerbaikinSearchId._(_root);
	@override String get name => 'Perbaikan jalan';
}

// Path: categories.post.dailyLife
class _TranslationsCategoriesPostDailyLifeId extends TranslationsCategoriesPostDailyLifeKo {
	_TranslationsCategoriesPostDailyLifeId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Sehari-hari/Pertanyaan';
	@override String get description => 'Bagikan kehidupan sehari-hari atau ajukan pertanyaan.';
}

// Path: categories.post.helpShare
class _TranslationsCategoriesPostHelpShareId extends TranslationsCategoriesPostHelpShareKo {
	_TranslationsCategoriesPostHelpShareId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Bantuan/ Berbagi';
	@override String get description => 'Butuh bantuan atau ingin berbagi sesuatu? Posting di sini.';
}

// Path: categories.post.incidentReport
class _TranslationsCategoriesPostIncidentReportId extends TranslationsCategoriesPostIncidentReportKo {
	_TranslationsCategoriesPostIncidentReportId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Insiden';
	@override String get description => 'Bagikan kabar insiden di lingkungan Anda.';
}

// Path: categories.post.localNews
class _TranslationsCategoriesPostLocalNewsId extends TranslationsCategoriesPostLocalNewsKo {
	_TranslationsCategoriesPostLocalNewsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Berita lingkungan';
	@override String get description => 'Bagikan berita dan informasi tentang lingkungan kita.';
}

// Path: categories.post.november
class _TranslationsCategoriesPostNovemberId extends TranslationsCategoriesPostNovemberKo {
	_TranslationsCategoriesPostNovemberId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'November';
}

// Path: categories.post.rain
class _TranslationsCategoriesPostRainId extends TranslationsCategoriesPostRainKo {
	_TranslationsCategoriesPostRainId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Hujan';
}

// Path: categories.post.dailyQuestion
class _TranslationsCategoriesPostDailyQuestionId extends TranslationsCategoriesPostDailyQuestionKo {
	_TranslationsCategoriesPostDailyQuestionId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Ada pertanyaan?';
	@override String get description => 'Tanyakan apa saja kepada tetangga Anda.';
}

// Path: categories.post.storePromo
class _TranslationsCategoriesPostStorePromoId extends TranslationsCategoriesPostStorePromoKo {
	_TranslationsCategoriesPostStorePromoId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Promo toko';
	@override String get description => 'Promosikan diskon atau event di toko Anda.';
}

// Path: categories.post.etc
class _TranslationsCategoriesPostEtcId extends TranslationsCategoriesPostEtcKo {
	_TranslationsCategoriesPostEtcId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Lainnya';
	@override String get description => 'Bagikan cerita lain secara bebas.';
}

// Path: categories.auction.collectibles
class _TranslationsCategoriesAuctionCollectiblesId extends TranslationsCategoriesAuctionCollectiblesKo {
	_TranslationsCategoriesAuctionCollectiblesId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Koleksi';
	@override String get description => 'Mainan, kartu, figur, dan lainnya.';
}

// Path: categories.auction.digital
class _TranslationsCategoriesAuctionDigitalId extends TranslationsCategoriesAuctionDigitalKo {
	_TranslationsCategoriesAuctionDigitalId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Digital';
	@override String get description => 'Produk dan aset digital.';
}

// Path: categories.auction.fashion
class _TranslationsCategoriesAuctionFashionId extends TranslationsCategoriesAuctionFashionKo {
	_TranslationsCategoriesAuctionFashionId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Fashion';
	@override String get description => 'Pakaian, aksesori, dan kecantikan.';
}

// Path: categories.auction.vintage
class _TranslationsCategoriesAuctionVintageId extends TranslationsCategoriesAuctionVintageKo {
	_TranslationsCategoriesAuctionVintageId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Vintage';
	@override String get description => 'Barang retro dan klasik.';
}

// Path: categories.auction.artCraft
class _TranslationsCategoriesAuctionArtCraftId extends TranslationsCategoriesAuctionArtCraftKo {
	_TranslationsCategoriesAuctionArtCraftId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Seni & kerajinan';
	@override String get description => 'Karya seni dan kerajinan tangan.';
}

// Path: categories.auction.etc
class _TranslationsCategoriesAuctionEtcId extends TranslationsCategoriesAuctionEtcKo {
	_TranslationsCategoriesAuctionEtcId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Lainnya';
	@override String get description => 'Barang lelang lainnya.';
}

// Path: jobs.findFriend.tabs
class _TranslationsJobsFindFriendTabsId extends TranslationsJobsFindFriendTabsKo {
	_TranslationsJobsFindFriendTabsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get friends => 'Teman';
	@override String get groups => 'Grup';
	@override String get clubs => 'Klub';
}

// Path: jobs.interests.items
class _TranslationsJobsInterestsItemsId extends TranslationsJobsInterestsItemsKo {
	_TranslationsJobsInterestsItemsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get drawing => 'Menggambar';
	@override String get instrument => 'Main alat musik';
	@override String get photography => 'Fotografi';
	@override String get writing => 'Menulis';
	@override String get crafting => 'Kerajinan tangan';
	@override String get gardening => 'Berkebun';
	@override String get soccer => 'Sepak bola/Futsal';
	@override String get hiking => 'Mendaki';
	@override String get camping => 'Berkemah';
	@override String get running => 'Lari/Jogging';
	@override String get biking => 'Bersepeda';
	@override String get golf => 'Golf';
	@override String get workout => 'Workout/Fitness';
	@override String get foodie => 'Pencinta kuliner';
	@override String get cooking => 'Memasak';
	@override String get baking => 'Baking';
	@override String get coffee => 'Kopi';
	@override String get wine => 'Wine/Minuman';
	@override String get tea => 'Teh';
	@override String get movies => 'Film/Drama';
	@override String get music => 'Mendengarkan musik';
	@override String get concerts => 'Konser/Festival';
	@override String get gaming => 'Gaming';
	@override String get reading => 'Membaca';
	@override String get investing => 'Investasi';
	@override String get language => 'Belajar bahasa';
	@override String get coding => 'Coding';
	@override String get travel => 'Travel';
	@override String get pets => 'Hewan peliharaan';
	@override String get volunteering => 'Relawan';
	@override String get minimalism => 'Minimalisme';
}

// Path: jobs.clubs.tabs
class _TranslationsJobsClubsTabsId extends TranslationsJobsClubsTabsKo {
	_TranslationsJobsClubsTabsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get proposals => 'Proposal';
	@override String get activeClubs => 'Klub aktif';
	@override String get myClubs => 'Klub saya';
	@override String get exploreClubs => 'Jelajahi';
}

// Path: jobs.clubs.sections
class _TranslationsJobsClubsSectionsId extends TranslationsJobsClubsSectionsKo {
	_TranslationsJobsClubsSectionsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get active => 'Klub resmi';
	@override String get proposals => 'Proposal klub';
}

// Path: jobs.clubs.screen
class _TranslationsJobsClubsScreenId extends TranslationsJobsClubsScreenKo {
	_TranslationsJobsClubsScreenId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get error => 'Kesalahan: {error}';
	@override String get empty => 'Belum ada klub.';
}

// Path: jobs.clubs.postList
class _TranslationsJobsClubsPostListId extends TranslationsJobsClubsPostListKo {
	_TranslationsJobsClubsPostListId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get empty => 'Belum ada postingan. Jadilah yang pertama!';
	@override String get writeTooltip => 'Tulis';
}

// Path: jobs.clubs.memberCard
class _TranslationsJobsClubsMemberCardId extends TranslationsJobsClubsMemberCardKo {
	_TranslationsJobsClubsMemberCardId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get kickConfirmTitle => 'Hapus {memberName}?';
	@override String get kickConfirmContent => 'Anggota yang dihapus tidak dapat mengikuti aktivitas klub lagi.';
	@override String get kick => 'Hapus';
	@override String get kickedSuccess => '{memberName} telah dihapus.';
	@override String get kickFail => 'Gagal menghapus anggota: {error}';
}

// Path: jobs.clubs.postCard
class _TranslationsJobsClubsPostCardId extends TranslationsJobsClubsPostCardKo {
	_TranslationsJobsClubsPostCardId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get deleteTitle => 'Hapus postingan';
	@override String get deleteContent => 'Yakin ingin menghapus postingan ini? Tindakan ini tidak dapat dibatalkan.';
	@override String get deleteSuccess => 'Postingan dihapus.';
	@override String get deleteFail => 'Gagal menghapus postingan: {error}';
	@override String get withdrawnMember => 'Anggota keluar';
	@override String get deleteTooltip => 'Hapus postingan';
	@override String get loadingUser => 'Memuat info pengguna...';
}

// Path: jobs.clubs.card
class _TranslationsJobsClubsCardId extends TranslationsJobsClubsCardKo {
	_TranslationsJobsClubsCardId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get membersCount => '{count} anggota';
}

// Path: jobs.clubs.postDetail
class _TranslationsJobsClubsPostDetailId extends TranslationsJobsClubsPostDetailKo {
	_TranslationsJobsClubsPostDetailId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get commentFail => 'Gagal menambahkan komentar: {error}';
	@override String get appBarTitle => 'Papan {title}';
	@override String get commentsTitle => 'Komentar';
	@override String get noComments => 'Belum ada komentar.';
	@override String get commentHint => 'Tulis komentar...';
	@override String get unknownUser => 'Pengguna tidak dikenal';
}

// Path: jobs.clubs.detail
class _TranslationsJobsClubsDetailId extends TranslationsJobsClubsDetailKo {
	_TranslationsJobsClubsDetailId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get joined => 'Anda bergabung dengan klub \'{title}\'!';
	@override String get pendingApproval => 'Menunggu persetujuan pemilik. Anda bisa ikut setelah disetujui.';
	@override String get joinFail => 'Gagal meminta bergabung: {error}';
	@override late final _TranslationsJobsClubsDetailTabsId tabs = _TranslationsJobsClubsDetailTabsId._(_root);
	@override String get joinChat => 'Masuk chat';
	@override String get joinClub => 'Gabung klub';
	@override String get owner => 'Admin';
	@override late final _TranslationsJobsClubsDetailInfoId info = _TranslationsJobsClubsDetailInfoId._(_root);
	@override String get location => 'Lokasi';
	@override String get leaveConfirmTitle => 'Keluar dari klub';
	@override String get leaveConfirmContent => 'Yakin ingin keluar dari {title}?';
	@override String get leave => 'Keluar';
	@override String get leaveSuccess => 'Anda telah keluar dari {title}';
	@override String get leaveFail => 'Gagal keluar: {error}';
}

// Path: jobs.clubs.memberList
class _TranslationsJobsClubsMemberListId extends TranslationsJobsClubsMemberListKo {
	_TranslationsJobsClubsMemberListId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get pendingMembers => 'Anggota menunggu';
	@override String get allMembers => 'Semua anggota';
}

// Path: jobs.clubs.createPost
class _TranslationsJobsClubsCreatePostId extends TranslationsJobsClubsCreatePostKo {
	_TranslationsJobsClubsCreatePostId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Postingan baru';
	@override String get submit => 'Kirim';
	@override String get success => 'Postingan berhasil dikirim.';
	@override String get fail => 'Gagal mengirim postingan: {error}';
	@override String get bodyHint => 'Tulis konten...';
}

// Path: jobs.clubs.createClub
class _TranslationsJobsClubsCreateClubId extends TranslationsJobsClubsCreateClubKo {
	_TranslationsJobsClubsCreateClubId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get selectAtLeastOneInterest => 'Pilih minimal satu minat.';
	@override String get success => 'Klub berhasil dibuat!';
	@override String get fail => 'Gagal membuat klub: {error}';
	@override String get title => 'Buat klub';
	@override String get nameLabel => 'Nama klub';
	@override String get nameError => 'Silakan isi nama klub.';
	@override String get descriptionLabel => 'Deskripsi klub';
	@override String get descriptionError => 'Silakan isi deskripsi klub.';
	@override String get tagsHint => 'Ketik tag lalu tekan Spasi untuk menambah';
	@override String get maxInterests => 'Anda bisa memilih hingga 3 minat.';
	@override String get privateClub => 'Klub privat';
	@override String get privateDescription => 'Hanya untuk undangan.';
	@override String get locationLabel => 'Lokasi';
}

// Path: jobs.clubs.editClub
class _TranslationsJobsClubsEditClubId extends TranslationsJobsClubsEditClubKo {
	_TranslationsJobsClubsEditClubId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Edit informasi klub';
	@override String get save => 'Simpan';
	@override String get success => 'Informasi klub diperbarui.';
	@override String get fail => 'Gagal memperbarui klub: {error}';
}

// Path: jobs.clubs.create
class _TranslationsJobsClubsCreateId extends TranslationsJobsClubsCreateKo {
	_TranslationsJobsClubsCreateId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Buat klub';
}

// Path: jobs.clubs.repository
class _TranslationsJobsClubsRepositoryId extends TranslationsJobsClubsRepositoryKo {
	_TranslationsJobsClubsRepositoryId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get chatCreated => 'Ruang chat klub dibuat.';
}

// Path: jobs.clubs.proposal
class _TranslationsJobsClubsProposalId extends TranslationsJobsClubsProposalKo {
	_TranslationsJobsClubsProposalId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get createTitle => 'Ajukan klub';
	@override String get imageError => 'Silakan pilih gambar sampul.';
	@override String get createSuccess => 'Proposal klub berhasil dibuat.';
	@override String get createFail => 'Gagal membuat proposal: {error}';
	@override String get tagsHint => 'Ketik tag lalu tekan Spasi untuk menambah';
	@override String get targetMembers => 'Target member';
	@override String get targetMembersCount => 'Total {count} anggota';
	@override String get empty => 'Belum ada proposal.';
	@override String get memberStatus => '{current} / {target} anggota';
	@override String get join => 'Gabung';
	@override String get leave => 'Keluar';
	@override String get members => 'Anggota';
	@override String get noMembers => 'Belum ada anggota.';
	@override late final _TranslationsJobsClubsProposalDetailId detail = _TranslationsJobsClubsProposalDetailId._(_root);
}

// Path: jobs.findfriend.form
class _TranslationsJobsFindfriendFormId extends TranslationsJobsFindfriendFormKo {
	_TranslationsJobsFindfriendFormId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Buat Profil Cari Teman';
}

// Path: jobs.auctions.card
class _TranslationsJobsAuctionsCardId extends TranslationsJobsAuctionsCardKo {
	_TranslationsJobsAuctionsCardId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get currentBid => 'Penawaran saat ini';
	@override String get endTime => 'Sisa waktu';
	@override String get ended => 'Selesai';
	@override String get winningBid => 'Penawaran menang';
	@override String get winner => 'Pemenang';
	@override String get noBidders => 'Belum ada penawar';
	@override String get unknownBidder => 'Penawar tidak dikenal';
	@override String get timeLeft => '{hours}:{minutes}:{seconds} tersisa';
	@override String get timeLeftDays => '{days} hari {hours}:{minutes}:{seconds} tersisa';
}

// Path: jobs.auctions.errors
class _TranslationsJobsAuctionsErrorsId extends TranslationsJobsAuctionsErrorsKo {
	_TranslationsJobsAuctionsErrorsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get fetchFailed => 'Gagal memuat daftar lelang: {error}';
	@override String get notFound => 'Lelang tidak ditemukan.';
	@override String get lowerBid => 'Anda harus memasukkan penawaran yang lebih tinggi.';
	@override String get alreadyEnded => 'Lelang ini telah selesai.';
}

// Path: jobs.auctions.filter
class _TranslationsJobsAuctionsFilterId extends TranslationsJobsAuctionsFilterKo {
	_TranslationsJobsAuctionsFilterId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get tooltip => 'Filter';
	@override String get clearTooltip => 'Hapus filter';
}

// Path: jobs.auctions.create
class _TranslationsJobsAuctionsCreateId extends TranslationsJobsAuctionsCreateKo {
	_TranslationsJobsAuctionsCreateId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get tooltip => 'Buat lelang';
	@override String get title => 'Buat Lelang';
	@override String get registrationType => 'Jenis registrasi';
	@override late final _TranslationsJobsAuctionsCreateTypeId type = _TranslationsJobsAuctionsCreateTypeId._(_root);
	@override String get success => 'Lelang berhasil dibuat.';
	@override String get fail => 'Gagal membuat lelang: {error}';
	@override String get submitButton => 'Mulai Lelang';
	@override String get confirmTitle => 'Daftar sebagai lelang?';
	@override String get confirmContent => 'Setelah didaftarkan sebagai lelang, tidak dapat diubah kembali ke penjualan biasa. Biaya 5% akan dikenakan jika lelang berhasil. Lanjut?';
	@override late final _TranslationsJobsAuctionsCreateErrorsId errors = _TranslationsJobsAuctionsCreateErrorsId._(_root);
	@override late final _TranslationsJobsAuctionsCreateFormId form = _TranslationsJobsAuctionsCreateFormId._(_root);
}

// Path: jobs.auctions.edit
class _TranslationsJobsAuctionsEditId extends TranslationsJobsAuctionsEditKo {
	_TranslationsJobsAuctionsEditId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get tooltip => 'Edit lelang';
	@override String get title => 'Edit Lelang';
	@override String get save => 'Simpan';
	@override String get success => 'Lelang berhasil diperbarui.';
	@override String get fail => 'Gagal memperbarui lelang: {error}';
}

// Path: jobs.auctions.form
class _TranslationsJobsAuctionsFormId extends TranslationsJobsAuctionsFormKo {
	_TranslationsJobsAuctionsFormId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get titleRequired => 'Silakan masukkan judul.';
	@override String get descriptionRequired => 'Silakan masukkan deskripsi.';
	@override String get startPriceRequired => 'Silakan masukkan harga awal.';
	@override String get categoryRequired => 'Silakan pilih kategori.';
}

// Path: jobs.auctions.delete
class _TranslationsJobsAuctionsDeleteId extends TranslationsJobsAuctionsDeleteKo {
	_TranslationsJobsAuctionsDeleteId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get tooltip => 'Hapus lelang';
	@override String get confirmTitle => 'Hapus lelang';
	@override String get confirmContent => 'Yakin ingin menghapus lelang ini?';
	@override String get success => 'Lelang dihapus.';
	@override String get fail => 'Gagal menghapus lelang: {error}';
}

// Path: jobs.auctions.detail
class _TranslationsJobsAuctionsDetailId extends TranslationsJobsAuctionsDetailKo {
	_TranslationsJobsAuctionsDetailId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get currentBid => 'Penawaran saat ini: {amount}';
	@override String get location => 'Lokasi';
	@override String get seller => 'Penjual';
	@override String get qnaTitle => 'Tanya jawab';
	@override String get qnaHint => 'Tanya penjual...';
	@override String get endTime => 'Waktu selesai: {time}';
	@override String get bidsTitle => 'Daftar penawaran';
	@override String get noBids => 'Belum ada penawaran.';
	@override String get unknownBidder => 'Penawar tidak dikenal';
	@override String get bidAmountLabel => 'Masukkan penawaran (Rp)';
	@override String get placeBid => 'Tawar';
	@override String get bidSuccess => 'Penawaran berhasil!';
	@override String get bidFail => 'Gagal menawar: {error}';
	@override late final _TranslationsJobsAuctionsDetailErrorsId errors = _TranslationsJobsAuctionsDetailErrorsId._(_root);
}

// Path: jobs.localStores.create
class _TranslationsJobsLocalStoresCreateId extends TranslationsJobsLocalStoresCreateKo {
	_TranslationsJobsLocalStoresCreateId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get tooltip => 'Daftarkan toko saya';
	@override String get title => 'Daftarkan Toko Baru';
	@override String get submit => 'Daftarkan';
	@override String get success => 'Toko berhasil didaftarkan.';
	@override String get fail => 'Gagal mendaftarkan toko: {error}';
}

// Path: jobs.localStores.edit
class _TranslationsJobsLocalStoresEditId extends TranslationsJobsLocalStoresEditKo {
	_TranslationsJobsLocalStoresEditId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Edit Info Toko';
	@override String get save => 'Simpan';
	@override String get success => 'Info toko berhasil diperbarui.';
	@override String get fail => 'Gagal memperbarui info: {error}';
	@override String get tooltip => 'Edit info toko';
}

// Path: jobs.localStores.form
class _TranslationsJobsLocalStoresFormId extends TranslationsJobsLocalStoresFormKo {
	_TranslationsJobsLocalStoresFormId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get nameLabel => 'Nama toko';
	@override String get nameError => 'Silakan masukkan nama toko.';
	@override String get descriptionLabel => 'Deskripsi toko';
	@override String get descriptionError => 'Silakan masukkan deskripsi toko.';
	@override String get contactLabel => 'Kontak';
	@override String get hoursLabel => 'Jam buka';
	@override String get hoursHint => 'mis. 09:00 - 18:00';
	@override String get photoLabel => 'Foto (maks {count})';
	@override String get categoryLabel => 'Kategori';
	@override String get categoryError => 'Silakan pilih kategori.';
	@override String get productsLabel => 'Produk/Layanan utama';
	@override String get productsHint => 'Pisahkan dengan koma, mis. Haircut, Coloring, Perm';
	@override String get imageError => 'Gambar gagal dimuat. Coba lagi.';
}

// Path: jobs.localStores.categories
class _TranslationsJobsLocalStoresCategoriesId extends TranslationsJobsLocalStoresCategoriesKo {
	_TranslationsJobsLocalStoresCategoriesId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get all => 'Semua';
	@override String get food => 'Restoran';
	@override String get cafe => 'Kafe';
	@override String get massage => 'Pijat';
	@override String get beauty => 'Kecantikan';
	@override String get nail => 'Nail';
	@override String get auto => 'Bengkel';
	@override String get kids => 'Anak-anak';
	@override String get hospital => 'Rumah sakit/Klinik';
	@override String get etc => 'Lainnya';
}

// Path: jobs.localStores.detail
class _TranslationsJobsLocalStoresDetailId extends TranslationsJobsLocalStoresDetailKo {
	_TranslationsJobsLocalStoresDetailId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get description => 'Deskripsi toko';
	@override String get products => 'Produk/Layanan';
	@override String get deleteTitle => 'Hapus toko';
	@override String get deleteContent => 'Yakin ingin menghapus toko ini? Tindakan ini tidak dapat dibatalkan.';
	@override String get deleteTooltip => 'Hapus toko';
	@override String get delete => 'Hapus';
	@override String get cancel => 'Batal';
	@override String get deleteSuccess => 'Toko dihapus.';
	@override String get deleteFail => 'Gagal menghapus toko: {error}';
	@override String get inquire => 'Hubungi';
	@override String get noOwnerInfo => 'Info pemilik tidak tersedia';
	@override String get startChatFail => 'Tidak dapat memulai chat: {error}';
	@override String get reviews => 'Ulasan';
	@override String get writeReview => 'Tulis ulasan';
	@override String get noReviews => 'Belum ada ulasan.';
	@override String get reviewDialogContent => 'Silakan tulis ulasan Anda.';
}

// Path: jobs.pom.search
class _TranslationsJobsPomSearchId extends TranslationsJobsPomSearchKo {
	_TranslationsJobsPomSearchId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get hint => 'Cari POM, tag, pengguna';
}

// Path: jobs.pom.tabs
class _TranslationsJobsPomTabsId extends TranslationsJobsPomTabsKo {
	_TranslationsJobsPomTabsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get local => 'Lokal';
	@override String get all => 'Semua';
	@override String get popular => 'Populer';
	@override String get myPoms => 'POM saya';
}

// Path: jobs.pom.errors
class _TranslationsJobsPomErrorsId extends TranslationsJobsPomErrorsKo {
	_TranslationsJobsPomErrorsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get fetchFailed => 'Terjadi kesalahan: {error}';
	@override String get videoSource => 'Video tidak dapat diputar. Sumber tidak tersedia atau diblokir.';
}

// Path: jobs.pom.comments
class _TranslationsJobsPomCommentsId extends TranslationsJobsPomCommentsKo {
	_TranslationsJobsPomCommentsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Komentar';
	@override String get viewAll => 'Lihat semua {} komentar';
	@override String get empty => 'Belum ada komentar.';
	@override String get placeholder => 'Tulis komentar...';
	@override String get fail => 'Gagal menambahkan komentar: {error}';
}

// Path: jobs.pom.create
class _TranslationsJobsPomCreateId extends TranslationsJobsPomCreateKo {
	_TranslationsJobsPomCreateId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Unggah POM Baru';
	@override String get photo => 'Foto';
	@override String get video => 'Video';
	@override String get titleImage => 'Unggah Foto';
	@override String get submit => 'Unggah';
	@override String get success => 'POM berhasil diunggah.';
	@override String get fail => 'Gagal mengunggah POM: {error}';
	@override late final _TranslationsJobsPomCreateFormId form = _TranslationsJobsPomCreateFormId._(_root);
}

// Path: jobs.realEstate.tabs
class _TranslationsJobsRealEstateTabsId extends TranslationsJobsRealEstateTabsKo {
	_TranslationsJobsRealEstateTabsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get all => 'Semua';
	@override String get rent => 'Sewa';
	@override String get sale => 'Dijual';
	@override String get myListings => 'Daftar saya';
}

// Path: jobs.realEstate.create
class _TranslationsJobsRealEstateCreateId extends TranslationsJobsRealEstateCreateKo {
	_TranslationsJobsRealEstateCreateId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get tooltip => 'Pasang iklan';
	@override String get title => 'Pasang Properti Baru';
	@override String get submit => 'Pasang';
	@override String get success => 'Properti berhasil dipasang.';
	@override String get fail => 'Gagal memasang properti: {error}';
}

// Path: jobs.realEstate.edit
class _TranslationsJobsRealEstateEditId extends TranslationsJobsRealEstateEditKo {
	_TranslationsJobsRealEstateEditId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Edit Properti';
	@override String get save => 'Simpan';
	@override String get success => 'Properti berhasil diperbarui.';
	@override String get fail => 'Gagal memperbarui properti: {error}';
	@override String get tooltip => 'Edit properti';
}

// Path: jobs.realEstate.form
class _TranslationsJobsRealEstateFormId extends TranslationsJobsRealEstateFormKo {
	_TranslationsJobsRealEstateFormId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get titleLabel => 'Judul';
	@override String get titleError => 'Silakan masukkan judul.';
	@override String get descriptionLabel => 'Deskripsi';
	@override String get descriptionError => 'Silakan masukkan deskripsi.';
	@override String get priceLabel => 'Harga (IDR)';
	@override String get priceError => 'Silakan masukkan harga.';
	@override String get categoryLabel => 'Tipe';
	@override String get categoryError => 'Silakan pilih tipe.';
	@override String get locationLabel => 'Lokasi';
	@override String get locationError => 'Silakan masukkan lokasi.';
	@override String get roomsLabel => 'Jumlah kamar';
	@override String get bathLabel => 'Kamar mandi';
	@override String get areaLabel => 'Luas (m²)';
	@override String get photoLabel => 'Foto (maks 10)';
	@override String get imageError => 'Gagal memuat gambar.';
}

// Path: jobs.realEstate.categories
class _TranslationsJobsRealEstateCategoriesId extends TranslationsJobsRealEstateCategoriesKo {
	_TranslationsJobsRealEstateCategoriesId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get house => 'Rumah';
	@override String get apartment => 'Apartemen';
	@override String get kost => 'Kost';
	@override String get villa => 'Villa';
	@override String get office => 'Kantor';
	@override String get land => 'Tanah';
	@override String get shophouse => 'Ruko';
	@override String get warehouse => 'Gudang';
	@override String get etc => 'Lainnya';
}

// Path: jobs.realEstate.detail
class _TranslationsJobsRealEstateDetailId extends TranslationsJobsRealEstateDetailKo {
	_TranslationsJobsRealEstateDetailId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get price => 'Harga';
	@override String get rooms => 'Kamar';
	@override String get bathrooms => 'Kamar mandi';
	@override String get area => 'Luas';
	@override String get location => 'Lokasi';
	@override String get contactSeller => 'Hubungi penjual';
	@override String get contactFail => 'Tidak dapat memulai chat: {error}';
	@override String get delete => 'Hapus';
	@override String get deleteConfirm => 'Hapus properti ini?';
	@override String get deleteSuccess => 'Properti dihapus.';
	@override String get deleteFail => 'Gagal menghapus properti: {error}';
	@override String get postedBy => 'Diposting oleh';
}

// Path: jobs.lostAndFound.tabs
class _TranslationsJobsLostAndFoundTabsId extends TranslationsJobsLostAndFoundTabsKo {
	_TranslationsJobsLostAndFoundTabsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get lost => 'Hilang';
	@override String get found => 'Ditemukan';
	@override String get myReports => 'Laporan saya';
}

// Path: jobs.lostAndFound.create
class _TranslationsJobsLostAndFoundCreateId extends TranslationsJobsLostAndFoundCreateKo {
	_TranslationsJobsLostAndFoundCreateId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get tooltip => 'Buat laporan';
	@override String get title => 'Buat Laporan Baru';
	@override String get submit => 'Kirim';
	@override String get success => 'Laporan berhasil dibuat.';
	@override String get fail => 'Gagal membuat laporan: {error}';
}

// Path: jobs.lostAndFound.edit
class _TranslationsJobsLostAndFoundEditId extends TranslationsJobsLostAndFoundEditKo {
	_TranslationsJobsLostAndFoundEditId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Edit laporan';
	@override String get save => 'Simpan';
	@override String get success => 'Laporan berhasil diperbarui.';
	@override String get fail => 'Gagal memperbarui laporan: {error}';
}

// Path: jobs.lostAndFound.form
class _TranslationsJobsLostAndFoundFormId extends TranslationsJobsLostAndFoundFormKo {
	_TranslationsJobsLostAndFoundFormId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get titleLabel => 'Judul';
	@override String get titleError => 'Silakan masukkan judul.';
	@override String get descriptionLabel => 'Detail';
	@override String get descriptionError => 'Silakan masukkan detail.';
	@override String get categoryLabel => 'Kategori';
	@override String get categoryError => 'Silakan pilih kategori.';
	@override String get locationLabel => 'Lokasi';
	@override String get locationError => 'Silakan masukkan lokasi.';
	@override String get photoLabel => 'Foto (maks 10)';
}

// Path: jobs.lostAndFound.categories
class _TranslationsJobsLostAndFoundCategoriesId extends TranslationsJobsLostAndFoundCategoriesKo {
	_TranslationsJobsLostAndFoundCategoriesId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get pet => 'Hewan peliharaan';
	@override String get item => 'Barang';
	@override String get person => 'Orang';
	@override String get scam => 'Penipuan';
	@override String get etc => 'Lainnya';
}

// Path: jobs.lostAndFound.detail
class _TranslationsJobsLostAndFoundDetailId extends TranslationsJobsLostAndFoundDetailKo {
	_TranslationsJobsLostAndFoundDetailId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get location => 'Lokasi';
	@override String get contact => 'Hubungi';
	@override String get contactFail => 'Tidak dapat memulai chat: {error}';
	@override String get delete => 'Hapus';
	@override String get deleteConfirm => 'Hapus laporan ini?';
	@override String get deleteSuccess => 'Laporan dihapus.';
	@override String get deleteFail => 'Gagal menghapus laporan: {error}';
}

// Path: jobs.community.create
class _TranslationsJobsCommunityCreateId extends TranslationsJobsCommunityCreateKo {
	_TranslationsJobsCommunityCreateId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Postingan Baru';
	@override String get submit => 'Kirim';
	@override String get success => 'Postingan berhasil dibuat.';
	@override String get fail => 'Gagal membuat postingan: {error}';
}

// Path: jobs.community.edit
class _TranslationsJobsCommunityEditId extends TranslationsJobsCommunityEditKo {
	_TranslationsJobsCommunityEditId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Edit Postingan';
	@override String get save => 'Simpan';
	@override String get success => 'Postingan berhasil diperbarui.';
	@override String get fail => 'Gagal memperbarui: {error}';
}

// Path: jobs.community.post
class _TranslationsJobsCommunityPostId extends TranslationsJobsCommunityPostKo {
	_TranslationsJobsCommunityPostId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get delete => 'Hapus';
	@override String get deleteConfirm => 'Hapus postingan ini?';
	@override String get deleteSuccess => 'Postingan dihapus.';
	@override String get deleteFail => 'Gagal menghapus postingan: {error}';
}

// Path: jobs.shared.tagInput
class _TranslationsJobsSharedTagInputId extends TranslationsJobsSharedTagInputKo {
	_TranslationsJobsSharedTagInputId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get defaultHint => 'Tambahkan tag (tekan spasi untuk konfirmasi)';
}

// Path: jobs.admin.screen
class _TranslationsJobsAdminScreenId extends TranslationsJobsAdminScreenKo {
	_TranslationsJobsAdminScreenId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Menu Admin';
}

// Path: jobs.admin.menu
class _TranslationsJobsAdminMenuId extends TranslationsJobsAdminMenuKo {
	_TranslationsJobsAdminMenuId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get aiApproval => 'Manajemen Verifikasi AI';
	@override String get reportManagement => 'Manajemen Laporan';
}

// Path: jobs.admin.aiApproval
class _TranslationsJobsAdminAiApprovalId extends TranslationsJobsAdminAiApprovalKo {
	_TranslationsJobsAdminAiApprovalId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get empty => 'Tidak ada produk yang menunggu verifikasi AI.';
	@override String get error => 'Terjadi kesalahan saat memuat produk yang menunggu.';
	@override String get requestedAt => 'Waktu permintaan';
}

// Path: jobs.admin.reports
class _TranslationsJobsAdminReportsId extends TranslationsJobsAdminReportsKo {
	_TranslationsJobsAdminReportsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Manajemen Laporan';
	@override String get empty => 'Tidak ada laporan yang menunggu.';
	@override String get error => 'Terjadi kesalahan saat memuat laporan.';
	@override String get createdAt => 'Dibuat pada';
}

// Path: jobs.admin.reportList
class _TranslationsJobsAdminReportListId extends TranslationsJobsAdminReportListKo {
	_TranslationsJobsAdminReportListId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Manajemen Laporan';
	@override String get empty => 'Tidak ada laporan yang menunggu.';
	@override String get error => 'Terjadi kesalahan saat memuat laporan.';
}

// Path: jobs.admin.reportDetail
class _TranslationsJobsAdminReportDetailId extends TranslationsJobsAdminReportDetailKo {
	_TranslationsJobsAdminReportDetailId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get title => 'Detail Laporan';
	@override String get loadError => 'Terjadi kesalahan saat memuat detail laporan.';
	@override String get sectionReportInfo => 'Informasi laporan';
	@override String get idLabel => 'ID';
	@override String get postIdLabel => 'ID postingan yang dilaporkan';
	@override String get reporter => 'Pelapor';
	@override String get reportedUser => 'Pengguna yang dilaporkan';
	@override String get reason => 'Alasan';
	@override String get reportedAt => 'Waktu laporan';
	@override String get currentStatus => 'Status';
	@override String get sectionContent => 'Konten yang dilaporkan';
	@override String get loadingContent => 'Memuat konten...';
	@override String get contentLoadError => 'Gagal memuat konten yang dilaporkan.';
	@override String get contentNotAvailable => 'Informasi konten tidak tersedia atau sudah dihapus.';
	@override String get authorIdLabel => 'ID pembuat';
	@override late final _TranslationsJobsAdminReportDetailContentId content = _TranslationsJobsAdminReportDetailContentId._(_root);
	@override String get viewOriginalPost => 'Lihat postingan asli';
	@override String get sectionActions => 'Tindakan';
	@override String get actionReviewed => 'Tandai sudah ditinjau';
	@override String get actionTaken => 'Tandai tindakan diambil (mis. dihapus)';
	@override String get actionDismissed => 'Abaikan laporan';
	@override String get statusUpdateSuccess => 'Status laporan diperbarui menjadi \'{status}\'.';
	@override String get statusUpdateFail => 'Gagal memperbarui status: {error}';
	@override String get originalPostNotFound => 'Postingan asli tidak ditemukan.';
	@override String get couldNotOpenOriginalPost => 'Tidak dapat membuka postingan asli.';
}

// Path: jobs.tags.localNews
class _TranslationsJobsTagsLocalNewsId extends TranslationsJobsTagsLocalNewsKo {
	_TranslationsJobsTagsLocalNewsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override late final _TranslationsJobsTagsLocalNewsKelurahanNoticeId kelurahanNotice = _TranslationsJobsTagsLocalNewsKelurahanNoticeId._(_root);
	@override late final _TranslationsJobsTagsLocalNewsKecamatanNoticeId kecamatanNotice = _TranslationsJobsTagsLocalNewsKecamatanNoticeId._(_root);
	@override late final _TranslationsJobsTagsLocalNewsPublicCampaignId publicCampaign = _TranslationsJobsTagsLocalNewsPublicCampaignId._(_root);
	@override late final _TranslationsJobsTagsLocalNewsSiskamlingId siskamling = _TranslationsJobsTagsLocalNewsSiskamlingId._(_root);
	@override late final _TranslationsJobsTagsLocalNewsPowerOutageId powerOutage = _TranslationsJobsTagsLocalNewsPowerOutageId._(_root);
	@override late final _TranslationsJobsTagsLocalNewsWaterOutageId waterOutage = _TranslationsJobsTagsLocalNewsWaterOutageId._(_root);
	@override late final _TranslationsJobsTagsLocalNewsWasteCollectionId wasteCollection = _TranslationsJobsTagsLocalNewsWasteCollectionId._(_root);
	@override late final _TranslationsJobsTagsLocalNewsRoadWorksId roadWorks = _TranslationsJobsTagsLocalNewsRoadWorksId._(_root);
	@override late final _TranslationsJobsTagsLocalNewsPublicFacilityId publicFacility = _TranslationsJobsTagsLocalNewsPublicFacilityId._(_root);
	@override late final _TranslationsJobsTagsLocalNewsWeatherWarningId weatherWarning = _TranslationsJobsTagsLocalNewsWeatherWarningId._(_root);
	@override late final _TranslationsJobsTagsLocalNewsFloodAlertId floodAlert = _TranslationsJobsTagsLocalNewsFloodAlertId._(_root);
	@override late final _TranslationsJobsTagsLocalNewsAirQualityId airQuality = _TranslationsJobsTagsLocalNewsAirQualityId._(_root);
	@override late final _TranslationsJobsTagsLocalNewsDiseaseAlertId diseaseAlert = _TranslationsJobsTagsLocalNewsDiseaseAlertId._(_root);
	@override late final _TranslationsJobsTagsLocalNewsSchoolNoticeId schoolNotice = _TranslationsJobsTagsLocalNewsSchoolNoticeId._(_root);
	@override late final _TranslationsJobsTagsLocalNewsPosyanduId posyandu = _TranslationsJobsTagsLocalNewsPosyanduId._(_root);
	@override late final _TranslationsJobsTagsLocalNewsHealthCampaignId healthCampaign = _TranslationsJobsTagsLocalNewsHealthCampaignId._(_root);
	@override late final _TranslationsJobsTagsLocalNewsTrafficControlId trafficControl = _TranslationsJobsTagsLocalNewsTrafficControlId._(_root);
	@override late final _TranslationsJobsTagsLocalNewsPublicTransportId publicTransport = _TranslationsJobsTagsLocalNewsPublicTransportId._(_root);
	@override late final _TranslationsJobsTagsLocalNewsParkingPolicyId parkingPolicy = _TranslationsJobsTagsLocalNewsParkingPolicyId._(_root);
	@override late final _TranslationsJobsTagsLocalNewsCommunityEventId communityEvent = _TranslationsJobsTagsLocalNewsCommunityEventId._(_root);
	@override late final _TranslationsJobsTagsLocalNewsWorshipEventId worshipEvent = _TranslationsJobsTagsLocalNewsWorshipEventId._(_root);
	@override late final _TranslationsJobsTagsLocalNewsIncidentReportId incidentReport = _TranslationsJobsTagsLocalNewsIncidentReportId._(_root);
}

// Path: jobs.boards.popup
class _TranslationsJobsBoardsPopupId extends TranslationsJobsBoardsPopupKo {
	_TranslationsJobsBoardsPopupId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get inactiveTitle => 'Papan lingkungan belum aktif';
	@override String get inactiveBody => 'Untuk mengaktifkan papan lingkungan Anda, buat dulu satu posting Berita Lokal. Jika tetangga mulai ikut serta, papan akan terbuka otomatis.';
	@override String get writePost => 'Tulis Berita Lokal';
}

// Path: jobs.signup.alerts
class _TranslationsJobsSignupAlertsId extends TranslationsJobsSignupAlertsKo {
	_TranslationsJobsSignupAlertsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get signupSuccessLoginNotice => 'Pendaftaran berhasil! Silakan login.';
}

// Path: jobs.signup.buttons
class _TranslationsJobsSignupButtonsId extends TranslationsJobsSignupButtonsKo {
	_TranslationsJobsSignupButtonsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get signup => 'Daftar';
}

// Path: categories.post.jalanPerbaikin.search
class _TranslationsCategoriesPostJalanPerbaikinSearchId extends TranslationsCategoriesPostJalanPerbaikinSearchKo {
	_TranslationsCategoriesPostJalanPerbaikinSearchId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get hint => 'Cari POM, tag, pengguna';
}

// Path: jobs.clubs.detail.tabs
class _TranslationsJobsClubsDetailTabsId extends TranslationsJobsClubsDetailTabsKo {
	_TranslationsJobsClubsDetailTabsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get info => 'Info';
	@override String get board => 'Papan';
	@override String get members => 'Anggota';
}

// Path: jobs.clubs.detail.info
class _TranslationsJobsClubsDetailInfoId extends TranslationsJobsClubsDetailInfoKo {
	_TranslationsJobsClubsDetailInfoId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get members => 'Anggota';
	@override String get location => 'Lokasi';
}

// Path: jobs.clubs.proposal.detail
class _TranslationsJobsClubsProposalDetailId extends TranslationsJobsClubsProposalDetailKo {
	_TranslationsJobsClubsProposalDetailId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get joined => 'Anda bergabung!';
	@override String get left => 'Anda keluar.';
	@override String get loginRequired => 'Silakan login untuk bergabung.';
	@override String get error => 'Terjadi kesalahan: {error}';
}

// Path: jobs.auctions.create.type
class _TranslationsJobsAuctionsCreateTypeId extends TranslationsJobsAuctionsCreateTypeKo {
	_TranslationsJobsAuctionsCreateTypeId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get sale => 'Jual';
	@override String get auction => 'Lelang';
}

// Path: jobs.auctions.create.errors
class _TranslationsJobsAuctionsCreateErrorsId extends TranslationsJobsAuctionsCreateErrorsKo {
	_TranslationsJobsAuctionsCreateErrorsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get noPhoto => 'Tambahkan setidaknya satu foto.';
}

// Path: jobs.auctions.create.form
class _TranslationsJobsAuctionsCreateFormId extends TranslationsJobsAuctionsCreateFormKo {
	_TranslationsJobsAuctionsCreateFormId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get photoSectionTitle => 'Unggah foto (maks 10)';
	@override String get title => 'Judul';
	@override String get description => 'Deskripsi';
	@override String get startPrice => 'Harga awal';
	@override String get category => 'Kategori';
	@override String get categoryHint => 'Pilih kategori';
	@override String get tagsHint => 'Ketik tag lalu tekan Spasi untuk menambah';
	@override String get duration => 'Durasi';
	@override String get durationOption => '{days} hari';
	@override String get location => 'Lokasi';
}

// Path: jobs.auctions.detail.errors
class _TranslationsJobsAuctionsDetailErrorsId extends TranslationsJobsAuctionsDetailErrorsKo {
	_TranslationsJobsAuctionsDetailErrorsId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get loginRequired => 'Login diperlukan.';
	@override String get invalidAmount => 'Masukkan jumlah penawaran yang valid.';
}

// Path: jobs.pom.create.form
class _TranslationsJobsPomCreateFormId extends TranslationsJobsPomCreateFormKo {
	_TranslationsJobsPomCreateFormId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get titleLabel => 'Judul';
	@override String get descriptionLabel => 'Deskripsi';
}

// Path: jobs.admin.reportDetail.content
class _TranslationsJobsAdminReportDetailContentId extends TranslationsJobsAdminReportDetailContentKo {
	_TranslationsJobsAdminReportDetailContentId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get post => 'Postingan: {title}\n\n{body}';
	@override String get comment => 'Komentar: {content}';
	@override String get reply => 'Balasan: {content}';
}

// Path: jobs.tags.localNews.kelurahanNotice
class _TranslationsJobsTagsLocalNewsKelurahanNoticeId extends TranslationsJobsTagsLocalNewsKelurahanNoticeKo {
	_TranslationsJobsTagsLocalNewsKelurahanNoticeId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Pengumuman kelurahan';
	@override String get desc => 'Pengumuman resmi dari kantor kelurahan.';
}

// Path: jobs.tags.localNews.kecamatanNotice
class _TranslationsJobsTagsLocalNewsKecamatanNoticeId extends TranslationsJobsTagsLocalNewsKecamatanNoticeKo {
	_TranslationsJobsTagsLocalNewsKecamatanNoticeId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Pengumuman kecamatan';
	@override String get desc => 'Pengumuman dari kantor kecamatan.';
}

// Path: jobs.tags.localNews.publicCampaign
class _TranslationsJobsTagsLocalNewsPublicCampaignId extends TranslationsJobsTagsLocalNewsPublicCampaignKo {
	_TranslationsJobsTagsLocalNewsPublicCampaignId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Kampanye publik';
	@override String get desc => 'Informasi publik dan program pemerintah.';
}

// Path: jobs.tags.localNews.siskamling
class _TranslationsJobsTagsLocalNewsSiskamlingId extends TranslationsJobsTagsLocalNewsSiskamlingKo {
	_TranslationsJobsTagsLocalNewsSiskamlingId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Siskamling';
	@override String get desc => 'Kegiatan ronda dan keamanan lingkungan.';
}

// Path: jobs.tags.localNews.powerOutage
class _TranslationsJobsTagsLocalNewsPowerOutageId extends TranslationsJobsTagsLocalNewsPowerOutageKo {
	_TranslationsJobsTagsLocalNewsPowerOutageId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Pemadaman listrik';
	@override String get desc => 'Informasi pemadaman listrik di area Anda.';
}

// Path: jobs.tags.localNews.waterOutage
class _TranslationsJobsTagsLocalNewsWaterOutageId extends TranslationsJobsTagsLocalNewsWaterOutageKo {
	_TranslationsJobsTagsLocalNewsWaterOutageId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Gangguan air';
	@override String get desc => 'Informasi gangguan/pemutusan pasokan air.';
}

// Path: jobs.tags.localNews.wasteCollection
class _TranslationsJobsTagsLocalNewsWasteCollectionId extends TranslationsJobsTagsLocalNewsWasteCollectionKo {
	_TranslationsJobsTagsLocalNewsWasteCollectionId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Pengangkutan sampah';
	@override String get desc => 'Jadwal atau pemberitahuan pengangkutan sampah.';
}

// Path: jobs.tags.localNews.roadWorks
class _TranslationsJobsTagsLocalNewsRoadWorksId extends TranslationsJobsTagsLocalNewsRoadWorksKo {
	_TranslationsJobsTagsLocalNewsRoadWorksId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Perbaikan jalan';
	@override String get desc => 'Informasi perbaikan dan pekerjaan jalan.';
}

// Path: jobs.tags.localNews.publicFacility
class _TranslationsJobsTagsLocalNewsPublicFacilityId extends TranslationsJobsTagsLocalNewsPublicFacilityKo {
	_TranslationsJobsTagsLocalNewsPublicFacilityId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Fasilitas umum';
	@override String get desc => 'Info tentang taman, lapangan, dan fasilitas umum.';
}

// Path: jobs.tags.localNews.weatherWarning
class _TranslationsJobsTagsLocalNewsWeatherWarningId extends TranslationsJobsTagsLocalNewsWeatherWarningKo {
	_TranslationsJobsTagsLocalNewsWeatherWarningId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Peringatan cuaca';
	@override String get desc => 'Peringatan cuaca ekstrem di area Anda.';
}

// Path: jobs.tags.localNews.floodAlert
class _TranslationsJobsTagsLocalNewsFloodAlertId extends TranslationsJobsTagsLocalNewsFloodAlertKo {
	_TranslationsJobsTagsLocalNewsFloodAlertId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Peringatan banjir';
	@override String get desc => 'Informasi peringatan dan area terdampak banjir.';
}

// Path: jobs.tags.localNews.airQuality
class _TranslationsJobsTagsLocalNewsAirQualityId extends TranslationsJobsTagsLocalNewsAirQualityKo {
	_TranslationsJobsTagsLocalNewsAirQualityId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Kualitas udara';
	@override String get desc => 'Informasi polusi udara dan AQI.';
}

// Path: jobs.tags.localNews.diseaseAlert
class _TranslationsJobsTagsLocalNewsDiseaseAlertId extends TranslationsJobsTagsLocalNewsDiseaseAlertKo {
	_TranslationsJobsTagsLocalNewsDiseaseAlertId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Peringatan penyakit';
	@override String get desc => 'Peringatan penyakit menular dan info kesehatan.';
}

// Path: jobs.tags.localNews.schoolNotice
class _TranslationsJobsTagsLocalNewsSchoolNoticeId extends TranslationsJobsTagsLocalNewsSchoolNoticeKo {
	_TranslationsJobsTagsLocalNewsSchoolNoticeId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Pengumuman sekolah';
	@override String get desc => 'Pengumuman dari sekolah-sekolah di sekitar.';
}

// Path: jobs.tags.localNews.posyandu
class _TranslationsJobsTagsLocalNewsPosyanduId extends TranslationsJobsTagsLocalNewsPosyanduKo {
	_TranslationsJobsTagsLocalNewsPosyanduId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Posyandu';
	@override String get desc => 'Kegiatan posyandu dan layanan kesehatan masyarakat.';
}

// Path: jobs.tags.localNews.healthCampaign
class _TranslationsJobsTagsLocalNewsHealthCampaignId extends TranslationsJobsTagsLocalNewsHealthCampaignKo {
	_TranslationsJobsTagsLocalNewsHealthCampaignId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Kampanye kesehatan';
	@override String get desc => 'Kampanye dan edukasi kesehatan masyarakat.';
}

// Path: jobs.tags.localNews.trafficControl
class _TranslationsJobsTagsLocalNewsTrafficControlId extends TranslationsJobsTagsLocalNewsTrafficControlKo {
	_TranslationsJobsTagsLocalNewsTrafficControlId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Pengaturan lalu lintas';
	@override String get desc => 'Informasi pengalihan, penutupan, dan rekayasa lalu lintas.';
}

// Path: jobs.tags.localNews.publicTransport
class _TranslationsJobsTagsLocalNewsPublicTransportId extends TranslationsJobsTagsLocalNewsPublicTransportKo {
	_TranslationsJobsTagsLocalNewsPublicTransportId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Transportasi umum';
	@override String get desc => 'Info bus, kereta, dan transportasi umum lainnya.';
}

// Path: jobs.tags.localNews.parkingPolicy
class _TranslationsJobsTagsLocalNewsParkingPolicyId extends TranslationsJobsTagsLocalNewsParkingPolicyKo {
	_TranslationsJobsTagsLocalNewsParkingPolicyId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Kebijakan parkir';
	@override String get desc => 'Info parkir dan perubahan kebijakan parkir.';
}

// Path: jobs.tags.localNews.communityEvent
class _TranslationsJobsTagsLocalNewsCommunityEventId extends TranslationsJobsTagsLocalNewsCommunityEventKo {
	_TranslationsJobsTagsLocalNewsCommunityEventId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Acara komunitas';
	@override String get desc => 'Festival, kumpul warga, dan acara lokal.';
}

// Path: jobs.tags.localNews.worshipEvent
class _TranslationsJobsTagsLocalNewsWorshipEventId extends TranslationsJobsTagsLocalNewsWorshipEventKo {
	_TranslationsJobsTagsLocalNewsWorshipEventId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Acara keagamaan';
	@override String get desc => 'Kegiatan di masjid, gereja, pura, dan tempat ibadah lain.';
}

// Path: jobs.tags.localNews.incidentReport
class _TranslationsJobsTagsLocalNewsIncidentReportId extends TranslationsJobsTagsLocalNewsIncidentReportKo {
	_TranslationsJobsTagsLocalNewsIncidentReportId._(TranslationsId root) : this._root = root, super.internal(root);

	final TranslationsId _root; // ignore: unused_field

	// Translations
	@override String get name => 'Laporan insiden';
	@override String get desc => 'Laporan kejadian dan kecelakaan di lingkungan.';
}

/// The flat map containing all translations for locale <id>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on TranslationsId {
	dynamic _flatMapFunction(String path) {
		return switch (path) {
			'login.title' => 'Masuk',
			'login.subtitle' => 'Beli dan jual dengan mudah di Bling!',
			'login.emailHint' => 'Alamat Email',
			'login.passwordHint' => 'Kata Sandi',
			'login.buttons.login' => 'Masuk',
			'login.buttons.google' => 'Lanjut dengan Google',
			'login.buttons.apple' => 'Lanjut dengan Apple',
			'login.links.findPassword' => 'Lupa kata sandi?',
			'login.links.askForAccount' => 'Belum punya akun?',
			'login.links.signUp' => 'Daftar',
			'login.alerts.invalidEmail' => 'Format email tidak valid.',
			'login.alerts.userNotFound' => 'Pengguna tidak ditemukan atau kata sandi salah.',
			'login.alerts.wrongPassword' => 'Kata sandi salah.',
			'login.alerts.unknownError' => 'Terjadi kesalahan. Silakan coba lagi.',
			'main.appBar.locationNotSet' => 'Lokasi belum diatur',
			'main.appBar.locationError' => 'Kesalahan lokasi',
			'main.appBar.locationLoading' => 'Memuat...',
			'main.tabs.newFeed' => 'Feed Baru',
			'main.tabs.localNews' => 'Berita Lingkungan',
			'main.tabs.marketplace' => 'Preloved',
			'main.tabs.findFriends' => 'Cari Teman',
			'main.tabs.clubs' => 'Klub',
			'main.tabs.jobs' => 'Pekerjaan',
			'main.tabs.localStores' => 'Toko Sekitar',
			'main.tabs.auction' => 'Lelang',
			'main.tabs.pom' => 'POM',
			'main.tabs.lostAndFound' => 'Hilang & Temuan',
			'main.tabs.realEstate' => 'Properti',
			'main.bottomNav.home' => 'Beranda',
			'main.bottomNav.board' => 'Lingkungan',
			'main.bottomNav.search' => 'Cari',
			'main.bottomNav.chat' => 'Chat',
			'main.bottomNav.myBling' => 'Bling Saya',
			'main.errors.loginRequired' => 'Harus masuk terlebih dahulu.',
			'main.errors.userNotFound' => 'Pengguna tidak ditemukan.',
			'main.errors.unknown' => 'Terjadi kesalahan.',
			'main.myTown' => 'Lingkungan Saya',
			'main.mapView.showMap' => 'Lihat peta',
			'main.mapView.showList' => 'Lihat daftar',
			'main.search.placeholder' => 'Cari',
			'main.search.chipPlaceholder' => 'Cari tetangga, berita, preloved, pekerjaan…',
			'main.search.hint.globalSheet' => 'Cari di {}',
			'main.search.hint.localNews' => 'Cari judul, isi, tag',
			'main.search.hint.jobs' => 'Cari pekerjaan, perusahaan, \'Bantu Saya\'',
			'main.search.hint.lostAndFound' => 'Cari barang hilang/temuan',
			'main.search.hint.marketplace' => 'Cari barang jual',
			'main.search.hint.localStores' => 'Cari toko atau layanan',
			'main.search.hint.findFriends' => 'Cari profil, minat',
			'main.search.hint.clubs' => 'Cari klub, minat, lokasi',
			'main.search.hint.realEstate' => 'Cari properti, area, harga',
			'main.search.hint.auction' => 'Cari barang lelang, merek',
			'main.search.hint.pom' => 'Cari POM, tag, pengguna',
			'search.resultsTitle' => 'Hasil untuk \'{keyword}\'',
			'search.empty.message' => 'Tidak ada hasil untuk \'{keyword}\'.',
			'search.empty.checkSpelling' => 'Periksa ejaan atau coba kata kunci lain.',
			'search.empty.expandToNational' => 'Cari secara Nasional',
			'search.prompt' => 'Ketik kata kunci',
			'search.sheet.localNews' => 'Cari Berita Lingkungan',
			'search.sheet.localNewsDesc' => 'Cari berdasarkan judul, isi, tag',
			'search.sheet.jobs' => 'Cari Pekerjaan',
			'search.sheet.jobsDesc' => 'Cari berdasarkan posisi, perusahaan, tag',
			'search.sheet.lostAndFound' => 'Cari Hilang & Temuan',
			'search.sheet.lostAndFoundDesc' => 'Cari berdasarkan nama barang atau lokasi',
			'search.sheet.marketplace' => 'Cari Preloved',
			'search.sheet.marketplaceDesc' => 'Cari berdasarkan nama barang, kategori, tag',
			'search.sheet.localStores' => 'Cari Toko Sekitar',
			'search.sheet.localStoresDesc' => 'Cari berdasarkan nama toko, jenis usaha, kata kunci',
			'search.sheet.clubs' => 'Cari Klub',
			'search.sheet.clubsDesc' => 'Cari berdasarkan nama klub, minat',
			'search.sheet.findFriends' => 'Cari Teman',
			'search.sheet.findFriendsDesc' => 'Cari berdasarkan nama panggilan atau minat',
			'search.sheet.realEstate' => 'Cari Properti',
			'search.sheet.realEstateDesc' => 'Cari berdasarkan judul, area, tag',
			'search.sheet.auction' => 'Cari Lelang',
			'search.sheet.auctionDesc' => 'Cari berdasarkan nama barang atau tag',
			'search.sheet.pom' => 'Cari POM',
			'search.sheet.pomDesc' => 'Cari berdasarkan judul atau hashtag',
			'search.sheet.comingSoon' => 'Segera hadir',
			'search.results' => 'hasil',
			'drawer.editProfile' => 'Edit Profil',
			'drawer.bookmarks' => 'Bookmark',
			'drawer.uploadSampleData' => 'Unggah Data Contoh',
			'drawer.logout' => 'Keluar',
			'drawer.trustDashboard.title' => 'Status Verifikasi Kepercayaan',
			'drawer.trustDashboard.kelurahanAuth' => 'Verifikasi Kelurahan',
			'drawer.trustDashboard.rtRwAuth' => 'Verifikasi Alamat (RT/RW)',
			'drawer.trustDashboard.phoneAuth' => 'Verifikasi Nomor Telepon',
			'drawer.trustDashboard.profileComplete' => 'Profil Lengkap',
			'drawer.trustDashboard.feedThanks' => 'Terima Kasih Feed',
			'drawer.trustDashboard.marketThanks' => 'Terima Kasih Marketplace',
			'drawer.trustDashboard.reports' => 'Laporan',
			'drawer.trustDashboard.breakdownButton' => 'Detail',
			'drawer.trustDashboard.breakdownModalTitle' => 'Rincian Skor Kepercayaan',
			'drawer.trustDashboard.breakdownClose' => 'OK',
			'drawer.trustDashboard.breakdown.kelurahanAuth' => '+50',
			'drawer.trustDashboard.breakdown.rtRwAuth' => '+50',
			'drawer.trustDashboard.breakdown.phoneAuth' => '+100',
			'drawer.trustDashboard.breakdown.profileComplete' => '+50',
			'drawer.trustDashboard.breakdown.feedThanks' => '+10 per',
			'drawer.trustDashboard.breakdown.marketThanks' => '+20 per',
			'drawer.trustDashboard.breakdown.reports' => '-50 per',
			'drawer.runDataFix' => 'Jalankan Perbaikan Data',
			'marketplace.error' => 'Terjadi kesalahan: {error}',
			'marketplace.empty' => 'Belum ada produk.\nKetuk tombol + untuk menambahkan barang pertama!',
			'marketplace.registration.title' => 'Posting Baru',
			'marketplace.registration.done' => 'Simpan',
			'marketplace.registration.titleHint' => 'Nama Barang',
			'marketplace.registration.priceHint' => 'Harga (Rp)',
			'marketplace.registration.negotiable' => 'Bisa Nego',
			'marketplace.registration.addressHint' => 'Lingkungan',
			'marketplace.registration.addressDetailHint' => 'Tempat Bertemu',
			'marketplace.registration.descriptionHint' => 'Deskripsi Lengkap',
			'marketplace.registration.success' => 'Produk berhasil diposting!',
			'marketplace.registration.tagsHint' => 'Tambah tag (tekan spasi untuk konfirmasi)',
			'marketplace.registration.fail' => 'gagal',
			'marketplace.edit.title' => 'Edit Postingan',
			'marketplace.edit.done' => 'Selesai Update',
			'marketplace.edit.titleHint' => 'Edit nama barang',
			'marketplace.edit.addressHint' => 'Edit lokasi',
			'marketplace.edit.priceHint' => 'Edit harga (Rp)',
			'marketplace.edit.negotiable' => 'Edit bisa nego',
			'marketplace.edit.descriptionHint' => 'Edit deskripsi',
			'marketplace.edit.tagsHint' => 'Tambah tag (tekan spasi untuk konfirmasi)',
			'marketplace.edit.success' => 'Produk berhasil diperbarui.',
			'marketplace.edit.fail' => 'Gagal mengupdate produk: {error}',
			'marketplace.edit.resetLocation' => 'Reset lokasi',
			'marketplace.edit.save' => 'Simpan perubahan',
			'marketplace.detail.makeOffer' => 'Ajukan penawaran',
			'marketplace.detail.fixedPrice' => 'Harga tetap',
			'marketplace.detail.description' => 'Deskripsi produk',
			'marketplace.detail.sellerInfo' => 'Info penjual',
			'marketplace.detail.chat' => 'Chat',
			'marketplace.detail.favorite' => 'Favorit',
			'marketplace.detail.unfavorite' => 'Hapus favorit',
			'marketplace.detail.share' => 'Bagikan',
			'marketplace.detail.edit' => 'Edit',
			'marketplace.detail.delete' => 'Hapus',
			'marketplace.detail.category' => 'Kategori',
			'marketplace.detail.categoryError' => 'Kategori: -',
			'marketplace.detail.categoryNone' => 'Tidak ada kategori',
			'marketplace.detail.views' => 'Dilihat',
			'marketplace.detail.likes' => 'Suka',
			'marketplace.detail.chats' => 'Chat',
			'marketplace.detail.noSeller' => 'Info penjual tidak tersedia.',
			'marketplace.detail.noLocation' => 'Info lokasi tidak tersedia.',
			'marketplace.detail.seller' => 'Penjual',
			'marketplace.detail.dealLocation' => 'Lokasi transaksi',
			'marketplace.dialog.deleteTitle' => 'Hapus postingan',
			'marketplace.dialog.deleteContent' => 'Apakah Anda yakin ingin menghapus postingan ini? Tindakan ini tidak bisa dibatalkan.',
			'marketplace.dialog.cancel' => 'Batal',
			'marketplace.dialog.deleteConfirm' => 'Hapus',
			'marketplace.dialog.deleteSuccess' => 'Postingan berhasil dihapus.',
			'marketplace.dialog.close' => 'Tutup',
			'marketplace.errors.deleteError' => 'Gagal menghapus postingan: {error}',
			'marketplace.errors.requiredField' => 'Kolom ini wajib diisi.',
			'marketplace.errors.noPhoto' => 'Tambahkan minimal 1 foto.',
			'marketplace.errors.noCategory' => 'Silakan pilih kategori.',
			'marketplace.errors.loginRequired' => 'Login diperlukan.',
			'marketplace.errors.userNotFound' => 'Data pengguna tidak ditemukan.',
			'marketplace.condition.label' => 'Kondisi',
			'marketplace.condition.kNew' => 'Baru',
			'marketplace.condition.used' => 'Bekas',
			'marketplace.reservation.title' => 'Pembayaran deposit 10%',
			'marketplace.reservation.content' => 'Untuk memesan produk yang sudah diverifikasi AI, Anda perlu membayar deposit 10% sebesar {amount}. Jika transaksi dibatalkan setelah verifikasi di tempat, deposit akan dikembalikan.',
			'marketplace.reservation.confirm' => 'Bayar & Pesan',
			'marketplace.reservation.button' => 'Pesan dengan Jaminan AI',
			'marketplace.reservation.success' => 'Reservasi berhasil. Silakan atur janji temu dengan penjual.',
			'marketplace.status.reserved' => 'Dipesan',
			'marketplace.status.sold' => 'Terjual',
			'marketplace.ai.cancelConfirm' => 'Batalkan verifikasi AI',
			'marketplace.ai.cancelLimit' => 'Verifikasi AI hanya dapat dibatalkan satu kali per produk. Permintaan ulang verifikasi AI dapat dikenakan biaya.',
			'marketplace.ai.cancelAckCharge' => 'Saya mengerti mungkin akan dikenakan biaya.',
			'marketplace.ai.cancelSuccess' => 'Verifikasi AI telah dibatalkan. Produk ini sekarang menjadi listing biasa.',
			'marketplace.ai.cancelError' => 'Terjadi kesalahan saat membatalkan verifikasi AI: {0}',
			'marketplace.takeover.button' => 'Ambil & verifikasi di tempat',
			'marketplace.takeover.title' => 'Verifikasi AI di Lokasi',
			'marketplace.takeover.guide.title' => 'Verifikasi kesesuaian di lokasi dengan AI',
			'marketplace.takeover.guide.subtitle' => 'Pastikan barang di lokasi sama dengan yang ada di laporan AI. Ambil minimal 3 foto yang jelas menunjukkan ciri utama barang.',
			'marketplace.takeover.photoTitle' => 'Ambil foto di lokasi',
			'marketplace.takeover.buttonVerify' => 'Mulai verifikasi kesesuaian AI',
			'marketplace.takeover.errors.noPhoto' => 'Minimal 1 foto di lokasi diperlukan untuk verifikasi.',
			'marketplace.takeover.dialog.matchTitle' => 'Verifikasi AI berhasil',
			'marketplace.takeover.dialog.noMatchTitle' => 'Verifikasi AI gagal',
			'marketplace.takeover.dialog.finalize' => 'Konfirmasi serah terima akhir',
			'marketplace.takeover.dialog.cancelDeal' => 'Batalkan transaksi (minta refund)',
			'marketplace.takeover.success.finalized' => 'Transaksi berhasil diselesaikan.',
			'marketplace.takeover.success.cancelled' => 'Transaksi dibatalkan. Deposit akan dikembalikan.',
			'marketplace.aiBadge' => 'Diverifikasi AI',
			'marketplace.setLocationPrompt' => 'Atur lingkungan Anda terlebih dahulu untuk melihat barang preloved!',
			'aiFlow.common.error' => 'Terjadi kesalahan: {error}',
			'aiFlow.common.addPhoto' => 'Tambah foto',
			'aiFlow.common.skip' => 'Lewati',
			'aiFlow.common.addedPhoto' => 'Foto ditambahkan: {}',
			'aiFlow.common.skipped' => 'Dilewati',
			'aiFlow.cta.title' => '🤖 Tingkatkan kepercayaan dengan verifikasi AI (opsional)',
			'aiFlow.cta.subtitle' => 'Dapatkan badge verifikasi AI untuk meningkatkan kepercayaan pembeli dan jual lebih cepat. Lengkapi semua info produk sebelum mulai.',
			'aiFlow.cta.startButton' => 'Mulai verifikasi AI',
			'aiFlow.cta.missingRequiredFields' => 'Masukkan nama barang, kategori, dan minimal satu gambar terlebih dahulu.',
			'aiFlow.categorySelection.title' => 'Verifikasi AI: Pilih kategori',
			'aiFlow.categorySelection.error' => 'Gagal memuat kategori.',
			'aiFlow.categorySelection.noCategories' => 'Tidak ada kategori yang tersedia untuk verifikasi.',
			'aiFlow.galleryUpload.title' => 'Verifikasi AI: Pilih foto',
			'aiFlow.galleryUpload.guide' => 'Unggah minimal {count} foto untuk verifikasi.',
			'aiFlow.galleryUpload.minPhotoError' => 'Anda harus memilih minimal {count} foto.',
			'aiFlow.galleryUpload.nextButton' => 'Minta analisis AI',
			'aiFlow.prediction.title' => 'Hasil analisis AI',
			'aiFlow.prediction.guide' => 'Ini adalah nama barang yang diprediksi AI.',
			'aiFlow.prediction.editLabel' => 'Edit nama barang',
			'aiFlow.prediction.editButton' => 'Edit manual',
			'aiFlow.prediction.saveButton' => 'Simpan perubahan',
			'aiFlow.prediction.noName' => 'Tidak ada nama barang.',
			'aiFlow.prediction.error' => 'Barang tidak dapat dikenali. Silakan coba lagi.',
			'aiFlow.prediction.authError' => 'Info autentikasi pengguna tidak ditemukan. Analisis tidak dapat dimulai.',
			'aiFlow.prediction.question' => 'Apakah nama barang ini sudah benar?',
			'aiFlow.prediction.confirmButton' => 'Ya, benar',
			'aiFlow.prediction.rejectButton' => 'Tidak, kembali',
			'aiFlow.prediction.analysisError' => 'Terjadi kesalahan saat analisis.',
			'aiFlow.prediction.retryButton' => 'Coba lagi',
			'aiFlow.prediction.backButton' => 'Kembali',
			'aiFlow.guidedCamera.title' => 'Panduan AI: bukti foto yang kurang',
			'aiFlow.guidedCamera.guide' => 'Untuk meningkatkan kepercayaan, tambahkan foto sesuai saran berikut.',
			'aiFlow.guidedCamera.locationMismatchError' => 'Lokasi foto tidak sama dengan lokasi Anda sekarang. Harap ambil foto di tempat yang sama.',
			'aiFlow.guidedCamera.locationPermissionError' => 'Izin lokasi ditolak. Aktifkan izin lokasi di pengaturan.',
			'aiFlow.guidedCamera.noLocationDataError' => 'Tidak ada data lokasi di foto. Aktifkan tag lokasi di pengaturan kamera.',
			'aiFlow.guidedCamera.nextButton' => 'Buat laporan akhir',
			'aiFlow.finalReport.title' => 'Laporan Verifikasi AI',
			'aiFlow.finalReport.guide' => 'AI membuat draft listing. Edit konten lalu selesaikan pendaftaran.',
			'aiFlow.finalReport.loading' => 'AI sedang membuat laporan akhir...',
			'aiFlow.finalReport.error' => 'Gagal membuat laporan.',
			'aiFlow.finalReport.success' => 'Laporan akhir berhasil dibuat.',
			'aiFlow.finalReport.submitButton' => 'Daftarkan untuk dijual',
			'aiFlow.finalReport.suggestedPrice' => 'Harga yang disarankan AI ({})',
			'aiFlow.finalReport.summary' => 'Ringkasan verifikasi',
			'aiFlow.finalReport.buyerNotes' => 'Catatan untuk pembeli (AI)',
			'aiFlow.finalReport.keySpecs' => 'Spesifikasi utama',
			'aiFlow.finalReport.condition' => 'Pemeriksaan kondisi',
			'aiFlow.finalReport.includedItems' => 'Barang termasuk (pisahkan dengan koma)',
			'aiFlow.finalReport.finalDescription' => 'Deskripsi akhir',
			'aiFlow.finalReport.applySuggestions' => 'Terapkan saran ke deskripsi',
			'aiFlow.finalReport.includedItemsLabel' => 'Barang termasuk',
			'aiFlow.finalReport.buyerNotesLabel' => 'Catatan pembeli',
			'aiFlow.finalReport.skippedItems' => 'Item bukti yang dilewati',
			'aiFlow.finalReport.fail' => 'Gagal membuat laporan akhir: {error}',
			'aiFlow.evidence.allShotsRequired' => 'Semua foto yang disarankan wajib diunggah.',
			'aiFlow.evidence.title' => 'Foto bukti',
			'aiFlow.evidence.submitButton' => 'Kirim bukti',
			'aiFlow.error.reportGeneration' => 'Gagal membuat laporan AI: {error}',
			'registrationFlow.title' => 'Pilih jenis barang yang akan dijual',
			'registrationFlow.newItemTitle' => 'Daftar barang baru & bekas biasa',
			'registrationFlow.newItemDesc' => 'Daftarkan barang baru yang tidak terpakai dan barang bekas biasa dengan cepat.',
			'registrationFlow.usedItemTitle' => 'Barang bekas (Verifikasi AI)',
			'registrationFlow.usedItemDesc' => 'AI menganalisis barang Anda untuk membangun kepercayaan dan membantu penjualan.',
			'myBling.title' => 'Bling Saya',
			'myBling.editProfile' => 'Edit profil',
			'myBling.settings' => 'Pengaturan',
			'myBling.posts' => 'Postingan',
			'myBling.followers' => 'Pengikut',
			'myBling.neighbors' => 'Tetangga',
			'myBling.friends' => 'Teman',
			'myBling.stats.posts' => 'Postingan',
			'myBling.stats.followers' => 'Pengikut',
			'myBling.stats.neighbors' => 'Tetangga',
			'myBling.stats.friends' => 'Teman',
			'myBling.tabs.posts' => 'Postingan saya',
			'myBling.tabs.products' => 'Produk saya',
			'myBling.tabs.bookmarks' => 'Bookmark',
			'myBling.tabs.friends' => 'Teman',
			'myBling.friendRequests' => 'Permintaan pertemanan diterima',
			'myBling.sentFriendRequests' => 'Permintaan yang dikirim',
			'profileView.title' => 'Profil',
			'profileView.tabs.posts' => 'Postingan',
			'profileView.tabs.interests' => 'Minat',
			'profileView.noPosts' => 'Belum ada postingan.',
			'profileView.noInterests' => 'Belum ada minat yang disetel.',
			'settings.title' => 'Pengaturan',
			'settings.accountPrivacy' => 'Akun & Privasi',
			'settings.notifications.loadError' => 'Gagal memuat pengaturan notifikasi.',
			'settings.notifications.saveSuccess' => 'Pengaturan notifikasi berhasil disimpan.',
			'settings.notifications.saveError' => 'Gagal menyimpan pengaturan notifikasi.',
			'settings.notifications.scopeTitle' => 'Jangkauan notifikasi',
			'settings.notifications.scopeDescription' => 'Pilih seberapa luas notifikasi yang ingin diterima (hanya lingkungan saya, area sekitar, dll.).',
			'settings.notifications.scopeLabel' => 'Jangkauan notifikasi',
			'settings.notifications.tagsTitle' => 'Topik notifikasi',
			'settings.notifications.tagsDescription' => 'Pilih topik apa saja yang ingin Anda terima (berita, kerja, marketplace, dll.).',
			'settings.appInfo' => 'Info aplikasi',
			'friendRequests.title' => 'Permintaan pertemanan diterima',
			'friendRequests.noRequests' => 'Belum ada permintaan pertemanan.',
			'friendRequests.acceptSuccess' => 'Permintaan pertemanan diterima.',
			'friendRequests.rejectSuccess' => 'Permintaan pertemanan ditolak.',
			'friendRequests.error' => 'Terjadi kesalahan: {error}',
			'friendRequests.tooltip.accept' => 'Terima',
			'friendRequests.tooltip.reject' => 'Tolak',
			'friendRequests.defaultChatMessage' => 'Sekarang kalian sudah berteman! Mulai ngobrol, yuk.',
			'sentFriendRequests.title' => 'Permintaan pertemanan terkirim',
			'sentFriendRequests.noRequests' => 'Belum ada permintaan pertemanan yang dikirim.',
			'sentFriendRequests.statusLabel' => 'Status: {status}',
			'sentFriendRequests.status.pending' => 'Menunggu',
			'sentFriendRequests.status.accepted' => 'Diterima',
			'sentFriendRequests.status.rejected' => 'Ditolak',
			'blockedUsers.title' => 'Pengguna yang diblokir',
			'blockedUsers.noBlockedUsers' => 'Anda belum memblokir siapa pun.',
			'blockedUsers.unblock' => 'Buka blokir',
			'blockedUsers.unblockDialog.title' => 'Buka blokir {nickname}?',
			'blockedUsers.unblockDialog.content' => 'Setelah dibuka blokirnya, pengguna ini bisa muncul lagi di daftar Find Friends Anda.',
			'blockedUsers.unblockSuccess' => 'Blokir untuk {nickname} telah dibuka.',
			'blockedUsers.unblockFailure' => 'Gagal membuka blokir: {error}',
			'blockedUsers.unknownUser' => 'Pengguna tidak dikenal',
			'blockedUsers.empty' => 'Tidak ada pengguna yang diblokir.',
			'rejectedUsers.title' => 'Kelola pengguna yang ditolak',
			'rejectedUsers.noRejectedUsers' => 'Tidak ada permintaan pertemanan yang Anda tolak.',
			'rejectedUsers.unreject' => 'Batalkan penolakan',
			'rejectedUsers.unrejectDialog.title' => 'Batalkan penolakan untuk {nickname}?',
			'rejectedUsers.unrejectDialog.content' => 'Jika dibatalkan, Anda bisa muncul lagi di daftar Find Friends mereka.',
			'rejectedUsers.unrejectSuccess' => 'Penolakan untuk {nickname} telah dibatalkan.',
			'rejectedUsers.unrejectFailure' => 'Gagal membatalkan penolakan: {error}',
			'prompt.title' => 'Selamat datang di Bling!',
			'prompt.subtitle' => 'Untuk melihat berita dan barang di sekitar, atur lingkungan Anda terlebih dahulu.',
			'prompt.button' => 'Atur Lingkungan Saya',
			'location.title' => 'Atur Lingkungan',
			'location.searchHint' => 'Cari berdasarkan nama lingkungan, mis. Serpong',
			'location.gpsButton' => 'Gunakan lokasi saat ini',
			'location.success' => 'Lingkungan berhasil disetel.',
			'location.error' => 'Gagal menyetel lingkungan: {error}',
			'location.empty' => 'Silakan masukkan nama lingkungan.',
			'location.permissionDenied' => 'Izin lokasi diperlukan untuk menemukan lingkungan Anda.',
			'location.rtLabel' => 'RT',
			'location.rwLabel' => 'RW',
			'location.rtHint' => 'mis. 003',
			'location.rwHint' => 'mis. 007',
			'location.rtRequired' => 'Silakan masukkan RT.',
			'location.rwRequired' => 'Silakan masukkan RW.',
			'location.rtRwInfo' => 'RT/RW Anda tidak akan ditampilkan ke publik. Data ini hanya digunakan untuk meningkatkan kepercayaan dan fitur lokal.',
			'location.saveThisLocation' => 'Simpan lokasi ini',
			'location.manualSelect' => 'Pilih manual',
			'location.refreshFromGps' => 'Perbarui dari GPS',
			'profileEdit.title' => 'Pengaturan profil',
			'profileEdit.nicknameHint' => 'Nama panggilan',
			'profileEdit.phoneHint' => 'Nomor telepon',
			'profileEdit.bioHint' => 'Bio',
			'profileEdit.locationTitle' => 'Lokasi',
			'profileEdit.changeLocation' => 'Ubah',
			'profileEdit.locationNotSet' => 'Belum disetel',
			'profileEdit.interests.title' => 'Minat',
			'profileEdit.interests.hint' => 'Gunakan koma dan Enter untuk menambahkan beberapa item',
			'profileEdit.privacy.title' => 'Pengaturan privasi',
			'profileEdit.privacy.showLocation' => 'Tampilkan lokasi saya di peta',
			'profileEdit.privacy.allowRequests' => 'Izinkan permintaan pertemanan',
			'profileEdit.saveButton' => 'Simpan perubahan',
			'profileEdit.successMessage' => 'Profil berhasil diperbarui.',
			'profileEdit.errors.noUser' => 'Tidak ada pengguna yang login.',
			'profileEdit.errors.updateFailed' => 'Gagal memperbarui profil: {error}',
			'mainFeed.error' => 'Terjadi kesalahan: {error}',
			'mainFeed.empty' => 'Belum ada postingan baru.',
			'postCard.locationNotSet' => 'Lokasi belum disetel',
			'postCard.location' => 'Lokasi',
			'postCard.authorNotFound' => 'Penulis tidak ditemukan',
			'time.now' => 'Baru saja',
			'time.minutesAgo' => '{minutes} menit yang lalu',
			'time.hoursAgo' => '{hours} jam yang lalu',
			'time.daysAgo' => '{days} hari yang lalu',
			'time.dateFormat' => 'yy.MM.dd',
			'time.dateFormatLong' => 'd MMM',
			'productCard.currency' => '\$',
			'localNewsFeed.setLocationPrompt' => 'Atur lingkungan Anda untuk melihat cerita lokal!',
			'localNewsFeed.allCategory' => 'Semua',
			'localNewsFeed.empty' => 'Tidak ada postingan untuk ditampilkan.',
			'localNewsFeed.error' => 'Terjadi kesalahan: {error}',
			'categories.post.jalanPerbaikin.search.hint' => 'Cari POM, tag, pengguna',
			'categories.post.jalanPerbaikin.name' => 'Perbaikan jalan',
			'categories.post.dailyLife.name' => 'Sehari-hari/Pertanyaan',
			'categories.post.dailyLife.description' => 'Bagikan kehidupan sehari-hari atau ajukan pertanyaan.',
			'categories.post.helpShare.name' => 'Bantuan/ Berbagi',
			'categories.post.helpShare.description' => 'Butuh bantuan atau ingin berbagi sesuatu? Posting di sini.',
			'categories.post.incidentReport.name' => 'Insiden',
			'categories.post.incidentReport.description' => 'Bagikan kabar insiden di lingkungan Anda.',
			'categories.post.localNews.name' => 'Berita lingkungan',
			'categories.post.localNews.description' => 'Bagikan berita dan informasi tentang lingkungan kita.',
			'categories.post.november.name' => 'November',
			'categories.post.rain.name' => 'Hujan',
			'categories.post.dailyQuestion.name' => 'Ada pertanyaan?',
			'categories.post.dailyQuestion.description' => 'Tanyakan apa saja kepada tetangga Anda.',
			'categories.post.storePromo.name' => 'Promo toko',
			'categories.post.storePromo.description' => 'Promosikan diskon atau event di toko Anda.',
			'categories.post.etc.name' => 'Lainnya',
			'categories.post.etc.description' => 'Bagikan cerita lain secara bebas.',
			'categories.auction.all' => 'Semua',
			'categories.auction.collectibles.name' => 'Koleksi',
			'categories.auction.collectibles.description' => 'Mainan, kartu, figur, dan lainnya.',
			'categories.auction.digital.name' => 'Digital',
			'categories.auction.digital.description' => 'Produk dan aset digital.',
			'categories.auction.fashion.name' => 'Fashion',
			'categories.auction.fashion.description' => 'Pakaian, aksesori, dan kecantikan.',
			'categories.auction.vintage.name' => 'Vintage',
			'categories.auction.vintage.description' => 'Barang retro dan klasik.',
			'categories.auction.artCraft.name' => 'Seni & kerajinan',
			'categories.auction.artCraft.description' => 'Karya seni dan kerajinan tangan.',
			'categories.auction.etc.name' => 'Lainnya',
			'categories.auction.etc.description' => 'Barang lelang lainnya.',
			'localNewsCreate.appBarTitle' => 'Buat postingan baru',
			'localNewsCreate.title' => 'Buat postingan baru',
			'localNewsCreate.form.categoryLabel' => 'Kategori',
			'localNewsCreate.form.titleLabel' => 'Judul',
			'localNewsCreate.form.contentLabel' => 'Tulis konten',
			'localNewsCreate.form.tagsLabel' => 'Tag',
			'localNewsCreate.form.tagsHint' => 'Tambahkan tag (tekan spasi untuk konfirmasi)',
			'localNewsCreate.form.recommendedTags' => 'Tag yang disarankan',
			'localNewsCreate.labels.title' => 'Judul',
			'localNewsCreate.labels.body' => 'Konten',
			'localNewsCreate.labels.tags' => 'Tag',
			'localNewsCreate.labels.guidedTitle' => 'Info tambahan (opsional)',
			'localNewsCreate.labels.eventLocation' => 'Lokasi acara/kejadian',
			'localNewsCreate.hints.body' => 'Bagikan berita lingkungan atau ajukan pertanyaan ke tetangga...',
			'localNewsCreate.hints.tagSelection' => '(Pilih 1–3 tag)',
			'localNewsCreate.hints.eventLocation' => 'mis. Jl. Sudirman 123',
			'localNewsCreate.validation.bodyRequired' => 'Silakan isi konten.',
			'localNewsCreate.validation.tagRequired' => 'Silakan pilih minimal satu tag.',
			'localNewsCreate.validation.tagMaxLimit' => 'Anda bisa memilih maksimal 3 tag.',
			'localNewsCreate.validation.imageMaxLimit' => 'Anda bisa melampirkan maksimal 5 gambar.',
			'localNewsCreate.validation.titleRequired' => 'Silakan masukkan judul.',
			'localNewsCreate.buttons.addImage' => 'Tambah gambar',
			'localNewsCreate.buttons.submit' => 'Kirim',
			'localNewsCreate.alerts.contentRequired' => 'Silakan isi konten.',
			'localNewsCreate.alerts.categoryRequired' => 'Silakan pilih kategori.',
			'localNewsCreate.alerts.success' => 'Postingan berhasil dibuat.',
			'localNewsCreate.alerts.failure' => 'Gagal mengunggah: {error}',
			'localNewsCreate.alerts.loginRequired' => 'Anda harus login untuk membuat postingan.',
			'localNewsCreate.alerts.userNotFound' => 'Info pengguna tidak ditemukan.',
			'localNewsCreate.success' => 'Postingan berhasil dibuat.',
			'localNewsCreate.fail' => 'Gagal membuat postingan: {error}',
			'localNewsDetail.appBarTitle' => 'Postingan',
			'localNewsDetail.menu.edit' => 'Edit',
			'localNewsDetail.menu.report' => 'Laporkan',
			'localNewsDetail.menu.share' => 'Bagikan',
			'localNewsDetail.stats.views' => 'Dilihat',
			'localNewsDetail.stats.comments' => 'Komentar',
			'localNewsDetail.stats.likes' => 'Suka',
			'localNewsDetail.stats.thanks' => 'Terima kasih',
			'localNewsDetail.buttons.comment' => 'Tambah komentar',
			'localNewsDetail.confirmDelete' => 'Yakin ingin menghapus postingan ini?',
			'localNewsDetail.deleted' => 'Postingan telah dihapus.',
			'localNewsEdit.appBarTitle' => 'Edit postingan',
			'localNewsEdit.buttons.submit' => 'Perbarui',
			'localNewsEdit.alerts.success' => 'Postingan berhasil diperbarui.',
			'localNewsEdit.alerts.failure' => 'Gagal memperbarui: {error}',
			'commentInputField.secretCommentLabel' => 'Rahasia',
			'commentInputField.hintText' => 'Tulis komentar...',
			'commentInputField.replyHintText' => 'Membalas {nickname}...',
			'commentInputField.button.send' => 'Kirim',
			'commentListView.empty' => 'Belum ada komentar. Jadilah yang pertama!',
			'commentListView.reply' => 'Balas',
			'commentListView.delete' => 'Hapus',
			'commentListView.deleted' => '[Komentar ini telah dihapus]',
			'commentListView.secret' => 'Ini adalah komentar rahasia yang hanya bisa dilihat penulis dan pemilik postingan.',
			'common.cancel' => 'Batal',
			'common.confirm' => 'OK',
			'common.delete' => 'Hapus',
			'common.done' => 'Selesai',
			'common.clear' => 'Bersihkan',
			'common.report' => 'Laporkan',
			'common.moreOptions' => 'Lainnya',
			'common.viewAll' => 'Lihat semua',
			'common.kNew' => 'Baru',
			'common.updated' => 'Diperbarui',
			'common.comments' => 'Komentar',
			'common.sponsored' => 'Sponsor',
			'common.filter' => 'Filter',
			'common.reset' => 'Reset',
			'common.apply' => 'Terapkan',
			'common.verified' => 'Terverifikasi',
			'common.bookmark' => 'Bookmark',
			'common.sort.kDefault' => 'Default',
			'common.sort.distance' => 'Jarak',
			'common.sort.popular' => 'Populer',
			'common.error' => 'Terjadi kesalahan.',
			'common.shareError' => 'Gagal membagikan. Silakan coba lagi.',
			'common.edit' => 'Edit',
			'common.submit' => 'Kirim',
			'common.loginRequired' => 'Login diperlukan.',
			'common.unknownUser' => 'Pengguna tidak dikenal.',
			'reportDialog.title' => 'Laporkan postingan',
			'reportDialog.titleComment' => 'Laporkan komentar',
			'reportDialog.titleReply' => 'Laporkan balasan',
			'reportDialog.cannotReportSelfComment' => 'Anda tidak dapat melaporkan komentar Anda sendiri.',
			'reportDialog.cannotReportSelfReply' => 'Anda tidak dapat melaporkan balasan Anda sendiri.',
			'reportDialog.success' => 'Laporan telah dikirim. Terima kasih.',
			'reportDialog.fail' => 'Gagal mengirim laporan: {error}',
			'reportDialog.cannotReportSelf' => 'Anda tidak dapat melaporkan postingan Anda sendiri.',
			'replyDelete.fail' => 'Gagal menghapus balasan: {error}',
			'reportReasons.spam' => 'Spam atau menyesatkan',
			'reportReasons.abuse' => 'Pelecehan atau ujaran kebencian',
			'reportReasons.inappropriate' => 'Tidak pantas secara seksual',
			'reportReasons.illegal' => 'Konten ilegal',
			'reportReasons.etc' => 'Lainnya',
			'deleteConfirm.title' => 'Hapus komentar',
			'deleteConfirm.content' => 'Yakin ingin menghapus komentar ini?',
			'deleteConfirm.failure' => 'Gagal menghapus komentar: {error}',
			'replyInputField.hintText' => 'Tulis balasan',
			'replyInputField.button.send' => 'Kirim',
			'replyInputField.failure' => 'Gagal menambahkan balasan: {error}',
			'chatList.appBarTitle' => 'Chat',
			'chatList.empty' => 'Belum ada percakapan.',
			'chatRoom.startConversation' => 'Mulai percakapan',
			'chatRoom.icebreaker1' => 'Halo! 👋',
			'chatRoom.icebreaker2' => 'Biasanya kamu ngapain kalau weekend?',
			'chatRoom.icebreaker3' => 'Ada tempat favorit di sekitar sini?',
			'chatRoom.mediaBlocked' => 'Demi keamanan, pengiriman media dibatasi selama 24 jam.',
			'chatRoom.imageMessage' => 'Gambar',
			'chatRoom.linkHidden' => 'Mode perlindungan: tautan disembunyikan',
			'chatRoom.contactHidden' => 'Mode perlindungan: kontak disembunyikan',
			'jobs.setLocationPrompt' => 'Atur lokasi Anda untuk melihat lowongan kerja!',
			'jobs.screen.empty' => 'Belum ada lowongan kerja di area ini.',
			'jobs.screen.createTooltip' => 'Pasang lowongan',
			_ => null,
		} ?? switch (path) {
			'jobs.tabs.all' => 'Semua',
			'jobs.tabs.quickGig' => 'Gig singkat',
			'jobs.tabs.regular' => 'Paruh waktu/Penuh waktu',
			'jobs.selectType.title' => 'Pilih jenis lowongan',
			'jobs.selectType.regularTitle' => 'Lowongan paruh waktu / penuh waktu',
			'jobs.selectType.regularDesc' => 'Pekerjaan reguler seperti kafe, restoran, kantor',
			'jobs.selectType.quickGigTitle' => 'Gig singkat / bantuan sederhana',
			'jobs.selectType.quickGigDesc' => 'Antar dokumen, pindahan, bersih-bersih, dan lain-lain',
			'jobs.form.title' => 'Pasang lowongan kerja',
			'jobs.form.titleHint' => 'Judul lowongan',
			'jobs.form.descriptionPositionHint' => 'Jelaskan posisi yang dicari',
			'jobs.form.categoryHint' => 'Kategori',
			'jobs.form.categorySelectHint' => 'Pilih kategori',
			'jobs.form.categoryValidator' => 'Silakan pilih kategori.',
			'jobs.form.locationHint' => 'Lokasi kerja',
			'jobs.form.submit' => 'Pasang lowongan',
			'jobs.form.titleLabel' => 'Judul',
			'jobs.form.titleValidator' => 'Silakan masukkan judul.',
			'jobs.form.titleRegular' => 'Pasang lowongan paruh waktu/penuh waktu',
			'jobs.form.titleQuickGig' => 'Pasang gig singkat',
			'jobs.form.validationError' => 'Silakan isi semua kolom wajib.',
			'jobs.form.saveSuccess' => 'Lowongan kerja berhasil disimpan.',
			'jobs.form.saveError' => 'Gagal menyimpan lowongan kerja: {error}',
			'jobs.form.categoryLabel' => 'Kategori',
			'jobs.form.titleHintQuickGig' => 'mis. Antar dokumen pakai motor (ASAP)',
			'jobs.form.salaryLabel' => 'Gaji (IDR)',
			'jobs.form.salaryHint' => 'Masukkan jumlah gaji',
			'jobs.form.salaryValidator' => 'Silakan masukkan jumlah gaji yang valid.',
			'jobs.form.totalPayLabel' => 'Total bayaran (IDR)',
			'jobs.form.totalPayHint' => 'Masukkan total bayaran yang ditawarkan',
			'jobs.form.totalPayValidator' => 'Silakan masukkan jumlah yang valid.',
			'jobs.form.negotiable' => 'Bisa nego',
			'jobs.form.workPeriodLabel' => 'Periode kerja',
			'jobs.form.workPeriodHint' => 'Pilih periode kerja',
			'jobs.form.locationLabel' => 'Lokasi / tempat kerja',
			'jobs.form.locationValidator' => 'Silakan masukkan lokasi.',
			'jobs.form.imageLabel' => 'Gambar (Opsional, maks 10)',
			'jobs.form.descriptionHintQuickGig' => 'Tulis detailnya (mis. titik jemput, tujuan, permintaan khusus).',
			'jobs.form.salaryInfoTitle' => 'Info gaji',
			'jobs.form.salaryTypeHint' => 'Jenis pembayaran',
			'jobs.form.salaryAmountLabel' => 'Nominal (IDR)',
			'jobs.form.salaryNegotiable' => 'Gaji bisa dinegosiasikan',
			'jobs.form.workInfoTitle' => 'Syarat kerja',
			'jobs.form.workPeriodTitle' => 'Periode kerja',
			'jobs.form.workHoursLabel' => 'Hari/Jam kerja',
			'jobs.form.workHoursHint' => 'mis. Senin–Jumat, 09.00–18.00',
			'jobs.form.imageSectionTitle' => 'Lampirkan foto (opsional, maks 5)',
			'jobs.form.descriptionLabel' => 'Deskripsi',
			'jobs.form.descriptionHint' => 'mis. Part-time 3 hari seminggu, jam 5–10 sore. Gaji bisa nego.',
			'jobs.form.descriptionValidator' => 'Silakan masukkan deskripsi.',
			'jobs.form.submitSuccess' => 'Lowongan kerja berhasil dipasang.',
			'jobs.form.submitFail' => 'Gagal memasang lowongan kerja: {error}',
			'jobs.categories.restaurant' => 'Restoran',
			'jobs.categories.cafe' => 'Kafe',
			'jobs.categories.retail' => 'Ritel/Toko',
			'jobs.categories.delivery' => 'Kurir/Antar',
			'jobs.categories.etc' => 'Lainnya',
			'jobs.categories.service' => 'Jasa/Service',
			'jobs.categories.salesMarketing' => 'Sales/Marketing',
			'jobs.categories.deliveryLogistics' => 'Pengiriman/Logistik',
			'jobs.categories.it' => 'IT/Teknologi',
			'jobs.categories.design' => 'Desain',
			'jobs.categories.education' => 'Pendidikan',
			'jobs.categories.quickGigDelivery' => 'Antar barang pakai motor',
			'jobs.categories.quickGigTransport' => 'Antar orang pakai motor (ojek)',
			'jobs.categories.quickGigMoving' => 'Bantu pindahan',
			'jobs.categories.quickGigCleaning' => 'Bersih-bersih/Rumah tangga',
			'jobs.categories.quickGigQueuing' => 'Antri menggantikan',
			'jobs.categories.quickGigEtc' => 'Jasa titip/bantuan lainnya',
			'jobs.salaryTypes.hourly' => 'Per jam',
			'jobs.salaryTypes.daily' => 'Harian',
			'jobs.salaryTypes.weekly' => 'Mingguan',
			'jobs.salaryTypes.monthly' => 'Bulanan',
			'jobs.salaryTypes.total' => 'Total',
			'jobs.salaryTypes.perCase' => 'Per kasus',
			'jobs.salaryTypes.etc' => 'Lainnya',
			'jobs.salaryTypes.yearly' => 'Tahunan',
			'jobs.workPeriods.shortTerm' => 'Jangka pendek',
			'jobs.workPeriods.midTerm' => 'Jangka menengah',
			'jobs.workPeriods.longTerm' => 'Jangka panjang',
			'jobs.workPeriods.oneTime' => 'Satu kali',
			'jobs.workPeriods.k1Week' => '1 minggu',
			'jobs.workPeriods.k1Month' => '1 bulan',
			'jobs.workPeriods.k3Months' => '3 bulan',
			'jobs.workPeriods.k6MonthsPlus' => '6 bulan ke atas',
			'jobs.workPeriods.negotiable' => 'Bisa dinegosiasikan',
			'jobs.workPeriods.etc' => 'Lainnya',
			'jobs.detail.infoTitle' => 'Detail',
			'jobs.detail.apply' => 'Lamar',
			'jobs.detail.noAuthor' => 'Info pembuat tidak tersedia',
			'jobs.detail.chatError' => 'Tidak dapat memulai chat: {error}',
			'jobs.card.noLocation' => 'Lokasi tidak tersedia',
			'jobs.card.minutesAgo' => 'menit lalu',
			'jobs.findFriend.title' => 'Cari Teman',
			'jobs.findFriend.tabs.friends' => 'Teman',
			'jobs.findFriend.tabs.groups' => 'Grup',
			'jobs.findFriend.tabs.clubs' => 'Klub',
			'jobs.findFriend.editTitle' => 'Edit Profil Cari Teman',
			'jobs.findFriend.editProfileTitle' => 'Edit Profil',
			'jobs.findFriend.save' => 'Simpan',
			'jobs.findFriend.profileImagesLabel' => 'Foto Profil (maks 6)',
			'jobs.findFriend.bioLabel' => 'Bio',
			'jobs.findFriend.bioHint' => 'Perkenalkan diri Anda kepada orang lain.',
			'jobs.findFriend.bioValidator' => 'Silakan isi bio.',
			'jobs.findFriend.ageLabel' => 'Usia',
			'jobs.findFriend.ageHint' => 'Masukkan usia Anda.',
			'jobs.findFriend.genderLabel' => 'Jenis kelamin',
			'jobs.findFriend.genderMale' => 'Pria',
			'jobs.findFriend.genderFemale' => 'Wanita',
			'jobs.findFriend.genderHint' => 'Pilih jenis kelamin',
			'jobs.findFriend.interestsLabel' => 'Minat',
			'jobs.findFriend.preferredAgeLabel' => 'Usia teman yang diinginkan',
			'jobs.findFriend.preferredAgeUnit' => 'thn',
			'jobs.findFriend.preferredGenderLabel' => 'Jenis kelamin teman yang diinginkan',
			'jobs.findFriend.preferredGenderAll' => 'Semua',
			'jobs.findFriend.showProfileLabel' => 'Tampilkan profil saya di daftar',
			'jobs.findFriend.showProfileSubtitle' => 'Jika dimatikan, orang lain tidak bisa menemukan Anda.',
			'jobs.findFriend.saveSuccess' => 'Profil berhasil disimpan!',
			'jobs.findFriend.saveFailed' => 'Gagal menyimpan profil:',
			'jobs.findFriend.loginRequired' => 'Login diperlukan.',
			'jobs.findFriend.noFriendsFound' => 'Belum ada teman terdekat yang ditemukan.',
			'jobs.findFriend.promptTitle' => 'Untuk bertemu teman baru,\nbuat profil Anda terlebih dahulu!',
			'jobs.findFriend.promptButton' => 'Buat Profil Saya',
			'jobs.findFriend.chatLimitReached' => 'Anda telah mencapai batas harian ({limit}) untuk memulai chat baru.',
			'jobs.findFriend.chatChecking' => 'Memeriksa...',
			'jobs.findFriend.empty' => 'Belum ada profil untuk ditampilkan.',
			'jobs.interests.title' => 'Minat',
			'jobs.interests.limitInfo' => 'Anda bisa memilih hingga 10 minat.',
			'jobs.interests.limitReached' => 'Anda hanya bisa memilih hingga 10 minat.',
			'jobs.interests.categoryCreative' => '🎨 Kreatif',
			'jobs.interests.categorySports' => '🏃 Olahraga & Aktivitas',
			'jobs.interests.categoryFoodDrink' => '🍸 Makanan & Minuman',
			'jobs.interests.categoryEntertainment' => '🍿 Hiburan',
			'jobs.interests.categoryGrowth' => '📚 Pengembangan diri',
			'jobs.interests.categoryLifestyle' => '🌴 Gaya hidup',
			'jobs.interests.items.drawing' => 'Menggambar',
			'jobs.interests.items.instrument' => 'Main alat musik',
			'jobs.interests.items.photography' => 'Fotografi',
			'jobs.interests.items.writing' => 'Menulis',
			'jobs.interests.items.crafting' => 'Kerajinan tangan',
			'jobs.interests.items.gardening' => 'Berkebun',
			'jobs.interests.items.soccer' => 'Sepak bola/Futsal',
			'jobs.interests.items.hiking' => 'Mendaki',
			'jobs.interests.items.camping' => 'Berkemah',
			'jobs.interests.items.running' => 'Lari/Jogging',
			'jobs.interests.items.biking' => 'Bersepeda',
			'jobs.interests.items.golf' => 'Golf',
			'jobs.interests.items.workout' => 'Workout/Fitness',
			'jobs.interests.items.foodie' => 'Pencinta kuliner',
			'jobs.interests.items.cooking' => 'Memasak',
			'jobs.interests.items.baking' => 'Baking',
			'jobs.interests.items.coffee' => 'Kopi',
			'jobs.interests.items.wine' => 'Wine/Minuman',
			'jobs.interests.items.tea' => 'Teh',
			'jobs.interests.items.movies' => 'Film/Drama',
			'jobs.interests.items.music' => 'Mendengarkan musik',
			'jobs.interests.items.concerts' => 'Konser/Festival',
			'jobs.interests.items.gaming' => 'Gaming',
			'jobs.interests.items.reading' => 'Membaca',
			'jobs.interests.items.investing' => 'Investasi',
			'jobs.interests.items.language' => 'Belajar bahasa',
			'jobs.interests.items.coding' => 'Coding',
			'jobs.interests.items.travel' => 'Travel',
			'jobs.interests.items.pets' => 'Hewan peliharaan',
			'jobs.interests.items.volunteering' => 'Relawan',
			'jobs.interests.items.minimalism' => 'Minimalisme',
			'jobs.friendDetail.request' => 'Kirim permintaan',
			'jobs.friendDetail.requestSent' => 'Dikirim',
			'jobs.friendDetail.alreadyFriends' => 'Sudah berteman',
			'jobs.friendDetail.requestFailed' => 'Gagal mengirim permintaan:',
			'jobs.friendDetail.chatError' => 'Tidak dapat memulai chat.',
			'jobs.friendDetail.startChat' => 'Mulai chat',
			'jobs.friendDetail.block' => 'Blokir',
			'jobs.friendDetail.report' => 'Laporkan',
			'jobs.friendDetail.loginRequired' => 'Login diperlukan.',
			'jobs.friendDetail.unblocked' => 'Pengguna telah dibuka blokirnya.',
			'jobs.friendDetail.blocked' => 'Pengguna telah diblokir.',
			'jobs.friendDetail.unblock' => 'Buka blokir',
			'jobs.locationFilter.title' => 'Filter lokasi',
			'jobs.locationFilter.provinsi' => 'Provinsi',
			'jobs.locationFilter.kabupaten' => 'Kabupaten',
			'jobs.locationFilter.kota' => 'Kota',
			'jobs.locationFilter.kecamatan' => 'Kecamatan',
			'jobs.locationFilter.kelurahan' => 'Kelurahan',
			'jobs.locationFilter.apply' => 'Terapkan filter',
			'jobs.locationFilter.all' => 'Semua',
			'jobs.locationFilter.reset' => 'Reset',
			'jobs.clubs.tabs.proposals' => 'Proposal',
			'jobs.clubs.tabs.activeClubs' => 'Klub aktif',
			'jobs.clubs.tabs.myClubs' => 'Klub saya',
			'jobs.clubs.tabs.exploreClubs' => 'Jelajahi',
			'jobs.clubs.sections.active' => 'Klub resmi',
			'jobs.clubs.sections.proposals' => 'Proposal klub',
			'jobs.clubs.screen.error' => 'Kesalahan: {error}',
			'jobs.clubs.screen.empty' => 'Belum ada klub.',
			'jobs.clubs.postList.empty' => 'Belum ada postingan. Jadilah yang pertama!',
			'jobs.clubs.postList.writeTooltip' => 'Tulis',
			'jobs.clubs.memberCard.kickConfirmTitle' => 'Hapus {memberName}?',
			'jobs.clubs.memberCard.kickConfirmContent' => 'Anggota yang dihapus tidak dapat mengikuti aktivitas klub lagi.',
			'jobs.clubs.memberCard.kick' => 'Hapus',
			'jobs.clubs.memberCard.kickedSuccess' => '{memberName} telah dihapus.',
			'jobs.clubs.memberCard.kickFail' => 'Gagal menghapus anggota: {error}',
			'jobs.clubs.postCard.deleteTitle' => 'Hapus postingan',
			'jobs.clubs.postCard.deleteContent' => 'Yakin ingin menghapus postingan ini? Tindakan ini tidak dapat dibatalkan.',
			'jobs.clubs.postCard.deleteSuccess' => 'Postingan dihapus.',
			'jobs.clubs.postCard.deleteFail' => 'Gagal menghapus postingan: {error}',
			'jobs.clubs.postCard.withdrawnMember' => 'Anggota keluar',
			'jobs.clubs.postCard.deleteTooltip' => 'Hapus postingan',
			'jobs.clubs.postCard.loadingUser' => 'Memuat info pengguna...',
			'jobs.clubs.card.membersCount' => '{count} anggota',
			'jobs.clubs.postDetail.commentFail' => 'Gagal menambahkan komentar: {error}',
			'jobs.clubs.postDetail.appBarTitle' => 'Papan {title}',
			'jobs.clubs.postDetail.commentsTitle' => 'Komentar',
			'jobs.clubs.postDetail.noComments' => 'Belum ada komentar.',
			'jobs.clubs.postDetail.commentHint' => 'Tulis komentar...',
			'jobs.clubs.postDetail.unknownUser' => 'Pengguna tidak dikenal',
			'jobs.clubs.detail.joined' => 'Anda bergabung dengan klub \'{title}\'!',
			'jobs.clubs.detail.pendingApproval' => 'Menunggu persetujuan pemilik. Anda bisa ikut setelah disetujui.',
			'jobs.clubs.detail.joinFail' => 'Gagal meminta bergabung: {error}',
			'jobs.clubs.detail.tabs.info' => 'Info',
			'jobs.clubs.detail.tabs.board' => 'Papan',
			'jobs.clubs.detail.tabs.members' => 'Anggota',
			'jobs.clubs.detail.joinChat' => 'Masuk chat',
			'jobs.clubs.detail.joinClub' => 'Gabung klub',
			'jobs.clubs.detail.owner' => 'Admin',
			'jobs.clubs.detail.info.members' => 'Anggota',
			'jobs.clubs.detail.info.location' => 'Lokasi',
			'jobs.clubs.detail.location' => 'Lokasi',
			'jobs.clubs.detail.leaveConfirmTitle' => 'Keluar dari klub',
			'jobs.clubs.detail.leaveConfirmContent' => 'Yakin ingin keluar dari {title}?',
			'jobs.clubs.detail.leave' => 'Keluar',
			'jobs.clubs.detail.leaveSuccess' => 'Anda telah keluar dari {title}',
			'jobs.clubs.detail.leaveFail' => 'Gagal keluar: {error}',
			'jobs.clubs.memberList.pendingMembers' => 'Anggota menunggu',
			'jobs.clubs.memberList.allMembers' => 'Semua anggota',
			'jobs.clubs.createPost.title' => 'Postingan baru',
			'jobs.clubs.createPost.submit' => 'Kirim',
			'jobs.clubs.createPost.success' => 'Postingan berhasil dikirim.',
			'jobs.clubs.createPost.fail' => 'Gagal mengirim postingan: {error}',
			'jobs.clubs.createPost.bodyHint' => 'Tulis konten...',
			'jobs.clubs.createClub.selectAtLeastOneInterest' => 'Pilih minimal satu minat.',
			'jobs.clubs.createClub.success' => 'Klub berhasil dibuat!',
			'jobs.clubs.createClub.fail' => 'Gagal membuat klub: {error}',
			'jobs.clubs.createClub.title' => 'Buat klub',
			'jobs.clubs.createClub.nameLabel' => 'Nama klub',
			'jobs.clubs.createClub.nameError' => 'Silakan isi nama klub.',
			'jobs.clubs.createClub.descriptionLabel' => 'Deskripsi klub',
			'jobs.clubs.createClub.descriptionError' => 'Silakan isi deskripsi klub.',
			'jobs.clubs.createClub.tagsHint' => 'Ketik tag lalu tekan Spasi untuk menambah',
			'jobs.clubs.createClub.maxInterests' => 'Anda bisa memilih hingga 3 minat.',
			'jobs.clubs.createClub.privateClub' => 'Klub privat',
			'jobs.clubs.createClub.privateDescription' => 'Hanya untuk undangan.',
			'jobs.clubs.createClub.locationLabel' => 'Lokasi',
			'jobs.clubs.editClub.title' => 'Edit informasi klub',
			'jobs.clubs.editClub.save' => 'Simpan',
			'jobs.clubs.editClub.success' => 'Informasi klub diperbarui.',
			'jobs.clubs.editClub.fail' => 'Gagal memperbarui klub: {error}',
			'jobs.clubs.create.title' => 'Buat klub',
			'jobs.clubs.repository.chatCreated' => 'Ruang chat klub dibuat.',
			'jobs.clubs.proposal.createTitle' => 'Ajukan klub',
			'jobs.clubs.proposal.imageError' => 'Silakan pilih gambar sampul.',
			'jobs.clubs.proposal.createSuccess' => 'Proposal klub berhasil dibuat.',
			'jobs.clubs.proposal.createFail' => 'Gagal membuat proposal: {error}',
			'jobs.clubs.proposal.tagsHint' => 'Ketik tag lalu tekan Spasi untuk menambah',
			'jobs.clubs.proposal.targetMembers' => 'Target member',
			'jobs.clubs.proposal.targetMembersCount' => 'Total {count} anggota',
			'jobs.clubs.proposal.empty' => 'Belum ada proposal.',
			'jobs.clubs.proposal.memberStatus' => '{current} / {target} anggota',
			'jobs.clubs.proposal.join' => 'Gabung',
			'jobs.clubs.proposal.leave' => 'Keluar',
			'jobs.clubs.proposal.members' => 'Anggota',
			'jobs.clubs.proposal.noMembers' => 'Belum ada anggota.',
			'jobs.clubs.proposal.detail.joined' => 'Anda bergabung!',
			'jobs.clubs.proposal.detail.left' => 'Anda keluar.',
			'jobs.clubs.proposal.detail.loginRequired' => 'Silakan login untuk bergabung.',
			'jobs.clubs.proposal.detail.error' => 'Terjadi kesalahan: {error}',
			'jobs.clubs.empty' => 'Tidak ada klub untuk ditampilkan.',
			'jobs.findfriend.form.title' => 'Buat Profil Cari Teman',
			'jobs.auctions.card.currentBid' => 'Penawaran saat ini',
			'jobs.auctions.card.endTime' => 'Sisa waktu',
			'jobs.auctions.card.ended' => 'Selesai',
			'jobs.auctions.card.winningBid' => 'Penawaran menang',
			'jobs.auctions.card.winner' => 'Pemenang',
			'jobs.auctions.card.noBidders' => 'Belum ada penawar',
			'jobs.auctions.card.unknownBidder' => 'Penawar tidak dikenal',
			'jobs.auctions.card.timeLeft' => '{hours}:{minutes}:{seconds} tersisa',
			'jobs.auctions.card.timeLeftDays' => '{days} hari {hours}:{minutes}:{seconds} tersisa',
			'jobs.auctions.errors.fetchFailed' => 'Gagal memuat daftar lelang: {error}',
			'jobs.auctions.errors.notFound' => 'Lelang tidak ditemukan.',
			'jobs.auctions.errors.lowerBid' => 'Anda harus memasukkan penawaran yang lebih tinggi.',
			'jobs.auctions.errors.alreadyEnded' => 'Lelang ini telah selesai.',
			'jobs.auctions.empty' => 'Belum ada lelang.',
			'jobs.auctions.filter.tooltip' => 'Filter',
			'jobs.auctions.filter.clearTooltip' => 'Hapus filter',
			'jobs.auctions.create.tooltip' => 'Buat lelang',
			'jobs.auctions.create.title' => 'Buat Lelang',
			'jobs.auctions.create.registrationType' => 'Jenis registrasi',
			'jobs.auctions.create.type.sale' => 'Jual',
			'jobs.auctions.create.type.auction' => 'Lelang',
			'jobs.auctions.create.success' => 'Lelang berhasil dibuat.',
			'jobs.auctions.create.fail' => 'Gagal membuat lelang: {error}',
			'jobs.auctions.create.submitButton' => 'Mulai Lelang',
			'jobs.auctions.create.confirmTitle' => 'Daftar sebagai lelang?',
			'jobs.auctions.create.confirmContent' => 'Setelah didaftarkan sebagai lelang, tidak dapat diubah kembali ke penjualan biasa. Biaya 5% akan dikenakan jika lelang berhasil. Lanjut?',
			'jobs.auctions.create.errors.noPhoto' => 'Tambahkan setidaknya satu foto.',
			'jobs.auctions.create.form.photoSectionTitle' => 'Unggah foto (maks 10)',
			'jobs.auctions.create.form.title' => 'Judul',
			'jobs.auctions.create.form.description' => 'Deskripsi',
			'jobs.auctions.create.form.startPrice' => 'Harga awal',
			'jobs.auctions.create.form.category' => 'Kategori',
			'jobs.auctions.create.form.categoryHint' => 'Pilih kategori',
			'jobs.auctions.create.form.tagsHint' => 'Ketik tag lalu tekan Spasi untuk menambah',
			'jobs.auctions.create.form.duration' => 'Durasi',
			'jobs.auctions.create.form.durationOption' => '{days} hari',
			'jobs.auctions.create.form.location' => 'Lokasi',
			'jobs.auctions.edit.tooltip' => 'Edit lelang',
			'jobs.auctions.edit.title' => 'Edit Lelang',
			'jobs.auctions.edit.save' => 'Simpan',
			'jobs.auctions.edit.success' => 'Lelang berhasil diperbarui.',
			'jobs.auctions.edit.fail' => 'Gagal memperbarui lelang: {error}',
			'jobs.auctions.form.titleRequired' => 'Silakan masukkan judul.',
			'jobs.auctions.form.descriptionRequired' => 'Silakan masukkan deskripsi.',
			'jobs.auctions.form.startPriceRequired' => 'Silakan masukkan harga awal.',
			'jobs.auctions.form.categoryRequired' => 'Silakan pilih kategori.',
			'jobs.auctions.delete.tooltip' => 'Hapus lelang',
			'jobs.auctions.delete.confirmTitle' => 'Hapus lelang',
			'jobs.auctions.delete.confirmContent' => 'Yakin ingin menghapus lelang ini?',
			'jobs.auctions.delete.success' => 'Lelang dihapus.',
			'jobs.auctions.delete.fail' => 'Gagal menghapus lelang: {error}',
			'jobs.auctions.detail.currentBid' => 'Penawaran saat ini: {amount}',
			'jobs.auctions.detail.location' => 'Lokasi',
			'jobs.auctions.detail.seller' => 'Penjual',
			'jobs.auctions.detail.qnaTitle' => 'Tanya jawab',
			'jobs.auctions.detail.qnaHint' => 'Tanya penjual...',
			'jobs.auctions.detail.endTime' => 'Waktu selesai: {time}',
			'jobs.auctions.detail.bidsTitle' => 'Daftar penawaran',
			'jobs.auctions.detail.noBids' => 'Belum ada penawaran.',
			'jobs.auctions.detail.unknownBidder' => 'Penawar tidak dikenal',
			'jobs.auctions.detail.bidAmountLabel' => 'Masukkan penawaran (Rp)',
			'jobs.auctions.detail.placeBid' => 'Tawar',
			'jobs.auctions.detail.bidSuccess' => 'Penawaran berhasil!',
			'jobs.auctions.detail.bidFail' => 'Gagal menawar: {error}',
			'jobs.auctions.detail.errors.loginRequired' => 'Login diperlukan.',
			'jobs.auctions.detail.errors.invalidAmount' => 'Masukkan jumlah penawaran yang valid.',
			'jobs.localStores.setLocationPrompt' => 'Atur lokasi Anda untuk melihat toko terdekat.',
			'jobs.localStores.empty' => 'Belum ada toko.',
			'jobs.localStores.error' => 'Terjadi kesalahan: {error}',
			'jobs.localStores.create.tooltip' => 'Daftarkan toko saya',
			'jobs.localStores.create.title' => 'Daftarkan Toko Baru',
			'jobs.localStores.create.submit' => 'Daftarkan',
			'jobs.localStores.create.success' => 'Toko berhasil didaftarkan.',
			'jobs.localStores.create.fail' => 'Gagal mendaftarkan toko: {error}',
			'jobs.localStores.edit.title' => 'Edit Info Toko',
			'jobs.localStores.edit.save' => 'Simpan',
			'jobs.localStores.edit.success' => 'Info toko berhasil diperbarui.',
			'jobs.localStores.edit.fail' => 'Gagal memperbarui info: {error}',
			'jobs.localStores.edit.tooltip' => 'Edit info toko',
			'jobs.localStores.form.nameLabel' => 'Nama toko',
			'jobs.localStores.form.nameError' => 'Silakan masukkan nama toko.',
			'jobs.localStores.form.descriptionLabel' => 'Deskripsi toko',
			'jobs.localStores.form.descriptionError' => 'Silakan masukkan deskripsi toko.',
			'jobs.localStores.form.contactLabel' => 'Kontak',
			'jobs.localStores.form.hoursLabel' => 'Jam buka',
			'jobs.localStores.form.hoursHint' => 'mis. 09:00 - 18:00',
			'jobs.localStores.form.photoLabel' => 'Foto (maks {count})',
			'jobs.localStores.form.categoryLabel' => 'Kategori',
			'jobs.localStores.form.categoryError' => 'Silakan pilih kategori.',
			'jobs.localStores.form.productsLabel' => 'Produk/Layanan utama',
			'jobs.localStores.form.productsHint' => 'Pisahkan dengan koma, mis. Haircut, Coloring, Perm',
			'jobs.localStores.form.imageError' => 'Gambar gagal dimuat. Coba lagi.',
			'jobs.localStores.categories.all' => 'Semua',
			'jobs.localStores.categories.food' => 'Restoran',
			'jobs.localStores.categories.cafe' => 'Kafe',
			'jobs.localStores.categories.massage' => 'Pijat',
			'jobs.localStores.categories.beauty' => 'Kecantikan',
			'jobs.localStores.categories.nail' => 'Nail',
			'jobs.localStores.categories.auto' => 'Bengkel',
			'jobs.localStores.categories.kids' => 'Anak-anak',
			'jobs.localStores.categories.hospital' => 'Rumah sakit/Klinik',
			'jobs.localStores.categories.etc' => 'Lainnya',
			'jobs.localStores.detail.description' => 'Deskripsi toko',
			'jobs.localStores.detail.products' => 'Produk/Layanan',
			'jobs.localStores.detail.deleteTitle' => 'Hapus toko',
			'jobs.localStores.detail.deleteContent' => 'Yakin ingin menghapus toko ini? Tindakan ini tidak dapat dibatalkan.',
			'jobs.localStores.detail.deleteTooltip' => 'Hapus toko',
			'jobs.localStores.detail.delete' => 'Hapus',
			'jobs.localStores.detail.cancel' => 'Batal',
			'jobs.localStores.detail.deleteSuccess' => 'Toko dihapus.',
			'jobs.localStores.detail.deleteFail' => 'Gagal menghapus toko: {error}',
			'jobs.localStores.detail.inquire' => 'Hubungi',
			'jobs.localStores.detail.noOwnerInfo' => 'Info pemilik tidak tersedia',
			'jobs.localStores.detail.startChatFail' => 'Tidak dapat memulai chat: {error}',
			'jobs.localStores.detail.reviews' => 'Ulasan',
			'jobs.localStores.detail.writeReview' => 'Tulis ulasan',
			'jobs.localStores.detail.noReviews' => 'Belum ada ulasan.',
			'jobs.localStores.detail.reviewDialogContent' => 'Silakan tulis ulasan Anda.',
			'jobs.localStores.noLocation' => 'Tidak ada info lokasi',
			'jobs.pom.title' => 'POM',
			'jobs.pom.search.hint' => 'Cari POM, tag, pengguna',
			'jobs.pom.tabs.local' => 'Lokal',
			'jobs.pom.tabs.all' => 'Semua',
			'jobs.pom.tabs.popular' => 'Populer',
			'jobs.pom.tabs.myPoms' => 'POM saya',
			'jobs.pom.more' => 'Lihat lebih banyak',
			'jobs.pom.less' => 'Tutup',
			'jobs.pom.likesCount' => '{} suka',
			'jobs.pom.report' => 'Laporkan {}',
			'jobs.pom.block' => 'Blokir {}',
			'jobs.pom.emptyPopular' => 'Belum ada POM populer.',
			'jobs.pom.emptyMine' => 'Anda belum mengunggah POM.',
			'jobs.pom.emptyHintPopular' => 'Coba lihat tab \'Semua\' untuk POM terbaru.',
			'jobs.pom.emptyCtaMine' => 'Tekan + untuk mengunggah POM pertama Anda.',
			'jobs.pom.share' => 'Bagikan',
			'jobs.pom.empty' => 'Belum ada POM.',
			'jobs.pom.errors.fetchFailed' => 'Terjadi kesalahan: {error}',
			'jobs.pom.errors.videoSource' => 'Video tidak dapat diputar. Sumber tidak tersedia atau diblokir.',
			'jobs.pom.comments.title' => 'Komentar',
			'jobs.pom.comments.viewAll' => 'Lihat semua {} komentar',
			'jobs.pom.comments.empty' => 'Belum ada komentar.',
			'jobs.pom.comments.placeholder' => 'Tulis komentar...',
			'jobs.pom.comments.fail' => 'Gagal menambahkan komentar: {error}',
			'jobs.pom.create.title' => 'Unggah POM Baru',
			'jobs.pom.create.photo' => 'Foto',
			'jobs.pom.create.video' => 'Video',
			'jobs.pom.create.titleImage' => 'Unggah Foto',
			'jobs.pom.create.submit' => 'Unggah',
			'jobs.pom.create.success' => 'POM berhasil diunggah.',
			'jobs.pom.create.fail' => 'Gagal mengunggah POM: {error}',
			'jobs.pom.create.form.titleLabel' => 'Judul',
			'jobs.pom.create.form.descriptionLabel' => 'Deskripsi',
			'jobs.realEstate.title' => 'Properti',
			'jobs.realEstate.tabs.all' => 'Semua',
			'jobs.realEstate.tabs.rent' => 'Sewa',
			'jobs.realEstate.tabs.sale' => 'Dijual',
			'jobs.realEstate.tabs.myListings' => 'Daftar saya',
			'jobs.realEstate.setLocationPrompt' => 'Atur lokasi Anda untuk melihat properti terdekat.',
			'jobs.realEstate.empty' => 'Belum ada daftar properti.',
			'jobs.realEstate.error' => 'Terjadi kesalahan: {error}',
			'jobs.realEstate.create.tooltip' => 'Pasang iklan',
			'jobs.realEstate.create.title' => 'Pasang Properti Baru',
			'jobs.realEstate.create.submit' => 'Pasang',
			'jobs.realEstate.create.success' => 'Properti berhasil dipasang.',
			'jobs.realEstate.create.fail' => 'Gagal memasang properti: {error}',
			'jobs.realEstate.edit.title' => 'Edit Properti',
			'jobs.realEstate.edit.save' => 'Simpan',
			'jobs.realEstate.edit.success' => 'Properti berhasil diperbarui.',
			'jobs.realEstate.edit.fail' => 'Gagal memperbarui properti: {error}',
			'jobs.realEstate.edit.tooltip' => 'Edit properti',
			'jobs.realEstate.form.titleLabel' => 'Judul',
			'jobs.realEstate.form.titleError' => 'Silakan masukkan judul.',
			'jobs.realEstate.form.descriptionLabel' => 'Deskripsi',
			'jobs.realEstate.form.descriptionError' => 'Silakan masukkan deskripsi.',
			'jobs.realEstate.form.priceLabel' => 'Harga (IDR)',
			'jobs.realEstate.form.priceError' => 'Silakan masukkan harga.',
			'jobs.realEstate.form.categoryLabel' => 'Tipe',
			'jobs.realEstate.form.categoryError' => 'Silakan pilih tipe.',
			'jobs.realEstate.form.locationLabel' => 'Lokasi',
			'jobs.realEstate.form.locationError' => 'Silakan masukkan lokasi.',
			'jobs.realEstate.form.roomsLabel' => 'Jumlah kamar',
			'jobs.realEstate.form.bathLabel' => 'Kamar mandi',
			'jobs.realEstate.form.areaLabel' => 'Luas (m²)',
			'jobs.realEstate.form.photoLabel' => 'Foto (maks 10)',
			'jobs.realEstate.form.imageError' => 'Gagal memuat gambar.',
			'jobs.realEstate.categories.house' => 'Rumah',
			'jobs.realEstate.categories.apartment' => 'Apartemen',
			'jobs.realEstate.categories.kost' => 'Kost',
			'jobs.realEstate.categories.villa' => 'Villa',
			'jobs.realEstate.categories.office' => 'Kantor',
			'jobs.realEstate.categories.land' => 'Tanah',
			'jobs.realEstate.categories.shophouse' => 'Ruko',
			'jobs.realEstate.categories.warehouse' => 'Gudang',
			'jobs.realEstate.categories.etc' => 'Lainnya',
			'jobs.realEstate.detail.price' => 'Harga',
			'jobs.realEstate.detail.rooms' => 'Kamar',
			'jobs.realEstate.detail.bathrooms' => 'Kamar mandi',
			'jobs.realEstate.detail.area' => 'Luas',
			'jobs.realEstate.detail.location' => 'Lokasi',
			'jobs.realEstate.detail.contactSeller' => 'Hubungi penjual',
			'jobs.realEstate.detail.contactFail' => 'Tidak dapat memulai chat: {error}',
			'jobs.realEstate.detail.delete' => 'Hapus',
			'jobs.realEstate.detail.deleteConfirm' => 'Hapus properti ini?',
			'jobs.realEstate.detail.deleteSuccess' => 'Properti dihapus.',
			'jobs.realEstate.detail.deleteFail' => 'Gagal menghapus properti: {error}',
			'jobs.realEstate.detail.postedBy' => 'Diposting oleh',
			'jobs.lostAndFound.title' => 'Hilang & Temuan',
			'jobs.lostAndFound.tabs.lost' => 'Hilang',
			'jobs.lostAndFound.tabs.found' => 'Ditemukan',
			'jobs.lostAndFound.tabs.myReports' => 'Laporan saya',
			'jobs.lostAndFound.empty' => 'Belum ada laporan.',
			'jobs.lostAndFound.setLocationPrompt' => 'Atur lokasi Anda untuk melihat laporan sekitar.',
			'jobs.lostAndFound.create.tooltip' => 'Buat laporan',
			'jobs.lostAndFound.create.title' => 'Buat Laporan Baru',
			'jobs.lostAndFound.create.submit' => 'Kirim',
			'jobs.lostAndFound.create.success' => 'Laporan berhasil dibuat.',
			'jobs.lostAndFound.create.fail' => 'Gagal membuat laporan: {error}',
			'jobs.lostAndFound.edit.title' => 'Edit laporan',
			'jobs.lostAndFound.edit.save' => 'Simpan',
			'jobs.lostAndFound.edit.success' => 'Laporan berhasil diperbarui.',
			'jobs.lostAndFound.edit.fail' => 'Gagal memperbarui laporan: {error}',
			'jobs.lostAndFound.form.titleLabel' => 'Judul',
			'jobs.lostAndFound.form.titleError' => 'Silakan masukkan judul.',
			'jobs.lostAndFound.form.descriptionLabel' => 'Detail',
			'jobs.lostAndFound.form.descriptionError' => 'Silakan masukkan detail.',
			'jobs.lostAndFound.form.categoryLabel' => 'Kategori',
			'jobs.lostAndFound.form.categoryError' => 'Silakan pilih kategori.',
			'jobs.lostAndFound.form.locationLabel' => 'Lokasi',
			'jobs.lostAndFound.form.locationError' => 'Silakan masukkan lokasi.',
			'jobs.lostAndFound.form.photoLabel' => 'Foto (maks 10)',
			'jobs.lostAndFound.categories.pet' => 'Hewan peliharaan',
			'jobs.lostAndFound.categories.item' => 'Barang',
			'jobs.lostAndFound.categories.person' => 'Orang',
			'jobs.lostAndFound.categories.scam' => 'Penipuan',
			_ => null,
		} ?? switch (path) {
			'jobs.lostAndFound.categories.etc' => 'Lainnya',
			'jobs.lostAndFound.detail.location' => 'Lokasi',
			'jobs.lostAndFound.detail.contact' => 'Hubungi',
			'jobs.lostAndFound.detail.contactFail' => 'Tidak dapat memulai chat: {error}',
			'jobs.lostAndFound.detail.delete' => 'Hapus',
			'jobs.lostAndFound.detail.deleteConfirm' => 'Hapus laporan ini?',
			'jobs.lostAndFound.detail.deleteSuccess' => 'Laporan dihapus.',
			'jobs.lostAndFound.detail.deleteFail' => 'Gagal menghapus laporan: {error}',
			'jobs.community.title' => 'Komunitas',
			'jobs.community.empty' => 'Belum ada postingan.',
			'jobs.community.error' => 'Terjadi kesalahan: {error}',
			'jobs.community.create.title' => 'Postingan Baru',
			'jobs.community.create.submit' => 'Kirim',
			'jobs.community.create.success' => 'Postingan berhasil dibuat.',
			'jobs.community.create.fail' => 'Gagal membuat postingan: {error}',
			'jobs.community.edit.title' => 'Edit Postingan',
			'jobs.community.edit.save' => 'Simpan',
			'jobs.community.edit.success' => 'Postingan berhasil diperbarui.',
			'jobs.community.edit.fail' => 'Gagal memperbarui: {error}',
			'jobs.community.post.delete' => 'Hapus',
			'jobs.community.post.deleteConfirm' => 'Hapus postingan ini?',
			'jobs.community.post.deleteSuccess' => 'Postingan dihapus.',
			'jobs.community.post.deleteFail' => 'Gagal menghapus postingan: {error}',
			'jobs.shared.tagInput.defaultHint' => 'Tambahkan tag (tekan spasi untuk konfirmasi)',
			'jobs.linkPreview.errorTitle' => 'Tidak dapat memuat pratinjau',
			'jobs.linkPreview.errorBody' => 'Periksa tautannya atau coba lagi nanti.',
			'jobs.selectCategory' => 'Pilih kategori',
			'jobs.addressNeighborhood' => 'Lingkungan',
			'jobs.addressDetailHint' => 'Detail alamat',
			'jobs.localNewsTagResult.error' => 'Terjadi kesalahan saat mencari: {error}',
			'jobs.localNewsTagResult.empty' => 'Tidak ada postingan dengan tag \'#{tag}\'.',
			'jobs.admin.screen.title' => 'Menu Admin',
			'jobs.admin.menu.aiApproval' => 'Manajemen Verifikasi AI',
			'jobs.admin.menu.reportManagement' => 'Manajemen Laporan',
			'jobs.admin.aiApproval.empty' => 'Tidak ada produk yang menunggu verifikasi AI.',
			'jobs.admin.aiApproval.error' => 'Terjadi kesalahan saat memuat produk yang menunggu.',
			'jobs.admin.aiApproval.requestedAt' => 'Waktu permintaan',
			'jobs.admin.reports.title' => 'Manajemen Laporan',
			'jobs.admin.reports.empty' => 'Tidak ada laporan yang menunggu.',
			'jobs.admin.reports.error' => 'Terjadi kesalahan saat memuat laporan.',
			'jobs.admin.reports.createdAt' => 'Dibuat pada',
			'jobs.admin.reportList.title' => 'Manajemen Laporan',
			'jobs.admin.reportList.empty' => 'Tidak ada laporan yang menunggu.',
			'jobs.admin.reportList.error' => 'Terjadi kesalahan saat memuat laporan.',
			'jobs.admin.reportDetail.title' => 'Detail Laporan',
			'jobs.admin.reportDetail.loadError' => 'Terjadi kesalahan saat memuat detail laporan.',
			'jobs.admin.reportDetail.sectionReportInfo' => 'Informasi laporan',
			'jobs.admin.reportDetail.idLabel' => 'ID',
			'jobs.admin.reportDetail.postIdLabel' => 'ID postingan yang dilaporkan',
			'jobs.admin.reportDetail.reporter' => 'Pelapor',
			'jobs.admin.reportDetail.reportedUser' => 'Pengguna yang dilaporkan',
			'jobs.admin.reportDetail.reason' => 'Alasan',
			'jobs.admin.reportDetail.reportedAt' => 'Waktu laporan',
			'jobs.admin.reportDetail.currentStatus' => 'Status',
			'jobs.admin.reportDetail.sectionContent' => 'Konten yang dilaporkan',
			'jobs.admin.reportDetail.loadingContent' => 'Memuat konten...',
			'jobs.admin.reportDetail.contentLoadError' => 'Gagal memuat konten yang dilaporkan.',
			'jobs.admin.reportDetail.contentNotAvailable' => 'Informasi konten tidak tersedia atau sudah dihapus.',
			'jobs.admin.reportDetail.authorIdLabel' => 'ID pembuat',
			'jobs.admin.reportDetail.content.post' => 'Postingan: {title}\n\n{body}',
			'jobs.admin.reportDetail.content.comment' => 'Komentar: {content}',
			'jobs.admin.reportDetail.content.reply' => 'Balasan: {content}',
			'jobs.admin.reportDetail.viewOriginalPost' => 'Lihat postingan asli',
			'jobs.admin.reportDetail.sectionActions' => 'Tindakan',
			'jobs.admin.reportDetail.actionReviewed' => 'Tandai sudah ditinjau',
			'jobs.admin.reportDetail.actionTaken' => 'Tandai tindakan diambil (mis. dihapus)',
			'jobs.admin.reportDetail.actionDismissed' => 'Abaikan laporan',
			'jobs.admin.reportDetail.statusUpdateSuccess' => 'Status laporan diperbarui menjadi \'{status}\'.',
			'jobs.admin.reportDetail.statusUpdateFail' => 'Gagal memperbarui status: {error}',
			'jobs.admin.reportDetail.originalPostNotFound' => 'Postingan asli tidak ditemukan.',
			'jobs.admin.reportDetail.couldNotOpenOriginalPost' => 'Tidak dapat membuka postingan asli.',
			'jobs.tags.localNews.kelurahanNotice.name' => 'Pengumuman kelurahan',
			'jobs.tags.localNews.kelurahanNotice.desc' => 'Pengumuman resmi dari kantor kelurahan.',
			'jobs.tags.localNews.kecamatanNotice.name' => 'Pengumuman kecamatan',
			'jobs.tags.localNews.kecamatanNotice.desc' => 'Pengumuman dari kantor kecamatan.',
			'jobs.tags.localNews.publicCampaign.name' => 'Kampanye publik',
			'jobs.tags.localNews.publicCampaign.desc' => 'Informasi publik dan program pemerintah.',
			'jobs.tags.localNews.siskamling.name' => 'Siskamling',
			'jobs.tags.localNews.siskamling.desc' => 'Kegiatan ronda dan keamanan lingkungan.',
			'jobs.tags.localNews.powerOutage.name' => 'Pemadaman listrik',
			'jobs.tags.localNews.powerOutage.desc' => 'Informasi pemadaman listrik di area Anda.',
			'jobs.tags.localNews.waterOutage.name' => 'Gangguan air',
			'jobs.tags.localNews.waterOutage.desc' => 'Informasi gangguan/pemutusan pasokan air.',
			'jobs.tags.localNews.wasteCollection.name' => 'Pengangkutan sampah',
			'jobs.tags.localNews.wasteCollection.desc' => 'Jadwal atau pemberitahuan pengangkutan sampah.',
			'jobs.tags.localNews.roadWorks.name' => 'Perbaikan jalan',
			'jobs.tags.localNews.roadWorks.desc' => 'Informasi perbaikan dan pekerjaan jalan.',
			'jobs.tags.localNews.publicFacility.name' => 'Fasilitas umum',
			'jobs.tags.localNews.publicFacility.desc' => 'Info tentang taman, lapangan, dan fasilitas umum.',
			'jobs.tags.localNews.weatherWarning.name' => 'Peringatan cuaca',
			'jobs.tags.localNews.weatherWarning.desc' => 'Peringatan cuaca ekstrem di area Anda.',
			'jobs.tags.localNews.floodAlert.name' => 'Peringatan banjir',
			'jobs.tags.localNews.floodAlert.desc' => 'Informasi peringatan dan area terdampak banjir.',
			'jobs.tags.localNews.airQuality.name' => 'Kualitas udara',
			'jobs.tags.localNews.airQuality.desc' => 'Informasi polusi udara dan AQI.',
			'jobs.tags.localNews.diseaseAlert.name' => 'Peringatan penyakit',
			'jobs.tags.localNews.diseaseAlert.desc' => 'Peringatan penyakit menular dan info kesehatan.',
			'jobs.tags.localNews.schoolNotice.name' => 'Pengumuman sekolah',
			'jobs.tags.localNews.schoolNotice.desc' => 'Pengumuman dari sekolah-sekolah di sekitar.',
			'jobs.tags.localNews.posyandu.name' => 'Posyandu',
			'jobs.tags.localNews.posyandu.desc' => 'Kegiatan posyandu dan layanan kesehatan masyarakat.',
			'jobs.tags.localNews.healthCampaign.name' => 'Kampanye kesehatan',
			'jobs.tags.localNews.healthCampaign.desc' => 'Kampanye dan edukasi kesehatan masyarakat.',
			'jobs.tags.localNews.trafficControl.name' => 'Pengaturan lalu lintas',
			'jobs.tags.localNews.trafficControl.desc' => 'Informasi pengalihan, penutupan, dan rekayasa lalu lintas.',
			'jobs.tags.localNews.publicTransport.name' => 'Transportasi umum',
			'jobs.tags.localNews.publicTransport.desc' => 'Info bus, kereta, dan transportasi umum lainnya.',
			'jobs.tags.localNews.parkingPolicy.name' => 'Kebijakan parkir',
			'jobs.tags.localNews.parkingPolicy.desc' => 'Info parkir dan perubahan kebijakan parkir.',
			'jobs.tags.localNews.communityEvent.name' => 'Acara komunitas',
			'jobs.tags.localNews.communityEvent.desc' => 'Festival, kumpul warga, dan acara lokal.',
			'jobs.tags.localNews.worshipEvent.name' => 'Acara keagamaan',
			'jobs.tags.localNews.worshipEvent.desc' => 'Kegiatan di masjid, gereja, pura, dan tempat ibadah lain.',
			'jobs.tags.localNews.incidentReport.name' => 'Laporan insiden',
			'jobs.tags.localNews.incidentReport.desc' => 'Laporan kejadian dan kecelakaan di lingkungan.',
			'jobs.boards.popup.inactiveTitle' => 'Papan lingkungan belum aktif',
			'jobs.boards.popup.inactiveBody' => 'Untuk mengaktifkan papan lingkungan Anda, buat dulu satu posting Berita Lokal. Jika tetangga mulai ikut serta, papan akan terbuka otomatis.',
			'jobs.boards.popup.writePost' => 'Tulis Berita Lokal',
			'jobs.boards.defaultTitle' => 'Papan',
			'jobs.boards.chatRoomComingSoon' => 'Ruang chat segera hadir',
			'jobs.boards.chatRoomTitle' => 'Ruang Chat',
			'jobs.boards.emptyFeed' => 'Belum ada postingan.',
			'jobs.boards.chatRoomCreated' => 'Ruang chat telah dibuat.',
			'jobs.locationSettingError' => 'Gagal menyetel lokasi.',
			'jobs.signupFailRequired' => 'Kolom ini wajib diisi.',
			'jobs.signup.alerts.signupSuccessLoginNotice' => 'Pendaftaran berhasil! Silakan login.',
			'jobs.signup.title' => 'Daftar',
			'jobs.signup.subtitle' => 'Bergabunglah dengan komunitas lingkungan Anda!',
			'jobs.signup.nicknameHint' => 'Nama panggilan',
			'jobs.signup.emailHint' => 'Alamat email',
			'jobs.signup.passwordHint' => 'Kata sandi',
			'jobs.signup.passwordConfirmHint' => 'Konfirmasi kata sandi',
			'jobs.signup.locationHint' => 'Lokasi',
			'jobs.signup.locationNotice' => 'Lokasi Anda hanya digunakan untuk menampilkan postingan lokal dan tidak dibagikan.',
			'jobs.signup.buttons.signup' => 'Daftar',
			'jobs.signupFailDefault' => 'Pendaftaran gagal.',
			'jobs.signupFailWeakPassword' => 'Kata sandi terlalu lemah.',
			'jobs.signupFailEmailInUse' => 'Email sudah digunakan.',
			'jobs.signupFailInvalidEmail' => 'Format email tidak valid.',
			'jobs.signupFailUnknown' => 'Terjadi kesalahan yang tidak diketahui.',
			'jobs.categoryEmpty' => 'Tidak ada kategori',
			'jobs.user.notLoggedIn' => 'Belum login.',
			_ => null,
		};
	}
}
