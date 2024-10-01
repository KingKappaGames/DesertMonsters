if (live_call()) return live_result;

bombsRemaining = 99;
accuracy = 0; // 0 to radius (ish)

xChange = 0;
yChange = 0;

bombTimerMax = 144;
bombTimerCurrent = 0;

bombingDelay = 999;

bombType = obj_mortar;

bombingType = 0; // 0 for path, 1 for targeted fire

despawnTimer = 720;