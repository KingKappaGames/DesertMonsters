/// @func draw_arc(x,y,radius,anglefrom,angleto,[precision])
/// @desc Draws a circular line around the given center, with the given radius and between given angles.
/// @arg {Real} x               The x coordinate of the arc center.
/// @arg {Real} y               The y coordinate of the arc center.
/// @arg {Real} radius          The radius of the arc around the center.
/// @arg {Real} anglefrom       The starting angle of the arc.
/// @arg {Real} angleto         The ending angle of the arc.
/// @arg {Real} [precision]     The precision of the circle the arc is a part of.
function draw_arc(_x, _y, _radius, _anglefrom, _angleto, _precision = 24) {
    // static functions    
    static get_segment_position = function(_angle, _segment_angle) {
        _angle = _angle - floor(_angle / _segment_angle) * _segment_angle;
        if (_angle == 0)
            return 0;
        
        var _yfrom = dsin(_angle);
        var _yto = dsin(_angle - _segment_angle);
        return _yfrom / (_yfrom - _yto);
    }
    
    static draw_circle_vertex = function(_x, _y, _radius, _angle) {
        draw_vertex(_x + lengthdir_x(_radius, _angle), _y + lengthdir_y(_radius, _angle));
    }
    
    static draw_midsegment_vertex = function(_x, _y, _radius, _angle1, _angle2, _amount) {
        if (_amount == 0) {
            draw_circle_vertex(_x, _y, _radius, _angle1);
            return;
        }
        
        var _x1 = _x + lengthdir_x(_radius, _angle1);
        var _y1 = _y + lengthdir_y(_radius, _angle1);
        var _x2 = _x + lengthdir_x(_radius, _angle2);
        var _y2 = _y + lengthdir_y(_radius, _angle2);
        draw_vertex(lerp(_x1, _x2, _amount), lerp(_y1, _y2, _amount));
    }
    
    static normalize_angles = function(_anglefrom, _angleto) {
        static result = [0, 0];
        
        result[0] = min(_anglefrom, _angleto);
        result[1] = max(_anglefrom, _angleto);
        
        if (result[0] + 360 < result[1]) {
            result[0] = 0;
            result[1] = 360;
        }
        
        return result;
    }
    
    static draw_arc_vertices = method(static_get(draw_arc), function(_x, _y, _radius, _anglefrom, _angleto, _precision, _close) {
        var _segment_angle = 360 / _precision;
        var _start_amount = get_segment_position(_anglefrom, _segment_angle);
        var _end_amount = get_segment_position(_angleto, _segment_angle);
        var _start_index = floor(_anglefrom / _segment_angle);
        var _end_index = floor(_angleto / _segment_angle);
        
        // starting vertex
        draw_midsegment_vertex(_x, _y, _radius, _start_index * _segment_angle, (_start_index + 1) * _segment_angle, _start_amount);
        
        // mid-to-end vertices
        for (var i = _start_index + 1; i <= _end_index; i++) {
            draw_circle_vertex(_x, _y, _radius, i * _segment_angle);
        }
        
        // end midsegment, if any
        if (_end_amount > 0)
            draw_midsegment_vertex(_x, _y, _radius, _end_index * _segment_angle, (_end_index + 1) * _segment_angle, _end_amount);
        
        // move back to starting vertex if needed
        if (_close)
            draw_midsegment_vertex(_x, _y, _radius, _start_index * _segment_angle, (_start_index + 1) * _segment_angle, _start_amount);
    });
    
    // normalise the angles for easier processing
    var _normangles = normalize_angles(_anglefrom, _angleto);
    _anglefrom = _normangles[0];
    _angleto = _normangles[1];
    if (_anglefrom == _angleto)
        return;
    
    // draw the actual arc
    draw_primitive_begin(pr_linestrip);
    draw_arc_vertices(_x, _y, _radius, _anglefrom, _angleto, _precision, false);
    draw_primitive_end();
}