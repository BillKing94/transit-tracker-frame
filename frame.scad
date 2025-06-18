wallThickness = 2;
displayDims = [160, 80, 14.6];
bevelWidth = 17;
displayMountWidth = 12.5;
bevelRadius = 5;
displayLayout=[2,1];
circuitDepth = 12;
portCutoutDims = [46,7];

screwHoleRadius = 2.1;
screwPositions = [
    [17.5, 7.5],
    [67.5, 7.5],
    [142.5, 7.5],
    [17.5, 72.5],
    [92.5, 72.5],
    [142.5, 72.5],
];

postHoleRadius = 2;
postPositions = [
    [152.5, 55.5],
    [7.5, 24.5]
];

sliceInHalf = false;
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
                    cylinder(h=wallThickness + 2*epsilon, r=screwHoleRadius);
                }
                
                for(pos = postPositions) {
                    translate([pos.x, pos.y, -epsilon])
                    cylinder(h=wallThickness + 2*epsilon, r=postHoleRadius);
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