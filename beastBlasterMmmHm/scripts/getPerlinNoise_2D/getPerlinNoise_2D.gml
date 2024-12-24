function getPerlinNoise_2D(xx, yy, range) {
	var chunkSize = 128; // the size of the sections of different terrain roughly (times valueRange too)
	var noise = 0;
	range = range;
	
	var index_x = 0;
	var index_y = 0;
	var t_x = 0;
	var t_y = 0;
	var r_00 = 0;
	var r_01 = 0; // faster to preload and hold then reallocate
	var r_10 = 0;
	var r_11 = 0;
	var r_0 = 0;
	var r_1 = 0;
	
	while(chunkSize > 1){
	    index_x = xx div chunkSize;
	    index_y = yy div chunkSize;
    
	    t_x = (xx % chunkSize) / chunkSize;
	    t_y = (yy % chunkSize) / chunkSize;
    
		random_set_seed(seed + index_x + index_y * 65536);
		r_00 = irandom_range(0,range);
		
		random_set_seed(seed + index_x + (index_y+1) * 65536);
	    r_01 = irandom_range(0,range);
		
		random_set_seed(seed + (index_x+1) + index_y * 65536);
	    r_10 = irandom_range(0,range);
		
		random_set_seed(seed + (index_x+1) + (index_y+1) * 65536);
	    r_11 = irandom_range(0,range);
		
		
    
	    r_0 = lerp(r_00,r_01,t_y);
	    r_1 = lerp(r_10,r_11,t_y);
    
	    noise += lerp(r_0,r_1,t_x);
    
	    chunkSize = chunkSize div 8;
	    range = range div 8;
	    range = max(1,range);
	}
	
	return noise;
}
