event_inherited();

image_alpha = 0;

Health = 1.5;
angleShake = 0;

hit = function(damageAmount) {
	if(damageAmount > 1) {
		Health -= sqrt(damageAmount);
	} else {
		Health -= sqr(damageAmount);
	}
	
	angleShake += damageAmount;
	
	if(Health <= 0) {
		script_createMeatDebris(x, y, 1, 0, 0, 0, irandom_range(3, 5), 50);
		instance_destroy();
	}
}

/* I think the first kind of building I should make is actually trees, dead trees or palm trees that wave around
like they are in wind or bobbing ect and they can get wiggled by bombs and nukes and ect. They would have multiple
segments that bent together and could break apart into pieces with particles and such to show leaves being knocked
off or pieces being broken away. These pieces could then fall to the ground and maybe become debris?

segments could try and lower towards a y value of "ground" but their direction could be restricted by the segment they
connect to so if segment one is leaning 10 degrees right then segment two would be drawn super tightly to only hang say 
15 degrees different so 25 degrees and then segement three would be 25+15=40 degrees. I think this both makes the tree 
look like it's under weight and also balances the "physics" to make it seem like it's flexible and has realistic connections
perhaps the breaking conditions could be segment to segment angle differences above 20 degrees including ground. This would 
directly make the warping of the tree related to it's breaking. It would also use IK to link sections and create the pull
that let's the gravity work against something. Sounds sick. The leaves could be IK or just drawn shapes with random wag
for the degree of shake that their segment is under. Trying to avoid lag of course.. Should be easy to cull these though.

*/