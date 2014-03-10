chamber_internal_radius=15;
chamber_height=15;
chamber_wall_thickness=2;
tripod_offset=45;

chamber_external_radius=chamber_internal_radius+chamber_wall_thickness;
flange_radius=chamber_external_radius+4;

flange_hole_distance = (flange_radius - chamber_external_radius)/2;
fn_resolution=100; //quality vs render time

module flange_old(thick=1) {
	cylinder(h=thick, r1=flange_radius, r2=flange_radius, $fn=fn_resolution);
}

module screw_holes(n_holes=4, radius=flange_radius-flange_hole_distance) {
	for ( i = [0 : n_holes] ){
		rotate( [0, 0, i * (360/n_holes)]) {
			translate([radius,0,-2]) 	cylinder(h=5, r1=1, r2=1, $fn=fn_resolution);
}	}	}


module flange(thick=1,hole=0,n_screw_holes=0,radius=flange_radius) {
difference(){
	difference(){
		cylinder(h=thick, r1=radius, r2=radius, $fn=fn_resolution);
		translate([0,0,-thick]) cylinder(h=thick*3, r1=hole, r2=hole, $fn=fn_resolution);
	}
	screw_holes(n_screw_holes);
}	}

module chamber_in_out_holes() {
	offset=20;
	h_in=chamber_height/-4;
	h_out=3*chamber_height/-4;
	
	rotate([0,90,offset]){
		translate([h_in,0,10]) {
			cylinder(h=chamber_external_radius,r1=1, r2=1, $fn=fn_resolution);
	}	}
	rotate([0,90,offset+90]){
		translate([h_out,0,10]) {
			cylinder(h=chamber_external_radius,r1=1, r2=1, $fn=fn_resolution);
}	}	}

module tripod() {
	difference() {
		for ( i = [0 : 3] ){
			rotate( [0, 0, tripod_offset + (i * 120)]) {
				translate([flange_radius,0,0]) cylinder(h=1, r1=5, r2=5, $fn=fn_resolution);
	}	}
	translate([0,0,-0.5]) flange(thick=2);
}	}


module tripod_holes() {
	for ( i = [0 : 3] ){
		rotate( [0, 0, tripod_offset + (i * 120)]) {
			translate([flange_radius+2,0,0]) {
				translate([0,0,-2])  cylinder(h=5, r1=1, r2=1, $fn=fn_resolution);
}	}	}	}


module shell() {
		tripod();
		flange(n_screw_holes=4);
		translate([0, 0, chamber_height]) flange(n_screw_holes=4);
		cylinder(h=chamber_height, r1=chamber_external_radius, 
		r2=chamber_external_radius, $fn=fn_resolution);
}

module chamber() {
	difference(){
		shell();
		translate([0,0,-2]){
			cylinder(h=chamber_height+10, r1=chamber_internal_radius, 
			r2=chamber_internal_radius, $fn=fn_resolution);
}	}	}

/// Draw the object using functions defined above

// 1. Chamber with holes for air pipes
difference() {
	difference() {
		chamber();
		chamber_in_out_holes();
	}
tripod_holes();
}
// 2. transparent top 
translate([0, 0, chamber_height+10]) 	%flange(thick=0.1,hole=0,n_screw_holes=4);

// 3. Clamp to screw down onto transparent top
translate([0, 0, chamber_height+20]) 	flange(hole=chamber_internal_radius,n_screw_holes=4);

// 4. Clamp for bottom to hold sample on.
translate([0, 0, -10]) flange(hole=chamber_internal_radius,n_screw_holes=4);
