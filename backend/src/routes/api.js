require('dotenv').config({ path: require('path').join(__dirname, '../../.env') });
const express = require('express');
const router = express.Router();
const { createClient } = require('@supabase/supabase-js');
const { awardKarma, getUserProfile, getKarmaLevel } = require('../services/karmaService');

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseServiceKey = process.env.SUPABASE_KEY;

console.log('API Route - SUPABASE_URL:', supabaseUrl ? '[SET]' : '[NOT SET]');
console.log('API Route - SUPABASE_KEY:', supabaseServiceKey ? '[SET]' : '[NOT SET]');

const supabase = createClient(supabaseUrl, supabaseServiceKey);

router.post('/complete-task', async (req, res) => {
  const { requestId, helperId } = req.body;

  if (!requestId || !helperId) {
    return res.status(400).json({ error: 'Missing required fields: requestId, helperId' });
  }

  try {
    const { data: request, error: requestError } = await supabase
      .from('help_requests')
      .select('*, profiles:user_id(karma_points)')
      .eq('id', requestId)
      .single();

    if (requestError || !request) {
      return res.status(404).json({ error: 'Request not found' });
    }

    if (request.status === 'completed') {
      return res.status(400).json({ error: 'Task already completed' });
    }

    if (request.helper_id !== helperId && request.user_id !== helperId) {
      return res.status(403).json({ error: 'Not authorized to complete this task' });
    }

    const karmaResult = await awardKarma(helperId, 50);
    
    if (!karmaResult.success) {
      throw new Error(karmaResult.error);
    }

    const { error: updateError } = await supabase
      .from('help_requests')
      .update({ 
        status: 'completed',
        completed_at: new Date().toISOString()
      })
      .eq('id', requestId);

    if (updateError) throw updateError;

    const updatedProfile = await getUserProfile(helperId);

    res.json({
      success: true,
      message: 'Task completed successfully!',
      karmaAwarded: 50,
      totalKarma: updatedProfile.data?.karma_points || 0,
      karmaLevel: getKarmaLevel(updatedProfile.data?.karma_points || 0)
    });

  } catch (error) {
    console.error('Complete task error:', error);
    res.status(500).json({ error: error.message || 'Failed to complete task' });
  }
});

router.get('/user/:userId', async (req, res) => {
  const { userId } = req.params;

  try {
    const result = await getUserProfile(userId);
    
    if (!result.success) {
      return res.status(404).json({ error: result.error });
    }

    res.json({
      ...result.data,
      karmaLevel: getKarmaLevel(result.data.karma_points || 0)
    });

  } catch (error) {
    console.error('Get user error:', error);
    res.status(500).json({ error: error.message });
  }
});

router.get('/karma-level/:points', (req, res) => {
  const points = parseInt(req.params.points) || 0;
  res.json({
    level: getKarmaLevel(points),
    points: points
  });
});

router.post('/karma/award', async (req, res) => {
  const { targetUserId, amount, reason } = req.body;

  if (!targetUserId || !amount) {
    return res.status(400).json({ error: 'Missing required fields' });
  }

  try {
    const result = await awardKarma(targetUserId, amount);
    
    if (!result.success) {
      throw new Error(result.error);
    }

    res.json({
      success: true,
      message: reason || `Awarded ${amount} karma points`,
      pointsAwarded: amount
    });

  } catch (error) {
    console.error('Award karma error:', error);
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
