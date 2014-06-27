chamber_internal_radius=100;
chamber_height=50;


chamber_external_radius=chamber_internal_radius*2;
chamber_internal_radius_top=chamber_internal_radius*1.5;
chamber_wall_thickness=chamber_external_radius-chamber_internal_radius_top;
chamber_wall_middle_radius=chamber_internal_radius+(1.5*chamber_wall_thickness);

box_length=chamber_external_radius*2;
pipe_radius=3;
oring_xs_radius=1.5;

h_in=1.5*chamber_height/4;

fn_resolution=100; //quality vs render time

module shell2() {
translate([0,-1*chamber_external_radius,0]){
cube([box_length,chamber_external_radius*2,chamber_height]);
}
cylinder(h=chamber_height, r1=chamber_external_radius,  r2=chamber_external_radius,$fn=fn_resolution*3);

}

module housing_hole(){
translate([chamber_external_radius,chamber_wall_thickness-chamber_external_radius,2.5]){
cube([box_length+10,chamber_internal_radius_top*2,chamber_height+5]);
}
}

module pipe_control_cutout() {
offset=5;
cutout_y=offset+chamber_wall_thickness/2;
translate([chamber_wall_middle_radius*1.5,chamber_wall_middle_radius-cutout_y+pipe_radius,2.5]){
cube([100,cutout_y+offset*2,chamber_height+5]);
}	
}

module pipe_control_surface() {
offset=10;
cutout_y=offset+chamber_wall_thickness/2;
translate([chamber_wall_middle_radius*1.5,chamber_wall_middle_radius+offset,chamber_height+0.8*h_in]){
rotate([90,0,0]) {
cylinder(r=50,h=cutout_y+offset,$fn=fn_resolution);
}
}	
}

//union(){
//pipe_control_cutout();
//pipe_control_surface();
//}

*pipe_control_cutout();
module chamber_hole(){
translate([0,0,-1]){
cylinder(h=chamber_height+2, r1=chamber_internal_radius,  r2=chamber_internal_radius_top,$fn=fn_resolution*3);}
}


module shell_w_housing(){
difference(){
shell2();
housing_hole();
}
}

module shell_w_housing_w_chamber(){
difference(){
shell_w_housing();
chamber_hole();
}
}

difference(){
shell_w_housing_w_chamber();
chamber_in_out_holes();
}


module lpipe() {

	translate([0,chamber_wall_middle_radius,h_in]) {
			rotate([0,90,0]) {
				cylinder(h=box_length+2,r=pipe_radius,$fn=fn_resolution);
			}
		translate([0,1,0]) {
			rotate([90,0,0]) {
				cylinder(h=chamber_wall_middle_radius,r=pipe_radius,$fn=fn_resolution);
			}
		}
	}
}

module lid_seal() {
	rotate_extrude(convexity = 10,$fn=100)
	translate([chamber_wall_middle_radius,chamber_height, 0])
	circle(r = oring_xs_radius, $fn=100);
}

module zpipe() {
	h_out=1.5*chamber_height/4;

			// pipe entering chamber
			translate([0,0,h_out]) {
				rotate([0,90,0]) {
					cylinder(h=chamber_wall_middle_radius,r=pipe_radius,$fn=fn_resolution);
				}
			}
	// pipe exiting end housing
	translate([chamber_wall_middle_radius,chamber_wall_middle_radius-15,h_out]) {
			rotate([0,90,0]) {
				cylinder(h=box_length,r=pipe_radius,$fn=fn_resolution);
			}
	
	// perpendicular pipe joining the other 2
		translate([0,1,0]) {
			rotate([90,0,0]) {
				cylinder(h=chamber_wall_middle_radius-15+pipe_radius,r=pipe_radius,$fn=fn_resolution);
			}
		}
	}
}



module chamber_in_out_holes() {
	zpipe();
	lpipe();
	lid_seal();
pipe_control_surface();
}



module holes() {
	for ( i = [0 : 4] ){
		rotate( [0, 0, i * 90]) {
			translate([flange_radius-flange_hole_distance,0,-2]) {
				cylinder(h=5, r1=1, r2=1, $fn=fn_resolution);
			}
		}
	}
}



