//shader_set(shd_depth);

var _texture = surface_get_texture(getFogSurf());

draw_primitive_begin_texture(pr_trianglestrip, _texture);

var _w = camera_get_view_width(view_camera[0]);
var _h = camera_get_view_height(view_camera[0]);

draw_vertex_texture(_w * .75, 0, 0, 0);
draw_vertex_texture(_w, 0, 1, 0);
draw_vertex_texture(_w * .75, _h * .25, 0, 1);
draw_vertex_texture(_w, _h * .25, 1, 1);

draw_primitive_end();



shader_set(shd_alphaToWhite);

draw_primitive_begin_texture(pr_trianglestrip, _texture);

draw_vertex_texture(_w * .5, 0, 0, 0);
draw_vertex_texture(_w * .75, 0, 1, 0);
draw_vertex_texture(_w * .5, _h * .25, 0, 1);
draw_vertex_texture(_w * .75, _h * .25, 1, 1);

draw_primitive_end();

shader_reset();

//shader_reset();