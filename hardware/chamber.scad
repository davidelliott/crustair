// Main configurable parameters
chamber_internal_radius=100;
chamber_height=50;
mink_r=30; // radius for curved edges
pipe_radius=3; // main air pipes
oring_xs_radius=1.5; // o-ring seal cross section
fn_resolution=100; //quality vs render time
$fn=fn_resolution;
housing_floor_thickness=5;
///////////////////////////////

// calculate important dimensions
// Some of these would be suitable for manual setting
// The calculations just make reasonable estimates
chamber_external_radius=chamber_internal_radius*2;
chamber_internal_radius_top=chamber_internal_radius*1.5;
chamber_wall_thickness=chamber_external_radius-chamber_internal_radius_top;
chamber_wall_middle_radius=chamber_internal_radius+(1.5*chamber_wall_thickness);
box_length=chamber_external_radius*2;
h_in=chamber_height/2; // height of inlet pipe
h_out=chamber_height/2; // height of inlet pipe
mink_d=mink_r*2;
//////////////////////////////////

// Build the object
difference(){
shell3();
chamber_hole();
housing_hole();
pipe_out();
pipe_in();
lid_seal();
foot_holes();
*pipe_screw1();
}
//////////////////

/////////////
// MODULES //
/////////////

// pipe_out
// this pipe should have the shortest length because the gas will
// be measured. Better to get to the detecter by a short route.
module pipe_out(){
	// First make the pipe
	translate([chamber_external_radius,chamber_external_radius,h_out])
		rotate([0,90,0])
			cylinder(h=box_length+2,r=pipe_radius,$fn=fn_resolution);
}

// pipe_out2 - unfinished idea
// putting proper curces on pipes
module pipe_out2(){
	rotate([0,90,90])
	pipe_90();
	rotate([0,-90,-90])
	pipe_90();
}

// pipe_90 - 90 degree pipe turn
module pipe_90() {
	difference(){
	rotate_extrude(convexity = 10,$fn=100)
		translate([pipe_radius*4,0, 0])
			circle(r = pipe_radius, $fn=100);
	translate([pipe_radius*4,0,0])
		cube([pipe_radius*8,pipe_radius*15,pipe_radius*3],center=true);
	translate([0,pipe_radius*4,0])
		cube([pipe_radius*15,pipe_radius*8,pipe_radius*3],center=true);
}
}

// pipe_in - pipe for gas flow into chamber
// follows a winding path through the casing to enter
// at 90 degrees compared to the pipe_out
module pipe_in() {
			// pipe entering chamber
			translate([chamber_external_radius,chamber_external_radius,h_in]) {
				rotate([0,90,90]) {
					cylinder(h=chamber_wall_middle_radius,r=pipe_radius,$fn=fn_resolution);
				}
			}
	// pipe exiting to housing
	translate([chamber_external_radius*2-chamber_wall_thickness*1.5,chamber_external_radius+30,h_in]) {
			rotate([0,90,0]) {
				cylinder(h=box_length,r=pipe_radius,$fn=fn_resolution);
			}
	}

	// pipe parallel to housing edge
	translate([chamber_external_radius*2-chamber_wall_thickness*1.5+pipe_radius,chamber_external_radius+30+chamber_wall_middle_radius-30,h_in]) {
	rotate([90,90,0]) {
		cylinder(h=chamber_wall_middle_radius-30,r=pipe_radius,$fn=fn_resolution);
	}
	}

	// pipe parallel to chamber outer wall
	translate([chamber_external_radius-pipe_radius,chamber_external_radius+30+chamber_wall_middle_radius-30,h_in]) {
	#rotate([00,90,0]) {
		cylinder(h=chamber_wall_middle_radius-30-10,r=pipe_radius,$fn=fn_resolution);
	}
	}

}

module lid_seal() {
	translate([chamber_external_radius,chamber_external_radius,0])	
	rotate_extrude(convexity = 10,$fn=100)
	translate([chamber_wall_middle_radius,chamber_height, 0])
	circle(r = oring_xs_radius, $fn=100);
}


// shell3 - the main body shell
// minkowski() adds curved edges, but also enlarges each edge by
// the radius of the minkowski object
// - hence translation (mink_r) and size adjustment (mink_d)
module shell3() {
translate([mink_r,mink_r,0]) {
minkowski(){
	cube([chamber_external_radius+box_length-mink_d,chamber_external_radius*2-mink_d,chamber_height]);
	cylinder(r=mink_r,h=0.1);
}
}
}


// chamber_hole - the void that will be subtracted from the shell
module chamber_hole(){
translate([chamber_external_radius,chamber_external_radius,-1]){
union(){
cylinder(h=chamber_height+2, r1=chamber_internal_radius,  r2=chamber_internal_radius_top,$fn=fn_resolution*3,center=false);
cylinder(h=chamber_height+2, r=chamber_internal_radius+10,$fn=fn_resolution*3);

}
}

}

module housing_hole(){
translate([chamber_external_radius*2-chamber_wall_thickness*0,chamber_wall_thickness,housing_floor_thickness]){
	cube([box_length,chamber_internal_radius_top*2,chamber_height+5]);
}
}


// foot_holes are meant to have an M8 bolt passed through to
// act as feet and support the whole apparatus off the ground.
// This is important to avoid blocking gas movement in soil 
// surrounding the measurement area, and is also good for isolating
// the equipment from moisture and dirt.
module foot_holes() {
y0=chamber_wall_thickness/2;
y1=chamber_external_radius*2-y0;
x0=chamber_wall_thickness/2;
x1=chamber_external_radius*2-x0;
x2=chamber_external_radius+box_length-x0;

translate([x0,y0,-1]) 
	cylinder(h=chamber_height+2, r=9, $fn=fn_resolution);
translate([x0,y1,-1]) 
	cylinder(h=chamber_height+2, r=9, $fn=fn_resolution);
translate([x1,y0,-1]) 
	cylinder(h=chamber_height+2, r=9, $fn=fn_resolution);
translate([x1,y1,-1]) 
	cylinder(h=chamber_height+2, r=9, $fn=fn_resolution);
translate([x2,y0,-1]) 
	cylinder(h=chamber_height+2, r=9, $fn=fn_resolution);
translate([x2,y1,-1]) 
	cylinder(h=chamber_height+2, r=9, $fn=fn_resolution);
}

module foot_holes0() {
	for ( i = [0 : 4] ){
		rotate( [0, 0, i * 90]) {
			translate([flange_radius-flange_hole_distance,0,-2]) {
				cylinder(h=chamber_height+2, r1=1, r2=1, $fn=fn_resolution);
			}
		}
	}
}
