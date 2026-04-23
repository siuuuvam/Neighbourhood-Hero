require('dotenv').config();
require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });
const { createClient } = require('@supabase/supabase-js');

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseKey = process.env.SUPABASE_KEY;

if (!supabaseUrl || !supabaseKey) {
  console.error('Missing Supabase credentials in .env file');
  console.log('SUPABASE_URL:', supabaseUrl);
  console.log('SUPABASE_KEY:', supabaseKey ? '[SET]' : '[NOT SET]');
}

const supabase = createClient(supabaseUrl, supabaseKey);

const awardKarma = async (targetUserId, amount) => {
  try {
    const { data, error } = await supabase.rpc('add_karma', {
      target_user_id: targetUserId,
      amount: amount
    });

    if (error) throw error;

    return { success: true, message: `Awarded ${amount} karma to ${targetUserId}` };
  } catch (error) {
    console.error('Karma Service Error:', error);
    return { success: false, error: error.message };
  }
};

const getUserProfile = async (userId) => {
  try {
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .single();

    if (error) throw error;
    return { success: true, data };
  } catch (error) {
    console.error('Profile Fetch Error:', error);
    return { success: false, error: error.message };
  }
};

const getKarmaLevel = (points) => {
  if (points >= 500) return 'Neighborhood Legend';
  if (points >= 200) return 'Neighborhood Hero';
  if (points >= 50) return 'Active Neighbor';
  return 'New Neighbor';
};

const getKarmaProgress = (points) => {
  const levels = [
    { name: 'New Neighbor', threshold: 0 },
    { name: 'Active Neighbor', threshold: 50 },
    { name: 'Neighborhood Hero', threshold: 200 },
    { name: 'Neighborhood Legend', threshold: 500 }
  ];

  let currentLevel = levels[0];
  let nextLevel = levels[1];

  for (let i = 0; i < levels.length; i++) {
    if (points >= levels[i].threshold) {
      currentLevel = levels[i];
      nextLevel = levels[i + 1] || null;
    }
  }

  if (!nextLevel) {
    return {
      currentLevel: currentLevel.name,
      nextLevel: null,
      progress: 100,
      pointsToNext: 0
    };
  }

  const pointsInLevel = points - currentLevel.threshold;
  const pointsNeeded = nextLevel.threshold - currentLevel.threshold;
  const progress = Math.round((pointsInLevel / pointsNeeded) * 100);

  return {
    currentLevel: currentLevel.name,
    nextLevel: nextLevel.name,
    progress: progress,
    pointsToNext: nextLevel.threshold - points
  };
};

module.exports = {
  awardKarma,
  getUserProfile,
  getKarmaLevel,
  getKarmaProgress
};
