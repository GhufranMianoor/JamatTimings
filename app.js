import { getMasjids, addMasjid, updateTimings } from './supabase.js';

let masjidsData = [];
let isAdmin = false;
let activeArea = 'all';

// Prayer order for determining "now"
const PRAYERS = ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha'];
const PRAYER_LABELS = { fajr: 'Fajr', dhuhr: 'Zuhr', asr: 'Asr', maghrib: 'Maghrib', isha: 'Isha', jummah: "Jumu'ah" };

// DOM elements
const userView = document.getElementById('user-view');
const adminView = document.getElementById('admin-view');
const masjidsListEl = document.getElementById('masjids-list');
const adminMasjidsListEl = document.getElementById('admin-masjids-list');
const searchInput = document.getElementById('search-input');
const areaFiltersEl = document.getElementById('area-filters');

// Nav
const navHome = document.getElementById('nav-home');
const navAdmin = document.getElementById('nav-admin');

// Admin Auth
const adminAuthPanel = document.getElementById('admin-auth-panel');
const adminDashboardPanel = document.getElementById('admin-dashboard-panel');
const openLoginModalBtn = document.getElementById('open-login-modal-btn');
const adminLoginModal = document.getElementById('admin-login-modal');
const adminPinInput = document.getElementById('admin-pin');
const submitLoginBtn = document.getElementById('submit-login-btn');
const cancelLoginBtn = document.getElementById('cancel-login-btn');
const adminLogoutBtn = document.getElementById('admin-logout-btn');

// Admin Modals & Inputs
const addMasjidFab = document.getElementById('add-masjid-fab');
const adminModalOverlay = document.getElementById('admin-modal-overlay');
const adminModal = document.getElementById('admin-modal');
const closeModalBtn = document.getElementById('close-modal-btn');
const saveMasjidBtn = document.getElementById('save-masjid-btn');
const modalMasjidName = document.getElementById('modal-masjid-name');
const editId = document.getElementById('edit-id');
const editName = document.getElementById('edit-name');
const editArea = document.getElementById('edit-area');

const timeInputs = {
  fajr: document.getElementById('edit-fajr'),
  dhuhr: document.getElementById('edit-dhuhr'),
  asr: document.getElementById('edit-asr'),
  maghrib: document.getElementById('edit-maghrib'),
  isha: document.getElementById('edit-isha'),
  jummah: document.getElementById('edit-jummah')
};

// Toast
const toast = document.getElementById('toast');
const toastMessage = document.getElementById('toast-message');

// =================== UTILS ===================
const formatTime = (t) => {
  if (!t || t === '--:--') return '--:--';
  const [h, m] = t.split(':').map(Number);
  const ampm = h >= 12 ? 'PM' : 'AM';
  return `${h % 12 || 12}:${String(m).padStart(2,'0')} ${ampm}`;
};

const formatForInput = (val) => (!val || val === '--:--') ? '' : val;

function getCurrentPrayer(masjid) {
  const now = new Date();
  const nowMins = now.getHours() * 60 + now.getMinutes();
  let currentPrayer = null;
  for (let i = PRAYERS.length - 1; i >= 0; i--) {
    const key = PRAYERS[i];
    const val = masjid[key];
    if (!val || val === '--:--') continue;
    const [h, m] = val.split(':').map(Number);
    if (nowMins >= h * 60 + m) { currentPrayer = key; break; }
  }
  return currentPrayer;
}

function getGregorianDisplay() {
  const now = new Date();
  return now.toLocaleDateString('en-GB', { day: '2-digit', month: 'short', year: 'numeric' });
}

function setDates() {
  document.getElementById('date-gregorian').textContent = getGregorianDisplay();
  document.getElementById('date-hijri').textContent = '07 Zul Qaida 1447';
}

function getUniqueAreas() {
  const areas = [...new Set(masjidsData.map(m => m.area).filter(Boolean))];
  return areas.sort();
}

function showToast(msg) {
  toastMessage.textContent = msg;
  toast.classList.remove('translate-x-full');
  setTimeout(() => {
    toast.classList.add('translate-x-full');
  }, 3000);
}

// =================== RENDERING ===================

function switchView(viewName) {
    if (viewName === 'home') {
        userView.classList.remove('hidden');
        userView.classList.add('active');
        adminView.classList.add('hidden');
        adminView.classList.remove('active');
        navHome.classList.add('active');
        navAdmin.classList.remove('active');
    } else {
        adminView.classList.remove('hidden');
        adminView.classList.add('active');
        userView.classList.add('hidden');
        userView.classList.remove('active');
        navAdmin.classList.add('active');
        navHome.classList.remove('active');
        updateAdminPanel();
    }
}

function updateAdminPanel() {
    if (isAdmin) {
        adminAuthPanel.classList.add('hidden');
        adminDashboardPanel.classList.remove('hidden');
        renderAdminMasjids();
    } else {
        adminAuthPanel.classList.remove('hidden');
        adminDashboardPanel.classList.add('hidden');
    }
}

function renderAreaChips() {
  if (!areaFiltersEl) return;
  const areas = getUniqueAreas();
  const createChipHTML = (name, val, isActive) => {
    if (isActive) {
      return `<button class="px-6 py-2.5 rounded-full bg-primary-container text-surface-container-lowest font-bold text-sm transition-all scale-95 active:opacity-80 flex-shrink-0" data-area="${val}">${name}</button>`;
    }
    return `<button class="px-6 py-2.5 rounded-full bg-surface-container-high text-on-surface-variant font-semibold text-sm hover:bg-[#ece8e0] transition-colors whitespace-nowrap flex-shrink-0" data-area="${val}">${name}</button>`;
  };

  areaFiltersEl.innerHTML = createChipHTML('All', 'all', activeArea === 'all');
  areas.forEach(area => {
    areaFiltersEl.innerHTML += createChipHTML(area, area, activeArea === area);
  });

  areaFiltersEl.querySelectorAll('button').forEach(btn => {
    btn.addEventListener('click', (e) => {
      activeArea = e.currentTarget.dataset.area;
      renderAreaChips();
      renderMasjids(searchInput.value);
    });
  });
}

function filterMasjids(query = '') {
  let list = masjidsData;
  if (activeArea !== 'all') list = list.filter(m => m.area === activeArea);
  if (query.trim()) {
    const q = query.toLowerCase();
    list = list.filter(m => 
        (m.name?.toLowerCase().includes(q)) || 
        (m.name_urdu?.includes(query)) ||
        (m.area?.toLowerCase().includes(q))
    );
  }
  return list;
}

function renderMasjids(filterQuery = '') {
  if (!masjidsListEl) return;
  masjidsListEl.innerHTML = '';
  const filtered = filterMasjids(filterQuery);

  if (filtered.length === 0) {
    masjidsListEl.innerHTML = '<div class="text-center py-10 opacity-60 text-on-surface-variant">No locations found.</div>';
    return;
  }

  filtered.forEach((m, index) => {
    const nowPrayer = getCurrentPrayer(m);
    const makeTiming = (key) => {
      const isNow = key === nowPrayer;
      const label = PRAYER_LABELS[key];
      const timeVal = formatTime(m[key]);
      if (isNow) {
        return `<div class="bg-[#E8C99A] rounded-xl p-4 flex flex-col items-center justify-center relative shadow-sm border border-[#2c1a0e]/5"><div class="absolute top-2 right-2 flex items-center gap-1"><span class="w-1.5 h-1.5 rounded-full bg-orange-600 animate-pulse"></span><span class="text-[8px] font-black text-on-tertiary-fixed uppercase">Now</span></div><span class="text-[10px] font-bold text-on-tertiary-fixed uppercase tracking-widest mb-1">${label}</span><span class="text-lg font-display font-bold text-on-tertiary-fixed">${timeVal}</span></div>`;
      }
      return `<div class="bg-surface-container-low rounded-xl p-4 flex flex-col items-center justify-center"><span class="text-[10px] font-bold text-on-surface-variant uppercase tracking-widest mb-1">${label}</span><span class="text-lg font-display font-bold text-primary-container">${timeVal}</span></div>`;
    };

    const isPrimaryCard = index === 0 && !filterQuery;
    const card = document.createElement('div');
    card.className = `rounded-2xl overflow-hidden relative transition-all duration-300 ${isPrimaryCard ? 'bg-surface-container-lowest shadow-xl' : 'bg-surface-container-low/50 border border-outline-variant/10'}`;
    if(isPrimaryCard) card.innerHTML += `<div class="absolute left-0 top-0 bottom-0 w-1.5 bg-[#795e3d]"></div>`;

    card.innerHTML += `
      <div class="p-6">
          <div class="flex justify-between items-start mb-6">
              <div>
                  <h2 class="text-xl font-display font-extrabold text-primary-container mb-1">${m.name_urdu || m.name}</h2>
                  <div class="flex gap-2 items-center">
                    <span class="inline-block px-3 py-1 rounded-full bg-surface-container text-[10px] font-bold text-on-surface-variant uppercase tracking-widest">${m.area}</span>
                    ${m.name_urdu ? `<span class="text-xs opacity-40 font-medium">${m.name}</span>` : ''}
                  </div>
              </div>
              <button class="p-2 rounded-xl hover:bg-surface-container transition-colors text-outline">
                  <span class="material-symbols-outlined pointer-events-none">near_me</span>
              </button>
          </div>
          <div class="grid grid-cols-3 gap-3">
              ${PRAYERS.map(p => makeTiming(p)).join('')}
              ${makeTiming('jummah')}
          </div>
      </div>
    `;
    masjidsListEl.appendChild(card);
  });
}

function renderAdminMasjids() {
    if (!adminMasjidsListEl) return;
    adminMasjidsListEl.innerHTML = '';
    
    masjidsData.forEach(m => {
        const card = document.createElement('div');
        card.className = "bg-surface-container-low rounded-2xl p-5 flex items-center justify-between border border-outline-variant/10 shadow-sm";
        card.innerHTML = `
            <div class="flex items-center gap-4">
                <div class="w-10 h-10 rounded-xl bg-secondary-container/50 flex items-center justify-center text-secondary">
                    <span class="material-symbols-outlined">mosque</span>
                </div>
                <div>
                    <h3 class="font-bold text-primary-container">${m.name_urdu || m.name}</h3>
                    <p class="text-[10px] text-on-surface-variant uppercase font-bold tracking-widest">${m.area}</p>
                </div>
            </div>
            <button data-id="${m.id}" class="edit-btn w-10 h-10 rounded-xl bg-surface-container-high hover:bg-secondary-container transition-colors flex items-center justify-center text-on-surface-variant hover:text-on-secondary-container">
                <span class="material-symbols-outlined">edit</span>
            </button>
        `;
        adminMasjidsListEl.appendChild(card);
    });

    adminMasjidsListEl.querySelectorAll('.edit-btn').forEach(btn => {
        btn.addEventListener('click', (e) => openEditModal(e.currentTarget.dataset.id));
    });
}

// =================== MODALS & EVENTS ===================

function openEditModal(id) {
  editId.value = id || 'new';
  modalMasjidName.textContent = id ? 'Edit Timings' : 'Add Location';
  
  if (id) {
    const m = masjidsData.find(x => x.id === id);
    editName.value = m.name || '';
    editArea.value = m.area || '';
    Object.keys(timeInputs).forEach(k => { timeInputs[k].value = formatForInput(m[k]); });
  } else {
    editName.value = '';
    editArea.value = '';
    Object.keys(timeInputs).forEach(k => { timeInputs[k].value = ''; });
  }

  adminModalOverlay.classList.remove('hidden');
  requestAnimationFrame(() => {
    adminModalOverlay.classList.remove('opacity-0');
    adminModal.classList.remove('translate-y-full');
  });
}

function closeEditModal() {
  adminModalOverlay.classList.add('opacity-0');
  adminModal.classList.add('translate-y-full');
  setTimeout(() => adminModalOverlay.classList.add('hidden'), 300);
}

function setupEventListeners() {
  searchInput.addEventListener('input', (e) => renderMasjids(e.target.value));

  navHome.addEventListener('click', () => switchView('home'));
  navAdmin.addEventListener('click', () => switchView('admin'));

  openLoginModalBtn.addEventListener('click', () => {
      adminLoginModal.classList.remove('hidden');
      requestAnimationFrame(() => {
          adminLoginModal.classList.remove('opacity-0', 'pointer-events-none');
          adminLoginModal.querySelector('div').classList.remove('scale-95');
          adminPinInput.focus();
      });
  });

  const closeLogin = () => {
    adminLoginModal.classList.add('opacity-0', 'pointer-events-none');
    adminLoginModal.querySelector('div').classList.add('scale-95');
    setTimeout(() => adminLoginModal.classList.add('hidden'), 300);
  };
  cancelLoginBtn.addEventListener('click', closeLogin);

  submitLoginBtn.addEventListener('click', () => {
    if (adminPinInput.value === '1234') {
      isAdmin = true;
      closeLogin();
      updateAdminPanel();
      showToast("Access granted.");
    } else { alert('Incorrect PIN'); }
  });

  adminLogoutBtn.addEventListener('click', () => {
      isAdmin = false;
      updateAdminPanel();
      showToast("Logged out.");
  });

  addMasjidFab.addEventListener('click', () => openEditModal(null));
  closeModalBtn.addEventListener('click', closeEditModal);
  adminModalOverlay.addEventListener('click', closeEditModal);

  saveMasjidBtn.addEventListener('click', async () => {
    const id = editId.value;
    const name = editName.value.trim();
    const area = editArea.value.trim();
    if (!name || !area) return alert('Required.');

    const timingsObj = {};
    Object.keys(timeInputs).forEach(k => { timingsObj[k] = timeInputs[k].value || '--:--'; });

    saveMasjidBtn.innerHTML = '<span class="material-symbols-outlined animate-spin">refresh</span>';
    try {
      if (id === 'new') {
        const newM = await addMasjid({ name, area, ...timingsObj });
        masjidsData.push(newM);
      } else {
        await updateTimings(id, { name, area, ...timingsObj });
        const idx = masjidsData.findIndex(x => x.id === id);
        if (idx > -1) masjidsData[idx] = { ...masjidsData[idx], name, area, ...timingsObj };
      }
      closeEditModal();
      renderAreaChips();
      renderMasjids(searchInput.value);
      renderAdminMasjids();
      showToast("Saved.");
    } catch (e) { alert('Error: ' + e.message); }
    saveMasjidBtn.innerHTML = '<span class="material-symbols-outlined">save</span> Save Changes';
  });

  // PWA logic
  const installAppBtn = document.getElementById('install-app-btn');
  const manualInstallModal = document.getElementById('manual-install-modal');
  const manualInstallInstructions = document.getElementById('manual-install-instructions');
  let deferredPrompt;

  const isStandalone = window.matchMedia('(display-mode: standalone)').matches || window.navigator.standalone;

  window.addEventListener('beforeinstallprompt', (e) => {
    e.preventDefault();
    deferredPrompt = e;
    if (installAppBtn) installAppBtn.classList.replace('opacity-0', 'opacity-100');
  });

  // Non-Chrome Fallbacks (Safari/Firefox)
  if (!isStandalone && installAppBtn) {
      const ua = navigator.userAgent.toLowerCase();
      const isMobile = /iphone|ipad|ipod|android/.test(ua);
      if (ua.includes('firefox') || (/safari/.test(ua) && !ua.includes('chrome'))) {
          installAppBtn.classList.replace('opacity-0', 'opacity-100');
      }
  }

  installAppBtn?.addEventListener('click', async () => {
    if (deferredPrompt) {
      deferredPrompt.prompt();
      const { outcome } = await deferredPrompt.userChoice;
      if (outcome === 'accepted') {
          installAppBtn.classList.replace('opacity-100', 'opacity-0');
          deferredPrompt = null;
      }
    } else if (manualInstallModal) {
      const ua = navigator.userAgent.toLowerCase();
      let inst = "To install this app, tap your browser's menu button and select <strong>Add to Home Screen</strong>.";
      if (/ipad|iphone|ipod/.test(ua)) {
          inst = "To install, tap the <strong>Share</strong> button below and select <strong>Add to Home Screen</strong>.";
      } else if (ua.includes('firefox')) {
          inst = "To install in Firefox, tap the <strong>Menu</strong> (three dots) > <strong>Install or Add to Home screen</strong>.";
      }
      manualInstallInstructions.innerHTML = inst;
      manualInstallModal.classList.remove('hidden');
      requestAnimationFrame(() => {
          manualInstallModal.classList.remove('opacity-0', 'pointer-events-none');
          manualInstallModal.querySelector('div').classList.remove('scale-95');
      });
    }
  });

  document.getElementById('close-install-modal-btn')?.addEventListener('click', () => {
      manualInstallModal.classList.add('opacity-0', 'pointer-events-none');
      setTimeout(() => manualInstallModal.classList.add('hidden'), 300);
  });
  document.getElementById('ok-install-modal-btn')?.addEventListener('click', () => {
      manualInstallModal.classList.add('opacity-0', 'pointer-events-none');
      setTimeout(() => manualInstallModal.classList.add('hidden'), 300);
  });
}

// =================== INIT ===================
async function init() {
  setDates();
  console.log("Initializing Supabase fetch...");
  try {
      masjidsData = await getMasjids();
      console.log("Masjids loaded:", masjidsData.length);
  } catch (err) {
      console.error("Failed to fetch masjids:", err);
  }
  setupEventListeners();
  renderAreaChips();
  renderMasjids();
}

window.addEventListener('DOMContentLoaded', init);
