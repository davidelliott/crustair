chamber_internal_radius=10;
chamber_height=10;
chamber_wall_thickness=2;

chamber_external_radius=chamber_internal_radius*2;
flange_radius=chamber_external_radius+4;

flange_hole_distance = (flange_radius - chamber_external_radius)/2;
fn_resolution=100; //quality vs render time



module shell2() {
translate([0,-1*chamber_external_radius,0]){
cube([40,chamber_external_radius*2,chamber_height]);
}
cylinder(h=chamber_height, r1=chamber_external_radius,  r2=chamber_external_radius);

}

module housing_hole(){
translate([chamber_external_radius,5-chamber_external_radius,2.5]){
cube([50,(chamber_external_radius*2)-10,chamber_height+5]);
}
}

module chamber_hole(){
translate([0,0,-1]){
cylinder(h=chamber_height+2, r1=chamber_internal_radius,  r2=chamber_internal_radius*1.5);}
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

shell_w_housing_w_chamber();



module flange() {
	cylinder(h=1, r1=flange_radius, r2=flange_radius, $fn=fn_resolution);
}


module chamber_in_out_holes() {
	offset=20;
	h_in=chamber_height/-4;
	h_out=3*chamber_height/-4;
	
	rotate([0,90,offset]){
		translate([h_in,0,10]) {
			cylinder(h=5,r1=1, r2=1, $fn=fn_resolution);
		}
	}
	rotate([0,90,offset+90]){
		translate([h_out,0,10]) {
			cylinder(h=5,r1=1, r2=1, $fn=fn_resolution);
		}
	}
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

tripod_offset=45;

module tripod() {
	for ( i = [0 : 3] ){
		rotate( [0, 0, tripod_offset + (i * 120)]) {
			translate([flange_radius,0,0]) {
				cylinder(h=1, r1=5, r2=5, $fn=fn_resolution);
			}
		}
	}
}

module tripod_holes() {
	for ( i = [0 : 3] ){
		rotate( [0, 0, tripod_offset + (i * 120)]) {
			translate([flange_radius+0.5,0,0]) {
				translate([0,0,-2]) { cylinder(h=5, r1=1, r2=1, $fn=fn_resolution);
				}
			}
		}
	}
}

module flange_w_holes() {
	difference(){
		cylinder(h=1, r1=flange_radius, r2=flange_radius, $fn=fn_resolution);
		holes();
	}
}

module flange_w_tripod() {
	difference(){
		union(){
			flange();
			tripod();
		}
		tripod_holes();
	}
}

module flange_w_tripod_w_holes() {
	difference(){
		flange_w_tripod();
		holes();
	}
}

//flange_w_tripod_w_holes();

module shell() {
	flange_w_tripod_w_holes();
	translate([0, 0, chamber_height]) {
	flange_w_holes();	
	}
	cylinder(h=chamber_height, r1=chamber_external_radius, r2=chamber_external_radius, $fn=fn_resolution);
}

module chamber() {
	difference(){
		shell();
		translate([0,0,-2]){
			cylinder(h=chamber_height+10, r1=chamber_internal_radius, r2=chamber_internal_radius, $fn=fn_resolution);
		}
	}
}
