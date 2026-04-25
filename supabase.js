import { createClient } from '@supabase/supabase-js'

// Pull keys from the environment variables configured in `.env`
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://your-project-id.supabase.co';
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.your-anon-key-here';

export const supabase = createClient(supabaseUrl, supabaseKey)

// In case the user hasn't set up Supabase yet, we fallback to Local Storage for testing the UI
export const isSupabaseConfigured = (supabaseUrl && !supabaseUrl.includes('your-project-id')) ? true : false;

console.log("Supabase Config:", { 
    url: supabaseUrl, 
    key: supabaseKey ? "Present (Starts with " + supabaseKey.substring(0, 10) + "...)" : "Missing",
    configured: isSupabaseConfigured 
});

// Helper mock data if Supabase isn't configured
const mockMasjids = [
  { id: '1', name: 'Makkah Masjid', area: 'Bahadurabad', fajr: '05:35', dhuhr: '13:30', asr: '17:30', maghrib: '18:50', isha: '20:45', jummah: '14:00' },
  { id: '2', name: 'Madina Masjid', area: 'Tariq Road', fajr: '05:30', dhuhr: '13:15', asr: '17:15', maghrib: '18:45', isha: '20:30', jummah: '13:30' }
];

// Helper functions to fetch and mutate data
export async function getMasjids() {
  if (!isSupabaseConfigured) {
    const local = localStorage.getItem('mockMasjids');
    if (local) return JSON.parse(local);
    localStorage.setItem('mockMasjids', JSON.stringify(mockMasjids));
    return mockMasjids;
  }

  // Actual Supabase fetch
  // Assuming a single table `masjids` containing all info as flat columns for simplicity
  const { data, error } = await supabase.from('masjids').select('*').order('area', { ascending: true });
  if (error) {
    console.error('Error fetching masjids:', error);
    return [];
  }
  return data;
}

export async function addMasjid(masjidObj) {
  if (!isSupabaseConfigured) {
    const list = await getMasjids();
    const newMasjid = { id: Date.now().toString(), ...masjidObj, fajr: '--:--', dhuhr: '--:--', asr: '--:--', maghrib: '--:--', isha: '--:--', jummah: '--:--' };
    list.push(newMasjid);
    localStorage.setItem('mockMasjids', JSON.stringify(list));
    return newMasjid;
  }

  const { data, error } = await supabase.from('masjids').insert([masjidObj]).select();
  if (error) throw error;
  return data[0];
}

export async function updateTimings(id, timingsObj) {
  if (!isSupabaseConfigured) {
    const list = await getMasjids();
    const index = list.findIndex(m => m.id === id);
    if (index > -1) {
      list[index] = { ...list[index], ...timingsObj };
      localStorage.setItem('mockMasjids', JSON.stringify(list));
    }
    return;
  }

  const { error } = await supabase.from('masjids').update(timingsObj).eq('id', id);
  if (error) throw error;
}
