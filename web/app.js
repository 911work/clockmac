"use strict";

const state = {
  profile: null,
  scored: [],        // [{country, probability}]
  selected: null,    // destination object
  uploads: {},       // docId -> filename
};

const $ = (sel, root = document) => root.querySelector(sel);
const $$ = (sel, root = document) => [...root.querySelectorAll(sel)];

const SCREENS = ["scan", "results", "country", "docs", "status"];

function goto(screen) {
  $$(".screen").forEach((s) => (s.hidden = s.dataset.screen !== screen));
  const idx = SCREENS.indexOf(screen);
  $$("#stepNav .step").forEach((el) => {
    const i = SCREENS.indexOf(el.dataset.step);
    el.classList.toggle("active", i === idx);
    el.classList.toggle("done", i < idx);
  });
  window.scrollTo({ top: 0, behavior: "smooth" });
}

/* ---------- Scoring ---------- */
function ageFromDob(dob) {
  const d = new Date(dob);
  return Math.floor((Date.now() - d.getTime()) / (365.25 * 864e5));
}

// Combine passport strength, destination base rate and an age factor into a
// 0..100 approval probability. Deterministic, no randomness in the score.
function scoreProfile(profile) {
  const power = PASSPORT_POWER[profile.nationality] ?? 0.45;
  const age = ageFromDob(profile.dob);
  // Sweet spot 25–40; gentle penalty outside.
  const ageFactor = age >= 25 && age <= 40 ? 1 : age < 25 ? 0.92 : Math.max(0.7, 1 - (age - 40) * 0.012);

  return DESTINATIONS.map((c) => {
    let p = c.baseApproval * (0.55 + 0.45 * power) * ageFactor;
    p = Math.max(0.18, Math.min(0.95, p));
    return { country: c, probability: Math.round(p * 100) };
  }).sort((a, b) => b.probability - a.probability);
}

function probClass(p) { return p >= 70 ? "good" : p >= 50 ? "warn" : "bad"; }
function probColor(p) {
  return p >= 70 ? "var(--good)" : p >= 50 ? "var(--warn)" : "var(--bad)";
}
const eur = (n) => "€" + n.toLocaleString("ru-RU");

/* ---------- Step 1: scan ---------- */
function initScan() {
  const input = $("#passportInput");
  const drop = $("#passportDrop");
  const natSelect = $("#natSelect");

  Object.keys(COUNTRY_NAMES).sort((a, b) =>
    COUNTRY_NAMES[a].localeCompare(COUNTRY_NAMES[b], "ru")
  ).forEach((code) => {
    const o = document.createElement("option");
    o.value = code; o.textContent = `${COUNTRY_NAMES[code]} (${code})`;
    natSelect.appendChild(o);
  });

  ["dragenter", "dragover"].forEach((ev) =>
    drop.addEventListener(ev, (e) => { e.preventDefault(); drop.classList.add("drag"); }));
  ["dragleave", "drop"].forEach((ev) =>
    drop.addEventListener(ev, () => drop.classList.remove("drag")));
  drop.addEventListener("drop", (e) => {
    e.preventDefault();
    const f = e.dataTransfer.files[0];
    if (f) handlePassport(f);
  });
  input.addEventListener("change", () => input.files[0] && handlePassport(input.files[0]));

  $("#profileForm").addEventListener("submit", (e) => {
    e.preventDefault();
    const fd = new FormData(e.target);
    state.profile = Object.fromEntries(fd.entries());
    state.scored = scoreProfile(state.profile);
    renderResults();
    goto("results");
  });
}

function handlePassport(file) {
  const drop = $("#passportDrop");
  const preview = $("#passportPreview");
  const reader = new FileReader();
  reader.onload = () => {
    preview.src = reader.result;
    preview.hidden = false;
    $("#dzInner").hidden = true;
    runOcrAnimation(drop);
  };
  reader.readAsDataURL(file);
}

// Demo "AI OCR": shows a scanning animation, then fills a plausible profile
// that the user can correct by hand. Swap fillProfile() for a real OCR call.
function runOcrAnimation(drop) {
  const overlay = document.createElement("div");
  overlay.className = "scanning";
  overlay.innerHTML = `<div class="scanline"></div><div>Распознаём данные паспорта…</div>`;
  drop.appendChild(overlay);
  setTimeout(() => {
    overlay.remove();
    const demo = DEMO_PROFILES[Math.floor(Math.random() * DEMO_PROFILES.length)];
    fillProfile(demo);
  }, 1600);
}

function fillProfile(p) {
  const form = $("#profileForm");
  form.hidden = false;
  form.surname.value = p.surname;
  form.given.value = p.given;
  form.nationality.value = p.nationality;
  form.sex.value = p.sex;
  form.dob.value = p.dob;
  form.passportNo.value = p.passportNo;
  form.expiry.value = p.expiry;
}

/* ---------- Step 2: results ---------- */
function renderResults() {
  const grid = $("#countryGrid");
  $("#resultsSub").textContent =
    `${state.profile.given} ${state.profile.surname} · ${COUNTRY_NAMES[state.profile.nationality]} · ${ageFromDob(state.profile.dob)} лет`;
  grid.innerHTML = "";
  state.scored.forEach(({ country, probability }) => {
    const card = document.createElement("div");
    card.className = "country-card";
    card.innerHTML = `
      <div class="cc-head">
        <span class="cc-flag">${country.flag}</span>
        <div><div class="cc-name">${country.name}</div><div class="cc-route">${country.route}</div></div>
      </div>
      <div class="gauge">
        <div class="gauge-num" style="color:${probColor(probability)}">${probability}%</div>
        <div class="bar"><i style="width:${probability}%;background:${probColor(probability)}"></i></div>
      </div>
      <div class="cc-meta">
        <span>ЗП ≈ ${eur(country.avgSalary)}/мес</span>
        <span>Срок: ${country.processingWeeks}</span>
      </div>`;
    card.addEventListener("click", () => selectCountry(country));
    grid.appendChild(card);
  });
}

/* ---------- Step 3: country detail ---------- */
function selectCountry(country) {
  state.selected = country;
  const score = state.scored.find((s) => s.country.code === country.code).probability;
  const f = country.fees;
  const total = f.gov + f.service + f.legal + f.insurance;
  const disposable = country.avgSalary - country.costOfLiving;

  $("#countryDetail").innerHTML = `
    <div class="detail-head">
      <span class="cc-flag">${country.flag}</span>
      <div><h2>${country.name}</h2><div class="cc-route">${country.route} · срок ${country.processingWeeks}</div></div>
    </div>
    <div class="stat-grid">
      <div class="stat"><div class="k">Шанс одобрения</div><div class="v" style="color:${probColor(score)}">${score}%</div></div>
      <div class="stat"><div class="k">Средняя ЗП (нетто)</div><div class="v">${eur(country.avgSalary)}<small>/мес</small></div></div>
      <div class="stat"><div class="k">Стоимость жизни</div><div class="v">${eur(country.costOfLiving)}<small>/мес</small></div></div>
      <div class="stat"><div class="k">Остаётся в месяц</div><div class="v" style="color:${disposable>0?'var(--good)':'var(--bad)'}">${eur(disposable)}</div></div>
    </div>
    <div class="fees">
      <h3>Стоимость энрола со всеми комиссиями</h3>
      <div class="fee-row"><span>Госпошлина <span class="muted">/ консульский сбор</span></span><span>${eur(f.gov)}</span></div>
      <div class="fee-row"><span>Сервисный сбор центра</span><span>${eur(f.service)}</span></div>
      <div class="fee-row"><span>Юридическое сопровождение</span><span>${eur(f.legal)}</span></div>
      <div class="fee-row"><span>Страховка (год)</span><span>${eur(f.insurance)}</span></div>
      <div class="fee-row total"><span>Итого</span><span>${eur(total)}</span></div>
    </div>
    <button class="btn primary block" id="chooseCountry">Выбрать ${country.name} и загрузить документы →</button>`;

  $("#chooseCountry").addEventListener("click", () => { state.uploads = {}; renderDocs(); goto("docs"); });
  goto("country");
}

/* ---------- Step 4: docs ---------- */
function renderDocs() {
  const c = state.selected;
  $("#docsTitle").textContent = `Документы для ${c.name}`;
  const list = $("#docsList");
  list.innerHTML = "";

  c.docs.forEach((doc) => {
    const item = document.createElement("label");
    item.className = "doc-item";
    item.innerHTML = `
      <input type="file" hidden />
      <div class="doc-icon">📄</div>
      <div class="doc-main">
        <div class="doc-title">${doc.title}</div>
        <div class="doc-hint">${doc.hint}</div>
        <div class="doc-file"></div>
      </div>
      <span class="doc-action">Загрузить</span>`;
    const input = $("input", item);
    const setFile = (file) => {
      if (!file) return;
      state.uploads[doc.id] = file.name;
      item.classList.add("done");
      $(".doc-file", item).textContent = "✓ " + file.name;
      $(".doc-action", item).textContent = "Заменить";
      $(".doc-icon", item).textContent = "🗎";
      updateDocsProgress();
    };
    input.addEventListener("change", () => setFile(input.files[0]));
    ["dragenter", "dragover"].forEach((ev) =>
      item.addEventListener(ev, (e) => { e.preventDefault(); item.classList.add("drag"); }));
    ["dragleave", "drop"].forEach((ev) =>
      item.addEventListener(ev, () => item.classList.remove("drag")));
    item.addEventListener("drop", (e) => { e.preventDefault(); setFile(e.dataTransfer.files[0]); });
    list.appendChild(item);
  });
  updateDocsProgress();

  $("#submitBtn").onclick = submitApplication;
}

function updateDocsProgress() {
  const total = state.selected.docs.length;
  const done = Object.keys(state.uploads).length;
  $("#docsProgress").style.width = (done / total) * 100 + "%";
  const btn = $("#submitBtn");
  btn.disabled = done < total;
  btn.textContent = done < total
    ? `Загружено ${done} из ${total} документов`
    : "Отправить заявку на проверку";
}

/* ---------- Step 5: status ---------- */
function submitApplication() {
  const ref = "VS-" + state.selected.code + "-" + Date.now().toString(36).toUpperCase().slice(-6);
  $("#appRef").textContent = ref;
  $("#statusSub").textContent =
    `${state.selected.flag} ${state.selected.name} · ${state.selected.route}. Мы проверяем комплектность и качество документов.`;
  const steps = [
    "Документы получены",
    "Проверка комплектности",
    "Проверка экспертом",
    "Готово к подаче",
  ];
  const tl = $("#statusTimeline");
  tl.innerHTML = steps.map((s, i) =>
    `<li data-i="${i}"><span class="dot"></span><span>${s}</span></li>`).join("");
  goto("status");

  let i = 0;
  const lis = $$("#statusTimeline li");
  const tick = () => {
    if (i > 0) lis[i - 1].classList.replace("active", "done");
    if (i < lis.length) {
      lis[i].classList.add("active");
      i++;
      setTimeout(tick, i === lis.length ? 1400 : 1300);
    } else {
      lis[lis.length - 1].classList.replace("active", "done");
      $("#statusSpinner").classList.add("done");
      $("#statusSpinner").textContent = "✓";
      $("#statusSpinner").style.cssText += "font-size:32px;color:var(--good);display:flex;align-items:center;justify-content:center;";
      $("#statusTitle").textContent = "Заявка принята на проверку";
    }
  };
  tick();
}

/* ---------- init ---------- */
document.addEventListener("click", (e) => {
  const back = e.target.closest(".link-back");
  if (back) goto(back.dataset.goto);
});
initScan();
goto("scan");
