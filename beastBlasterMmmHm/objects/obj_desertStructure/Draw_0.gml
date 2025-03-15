draw_sprite_ext(spr_desertStructure, round(dsin(current_time)), x, y, 1, 2, image_angle, c_white, image_alpha);

//x += 10000;
//var _nearest = instance_nearest(x - 10000, y, obj_desertStructure);
//x -= 10000;

//if(_nearest != id) {
//	var _dist = point_distance(x, y, _nearest.x, _nearest.y);
//	var _dir = point_direction(x, y, _nearest.x, _nearest.y);
//	draw_arc((x + _nearest.x) / 2, (y + _nearest.y) / 2, _dist, _dir + sign(angle_difference(270, _dir)) * 20, _dir + 180 + sign(angle_difference(270, _dir + 180)) * 20);
//}