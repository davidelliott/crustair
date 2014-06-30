// Main configurable parameters
chamber_internal_radius=25; // radius of the soil surface
chamber_internal_step_width=5; // This is used to avoid having a sharp(=delicate) edge at the bottom of the chamber
chamber_internal_radius_top=40; // larger radius at top allows sunlight to enter when sun lower in sky
chamber_height=40;
chamber_wall_thickness=15;
mink_r=10; // radius for curved edges
pipe_radius=3; // main air pipes
oring_xs_radius=1.5; // o-ring seal cross section
pipe_spacing=20; // distance between in/out pipes where they emerge in the housing
bolt_radius=3.2; // M6 bolt diameter = 6mm, leave some clearance
// servo to be installed on side
servo_length=24.6;
servo_hole_spacing=28.6;
servo_axis_z=11.6/2;
servo_axis_x=7; // manual measurement - not shown on data sheet
servo_width=11.6;
cam_axle_height=chamber_height-servo_axis_z;
cam_axle_radius=2.5;
fn_resolution=30; //quality vs render time
$fn=fn_resolution;
housing_floor_thickness=5;
///////////////////////////////

// calculate important dimensions
// Some of these would be suitable for manual setting
// The calculations just make reasonable estimates
chamber_external_radius=chamber_internal_radius_top+chamber_wall_thickness;
chamber_wall_middle_radius=chamber_internal_radius_top+(0.5*chamber_wall_thickness);
housing_length=chamber_external_radius;
box_length=chamber_external_radius+housing_length;
h_in=chamber_height/4; // height of inlet pipe
h_out=chamber_height/4; // height of outlet pipe
mink_d=mink_r*2;
//////////////////////////////////


// Output some useful information about the object
echo("Overall dimensions (l,w,d) in cm: ",(chamber_external_radius+box_length)/10,chamber_external_radius*2/10,chamber_height/10);

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

pipe_control_cutout();


module pipe_control_cutout() {
gap=15; // space to fix pipes in by hand after printing
xpos=chamber_external_radius+housing_length+gap;
//ypos=chamber_wall_middle_radius+(pipe_spacing/2);
width=pipe_spacing*3;
wall_thickness=4;
length=housing_length-gap;
length_middle=xpos+(length/2);
//ypos=(chamber_external_radius)-wall_thickness ;

cutout_y=width-(2*wall_thickness); //offset+chamber_wall_thickness/2;

ypos=chamber_external_radius-wall_thickness-(cutout_y/2)+(pipe_spacing/2) ;
first_hole=(servo_length-servo_hole_spacing)/2;

// Build the main control surface: a cuboid with cylindrical cutout
difference(){
	// A cuboid from which we will cut away to make the shape
	translate([xpos,ypos,housing_floor_thickness]){
		cube([length,width,chamber_height-housing_floor_thickness]);
	}	
	
	// cutting away several bits - therefore use union here to merge the cutout shapes
	union(){
	// Cut out a cylinder
	translate([length_middle,ypos+cutout_y+wall_thickness,chamber_height+0.8*h_in]){
		rotate([90,0,0]) {
			cylinder(r=chamber_height,h=cutout_y,$fn=fn_resolution);
		}
	}
	// cut out a path for the outlet pipe
	translate([xpos-gap,chamber_external_radius-pipe_radius,h_in-pipe_radius]){
		cube([housing_length+1,pipe_radius*2,chamber_height]);
	}
	
	// cut out a path for the intlet pipe
	translate([xpos-gap,chamber_external_radius-pipe_radius+pipe_spacing,h_in-pipe_radius]){
		cube([housing_length+1,pipe_radius*2,chamber_height]);
	}

	}

	// cut out a hole for the cam axle
	translate([length_middle,chamber_external_radius+width,cam_axle_height]){
		rotate([90,0,0]) {
			cylinder(r=cam_axle_radius,h=cutout_y*2,$fn=fn_resolution);
		}
	}
	
	// cut out a hole where the servo will be mounted
	translate([length_middle-servo_length+servo_axis_x,ypos-1,cam_axle_height-servo_axis_z]){
	cube([servo_length,7.3,servo_width+1]);

	// screw hole 1
	translate([first_hole,7.3,servo_width/2])
	rotate([90,0,0])
	cylinder(r=1,h=7.3);

	// screw hole 2
	translate([first_hole+servo_hole_spacing,7.3,servo_width/2])
	rotate([90,0,0])
	cylinder(r=1,h=7.3);

}	



}
}


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
// putting proper curves on pipes
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
// calcs in this module could probably be simplified a lot.
module pipe_in() {
	// pipe entering chamber
	translate([chamber_external_radius,chamber_external_radius,h_in]) {
		rotate([0,90,90]) {
			cylinder(h=chamber_wall_middle_radius,r=pipe_radius,$fn=fn_resolution);
		}
	}
	// pipe exiting to housing
	translate([chamber_external_radius*2-(chamber_wall_thickness/2)-pipe_radius*2,chamber_external_radius+pipe_spacing,h_in]) {
			rotate([0,90,0]) {
				cylinder(h=box_length,r=pipe_radius,$fn=fn_resolution);
			}
	}


	difference(){
	// curved pipe parallel to chamber edge
	translate([chamber_external_radius,chamber_external_radius,0])	
	rotate_extrude(convexity = 10,$fn=100)
	translate([chamber_wall_middle_radius,h_in, 0])
	circle(r = pipe_radius, $fn=100);

	// cutout section of curved pipe
	union(){
		translate([0,0,h_in-pipe_radius*2]){
			cube([chamber_external_radius*2,chamber_external_radius-pipe_radius+pipe_spacing,pipe_radius*4]);
			cube([chamber_external_radius-pipe_radius,chamber_external_radius*2,pipe_radius*4]);
		}
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
	cube([housing_length+box_length-mink_d,chamber_external_radius*2-mink_d,chamber_height]);
	cylinder(r=mink_r,h=0.1);
}
}
}


// chamber_hole - the void that will be subtracted from the shell
module chamber_hole(){
translate([chamber_external_radius,chamber_external_radius,-1]){
union(){
cylinder(h=chamber_height+2, r1=chamber_internal_radius-chamber_internal_step_width,  r2=chamber_internal_radius_top,$fn=fn_resolution*3,center=false);
cylinder(h=chamber_height+2, r=chamber_internal_radius,$fn=fn_resolution*3);

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
	cylinder(h=chamber_height+2, r=bolt_radius, $fn=fn_resolution);
translate([x0,y1,-1]) 
	cylinder(h=chamber_height+2, r=bolt_radius, $fn=fn_resolution);
translate([x1,y0,-1]) 
	cylinder(h=chamber_height+2, r=bolt_radius, $fn=fn_resolution);
translate([x1,y1,-1]) 
	cylinder(h=chamber_height+2, r=bolt_radius, $fn=fn_resolution);
translate([x2,y0,-1]) 
	cylinder(h=chamber_height+2, r=bolt_radius, $fn=fn_resolution);
translate([x2,y1,-1]) 
	cylinder(h=chamber_height+2, r=bolt_radius, $fn=fn_resolution);
}

