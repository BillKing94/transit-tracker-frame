/* [General] */
// Thickness of all thin walls.
wallThickness = 2;

// Width of the bezel around the displays.
bezelWidth = [17,17];

// Radius of the exterior bevel.
bevelRadius = 5;
 
/* [Displays] */
// Dimensions of one display module.
displayDimsRaw = [160, 80, 14.6];

// Extra wiggle room around the display.
displayWiggleRoom = [.5, .5, 0];

// Display module layout.
displayLayout=[2,1];
 
// Width of the flange on the left and right side of the displays.
displaySideMountWidth = 15;

/* [Electronics] */
// Height of cavity for electronic components.
circuitHeight = 53;

// Depth of the electronics compartment.
circuitDepth = 12;

// For layouts with multiple rows of displays, the position of the cable passthrough from the display edge.
cablePassthroughPos = 100;

// For layouts with multiple rows of displays, the width of the cable passthrough.
cablePassthroughWidth = 30;

/* [Hangers] */
// Whether teardrop hangers should be added for hanging the display on a wall.
addHangersTop = false;

// Adds hangers for hanging "upside down." Also useful for multi-part printing.
addHangersBottom = false;

// Radius for the top of each hanger.
hangerRadiusTop = 3;

// Radius for the bottom of each hanger.
hangerRadiusBottom = 7;

// How much overhang should be added to grip the nail/screw head when hanging.
hangerLip = 2;

// How thick the hanger lip should be.
hangerLipThickness = 2; // .1

// How deep the hanging hole should extend into the body of the frame.
hangerDepth = 5; // .1

// Height of each hanger.
hangerHeight = 15;

/* [Port Cutout] */
// Whether a cutout should be added for power/buttons.
portCutout = true;

// Whether the port cutout should be an inset cutout in the back of the frame.
portCutoutInset = false;
portCutoutSmall = !portCutoutInset;

// If portCutoutInset is enabled, how far from the edge of the frame the controller should be positioned.
portCutoutInsetDepth = 55;

// Dimensions of the power/button cutout on the side of the unit.
portCutoutDims = [46,7];

// Height of the port cutout from the bottom of the electronics compartment.
portCutoutHeightFromBase = 5; // .1

/* [Display Mounting] */
// Radius for display screw holes.
screwHoleRadius = 2.1;

// Positions of screw holes for each display, relative to the display's bottom-left corner.
screwPositions = [
    [17.5, 7.5],
    [92.5, 7.5],
    [142.5, 7.5],
    [17.5, 72.5],
    [67.5, 72.5],
    [142.5, 72.5],
];

// Width of channels for screws.
screwCutoutWidth = 12;

// Radius for display post holes.
postHoleRadius = 3;

// Positions of post holes for each display, relative to the display's bottom-left corner. An optional third value of LEFT, RIGHT, UP, or DOWN (in quotes) may be provided with each vector to indicate a direction to cut a slot.
postPositions = [
    [7.5, 55.5, "RIGHT"],
    [152.5, 24.5, "LEFT"]
];

/* [Controller Mounting] */
// If set, a separate mount should be added for the controller.
addControllerMount = false;

// Height of the controller module.
controllerHeight = 44.5;

// Rear clearance required for the controller module.
controllerStandOff = 10;

// Extra space around controller screw holes.
controllerScrewPadding = 2;

// Positions of controller mounting screws, relative to the controller's bottom-left corner.
controllerScrewPositions = [
    [7.5, 15.5],
    [7.5, 35.5],
    [48, 15.5],
    [48, 35.5]
];

// Radius for controller screw holes.
controllerScrewHoleRadius = 1.5;

/* [Multi-Part Printing] */
// If set, cut the model in half to be printed in two parts.
sliceInHalf = false;

// If sliceInHalf is set, how much the two halves should overlap.
topHalfOverhang = 50;

/* [Stand] */
// Whether to generate a stand for the frame, rather than the frame itself.
stand = false;

// The distance the stand should extend out from the frame.zs
standFootWidth = 30;

// How much the stand should elevate the frame.
standElevation = 10;

// How thick the stand should be.
standThickness = 20;

// Radius for stand outer edge rounding.
standOuterRadius = 2;

// How much extra wiggle room should be added to accomodate the frame.
standWiggleRoom = .5; // .1

/* [Miscellaneous] */
epsilon = .1;

$fn = $preview ? 20 : 70;

function hadamard(v1, v2) = 
    [v1.x*v2.x, v1.y*v2.y, v1.z*v2.z];

displayDims = displayDimsRaw + hadamard([1,1,0], displayWiggleRoom);
displayVolume = hadamard([displayLayout.x, displayLayout.y, 1], displayDims);

displayTopBottomMountWidth = (displayDims.y - circuitHeight)/2;

bezelSize = [bezelWidth.x, bezelWidth.y, 0];


frontDims = displayVolume
    + [0,0,1]*wallThickness
    + 2 * bezelSize;
    
backDims = hadamard([1,1,0], displayVolume)
    + [0,0,1]*circuitDepth
    + [0,0,1]*wallThickness
    + 2 * bezelSize;
    
fullFrameDims = [
    backDims.x,
    backDims.y,
    frontDims.z + backDims.z
];

function str_to_dir(dirName) =
    (dirName == "LEFT") ? [-1, 0, 0] : 
    (dirName == "RIGHT") ? [1, 0, 0] :
    (dirName == "UP") ? [0, 1, 0] :
    (dirName == "DOWN") ? [0, -1, 0]
    : [0,0,0];

module mounting_holes() { 
    for(disX = [0:displayLayout.x-1]) {
        for(disY = [0:displayLayout.y-1]) {
            displayOffset = [displayDims.x * disX, displayDims.y * disY, 0]
                + hadamard([.5, .5, 0], displayWiggleRoom);
            
            translate(displayOffset) {
                for(pos = screwPositions) {
                    translate([pos.x, pos.y, -epsilon])
                    cylinder(h=wallThickness + 2*epsilon, r=screwHoleRadius, $fn=10);
                }
                
                for(pos = postPositions) {
                    translate([pos.x, pos.y, -epsilon])
                    hull() {
                        cylinder(h=wallThickness + 2*epsilon, r=postHoleRadius, $fn=10);
                        dirName = pos.z;
                        
                        slotSize = (dirName == "LEFT" || dirName == "RIGHT")
                            ? displaySideMountWidth
                            : displayTopBottomMountWidth;
                        
                        cylinderCutDirection = str_to_dir(pos.z);
                        translate(cylinderCutDirection * slotSize)
                        cylinder(h=wallThickness + 2*epsilon, r=postHoleRadius, $fn=10);
                    }
                }
            }
        }
    }
}


module beveled_box(dims, radius, bevelTopEdges) {
    topZ = bevelTopEdges ? 1 : 2.5;
    sphereOffsets = [
        [0,0,topZ],
        [0,1,topZ],
        [1,0,topZ],
        [1,1,topZ],
        [0,0,-1.5],
        [0,1,-1.5],
        [1,0,-1.5],
        [1,1,-1.5]
    ];
    
    radiusOffset = radius*[1,1,1];
    dimsOffset = dims - 2*radiusOffset;
    
    intersection() {
        hull() {
            for(o = sphereOffsets) {
            translate(radiusOffset + hadamard(o, dimsOffset))
                sphere(radius);
            }
        };
        
        cube(dims);
    }
}

    
module cable_passthroughs(xPos, zDepth, inner)
{     
    if(displayLayout.y > 1) {
        for(iDisplay = [1 : displayLayout.y - 1]) {
            passthroughDims = [
                cablePassthroughWidth + (inner ? 0 : 2*wallThickness),
                displayDims.y - circuitHeight,
                zDepth + (inner ? -wallThickness : 0)
            ];
            
            offsetForPassthrough = [
                bezelWidth.x + xPos + (inner ? 0 : -wallThickness),
                bezelWidth.y + iDisplay * displayDims.y - .5*passthroughDims.y,
                (inner ? wallThickness : 0)
            ];
            
            translate(offsetForPassthrough)
            cube(passthroughDims);
        }    
    }
}

module front() {
    displayOffset = [bezelWidth.x,bezelWidth.y,wallThickness];
    
    //backCutoutDims = hadamard([1,1,0],displayVolume) - [2,2,0]*displayMountWidth + [0,0,wallThickness] + [0,0,2*epsilon];
    
    backCutoutDims = [
        displayVolume.x - 2*displaySideMountWidth,
        circuitHeight,
        wallThickness + 2*epsilon
    ];
    
    backCutoutOffset = [
        .5 * frontDims.x - .5 * backCutoutDims.x,
        bezelWidth.y + .5 * displayDims.y - .5 * backCutoutDims.y,
        0
    ];
    
    intersection() {
        difference() {
            beveled_box(frontDims, bevelRadius, true);
            
            translate(displayOffset)
            cube(displayVolume);
            
            for(iDisplay = [0 : displayLayout.y - 1]) {
                translate([0,iDisplay * displayDims.y, 0])
                translate(backCutoutOffset)
                translate([0,0,-epsilon])
                    cube(backCutoutDims);
            }
            
            translate(displayOffset)
            translate([0,0,-wallThickness])
            mounting_holes();
            
            translate([0,0,-wallThickness])
            cable_passthroughs(cablePassthroughPos, frontDims.z, true);
        }
        
        
        
        if(sliceInHalf) {
            overhangHull1 = [
                .5*frontDims.x + .5*topHalfOverhang,
                .5*frontDims.y,
                frontDims.z
            ];
            
            overhangHull2 = [
                .5*frontDims.x - .5*topHalfOverhang,
                .5*frontDims.y,
                frontDims.z
            ];
            
            union() {
                cube(overhangHull1);
                
                translate([0,.5*frontDims.y, 0])
                cube(overhangHull2);
            }
        }
    }
}

module back() {
    
    displayOffset = [bezelWidth.x, bezelWidth.y, backDims.z];
    
    circuitCutoutDims = [ 
        backDims.x - 2*wallThickness,
        circuitHeight,
        circuitDepth + epsilon
    ];
    
    offsetToCircuitCutout = [
        wallThickness,
        bezelWidth.y + .5*displayDims.y - .5*circuitHeight,
        wallThickness
    ];
    
    portCutoutDimsRotated = [wallThickness, portCutoutDims.x, portCutoutDims.y];
    offsetToPortCutout = [
        portCutoutInset ? portCutoutInsetDepth : 0,
        bezelWidth.y + .5*displayDims.y - .5*portCutoutDimsRotated.y,
        wallThickness + portCutoutHeightFromBase
    ];
    
    screwBackCutoutDims = [
        displayDims.x * displayLayout.x,
        screwCutoutWidth,
        backDims.z - wallThickness
    ];
    
    offsetToScrewBackCutout1 = [
        bezelWidth.x,
        bezelWidth.y,
        0
    ];
    
    offsetToScrewBackCutout2 = [
        offsetToScrewBackCutout1.x,
        offsetToScrewBackCutout1.y + displayDims.y - screwBackCutoutDims.y,
        offsetToScrewBackCutout1.z
    ];
    
    offsetToControllerStandoff = [
        ((portCutout && portCutoutInset) ? portCutoutInsetDepth : wallThickness),
        bezelWidth.y + .5*displayDims.y - .5*controllerHeight,
        0
    ];
    
    module controller_standoff_shell(inner) {
        hull() {
            screwBoxSize = ((inner ? [0,0,0] : [2,2,1])*wallThickness)
                + [2,2,0]*controllerScrewHoleRadius
                + [2,2,0]*controllerScrewPadding
                + [0,0,1]*controllerStandOff
                + (inner ? [0,0,epsilon] : [0,0,0]);
            
            translate(inner ? [0,0,-epsilon] : [0,0,0])
            for(screwPos = controllerScrewPositions) {
                translate([screwPos.x, screwPos.y, 0] - hadamard([.5, .5, 0], screwBoxSize))
                cube(screwBoxSize);
            }
            
            if(!inner) {
                for(screwPos = controllerScrewPositions) {
                    spacerSize = [1,1,1];
                    translate([0, screwPos.y - .5*screwBoxSize.y, 0])
                    cube(screwBoxSize);
                }
            }
        }
    }
    
    module port_inset_cutout(inner) {
        cutoutOuterDims = [
            portCutoutInsetDepth + wallThickness,
            (backDims.y - circuitHeight) / 2 + circuitHeight + wallThickness,
            controllerStandOff + portCutoutDims.y + 2*wallThickness
        ];
        
        cutoutInnerDims = [
            portCutoutInsetDepth - bezelWidth.x,
            circuitHeight - 2*wallThickness,
            controllerStandOff + portCutoutDims.y + wallThickness + epsilon
        ];
        
        cutoutDims = inner ? cutoutInnerDims : cutoutOuterDims;
        
        cutoutOuterOffset = [0, bezelWidth.y + displayDims.y - cutoutDims.y, 0];
        
        cutoutInnerOffset = [
            bezelWidth.x,
            bezelWidth.y + (displayDims.y - cutoutInnerDims.y) / 2,
            -epsilon
        ];
        
        cutoutOffset = inner ? cutoutInnerOffset : cutoutOuterOffset;
        
        intersection() {
            translate(cutoutOffset)
                cube(cutoutDims);
            
            if(!inner) {
                translate(offsetToCircuitCutout)
                cube(circuitCutoutDims);
            }
        }
            
        module cutout_for_wire_routing() {
            cutoutDepth = cutoutInnerDims.z;
            cutoutHeight = cutoutInnerDims.x;
        
            wireCutoutDepth = .5 * (displayDims.y - cutoutInnerDims.y - 2*screwCutoutWidth);
            wireCutoutStraightPartWidth = cutoutHeight - cutoutDepth;
            
            translate([0, wireCutoutDepth, 0])
            rotate([90, 0, 0])
            linear_extrude(wireCutoutDepth)
            polygon([
                [0, 0],
                [wireCutoutStraightPartWidth + cutoutDepth, 0],
                [wireCutoutStraightPartWidth, cutoutDepth],
                [0, cutoutDepth]
            ]);
        }
        
        if(inner) {
            wireCutoutOffset1 = [
                bezelWidth.x,
                bezelWidth.y + screwCutoutWidth,
                0
            ];
            
            wireCutoutOffset2 = [
                wireCutoutOffset1.x,
                cutoutOffset.y + cutoutDims.y,
                wireCutoutOffset1.z
            ];
            
            translate(wireCutoutOffset1)
            cutout_for_wire_routing();
            
            translate(wireCutoutOffset2)
            cutout_for_wire_routing();
        }
    }
    
    translate([0,0,-backDims.z])
    intersection() {
        difference() {
            union() {
                difference() {
                    beveled_box(backDims, bevelRadius, false);
                    
                    for(iDisplay = [0 : displayLayout.y - 1]) {
                        translate(offsetToCircuitCutout)
                        translate(iDisplay * displayDims.y * [0,1,0])
                            cube(circuitCutoutDims);
                    }
                    
                    for(iDisplay = [0 : displayLayout.y - 1]) {
                        offsetForDisplay = [0,iDisplay * displayDims.y, 0];
                        translate(offsetForDisplay) {
                            translate(offsetToScrewBackCutout1)
                            translate(epsilon*[0,0,-1])
                            cube(screwBackCutoutDims + epsilon*[0,0,1]);
                           
                            translate(offsetToScrewBackCutout2)
                            translate(epsilon*[0,0,-1])
                            cube(screwBackCutoutDims + epsilon*[0,0,1]);
                        }
                    }
                    
                    translate(displayOffset)
                    translate([0,0,-wallThickness])
                    mounting_holes();
                }
                
                if(addControllerMount) {
                    translate(offsetToControllerStandoff)
                    if(controllerStandOff > 0)
                        controller_standoff_shell(false);
                }
                
                if(portCutout && portCutoutInset) {
                    port_inset_cutout(false);
                }
                
                cable_passthroughs(cablePassthroughPos, backDims.z, false);
            }
            
            if(addControllerMount) {
                translate(offsetToControllerStandoff) {
                    if(controllerStandOff > 0)
                        controller_standoff_shell(true);
                    
                    for(screwPos = controllerScrewPositions) {
                        translate(screwPos - [0,0,epsilon])
                        cylinder(h = backDims.z + 2*epsilon, r = controllerScrewHoleRadius, $fn = 10);
                    }
                }
            }
                    
            if(portCutout) {
                translate(offsetToPortCutout)
                translate(epsilon*[-1,0,0])
                    cube(portCutoutDimsRotated + epsilon*[2,0,1]);
                
                if(portCutoutInset) {
                    port_inset_cutout(true);
                }
            }
            
            cable_passthroughs(cablePassthroughPos, backDims.z, true);
        }
            
        if(sliceInHalf) {
            sliceDims = [.5*backDims.x, backDims.y, backDims.z];
            cube(sliceDims);
        }
    }
}

module teardrop(radiusTop, radiusBottom, height) {
    circleSpacing = height - radiusTop - radiusBottom;
    
    translate([0, -radiusTop, 0])
    hull() {
        circle(r=radiusTop);
        
        translate([0, -circleSpacing, 0])
        circle(r=radiusBottom);
    }
}

module hanger() {
    translate([0,0,hangerLipThickness])
    linear_extrude(hangerDepth - hangerLipThickness)
    teardrop(hangerRadiusTop, hangerRadiusBottom, hangerHeight);
    
    translate([0, -hangerLip, 0])
    linear_extrude(hangerDepth)
    teardrop(hangerRadiusTop - hangerLip, hangerRadiusBottom - hangerLip, hangerHeight - hangerLipThickness);
}

module frame() {
    difference() {
        translate([0,0,backDims.z])
        union() {
            front();
            back();
        }
        
        if(addHangersTop) {
            translate([bezelWidth.x/2, backDims.y - wallThickness, 0])
            hanger();
            
            translate([backDims.x - bezelWidth.x/2, backDims.y - wallThickness, 0])
            hanger();
        }
        
        if(addHangersBottom) {
            translate([bezelWidth.x/2, wallThickness, 0])
            rotate([0,0,180])
            hanger();
            
            translate([backDims.x - bezelWidth.x/2, wallThickness, 0])
            rotate([0,0,180])
            hanger();
        }
    }
}

module stand_body() {
    standDims = [fullFrameDims.z + 2*standFootWidth, bezelWidth.y + standElevation];
    
    translate([bezelWidth.y,-standElevation - epsilon,standDims.x/2 + fullFrameDims.z/2])
    rotate([0,90,0])
    linear_extrude(standThickness)
    difference() {
        square(standDims);
        
        translate([standOuterRadius, standFootWidth + standElevation])
        circle(r=standFootWidth);
        
        translate([standDims.x - standOuterRadius, standFootWidth + standElevation])
        circle(r=standFootWidth);
    
        // Rounded outer edges
        translate([0, standElevation - standOuterRadius, 0])
        difference() {
            square(standOuterRadius * [1,2]);
           
            translate([standOuterRadius, 0])
            circle(r=standOuterRadius);
        }
        
        translate([standDims.x - standOuterRadius, standElevation- standOuterRadius, 0])
        difference() {
            square(standOuterRadius * [1,2]);
            circle(r=standOuterRadius);
        }
    
    }
}

if(stand) {
    translate([0,0,standElevation])
    rotate([90,0,0])
    difference() {
        stand_body();

        translate([0,0,-.5*standWiggleRoom])
        frame();
        
        translate([0,0,.5*standWiggleRoom])
        frame();
    }
}
else {
    frame();
}