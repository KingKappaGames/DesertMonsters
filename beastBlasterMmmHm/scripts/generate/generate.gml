//WIP DO NOT DELETE - REGEN ONLY PART OF GRID NECESSARY - PERFORMANCE UP ONE MILLION BILLION PERCENT 
///@desc The limits represent the edge of the existing grid (in PIXELS!) to draw in so if you moved to the left 50 and down 50 the grid would have a rightLimit of 50 and bottomLimit of 50 to represent those sections needing drawing!
function generate(leftMargin = 0, topMargin = 0, rightMargin = 0, bottomMargin = 0) {
	live_auto_call
	
	//msg("_______________________");
	//msg($"Left margin: {leftMargin}");
	//msg($"Right margin: {rightMargin}");
	//msg($"Top margin: {topMargin}");
	//msg($"Bottom margin: {bottomMargin}");
	//msg("########################");
	
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
		//msg("$$$$$");
		//msg("horizonta lMovement dectectado");
		for(var i = _beginX; i < _endX; i++) { // start at flipped margin position since you only need everything else to move to
		    for(var j = 0; j < height; j++) {
		        var _zz = getPerlinNoise_2D(i + updateLastX / blockSize, j + updateLastY / blockSize, valueRange);
			
		        ds_grid_set(grid, i, j, _zz); // vertical slice
		    }
		}
		
		if(topMargin != 0 || bottomMargin != height) {
			//msg("$$$$$");
			//msg("vertical Movement dectectado TOO TOO TOO TOO");
			for(var i = leftMargin; i < rightMargin; i++) { // start at flipped margin position since you only need everything else to move to
			    for(var j = _beginY; j < _endY; j++) {
			        var _zz = getPerlinNoise_2D(i + updateLastX / blockSize, j + updateLastY / blockSize, valueRange);
			
			        ds_grid_set(grid, i, j, _zz); // horizontal strip UP TO vertical strip
			    }
			}
		}
		
		//msg($"Width: {width}");
		//msg($"Height: {height}");
		//msg($"Begin X: {_beginX}");
		//msg($"Begin Y: {_beginY}");
		//msg($"End X: {_endX}");
		//msg($"End Y: {_endY}");
	} else { // no horizontal, only draw horizontal stips if applicable
		//msg("$$$$$");
		//msg("vertical Movement dectectado");
		for(var i = 0; i < width; i++) { // start at flipped margin position since you only need everything else to move to
		    for(var j = _beginY; j < _endY; j++) {
		        var _zz = getPerlinNoise_2D(i + updateLastX / blockSize, j + updateLastY / blockSize, valueRange);
			
		        ds_grid_set(grid, i, j, _zz); // only horizontal stip at bottom or top
		    }
		}
		
		//msg($"Width: {width}");
		//msg($"Height: {height}");
		//msg($"Begin X: {_beginX}");
		//msg($"Begin Y: {_beginY}");
		//msg($"End X: {_endX}");
		//msg($"End Y: {_endY}");
	}
}




/* info dump records (no code)

84 fps non yyc with 32 block size and 6 buffer
(new 500! This is what I mean by it's mostly other things, with vm slowing down more with math this shows the efficiency of the perlin part, 8x improvement!)

360 fps yyc with 32 block size and 6 buffer (holy moly yyc chad) 
(new 1200! ( a lot of the slow down is draw and other objects, running 4 block size 8 buffer this did 160 fps which is unthinkable with prev version)