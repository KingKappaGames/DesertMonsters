if (live_call()) return live_result;

var _rotate = (current_time % 1440) / 4;
var _speed = point_distance(0, 0, xChange, yChange);

var _sin1 = clamp(dsin(_rotate)        * _speed * 30, -10, 10);
var _sin2 = clamp(dsin(_rotate + 60)   * _speed * 30, -10, 10);
var _sin3 = clamp(dsin(_rotate + 120)  * _speed * 30, -10, 10);
var _sin4 = clamp(dsin(_rotate +  180) * _speed * 30, -10, 10);

draw_rectangle(x - 40, y + 20 - _sin1, x - 20, y - _sin1, false);
draw_rectangle(x - 20, y + 20 - _sin2, x, y - _sin2, false);
draw_rectangle(x + 0, y + 20 - _sin3, x + 20, y - _sin3, false);
draw_rectangle(x + 20, y + 20 - _sin4, x + 40, y - _sin4, false);
draw_line(x + 40, y + 20 - _sin4, x + 40, y - _sin4 - 40);

//draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true)