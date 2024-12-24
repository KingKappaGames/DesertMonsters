function randomSeed(range, num, numAlt = 0) {
	if(numAlt != 0) {
		num = num + numAlt * 65536;
	}

	var seed = obj_generator.seed + num;

	random_set_seed(seed);
	return round(irandom_range(0,range));
}
