chamber_internal_radius=10;
chamber_height=10;


chamber_external_radius=chamber_internal_radius*2;
chamber_internal_radius_top=chamber_internal_radius*1.5;
chamber_wall_thickness=chamber_external_radius-chamber_internal_radius_top;
chamber_wall_middle_radius=chamber_internal_radius+(1.5*chamber_wall_thickness);

fn_resolution=100; //quality vs render time

module shell2() {
translate([0,-1*chamber_external_radius,0]){
cube([40,chamber_external_radius*2,chamber_height]);
}
cylinder(h=chamber_height, r1=chamber_external_radius,  r2=chamber_external_radius,$fn=fn_resolution*3);

}

module housing_hole(){
translate([chamber_external_radius,chamber_wall_thickness-chamber_external_radius,2.5]){
cube([50,chamber_internal_radius_top*2,chamber_height+5]);
}
}

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
	h_in=1.5*chamber_height/4;

	translate([0,chamber_wall_middle_radius,h_in]) {
			rotate([0,90,0]) {
				cylinder(h=50,r=1,$fn=fn_resolution);
			}
		translate([0,1,0]) {
			rotate([90,0,0]) {
				cylinder(h=10,r=1,$fn=fn_resolution);
			}
		}
	}
}

module lid_seal() {
	rotate_extrude(convexity = 10,$fn=100)
	translate([chamber_wall_middle_radius,chamber_height, 0])
	circle(r = 0.5, $fn=100);
}


module zpipe() {
	h_out=3*chamber_height/4;

			// pipe entering chamber
			translate([0,0,h_out]) {
				rotate([0,90,0]) {
					cylinder(h=chamber_wall_middle_radius,r=1,$fn=fn_resolution);
				}
			}
	// pipe exiting end housing
	translate([chamber_wall_middle_radius,chamber_wall_middle_radius,h_out]) {
			rotate([0,90,0]) {
				cylinder(h=30,r=1,$fn=fn_resolution);
			}
	
	// perpendicular pipe joining the other 2
		translate([0,1,0]) {
			rotate([90,0,0]) {
				cylinder(h=chamber_wall_middle_radius+2,r=1,$fn=fn_resolution);
			}
		}
	}
}



module chamber_in_out_holes() {
	zpipe();
	lpipe();
	lid_seal();
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



