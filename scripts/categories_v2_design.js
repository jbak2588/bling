// '카테코리 설계도.xlsx' 파일의 내용을 기반으로 재구성한 데이터입니다.
// 이 파일은 rebuild_categories.js 스크립트에서 사용됩니다.

const design = {
  // 문서 1: 디지털기기
  "PnPa5ZjI9FYQiAGP6I7m": {
    isParent: true, name_ko: "디지털기기", name_en: "Digital Devices", name_id: "Perangkat Digital", order: 1,
    subCategories: {
      "electronics": { name_ko: "전자기기", name_en: "Electronics", name_id: "Elektronik", order: 1 },
      "smartphone-tablet": { name_ko: "스마트폰/태블릿", name_en: "Smartphone/Tablet", name_id: "Handphone & Tablet", order: 2 },
      "computer-laptop": { name_ko: "컴퓨터/노트북", name_en: "Computer/Laptop", name_id: "Komputer & Laptop", order: 3 },
      "camera-drone": { name_ko: "카메라/드론", name_en: "Camera/Drone", name_id: "Kamera & Drone", order: 4 },
      "other-digital-devices": { name_ko: "기타 디지털기기", name_en: "Other Digital Devices", name_id: "Perangkat Digital Lainnya", order: 99 }
    }
  },
  // 문서 2: 생활용품
  "4hx6hyOYodriXgPiR5bl": {
    isParent: true, name_ko: "생활용품", name_en: "Home Essentials", name_id: "Perlengkapan Rumah", order: 2,
    subCategories: {
      "kitchenware": { name_ko: "주방용품", name_en: "Kitchenware", name_id: "Peralatan Dapur", order: 1 },
      "furniture": { name_ko: "가구", name_en: "Furniture", name_id: "Perabot", order: 2 },
      "lighting-electrical": { name_ko: "조명/전기", name_en: "Lighting & Electrical", name_id: "Lampu & Listrik", order: 3 },
      "other-home-essentials": { name_ko: "기타 생활용품", name_en: "Others Home Essentials", name_id: "Perlengkapan Rumah Lainnya", order: 99 }
    }
  },
  // 문서 3: 패션
  "OkjaREVlnybYXdJKZvF7": {
    isParent: true, name_ko: "패션", name_en: "Fashion", name_id: "Fashion", order: 3,
    subCategories: {
      "women-s-clothing": { name_ko: "여성의류", name_en: "Women's Clothing", name_id: "Pakaian Wanita", order: 1 },
      "men-s-clothing": { name_ko: "남성의류", name_en: "Men's Clothing", name_id: "Pakaian Pria", order: 2 },
      "shoes": { name_ko: "신발", name_en: "Shoes", name_id: "Sepatu", order: 3 },
      "bags-accessories": { name_ko: "가방/잡화", name_en: "Tas & Aksesori", name_id: "Tas & Aksesoris", order: 4 },
      "other-fashion": { name_ko: "기타 패션 ", name_en: "Other Fashion Itmes", name_id: "Fashion  Lainnya", order: 99 }
    }
  },
  // 문서 4: 뷰티/미용
  "lhxeaWRmfmd2gElvHy8y": {
    isParent: true, name_ko: "뷰티/미용", name_en: "Beauty & Care", name_id: "Kecantikan & Perawatan", order: 4,
    subCategories: {
      "skincare": { name_ko: "스킨케어", name_en: "Skincare", name_id: "Perawatan Kulit", order: 1 },
      "makeup": { name_ko: "메이크업", name_en: "Makeup", name_id: "Rias Wajah", order: 2 },
      "hair-body": { name_ko: "헤어/바디", name_en: "Hair/Body", name_id: "Perawatan Rambut & Tubuh", order: 3 },
      "other-beauty-care": { name_ko: "기타 뷰티/미용", name_en: "Other Beauty & Care", name_id: "Kecantikan & Perawatan Lainnya", order: 99 }
    }
  },
  // 문서 5: 한정판/명품/급매품
  "wyYkvRznDcngqzuJvOIJ": {
    isParent: true, name_ko: "한정판/명품/급매품", name_en: "Limited & Luxury", name_id: "Edisi Terbatas & Mewah", order: 5,
    subCategories: {
      "limited-edition": { name_ko: "한정판", name_en: "Limited Edition", name_id: "Edisi Terbatas", order: 1 },
      "luxury-goods": { name_ko: "명품", name_en: "Luxury Goods", name_id: "Barang Mewah", order: 2 },
      "hunter-s-pick": { name_ko: "헌터 아이템", name_en: "Hunter's Pick", name_id: "Pilihan Hunter", order: 3 },
      "other-limited-luxury": { name_ko: "기타 한정판/명품/급매품", name_en: "Other Limited & Luxury Items", name_id: "Edisi Terbatas & Mewah Lainnya", order: 99 }
    }
  },
  // 문서 6: 취미/여가
  "IJ9rF047d2rRnFFkdLyw": {
    isParent: true, name_ko: "취미/여가", name_en: "Hobby & Leisure", name_id: "Hobi & Rekreasi", order: 6,
    subCategories: {
      "sports-leisure": { name_ko: "스포츠/레저", name_en: "Sports & Leisure", name_id: "Olahraga & Rekreasi", order: 1 },
      "games-consoles": { name_ko: "게임/콘솔", name_en: "Games & Consoles", name_id: "Game & Konsol", order: 2 },
      "instruments": { name_ko: "악기", name_en: "Instruments", name_id: "Alat Musik", order: 3 },
      "books-stationery": { name_ko: "도서/문구", name_en: "Books & Stationery", name_id: "Buku & Alat Tulis", order: 4 },
      "other-hobby-leisure": { name_ko: "기타 취미/여가", name_en: "Other Hobby & Leisure", name_id: "Hobi & Rekreasi Lainnya", order: 99 }
    }
  },
  // 문서 7: 유아/아동
  "6WtvHv9Mm2M49KIVRdZT": {
    isParent: true, name_ko: "유아/아동", name_en: "Baby & Kids", name_id: "Bayi & Anak", order: 7,
    subCategories: {
      "baby-clothing": { name_ko: "유아 의류", name_en: "Baby Clothing", name_id: "Pakaian Bayi", order: 1 },
      "toys": { name_ko: "완구/장난감", name_en: "Toys", name_id: "Mainan Anak", order: 2 },
      "baby-essentials": { name_ko: "육아 용품", name_en: "Baby Essentials", name_id: "Perlengkapan Bayi", order: 3 },
      "other-baby-kids": { name_ko: "기타 유아/아동", name_en: "Other Baby & Kids Items", name_id: "Bayi & Anak Lainnya", order: 99 }
    }
  },
  // 문서 8: 오토바이
  "5B68mEyct8tpIr9Eyc8j": {
    isParent: true, name_ko: "오토바이", name_en: "Motorcycle", name_id: "Motor", order: 8,
    subCategories: {
      "motorcycle": { name_ko: "오토바이", name_en: "Motorcycle", name_id: "motor", order: 1 },
      "motor-parts": { name_ko: "부품", name_en: "Motor Parts", name_id: "Suku Cadang Motor", order: 2 },
      "motor-accessories": { name_ko: "액세서리", name_en: "Motor Accessories", name_id: "Aksesoris Motor", order: 3 },
      "other-motorcycle": { name_ko: "기타 오토바이", name_en: "Other Motorcycles Items", name_id: "Motor Lainnya", order: 99 }
    }
  },
  // 문서 99: 기타
  "BnGbVd3W9P3ztu0HBJix": {
    isParent: true, name_ko: "기타", name_en: "Other Items", name_id: "Barang Lainnya", order: 99,
    subCategories: {
      "handcrafts": { name_ko: "수공예/핸드메이드", name_en: "Handcrafts", name_id: "Kerajinan Tangan", order: 1 },
      "other-used-items": { name_ko: "기타 중고물품", name_en: "Other Used Items", name_id: "Barang Preloved Lainnya", order: 2 }
    }
  }
};

module.exports = design;
