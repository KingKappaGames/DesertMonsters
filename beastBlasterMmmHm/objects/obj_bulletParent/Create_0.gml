//if (live_call()) return live_result;

sys = global.particleSystem;
manager = global.manager;

sbDustErupt = global.sandBurstDustErupt;
sbDust = global.sandBurstDust;
sbDustFloat = global.sandBurstDustFloat;
sbHaze = global.sandBurstHaze;
shimmer = global.shimmer;
debris = global.darkDebris;
nukeShimmer = global.nuclearShimmer;
shockwaveLead = global.shockwaveLead;
darkout = global.darkout;
bloodSpray = global.bloodSpray;
smokeTrail = global.smokeTrail;
smokeHaze = global.smokeHaze;
smokingClods = global.eruptClods;

bulletDamage = 1 + irandom(2);
bulletSize = 2 + irandom(2);

bulletLevel = 1;

hitIds = ds_list_create();

drawOnNextFrame = false; //TODO not working... how do I draw the debris to the ground on the same frame it's deleting if it doesn't draw it's draw? Maybe it does? It seems like it's not doing shit tbh, destroyed or not.

hit = function() {
	
}