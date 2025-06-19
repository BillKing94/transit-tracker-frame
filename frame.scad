// Thickness of all thin walls.
wallThickness = 2;

// Dimensions of one display module.
displayDims = [160, 80, 14.6];

// Display module layout.
displayLayout=[2,1];

// Width of the bevel around the displays.
bevelWidth = 17;

// Width of the face around the interior which the display mounts to.
displayMountWidth = 12.5;

// Radius of the exterior bevel.
bevelRadius = 5;

// Depth of the electronics compartment.
circuitDepth = 12;

// Dimensions of the power/button cutout on the side of the unit.
portCutoutDims = [46,7];

// Radius for screw holes.
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

// Radius for post holes.
postHoleRadius = 2;

// Positions of post holes for each display, relative to the display's bottom-left corner.
postPositions = [
    [152.5, 24.5],
    [7.5, 55.5]
];

// If set, cut the model in half to be printed in two parts.
sliceInHalf = false;

// If sliceInHalf is set, how much the two halves should overlap.
topHalfOverhang = 50;

epsilon = .01;

$fn = $preview ? 20 : 70;

function hadamard(v1, v2) = 
    [v1.x*v2.x, v1.y*v2.y, v1.z*v2.z];

displayVolume = hadamard([displayLayout.x, displayLayout.y, 1], displayDims);

module mounting_holes() { 
    for(disX = [0:displayLayout.x-1]) {
        for(disY = [0:displayLayout.y-1]) {
            displayOffset = [displayDims.x * disX, displayDims.y * disY, 0];
            
            translate(displayOffset) {
                for(pos = screwPositions) {
                    translate([pos.x, pos.y, -epsilon])
                    cylinder(h=wallThickness + 2*epsilon, r=screwHoleRadius, $fn=10);
                }
                
                for(pos = postPositions) {
                    translate([pos.x, pos.y, -epsilon])
                    cylinder(h=wallThickness + 2*epsilon, r=postHoleRadius, $fn=10);
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


module front() {
    frameDims = displayVolume
        + [0,0,1]*wallThickness
        + [1,1,0]*2*bevelWidth;
    
    displayOffset = [bevelWidth,bevelWidth,wallThickness];
     
    cutoutOffsetFromDisplay = [displayMountWidth,displayMountWidth,-wallThickness];
    
    backCutoutDims = hadamard([1,1,0],displayVolume) - [2,2,0]*displayMountWidth + [0,0,wallThickness] + [0,0,2*epsilon];
    
    intersection() {
        translate(displayOffset)
        difference() {
            translate(cutoutOffsetFromDisplay)
            difference() {
                translate(-cutoutOffsetFromDisplay) {
                    difference() {
                        translate(-displayOffset)
                            beveled_box(frameDims, bevelRadius, true);
                        
                        cube(displayVolume);
                    }
                }
                
                translate([0,0,-epsilon])
                    cube(backCutoutDims);
            }
            
            
            translate([0,0,-wallThickness])    
            mounting_holes();
        }
        
        
        
        if(sliceInHalf) {
            overhangHull1 = [
                .5*frameDims.x + .5*topHalfOverhang,
                .5*frameDims.y,
                frameDims.z
            ];
            
            overhangHull2 = [
                .5*frameDims.x - .5*topHalfOverhang,
                .5*frameDims.y,
                frameDims.z
            ];
            
            union() {
                cube(overhangHull1);
                
                translate([0,.5*frameDims.y, 0])
                cube(overhangHull2);
            }
        }
    }
}

module back() {
    frameDims = hadamard([1,1,0], displayVolume)
        + [0,0,1]*circuitDepth
        + [0,0,1]*wallThickness
        + [1,1,0]*2*bevelWidth;
    
    displayOffset = [bevelWidth, bevelWidth, frameDims.z];
    
    offsetToCircuitCutout = [
        wallThickness,
        bevelWidth + displayMountWidth,
        wallThickness
    ];
    
    circuitCutoutDims = [ 
        frameDims.x - 2*wallThickness,
        frameDims.y - 2*(bevelWidth + displayMountWidth),
        frameDims.z - wallThickness + epsilon
    ];
    
    portCutoutDimsRotated = [wallThickness, portCutoutDims.x, portCutoutDims.y];
    offsetToPortCutout = [
        0,
        (frameDims.y - portCutoutDimsRotated.y)/2,
        frameDims.z - portCutoutDimsRotated.z
    ];
    
    screwBackCutoutDims = [
        frameDims.x - 2*wallThickness - 2*bevelRadius,
        (frameDims.y - circuitCutoutDims.y - 4*wallThickness)/2,
        frameDims.z - wallThickness
    ];
    
    offsetToScrewBackCutout = [
        wallThickness + bevelRadius,
        wallThickness,
        0
    ];
    
    translate([0,0,-frameDims.z])
    intersection() {
        translate(displayOffset) {
            difference() {
                translate(-displayOffset) {
                    mirror([0,1,0])
                    translate(offsetToScrewBackCutout - [0,frameDims.y, 0])
                    difference() {
                        translate([0,frameDims.y, 0] - offsetToScrewBackCutout)
                        mirror([0,1,0])
                        translate(offsetToScrewBackCutout)
                        difference() {
                            translate(offsetToPortCutout - offsetToScrewBackCutout)
                            difference() {
                                translate(offsetToCircuitCutout-offsetToPortCutout)
                                difference() {
                                    translate(-offsetToCircuitCutout)
                                        beveled_box(frameDims, bevelRadius, false);
                                    
                                    cube(circuitCutoutDims);
                                }
                                
                                translate(epsilon*[-1,0,0])
                                cube(portCutoutDimsRotated + epsilon*[2,0,1]);
                            }
                            
                            translate(epsilon*[0,0,-1])
                            cube(screwBackCutoutDims + epsilon*[0,0,1]);
                        }
                        
                        translate(epsilon*[0,0,-1])
                        cube(screwBackCutoutDims + epsilon*[0,0,1]);
                    }
                }
                
                translate([0,0,-wallThickness])
                mounting_holes();
            }
        }
            
        if(sliceInHalf) {
            sliceDims = [.5*frameDims.x, frameDims.y, frameDims.z];
            cube(sliceDims);
        }
    }
}

union() {
    front();
    back();
}