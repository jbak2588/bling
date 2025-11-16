const url = 'http://127.0.0.1:5001/blingbling-app/asia-southeast2/generatefinalreport';
const payload = {
  data: {
    imageUrls: { initial: [], guided: {} },
    confirmedProductName: 'Smoke Test Item',
    categoryName: 'SmokeTest',
    locale: 'en'
  }
};

(async () => {
  try {
    const resp = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });
    const text = await resp.text();
    console.log('HTTP', resp.status);
    try {
      console.log(JSON.stringify(JSON.parse(text), null, 2));
    } catch (e) {
      console.log('RAW RESPONSE:', text);
    }
  } catch (e) {
    console.error('REQUEST ERROR:', e);
    process.exitCode = 2;
  }
})();
