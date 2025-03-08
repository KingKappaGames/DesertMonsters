//WIP DO NOT DELETE - REGEN ONLY PART OF GRID NECESSARY - PERFORMANCE UP ONE MILLION BILLION PERCENT 
///@desc The limits represent the edge of the existing grid (in PIXELS!) to draw in so if you moved to the left 50 and down 50 the grid would have a rightLimit of 50 and bottomLimit of 50 to represent those sections needing drawing!
function generate(leftMargin = 0, topMargin = 0, rightMargin = 0, bottomMargin = 0) {
	updatePerlin = true;
	
	leftMargin = floor(leftMargin / blockSize);
	topMargin = floor(topMargin / blockSize);
	
	var _widthRightMargin = floor(rightMargin / blockSize); // non flipped width of right and bottom, so 3 border would stay 3 instead of becoming width - 3 (convinience)
	var _widthBottomMargin = floor(bottomMargin / blockSize);
	
	rightMargin = width - _widthRightMargin;
	bottomMargin = height - _widthBottomMargin; // flip right and bottom Margins
	
	#region copy the existing grid to offset position to start generation
	ds_grid_set_grid_region(grid, grid, _widthRightMargin, _widthBottomMargin, (width - leftMargin) - 1, (height - topMargin) - 1, leftMargin, topMargin);
	#endregion
	
	var _beginX = (_widthRightMargin == 0) ? 0 : rightMargin;
	var _beginY = (_widthBottomMargin == 0) ? 0 : bottomMargin; // terniary setting of beginnings and endings, (terniary's basically just a if() then A else B compressed into a statement)
	var _endX = (leftMargin == 0) ? width : leftMargin; // either stop at the edge or at the margin depending on whether you're moving towards it or away (based on index++ as your direction...)
	var _endY = (topMargin == 0) ? height : topMargin;
	
	debugWidth = (_endX - _beginX) * blockSize;
	debugHeight = (_endY - _beginY) * blockSize;
	
	if(leftMargin != 0 || rightMargin != width) { // any horizontal (draw whole vertical slice then partial horizontals (if aplicable))
		for(var i = _beginX; i < _endX; i++) { // start at flipped margin position since you only need everything else to move to
		    for(var j = 0; j < height; j++) {
		        var _zz = getPerlinNoise_2D(i + updateLastX / blockSize, j + updateLastY / blockSize, valueRange);
			
		        ds_grid_set(grid, i, j, _zz); // vertical slice
				
				random_set_seed((i * blockSize + updateLastX) * 65536 + j * blockSize + updateLastY);
				
				var _heightVal = 1 - (_zz / valueRange) * 2.5; // range of .25 - 1 (_zz is cut below .3 here so...)
				if(_zz < valueRange * .3) {
					var _rand = random(1);
					
					if(_rand > .999) {
						instance_create_layer(i * blockSize + updateLastX, j * blockSize + updateLastY, "Instances", obj_palmTree);
					} else if(_rand < _heightVal) {
						repeat(2) {
							var _grass = instance_create_layer(i * blockSize + updateLastX + irandom_range(-blockSize, blockSize), j * blockSize + updateLastY + irandom_range(-blockSize, blockSize), "Instances", obj_grassBlade);
		
							_grass.height = random_range(_heightVal / 2 + .1, _heightVal) * sprite_get_height(_grass.sprite_index);
							if(_heightVal > .8) {
								_grass.image_blend = #DBE7FF;
							} else if(_heightVal > .6) {
								_grass.image_blend = #dfffdf;
							} else if(_heightVal > .4) {
								_grass.image_blend = #D0FFC1;
							} else {
								_grass.image_blend = #FFC6C3;
							}
						}
					}
				}
		    }
		}
		
		if(topMargin != 0 || bottomMargin != height) {
			for(var i = leftMargin; i < rightMargin; i++) { // start at flipped margin position since you only need everything else to move to
			    for(var j = _beginY; j < _endY; j++) {
			        var _zz = getPerlinNoise_2D(i + updateLastX / blockSize, j + updateLastY / blockSize, valueRange);
			
			        ds_grid_set(grid, i, j, _zz); // horizontal strip UP TO vertical strip
					
					random_set_seed((i * blockSize + updateLastX) * 65536 + j * blockSize + updateLastY);
					
					var _heightVal = 1 - (_zz / valueRange) * 2; // range of .4 - 1 (_zz is cut below .3 here so...)
					if(_zz < valueRange * .3) {
						var _rand = random(1);
					
						if(_rand > .999) {
							instance_create_layer(i * blockSize + updateLastX, j * blockSize + updateLastY, "Instances", obj_palmTree);
						} else if(_rand < _heightVal) {
							//repeat(2) {
								var _grass = instance_create_layer(i * blockSize + updateLastX + irandom_range(-blockSize, blockSize), j * blockSize + updateLastY + irandom_range(-blockSize, blockSize), "Instances", obj_grassBlade);
		
								_grass.height = random_range(_heightVal / 2 + .1, _heightVal) * sprite_get_height(_grass.sprite_index);
								if(_heightVal > .8) {
									_grass.image_blend = #158a6e;
								} else if(_heightVal > .6) {
									_grass.image_blend = #19bf4e;
								} else if(_heightVal > .4) {
									_grass.image_blend = #badc60;
								} else {
									_grass.image_blend = #a12c1d;
								}
							//}
						}
					}
			    }
			}
		}
	} else { // no horizontal, only draw horizontal stips if applicable
		for(var i = 0; i < width; i++) { // start at flipped margin position since you only need everything else to move to
		    for(var j = _beginY; j < _endY; j++) {
		        var _zz = getPerlinNoise_2D(i + updateLastX / blockSize, j + updateLastY / blockSize, valueRange);
			
		        ds_grid_set(grid, i, j, _zz); // only horizontal stip at bottom or top
				
				random_set_seed((i * blockSize + updateLastX) * 65536 + j * blockSize + updateLastY);
				
				var _heightVal = 1 - (_zz / valueRange) * 2; // range of .4 - 1 (_zz is cut below .3 here so...)
				if(_zz < valueRange * .3) {
					var _rand = random(1);
					
					if(_rand > .999) {
						instance_create_layer(i * blockSize + updateLastX, j * blockSize + updateLastY, "Instances", obj_palmTree);
					} else if(_rand < sqr(_heightVal)) {
						//repeat(2) {
							var _grass = instance_create_layer(i * blockSize + updateLastX + irandom_range(-blockSize, blockSize), j * blockSize + updateLastY + irandom_range(-blockSize, blockSize), "Instances", obj_grassBlade);
		
							_grass.height = random_range(_heightVal / 2 + .1, _heightVal) * sprite_get_height(_grass.sprite_index);
							if(_heightVal > .8) {
								_grass.image_blend = #158a6e;
							} else if(_heightVal > .6) {
								_grass.image_blend = #19bf4e;
							} else if(_heightVal > .4) {
								_grass.image_blend = #badc60;
							} else {
								_grass.image_blend = #a12c1d;
							}
						//}
					}
				}
		    }
		}
	}
}




/* info dump records (no code)

84 fps non yyc with 32 block size and 6 buffer
(new 500! This is what I mean by it's mostly other things, with vm slowing down more with math this shows the efficiency of the perlin part, 8x improvement!)

360 fps yyc with 32 block size and 6 buffer (holy moly yyc chad) 
(new 1200! ( a lot of the slow down is draw and other objects, running 4 block size 8 buffer this did 160 fps which is unthinkable with prev version)