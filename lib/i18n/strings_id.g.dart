///
/// Generated file. Do not edit.
///
// coverage:ignore-file
// ignore_for_file: type=lint, unused_import
// dart format off

part of 'strings.g.dart';

// Path: <root>
typedef TranslationsId = Translations; // ignore: unused_element
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
		    locale: AppLocale.id,
		    overrides: overrides ?? {},
		    cardinalResolver: cardinalResolver,
		    ordinalResolver: ordinalResolver,
		  ) {
		$meta.setFlatMapFunction(_flatMapFunction);
	}

	/// Metadata for the translations of <id>.
	@override final TranslationMetadata<AppLocale, Translations> $meta;

	/// Access flat map
	dynamic operator[](String key) => $meta.getTranslation(key);

	late final Translations _root = this; // ignore: unused_field

	Translations $copyWith({TranslationMetadata<AppLocale, Translations>? meta}) => Translations(meta: meta ?? this.$meta);

	// Translations
	late final TranslationsLoginId login = TranslationsLoginId.internal(_root);
	late final TranslationsMainId main = TranslationsMainId.internal(_root);
	late final TranslationsSearchId search = TranslationsSearchId.internal(_root);
	late final TranslationsDrawerId drawer = TranslationsDrawerId.internal(_root);
	late final TranslationsMarketplaceId marketplace = TranslationsMarketplaceId.internal(_root);
	late final TranslationsAiFlowId aiFlow = TranslationsAiFlowId.internal(_root);
	late final TranslationsRegistrationFlowId registrationFlow = TranslationsRegistrationFlowId.internal(_root);
	late final TranslationsMyBlingId myBling = TranslationsMyBlingId.internal(_root);
	late final TranslationsProfileViewId profileView = TranslationsProfileViewId.internal(_root);
	late final TranslationsSettingsId settings = TranslationsSettingsId.internal(_root);
	late final TranslationsFriendRequestsId friendRequests = TranslationsFriendRequestsId.internal(_root);
	late final TranslationsSentFriendRequestsId sentFriendRequests = TranslationsSentFriendRequestsId.internal(_root);
	late final TranslationsBlockedUsersId blockedUsers = TranslationsBlockedUsersId.internal(_root);
	late final TranslationsRejectedUsersId rejectedUsers = TranslationsRejectedUsersId.internal(_root);
	late final TranslationsPromptId prompt = TranslationsPromptId.internal(_root);
	late final TranslationsLocationId location = TranslationsLocationId.internal(_root);
	late final TranslationsProfileEditId profileEdit = TranslationsProfileEditId.internal(_root);
	late final TranslationsMainFeedId mainFeed = TranslationsMainFeedId.internal(_root);
	late final TranslationsPostCardId postCard = TranslationsPostCardId.internal(_root);
	late final TranslationsTimeId time = TranslationsTimeId.internal(_root);
	late final TranslationsProductCardId productCard = TranslationsProductCardId.internal(_root);
	late final TranslationsLocalNewsFeedId localNewsFeed = TranslationsLocalNewsFeedId.internal(_root);
	late final TranslationsCategoriesId categories = TranslationsCategoriesId.internal(_root);
	late final TranslationsLocalNewsCreateId localNewsCreate = TranslationsLocalNewsCreateId.internal(_root);
	late final TranslationsLocalNewsDetailId localNewsDetail = TranslationsLocalNewsDetailId.internal(_root);
	late final TranslationsLocalNewsEditId localNewsEdit = TranslationsLocalNewsEditId.internal(_root);
	late final TranslationsCommentInputFieldId commentInputField = TranslationsCommentInputFieldId.internal(_root);
	late final TranslationsCommentListViewId commentListView = TranslationsCommentListViewId.internal(_root);
	late final TranslationsCommonId common = TranslationsCommonId.internal(_root);
	late final TranslationsReportDialogId reportDialog = TranslationsReportDialogId.internal(_root);
	late final TranslationsReplyDeleteId replyDelete = TranslationsReplyDeleteId.internal(_root);
	late final TranslationsReportReasonsId reportReasons = TranslationsReportReasonsId.internal(_root);
	late final TranslationsDeleteConfirmId deleteConfirm = TranslationsDeleteConfirmId.internal(_root);
	late final TranslationsReplyInputFieldId replyInputField = TranslationsReplyInputFieldId.internal(_root);
	late final TranslationsChatListId chatList = TranslationsChatListId.internal(_root);
	late final TranslationsChatRoomId chatRoom = TranslationsChatRoomId.internal(_root);
	late final TranslationsJobsId jobs = TranslationsJobsId.internal(_root);
	late final TranslationsBoardsId boards = TranslationsBoardsId.internal(_root);

	/// id: 'Gagal menyetel lokasi.'
	String get locationSettingError => 'Gagal menyetel lokasi.';

	/// id: 'Kolom ini wajib diisi.'
	String get signupFailRequired => 'Kolom ini wajib diisi.';

	late final TranslationsSignupId signup = TranslationsSignupId.internal(_root);

	/// id: 'Pendaftaran gagal.'
	String get signupFailDefault => 'Pendaftaran gagal.';

	/// id: 'Kata sandi terlalu lemah.'
	String get signupFailWeakPassword => 'Kata sandi terlalu lemah.';

	/// id: 'Email sudah digunakan.'
	String get signupFailEmailInUse => 'Email sudah digunakan.';

	/// id: 'Format email tidak valid.'
	String get signupFailInvalidEmail => 'Format email tidak valid.';

	/// id: 'Terjadi kesalahan yang tidak diketahui.'
	String get signupFailUnknown => 'Terjadi kesalahan yang tidak diketahui.';

	/// id: 'Tidak ada kategori'
	String get categoryEmpty => 'Tidak ada kategori';

	late final TranslationsUserId user = TranslationsUserId.internal(_root);
	late final TranslationsFindFriendId findFriend = TranslationsFindFriendId.internal(_root);
	late final TranslationsInterestsId interests = TranslationsInterestsId.internal(_root);
	late final TranslationsFriendDetailId friendDetail = TranslationsFriendDetailId.internal(_root);
	late final TranslationsLocationFilterId locationFilter = TranslationsLocationFilterId.internal(_root);
	late final TranslationsClubsId clubs = TranslationsClubsId.internal(_root);
	late final TranslationsFindfriendId findfriend = TranslationsFindfriendId.internal(_root);
	late final TranslationsAuctionsId auctions = TranslationsAuctionsId.internal(_root);
	late final TranslationsLocalStoresId localStores = TranslationsLocalStoresId.internal(_root);
	late final TranslationsPomId pom = TranslationsPomId.internal(_root);
	late final TranslationsRealEstateId realEstate = TranslationsRealEstateId.internal(_root);
	late final TranslationsLostAndFoundId lostAndFound = TranslationsLostAndFoundId.internal(_root);
	late final TranslationsCommunityId community = TranslationsCommunityId.internal(_root);
	late final TranslationsSharedId shared = TranslationsSharedId.internal(_root);
	late final TranslationsLinkPreviewId linkPreview = TranslationsLinkPreviewId.internal(_root);

	/// id: 'Select category'
	String get selectCategory => 'Select category';

	/// id: 'Neighborhood'
	String get addressNeighborhood => 'Neighborhood';

	/// id: 'Address details'
	String get addressDetailHint => 'Address details';

	late final TranslationsLocalNewsTagResultId localNewsTagResult = TranslationsLocalNewsTagResultId.internal(_root);
	late final TranslationsAdminId admin = TranslationsAdminId.internal(_root);
	late final TranslationsTagsId tags = TranslationsTagsId.internal(_root);

	/// id: 'Kedua kata sandi tidak cocok.'
	String get signupFailPasswordMismatch => 'Kedua kata sandi tidak cocok.';
}

// Path: login
class TranslationsLoginId {
	TranslationsLoginId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Masuk'
	String get title => 'Masuk';

	/// id: 'Beli dan jual dengan mudah di Bling!'
	String get subtitle => 'Beli dan jual dengan mudah di Bling!';

	/// id: 'Alamat Email'
	String get emailHint => 'Alamat Email';

	/// id: 'Kata Sandi'
	String get passwordHint => 'Kata Sandi';

	late final TranslationsLoginButtonsId buttons = TranslationsLoginButtonsId.internal(_root);
	late final TranslationsLoginLinksId links = TranslationsLoginLinksId.internal(_root);
	late final TranslationsLoginAlertsId alerts = TranslationsLoginAlertsId.internal(_root);
}

// Path: main
class TranslationsMainId {
	TranslationsMainId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsMainAppBarId appBar = TranslationsMainAppBarId.internal(_root);
	late final TranslationsMainTabsId tabs = TranslationsMainTabsId.internal(_root);
	late final TranslationsMainBottomNavId bottomNav = TranslationsMainBottomNavId.internal(_root);
	late final TranslationsMainErrorsId errors = TranslationsMainErrorsId.internal(_root);

	/// id: 'Lingkungan Saya'
	String get myTown => 'Lingkungan Saya';

	late final TranslationsMainMapViewId mapView = TranslationsMainMapViewId.internal(_root);
	late final TranslationsMainSearchId search = TranslationsMainSearchId.internal(_root);
}

// Path: search
class TranslationsSearchId {
	TranslationsSearchId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Hasil untuk '{keyword}''
	String get resultsTitle => 'Hasil untuk \'{keyword}\'';

	late final TranslationsSearchEmptyId empty = TranslationsSearchEmptyId.internal(_root);

	/// id: 'Ketik kata kunci'
	String get prompt => 'Ketik kata kunci';

	late final TranslationsSearchSheetId sheet = TranslationsSearchSheetId.internal(_root);

	/// id: 'hasil'
	String get results => 'hasil';
}

// Path: drawer
class TranslationsDrawerId {
	TranslationsDrawerId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Edit Profil'
	String get editProfile => 'Edit Profil';

	/// id: 'Bookmark'
	String get bookmarks => 'Bookmark';

	/// id: 'Unggah Data Contoh'
	String get uploadSampleData => 'Unggah Data Contoh';

	/// id: 'Keluar'
	String get logout => 'Keluar';

	late final TranslationsDrawerTrustDashboardId trustDashboard = TranslationsDrawerTrustDashboardId.internal(_root);

	/// id: 'Jalankan Perbaikan Data'
	String get runDataFix => 'Jalankan Perbaikan Data';
}

// Path: marketplace
class TranslationsMarketplaceId {
	TranslationsMarketplaceId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Terjadi kesalahan: {error}'
	String get error => 'Terjadi kesalahan: {error}';

	/// id: 'Belum ada produk. Ketuk tombol + untuk menambahkan barang pertama!'
	String get empty => 'Belum ada produk.\nKetuk tombol + untuk menambahkan barang pertama!';

	late final TranslationsMarketplaceRegistrationId registration = TranslationsMarketplaceRegistrationId.internal(_root);
	late final TranslationsMarketplaceEditId edit = TranslationsMarketplaceEditId.internal(_root);
	late final TranslationsMarketplaceDetailId detail = TranslationsMarketplaceDetailId.internal(_root);
	late final TranslationsMarketplaceDialogId dialog = TranslationsMarketplaceDialogId.internal(_root);
	late final TranslationsMarketplaceErrorsId errors = TranslationsMarketplaceErrorsId.internal(_root);
	late final TranslationsMarketplaceConditionId condition = TranslationsMarketplaceConditionId.internal(_root);
	late final TranslationsMarketplaceReservationId reservation = TranslationsMarketplaceReservationId.internal(_root);
	late final TranslationsMarketplaceStatusId status = TranslationsMarketplaceStatusId.internal(_root);
	late final TranslationsMarketplaceAiId ai = TranslationsMarketplaceAiId.internal(_root);
	late final TranslationsMarketplaceTakeoverId takeover = TranslationsMarketplaceTakeoverId.internal(_root);

	/// id: 'Diverifikasi AI'
	String get aiBadge => 'Diverifikasi AI';

	/// id: 'Atur lingkungan Anda terlebih dahulu untuk melihat barang preloved!'
	String get setLocationPrompt => 'Atur lingkungan Anda terlebih dahulu untuk melihat barang preloved!';
}

// Path: aiFlow
class TranslationsAiFlowId {
	TranslationsAiFlowId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsAiFlowCommonId common = TranslationsAiFlowCommonId.internal(_root);
	late final TranslationsAiFlowCtaId cta = TranslationsAiFlowCtaId.internal(_root);
	late final TranslationsAiFlowCategorySelectionId categorySelection = TranslationsAiFlowCategorySelectionId.internal(_root);
	late final TranslationsAiFlowGalleryUploadId galleryUpload = TranslationsAiFlowGalleryUploadId.internal(_root);
	late final TranslationsAiFlowPredictionId prediction = TranslationsAiFlowPredictionId.internal(_root);
	late final TranslationsAiFlowGuidedCameraId guidedCamera = TranslationsAiFlowGuidedCameraId.internal(_root);
	late final TranslationsAiFlowFinalReportId finalReport = TranslationsAiFlowFinalReportId.internal(_root);
	late final TranslationsAiFlowEvidenceId evidence = TranslationsAiFlowEvidenceId.internal(_root);
	late final TranslationsAiFlowErrorId error = TranslationsAiFlowErrorId.internal(_root);
}

// Path: registrationFlow
class TranslationsRegistrationFlowId {
	TranslationsRegistrationFlowId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Pilih jenis barang yang akan dijual'
	String get title => 'Pilih jenis barang yang akan dijual';

	/// id: 'Daftar barang baru & bekas biasa'
	String get newItemTitle => 'Daftar barang baru & bekas biasa';

	/// id: 'Daftarkan barang baru yang tidak terpakai dan barang bekas biasa dengan cepat.'
	String get newItemDesc => 'Daftarkan barang baru yang tidak terpakai dan barang bekas biasa dengan cepat.';

	/// id: 'Barang bekas (Verifikasi AI)'
	String get usedItemTitle => 'Barang bekas (Verifikasi AI)';

	/// id: 'AI menganalisis barang Anda untuk membangun kepercayaan dan membantu penjualan.'
	String get usedItemDesc => 'AI menganalisis barang Anda untuk membangun kepercayaan dan membantu penjualan.';
}

// Path: myBling
class TranslationsMyBlingId {
	TranslationsMyBlingId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Bling Saya'
	String get title => 'Bling Saya';

	/// id: 'Edit profil'
	String get editProfile => 'Edit profil';

	/// id: 'Pengaturan'
	String get settings => 'Pengaturan';

	/// id: 'Postingan'
	String get posts => 'Postingan';

	/// id: 'Pengikut'
	String get followers => 'Pengikut';

	/// id: 'Tetangga'
	String get neighbors => 'Tetangga';

	/// id: 'Teman'
	String get friends => 'Teman';

	late final TranslationsMyBlingStatsId stats = TranslationsMyBlingStatsId.internal(_root);
	late final TranslationsMyBlingTabsId tabs = TranslationsMyBlingTabsId.internal(_root);

	/// id: 'Permintaan pertemanan diterima'
	String get friendRequests => 'Permintaan pertemanan diterima';

	/// id: 'Permintaan yang dikirim'
	String get sentFriendRequests => 'Permintaan yang dikirim';
}

// Path: profileView
class TranslationsProfileViewId {
	TranslationsProfileViewId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Profil'
	String get title => 'Profil';

	late final TranslationsProfileViewTabsId tabs = TranslationsProfileViewTabsId.internal(_root);

	/// id: 'Belum ada postingan.'
	String get noPosts => 'Belum ada postingan.';

	/// id: 'Belum ada minat yang disetel.'
	String get noInterests => 'Belum ada minat yang disetel.';
}

// Path: settings
class TranslationsSettingsId {
	TranslationsSettingsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Pengaturan'
	String get title => 'Pengaturan';

	/// id: 'Akun & Privasi'
	String get accountPrivacy => 'Akun & Privasi';

	late final TranslationsSettingsNotificationsId notifications = TranslationsSettingsNotificationsId.internal(_root);

	/// id: 'Info aplikasi'
	String get appInfo => 'Info aplikasi';
}

// Path: friendRequests
class TranslationsFriendRequestsId {
	TranslationsFriendRequestsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Permintaan pertemanan diterima'
	String get title => 'Permintaan pertemanan diterima';

	/// id: 'Belum ada permintaan pertemanan.'
	String get noRequests => 'Belum ada permintaan pertemanan.';

	/// id: 'Permintaan pertemanan diterima.'
	String get acceptSuccess => 'Permintaan pertemanan diterima.';

	/// id: 'Permintaan pertemanan ditolak.'
	String get rejectSuccess => 'Permintaan pertemanan ditolak.';

	/// id: 'Terjadi kesalahan: {error}'
	String get error => 'Terjadi kesalahan: {error}';

	late final TranslationsFriendRequestsTooltipId tooltip = TranslationsFriendRequestsTooltipId.internal(_root);

	/// id: 'Sekarang kalian sudah berteman! Mulai ngobrol, yuk.'
	String get defaultChatMessage => 'Sekarang kalian sudah berteman! Mulai ngobrol, yuk.';
}

// Path: sentFriendRequests
class TranslationsSentFriendRequestsId {
	TranslationsSentFriendRequestsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Permintaan pertemanan terkirim'
	String get title => 'Permintaan pertemanan terkirim';

	/// id: 'Belum ada permintaan pertemanan yang dikirim.'
	String get noRequests => 'Belum ada permintaan pertemanan yang dikirim.';

	/// id: 'Status: {status}'
	String get statusLabel => 'Status: {status}';

	late final TranslationsSentFriendRequestsStatusId status = TranslationsSentFriendRequestsStatusId.internal(_root);
}

// Path: blockedUsers
class TranslationsBlockedUsersId {
	TranslationsBlockedUsersId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Pengguna yang diblokir'
	String get title => 'Pengguna yang diblokir';

	/// id: 'Anda belum memblokir siapa pun.'
	String get noBlockedUsers => 'Anda belum memblokir siapa pun.';

	/// id: 'Buka blokir'
	String get unblock => 'Buka blokir';

	late final TranslationsBlockedUsersUnblockDialogId unblockDialog = TranslationsBlockedUsersUnblockDialogId.internal(_root);

	/// id: 'Blokir untuk {nickname} telah dibuka.'
	String get unblockSuccess => 'Blokir untuk {nickname} telah dibuka.';

	/// id: 'Gagal membuka blokir: {error}'
	String get unblockFailure => 'Gagal membuka blokir: {error}';

	/// id: 'Pengguna tidak dikenal'
	String get unknownUser => 'Pengguna tidak dikenal';

	/// id: 'Tidak ada pengguna yang diblokir.'
	String get empty => 'Tidak ada pengguna yang diblokir.';
}

// Path: rejectedUsers
class TranslationsRejectedUsersId {
	TranslationsRejectedUsersId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Kelola pengguna yang ditolak'
	String get title => 'Kelola pengguna yang ditolak';

	/// id: 'Tidak ada permintaan pertemanan yang Anda tolak.'
	String get noRejectedUsers => 'Tidak ada permintaan pertemanan yang Anda tolak.';

	/// id: 'Batalkan penolakan'
	String get unreject => 'Batalkan penolakan';

	late final TranslationsRejectedUsersUnrejectDialogId unrejectDialog = TranslationsRejectedUsersUnrejectDialogId.internal(_root);

	/// id: 'Penolakan untuk {nickname} telah dibatalkan.'
	String get unrejectSuccess => 'Penolakan untuk {nickname} telah dibatalkan.';

	/// id: 'Gagal membatalkan penolakan: {error}'
	String get unrejectFailure => 'Gagal membatalkan penolakan: {error}';
}

// Path: prompt
class TranslationsPromptId {
	TranslationsPromptId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Selamat datang di Bling!'
	String get title => 'Selamat datang di Bling!';

	/// id: 'Untuk melihat berita dan barang di sekitar, atur lingkungan Anda terlebih dahulu.'
	String get subtitle => 'Untuk melihat berita dan barang di sekitar, atur lingkungan Anda terlebih dahulu.';

	/// id: 'Atur Lingkungan Saya'
	String get button => 'Atur Lingkungan Saya';
}

// Path: location
class TranslationsLocationId {
	TranslationsLocationId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Atur Lingkungan'
	String get title => 'Atur Lingkungan';

	/// id: 'Cari berdasarkan nama lingkungan, mis. Serpong'
	String get searchHint => 'Cari berdasarkan nama lingkungan, mis. Serpong';

	/// id: 'Gunakan lokasi saat ini'
	String get gpsButton => 'Gunakan lokasi saat ini';

	/// id: 'Lingkungan berhasil disetel.'
	String get success => 'Lingkungan berhasil disetel.';

	/// id: 'Gagal menyetel lingkungan: {error}'
	String get error => 'Gagal menyetel lingkungan: {error}';

	/// id: 'Silakan masukkan nama lingkungan.'
	String get empty => 'Silakan masukkan nama lingkungan.';

	/// id: 'Izin lokasi diperlukan untuk menemukan lingkungan Anda.'
	String get permissionDenied => 'Izin lokasi diperlukan untuk menemukan lingkungan Anda.';

	/// id: 'RT'
	String get rtLabel => 'RT';

	/// id: 'RW'
	String get rwLabel => 'RW';

	/// id: 'mis. 003'
	String get rtHint => 'mis. 003';

	/// id: 'mis. 007'
	String get rwHint => 'mis. 007';

	/// id: 'Silakan masukkan RT.'
	String get rtRequired => 'Silakan masukkan RT.';

	/// id: 'Silakan masukkan RW.'
	String get rwRequired => 'Silakan masukkan RW.';

	/// id: 'RT/RW Anda tidak akan ditampilkan ke publik. Data ini hanya digunakan untuk meningkatkan kepercayaan dan fitur lokal.'
	String get rtRwInfo => 'RT/RW Anda tidak akan ditampilkan ke publik. Data ini hanya digunakan untuk meningkatkan kepercayaan dan fitur lokal.';

	/// id: 'Simpan lokasi ini'
	String get saveThisLocation => 'Simpan lokasi ini';

	/// id: 'Pilih manual'
	String get manualSelect => 'Pilih manual';

	/// id: 'Perbarui dari GPS'
	String get refreshFromGps => 'Perbarui dari GPS';
}

// Path: profileEdit
class TranslationsProfileEditId {
	TranslationsProfileEditId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Pengaturan profil'
	String get title => 'Pengaturan profil';

	/// id: 'Nama panggilan'
	String get nicknameHint => 'Nama panggilan';

	/// id: 'Nomor telepon'
	String get phoneHint => 'Nomor telepon';

	/// id: 'Bio'
	String get bioHint => 'Bio';

	/// id: 'Lokasi'
	String get locationTitle => 'Lokasi';

	/// id: 'Ubah'
	String get changeLocation => 'Ubah';

	/// id: 'Belum disetel'
	String get locationNotSet => 'Belum disetel';

	late final TranslationsProfileEditInterestsId interests = TranslationsProfileEditInterestsId.internal(_root);
	late final TranslationsProfileEditPrivacyId privacy = TranslationsProfileEditPrivacyId.internal(_root);

	/// id: 'Simpan perubahan'
	String get saveButton => 'Simpan perubahan';

	/// id: 'Profil berhasil diperbarui.'
	String get successMessage => 'Profil berhasil diperbarui.';

	late final TranslationsProfileEditErrorsId errors = TranslationsProfileEditErrorsId.internal(_root);
}

// Path: mainFeed
class TranslationsMainFeedId {
	TranslationsMainFeedId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Terjadi kesalahan: {error}'
	String get error => 'Terjadi kesalahan: {error}';

	/// id: 'Belum ada postingan baru.'
	String get empty => 'Belum ada postingan baru.';
}

// Path: postCard
class TranslationsPostCardId {
	TranslationsPostCardId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Lokasi belum disetel'
	String get locationNotSet => 'Lokasi belum disetel';

	/// id: 'Lokasi'
	String get location => 'Lokasi';

	/// id: 'Penulis tidak ditemukan'
	String get authorNotFound => 'Penulis tidak ditemukan';
}

// Path: time
class TranslationsTimeId {
	TranslationsTimeId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Baru saja'
	String get now => 'Baru saja';

	/// id: '{minutes} menit yang lalu'
	String get minutesAgo => '{minutes} menit yang lalu';

	/// id: '{hours} jam yang lalu'
	String get hoursAgo => '{hours} jam yang lalu';

	/// id: '{days} hari yang lalu'
	String get daysAgo => '{days} hari yang lalu';

	/// id: 'yy.MM.dd'
	String get dateFormat => 'yy.MM.dd';

	/// id: 'd MMM'
	String get dateFormatLong => 'd MMM';
}

// Path: productCard
class TranslationsProductCardId {
	TranslationsProductCardId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: '$'
	String get currency => '\$';
}

// Path: localNewsFeed
class TranslationsLocalNewsFeedId {
	TranslationsLocalNewsFeedId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Atur lingkungan Anda untuk melihat cerita lokal!'
	String get setLocationPrompt => 'Atur lingkungan Anda untuk melihat cerita lokal!';

	/// id: 'Semua'
	String get allCategory => 'Semua';

	/// id: 'Tidak ada postingan untuk ditampilkan.'
	String get empty => 'Tidak ada postingan untuk ditampilkan.';

	/// id: 'Terjadi kesalahan: {error}'
	String get error => 'Terjadi kesalahan: {error}';
}

// Path: categories
class TranslationsCategoriesId {
	TranslationsCategoriesId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsCategoriesPostId post = TranslationsCategoriesPostId.internal(_root);
	late final TranslationsCategoriesAuctionId auction = TranslationsCategoriesAuctionId.internal(_root);
}

// Path: localNewsCreate
class TranslationsLocalNewsCreateId {
	TranslationsLocalNewsCreateId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Buat postingan baru'
	String get appBarTitle => 'Buat postingan baru';

	/// id: 'Buat postingan baru'
	String get title => 'Buat postingan baru';

	late final TranslationsLocalNewsCreateFormId form = TranslationsLocalNewsCreateFormId.internal(_root);
	late final TranslationsLocalNewsCreateLabelsId labels = TranslationsLocalNewsCreateLabelsId.internal(_root);
	late final TranslationsLocalNewsCreateHintsId hints = TranslationsLocalNewsCreateHintsId.internal(_root);
	late final TranslationsLocalNewsCreateValidationId validation = TranslationsLocalNewsCreateValidationId.internal(_root);
	late final TranslationsLocalNewsCreateButtonsId buttons = TranslationsLocalNewsCreateButtonsId.internal(_root);
	late final TranslationsLocalNewsCreateAlertsId alerts = TranslationsLocalNewsCreateAlertsId.internal(_root);

	/// id: 'Postingan berhasil dibuat.'
	String get success => 'Postingan berhasil dibuat.';

	/// id: 'Gagal membuat postingan: {error}'
	String get fail => 'Gagal membuat postingan: {error}';
}

// Path: localNewsDetail
class TranslationsLocalNewsDetailId {
	TranslationsLocalNewsDetailId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Postingan'
	String get appBarTitle => 'Postingan';

	late final TranslationsLocalNewsDetailMenuId menu = TranslationsLocalNewsDetailMenuId.internal(_root);
	late final TranslationsLocalNewsDetailStatsId stats = TranslationsLocalNewsDetailStatsId.internal(_root);
	late final TranslationsLocalNewsDetailButtonsId buttons = TranslationsLocalNewsDetailButtonsId.internal(_root);

	/// id: 'Yakin ingin menghapus postingan ini?'
	String get confirmDelete => 'Yakin ingin menghapus postingan ini?';

	/// id: 'Postingan telah dihapus.'
	String get deleted => 'Postingan telah dihapus.';
}

// Path: localNewsEdit
class TranslationsLocalNewsEditId {
	TranslationsLocalNewsEditId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Edit postingan'
	String get appBarTitle => 'Edit postingan';

	late final TranslationsLocalNewsEditButtonsId buttons = TranslationsLocalNewsEditButtonsId.internal(_root);
	late final TranslationsLocalNewsEditAlertsId alerts = TranslationsLocalNewsEditAlertsId.internal(_root);
}

// Path: commentInputField
class TranslationsCommentInputFieldId {
	TranslationsCommentInputFieldId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Rahasia'
	String get secretCommentLabel => 'Rahasia';

	/// id: 'Tulis komentar...'
	String get hintText => 'Tulis komentar...';

	/// id: 'Membalas {nickname}...'
	String get replyHintText => 'Membalas {nickname}...';

	late final TranslationsCommentInputFieldButtonId button = TranslationsCommentInputFieldButtonId.internal(_root);
}

// Path: commentListView
class TranslationsCommentListViewId {
	TranslationsCommentListViewId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Belum ada komentar. Jadilah yang pertama!'
	String get empty => 'Belum ada komentar. Jadilah yang pertama!';

	/// id: 'Balas'
	String get reply => 'Balas';

	/// id: 'Hapus'
	String get delete => 'Hapus';

	/// id: '[Komentar ini telah dihapus]'
	String get deleted => '[Komentar ini telah dihapus]';

	/// id: 'Ini adalah komentar rahasia yang hanya bisa dilihat penulis dan pemilik postingan.'
	String get secret => 'Ini adalah komentar rahasia yang hanya bisa dilihat penulis dan pemilik postingan.';
}

// Path: common
class TranslationsCommonId {
	TranslationsCommonId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Batal'
	String get cancel => 'Batal';

	/// id: 'OK'
	String get confirm => 'OK';

	/// id: 'Hapus'
	String get delete => 'Hapus';

	/// id: 'Selesai'
	String get done => 'Selesai';

	/// id: 'Bersihkan'
	String get clear => 'Bersihkan';

	/// id: 'Laporkan'
	String get report => 'Laporkan';

	/// id: 'Lainnya'
	String get moreOptions => 'Lainnya';

	/// id: 'Lihat semua'
	String get viewAll => 'Lihat semua';

	/// id: 'Baru'
	String get kNew => 'Baru';

	/// id: 'Diperbarui'
	String get updated => 'Diperbarui';

	/// id: 'Komentar'
	String get comments => 'Komentar';

	/// id: 'Sponsor'
	String get sponsored => 'Sponsor';

	/// id: 'Filter'
	String get filter => 'Filter';

	/// id: 'Reset'
	String get reset => 'Reset';

	/// id: 'Terapkan'
	String get apply => 'Terapkan';

	/// id: 'Terverifikasi'
	String get verified => 'Terverifikasi';

	/// id: 'Bookmark'
	String get bookmark => 'Bookmark';

	late final TranslationsCommonSortId sort = TranslationsCommonSortId.internal(_root);

	/// id: 'Terjadi kesalahan.'
	String get error => 'Terjadi kesalahan.';

	/// id: 'Gagal membagikan. Silakan coba lagi.'
	String get shareError => 'Gagal membagikan. Silakan coba lagi.';

	/// id: 'Edit'
	String get edit => 'Edit';

	/// id: 'Kirim'
	String get submit => 'Kirim';

	/// id: 'Login diperlukan.'
	String get loginRequired => 'Login diperlukan.';

	/// id: 'Pengguna tidak dikenal.'
	String get unknownUser => 'Pengguna tidak dikenal.';
}

// Path: reportDialog
class TranslationsReportDialogId {
	TranslationsReportDialogId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Laporkan postingan'
	String get title => 'Laporkan postingan';

	/// id: 'Laporkan komentar'
	String get titleComment => 'Laporkan komentar';

	/// id: 'Laporkan balasan'
	String get titleReply => 'Laporkan balasan';

	/// id: 'Anda tidak dapat melaporkan komentar Anda sendiri.'
	String get cannotReportSelfComment => 'Anda tidak dapat melaporkan komentar Anda sendiri.';

	/// id: 'Anda tidak dapat melaporkan balasan Anda sendiri.'
	String get cannotReportSelfReply => 'Anda tidak dapat melaporkan balasan Anda sendiri.';

	/// id: 'Laporan telah dikirim. Terima kasih.'
	String get success => 'Laporan telah dikirim. Terima kasih.';

	/// id: 'Gagal mengirim laporan: {error}'
	String get fail => 'Gagal mengirim laporan: {error}';

	/// id: 'Anda tidak dapat melaporkan postingan Anda sendiri.'
	String get cannotReportSelf => 'Anda tidak dapat melaporkan postingan Anda sendiri.';
}

// Path: replyDelete
class TranslationsReplyDeleteId {
	TranslationsReplyDeleteId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Gagal menghapus balasan: {error}'
	String get fail => 'Gagal menghapus balasan: {error}';
}

// Path: reportReasons
class TranslationsReportReasonsId {
	TranslationsReportReasonsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Spam atau menyesatkan'
	String get spam => 'Spam atau menyesatkan';

	/// id: 'Pelecehan atau ujaran kebencian'
	String get abuse => 'Pelecehan atau ujaran kebencian';

	/// id: 'Tidak pantas secara seksual'
	String get inappropriate => 'Tidak pantas secara seksual';

	/// id: 'Konten ilegal'
	String get illegal => 'Konten ilegal';

	/// id: 'Lainnya'
	String get etc => 'Lainnya';
}

// Path: deleteConfirm
class TranslationsDeleteConfirmId {
	TranslationsDeleteConfirmId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Hapus komentar'
	String get title => 'Hapus komentar';

	/// id: 'Yakin ingin menghapus komentar ini?'
	String get content => 'Yakin ingin menghapus komentar ini?';

	/// id: 'Gagal menghapus komentar: {error}'
	String get failure => 'Gagal menghapus komentar: {error}';
}

// Path: replyInputField
class TranslationsReplyInputFieldId {
	TranslationsReplyInputFieldId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Tulis balasan'
	String get hintText => 'Tulis balasan';

	late final TranslationsReplyInputFieldButtonId button = TranslationsReplyInputFieldButtonId.internal(_root);

	/// id: 'Gagal menambahkan balasan: {error}'
	String get failure => 'Gagal menambahkan balasan: {error}';
}

// Path: chatList
class TranslationsChatListId {
	TranslationsChatListId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Chat'
	String get appBarTitle => 'Chat';

	/// id: 'Belum ada percakapan.'
	String get empty => 'Belum ada percakapan.';
}

// Path: chatRoom
class TranslationsChatRoomId {
	TranslationsChatRoomId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Mulai percakapan'
	String get startConversation => 'Mulai percakapan';

	/// id: 'Halo! 👋'
	String get icebreaker1 => 'Halo! 👋';

	/// id: 'Biasanya kamu ngapain kalau weekend?'
	String get icebreaker2 => 'Biasanya kamu ngapain kalau weekend?';

	/// id: 'Ada tempat favorit di sekitar sini?'
	String get icebreaker3 => 'Ada tempat favorit di sekitar sini?';

	/// id: 'Demi keamanan, pengiriman media dibatasi selama 24 jam.'
	String get mediaBlocked => 'Demi keamanan, pengiriman media dibatasi selama 24 jam.';

	/// id: 'Gambar'
	String get imageMessage => 'Gambar';

	/// id: 'Mode perlindungan: tautan disembunyikan'
	String get linkHidden => 'Mode perlindungan: tautan disembunyikan';

	/// id: 'Mode perlindungan: kontak disembunyikan'
	String get contactHidden => 'Mode perlindungan: kontak disembunyikan';
}

// Path: jobs
class TranslationsJobsId {
	TranslationsJobsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Atur lokasi Anda untuk melihat lowongan kerja!'
	String get setLocationPrompt => 'Atur lokasi Anda untuk melihat lowongan kerja!';

	late final TranslationsJobsScreenId screen = TranslationsJobsScreenId.internal(_root);
	late final TranslationsJobsTabsId tabs = TranslationsJobsTabsId.internal(_root);
	late final TranslationsJobsSelectTypeId selectType = TranslationsJobsSelectTypeId.internal(_root);
	late final TranslationsJobsFormId form = TranslationsJobsFormId.internal(_root);
	late final TranslationsJobsCategoriesId categories = TranslationsJobsCategoriesId.internal(_root);
	late final TranslationsJobsSalaryTypesId salaryTypes = TranslationsJobsSalaryTypesId.internal(_root);
	late final TranslationsJobsWorkPeriodsId workPeriods = TranslationsJobsWorkPeriodsId.internal(_root);
	late final TranslationsJobsDetailId detail = TranslationsJobsDetailId.internal(_root);
	late final TranslationsJobsCardId card = TranslationsJobsCardId.internal(_root);
}

// Path: boards
class TranslationsBoardsId {
	TranslationsBoardsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsBoardsPopupId popup = TranslationsBoardsPopupId.internal(_root);

	/// id: 'Papan'
	String get defaultTitle => 'Papan';

	/// id: 'Ruang chat segera hadir'
	String get chatRoomComingSoon => 'Ruang chat segera hadir';

	/// id: 'Ruang Chat'
	String get chatRoomTitle => 'Ruang Chat';

	/// id: 'Belum ada postingan.'
	String get emptyFeed => 'Belum ada postingan.';

	/// id: 'Ruang chat telah dibuat.'
	String get chatRoomCreated => 'Ruang chat telah dibuat.';
}

// Path: signup
class TranslationsSignupId {
	TranslationsSignupId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsSignupAlertsId alerts = TranslationsSignupAlertsId.internal(_root);

	/// id: 'Daftar'
	String get title => 'Daftar';

	/// id: 'Bergabunglah dengan komunitas lingkungan Anda!'
	String get subtitle => 'Bergabunglah dengan komunitas lingkungan Anda!';

	/// id: 'Nama panggilan'
	String get nicknameHint => 'Nama panggilan';

	/// id: 'Alamat email'
	String get emailHint => 'Alamat email';

	/// id: 'Kata sandi'
	String get passwordHint => 'Kata sandi';

	/// id: 'Konfirmasi kata sandi'
	String get passwordConfirmHint => 'Konfirmasi kata sandi';

	/// id: 'Lokasi'
	String get locationHint => 'Lokasi';

	/// id: 'Lokasi Anda hanya digunakan untuk menampilkan postingan lokal dan tidak dibagikan.'
	String get locationNotice => 'Lokasi Anda hanya digunakan untuk menampilkan postingan lokal dan tidak dibagikan.';

	late final TranslationsSignupButtonsId buttons = TranslationsSignupButtonsId.internal(_root);
}

// Path: user
class TranslationsUserId {
	TranslationsUserId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Belum login.'
	String get notLoggedIn => 'Belum login.';
}

// Path: findFriend
class TranslationsFindFriendId {
	TranslationsFindFriendId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Find Friends'
	String get title => 'Find Friends';

	late final TranslationsFindFriendTabsId tabs = TranslationsFindFriendTabsId.internal(_root);

	/// id: 'Edit FindFriend Profile'
	String get editTitle => 'Edit FindFriend Profile';

	/// id: 'Edit Profile'
	String get editProfileTitle => 'Edit Profile';

	/// id: 'Save'
	String get save => 'Save';

	/// id: 'Profile Images (Max 6)'
	String get profileImagesLabel => 'Profile Images (Max 6)';

	/// id: 'Bio'
	String get bioLabel => 'Bio';

	/// id: 'Introduce yourself to others.'
	String get bioHint => 'Introduce yourself to others.';

	/// id: 'Please enter your bio.'
	String get bioValidator => 'Please enter your bio.';

	/// id: 'Age'
	String get ageLabel => 'Age';

	/// id: 'Enter your age.'
	String get ageHint => 'Enter your age.';

	/// id: 'Gender'
	String get genderLabel => 'Gender';

	/// id: 'Male'
	String get genderMale => 'Male';

	/// id: 'Female'
	String get genderFemale => 'Female';

	/// id: 'Select your gender'
	String get genderHint => 'Select your gender';

	/// id: 'Interests'
	String get interestsLabel => 'Interests';

	/// id: 'Preferred Friend Age'
	String get preferredAgeLabel => 'Preferred Friend Age';

	/// id: 'yrs'
	String get preferredAgeUnit => 'yrs';

	/// id: 'Preferred Friend Gender'
	String get preferredGenderLabel => 'Preferred Friend Gender';

	/// id: 'All'
	String get preferredGenderAll => 'All';

	/// id: 'Show my profile in the list'
	String get showProfileLabel => 'Show my profile in the list';

	/// id: 'If off, others cannot find you.'
	String get showProfileSubtitle => 'If off, others cannot find you.';

	/// id: 'Profile saved!'
	String get saveSuccess => 'Profile saved!';

	/// id: 'Failed to save profile:'
	String get saveFailed => 'Failed to save profile:';

	/// id: 'Login is required.'
	String get loginRequired => 'Login is required.';

	/// id: 'No nearby friends found.'
	String get noFriendsFound => 'No nearby friends found.';

	/// id: 'To meet new friends, please create your profile first!'
	String get promptTitle => 'To meet new friends,\nplease create your profile first!';

	/// id: 'Create My Profile'
	String get promptButton => 'Create My Profile';

	/// id: 'You have reached your daily limit ({limit}) for starting new chats.'
	String get chatLimitReached => 'You have reached your daily limit ({limit}) for starting new chats.';

	/// id: 'Checking...'
	String get chatChecking => 'Checking...';

	/// id: 'No profiles to show yet.'
	String get empty => 'No profiles to show yet.';
}

// Path: interests
class TranslationsInterestsId {
	TranslationsInterestsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Interests'
	String get title => 'Interests';

	/// id: 'You can select up to 10.'
	String get limitInfo => 'You can select up to 10.';

	/// id: 'You can select up to 10 interests.'
	String get limitReached => 'You can select up to 10 interests.';

	/// id: '🎨 Creative'
	String get categoryCreative => '🎨 Creative';

	/// id: '🏃 Sports & Activities'
	String get categorySports => '🏃 Sports & Activities';

	/// id: '🍸 Food & Drinks'
	String get categoryFoodDrink => '🍸 Food & Drinks';

	/// id: '🍿 Entertainment'
	String get categoryEntertainment => '🍿 Entertainment';

	/// id: '📚 Self-development'
	String get categoryGrowth => '📚 Self-development';

	/// id: '🌴 Lifestyle'
	String get categoryLifestyle => '🌴 Lifestyle';

	late final TranslationsInterestsItemsId items = TranslationsInterestsItemsId.internal(_root);
}

// Path: friendDetail
class TranslationsFriendDetailId {
	TranslationsFriendDetailId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Send Request'
	String get request => 'Send Request';

	/// id: 'Sent'
	String get requestSent => 'Sent';

	/// id: 'Already Friends'
	String get alreadyFriends => 'Already Friends';

	/// id: 'Request failed:'
	String get requestFailed => 'Request failed:';

	/// id: 'Could not start chat.'
	String get chatError => 'Could not start chat.';

	/// id: 'Start Chat'
	String get startChat => 'Start Chat';

	/// id: 'Block'
	String get block => 'Block';

	/// id: 'Report'
	String get report => 'Report';

	/// id: 'Login is required.'
	String get loginRequired => 'Login is required.';

	/// id: 'User has been unblocked.'
	String get unblocked => 'User has been unblocked.';

	/// id: 'User has been blocked.'
	String get blocked => 'User has been blocked.';

	/// id: 'Unblock'
	String get unblock => 'Unblock';
}

// Path: locationFilter
class TranslationsLocationFilterId {
	TranslationsLocationFilterId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Location Filter'
	String get title => 'Location Filter';

	/// id: 'Provinsi'
	String get provinsi => 'Provinsi';

	/// id: 'Kabupaten'
	String get kabupaten => 'Kabupaten';

	/// id: 'Kota'
	String get kota => 'Kota';

	/// id: 'Kecamatan'
	String get kecamatan => 'Kecamatan';

	/// id: 'Kelurahan'
	String get kelurahan => 'Kelurahan';

	/// id: 'Apply Filter'
	String get apply => 'Apply Filter';

	/// id: 'All'
	String get all => 'All';

	/// id: 'Reset'
	String get reset => 'Reset';
}

// Path: clubs
class TranslationsClubsId {
	TranslationsClubsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsClubsTabsId tabs = TranslationsClubsTabsId.internal(_root);
	late final TranslationsClubsSectionsId sections = TranslationsClubsSectionsId.internal(_root);
	late final TranslationsClubsScreenId screen = TranslationsClubsScreenId.internal(_root);
	late final TranslationsClubsPostListId postList = TranslationsClubsPostListId.internal(_root);
	late final TranslationsClubsMemberCardId memberCard = TranslationsClubsMemberCardId.internal(_root);
	late final TranslationsClubsPostCardId postCard = TranslationsClubsPostCardId.internal(_root);
	late final TranslationsClubsCardId card = TranslationsClubsCardId.internal(_root);
	late final TranslationsClubsPostDetailId postDetail = TranslationsClubsPostDetailId.internal(_root);
	late final TranslationsClubsDetailId detail = TranslationsClubsDetailId.internal(_root);
	late final TranslationsClubsMemberListId memberList = TranslationsClubsMemberListId.internal(_root);
	late final TranslationsClubsCreatePostId createPost = TranslationsClubsCreatePostId.internal(_root);
	late final TranslationsClubsCreateClubId createClub = TranslationsClubsCreateClubId.internal(_root);
	late final TranslationsClubsEditClubId editClub = TranslationsClubsEditClubId.internal(_root);
	late final TranslationsClubsCreateId create = TranslationsClubsCreateId.internal(_root);
	late final TranslationsClubsRepositoryId repository = TranslationsClubsRepositoryId.internal(_root);
	late final TranslationsClubsProposalId proposal = TranslationsClubsProposalId.internal(_root);

	/// id: 'No clubs to display.'
	String get empty => 'No clubs to display.';
}

// Path: findfriend
class TranslationsFindfriendId {
	TranslationsFindfriendId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsFindfriendFormId form = TranslationsFindfriendFormId.internal(_root);
}

// Path: auctions
class TranslationsAuctionsId {
	TranslationsAuctionsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsAuctionsCardId card = TranslationsAuctionsCardId.internal(_root);
	late final TranslationsAuctionsErrorsId errors = TranslationsAuctionsErrorsId.internal(_root);

	/// id: 'No auctions.'
	String get empty => 'No auctions.';

	late final TranslationsAuctionsFilterId filter = TranslationsAuctionsFilterId.internal(_root);
	late final TranslationsAuctionsCreateId create = TranslationsAuctionsCreateId.internal(_root);
	late final TranslationsAuctionsEditId edit = TranslationsAuctionsEditId.internal(_root);
	late final TranslationsAuctionsFormId form = TranslationsAuctionsFormId.internal(_root);
	late final TranslationsAuctionsDeleteId delete = TranslationsAuctionsDeleteId.internal(_root);
	late final TranslationsAuctionsDetailId detail = TranslationsAuctionsDetailId.internal(_root);
}

// Path: localStores
class TranslationsLocalStoresId {
	TranslationsLocalStoresId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Set your location to see nearby stores.'
	String get setLocationPrompt => 'Set your location to see nearby stores.';

	/// id: 'No stores yet.'
	String get empty => 'No stores yet.';

	/// id: 'An error occurred: {error}'
	String get error => 'An error occurred: {error}';

	late final TranslationsLocalStoresCreateId create = TranslationsLocalStoresCreateId.internal(_root);
	late final TranslationsLocalStoresEditId edit = TranslationsLocalStoresEditId.internal(_root);
	late final TranslationsLocalStoresFormId form = TranslationsLocalStoresFormId.internal(_root);
	late final TranslationsLocalStoresCategoriesId categories = TranslationsLocalStoresCategoriesId.internal(_root);
	late final TranslationsLocalStoresDetailId detail = TranslationsLocalStoresDetailId.internal(_root);

	/// id: 'No location info'
	String get noLocation => 'No location info';
}

// Path: pom
class TranslationsPomId {
	TranslationsPomId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'POM'
	String get title => 'POM';

	late final TranslationsPomSearchId search = TranslationsPomSearchId.internal(_root);
	late final TranslationsPomTabsId tabs = TranslationsPomTabsId.internal(_root);

	/// id: 'More'
	String get more => 'More';

	/// id: 'Less'
	String get less => 'Less';

	/// id: '{} likes'
	String get likesCount => '{} likes';

	/// id: 'Report {}'
	String get report => 'Report {}';

	/// id: 'Block {}'
	String get block => 'Block {}';

	/// id: 'No popular POMs yet.'
	String get emptyPopular => 'No popular POMs yet.';

	/// id: 'You haven't uploaded any POMs yet.'
	String get emptyMine => 'You haven\'t uploaded any POMs yet.';

	/// id: 'Try the All tab to see the latest POMs.'
	String get emptyHintPopular => 'Try the All tab to see the latest POMs.';

	/// id: 'Tap + to upload your first POM.'
	String get emptyCtaMine => 'Tap + to upload your first POM.';

	/// id: 'Share'
	String get share => 'Share';

	/// id: 'No POM uploaded.'
	String get empty => 'No POM uploaded.';

	late final TranslationsPomErrorsId errors = TranslationsPomErrorsId.internal(_root);
	late final TranslationsPomCommentsId comments = TranslationsPomCommentsId.internal(_root);
	late final TranslationsPomCreateId create = TranslationsPomCreateId.internal(_root);
}

// Path: realEstate
class TranslationsRealEstateId {
	TranslationsRealEstateId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Tambahkan listing'
	String get create => 'Tambahkan listing';

	late final TranslationsRealEstateFormId form = TranslationsRealEstateFormId.internal(_root);
	late final TranslationsRealEstateDetailId detail = TranslationsRealEstateDetailId.internal(_root);

	/// id: 'Tidak ada info lokasi'
	String get locationUnknown => 'Tidak ada info lokasi';

	late final TranslationsRealEstatePriceUnitsId priceUnits = TranslationsRealEstatePriceUnitsId.internal(_root);
	late final TranslationsRealEstateFilterId filter = TranslationsRealEstateFilterId.internal(_root);
	late final TranslationsRealEstateInfoId info = TranslationsRealEstateInfoId.internal(_root);

	/// id: 'Bling adalah platform iklan dan bukan agen/broker properti. Keakuratan informasi, kepemilikan, harga, dan syarat merupakan tanggung jawab penuh pengiklan. Pengguna harus memverifikasi seluruh informasi langsung dengan pengiklan dan pihak berwenang sebelum melanjutkan transaksi.'
	String get disclaimer => 'Bling adalah platform iklan dan bukan agen/broker properti. Keakuratan informasi, kepemilikan, harga, dan syarat merupakan tanggung jawab penuh pengiklan. Pengguna harus memverifikasi seluruh informasi langsung dengan pengiklan dan pihak berwenang sebelum melanjutkan transaksi.';

	/// id: 'Tidak ada listing.'
	String get empty => 'Tidak ada listing.';

	/// id: 'Terjadi kesalahan: {error}'
	String get error => 'Terjadi kesalahan: {error}';

	late final TranslationsRealEstatePriceUnitId priceUnit = TranslationsRealEstatePriceUnitId.internal(_root);
	late final TranslationsRealEstateEditId edit = TranslationsRealEstateEditId.internal(_root);
}

// Path: lostAndFound
class TranslationsLostAndFoundId {
	TranslationsLostAndFoundId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsLostAndFoundTabsId tabs = TranslationsLostAndFoundTabsId.internal(_root);

	/// id: 'Tambahkan barang hilang/temuan'
	String get create => 'Tambahkan barang hilang/temuan';

	late final TranslationsLostAndFoundFormId form = TranslationsLostAndFoundFormId.internal(_root);
	late final TranslationsLostAndFoundDetailId detail = TranslationsLostAndFoundDetailId.internal(_root);

	/// id: 'Hilang'
	String get lost => 'Hilang';

	/// id: 'Ditemukan'
	String get found => 'Ditemukan';

	late final TranslationsLostAndFoundCardId card = TranslationsLostAndFoundCardId.internal(_root);

	/// id: 'No lost/found items yet.'
	String get empty => 'No lost/found items yet.';

	/// id: 'An error occurred: {error}'
	String get error => 'An error occurred: {error}';

	late final TranslationsLostAndFoundResolveId resolve = TranslationsLostAndFoundResolveId.internal(_root);
	late final TranslationsLostAndFoundEditId edit = TranslationsLostAndFoundEditId.internal(_root);
}

// Path: community
class TranslationsCommunityId {
	TranslationsCommunityId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Community Screen'
	String get title => 'Community Screen';
}

// Path: shared
class TranslationsSharedId {
	TranslationsSharedId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsSharedTagInputId tagInput = TranslationsSharedTagInputId.internal(_root);
}

// Path: linkPreview
class TranslationsLinkPreviewId {
	TranslationsLinkPreviewId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Could not load preview'
	String get errorTitle => 'Could not load preview';

	/// id: 'Please check the link or try again later.'
	String get errorBody => 'Please check the link or try again later.';
}

// Path: localNewsTagResult
class TranslationsLocalNewsTagResultId {
	TranslationsLocalNewsTagResultId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'An error occurred during search: {error}'
	String get error => 'An error occurred during search: {error}';

	/// id: 'No posts found with '#{tag}'.'
	String get empty => 'No posts found with \'#{tag}\'.';
}

// Path: admin
class TranslationsAdminId {
	TranslationsAdminId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsAdminScreenId screen = TranslationsAdminScreenId.internal(_root);
	late final TranslationsAdminMenuId menu = TranslationsAdminMenuId.internal(_root);
	late final TranslationsAdminAiApprovalId aiApproval = TranslationsAdminAiApprovalId.internal(_root);
	late final TranslationsAdminReportsId reports = TranslationsAdminReportsId.internal(_root);
	late final TranslationsAdminReportListId reportList = TranslationsAdminReportListId.internal(_root);
	late final TranslationsAdminReportDetailId reportDetail = TranslationsAdminReportDetailId.internal(_root);
	late final TranslationsAdminDataFixId dataFix = TranslationsAdminDataFixId.internal(_root);
}

// Path: tags
class TranslationsTagsId {
	TranslationsTagsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsTagsLocalNewsId localNews = TranslationsTagsLocalNewsId.internal(_root);
}

// Path: login.buttons
class TranslationsLoginButtonsId {
	TranslationsLoginButtonsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Masuk'
	String get login => 'Masuk';

	/// id: 'Lanjut dengan Google'
	String get google => 'Lanjut dengan Google';

	/// id: 'Lanjut dengan Apple'
	String get apple => 'Lanjut dengan Apple';
}

// Path: login.links
class TranslationsLoginLinksId {
	TranslationsLoginLinksId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Lupa kata sandi?'
	String get findPassword => 'Lupa kata sandi?';

	/// id: 'Belum punya akun?'
	String get askForAccount => 'Belum punya akun?';

	/// id: 'Daftar'
	String get signUp => 'Daftar';
}

// Path: login.alerts
class TranslationsLoginAlertsId {
	TranslationsLoginAlertsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Format email tidak valid.'
	String get invalidEmail => 'Format email tidak valid.';

	/// id: 'Pengguna tidak ditemukan atau kata sandi salah.'
	String get userNotFound => 'Pengguna tidak ditemukan atau kata sandi salah.';

	/// id: 'Kata sandi salah.'
	String get wrongPassword => 'Kata sandi salah.';

	/// id: 'Terjadi kesalahan. Silakan coba lagi.'
	String get unknownError => 'Terjadi kesalahan. Silakan coba lagi.';
}

// Path: main.appBar
class TranslationsMainAppBarId {
	TranslationsMainAppBarId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Lokasi belum diatur'
	String get locationNotSet => 'Lokasi belum diatur';

	/// id: 'Kesalahan lokasi'
	String get locationError => 'Kesalahan lokasi';

	/// id: 'Memuat...'
	String get locationLoading => 'Memuat...';
}

// Path: main.tabs
class TranslationsMainTabsId {
	TranslationsMainTabsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Feed Baru'
	String get newFeed => 'Feed Baru';

	/// id: 'Berita Lingkungan'
	String get localNews => 'Berita Lingkungan';

	/// id: 'Preloved'
	String get marketplace => 'Preloved';

	/// id: 'Cari Teman'
	String get findFriends => 'Cari Teman';

	/// id: 'Klub'
	String get clubs => 'Klub';

	/// id: 'Pekerjaan'
	String get jobs => 'Pekerjaan';

	/// id: 'Toko Sekitar'
	String get localStores => 'Toko Sekitar';

	/// id: 'Lelang'
	String get auction => 'Lelang';

	/// id: 'POM'
	String get pom => 'POM';

	/// id: 'Hilang & Temuan'
	String get lostAndFound => 'Hilang & Temuan';

	/// id: 'Properti'
	String get realEstate => 'Properti';
}

// Path: main.bottomNav
class TranslationsMainBottomNavId {
	TranslationsMainBottomNavId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Beranda'
	String get home => 'Beranda';

	/// id: 'Lingkungan'
	String get board => 'Lingkungan';

	/// id: 'Cari'
	String get search => 'Cari';

	/// id: 'Chat'
	String get chat => 'Chat';

	/// id: 'Bling Saya'
	String get myBling => 'Bling Saya';
}

// Path: main.errors
class TranslationsMainErrorsId {
	TranslationsMainErrorsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Harus masuk terlebih dahulu.'
	String get loginRequired => 'Harus masuk terlebih dahulu.';

	/// id: 'Pengguna tidak ditemukan.'
	String get userNotFound => 'Pengguna tidak ditemukan.';

	/// id: 'Terjadi kesalahan.'
	String get unknown => 'Terjadi kesalahan.';
}

// Path: main.mapView
class TranslationsMainMapViewId {
	TranslationsMainMapViewId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Lihat peta'
	String get showMap => 'Lihat peta';

	/// id: 'Lihat daftar'
	String get showList => 'Lihat daftar';
}

// Path: main.search
class TranslationsMainSearchId {
	TranslationsMainSearchId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Cari'
	String get placeholder => 'Cari';

	/// id: 'Cari tetangga, berita, preloved, pekerjaan…'
	String get chipPlaceholder => 'Cari tetangga, berita, preloved, pekerjaan…';

	late final TranslationsMainSearchHintId hint = TranslationsMainSearchHintId.internal(_root);
}

// Path: search.empty
class TranslationsSearchEmptyId {
	TranslationsSearchEmptyId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Tidak ada hasil untuk '{keyword}'.'
	String get message => 'Tidak ada hasil untuk \'{keyword}\'.';

	/// id: 'Periksa ejaan atau coba kata kunci lain.'
	String get checkSpelling => 'Periksa ejaan atau coba kata kunci lain.';

	/// id: 'Cari secara Nasional'
	String get expandToNational => 'Cari secara Nasional';
}

// Path: search.sheet
class TranslationsSearchSheetId {
	TranslationsSearchSheetId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Cari Berita Lingkungan'
	String get localNews => 'Cari Berita Lingkungan';

	/// id: 'Cari berdasarkan judul, isi, tag'
	String get localNewsDesc => 'Cari berdasarkan judul, isi, tag';

	/// id: 'Cari Pekerjaan'
	String get jobs => 'Cari Pekerjaan';

	/// id: 'Cari berdasarkan posisi, perusahaan, tag'
	String get jobsDesc => 'Cari berdasarkan posisi, perusahaan, tag';

	/// id: 'Cari Hilang & Temuan'
	String get lostAndFound => 'Cari Hilang & Temuan';

	/// id: 'Cari berdasarkan nama barang atau lokasi'
	String get lostAndFoundDesc => 'Cari berdasarkan nama barang atau lokasi';

	/// id: 'Cari Preloved'
	String get marketplace => 'Cari Preloved';

	/// id: 'Cari berdasarkan nama barang, kategori, tag'
	String get marketplaceDesc => 'Cari berdasarkan nama barang, kategori, tag';

	/// id: 'Cari Toko Sekitar'
	String get localStores => 'Cari Toko Sekitar';

	/// id: 'Cari berdasarkan nama toko, jenis usaha, kata kunci'
	String get localStoresDesc => 'Cari berdasarkan nama toko, jenis usaha, kata kunci';

	/// id: 'Cari Klub'
	String get clubs => 'Cari Klub';

	/// id: 'Cari berdasarkan nama klub, minat'
	String get clubsDesc => 'Cari berdasarkan nama klub, minat';

	/// id: 'Cari Teman'
	String get findFriends => 'Cari Teman';

	/// id: 'Cari berdasarkan nama panggilan atau minat'
	String get findFriendsDesc => 'Cari berdasarkan nama panggilan atau minat';

	/// id: 'Cari Properti'
	String get realEstate => 'Cari Properti';

	/// id: 'Cari berdasarkan judul, area, tag'
	String get realEstateDesc => 'Cari berdasarkan judul, area, tag';

	/// id: 'Cari Lelang'
	String get auction => 'Cari Lelang';

	/// id: 'Cari berdasarkan nama barang atau tag'
	String get auctionDesc => 'Cari berdasarkan nama barang atau tag';

	/// id: 'Cari POM'
	String get pom => 'Cari POM';

	/// id: 'Cari berdasarkan judul atau hashtag'
	String get pomDesc => 'Cari berdasarkan judul atau hashtag';

	/// id: 'Segera hadir'
	String get comingSoon => 'Segera hadir';
}

// Path: drawer.trustDashboard
class TranslationsDrawerTrustDashboardId {
	TranslationsDrawerTrustDashboardId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Status Verifikasi Kepercayaan'
	String get title => 'Status Verifikasi Kepercayaan';

	/// id: 'Verifikasi Kelurahan'
	String get kelurahanAuth => 'Verifikasi Kelurahan';

	/// id: 'Verifikasi Alamat (RT/RW)'
	String get rtRwAuth => 'Verifikasi Alamat (RT/RW)';

	/// id: 'Verifikasi Nomor Telepon'
	String get phoneAuth => 'Verifikasi Nomor Telepon';

	/// id: 'Profil Lengkap'
	String get profileComplete => 'Profil Lengkap';

	/// id: 'Terima Kasih Feed'
	String get feedThanks => 'Terima Kasih Feed';

	/// id: 'Terima Kasih Marketplace'
	String get marketThanks => 'Terima Kasih Marketplace';

	/// id: 'Laporan'
	String get reports => 'Laporan';

	/// id: 'Detail'
	String get breakdownButton => 'Detail';

	/// id: 'Rincian Skor Kepercayaan'
	String get breakdownModalTitle => 'Rincian Skor Kepercayaan';

	/// id: 'OK'
	String get breakdownClose => 'OK';

	late final TranslationsDrawerTrustDashboardBreakdownId breakdown = TranslationsDrawerTrustDashboardBreakdownId.internal(_root);
}

// Path: marketplace.registration
class TranslationsMarketplaceRegistrationId {
	TranslationsMarketplaceRegistrationId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Posting Baru'
	String get title => 'Posting Baru';

	/// id: 'Simpan'
	String get done => 'Simpan';

	/// id: 'Nama Barang'
	String get titleHint => 'Nama Barang';

	/// id: 'Harga (Rp)'
	String get priceHint => 'Harga (Rp)';

	/// id: 'Bisa Nego'
	String get negotiable => 'Bisa Nego';

	/// id: 'Lingkungan'
	String get addressHint => 'Lingkungan';

	/// id: 'Tempat Bertemu'
	String get addressDetailHint => 'Tempat Bertemu';

	/// id: 'Deskripsi Lengkap'
	String get descriptionHint => 'Deskripsi Lengkap';

	/// id: 'Produk berhasil diposting!'
	String get success => 'Produk berhasil diposting!';

	/// id: 'Tambah tag (tekan spasi untuk konfirmasi)'
	String get tagsHint => 'Tambah tag (tekan spasi untuk konfirmasi)';

	/// id: 'gagal'
	String get fail => 'gagal';
}

// Path: marketplace.edit
class TranslationsMarketplaceEditId {
	TranslationsMarketplaceEditId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Edit Postingan'
	String get title => 'Edit Postingan';

	/// id: 'Selesai Update'
	String get done => 'Selesai Update';

	/// id: 'Edit nama barang'
	String get titleHint => 'Edit nama barang';

	/// id: 'Edit lokasi'
	String get addressHint => 'Edit lokasi';

	/// id: 'Edit harga (Rp)'
	String get priceHint => 'Edit harga (Rp)';

	/// id: 'Edit bisa nego'
	String get negotiable => 'Edit bisa nego';

	/// id: 'Edit deskripsi'
	String get descriptionHint => 'Edit deskripsi';

	/// id: 'Tambah tag (tekan spasi untuk konfirmasi)'
	String get tagsHint => 'Tambah tag (tekan spasi untuk konfirmasi)';

	/// id: 'Produk berhasil diperbarui.'
	String get success => 'Produk berhasil diperbarui.';

	/// id: 'Gagal mengupdate produk: {error}'
	String get fail => 'Gagal mengupdate produk: {error}';

	/// id: 'Reset lokasi'
	String get resetLocation => 'Reset lokasi';

	/// id: 'Simpan perubahan'
	String get save => 'Simpan perubahan';
}

// Path: marketplace.detail
class TranslationsMarketplaceDetailId {
	TranslationsMarketplaceDetailId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Ajukan penawaran'
	String get makeOffer => 'Ajukan penawaran';

	/// id: 'Harga tetap'
	String get fixedPrice => 'Harga tetap';

	/// id: 'Deskripsi produk'
	String get description => 'Deskripsi produk';

	/// id: 'Info penjual'
	String get sellerInfo => 'Info penjual';

	/// id: 'Chat'
	String get chat => 'Chat';

	/// id: 'Favorit'
	String get favorite => 'Favorit';

	/// id: 'Hapus favorit'
	String get unfavorite => 'Hapus favorit';

	/// id: 'Bagikan'
	String get share => 'Bagikan';

	/// id: 'Edit'
	String get edit => 'Edit';

	/// id: 'Hapus'
	String get delete => 'Hapus';

	/// id: 'Kategori'
	String get category => 'Kategori';

	/// id: 'Kategori: -'
	String get categoryError => 'Kategori: -';

	/// id: 'Tidak ada kategori'
	String get categoryNone => 'Tidak ada kategori';

	/// id: 'Dilihat'
	String get views => 'Dilihat';

	/// id: 'Suka'
	String get likes => 'Suka';

	/// id: 'Chat'
	String get chats => 'Chat';

	/// id: 'Info penjual tidak tersedia.'
	String get noSeller => 'Info penjual tidak tersedia.';

	/// id: 'Info lokasi tidak tersedia.'
	String get noLocation => 'Info lokasi tidak tersedia.';

	/// id: 'Penjual'
	String get seller => 'Penjual';

	/// id: 'Lokasi transaksi'
	String get dealLocation => 'Lokasi transaksi';
}

// Path: marketplace.dialog
class TranslationsMarketplaceDialogId {
	TranslationsMarketplaceDialogId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Hapus postingan'
	String get deleteTitle => 'Hapus postingan';

	/// id: 'Apakah Anda yakin ingin menghapus postingan ini? Tindakan ini tidak bisa dibatalkan.'
	String get deleteContent => 'Apakah Anda yakin ingin menghapus postingan ini? Tindakan ini tidak bisa dibatalkan.';

	/// id: 'Batal'
	String get cancel => 'Batal';

	/// id: 'Hapus'
	String get deleteConfirm => 'Hapus';

	/// id: 'Postingan berhasil dihapus.'
	String get deleteSuccess => 'Postingan berhasil dihapus.';

	/// id: 'Tutup'
	String get close => 'Tutup';
}

// Path: marketplace.errors
class TranslationsMarketplaceErrorsId {
	TranslationsMarketplaceErrorsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Gagal menghapus postingan: {error}'
	String get deleteError => 'Gagal menghapus postingan: {error}';

	/// id: 'Kolom ini wajib diisi.'
	String get requiredField => 'Kolom ini wajib diisi.';

	/// id: 'Tambahkan minimal 1 foto.'
	String get noPhoto => 'Tambahkan minimal 1 foto.';

	/// id: 'Silakan pilih kategori.'
	String get noCategory => 'Silakan pilih kategori.';

	/// id: 'Login diperlukan.'
	String get loginRequired => 'Login diperlukan.';

	/// id: 'Data pengguna tidak ditemukan.'
	String get userNotFound => 'Data pengguna tidak ditemukan.';
}

// Path: marketplace.condition
class TranslationsMarketplaceConditionId {
	TranslationsMarketplaceConditionId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Kondisi'
	String get label => 'Kondisi';

	/// id: 'Baru'
	String get kNew => 'Baru';

	/// id: 'Bekas'
	String get used => 'Bekas';
}

// Path: marketplace.reservation
class TranslationsMarketplaceReservationId {
	TranslationsMarketplaceReservationId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Pembayaran deposit 10%'
	String get title => 'Pembayaran deposit 10%';

	/// id: 'Untuk memesan produk yang sudah diverifikasi AI, Anda perlu membayar deposit 10% sebesar {amount}. Jika transaksi dibatalkan setelah verifikasi di tempat, deposit akan dikembalikan.'
	String get content => 'Untuk memesan produk yang sudah diverifikasi AI, Anda perlu membayar deposit 10% sebesar {amount}. Jika transaksi dibatalkan setelah verifikasi di tempat, deposit akan dikembalikan.';

	/// id: 'Bayar & Pesan'
	String get confirm => 'Bayar & Pesan';

	/// id: 'Pesan dengan Jaminan AI'
	String get button => 'Pesan dengan Jaminan AI';

	/// id: 'Reservasi berhasil. Silakan atur janji temu dengan penjual.'
	String get success => 'Reservasi berhasil. Silakan atur janji temu dengan penjual.';
}

// Path: marketplace.status
class TranslationsMarketplaceStatusId {
	TranslationsMarketplaceStatusId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Dipesan'
	String get reserved => 'Dipesan';

	/// id: 'Terjual'
	String get sold => 'Terjual';
}

// Path: marketplace.ai
class TranslationsMarketplaceAiId {
	TranslationsMarketplaceAiId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Batalkan verifikasi AI'
	String get cancelConfirm => 'Batalkan verifikasi AI';

	/// id: 'Verifikasi AI hanya dapat dibatalkan satu kali per produk. Permintaan ulang verifikasi AI dapat dikenakan biaya.'
	String get cancelLimit => 'Verifikasi AI hanya dapat dibatalkan satu kali per produk. Permintaan ulang verifikasi AI dapat dikenakan biaya.';

	/// id: 'Saya mengerti mungkin akan dikenakan biaya.'
	String get cancelAckCharge => 'Saya mengerti mungkin akan dikenakan biaya.';

	/// id: 'Verifikasi AI telah dibatalkan. Produk ini sekarang menjadi listing biasa.'
	String get cancelSuccess => 'Verifikasi AI telah dibatalkan. Produk ini sekarang menjadi listing biasa.';

	/// id: 'Terjadi kesalahan saat membatalkan verifikasi AI: {0}'
	String get cancelError => 'Terjadi kesalahan saat membatalkan verifikasi AI: {0}';
}

// Path: marketplace.takeover
class TranslationsMarketplaceTakeoverId {
	TranslationsMarketplaceTakeoverId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Ambil & verifikasi di tempat'
	String get button => 'Ambil & verifikasi di tempat';

	/// id: 'Verifikasi AI di Lokasi'
	String get title => 'Verifikasi AI di Lokasi';

	late final TranslationsMarketplaceTakeoverGuideId guide = TranslationsMarketplaceTakeoverGuideId.internal(_root);

	/// id: 'Ambil foto di lokasi'
	String get photoTitle => 'Ambil foto di lokasi';

	/// id: 'Mulai verifikasi kesesuaian AI'
	String get buttonVerify => 'Mulai verifikasi kesesuaian AI';

	late final TranslationsMarketplaceTakeoverErrorsId errors = TranslationsMarketplaceTakeoverErrorsId.internal(_root);
	late final TranslationsMarketplaceTakeoverDialogId dialog = TranslationsMarketplaceTakeoverDialogId.internal(_root);
	late final TranslationsMarketplaceTakeoverSuccessId success = TranslationsMarketplaceTakeoverSuccessId.internal(_root);
}

// Path: aiFlow.common
class TranslationsAiFlowCommonId {
	TranslationsAiFlowCommonId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Terjadi kesalahan: {error}'
	String get error => 'Terjadi kesalahan: {error}';

	/// id: 'Tambah foto'
	String get addPhoto => 'Tambah foto';

	/// id: 'Lewati'
	String get skip => 'Lewati';

	/// id: 'Foto ditambahkan: {}'
	String get addedPhoto => 'Foto ditambahkan: {}';

	/// id: 'Dilewati'
	String get skipped => 'Dilewati';
}

// Path: aiFlow.cta
class TranslationsAiFlowCtaId {
	TranslationsAiFlowCtaId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: '🤖 Tingkatkan kepercayaan dengan verifikasi AI (opsional)'
	String get title => '🤖 Tingkatkan kepercayaan dengan verifikasi AI (opsional)';

	/// id: 'Dapatkan badge verifikasi AI untuk meningkatkan kepercayaan pembeli dan jual lebih cepat. Lengkapi semua info produk sebelum mulai.'
	String get subtitle => 'Dapatkan badge verifikasi AI untuk meningkatkan kepercayaan pembeli dan jual lebih cepat. Lengkapi semua info produk sebelum mulai.';

	/// id: 'Mulai verifikasi AI'
	String get startButton => 'Mulai verifikasi AI';

	/// id: 'Masukkan nama barang, kategori, dan minimal satu gambar terlebih dahulu.'
	String get missingRequiredFields => 'Masukkan nama barang, kategori, dan minimal satu gambar terlebih dahulu.';
}

// Path: aiFlow.categorySelection
class TranslationsAiFlowCategorySelectionId {
	TranslationsAiFlowCategorySelectionId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Verifikasi AI: Pilih kategori'
	String get title => 'Verifikasi AI: Pilih kategori';

	/// id: 'Gagal memuat kategori.'
	String get error => 'Gagal memuat kategori.';

	/// id: 'Tidak ada kategori yang tersedia untuk verifikasi.'
	String get noCategories => 'Tidak ada kategori yang tersedia untuk verifikasi.';
}

// Path: aiFlow.galleryUpload
class TranslationsAiFlowGalleryUploadId {
	TranslationsAiFlowGalleryUploadId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Verifikasi AI: Pilih foto'
	String get title => 'Verifikasi AI: Pilih foto';

	/// id: 'Unggah minimal {count} foto untuk verifikasi.'
	String get guide => 'Unggah minimal {count} foto untuk verifikasi.';

	/// id: 'Anda harus memilih minimal {count} foto.'
	String get minPhotoError => 'Anda harus memilih minimal {count} foto.';

	/// id: 'Minta analisis AI'
	String get nextButton => 'Minta analisis AI';
}

// Path: aiFlow.prediction
class TranslationsAiFlowPredictionId {
	TranslationsAiFlowPredictionId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Hasil analisis AI'
	String get title => 'Hasil analisis AI';

	/// id: 'Ini adalah nama barang yang diprediksi AI.'
	String get guide => 'Ini adalah nama barang yang diprediksi AI.';

	/// id: 'Edit nama barang'
	String get editLabel => 'Edit nama barang';

	/// id: 'Edit manual'
	String get editButton => 'Edit manual';

	/// id: 'Simpan perubahan'
	String get saveButton => 'Simpan perubahan';

	/// id: 'Tidak ada nama barang.'
	String get noName => 'Tidak ada nama barang.';

	/// id: 'Barang tidak dapat dikenali. Silakan coba lagi.'
	String get error => 'Barang tidak dapat dikenali. Silakan coba lagi.';

	/// id: 'Info autentikasi pengguna tidak ditemukan. Analisis tidak dapat dimulai.'
	String get authError => 'Info autentikasi pengguna tidak ditemukan. Analisis tidak dapat dimulai.';

	/// id: 'Apakah nama barang ini sudah benar?'
	String get question => 'Apakah nama barang ini sudah benar?';

	/// id: 'Ya, benar'
	String get confirmButton => 'Ya, benar';

	/// id: 'Tidak, kembali'
	String get rejectButton => 'Tidak, kembali';

	/// id: 'Terjadi kesalahan saat analisis.'
	String get analysisError => 'Terjadi kesalahan saat analisis.';

	/// id: 'Coba lagi'
	String get retryButton => 'Coba lagi';

	/// id: 'Kembali'
	String get backButton => 'Kembali';
}

// Path: aiFlow.guidedCamera
class TranslationsAiFlowGuidedCameraId {
	TranslationsAiFlowGuidedCameraId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Panduan AI: bukti foto yang kurang'
	String get title => 'Panduan AI: bukti foto yang kurang';

	/// id: 'Untuk meningkatkan kepercayaan, tambahkan foto sesuai saran berikut.'
	String get guide => 'Untuk meningkatkan kepercayaan, tambahkan foto sesuai saran berikut.';

	/// id: 'Lokasi foto tidak sama dengan lokasi Anda sekarang. Harap ambil foto di tempat yang sama.'
	String get locationMismatchError => 'Lokasi foto tidak sama dengan lokasi Anda sekarang. Harap ambil foto di tempat yang sama.';

	/// id: 'Izin lokasi ditolak. Aktifkan izin lokasi di pengaturan.'
	String get locationPermissionError => 'Izin lokasi ditolak. Aktifkan izin lokasi di pengaturan.';

	/// id: 'Tidak ada data lokasi di foto. Aktifkan tag lokasi di pengaturan kamera.'
	String get noLocationDataError => 'Tidak ada data lokasi di foto. Aktifkan tag lokasi di pengaturan kamera.';

	/// id: 'Buat laporan akhir'
	String get nextButton => 'Buat laporan akhir';
}

// Path: aiFlow.finalReport
class TranslationsAiFlowFinalReportId {
	TranslationsAiFlowFinalReportId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Laporan Verifikasi AI'
	String get title => 'Laporan Verifikasi AI';

	/// id: 'AI membuat draft listing. Edit konten lalu selesaikan pendaftaran.'
	String get guide => 'AI membuat draft listing. Edit konten lalu selesaikan pendaftaran.';

	/// id: 'AI sedang membuat laporan akhir...'
	String get loading => 'AI sedang membuat laporan akhir...';

	/// id: 'Gagal membuat laporan.'
	String get error => 'Gagal membuat laporan.';

	/// id: 'Laporan akhir berhasil dibuat.'
	String get success => 'Laporan akhir berhasil dibuat.';

	/// id: 'Daftarkan untuk dijual'
	String get submitButton => 'Daftarkan untuk dijual';

	/// id: 'Harga yang disarankan AI ({})'
	String get suggestedPrice => 'Harga yang disarankan AI ({})';

	/// id: 'Ringkasan verifikasi'
	String get summary => 'Ringkasan verifikasi';

	/// id: 'Catatan untuk pembeli (AI)'
	String get buyerNotes => 'Catatan untuk pembeli (AI)';

	/// id: 'Spesifikasi utama'
	String get keySpecs => 'Spesifikasi utama';

	/// id: 'Pemeriksaan kondisi'
	String get condition => 'Pemeriksaan kondisi';

	/// id: 'Barang termasuk (pisahkan dengan koma)'
	String get includedItems => 'Barang termasuk (pisahkan dengan koma)';

	/// id: 'Deskripsi akhir'
	String get finalDescription => 'Deskripsi akhir';

	/// id: 'Terapkan saran ke deskripsi'
	String get applySuggestions => 'Terapkan saran ke deskripsi';

	/// id: 'Barang termasuk'
	String get includedItemsLabel => 'Barang termasuk';

	/// id: 'Catatan pembeli'
	String get buyerNotesLabel => 'Catatan pembeli';

	/// id: 'Item bukti yang dilewati'
	String get skippedItems => 'Item bukti yang dilewati';

	/// id: 'Gagal membuat laporan akhir: {error}'
	String get fail => 'Gagal membuat laporan akhir: {error}';
}

// Path: aiFlow.evidence
class TranslationsAiFlowEvidenceId {
	TranslationsAiFlowEvidenceId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Semua foto yang disarankan wajib diunggah.'
	String get allShotsRequired => 'Semua foto yang disarankan wajib diunggah.';

	/// id: 'Foto bukti'
	String get title => 'Foto bukti';

	/// id: 'Kirim bukti'
	String get submitButton => 'Kirim bukti';
}

// Path: aiFlow.error
class TranslationsAiFlowErrorId {
	TranslationsAiFlowErrorId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Gagal membuat laporan AI: {error}'
	String get reportGeneration => 'Gagal membuat laporan AI: {error}';
}

// Path: myBling.stats
class TranslationsMyBlingStatsId {
	TranslationsMyBlingStatsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Postingan'
	String get posts => 'Postingan';

	/// id: 'Pengikut'
	String get followers => 'Pengikut';

	/// id: 'Tetangga'
	String get neighbors => 'Tetangga';

	/// id: 'Teman'
	String get friends => 'Teman';
}

// Path: myBling.tabs
class TranslationsMyBlingTabsId {
	TranslationsMyBlingTabsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Postingan saya'
	String get posts => 'Postingan saya';

	/// id: 'Produk saya'
	String get products => 'Produk saya';

	/// id: 'Bookmark'
	String get bookmarks => 'Bookmark';

	/// id: 'Teman'
	String get friends => 'Teman';
}

// Path: profileView.tabs
class TranslationsProfileViewTabsId {
	TranslationsProfileViewTabsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Postingan'
	String get posts => 'Postingan';

	/// id: 'Minat'
	String get interests => 'Minat';
}

// Path: settings.notifications
class TranslationsSettingsNotificationsId {
	TranslationsSettingsNotificationsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Gagal memuat pengaturan notifikasi.'
	String get loadError => 'Gagal memuat pengaturan notifikasi.';

	/// id: 'Pengaturan notifikasi berhasil disimpan.'
	String get saveSuccess => 'Pengaturan notifikasi berhasil disimpan.';

	/// id: 'Gagal menyimpan pengaturan notifikasi.'
	String get saveError => 'Gagal menyimpan pengaturan notifikasi.';

	/// id: 'Jangkauan notifikasi'
	String get scopeTitle => 'Jangkauan notifikasi';

	/// id: 'Pilih seberapa luas notifikasi yang ingin diterima (hanya lingkungan saya, area sekitar, dll.).'
	String get scopeDescription => 'Pilih seberapa luas notifikasi yang ingin diterima (hanya lingkungan saya, area sekitar, dll.).';

	/// id: 'Jangkauan notifikasi'
	String get scopeLabel => 'Jangkauan notifikasi';

	/// id: 'Topik notifikasi'
	String get tagsTitle => 'Topik notifikasi';

	/// id: 'Pilih topik apa saja yang ingin Anda terima (berita, kerja, marketplace, dll.).'
	String get tagsDescription => 'Pilih topik apa saja yang ingin Anda terima (berita, kerja, marketplace, dll.).';
}

// Path: friendRequests.tooltip
class TranslationsFriendRequestsTooltipId {
	TranslationsFriendRequestsTooltipId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Terima'
	String get accept => 'Terima';

	/// id: 'Tolak'
	String get reject => 'Tolak';
}

// Path: sentFriendRequests.status
class TranslationsSentFriendRequestsStatusId {
	TranslationsSentFriendRequestsStatusId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Menunggu'
	String get pending => 'Menunggu';

	/// id: 'Diterima'
	String get accepted => 'Diterima';

	/// id: 'Ditolak'
	String get rejected => 'Ditolak';
}

// Path: blockedUsers.unblockDialog
class TranslationsBlockedUsersUnblockDialogId {
	TranslationsBlockedUsersUnblockDialogId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Buka blokir {nickname}?'
	String get title => 'Buka blokir {nickname}?';

	/// id: 'Setelah dibuka blokirnya, pengguna ini bisa muncul lagi di daftar Find Friends Anda.'
	String get content => 'Setelah dibuka blokirnya, pengguna ini bisa muncul lagi di daftar Find Friends Anda.';
}

// Path: rejectedUsers.unrejectDialog
class TranslationsRejectedUsersUnrejectDialogId {
	TranslationsRejectedUsersUnrejectDialogId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Batalkan penolakan untuk {nickname}?'
	String get title => 'Batalkan penolakan untuk {nickname}?';

	/// id: 'Jika dibatalkan, Anda bisa muncul lagi di daftar Find Friends mereka.'
	String get content => 'Jika dibatalkan, Anda bisa muncul lagi di daftar Find Friends mereka.';
}

// Path: profileEdit.interests
class TranslationsProfileEditInterestsId {
	TranslationsProfileEditInterestsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Minat'
	String get title => 'Minat';

	/// id: 'Gunakan koma dan Enter untuk menambahkan beberapa item'
	String get hint => 'Gunakan koma dan Enter untuk menambahkan beberapa item';
}

// Path: profileEdit.privacy
class TranslationsProfileEditPrivacyId {
	TranslationsProfileEditPrivacyId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Pengaturan privasi'
	String get title => 'Pengaturan privasi';

	/// id: 'Tampilkan lokasi saya di peta'
	String get showLocation => 'Tampilkan lokasi saya di peta';

	/// id: 'Izinkan permintaan pertemanan'
	String get allowRequests => 'Izinkan permintaan pertemanan';
}

// Path: profileEdit.errors
class TranslationsProfileEditErrorsId {
	TranslationsProfileEditErrorsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Tidak ada pengguna yang login.'
	String get noUser => 'Tidak ada pengguna yang login.';

	/// id: 'Gagal memperbarui profil: {error}'
	String get updateFailed => 'Gagal memperbarui profil: {error}';
}

// Path: categories.post
class TranslationsCategoriesPostId {
	TranslationsCategoriesPostId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsCategoriesPostJalanPerbaikinId jalanPerbaikin = TranslationsCategoriesPostJalanPerbaikinId.internal(_root);
	late final TranslationsCategoriesPostDailyLifeId dailyLife = TranslationsCategoriesPostDailyLifeId.internal(_root);
	late final TranslationsCategoriesPostHelpShareId helpShare = TranslationsCategoriesPostHelpShareId.internal(_root);
	late final TranslationsCategoriesPostIncidentReportId incidentReport = TranslationsCategoriesPostIncidentReportId.internal(_root);
	late final TranslationsCategoriesPostLocalNewsId localNews = TranslationsCategoriesPostLocalNewsId.internal(_root);
	late final TranslationsCategoriesPostNovemberId november = TranslationsCategoriesPostNovemberId.internal(_root);
	late final TranslationsCategoriesPostRainId rain = TranslationsCategoriesPostRainId.internal(_root);
	late final TranslationsCategoriesPostDailyQuestionId dailyQuestion = TranslationsCategoriesPostDailyQuestionId.internal(_root);
	late final TranslationsCategoriesPostStorePromoId storePromo = TranslationsCategoriesPostStorePromoId.internal(_root);
	late final TranslationsCategoriesPostEtcId etc = TranslationsCategoriesPostEtcId.internal(_root);
}

// Path: categories.auction
class TranslationsCategoriesAuctionId {
	TranslationsCategoriesAuctionId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Semua'
	String get all => 'Semua';

	late final TranslationsCategoriesAuctionCollectiblesId collectibles = TranslationsCategoriesAuctionCollectiblesId.internal(_root);
	late final TranslationsCategoriesAuctionDigitalId digital = TranslationsCategoriesAuctionDigitalId.internal(_root);
	late final TranslationsCategoriesAuctionFashionId fashion = TranslationsCategoriesAuctionFashionId.internal(_root);
	late final TranslationsCategoriesAuctionVintageId vintage = TranslationsCategoriesAuctionVintageId.internal(_root);
	late final TranslationsCategoriesAuctionArtCraftId artCraft = TranslationsCategoriesAuctionArtCraftId.internal(_root);
	late final TranslationsCategoriesAuctionEtcId etc = TranslationsCategoriesAuctionEtcId.internal(_root);
}

// Path: localNewsCreate.form
class TranslationsLocalNewsCreateFormId {
	TranslationsLocalNewsCreateFormId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Kategori'
	String get categoryLabel => 'Kategori';

	/// id: 'Judul'
	String get titleLabel => 'Judul';

	/// id: 'Tulis konten'
	String get contentLabel => 'Tulis konten';

	/// id: 'Tag'
	String get tagsLabel => 'Tag';

	/// id: 'Tambahkan tag (tekan spasi untuk konfirmasi)'
	String get tagsHint => 'Tambahkan tag (tekan spasi untuk konfirmasi)';

	/// id: 'Tag yang disarankan'
	String get recommendedTags => 'Tag yang disarankan';
}

// Path: localNewsCreate.labels
class TranslationsLocalNewsCreateLabelsId {
	TranslationsLocalNewsCreateLabelsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Judul'
	String get title => 'Judul';

	/// id: 'Konten'
	String get body => 'Konten';

	/// id: 'Tag'
	String get tags => 'Tag';

	/// id: 'Info tambahan (opsional)'
	String get guidedTitle => 'Info tambahan (opsional)';

	/// id: 'Lokasi acara/kejadian'
	String get eventLocation => 'Lokasi acara/kejadian';
}

// Path: localNewsCreate.hints
class TranslationsLocalNewsCreateHintsId {
	TranslationsLocalNewsCreateHintsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Bagikan berita lingkungan atau ajukan pertanyaan ke tetangga...'
	String get body => 'Bagikan berita lingkungan atau ajukan pertanyaan ke tetangga...';

	/// id: '(Pilih 1–3 tag)'
	String get tagSelection => '(Pilih 1–3 tag)';

	/// id: 'mis. Jl. Sudirman 123'
	String get eventLocation => 'mis. Jl. Sudirman 123';
}

// Path: localNewsCreate.validation
class TranslationsLocalNewsCreateValidationId {
	TranslationsLocalNewsCreateValidationId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Silakan isi konten.'
	String get bodyRequired => 'Silakan isi konten.';

	/// id: 'Silakan pilih minimal satu tag.'
	String get tagRequired => 'Silakan pilih minimal satu tag.';

	/// id: 'Anda bisa memilih maksimal 3 tag.'
	String get tagMaxLimit => 'Anda bisa memilih maksimal 3 tag.';

	/// id: 'Anda bisa melampirkan maksimal 5 gambar.'
	String get imageMaxLimit => 'Anda bisa melampirkan maksimal 5 gambar.';

	/// id: 'Silakan masukkan judul.'
	String get titleRequired => 'Silakan masukkan judul.';
}

// Path: localNewsCreate.buttons
class TranslationsLocalNewsCreateButtonsId {
	TranslationsLocalNewsCreateButtonsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Tambah gambar'
	String get addImage => 'Tambah gambar';

	/// id: 'Kirim'
	String get submit => 'Kirim';
}

// Path: localNewsCreate.alerts
class TranslationsLocalNewsCreateAlertsId {
	TranslationsLocalNewsCreateAlertsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Silakan isi konten.'
	String get contentRequired => 'Silakan isi konten.';

	/// id: 'Silakan pilih kategori.'
	String get categoryRequired => 'Silakan pilih kategori.';

	/// id: 'Postingan berhasil dibuat.'
	String get success => 'Postingan berhasil dibuat.';

	/// id: 'Gagal mengunggah: {error}'
	String get failure => 'Gagal mengunggah: {error}';

	/// id: 'Anda harus login untuk membuat postingan.'
	String get loginRequired => 'Anda harus login untuk membuat postingan.';

	/// id: 'Info pengguna tidak ditemukan.'
	String get userNotFound => 'Info pengguna tidak ditemukan.';
}

// Path: localNewsDetail.menu
class TranslationsLocalNewsDetailMenuId {
	TranslationsLocalNewsDetailMenuId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Edit'
	String get edit => 'Edit';

	/// id: 'Laporkan'
	String get report => 'Laporkan';

	/// id: 'Bagikan'
	String get share => 'Bagikan';
}

// Path: localNewsDetail.stats
class TranslationsLocalNewsDetailStatsId {
	TranslationsLocalNewsDetailStatsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Dilihat'
	String get views => 'Dilihat';

	/// id: 'Komentar'
	String get comments => 'Komentar';

	/// id: 'Suka'
	String get likes => 'Suka';

	/// id: 'Terima kasih'
	String get thanks => 'Terima kasih';
}

// Path: localNewsDetail.buttons
class TranslationsLocalNewsDetailButtonsId {
	TranslationsLocalNewsDetailButtonsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Tambah komentar'
	String get comment => 'Tambah komentar';
}

// Path: localNewsEdit.buttons
class TranslationsLocalNewsEditButtonsId {
	TranslationsLocalNewsEditButtonsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Perbarui'
	String get submit => 'Perbarui';
}

// Path: localNewsEdit.alerts
class TranslationsLocalNewsEditAlertsId {
	TranslationsLocalNewsEditAlertsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Postingan berhasil diperbarui.'
	String get success => 'Postingan berhasil diperbarui.';

	/// id: 'Gagal memperbarui: {error}'
	String get failure => 'Gagal memperbarui: {error}';
}

// Path: commentInputField.button
class TranslationsCommentInputFieldButtonId {
	TranslationsCommentInputFieldButtonId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Kirim'
	String get send => 'Kirim';
}

// Path: common.sort
class TranslationsCommonSortId {
	TranslationsCommonSortId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Default'
	String get kDefault => 'Default';

	/// id: 'Jarak'
	String get distance => 'Jarak';

	/// id: 'Populer'
	String get popular => 'Populer';
}

// Path: replyInputField.button
class TranslationsReplyInputFieldButtonId {
	TranslationsReplyInputFieldButtonId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Kirim'
	String get send => 'Kirim';
}

// Path: jobs.screen
class TranslationsJobsScreenId {
	TranslationsJobsScreenId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Belum ada lowongan kerja di area ini.'
	String get empty => 'Belum ada lowongan kerja di area ini.';

	/// id: 'Pasang lowongan'
	String get createTooltip => 'Pasang lowongan';
}

// Path: jobs.tabs
class TranslationsJobsTabsId {
	TranslationsJobsTabsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Semua'
	String get all => 'Semua';

	/// id: 'Gig singkat'
	String get quickGig => 'Gig singkat';

	/// id: 'Paruh waktu/Penuh waktu'
	String get regular => 'Paruh waktu/Penuh waktu';
}

// Path: jobs.selectType
class TranslationsJobsSelectTypeId {
	TranslationsJobsSelectTypeId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Pilih jenis lowongan'
	String get title => 'Pilih jenis lowongan';

	/// id: 'Lowongan paruh waktu / penuh waktu'
	String get regularTitle => 'Lowongan paruh waktu / penuh waktu';

	/// id: 'Pekerjaan reguler seperti kafe, restoran, kantor'
	String get regularDesc => 'Pekerjaan reguler seperti kafe, restoran, kantor';

	/// id: 'Gig singkat / bantuan sederhana'
	String get quickGigTitle => 'Gig singkat / bantuan sederhana';

	/// id: 'Antar dokumen, pindahan, bersih-bersih, dan lain-lain'
	String get quickGigDesc => 'Antar dokumen, pindahan, bersih-bersih, dan lain-lain';
}

// Path: jobs.form
class TranslationsJobsFormId {
	TranslationsJobsFormId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Pasang lowongan kerja'
	String get title => 'Pasang lowongan kerja';

	/// id: 'Judul lowongan'
	String get titleHint => 'Judul lowongan';

	/// id: 'Jelaskan posisi yang dicari'
	String get descriptionPositionHint => 'Jelaskan posisi yang dicari';

	/// id: 'Kategori'
	String get categoryHint => 'Kategori';

	/// id: 'Pilih kategori'
	String get categorySelectHint => 'Pilih kategori';

	/// id: 'Silakan pilih kategori.'
	String get categoryValidator => 'Silakan pilih kategori.';

	/// id: 'Lokasi kerja'
	String get locationHint => 'Lokasi kerja';

	/// id: 'Pasang lowongan'
	String get submit => 'Pasang lowongan';

	/// id: 'Judul'
	String get titleLabel => 'Judul';

	/// id: 'Silakan masukkan judul.'
	String get titleValidator => 'Silakan masukkan judul.';

	/// id: 'Pasang lowongan paruh waktu/penuh waktu'
	String get titleRegular => 'Pasang lowongan paruh waktu/penuh waktu';

	/// id: 'Pasang gig singkat'
	String get titleQuickGig => 'Pasang gig singkat';

	/// id: 'Silakan isi semua kolom wajib.'
	String get validationError => 'Silakan isi semua kolom wajib.';

	/// id: 'Lowongan kerja berhasil disimpan.'
	String get saveSuccess => 'Lowongan kerja berhasil disimpan.';

	/// id: 'Gagal menyimpan lowongan kerja: {error}'
	String get saveError => 'Gagal menyimpan lowongan kerja: {error}';

	/// id: 'Kategori'
	String get categoryLabel => 'Kategori';

	/// id: 'mis. Antar dokumen pakai motor (ASAP)'
	String get titleHintQuickGig => 'mis. Antar dokumen pakai motor (ASAP)';

	/// id: 'Gaji (IDR)'
	String get salaryLabel => 'Gaji (IDR)';

	/// id: 'Masukkan jumlah gaji'
	String get salaryHint => 'Masukkan jumlah gaji';

	/// id: 'Silakan masukkan jumlah gaji yang valid.'
	String get salaryValidator => 'Silakan masukkan jumlah gaji yang valid.';

	/// id: 'Total bayaran (IDR)'
	String get totalPayLabel => 'Total bayaran (IDR)';

	/// id: 'Masukkan total bayaran yang ditawarkan'
	String get totalPayHint => 'Masukkan total bayaran yang ditawarkan';

	/// id: 'Silakan masukkan jumlah yang valid.'
	String get totalPayValidator => 'Silakan masukkan jumlah yang valid.';

	/// id: 'Bisa nego'
	String get negotiable => 'Bisa nego';

	/// id: 'Periode kerja'
	String get workPeriodLabel => 'Periode kerja';

	/// id: 'Pilih periode kerja'
	String get workPeriodHint => 'Pilih periode kerja';

	/// id: 'Lokasi / tempat kerja'
	String get locationLabel => 'Lokasi / tempat kerja';

	/// id: 'Silakan masukkan lokasi.'
	String get locationValidator => 'Silakan masukkan lokasi.';

	/// id: 'Gambar (Opsional, maks 10)'
	String get imageLabel => 'Gambar (Opsional, maks 10)';

	/// id: 'Tulis detailnya (mis. titik jemput, tujuan, permintaan khusus).'
	String get descriptionHintQuickGig => 'Tulis detailnya (mis. titik jemput, tujuan, permintaan khusus).';

	/// id: 'Info gaji'
	String get salaryInfoTitle => 'Info gaji';

	/// id: 'Jenis pembayaran'
	String get salaryTypeHint => 'Jenis pembayaran';

	/// id: 'Nominal (IDR)'
	String get salaryAmountLabel => 'Nominal (IDR)';

	/// id: 'Gaji bisa dinegosiasikan'
	String get salaryNegotiable => 'Gaji bisa dinegosiasikan';

	/// id: 'Syarat kerja'
	String get workInfoTitle => 'Syarat kerja';

	/// id: 'Periode kerja'
	String get workPeriodTitle => 'Periode kerja';

	/// id: 'Hari/Jam kerja'
	String get workHoursLabel => 'Hari/Jam kerja';

	/// id: 'mis. Senin–Jumat, 09.00–18.00'
	String get workHoursHint => 'mis. Senin–Jumat, 09.00–18.00';

	/// id: 'Lampirkan foto (opsional, maks 5)'
	String get imageSectionTitle => 'Lampirkan foto (opsional, maks 5)';

	/// id: 'Deskripsi'
	String get descriptionLabel => 'Deskripsi';

	/// id: 'mis. Part-time 3 hari seminggu, jam 5–10 sore. Gaji bisa nego.'
	String get descriptionHint => 'mis. Part-time 3 hari seminggu, jam 5–10 sore. Gaji bisa nego.';

	/// id: 'Silakan masukkan deskripsi.'
	String get descriptionValidator => 'Silakan masukkan deskripsi.';

	/// id: 'Lowongan kerja berhasil dipasang.'
	String get submitSuccess => 'Lowongan kerja berhasil dipasang.';

	/// id: 'Gagal memasang lowongan kerja: {error}'
	String get submitFail => 'Gagal memasang lowongan kerja: {error}';

	/// id: 'Lowongan berhasil diperbarui.'
	String get updateSuccess => 'Lowongan berhasil diperbarui.';

	/// id: 'Edit Lowongan'
	String get editTitle => 'Edit Lowongan';

	/// id: 'Perbarui'
	String get update => 'Perbarui';
}

// Path: jobs.categories
class TranslationsJobsCategoriesId {
	TranslationsJobsCategoriesId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Restoran'
	String get restaurant => 'Restoran';

	/// id: 'Kafe'
	String get cafe => 'Kafe';

	/// id: 'Ritel/Toko'
	String get retail => 'Ritel/Toko';

	/// id: 'Kurir/Antar'
	String get delivery => 'Kurir/Antar';

	/// id: 'Lainnya'
	String get etc => 'Lainnya';

	/// id: 'Jasa/Service'
	String get service => 'Jasa/Service';

	/// id: 'Sales/Marketing'
	String get salesMarketing => 'Sales/Marketing';

	/// id: 'Pengiriman/Logistik'
	String get deliveryLogistics => 'Pengiriman/Logistik';

	/// id: 'IT/Teknologi'
	String get it => 'IT/Teknologi';

	/// id: 'Desain'
	String get design => 'Desain';

	/// id: 'Pendidikan'
	String get education => 'Pendidikan';

	/// id: 'Antar barang pakai motor'
	String get quickGigDelivery => 'Antar barang pakai motor';

	/// id: 'Antar orang pakai motor (ojek)'
	String get quickGigTransport => 'Antar orang pakai motor (ojek)';

	/// id: 'Bantu pindahan'
	String get quickGigMoving => 'Bantu pindahan';

	/// id: 'Bersih-bersih/Rumah tangga'
	String get quickGigCleaning => 'Bersih-bersih/Rumah tangga';

	/// id: 'Antri menggantikan'
	String get quickGigQueuing => 'Antri menggantikan';

	/// id: 'Jasa titip/bantuan lainnya'
	String get quickGigEtc => 'Jasa titip/bantuan lainnya';
}

// Path: jobs.salaryTypes
class TranslationsJobsSalaryTypesId {
	TranslationsJobsSalaryTypesId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Per jam'
	String get hourly => 'Per jam';

	/// id: 'Harian'
	String get daily => 'Harian';

	/// id: 'Mingguan'
	String get weekly => 'Mingguan';

	/// id: 'Bulanan'
	String get monthly => 'Bulanan';

	/// id: 'Total'
	String get total => 'Total';

	/// id: 'Per kasus'
	String get perCase => 'Per kasus';

	/// id: 'Lainnya'
	String get etc => 'Lainnya';

	/// id: 'Tahunan'
	String get yearly => 'Tahunan';
}

// Path: jobs.workPeriods
class TranslationsJobsWorkPeriodsId {
	TranslationsJobsWorkPeriodsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Jangka pendek'
	String get shortTerm => 'Jangka pendek';

	/// id: 'Jangka menengah'
	String get midTerm => 'Jangka menengah';

	/// id: 'Jangka panjang'
	String get longTerm => 'Jangka panjang';

	/// id: 'Satu kali'
	String get oneTime => 'Satu kali';

	/// id: '1 minggu'
	String get k1Week => '1 minggu';

	/// id: '1 bulan'
	String get k1Month => '1 bulan';

	/// id: '3 bulan'
	String get k3Months => '3 bulan';

	/// id: '6 bulan ke atas'
	String get k6MonthsPlus => '6 bulan ke atas';

	/// id: 'Bisa dinegosiasikan'
	String get negotiable => 'Bisa dinegosiasikan';

	/// id: 'Lainnya'
	String get etc => 'Lainnya';
}

// Path: jobs.detail
class TranslationsJobsDetailId {
	TranslationsJobsDetailId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Detail'
	String get infoTitle => 'Detail';

	/// id: 'Lamar'
	String get apply => 'Lamar';

	/// id: 'Info pembuat tidak tersedia'
	String get noAuthor => 'Info pembuat tidak tersedia';

	/// id: 'Tidak dapat memulai chat: {error}'
	String get chatError => 'Tidak dapat memulai chat: {error}';
}

// Path: jobs.card
class TranslationsJobsCardId {
	TranslationsJobsCardId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Lokasi tidak tersedia'
	String get noLocation => 'Lokasi tidak tersedia';

	/// id: 'menit lalu'
	String get minutesAgo => 'menit lalu';
}

// Path: boards.popup
class TranslationsBoardsPopupId {
	TranslationsBoardsPopupId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Papan lingkungan belum aktif'
	String get inactiveTitle => 'Papan lingkungan belum aktif';

	/// id: 'Untuk mengaktifkan papan lingkungan Anda, buat dulu satu posting Berita Lokal. Jika tetangga mulai ikut serta, papan akan terbuka otomatis.'
	String get inactiveBody => 'Untuk mengaktifkan papan lingkungan Anda, buat dulu satu posting Berita Lokal. Jika tetangga mulai ikut serta, papan akan terbuka otomatis.';

	/// id: 'Tulis Berita Lokal'
	String get writePost => 'Tulis Berita Lokal';
}

// Path: signup.alerts
class TranslationsSignupAlertsId {
	TranslationsSignupAlertsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Pendaftaran berhasil! Silakan login.'
	String get signupSuccessLoginNotice => 'Pendaftaran berhasil! Silakan login.';
}

// Path: signup.buttons
class TranslationsSignupButtonsId {
	TranslationsSignupButtonsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Daftar'
	String get signup => 'Daftar';
}

// Path: findFriend.tabs
class TranslationsFindFriendTabsId {
	TranslationsFindFriendTabsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Friends'
	String get friends => 'Friends';

	/// id: 'Groups'
	String get groups => 'Groups';

	/// id: 'Clubs'
	String get clubs => 'Clubs';
}

// Path: interests.items
class TranslationsInterestsItemsId {
	TranslationsInterestsItemsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Drawing'
	String get drawing => 'Drawing';

	/// id: 'Playing instruments'
	String get instrument => 'Playing instruments';

	/// id: 'Photography'
	String get photography => 'Photography';

	/// id: 'Writing'
	String get writing => 'Writing';

	/// id: 'Crafting'
	String get crafting => 'Crafting';

	/// id: 'Gardening'
	String get gardening => 'Gardening';

	/// id: 'Soccer/Futsal'
	String get soccer => 'Soccer/Futsal';

	/// id: 'Hiking'
	String get hiking => 'Hiking';

	/// id: 'Camping'
	String get camping => 'Camping';

	/// id: 'Running/Jogging'
	String get running => 'Running/Jogging';

	/// id: 'Cycling'
	String get biking => 'Cycling';

	/// id: 'Golf'
	String get golf => 'Golf';

	/// id: 'Workout/Fitness'
	String get workout => 'Workout/Fitness';

	/// id: 'Foodie'
	String get foodie => 'Foodie';

	/// id: 'Cooking'
	String get cooking => 'Cooking';

	/// id: 'Baking'
	String get baking => 'Baking';

	/// id: 'Coffee'
	String get coffee => 'Coffee';

	/// id: 'Wine/Drinks'
	String get wine => 'Wine/Drinks';

	/// id: 'Tea'
	String get tea => 'Tea';

	/// id: 'Movies/Drama'
	String get movies => 'Movies/Drama';

	/// id: 'Listening to music'
	String get music => 'Listening to music';

	/// id: 'Concerts/Festivals'
	String get concerts => 'Concerts/Festivals';

	/// id: 'Gaming'
	String get gaming => 'Gaming';

	/// id: 'Reading'
	String get reading => 'Reading';

	/// id: 'Investing'
	String get investing => 'Investing';

	/// id: 'Language learning'
	String get language => 'Language learning';

	/// id: 'Coding'
	String get coding => 'Coding';

	/// id: 'Travel'
	String get travel => 'Travel';

	/// id: 'Pets'
	String get pets => 'Pets';

	/// id: 'Volunteering'
	String get volunteering => 'Volunteering';

	/// id: 'Minimalism'
	String get minimalism => 'Minimalism';
}

// Path: clubs.tabs
class TranslationsClubsTabsId {
	TranslationsClubsTabsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Proposals'
	String get proposals => 'Proposals';

	/// id: 'Active Clubs'
	String get activeClubs => 'Active Clubs';

	/// id: 'My Clubs'
	String get myClubs => 'My Clubs';

	/// id: 'Explore Clubs'
	String get exploreClubs => 'Explore Clubs';
}

// Path: clubs.sections
class TranslationsClubsSectionsId {
	TranslationsClubsSectionsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Official clubs'
	String get active => 'Official clubs';

	/// id: 'Club proposals'
	String get proposals => 'Club proposals';
}

// Path: clubs.screen
class TranslationsClubsScreenId {
	TranslationsClubsScreenId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Error: {error}'
	String get error => 'Error: {error}';

	/// id: 'No clubs yet.'
	String get empty => 'No clubs yet.';
}

// Path: clubs.postList
class TranslationsClubsPostListId {
	TranslationsClubsPostListId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'No posts yet. Be the first!'
	String get empty => 'No posts yet. Be the first!';

	/// id: 'Write'
	String get writeTooltip => 'Write';
}

// Path: clubs.memberCard
class TranslationsClubsMemberCardId {
	TranslationsClubsMemberCardId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Remove {memberName}?'
	String get kickConfirmTitle => 'Remove {memberName}?';

	/// id: 'Removed members can no longer participate in club activities.'
	String get kickConfirmContent => 'Removed members can no longer participate in club activities.';

	/// id: 'Remove'
	String get kick => 'Remove';

	/// id: 'Removed {memberName}.'
	String get kickedSuccess => 'Removed {memberName}.';

	/// id: 'Failed to remove member: {error}'
	String get kickFail => 'Failed to remove member: {error}';
}

// Path: clubs.postCard
class TranslationsClubsPostCardId {
	TranslationsClubsPostCardId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Delete Post'
	String get deleteTitle => 'Delete Post';

	/// id: 'Are you sure you want to delete this post? This action cannot be undone.'
	String get deleteContent => 'Are you sure you want to delete this post? This action cannot be undone.';

	/// id: 'Post deleted.'
	String get deleteSuccess => 'Post deleted.';

	/// id: 'Failed to delete post: {error}'
	String get deleteFail => 'Failed to delete post: {error}';

	/// id: 'Member left'
	String get withdrawnMember => 'Member left';

	/// id: 'Delete post'
	String get deleteTooltip => 'Delete post';

	/// id: 'Loading user info...'
	String get loadingUser => 'Loading user info...';
}

// Path: clubs.card
class TranslationsClubsCardId {
	TranslationsClubsCardId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: '{count} members'
	String get membersCount => '{count} members';
}

// Path: clubs.postDetail
class TranslationsClubsPostDetailId {
	TranslationsClubsPostDetailId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Failed to add comment: {error}'
	String get commentFail => 'Failed to add comment: {error}';

	/// id: '{title} Board'
	String get appBarTitle => '{title} Board';

	/// id: 'Comments'
	String get commentsTitle => 'Comments';

	/// id: 'No comments yet.'
	String get noComments => 'No comments yet.';

	/// id: 'Write a comment...'
	String get commentHint => 'Write a comment...';

	/// id: 'Unknown user'
	String get unknownUser => 'Unknown user';
}

// Path: clubs.detail
class TranslationsClubsDetailId {
	TranslationsClubsDetailId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Joined club '{title}'!'
	String get joined => 'Joined club \'{title}\'!';

	/// id: 'Waiting for owner approval. You can participate after approval.'
	String get pendingApproval => 'Waiting for owner approval. You can participate after approval.';

	/// id: 'Failed to request join: {error}'
	String get joinFail => 'Failed to request join: {error}';

	late final TranslationsClubsDetailTabsId tabs = TranslationsClubsDetailTabsId.internal(_root);

	/// id: 'Join chat'
	String get joinChat => 'Join chat';

	/// id: 'Join Club'
	String get joinClub => 'Join Club';

	/// id: 'Admin'
	String get owner => 'Admin';

	late final TranslationsClubsDetailInfoId info = TranslationsClubsDetailInfoId.internal(_root);

	/// id: 'Location'
	String get location => 'Location';

	/// id: 'Leave club'
	String get leaveConfirmTitle => 'Leave club';

	/// id: 'Are you sure you want to leave {title}?'
	String get leaveConfirmContent => 'Are you sure you want to leave {title}?';

	/// id: 'Leave'
	String get leave => 'Leave';

	/// id: 'You have left {title}'
	String get leaveSuccess => 'You have left {title}';

	/// id: 'Failed to leave: {error}'
	String get leaveFail => 'Failed to leave: {error}';
}

// Path: clubs.memberList
class TranslationsClubsMemberListId {
	TranslationsClubsMemberListId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Pending Members'
	String get pendingMembers => 'Pending Members';

	/// id: 'All Members'
	String get allMembers => 'All Members';
}

// Path: clubs.createPost
class TranslationsClubsCreatePostId {
	TranslationsClubsCreatePostId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'New Post'
	String get title => 'New Post';

	/// id: 'Submit'
	String get submit => 'Submit';

	/// id: 'Post submitted.'
	String get success => 'Post submitted.';

	/// id: 'Failed to submit post: {error}'
	String get fail => 'Failed to submit post: {error}';

	/// id: 'Enter content...'
	String get bodyHint => 'Enter content...';
}

// Path: clubs.createClub
class TranslationsClubsCreateClubId {
	TranslationsClubsCreateClubId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Select at least one interest.'
	String get selectAtLeastOneInterest => 'Select at least one interest.';

	/// id: 'Club created!'
	String get success => 'Club created!';

	/// id: 'Failed to create club: {error}'
	String get fail => 'Failed to create club: {error}';

	/// id: 'Create Club'
	String get title => 'Create Club';

	/// id: 'Club Name'
	String get nameLabel => 'Club Name';

	/// id: 'Please enter a club name.'
	String get nameError => 'Please enter a club name.';

	/// id: 'Club Description'
	String get descriptionLabel => 'Club Description';

	/// id: 'Please enter a club description.'
	String get descriptionError => 'Please enter a club description.';

	/// id: 'Type a tag and press Space to add'
	String get tagsHint => 'Type a tag and press Space to add';

	/// id: 'You can select up to 3 interests.'
	String get maxInterests => 'You can select up to 3 interests.';

	/// id: 'Private Club'
	String get privateClub => 'Private Club';

	/// id: 'Invitation only.'
	String get privateDescription => 'Invitation only.';

	/// id: 'Location'
	String get locationLabel => 'Location';
}

// Path: clubs.editClub
class TranslationsClubsEditClubId {
	TranslationsClubsEditClubId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Edit Club Info'
	String get title => 'Edit Club Info';

	/// id: 'Save'
	String get save => 'Save';

	/// id: 'Club info updated.'
	String get success => 'Club info updated.';

	/// id: 'Failed to update club: {error}'
	String get fail => 'Failed to update club: {error}';
}

// Path: clubs.create
class TranslationsClubsCreateId {
	TranslationsClubsCreateId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Create Club'
	String get title => 'Create Club';
}

// Path: clubs.repository
class TranslationsClubsRepositoryId {
	TranslationsClubsRepositoryId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Club chat room created.'
	String get chatCreated => 'Club chat room created.';
}

// Path: clubs.proposal
class TranslationsClubsProposalId {
	TranslationsClubsProposalId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Propose a Club'
	String get createTitle => 'Propose a Club';

	/// id: 'Please select a cover image.'
	String get imageError => 'Please select a cover image.';

	/// id: 'Your club proposal has been created.'
	String get createSuccess => 'Your club proposal has been created.';

	/// id: 'Failed to create proposal: {error}'
	String get createFail => 'Failed to create proposal: {error}';

	/// id: 'Type a tag and press Space to add'
	String get tagsHint => 'Type a tag and press Space to add';

	/// id: 'Target members'
	String get targetMembers => 'Target members';

	/// id: 'Total {count} members'
	String get targetMembersCount => 'Total {count} members';

	/// id: 'No proposals yet.'
	String get empty => 'No proposals yet.';

	/// id: '{current} / {target} members'
	String get memberStatus => '{current} / {target} members';

	/// id: 'Join'
	String get join => 'Join';

	/// id: 'Leave'
	String get leave => 'Leave';

	/// id: 'Members'
	String get members => 'Members';

	/// id: 'No members yet.'
	String get noMembers => 'No members yet.';

	late final TranslationsClubsProposalDetailId detail = TranslationsClubsProposalDetailId.internal(_root);
}

// Path: findfriend.form
class TranslationsFindfriendFormId {
	TranslationsFindfriendFormId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Create Find Friends Profile'
	String get title => 'Create Find Friends Profile';
}

// Path: auctions.card
class TranslationsAuctionsCardId {
	TranslationsAuctionsCardId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Current bid'
	String get currentBid => 'Current bid';

	/// id: 'Time left'
	String get endTime => 'Time left';

	/// id: 'Ended'
	String get ended => 'Ended';

	/// id: 'Winning bid'
	String get winningBid => 'Winning bid';

	/// id: 'Winner'
	String get winner => 'Winner';

	/// id: 'No bidders yet'
	String get noBidders => 'No bidders yet';

	/// id: 'Unknown bidder'
	String get unknownBidder => 'Unknown bidder';

	/// id: '{hours}:{minutes}:{seconds} left'
	String get timeLeft => '{hours}:{minutes}:{seconds} left';

	/// id: '{days} days {hours}:{minutes}:{seconds} left'
	String get timeLeftDays => '{days} days {hours}:{minutes}:{seconds} left';
}

// Path: auctions.errors
class TranslationsAuctionsErrorsId {
	TranslationsAuctionsErrorsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Failed to load auctions: {error}'
	String get fetchFailed => 'Failed to load auctions: {error}';

	/// id: 'Auction not found.'
	String get notFound => 'Auction not found.';

	/// id: 'You must enter a higher bid than the current one.'
	String get lowerBid => 'You must enter a higher bid than the current one.';

	/// id: 'This auction has already ended.'
	String get alreadyEnded => 'This auction has already ended.';
}

// Path: auctions.filter
class TranslationsAuctionsFilterId {
	TranslationsAuctionsFilterId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Filter'
	String get tooltip => 'Filter';

	/// id: 'Clear filter'
	String get clearTooltip => 'Clear filter';
}

// Path: auctions.create
class TranslationsAuctionsCreateId {
	TranslationsAuctionsCreateId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Create Auction'
	String get tooltip => 'Create Auction';

	/// id: 'Create Auction'
	String get title => 'Create Auction';

	/// id: 'Registration type'
	String get registrationType => 'Registration type';

	late final TranslationsAuctionsCreateTypeId type = TranslationsAuctionsCreateTypeId.internal(_root);

	/// id: 'Auction created.'
	String get success => 'Auction created.';

	/// id: 'Failed to create auction: {error}'
	String get fail => 'Failed to create auction: {error}';

	/// id: 'Start Auction'
	String get submitButton => 'Start Auction';

	/// id: 'List as an auction?'
	String get confirmTitle => 'List as an auction?';

	/// id: 'Once listed as an auction, you can't switch back to a normal sale. A 5% fee will be charged upon a successful bid. Continue?'
	String get confirmContent => 'Once listed as an auction, you can\'t switch back to a normal sale. A 5% fee will be charged upon a successful bid. Continue?';

	late final TranslationsAuctionsCreateErrorsId errors = TranslationsAuctionsCreateErrorsId.internal(_root);
	late final TranslationsAuctionsCreateFormId form = TranslationsAuctionsCreateFormId.internal(_root);
}

// Path: auctions.edit
class TranslationsAuctionsEditId {
	TranslationsAuctionsEditId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Edit auction'
	String get tooltip => 'Edit auction';

	/// id: 'Edit Auction'
	String get title => 'Edit Auction';

	/// id: 'Save'
	String get save => 'Save';

	/// id: 'Auction updated.'
	String get success => 'Auction updated.';

	/// id: 'Failed to update auction: {error}'
	String get fail => 'Failed to update auction: {error}';
}

// Path: auctions.form
class TranslationsAuctionsFormId {
	TranslationsAuctionsFormId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Please enter a title.'
	String get titleRequired => 'Please enter a title.';

	/// id: 'Please enter a description.'
	String get descriptionRequired => 'Please enter a description.';

	/// id: 'Please enter a start price.'
	String get startPriceRequired => 'Please enter a start price.';

	/// id: 'Please select a category.'
	String get categoryRequired => 'Please select a category.';
}

// Path: auctions.delete
class TranslationsAuctionsDeleteId {
	TranslationsAuctionsDeleteId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Delete auction'
	String get tooltip => 'Delete auction';

	/// id: 'Delete auction'
	String get confirmTitle => 'Delete auction';

	/// id: 'Are you sure you want to delete this auction?'
	String get confirmContent => 'Are you sure you want to delete this auction?';

	/// id: 'Auction deleted.'
	String get success => 'Auction deleted.';

	/// id: 'Failed to delete auction: {error}'
	String get fail => 'Failed to delete auction: {error}';
}

// Path: auctions.detail
class TranslationsAuctionsDetailId {
	TranslationsAuctionsDetailId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Current bid: {amount}'
	String get currentBid => 'Current bid: {amount}';

	/// id: 'Location'
	String get location => 'Location';

	/// id: 'Seller'
	String get seller => 'Seller';

	/// id: 'Q&A'
	String get qnaTitle => 'Q&A';

	/// id: 'Ask the seller...'
	String get qnaHint => 'Ask the seller...';

	/// id: 'End time: {time}'
	String get endTime => 'End time: {time}';

	/// id: 'Bids'
	String get bidsTitle => 'Bids';

	/// id: 'No bids yet.'
	String get noBids => 'No bids yet.';

	/// id: 'Unknown bidder'
	String get unknownBidder => 'Unknown bidder';

	/// id: 'Enter bid (Rp)'
	String get bidAmountLabel => 'Enter bid (Rp)';

	/// id: 'Bid'
	String get placeBid => 'Bid';

	/// id: 'Bid successful!'
	String get bidSuccess => 'Bid successful!';

	/// id: 'Failed to bid: {error}'
	String get bidFail => 'Failed to bid: {error}';

	late final TranslationsAuctionsDetailErrorsId errors = TranslationsAuctionsDetailErrorsId.internal(_root);
}

// Path: localStores.create
class TranslationsLocalStoresCreateId {
	TranslationsLocalStoresCreateId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Register my store'
	String get tooltip => 'Register my store';

	/// id: 'Register New Store'
	String get title => 'Register New Store';

	/// id: 'Register'
	String get submit => 'Register';

	/// id: 'Store registered.'
	String get success => 'Store registered.';

	/// id: 'Failed to register store: {error}'
	String get fail => 'Failed to register store: {error}';
}

// Path: localStores.edit
class TranslationsLocalStoresEditId {
	TranslationsLocalStoresEditId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Edit Store Info'
	String get title => 'Edit Store Info';

	/// id: 'Save'
	String get save => 'Save';

	/// id: 'Store info updated.'
	String get success => 'Store info updated.';

	/// id: 'Failed to update store: {error}'
	String get fail => 'Failed to update store: {error}';

	/// id: 'Edit store info'
	String get tooltip => 'Edit store info';
}

// Path: localStores.form
class TranslationsLocalStoresFormId {
	TranslationsLocalStoresFormId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Store Name'
	String get nameLabel => 'Store Name';

	/// id: 'Please enter a store name.'
	String get nameError => 'Please enter a store name.';

	/// id: 'Store Description'
	String get descriptionLabel => 'Store Description';

	/// id: 'Please enter a store description.'
	String get descriptionError => 'Please enter a store description.';

	/// id: 'Contact'
	String get contactLabel => 'Contact';

	/// id: 'Hours'
	String get hoursLabel => 'Hours';

	/// id: 'e.g. 09:00 - 18:00'
	String get hoursHint => 'e.g. 09:00 - 18:00';

	/// id: 'Photos (max {count})'
	String get photoLabel => 'Photos (max {count})';

	/// id: 'Category'
	String get categoryLabel => 'Category';

	/// id: 'Please select a category.'
	String get categoryError => 'Please select a category.';

	/// id: 'Representative Products/Services'
	String get productsLabel => 'Representative Products/Services';

	/// id: 'Comma-separated, e.g. Haircut, Coloring, Perm'
	String get productsHint => 'Comma-separated, e.g. Haircut, Coloring, Perm';

	/// id: 'Failed to load image. Please try again.'
	String get imageError => 'Failed to load image. Please try again.';
}

// Path: localStores.categories
class TranslationsLocalStoresCategoriesId {
	TranslationsLocalStoresCategoriesId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'All'
	String get all => 'All';

	/// id: 'Restaurant'
	String get food => 'Restaurant';

	/// id: 'Cafe'
	String get cafe => 'Cafe';

	/// id: 'Massage'
	String get massage => 'Massage';

	/// id: 'Beauty'
	String get beauty => 'Beauty';

	/// id: 'Nail'
	String get nail => 'Nail';

	/// id: 'Auto Repair'
	String get auto => 'Auto Repair';

	/// id: 'Kids'
	String get kids => 'Kids';

	/// id: 'Hospital/Clinic'
	String get hospital => 'Hospital/Clinic';

	/// id: 'Others'
	String get etc => 'Others';
}

// Path: localStores.detail
class TranslationsLocalStoresDetailId {
	TranslationsLocalStoresDetailId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Store Description'
	String get description => 'Store Description';

	/// id: 'Products/Services'
	String get products => 'Products/Services';

	/// id: 'Delete Store'
	String get deleteTitle => 'Delete Store';

	/// id: 'Are you sure you want to delete this store? This action cannot be undone.'
	String get deleteContent => 'Are you sure you want to delete this store? This action cannot be undone.';

	/// id: 'Delete store'
	String get deleteTooltip => 'Delete store';

	/// id: 'Delete'
	String get delete => 'Delete';

	/// id: 'Cancel'
	String get cancel => 'Cancel';

	/// id: 'Store deleted.'
	String get deleteSuccess => 'Store deleted.';

	/// id: 'Failed to delete store: {error}'
	String get deleteFail => 'Failed to delete store: {error}';

	/// id: 'Inquire'
	String get inquire => 'Inquire';

	/// id: 'No owner info'
	String get noOwnerInfo => 'No owner info';

	/// id: 'Could not start chat: {error}'
	String get startChatFail => 'Could not start chat: {error}';

	/// id: 'Reviews'
	String get reviews => 'Reviews';

	/// id: 'Write a review'
	String get writeReview => 'Write a review';

	/// id: 'No reviews yet.'
	String get noReviews => 'No reviews yet.';

	/// id: 'Please write your review.'
	String get reviewDialogContent => 'Please write your review.';
}

// Path: pom.search
class TranslationsPomSearchId {
	TranslationsPomSearchId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Search POMs, tags, users'
	String get hint => 'Search POMs, tags, users';
}

// Path: pom.tabs
class TranslationsPomTabsId {
	TranslationsPomTabsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Local'
	String get local => 'Local';

	/// id: 'All'
	String get all => 'All';

	/// id: 'Popular'
	String get popular => 'Popular';

	/// id: 'My POMs'
	String get myPoms => 'My POMs';
}

// Path: pom.errors
class TranslationsPomErrorsId {
	TranslationsPomErrorsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'An error occurred: {error}'
	String get fetchFailed => 'An error occurred: {error}';

	/// id: 'Can't play this video. The source is unavailable or blocked.'
	String get videoSource => 'Can\'t play this video. The source is unavailable or blocked.';
}

// Path: pom.comments
class TranslationsPomCommentsId {
	TranslationsPomCommentsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Comments'
	String get title => 'Comments';

	/// id: 'View all {} comments'
	String get viewAll => 'View all {} comments';

	/// id: 'No comments yet.'
	String get empty => 'No comments yet.';

	/// id: 'Write a comment...'
	String get placeholder => 'Write a comment...';

	/// id: 'Failed to add comment: {error}'
	String get fail => 'Failed to add comment: {error}';
}

// Path: pom.create
class TranslationsPomCreateId {
	TranslationsPomCreateId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Upload New POM'
	String get title => 'Upload New POM';

	/// id: 'Photo'
	String get photo => 'Photo';

	/// id: 'Video'
	String get video => 'Video';

	/// id: 'Upload Photos'
	String get titleImage => 'Upload Photos';

	/// id: 'Upload'
	String get submit => 'Upload';

	/// id: 'POM uploaded.'
	String get success => 'POM uploaded.';

	/// id: 'Failed to upload POM: {error}'
	String get fail => 'Failed to upload POM: {error}';

	late final TranslationsPomCreateFormId form = TranslationsPomCreateFormId.internal(_root);
}

// Path: realEstate.form
class TranslationsRealEstateFormId {
	TranslationsRealEstateFormId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Pasang Listing'
	String get title => 'Pasang Listing';

	/// id: 'Pasang'
	String get submit => 'Pasang';

	/// id: 'Harap lampirkan minimal satu foto.'
	String get imageRequired => 'Harap lampirkan minimal satu foto.';

	/// id: 'Listing berhasil dibuat.'
	String get success => 'Listing berhasil dibuat.';

	/// id: 'Gagal membuat listing: {error}'
	String get fail => 'Gagal membuat listing: {error}';

	late final TranslationsRealEstateFormTypeId type = TranslationsRealEstateFormTypeId.internal(_root);

	/// id: 'Masukkan harga.'
	String get priceRequired => 'Masukkan harga.';

	late final TranslationsRealEstateFormPriceUnitId priceUnit = TranslationsRealEstateFormPriceUnitId.internal(_root);

	/// id: 'Masukkan judul.'
	String get titleRequired => 'Masukkan judul.';

	late final TranslationsRealEstateFormRoomTypesId roomTypes = TranslationsRealEstateFormRoomTypesId.internal(_root);

	/// id: 'Jenis transaksi'
	String get listingType => 'Jenis transaksi';

	/// id: 'Pilih jenis transaksi'
	String get listingTypeHint => 'Pilih jenis transaksi';

	late final TranslationsRealEstateFormListingTypesId listingTypes = TranslationsRealEstateFormListingTypesId.internal(_root);

	/// id: 'Tipe pengiklan'
	String get publisherType => 'Tipe pengiklan';

	late final TranslationsRealEstateFormPublisherTypesId publisherTypes = TranslationsRealEstateFormPublisherTypesId.internal(_root);

	/// id: 'Luas'
	String get area => 'Luas';

	/// id: 'Luas tanah'
	String get landArea => 'Luas tanah';

	/// id: 'Kamar'
	String get rooms => 'Kamar';

	/// id: 'Kamar mandi'
	String get bathrooms => 'Kamar mandi';

	/// id: 'Kmr'
	String get bedAbbr => 'Kmr';

	/// id: 'Mandi'
	String get bathAbbr => 'Mandi';

	/// id: 'Tanggal masuk'
	String get moveInDate => 'Tanggal masuk';

	/// id: 'Pilih tanggal'
	String get selectDate => 'Pilih tanggal';

	/// id: 'Hapus tanggal'
	String get clearDate => 'Hapus tanggal';

	/// id: 'Fasilitas'
	String get amenities => 'Fasilitas';

	/// id: 'Detail listing'
	String get details => 'Detail listing';

	/// id: 'Biaya perawatan bulanan'
	String get maintenanceFee => 'Biaya perawatan bulanan';

	/// id: 'Biaya perawatan (per bulan, Rp)'
	String get maintenanceFeeHint => 'Biaya perawatan (per bulan, Rp)';

	/// id: 'Deposit'
	String get deposit => 'Deposit';

	/// id: 'Deposit (Rp)'
	String get depositHint => 'Deposit (Rp)';

	/// id: 'Info lantai'
	String get floorInfo => 'Info lantai';

	/// id: 'contoh: Lantai 3 dari 5'
	String get floorInfoHint => 'contoh: Lantai 3 dari 5';

	/// id: 'Harga'
	String get priceLabel => 'Harga';

	/// id: 'Judul'
	String get titleLabel => 'Judul';

	/// id: 'Deskripsi'
	String get descriptionLabel => 'Deskripsi';

	/// id: 'Tipe kamar'
	String get typeLabel => 'Tipe kamar';

	/// id: 'mis. 33'
	String get areaHint => 'mis. 33';

	late final TranslationsRealEstateFormAmenityId amenity = TranslationsRealEstateFormAmenityId.internal(_root);
}

// Path: realEstate.detail
class TranslationsRealEstateDetailId {
	TranslationsRealEstateDetailId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Hapus listing'
	String get deleteTitle => 'Hapus listing';

	/// id: 'Apakah Anda yakin ingin menghapus listing ini?'
	String get deleteContent => 'Apakah Anda yakin ingin menghapus listing ini?';

	/// id: 'Batal'
	String get cancel => 'Batal';

	/// id: 'Info pengiklan'
	String get publisherInfo => 'Info pengiklan';

	/// id: 'Kontak'
	String get contact => 'Kontak';

	/// id: 'Hapus'
	String get deleteConfirm => 'Hapus';

	/// id: 'Listing dihapus.'
	String get deleteSuccess => 'Listing dihapus.';

	/// id: 'Gagal menghapus listing: {error}'
	String get deleteFail => 'Gagal menghapus listing: {error}';

	/// id: 'Gagal memulai chat: {error}'
	String get chatError => 'Gagal memulai chat: {error}';

	/// id: 'Lokasi'
	String get location => 'Lokasi';
}

// Path: realEstate.priceUnits
class TranslationsRealEstatePriceUnitsId {
	TranslationsRealEstatePriceUnitsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'bulan'
	String get monthly => 'bulan';

	/// id: 'tahun'
	String get yearly => 'tahun';
}

// Path: realEstate.filter
class TranslationsRealEstateFilterId {
	TranslationsRealEstateFilterId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Filter lanjutan'
	String get title => 'Filter lanjutan';

	/// id: 'Rentang harga'
	String get priceRange => 'Rentang harga';

	/// id: 'Luas (m²)'
	String get areaRange => 'Luas (m²)';

	/// id: 'Luas tanah (m²)'
	String get landAreaRange => 'Luas tanah (m²)';

	/// id: 'Rentang deposit'
	String get depositRange => 'Rentang deposit';

	/// id: 'Info lantai'
	String get floorInfo => 'Info lantai';

	/// id: 'Deposit minimum'
	String get depositMin => 'Deposit minimum';

	/// id: 'Deposit maksimum'
	String get depositMax => 'Deposit maksimum';

	/// id: 'Hapus'
	String get clearFloorInfo => 'Hapus';

	/// id: 'Kondisi furnitur'
	String get furnishedStatus => 'Kondisi furnitur';

	/// id: 'Periode sewa'
	String get rentPeriod => 'Periode sewa';

	/// id: 'Pilih kondisi furnitur'
	String get selectFurnished => 'Pilih kondisi furnitur';

	/// id: 'Pilih kondisi furnitur'
	String get furnishedHint => 'Pilih kondisi furnitur';

	/// id: 'Pilih periode sewa'
	String get selectRentPeriod => 'Pilih periode sewa';

	late final TranslationsRealEstateFilterRentPeriodsId rentPeriods = TranslationsRealEstateFilterRentPeriodsId.internal(_root);

	/// id: 'Kondisi properti'
	String get propertyCondition => 'Kondisi properti';

	late final TranslationsRealEstateFilterPropertyConditionsId propertyConditions = TranslationsRealEstateFilterPropertyConditionsId.internal(_root);
	late final TranslationsRealEstateFilterFurnishedTypesId furnishedTypes = TranslationsRealEstateFilterFurnishedTypesId.internal(_root);
	late final TranslationsRealEstateFilterAmenitiesId amenities = TranslationsRealEstateFilterAmenitiesId.internal(_root);
	late final TranslationsRealEstateFilterKosId kos = TranslationsRealEstateFilterKosId.internal(_root);
	late final TranslationsRealEstateFilterApartmentId apartment = TranslationsRealEstateFilterApartmentId.internal(_root);
	late final TranslationsRealEstateFilterHouseId house = TranslationsRealEstateFilterHouseId.internal(_root);
	late final TranslationsRealEstateFilterCommercialId commercial = TranslationsRealEstateFilterCommercialId.internal(_root);
}

// Path: realEstate.info
class TranslationsRealEstateInfoId {
	TranslationsRealEstateInfoId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Kamar'
	String get bed => 'Kamar';

	/// id: 'Mandi'
	String get bath => 'Mandi';

	/// id: 'Kapan saja'
	String get anytime => 'Kapan saja';

	/// id: 'Pengiklan terverifikasi'
	String get verifiedPublisher => 'Pengiklan terverifikasi';
}

// Path: realEstate.priceUnit
class TranslationsRealEstatePriceUnitId {
	TranslationsRealEstatePriceUnitId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: '/bulan'
	String get monthly => '/bulan';
}

// Path: realEstate.edit
class TranslationsRealEstateEditId {
	TranslationsRealEstateEditId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Ubah Listing'
	String get title => 'Ubah Listing';

	/// id: 'Simpan'
	String get save => 'Simpan';

	/// id: 'Listing diperbarui.'
	String get success => 'Listing diperbarui.';

	/// id: 'Gagal memperbarui listing: {error}'
	String get fail => 'Gagal memperbarui listing: {error}';
}

// Path: lostAndFound.tabs
class TranslationsLostAndFoundTabsId {
	TranslationsLostAndFoundTabsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Semua'
	String get all => 'Semua';

	/// id: 'Lost'
	String get lost => 'Lost';

	/// id: 'Found'
	String get found => 'Found';
}

// Path: lostAndFound.form
class TranslationsLostAndFoundFormId {
	TranslationsLostAndFoundFormId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Daftarkan Barang Hilang/Temuan'
	String get title => 'Daftarkan Barang Hilang/Temuan';

	/// id: 'Daftar'
	String get submit => 'Daftar';

	late final TranslationsLostAndFoundFormTypeId type = TranslationsLostAndFoundFormTypeId.internal(_root);

	/// id: 'Tambah foto (maks 5)'
	String get photoSectionTitle => 'Tambah foto (maks 5)';

	/// id: 'Harap lampirkan minimal satu foto.'
	String get imageRequired => 'Harap lampirkan minimal satu foto.';

	/// id: 'Barang apa?'
	String get itemLabel => 'Barang apa?';

	/// id: 'Harap jelaskan barangnya.'
	String get itemError => 'Harap jelaskan barangnya.';

	/// id: 'Atur hadiah (opsional)'
	String get bountyTitle => 'Atur hadiah (opsional)';

	/// id: 'Jika diaktifkan, postingan akan menampilkan label hadiah.'
	String get bountyDesc => 'Jika diaktifkan, postingan akan menampilkan label hadiah.';

	/// id: 'Nominal hadiah (IDR)'
	String get bountyAmount => 'Nominal hadiah (IDR)';

	/// id: 'Masukkan jumlah hadiah untuk mengaktifkan.'
	String get bountyAmountError => 'Masukkan jumlah hadiah untuk mengaktifkan.';

	/// id: 'Berhasil didaftarkan.'
	String get success => 'Berhasil didaftarkan.';

	/// id: 'Gagal mendaftar: {error}'
	String get fail => 'Gagal mendaftar: {error}';

	/// id: 'Tambahkan tag (tekan spasi untuk konfirmasi)'
	String get tagsHint => 'Tambahkan tag (tekan spasi untuk konfirmasi)';

	/// id: 'Where was it lost or found?'
	String get locationLabel => 'Where was it lost or found?';

	/// id: 'Please describe the location.'
	String get locationError => 'Please describe the location.';
}

// Path: lostAndFound.detail
class TranslationsLostAndFoundDetailId {
	TranslationsLostAndFoundDetailId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Hilang & Temuan'
	String get title => 'Hilang & Temuan';

	/// id: 'Hadiah'
	String get bounty => 'Hadiah';

	/// id: 'Pendaftar'
	String get registrant => 'Pendaftar';

	/// id: 'Selesai'
	String get resolved => 'Selesai';

	/// id: 'Tandai selesai'
	String get markAsResolved => 'Tandai selesai';

	/// id: 'Hapus postingan'
	String get deleteTitle => 'Hapus postingan';

	/// id: 'Hapus postingan ini? Tindakan ini tidak dapat dibatalkan.'
	String get deleteContent => 'Hapus postingan ini? Tindakan ini tidak dapat dibatalkan.';

	/// id: 'Batal'
	String get cancel => 'Batal';

	/// id: 'Edit'
	String get editTooltip => 'Edit';

	/// id: 'Hapus'
	String get deleteTooltip => 'Hapus';

	/// id: 'Pengguna tidak ditemukan'
	String get noUser => 'Pengguna tidak ditemukan';

	/// id: 'Tidak dapat memulai chat: {error}'
	String get chatError => 'Tidak dapat memulai chat: {error}';

	/// id: 'Location'
	String get location => 'Location';

	/// id: 'Contact'
	String get contact => 'Contact';

	/// id: 'Delete'
	String get delete => 'Delete';

	/// id: 'Post deleted.'
	String get deleteSuccess => 'Post deleted.';

	/// id: 'Failed to delete post: {error}'
	String get deleteFail => 'Failed to delete post: {error}';
}

// Path: lostAndFound.card
class TranslationsLostAndFoundCardId {
	TranslationsLostAndFoundCardId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Lokasi: {location}'
	String get location => 'Lokasi: {location}';
}

// Path: lostAndFound.resolve
class TranslationsLostAndFoundResolveId {
	TranslationsLostAndFoundResolveId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Mark as resolved?'
	String get confirmTitle => 'Mark as resolved?';

	/// id: 'This will mark the item as resolved.'
	String get confirmBody => 'This will mark the item as resolved.';

	/// id: 'Marked as resolved.'
	String get success => 'Marked as resolved.';

	/// id: 'Found!'
	String get badgeLost => 'Found!';

	/// id: 'Returned!'
	String get badgeFound => 'Returned!';
}

// Path: lostAndFound.edit
class TranslationsLostAndFoundEditId {
	TranslationsLostAndFoundEditId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Edit Lost/Found Item'
	String get title => 'Edit Lost/Found Item';

	/// id: 'Save'
	String get save => 'Save';

	/// id: 'Updated.'
	String get success => 'Updated.';

	/// id: 'Failed to update: {error}'
	String get fail => 'Failed to update: {error}';
}

// Path: shared.tagInput
class TranslationsSharedTagInputId {
	TranslationsSharedTagInputId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Add tags (press space to confirm)'
	String get defaultHint => 'Add tags (press space to confirm)';
}

// Path: admin.screen
class TranslationsAdminScreenId {
	TranslationsAdminScreenId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Admin Menu'
	String get title => 'Admin Menu';
}

// Path: admin.menu
class TranslationsAdminMenuId {
	TranslationsAdminMenuId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'AI Verification Management'
	String get aiApproval => 'AI Verification Management';

	/// id: 'Report Management'
	String get reportManagement => 'Report Management';
}

// Path: admin.aiApproval
class TranslationsAdminAiApprovalId {
	TranslationsAdminAiApprovalId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'No products pending AI verification.'
	String get empty => 'No products pending AI verification.';

	/// id: 'Error loading pending products.'
	String get error => 'Error loading pending products.';

	/// id: 'Requested at'
	String get requestedAt => 'Requested at';
}

// Path: admin.reports
class TranslationsAdminReportsId {
	TranslationsAdminReportsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Report Management'
	String get title => 'Report Management';

	/// id: 'No pending reports.'
	String get empty => 'No pending reports.';

	/// id: 'Error loading reports.'
	String get error => 'Error loading reports.';

	/// id: 'Created at'
	String get createdAt => 'Created at';
}

// Path: admin.reportList
class TranslationsAdminReportListId {
	TranslationsAdminReportListId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Report Management'
	String get title => 'Report Management';

	/// id: 'No pending reports.'
	String get empty => 'No pending reports.';

	/// id: 'Error loading reports.'
	String get error => 'Error loading reports.';
}

// Path: admin.reportDetail
class TranslationsAdminReportDetailId {
	TranslationsAdminReportDetailId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Report Details'
	String get title => 'Report Details';

	/// id: 'Error loading report details.'
	String get loadError => 'Error loading report details.';

	/// id: 'Report Information'
	String get sectionReportInfo => 'Report Information';

	/// id: 'ID'
	String get idLabel => 'ID';

	/// id: 'Reported Post ID'
	String get postIdLabel => 'Reported Post ID';

	/// id: 'Reporter'
	String get reporter => 'Reporter';

	/// id: 'Reported User'
	String get reportedUser => 'Reported User';

	/// id: 'Reason'
	String get reason => 'Reason';

	/// id: 'Reported At'
	String get reportedAt => 'Reported At';

	/// id: 'Status'
	String get currentStatus => 'Status';

	/// id: 'Reported Content'
	String get sectionContent => 'Reported Content';

	/// id: 'Loading content...'
	String get loadingContent => 'Loading content...';

	/// id: 'Failed to load reported content.'
	String get contentLoadError => 'Failed to load reported content.';

	/// id: 'Content information not available or deleted.'
	String get contentNotAvailable => 'Content information not available or deleted.';

	/// id: 'Author ID'
	String get authorIdLabel => 'Author ID';

	late final TranslationsAdminReportDetailContentId content = TranslationsAdminReportDetailContentId.internal(_root);

	/// id: 'View Original Post'
	String get viewOriginalPost => 'View Original Post';

	/// id: 'Actions'
	String get sectionActions => 'Actions';

	/// id: 'Mark as Reviewed'
	String get actionReviewed => 'Mark as Reviewed';

	/// id: 'Mark Action Taken (e.g., Deleted)'
	String get actionTaken => 'Mark Action Taken (e.g., Deleted)';

	/// id: 'Dismiss Report'
	String get actionDismissed => 'Dismiss Report';

	/// id: 'Report status updated to '{status}'.'
	String get statusUpdateSuccess => 'Report status updated to \'{status}\'.';

	/// id: 'Failed to update status: {error}'
	String get statusUpdateFail => 'Failed to update status: {error}';

	/// id: 'Original post not found.'
	String get originalPostNotFound => 'Original post not found.';

	/// id: 'Could not open original post.'
	String get couldNotOpenOriginalPost => 'Could not open original post.';
}

// Path: admin.dataFix
class TranslationsAdminDataFixId {
	TranslationsAdminDataFixId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Data Fix Logs'
	String get logsLabel => 'Data Fix Logs';
}

// Path: tags.localNews
class TranslationsTagsLocalNewsId {
	TranslationsTagsLocalNewsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsTagsLocalNewsKelurahanNoticeId kelurahanNotice = TranslationsTagsLocalNewsKelurahanNoticeId.internal(_root);
	late final TranslationsTagsLocalNewsKecamatanNoticeId kecamatanNotice = TranslationsTagsLocalNewsKecamatanNoticeId.internal(_root);
	late final TranslationsTagsLocalNewsPublicCampaignId publicCampaign = TranslationsTagsLocalNewsPublicCampaignId.internal(_root);
	late final TranslationsTagsLocalNewsSiskamlingId siskamling = TranslationsTagsLocalNewsSiskamlingId.internal(_root);
	late final TranslationsTagsLocalNewsPowerOutageId powerOutage = TranslationsTagsLocalNewsPowerOutageId.internal(_root);
	late final TranslationsTagsLocalNewsWaterOutageId waterOutage = TranslationsTagsLocalNewsWaterOutageId.internal(_root);
	late final TranslationsTagsLocalNewsWasteCollectionId wasteCollection = TranslationsTagsLocalNewsWasteCollectionId.internal(_root);
	late final TranslationsTagsLocalNewsRoadWorksId roadWorks = TranslationsTagsLocalNewsRoadWorksId.internal(_root);
	late final TranslationsTagsLocalNewsPublicFacilityId publicFacility = TranslationsTagsLocalNewsPublicFacilityId.internal(_root);
	late final TranslationsTagsLocalNewsWeatherWarningId weatherWarning = TranslationsTagsLocalNewsWeatherWarningId.internal(_root);
	late final TranslationsTagsLocalNewsFloodAlertId floodAlert = TranslationsTagsLocalNewsFloodAlertId.internal(_root);
	late final TranslationsTagsLocalNewsAirQualityId airQuality = TranslationsTagsLocalNewsAirQualityId.internal(_root);
	late final TranslationsTagsLocalNewsDiseaseAlertId diseaseAlert = TranslationsTagsLocalNewsDiseaseAlertId.internal(_root);
	late final TranslationsTagsLocalNewsSchoolNoticeId schoolNotice = TranslationsTagsLocalNewsSchoolNoticeId.internal(_root);
	late final TranslationsTagsLocalNewsPosyanduId posyandu = TranslationsTagsLocalNewsPosyanduId.internal(_root);
	late final TranslationsTagsLocalNewsHealthCampaignId healthCampaign = TranslationsTagsLocalNewsHealthCampaignId.internal(_root);
	late final TranslationsTagsLocalNewsTrafficControlId trafficControl = TranslationsTagsLocalNewsTrafficControlId.internal(_root);
	late final TranslationsTagsLocalNewsPublicTransportId publicTransport = TranslationsTagsLocalNewsPublicTransportId.internal(_root);
	late final TranslationsTagsLocalNewsParkingPolicyId parkingPolicy = TranslationsTagsLocalNewsParkingPolicyId.internal(_root);
	late final TranslationsTagsLocalNewsCommunityEventId communityEvent = TranslationsTagsLocalNewsCommunityEventId.internal(_root);
	late final TranslationsTagsLocalNewsWorshipEventId worshipEvent = TranslationsTagsLocalNewsWorshipEventId.internal(_root);
	late final TranslationsTagsLocalNewsIncidentReportId incidentReport = TranslationsTagsLocalNewsIncidentReportId.internal(_root);
}

// Path: main.search.hint
class TranslationsMainSearchHintId {
	TranslationsMainSearchHintId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Cari di {}'
	String get globalSheet => 'Cari di {}';

	/// id: 'Cari judul, isi, tag'
	String get localNews => 'Cari judul, isi, tag';

	/// id: 'Cari pekerjaan, perusahaan, 'Bantu Saya''
	String get jobs => 'Cari pekerjaan, perusahaan, \'Bantu Saya\'';

	/// id: 'Cari barang hilang/temuan'
	String get lostAndFound => 'Cari barang hilang/temuan';

	/// id: 'Cari barang jual'
	String get marketplace => 'Cari barang jual';

	/// id: 'Cari toko atau layanan'
	String get localStores => 'Cari toko atau layanan';

	/// id: 'Cari profil, minat'
	String get findFriends => 'Cari profil, minat';

	/// id: 'Cari klub, minat, lokasi'
	String get clubs => 'Cari klub, minat, lokasi';

	/// id: 'Cari properti, area, harga'
	String get realEstate => 'Cari properti, area, harga';

	/// id: 'Cari barang lelang, merek'
	String get auction => 'Cari barang lelang, merek';

	/// id: 'Cari POM, tag, pengguna'
	String get pom => 'Cari POM, tag, pengguna';
}

// Path: drawer.trustDashboard.breakdown
class TranslationsDrawerTrustDashboardBreakdownId {
	TranslationsDrawerTrustDashboardBreakdownId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: '+50'
	String get kelurahanAuth => '+50';

	/// id: '+50'
	String get rtRwAuth => '+50';

	/// id: '+100'
	String get phoneAuth => '+100';

	/// id: '+50'
	String get profileComplete => '+50';

	/// id: '+10 per'
	String get feedThanks => '+10 per';

	/// id: '+20 per'
	String get marketThanks => '+20 per';

	/// id: '-50 per'
	String get reports => '-50 per';
}

// Path: marketplace.takeover.guide
class TranslationsMarketplaceTakeoverGuideId {
	TranslationsMarketplaceTakeoverGuideId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Verifikasi kesesuaian di lokasi dengan AI'
	String get title => 'Verifikasi kesesuaian di lokasi dengan AI';

	/// id: 'Pastikan barang di lokasi sama dengan yang ada di laporan AI. Ambil minimal 3 foto yang jelas menunjukkan ciri utama barang.'
	String get subtitle => 'Pastikan barang di lokasi sama dengan yang ada di laporan AI. Ambil minimal 3 foto yang jelas menunjukkan ciri utama barang.';
}

// Path: marketplace.takeover.errors
class TranslationsMarketplaceTakeoverErrorsId {
	TranslationsMarketplaceTakeoverErrorsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Minimal 1 foto di lokasi diperlukan untuk verifikasi.'
	String get noPhoto => 'Minimal 1 foto di lokasi diperlukan untuk verifikasi.';
}

// Path: marketplace.takeover.dialog
class TranslationsMarketplaceTakeoverDialogId {
	TranslationsMarketplaceTakeoverDialogId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Verifikasi AI berhasil'
	String get matchTitle => 'Verifikasi AI berhasil';

	/// id: 'Verifikasi AI gagal'
	String get noMatchTitle => 'Verifikasi AI gagal';

	/// id: 'Konfirmasi serah terima akhir'
	String get finalize => 'Konfirmasi serah terima akhir';

	/// id: 'Batalkan transaksi (minta refund)'
	String get cancelDeal => 'Batalkan transaksi (minta refund)';
}

// Path: marketplace.takeover.success
class TranslationsMarketplaceTakeoverSuccessId {
	TranslationsMarketplaceTakeoverSuccessId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Transaksi berhasil diselesaikan.'
	String get finalized => 'Transaksi berhasil diselesaikan.';

	/// id: 'Transaksi dibatalkan. Deposit akan dikembalikan.'
	String get cancelled => 'Transaksi dibatalkan. Deposit akan dikembalikan.';
}

// Path: categories.post.jalanPerbaikin
class TranslationsCategoriesPostJalanPerbaikinId {
	TranslationsCategoriesPostJalanPerbaikinId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations
	late final TranslationsCategoriesPostJalanPerbaikinSearchId search = TranslationsCategoriesPostJalanPerbaikinSearchId.internal(_root);

	/// id: 'Perbaikan jalan'
	String get name => 'Perbaikan jalan';
}

// Path: categories.post.dailyLife
class TranslationsCategoriesPostDailyLifeId {
	TranslationsCategoriesPostDailyLifeId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Sehari-hari/Pertanyaan'
	String get name => 'Sehari-hari/Pertanyaan';

	/// id: 'Bagikan kehidupan sehari-hari atau ajukan pertanyaan.'
	String get description => 'Bagikan kehidupan sehari-hari atau ajukan pertanyaan.';
}

// Path: categories.post.helpShare
class TranslationsCategoriesPostHelpShareId {
	TranslationsCategoriesPostHelpShareId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Bantuan/ Berbagi'
	String get name => 'Bantuan/ Berbagi';

	/// id: 'Butuh bantuan atau ingin berbagi sesuatu? Posting di sini.'
	String get description => 'Butuh bantuan atau ingin berbagi sesuatu? Posting di sini.';
}

// Path: categories.post.incidentReport
class TranslationsCategoriesPostIncidentReportId {
	TranslationsCategoriesPostIncidentReportId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Insiden'
	String get name => 'Insiden';

	/// id: 'Bagikan kabar insiden di lingkungan Anda.'
	String get description => 'Bagikan kabar insiden di lingkungan Anda.';
}

// Path: categories.post.localNews
class TranslationsCategoriesPostLocalNewsId {
	TranslationsCategoriesPostLocalNewsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Berita lingkungan'
	String get name => 'Berita lingkungan';

	/// id: 'Bagikan berita dan informasi tentang lingkungan kita.'
	String get description => 'Bagikan berita dan informasi tentang lingkungan kita.';
}

// Path: categories.post.november
class TranslationsCategoriesPostNovemberId {
	TranslationsCategoriesPostNovemberId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'November'
	String get name => 'November';
}

// Path: categories.post.rain
class TranslationsCategoriesPostRainId {
	TranslationsCategoriesPostRainId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Hujan'
	String get name => 'Hujan';
}

// Path: categories.post.dailyQuestion
class TranslationsCategoriesPostDailyQuestionId {
	TranslationsCategoriesPostDailyQuestionId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Ada pertanyaan?'
	String get name => 'Ada pertanyaan?';

	/// id: 'Tanyakan apa saja kepada tetangga Anda.'
	String get description => 'Tanyakan apa saja kepada tetangga Anda.';
}

// Path: categories.post.storePromo
class TranslationsCategoriesPostStorePromoId {
	TranslationsCategoriesPostStorePromoId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Promo toko'
	String get name => 'Promo toko';

	/// id: 'Promosikan diskon atau event di toko Anda.'
	String get description => 'Promosikan diskon atau event di toko Anda.';
}

// Path: categories.post.etc
class TranslationsCategoriesPostEtcId {
	TranslationsCategoriesPostEtcId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Lainnya'
	String get name => 'Lainnya';

	/// id: 'Bagikan cerita lain secara bebas.'
	String get description => 'Bagikan cerita lain secara bebas.';
}

// Path: categories.auction.collectibles
class TranslationsCategoriesAuctionCollectiblesId {
	TranslationsCategoriesAuctionCollectiblesId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Koleksi'
	String get name => 'Koleksi';

	/// id: 'Mainan, kartu, figur, dan lainnya.'
	String get description => 'Mainan, kartu, figur, dan lainnya.';
}

// Path: categories.auction.digital
class TranslationsCategoriesAuctionDigitalId {
	TranslationsCategoriesAuctionDigitalId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Digital'
	String get name => 'Digital';

	/// id: 'Produk dan aset digital.'
	String get description => 'Produk dan aset digital.';
}

// Path: categories.auction.fashion
class TranslationsCategoriesAuctionFashionId {
	TranslationsCategoriesAuctionFashionId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Fashion'
	String get name => 'Fashion';

	/// id: 'Pakaian, aksesori, dan kecantikan.'
	String get description => 'Pakaian, aksesori, dan kecantikan.';
}

// Path: categories.auction.vintage
class TranslationsCategoriesAuctionVintageId {
	TranslationsCategoriesAuctionVintageId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Vintage'
	String get name => 'Vintage';

	/// id: 'Barang retro dan klasik.'
	String get description => 'Barang retro dan klasik.';
}

// Path: categories.auction.artCraft
class TranslationsCategoriesAuctionArtCraftId {
	TranslationsCategoriesAuctionArtCraftId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Seni & kerajinan'
	String get name => 'Seni & kerajinan';

	/// id: 'Karya seni dan kerajinan tangan.'
	String get description => 'Karya seni dan kerajinan tangan.';
}

// Path: categories.auction.etc
class TranslationsCategoriesAuctionEtcId {
	TranslationsCategoriesAuctionEtcId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Lainnya'
	String get name => 'Lainnya';

	/// id: 'Barang lelang lainnya.'
	String get description => 'Barang lelang lainnya.';
}

// Path: clubs.detail.tabs
class TranslationsClubsDetailTabsId {
	TranslationsClubsDetailTabsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Info'
	String get info => 'Info';

	/// id: 'Board'
	String get board => 'Board';

	/// id: 'Members'
	String get members => 'Members';
}

// Path: clubs.detail.info
class TranslationsClubsDetailInfoId {
	TranslationsClubsDetailInfoId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Members'
	String get members => 'Members';

	/// id: 'Location'
	String get location => 'Location';
}

// Path: clubs.proposal.detail
class TranslationsClubsProposalDetailId {
	TranslationsClubsProposalDetailId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'You joined the proposal!'
	String get joined => 'You joined the proposal!';

	/// id: 'You left the proposal.'
	String get left => 'You left the proposal.';

	/// id: 'Please log in to join.'
	String get loginRequired => 'Please log in to join.';

	/// id: 'An error occurred: {error}'
	String get error => 'An error occurred: {error}';
}

// Path: auctions.create.type
class TranslationsAuctionsCreateTypeId {
	TranslationsAuctionsCreateTypeId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Sale'
	String get sale => 'Sale';

	/// id: 'Auction'
	String get auction => 'Auction';
}

// Path: auctions.create.errors
class TranslationsAuctionsCreateErrorsId {
	TranslationsAuctionsCreateErrorsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Please add at least one photo.'
	String get noPhoto => 'Please add at least one photo.';
}

// Path: auctions.create.form
class TranslationsAuctionsCreateFormId {
	TranslationsAuctionsCreateFormId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Upload photos (max 10)'
	String get photoSectionTitle => 'Upload photos (max 10)';

	/// id: 'Title'
	String get title => 'Title';

	/// id: 'Description'
	String get description => 'Description';

	/// id: 'Start price'
	String get startPrice => 'Start price';

	/// id: 'Category'
	String get category => 'Category';

	/// id: 'Select a category'
	String get categoryHint => 'Select a category';

	/// id: 'Type a tag and press Space to add'
	String get tagsHint => 'Type a tag and press Space to add';

	/// id: 'Duration'
	String get duration => 'Duration';

	/// id: '{days} days'
	String get durationOption => '{days} days';

	/// id: 'Location'
	String get location => 'Location';
}

// Path: auctions.detail.errors
class TranslationsAuctionsDetailErrorsId {
	TranslationsAuctionsDetailErrorsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Login required.'
	String get loginRequired => 'Login required.';

	/// id: 'Enter a valid bid amount.'
	String get invalidAmount => 'Enter a valid bid amount.';
}

// Path: pom.create.form
class TranslationsPomCreateFormId {
	TranslationsPomCreateFormId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Title'
	String get titleLabel => 'Title';

	/// id: 'Description'
	String get descriptionLabel => 'Description';
}

// Path: realEstate.form.type
class TranslationsRealEstateFormTypeId {
	TranslationsRealEstateFormTypeId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Kost'
	String get kos => 'Kost';

	/// id: 'Kontrakan (sewa bulanan)'
	String get kontrakan => 'Kontrakan (sewa bulanan)';

	/// id: 'Sewa'
	String get sewa => 'Sewa';
}

// Path: realEstate.form.priceUnit
class TranslationsRealEstateFormPriceUnitId {
	TranslationsRealEstateFormPriceUnitId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: '/bulan'
	String get monthly => '/bulan';

	/// id: '/tahun'
	String get yearly => '/tahun';
}

// Path: realEstate.form.roomTypes
class TranslationsRealEstateFormRoomTypesId {
	TranslationsRealEstateFormRoomTypesId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Kost'
	String get kos => 'Kost';

	/// id: 'Kontrakan'
	String get kontrakan => 'Kontrakan';

	/// id: 'Sewa'
	String get sewa => 'Sewa';

	/// id: 'Apartemen'
	String get apartment => 'Apartemen';

	/// id: 'Rumah'
	String get house => 'Rumah';

	/// id: 'Ruko'
	String get ruko => 'Ruko';

	/// id: 'Gudang'
	String get gudang => 'Gudang';

	/// id: 'Kantor'
	String get kantor => 'Kantor';

	/// id: 'Lainnya'
	String get etc => 'Lainnya';
}

// Path: realEstate.form.listingTypes
class TranslationsRealEstateFormListingTypesId {
	TranslationsRealEstateFormListingTypesId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Sewa'
	String get rent => 'Sewa';

	/// id: 'Jual'
	String get sale => 'Jual';
}

// Path: realEstate.form.publisherTypes
class TranslationsRealEstateFormPublisherTypesId {
	TranslationsRealEstateFormPublisherTypesId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Individu'
	String get individual => 'Individu';

	/// id: 'Agen'
	String get agent => 'Agen';
}

// Path: realEstate.form.amenity
class TranslationsRealEstateFormAmenityId {
	TranslationsRealEstateFormAmenityId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Wi‑Fi'
	String get wifi => 'Wi‑Fi';

	/// id: 'AC'
	String get ac => 'AC';

	/// id: 'Parkir'
	String get parking => 'Parkir';

	/// id: 'Dapur'
	String get kitchen => 'Dapur';
}

// Path: realEstate.filter.rentPeriods
class TranslationsRealEstateFilterRentPeriodsId {
	TranslationsRealEstateFilterRentPeriodsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Harian'
	String get daily => 'Harian';

	/// id: 'Bulanan'
	String get monthly => 'Bulanan';

	/// id: 'Tahunan'
	String get yearly => 'Tahunan';
}

// Path: realEstate.filter.propertyConditions
class TranslationsRealEstateFilterPropertyConditionsId {
	TranslationsRealEstateFilterPropertyConditionsId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Baru'
	String get kNew => 'Baru';

	/// id: 'Bekas'
	String get used => 'Bekas';
}

// Path: realEstate.filter.furnishedTypes
class TranslationsRealEstateFilterFurnishedTypesId {
	TranslationsRealEstateFilterFurnishedTypesId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Lengkap'
	String get furnished => 'Lengkap';

	/// id: 'Semi-lengkap'
	String get semiFurnished => 'Semi-lengkap';

	/// id: 'Tanpa furnitur'
	String get unfurnished => 'Tanpa furnitur';
}

// Path: realEstate.filter.amenities
class TranslationsRealEstateFilterAmenitiesId {
	TranslationsRealEstateFilterAmenitiesId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'AC'
	String get ac => 'AC';

	/// id: 'Tempat tidur'
	String get bed => 'Tempat tidur';

	/// id: 'Lemari'
	String get closet => 'Lemari';

	/// id: 'Meja'
	String get desk => 'Meja';

	/// id: 'Wi‑Fi'
	String get wifi => 'Wi‑Fi';

	/// id: 'Dapur'
	String get kitchen => 'Dapur';

	/// id: 'Ruang keluarga'
	String get livingRoom => 'Ruang keluarga';

	/// id: 'Kulkas'
	String get refrigerator => 'Kulkas';

	/// id: 'Parkir motor'
	String get parkingMotorcycle => 'Parkir motor';

	/// id: 'Parkir mobil'
	String get parkingCar => 'Parkir mobil';

	/// id: 'Kolam renang'
	String get pool => 'Kolam renang';

	/// id: 'Gym'
	String get gym => 'Gym';

	/// id: 'Keamanan 24 jam'
	String get security24h => 'Keamanan 24 jam';

	/// id: 'ATM'
	String get atmCenter => 'ATM';

	/// id: 'Minimarket'
	String get minimarket => 'Minimarket';

	/// id: 'Akses mall'
	String get mallAccess => 'Akses mall';

	/// id: 'Taman bermain'
	String get playground => 'Taman bermain';

	/// id: 'Carport'
	String get carport => 'Carport';

	/// id: 'Taman'
	String get garden => 'Taman';

	/// id: 'Air PAM'
	String get pam => 'Air PAM';

	/// id: 'Telepon'
	String get telephone => 'Telepon';

	/// id: 'Pemanas air'
	String get waterHeater => 'Pemanas air';

	/// id: 'Area parkir'
	String get parkingArea => 'Area parkir';

	/// id: 'Listrik'
	String get electricity => 'Listrik';

	/// id: 'Akses kontainer'
	String get containerAccess => 'Akses kontainer';

	late final TranslationsRealEstateFilterAmenitiesKosRoomId kosRoom = TranslationsRealEstateFilterAmenitiesKosRoomId.internal(_root);
	late final TranslationsRealEstateFilterAmenitiesKosPublicId kosPublic = TranslationsRealEstateFilterAmenitiesKosPublicId.internal(_root);
	late final TranslationsRealEstateFilterAmenitiesApartmentId apartment = TranslationsRealEstateFilterAmenitiesApartmentId.internal(_root);
	late final TranslationsRealEstateFilterAmenitiesHouseId house = TranslationsRealEstateFilterAmenitiesHouseId.internal(_root);
	late final TranslationsRealEstateFilterAmenitiesCommercialId commercial = TranslationsRealEstateFilterAmenitiesCommercialId.internal(_root);
}

// Path: realEstate.filter.kos
class TranslationsRealEstateFilterKosId {
	TranslationsRealEstateFilterKosId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Tipe kamar mandi'
	String get bathroomType => 'Tipe kamar mandi';

	late final TranslationsRealEstateFilterKosBathroomTypesId bathroomTypes = TranslationsRealEstateFilterKosBathroomTypesId.internal(_root);

	/// id: 'Kapasitas maksimal'
	String get maxOccupants => 'Kapasitas maksimal';

	/// id: 'Pilih tipe kamar mandi'
	String get hintBathroomType => 'Pilih tipe kamar mandi';

	/// id: 'Pilih jumlah penghuni'
	String get hintMaxOccupants => 'Pilih jumlah penghuni';

	/// id: 'Listrik termasuk'
	String get electricityIncluded => 'Listrik termasuk';

	/// id: 'Fasilitas kamar'
	String get roomFacilities => 'Fasilitas kamar';

	/// id: 'Fasilitas umum'
	String get publicFacilities => 'Fasilitas umum';

	/// id: 'Orang'
	String get occupant => 'Orang';
}

// Path: realEstate.filter.apartment
class TranslationsRealEstateFilterApartmentId {
	TranslationsRealEstateFilterApartmentId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Fasilitas apartemen'
	String get facilities => 'Fasilitas apartemen';
}

// Path: realEstate.filter.house
class TranslationsRealEstateFilterHouseId {
	TranslationsRealEstateFilterHouseId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Fasilitas rumah'
	String get facilities => 'Fasilitas rumah';
}

// Path: realEstate.filter.commercial
class TranslationsRealEstateFilterCommercialId {
	TranslationsRealEstateFilterCommercialId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Fasilitas komersial'
	String get facilities => 'Fasilitas komersial';
}

// Path: lostAndFound.form.type
class TranslationsLostAndFoundFormTypeId {
	TranslationsLostAndFoundFormTypeId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Saya kehilangan'
	String get lost => 'Saya kehilangan';

	/// id: 'Saya menemukan'
	String get found => 'Saya menemukan';
}

// Path: admin.reportDetail.content
class TranslationsAdminReportDetailContentId {
	TranslationsAdminReportDetailContentId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Post: {title} {body}'
	String get post => 'Post: {title}\n\n{body}';

	/// id: 'Comment: {content}'
	String get comment => 'Comment: {content}';

	/// id: 'Reply: {content}'
	String get reply => 'Reply: {content}';
}

// Path: tags.localNews.kelurahanNotice
class TranslationsTagsLocalNewsKelurahanNoticeId {
	TranslationsTagsLocalNewsKelurahanNoticeId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Kelurahan notice'
	String get name => 'Kelurahan notice';

	/// id: 'Neighborhood office announcements.'
	String get desc => 'Neighborhood office announcements.';
}

// Path: tags.localNews.kecamatanNotice
class TranslationsTagsLocalNewsKecamatanNoticeId {
	TranslationsTagsLocalNewsKecamatanNoticeId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Kecamatan notice'
	String get name => 'Kecamatan notice';

	/// id: 'District office announcements.'
	String get desc => 'District office announcements.';
}

// Path: tags.localNews.publicCampaign
class TranslationsTagsLocalNewsPublicCampaignId {
	TranslationsTagsLocalNewsPublicCampaignId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Public campaign'
	String get name => 'Public campaign';

	/// id: 'Public information and government programs.'
	String get desc => 'Public information and government programs.';
}

// Path: tags.localNews.siskamling
class TranslationsTagsLocalNewsSiskamlingId {
	TranslationsTagsLocalNewsSiskamlingId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Neighborhood watch'
	String get name => 'Neighborhood watch';

	/// id: 'Community safety patrol activities.'
	String get desc => 'Community safety patrol activities.';
}

// Path: tags.localNews.powerOutage
class TranslationsTagsLocalNewsPowerOutageId {
	TranslationsTagsLocalNewsPowerOutageId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Power outage'
	String get name => 'Power outage';

	/// id: 'Information about electricity outages in your area.'
	String get desc => 'Information about electricity outages in your area.';
}

// Path: tags.localNews.waterOutage
class TranslationsTagsLocalNewsWaterOutageId {
	TranslationsTagsLocalNewsWaterOutageId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Water outage'
	String get name => 'Water outage';

	/// id: 'Information about water supply outages.'
	String get desc => 'Information about water supply outages.';
}

// Path: tags.localNews.wasteCollection
class TranslationsTagsLocalNewsWasteCollectionId {
	TranslationsTagsLocalNewsWasteCollectionId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Waste collection'
	String get name => 'Waste collection';

	/// id: 'Garbage pickup schedules or notices.'
	String get desc => 'Garbage pickup schedules or notices.';
}

// Path: tags.localNews.roadWorks
class TranslationsTagsLocalNewsRoadWorksId {
	TranslationsTagsLocalNewsRoadWorksId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Road works'
	String get name => 'Road works';

	/// id: 'Road construction and maintenance information.'
	String get desc => 'Road construction and maintenance information.';
}

// Path: tags.localNews.publicFacility
class TranslationsTagsLocalNewsPublicFacilityId {
	TranslationsTagsLocalNewsPublicFacilityId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Public facility'
	String get name => 'Public facility';

	/// id: 'Parks, fields, and public facility updates.'
	String get desc => 'Parks, fields, and public facility updates.';
}

// Path: tags.localNews.weatherWarning
class TranslationsTagsLocalNewsWeatherWarningId {
	TranslationsTagsLocalNewsWeatherWarningId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Weather warning'
	String get name => 'Weather warning';

	/// id: 'Severe weather alerts in your area.'
	String get desc => 'Severe weather alerts in your area.';
}

// Path: tags.localNews.floodAlert
class TranslationsTagsLocalNewsFloodAlertId {
	TranslationsTagsLocalNewsFloodAlertId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Flood alert'
	String get name => 'Flood alert';

	/// id: 'Flood advisories and areas affected.'
	String get desc => 'Flood advisories and areas affected.';
}

// Path: tags.localNews.airQuality
class TranslationsTagsLocalNewsAirQualityId {
	TranslationsTagsLocalNewsAirQualityId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Air quality'
	String get name => 'Air quality';

	/// id: 'Air pollution and AQI information.'
	String get desc => 'Air pollution and AQI information.';
}

// Path: tags.localNews.diseaseAlert
class TranslationsTagsLocalNewsDiseaseAlertId {
	TranslationsTagsLocalNewsDiseaseAlertId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Disease alert'
	String get name => 'Disease alert';

	/// id: 'Communicable disease alerts and public health info.'
	String get desc => 'Communicable disease alerts and public health info.';
}

// Path: tags.localNews.schoolNotice
class TranslationsTagsLocalNewsSchoolNoticeId {
	TranslationsTagsLocalNewsSchoolNoticeId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'School notice'
	String get name => 'School notice';

	/// id: 'Notices from nearby schools.'
	String get desc => 'Notices from nearby schools.';
}

// Path: tags.localNews.posyandu
class TranslationsTagsLocalNewsPosyanduId {
	TranslationsTagsLocalNewsPosyanduId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Posyandu'
	String get name => 'Posyandu';

	/// id: 'Community health post activities.'
	String get desc => 'Community health post activities.';
}

// Path: tags.localNews.healthCampaign
class TranslationsTagsLocalNewsHealthCampaignId {
	TranslationsTagsLocalNewsHealthCampaignId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Health campaign'
	String get name => 'Health campaign';

	/// id: 'Health campaign and public health guidance.'
	String get desc => 'Health campaign and public health guidance.';
}

// Path: tags.localNews.trafficControl
class TranslationsTagsLocalNewsTrafficControlId {
	TranslationsTagsLocalNewsTrafficControlId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Traffic control'
	String get name => 'Traffic control';

	/// id: 'Traffic diversions, closures, and control info.'
	String get desc => 'Traffic diversions, closures, and control info.';
}

// Path: tags.localNews.publicTransport
class TranslationsTagsLocalNewsPublicTransportId {
	TranslationsTagsLocalNewsPublicTransportId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Public transport'
	String get name => 'Public transport';

	/// id: 'Bus, train, and public transportation updates.'
	String get desc => 'Bus, train, and public transportation updates.';
}

// Path: tags.localNews.parkingPolicy
class TranslationsTagsLocalNewsParkingPolicyId {
	TranslationsTagsLocalNewsParkingPolicyId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Parking policy'
	String get name => 'Parking policy';

	/// id: 'Parking information and policy changes.'
	String get desc => 'Parking information and policy changes.';
}

// Path: tags.localNews.communityEvent
class TranslationsTagsLocalNewsCommunityEventId {
	TranslationsTagsLocalNewsCommunityEventId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Community event'
	String get name => 'Community event';

	/// id: 'Local festivals, gatherings, and events.'
	String get desc => 'Local festivals, gatherings, and events.';
}

// Path: tags.localNews.worshipEvent
class TranslationsTagsLocalNewsWorshipEventId {
	TranslationsTagsLocalNewsWorshipEventId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Religious event'
	String get name => 'Religious event';

	/// id: 'Events at mosques, churches, temples, etc.'
	String get desc => 'Events at mosques, churches, temples, etc.';
}

// Path: tags.localNews.incidentReport
class TranslationsTagsLocalNewsIncidentReportId {
	TranslationsTagsLocalNewsIncidentReportId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Incident report'
	String get name => 'Incident report';

	/// id: 'Reports of incidents and accidents in the neighborhood.'
	String get desc => 'Reports of incidents and accidents in the neighborhood.';
}

// Path: categories.post.jalanPerbaikin.search
class TranslationsCategoriesPostJalanPerbaikinSearchId {
	TranslationsCategoriesPostJalanPerbaikinSearchId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Cari POM, tag, pengguna'
	String get hint => 'Cari POM, tag, pengguna';
}

// Path: realEstate.filter.amenities.kosRoom
class TranslationsRealEstateFilterAmenitiesKosRoomId {
	TranslationsRealEstateFilterAmenitiesKosRoomId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'AC'
	String get ac => 'AC';

	/// id: 'Tempat tidur'
	String get bed => 'Tempat tidur';

	/// id: 'Lemari'
	String get closet => 'Lemari';

	/// id: 'Meja'
	String get desk => 'Meja';

	/// id: 'Wi‑Fi'
	String get wifi => 'Wi‑Fi';
}

// Path: realEstate.filter.amenities.kosPublic
class TranslationsRealEstateFilterAmenitiesKosPublicId {
	TranslationsRealEstateFilterAmenitiesKosPublicId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Dapur'
	String get kitchen => 'Dapur';

	/// id: 'Ruang keluarga'
	String get livingRoom => 'Ruang keluarga';

	/// id: 'Kulkas'
	String get refrigerator => 'Kulkas';

	/// id: 'Parkir motor'
	String get parkingMotorcycle => 'Parkir motor';

	/// id: 'Parkir mobil'
	String get parkingCar => 'Parkir mobil';
}

// Path: realEstate.filter.amenities.apartment
class TranslationsRealEstateFilterAmenitiesApartmentId {
	TranslationsRealEstateFilterAmenitiesApartmentId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Kolam renang'
	String get pool => 'Kolam renang';

	/// id: 'Gym'
	String get gym => 'Gym';

	/// id: 'Keamanan 24 jam'
	String get security24h => 'Keamanan 24 jam';

	/// id: 'ATM'
	String get atmCenter => 'ATM';

	/// id: 'Minimarket'
	String get minimarket => 'Minimarket';

	/// id: 'Akses mall'
	String get mallAccess => 'Akses mall';

	/// id: 'Taman bermain'
	String get playground => 'Taman bermain';
}

// Path: realEstate.filter.amenities.house
class TranslationsRealEstateFilterAmenitiesHouseId {
	TranslationsRealEstateFilterAmenitiesHouseId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Carport'
	String get carport => 'Carport';

	/// id: 'Taman'
	String get garden => 'Taman';

	/// id: 'Air PAM'
	String get pam => 'Air PAM';

	/// id: 'Telepon'
	String get telephone => 'Telepon';

	/// id: 'Pemanas air'
	String get waterHeater => 'Pemanas air';
}

// Path: realEstate.filter.amenities.commercial
class TranslationsRealEstateFilterAmenitiesCommercialId {
	TranslationsRealEstateFilterAmenitiesCommercialId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Area parkir'
	String get parkingArea => 'Area parkir';

	/// id: 'Keamanan 24 jam'
	String get security24h => 'Keamanan 24 jam';

	/// id: 'Telepon'
	String get telephone => 'Telepon';

	/// id: 'Listrik'
	String get electricity => 'Listrik';

	/// id: 'Akses kontainer'
	String get containerAccess => 'Akses kontainer';
}

// Path: realEstate.filter.kos.bathroomTypes
class TranslationsRealEstateFilterKosBathroomTypesId {
	TranslationsRealEstateFilterKosBathroomTypesId.internal(this._root);

	final Translations _root; // ignore: unused_field

	// Translations

	/// id: 'Di dalam kamar'
	String get inRoom => 'Di dalam kamar';

	/// id: 'Di luar kamar'
	String get outRoom => 'Di luar kamar';
}

/// The flat map containing all translations for locale <id>.
/// Only for edge cases! For simple maps, use the map function of this library.
///
/// The Dart AOT compiler has issues with very large switch statements,
/// so the map is split into smaller functions (512 entries each).
extension on Translations {
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
			'jobs.form.updateSuccess' => 'Lowongan berhasil diperbarui.',
			'jobs.form.editTitle' => 'Edit Lowongan',
			'jobs.form.update' => 'Perbarui',
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
			'boards.popup.inactiveTitle' => 'Papan lingkungan belum aktif',
			'boards.popup.inactiveBody' => 'Untuk mengaktifkan papan lingkungan Anda, buat dulu satu posting Berita Lokal. Jika tetangga mulai ikut serta, papan akan terbuka otomatis.',
			'boards.popup.writePost' => 'Tulis Berita Lokal',
			'boards.defaultTitle' => 'Papan',
			'boards.chatRoomComingSoon' => 'Ruang chat segera hadir',
			'boards.chatRoomTitle' => 'Ruang Chat',
			'boards.emptyFeed' => 'Belum ada postingan.',
			'boards.chatRoomCreated' => 'Ruang chat telah dibuat.',
			'locationSettingError' => 'Gagal menyetel lokasi.',
			'signupFailRequired' => 'Kolom ini wajib diisi.',
			'signup.alerts.signupSuccessLoginNotice' => 'Pendaftaran berhasil! Silakan login.',
			'signup.title' => 'Daftar',
			'signup.subtitle' => 'Bergabunglah dengan komunitas lingkungan Anda!',
			'signup.nicknameHint' => 'Nama panggilan',
			'signup.emailHint' => 'Alamat email',
			'signup.passwordHint' => 'Kata sandi',
			'signup.passwordConfirmHint' => 'Konfirmasi kata sandi',
			'signup.locationHint' => 'Lokasi',
			'signup.locationNotice' => 'Lokasi Anda hanya digunakan untuk menampilkan postingan lokal dan tidak dibagikan.',
			'signup.buttons.signup' => 'Daftar',
			'signupFailDefault' => 'Pendaftaran gagal.',
			'signupFailWeakPassword' => 'Kata sandi terlalu lemah.',
			'signupFailEmailInUse' => 'Email sudah digunakan.',
			'signupFailInvalidEmail' => 'Format email tidak valid.',
			'signupFailUnknown' => 'Terjadi kesalahan yang tidak diketahui.',
			'categoryEmpty' => 'Tidak ada kategori',
			'user.notLoggedIn' => 'Belum login.',
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
			'realEstate.create' => 'Tambahkan listing',
			'realEstate.form.title' => 'Pasang Listing',
			'realEstate.form.submit' => 'Pasang',
			'realEstate.form.imageRequired' => 'Harap lampirkan minimal satu foto.',
			'realEstate.form.success' => 'Listing berhasil dibuat.',
			'realEstate.form.fail' => 'Gagal membuat listing: {error}',
			'realEstate.form.type.kos' => 'Kost',
			'realEstate.form.type.kontrakan' => 'Kontrakan (sewa bulanan)',
			'realEstate.form.type.sewa' => 'Sewa',
			'realEstate.form.priceRequired' => 'Masukkan harga.',
			'realEstate.form.priceUnit.monthly' => '/bulan',
			'realEstate.form.priceUnit.yearly' => '/tahun',
			'realEstate.form.titleRequired' => 'Masukkan judul.',
			'realEstate.form.roomTypes.kos' => 'Kost',
			'realEstate.form.roomTypes.kontrakan' => 'Kontrakan',
			'realEstate.form.roomTypes.sewa' => 'Sewa',
			'realEstate.form.roomTypes.apartment' => 'Apartemen',
			'realEstate.form.roomTypes.house' => 'Rumah',
			'realEstate.form.roomTypes.ruko' => 'Ruko',
			'realEstate.form.roomTypes.gudang' => 'Gudang',
			'realEstate.form.roomTypes.kantor' => 'Kantor',
			'realEstate.form.roomTypes.etc' => 'Lainnya',
			'realEstate.form.listingType' => 'Jenis transaksi',
			'realEstate.form.listingTypeHint' => 'Pilih jenis transaksi',
			'realEstate.form.listingTypes.rent' => 'Sewa',
			'realEstate.form.listingTypes.sale' => 'Jual',
			'realEstate.form.publisherType' => 'Tipe pengiklan',
			'realEstate.form.publisherTypes.individual' => 'Individu',
			'realEstate.form.publisherTypes.agent' => 'Agen',
			'realEstate.form.area' => 'Luas',
			'realEstate.form.landArea' => 'Luas tanah',
			'realEstate.form.rooms' => 'Kamar',
			'realEstate.form.bathrooms' => 'Kamar mandi',
			'realEstate.form.bedAbbr' => 'Kmr',
			'realEstate.form.bathAbbr' => 'Mandi',
			'realEstate.form.moveInDate' => 'Tanggal masuk',
			'realEstate.form.selectDate' => 'Pilih tanggal',
			'realEstate.form.clearDate' => 'Hapus tanggal',
			'realEstate.form.amenities' => 'Fasilitas',
			'realEstate.form.details' => 'Detail listing',
			'realEstate.form.maintenanceFee' => 'Biaya perawatan bulanan',
			'realEstate.form.maintenanceFeeHint' => 'Biaya perawatan (per bulan, Rp)',
			'realEstate.form.deposit' => 'Deposit',
			'realEstate.form.depositHint' => 'Deposit (Rp)',
			'realEstate.form.floorInfo' => 'Info lantai',
			'realEstate.form.floorInfoHint' => 'contoh: Lantai 3 dari 5',
			'realEstate.form.priceLabel' => 'Harga',
			'realEstate.form.titleLabel' => 'Judul',
			'realEstate.form.descriptionLabel' => 'Deskripsi',
			'realEstate.form.typeLabel' => 'Tipe kamar',
			'realEstate.form.areaHint' => 'mis. 33',
			'realEstate.form.amenity.wifi' => 'Wi‑Fi',
			_ => null,
		} ?? switch (path) {
			'realEstate.form.amenity.ac' => 'AC',
			'realEstate.form.amenity.parking' => 'Parkir',
			'realEstate.form.amenity.kitchen' => 'Dapur',
			'realEstate.detail.deleteTitle' => 'Hapus listing',
			'realEstate.detail.deleteContent' => 'Apakah Anda yakin ingin menghapus listing ini?',
			'realEstate.detail.cancel' => 'Batal',
			'realEstate.detail.publisherInfo' => 'Info pengiklan',
			'realEstate.detail.contact' => 'Kontak',
			'realEstate.detail.deleteConfirm' => 'Hapus',
			'realEstate.detail.deleteSuccess' => 'Listing dihapus.',
			'realEstate.detail.deleteFail' => 'Gagal menghapus listing: {error}',
			'realEstate.detail.chatError' => 'Gagal memulai chat: {error}',
			'realEstate.detail.location' => 'Lokasi',
			'realEstate.locationUnknown' => 'Tidak ada info lokasi',
			'realEstate.priceUnits.monthly' => 'bulan',
			'realEstate.priceUnits.yearly' => 'tahun',
			'realEstate.filter.title' => 'Filter lanjutan',
			'realEstate.filter.priceRange' => 'Rentang harga',
			'realEstate.filter.areaRange' => 'Luas (m²)',
			'realEstate.filter.landAreaRange' => 'Luas tanah (m²)',
			'realEstate.filter.depositRange' => 'Rentang deposit',
			'realEstate.filter.floorInfo' => 'Info lantai',
			'realEstate.filter.depositMin' => 'Deposit minimum',
			'realEstate.filter.depositMax' => 'Deposit maksimum',
			'realEstate.filter.clearFloorInfo' => 'Hapus',
			'realEstate.filter.furnishedStatus' => 'Kondisi furnitur',
			'realEstate.filter.rentPeriod' => 'Periode sewa',
			'realEstate.filter.selectFurnished' => 'Pilih kondisi furnitur',
			'realEstate.filter.furnishedHint' => 'Pilih kondisi furnitur',
			'realEstate.filter.selectRentPeriod' => 'Pilih periode sewa',
			'realEstate.filter.rentPeriods.daily' => 'Harian',
			'realEstate.filter.rentPeriods.monthly' => 'Bulanan',
			'realEstate.filter.rentPeriods.yearly' => 'Tahunan',
			'realEstate.filter.propertyCondition' => 'Kondisi properti',
			'realEstate.filter.propertyConditions.kNew' => 'Baru',
			'realEstate.filter.propertyConditions.used' => 'Bekas',
			'realEstate.filter.furnishedTypes.furnished' => 'Lengkap',
			'realEstate.filter.furnishedTypes.semiFurnished' => 'Semi-lengkap',
			'realEstate.filter.furnishedTypes.unfurnished' => 'Tanpa furnitur',
			'realEstate.filter.amenities.ac' => 'AC',
			'realEstate.filter.amenities.bed' => 'Tempat tidur',
			'realEstate.filter.amenities.closet' => 'Lemari',
			'realEstate.filter.amenities.desk' => 'Meja',
			'realEstate.filter.amenities.wifi' => 'Wi‑Fi',
			'realEstate.filter.amenities.kitchen' => 'Dapur',
			'realEstate.filter.amenities.livingRoom' => 'Ruang keluarga',
			'realEstate.filter.amenities.refrigerator' => 'Kulkas',
			'realEstate.filter.amenities.parkingMotorcycle' => 'Parkir motor',
			'realEstate.filter.amenities.parkingCar' => 'Parkir mobil',
			'realEstate.filter.amenities.pool' => 'Kolam renang',
			'realEstate.filter.amenities.gym' => 'Gym',
			'realEstate.filter.amenities.security24h' => 'Keamanan 24 jam',
			'realEstate.filter.amenities.atmCenter' => 'ATM',
			'realEstate.filter.amenities.minimarket' => 'Minimarket',
			'realEstate.filter.amenities.mallAccess' => 'Akses mall',
			'realEstate.filter.amenities.playground' => 'Taman bermain',
			'realEstate.filter.amenities.carport' => 'Carport',
			'realEstate.filter.amenities.garden' => 'Taman',
			'realEstate.filter.amenities.pam' => 'Air PAM',
			'realEstate.filter.amenities.telephone' => 'Telepon',
			'realEstate.filter.amenities.waterHeater' => 'Pemanas air',
			'realEstate.filter.amenities.parkingArea' => 'Area parkir',
			'realEstate.filter.amenities.electricity' => 'Listrik',
			'realEstate.filter.amenities.containerAccess' => 'Akses kontainer',
			'realEstate.filter.amenities.kosRoom.ac' => 'AC',
			'realEstate.filter.amenities.kosRoom.bed' => 'Tempat tidur',
			'realEstate.filter.amenities.kosRoom.closet' => 'Lemari',
			'realEstate.filter.amenities.kosRoom.desk' => 'Meja',
			'realEstate.filter.amenities.kosRoom.wifi' => 'Wi‑Fi',
			'realEstate.filter.amenities.kosPublic.kitchen' => 'Dapur',
			'realEstate.filter.amenities.kosPublic.livingRoom' => 'Ruang keluarga',
			'realEstate.filter.amenities.kosPublic.refrigerator' => 'Kulkas',
			'realEstate.filter.amenities.kosPublic.parkingMotorcycle' => 'Parkir motor',
			'realEstate.filter.amenities.kosPublic.parkingCar' => 'Parkir mobil',
			'realEstate.filter.amenities.apartment.pool' => 'Kolam renang',
			'realEstate.filter.amenities.apartment.gym' => 'Gym',
			'realEstate.filter.amenities.apartment.security24h' => 'Keamanan 24 jam',
			'realEstate.filter.amenities.apartment.atmCenter' => 'ATM',
			'realEstate.filter.amenities.apartment.minimarket' => 'Minimarket',
			'realEstate.filter.amenities.apartment.mallAccess' => 'Akses mall',
			'realEstate.filter.amenities.apartment.playground' => 'Taman bermain',
			'realEstate.filter.amenities.house.carport' => 'Carport',
			'realEstate.filter.amenities.house.garden' => 'Taman',
			'realEstate.filter.amenities.house.pam' => 'Air PAM',
			'realEstate.filter.amenities.house.telephone' => 'Telepon',
			'realEstate.filter.amenities.house.waterHeater' => 'Pemanas air',
			'realEstate.filter.amenities.commercial.parkingArea' => 'Area parkir',
			'realEstate.filter.amenities.commercial.security24h' => 'Keamanan 24 jam',
			'realEstate.filter.amenities.commercial.telephone' => 'Telepon',
			'realEstate.filter.amenities.commercial.electricity' => 'Listrik',
			'realEstate.filter.amenities.commercial.containerAccess' => 'Akses kontainer',
			'realEstate.filter.kos.bathroomType' => 'Tipe kamar mandi',
			'realEstate.filter.kos.bathroomTypes.inRoom' => 'Di dalam kamar',
			'realEstate.filter.kos.bathroomTypes.outRoom' => 'Di luar kamar',
			'realEstate.filter.kos.maxOccupants' => 'Kapasitas maksimal',
			'realEstate.filter.kos.hintBathroomType' => 'Pilih tipe kamar mandi',
			'realEstate.filter.kos.hintMaxOccupants' => 'Pilih jumlah penghuni',
			'realEstate.filter.kos.electricityIncluded' => 'Listrik termasuk',
			'realEstate.filter.kos.roomFacilities' => 'Fasilitas kamar',
			'realEstate.filter.kos.publicFacilities' => 'Fasilitas umum',
			'realEstate.filter.kos.occupant' => 'Orang',
			'realEstate.filter.apartment.facilities' => 'Fasilitas apartemen',
			'realEstate.filter.house.facilities' => 'Fasilitas rumah',
			'realEstate.filter.commercial.facilities' => 'Fasilitas komersial',
			'realEstate.info.bed' => 'Kamar',
			'realEstate.info.bath' => 'Mandi',
			'realEstate.info.anytime' => 'Kapan saja',
			'realEstate.info.verifiedPublisher' => 'Pengiklan terverifikasi',
			'realEstate.disclaimer' => 'Bling adalah platform iklan dan bukan agen/broker properti. Keakuratan informasi, kepemilikan, harga, dan syarat merupakan tanggung jawab penuh pengiklan. Pengguna harus memverifikasi seluruh informasi langsung dengan pengiklan dan pihak berwenang sebelum melanjutkan transaksi.',
			'realEstate.empty' => 'Tidak ada listing.',
			'realEstate.error' => 'Terjadi kesalahan: {error}',
			'realEstate.priceUnit.monthly' => '/bulan',
			'realEstate.edit.title' => 'Ubah Listing',
			'realEstate.edit.save' => 'Simpan',
			'realEstate.edit.success' => 'Listing diperbarui.',
			'realEstate.edit.fail' => 'Gagal memperbarui listing: {error}',
			'lostAndFound.tabs.all' => 'Semua',
			'lostAndFound.tabs.lost' => 'Lost',
			'lostAndFound.tabs.found' => 'Found',
			'lostAndFound.create' => 'Tambahkan barang hilang/temuan',
			'lostAndFound.form.title' => 'Daftarkan Barang Hilang/Temuan',
			'lostAndFound.form.submit' => 'Daftar',
			'lostAndFound.form.type.lost' => 'Saya kehilangan',
			'lostAndFound.form.type.found' => 'Saya menemukan',
			'lostAndFound.form.photoSectionTitle' => 'Tambah foto (maks 5)',
			'lostAndFound.form.imageRequired' => 'Harap lampirkan minimal satu foto.',
			'lostAndFound.form.itemLabel' => 'Barang apa?',
			'lostAndFound.form.itemError' => 'Harap jelaskan barangnya.',
			'lostAndFound.form.bountyTitle' => 'Atur hadiah (opsional)',
			'lostAndFound.form.bountyDesc' => 'Jika diaktifkan, postingan akan menampilkan label hadiah.',
			'lostAndFound.form.bountyAmount' => 'Nominal hadiah (IDR)',
			'lostAndFound.form.bountyAmountError' => 'Masukkan jumlah hadiah untuk mengaktifkan.',
			'lostAndFound.form.success' => 'Berhasil didaftarkan.',
			'lostAndFound.form.fail' => 'Gagal mendaftar: {error}',
			'lostAndFound.form.tagsHint' => 'Tambahkan tag (tekan spasi untuk konfirmasi)',
			'lostAndFound.form.locationLabel' => 'Where was it lost or found?',
			'lostAndFound.form.locationError' => 'Please describe the location.',
			'lostAndFound.detail.title' => 'Hilang & Temuan',
			'lostAndFound.detail.bounty' => 'Hadiah',
			'lostAndFound.detail.registrant' => 'Pendaftar',
			'lostAndFound.detail.resolved' => 'Selesai',
			'lostAndFound.detail.markAsResolved' => 'Tandai selesai',
			'lostAndFound.detail.deleteTitle' => 'Hapus postingan',
			'lostAndFound.detail.deleteContent' => 'Hapus postingan ini? Tindakan ini tidak dapat dibatalkan.',
			'lostAndFound.detail.cancel' => 'Batal',
			'lostAndFound.detail.editTooltip' => 'Edit',
			'lostAndFound.detail.deleteTooltip' => 'Hapus',
			'lostAndFound.detail.noUser' => 'Pengguna tidak ditemukan',
			'lostAndFound.detail.chatError' => 'Tidak dapat memulai chat: {error}',
			'lostAndFound.detail.location' => 'Location',
			'lostAndFound.detail.contact' => 'Contact',
			'lostAndFound.detail.delete' => 'Delete',
			'lostAndFound.detail.deleteSuccess' => 'Post deleted.',
			'lostAndFound.detail.deleteFail' => 'Failed to delete post: {error}',
			'lostAndFound.lost' => 'Hilang',
			'lostAndFound.found' => 'Ditemukan',
			'lostAndFound.card.location' => 'Lokasi: {location}',
			'lostAndFound.empty' => 'No lost/found items yet.',
			'lostAndFound.error' => 'An error occurred: {error}',
			'lostAndFound.resolve.confirmTitle' => 'Mark as resolved?',
			'lostAndFound.resolve.confirmBody' => 'This will mark the item as resolved.',
			'lostAndFound.resolve.success' => 'Marked as resolved.',
			'lostAndFound.resolve.badgeLost' => 'Found!',
			'lostAndFound.resolve.badgeFound' => 'Returned!',
			'lostAndFound.edit.title' => 'Edit Lost/Found Item',
			'lostAndFound.edit.save' => 'Save',
			'lostAndFound.edit.success' => 'Updated.',
			'lostAndFound.edit.fail' => 'Failed to update: {error}',
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
			'signupFailPasswordMismatch' => 'Kedua kata sandi tidak cocok.',
			_ => null,
		};
	}
}
