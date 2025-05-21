/*
 * 
 * Modern Key Holder
 * 
 * Author: James P Hansen
 * Version: 1.0.0
 * License: CC BY-NC 4.0 [https://creativecommons.org/licenses/by-nc/4.0/]
 * Link: []
 * Remix of Modern Key Holder by XYZ Space
 * Link: [https://www.printables.com/model/151052-modern-key-hanger]
 * 
 */

include <BOSL2/std.scad>

sqrt_3 = sqrt(3.0);
sqrt_3_div2 = sqrt_3/2.0;

/* [Core hexagon parameters] */
//Thickness of the overall key holder
main_hex_thickness = 6;
//Major radius of the individual hexagons
main_hex_radius = 30;
//How wide the border should be on the edge of the hexagons
main_hex_border = 3;

/* [Hanger Arms] */

//How thick of a hanger/biscuit the hanger can accomodate
biscuit_thickness = 6;
//How wide of a radius for a hanger/biscuit the hanger can accomodate
biscuit_radius = 13;
//Distance of the slots in the hanger from the back of the baseplate to cut out the biscuit
biscuit_height = 6.0;
//Minimum thickness of the arms of the hanger, added to the hanger radius
minimum_hanger_thickness=3;
//Extra to add onto the arms of the hanger, added to the hanger radius and the minimum thickness to determine the thickness of the attachment point of the hanger.
extra_hanger_thickness=4;
//Number of connected key hangers to generate
/* [Counts/Generation] */
//Number of key hangers to generate
number_of_hangers = 3;
//Number of columns of hangers before repeating
vertical_columns = 2;
//Which method to use to have multiple hangers, a horizontal or vertical orientation
stacking_algorithm = "horiz"; // [vert, horiz]
//Cut out a space for the keyring in the top of the blank hexagon spacers
cutout_blanks_for_keyring = false; 

/* [Quality settings] */
// This parameter controls how round do things like spheres and cylinders appear, the bigger this number the rounder they appear
$fn = 30;

/* [Calculated Variables] */
main_hex_inner_radius = main_hex_radius - main_hex_border;
apothem = sqrt_3_div2 * main_hex_radius;
shift = main_hex_radius+main_hex_radius/2;


module base_hex(hex_thickness=main_hex_thickness) {
    difference() {
        linear_extrude(hex_thickness)
        hexagon(r=main_hex_radius);
        up(hex_thickness-1)
        linear_extrude(1.001)
        hexagon(r=main_hex_inner_radius);
    }
}

module cutout_shape(x, y, z) {
    //cuboid([x, y, z]);
    p1_x1 = x;
    p1_x2 = x-2;
    p2_x1 = x-2;
    p2_x2 = x-3;
    p1_y1 = y;
    p1_y2 = y-2; 
    p2_y1 = y-2;
    p2_y2 = y-3;
    p3_x1 = x+2;
    p3_x2 = x;
    p3_y1 = y+2;
    p3_y2 = y;
    union() {
        up(z)
        prismoid(size2=[p3_x1,p3_y1], h=z/2, size1=[p3_x2,p3_y2]);
        up(z/2)
        prismoid(size2=[p1_x1,p1_y1], h=z/2, size1=[p1_x2,p1_y2]);
        prismoid(size2=[p2_x1,p2_y1], h=z/2, size1=[p2_x2,p2_y2]);
    }
}
module key_ring_cutout(bottom=true) {
    length = bottom ? 20 : 11;
    mhr_2 = main_hex_radius/2;
    y_move = bottom ? mhr_2 + 3 : mhr_2 + (mhr_2-length) + 5;
    mvmnt = [0,
             bottom ? -1 * y_move: y_move,
             (main_hex_thickness-4)/2+0.001];
    move(mvmnt)
    cutout_shape(5,
                 length,
                 main_hex_thickness-2);
}

module cut_hex(bottom=true) {
   difference() {
        base_hex();
        key_ring_cutout(bottom=bottom);
    }
}

module biscuit() {
    regular_prism(6,
                  r=biscuit_radius,
                  h=biscuit_thickness,
                  chamfer2=1.75);
}

module hanger() {
    apothem1 = sqrt_3_div2 * 16;
    apothem2 = sqrt_3_div2 * 11;
    difference() {
        linear_extrude(15)
        hexagon(r=16);
        echo(apothem1);
        back(apothem1/2)
        linear_extrude(15.001)
        rect([32,apothem1+0.001]);
        linear_extrude(15.001)
        hexagon(r=11);
        fwd(apothem2*2-0.001)
        linear_extrude(15.001)
        hexagon(r=11);
        
    }
    up(biscuit_height/2)
    biscuit();
}

module hanger2() {
    apothem1 = sqrt_3_div2 * 16;
    apothem2 = sqrt_3_div2 * 11;
    r1 = biscuit_radius+minimum_hanger_thickness+extra_hanger_thickness;
    r2 = biscuit_radius+minimum_hanger_thickness;
    h_height = biscuit_thickness*2 + minimum_hanger_thickness + 0.001;
    up(12.5-0.01) {
        difference() {
            regular_prism(6,
                          r2=r2,
                          r1=r1,
                          h=h_height,
                          chamfer2=1.75);
            back(apothem1)
            cuboid([40,(apothem1*2)+0.001,15.011]);
            regular_prism(6,r=biscuit_radius-2,h=h_height+0.01);
            fwd(apothem2*2-0.001)
            regular_prism(6,r=biscuit_radius-2,h=h_height+0.01);
            up(biscuit_height/4)
            biscuit();
        }   
    }
}

module hex_with_hanger() {
    cut_hex();
    hanger2();
}

module horizontal_stacking(count=1) {
    for (i=[0:count-1]) {
        right((main_hex_radius+main_hex_radius/2)*i)
        fwd(apothem*(i%2))
        hex_with_hanger();
    }
}

module hex_row(count=1) {
    for (i=[0:count-1]) {
        right((main_hex_radius+main_hex_radius/2)*i)
        fwd(apothem*(i%2))
        hex_with_hanger();
    }
}
module hex_blank_row(count=1, start=0, do_cut_hex=false) {
    for (i=[start:count-1]) {
        right((main_hex_radius+main_hex_radius/2)*i)
        fwd(apothem*(i%2))
        if (do_cut_hex)
            cut_hex(bottom=false);
        else
            base_hex();
    }
}

module sparse_vertical_stacking(count=1) {
    //apothem = sqrt_3/2.0 * main_hex_radius;
    //shift = main_hex_radius+main_hex_radius/2;
    
    vstacker(count, vertical_columns);
}

module vstacker(count,
                current_row_width,
                current_row=0,
                is_blank=false,
                total_placed=0) {
    vmove = apothem * 2 * current_row;
    next_blank = ! is_blank;
    row_width = current_row_width;
    if (total_placed < count) {
        act_row = total_placed + row_width < count ? row_width : count - total_placed;
        echo("V",current_row, vmove, next_blank, row_width, act_row);
        if (is_blank) {
            fwd(vmove)
            hex_blank_row(row_width,
                          start=0,
                          do_cut_hex=cutout_blanks_for_keyring);
            vstacker(count,
                     current_row_width,
                     current_row=current_row+1,
                     is_blank=next_blank,
                     total_placed=total_placed);
        }
        else {
            fwd(vmove)
            hex_row(act_row);
            vstacker(count,
                     current_row_width,
                     current_row=current_row+1,
                     is_blank=next_blank,
                     total_placed=total_placed + act_row);
        }
    }
}

module spiral_stacking(count=1) {
    echo("spiral");
    //apothem = sqrt_3/2.0 * main_hex_radius;
    //shift = main_hex_radius+main_hex_radius/2;
    hex_with_hanger();
    right(shift)
    fwd(apothem)
    hex_with_hanger();
    right(shift*0)
    fwd(apothem*2)
    hex_with_hanger();
    right(shift*1*-1)
    fwd(apothem)
    hex_with_hanger();
    right(shift*1*-1)
    fwd(apothem*-1)
    hex_with_hanger();
}

module multi_bases(count=1) {
    apothem = sqrt_3/2.0 * main_hex_radius;
    if(count <= 1) {
        hex_with_hanger();
    }
    else {
        if(stacking_algorithm == "horiz") {
            union() {
                horizontal_stacking(count=count);
            }
        }
        if(stacking_algorithm == "vert") {
            union() {
                sparse_vertical_stacking(count=count);
            }
        }
    }
}

module main() {
    multi_bases(number_of_hangers);
}

main();