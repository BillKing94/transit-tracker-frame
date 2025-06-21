// Thickness of all thin walls.
wallThickness = 2;

// Dimensions of one display module.
displayDims = [160, 80, 14.6];

// Display module layout.
displayLayout=[2,1];

// Width of the bezel around the displays.
bezelWidth = 17;

displaySideMountWidth = 15;

// Radius of the exterior bevel.
bevelRadius = 5;

// Height of cavity for electronic components.
circuitHeight = 53;

// Depth of the electronics compartment.
circuitDepth = 12;

// Whether a cutout should be added for power/buttons.
portCutout = true;

// Whether the port cutout should be an inset cutout in the back of the frame.
portCutoutInset = false;
portCutoutSmall = !portCutoutInset;

// If portCutoutInset is enabled, how far from the edge of the frame the controller should be positioned.
portCutoutInsetDepth = 40;

// Dimensions of the power/button cutout on the side of the unit.
portCutoutDims = [46,7];

// Height of the port cutout from the bottom of the electronics compartment.
portCutoutHeightFromBase = 5; // .1

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
postHoleRadius = 2;

// Positions of post holes for each display, relative to the display's bottom-left corner.
postPositions = [
    [152.5, 24.5],
    [7.5, 55.5]
];

// If set, a separate mount should be added for the controller.
addControllerMount = false;

// Height of the controller module.
controllerHeight = 44.5;

// Rear clearance required for the controller module.
controllerStandOff = 10;

// Extra space around controller screw holes.
controllerScrewPadding = 1.5;

// Positions of controller mounting screws, relative to the controller's bottom-left corner.
controllerScrewPositions = [
    [7.5, 15.5],
    [7.5, 35.5],
    [48, 15.5],
    [48, 35.5]
];

// Radius for controller screw holes.
controllerScrewHoleRadius = 1.5;

// If set, cut the model in half to be printed in two parts.
sliceInHalf = false;

// If sliceInHalf is set, how much the two halves should overlap.
topHalfOverhang = 50;

epsilon = .1;

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
        + [1,1,0]*2*bezelWidth;
    
    displayOffset = [bezelWidth,bezelWidth,wallThickness];
    
    //backCutoutDims = hadamard([1,1,0],displayVolume) - [2,2,0]*displayMountWidth + [0,0,wallThickness] + [0,0,2*epsilon];
    
    backCutoutDims = [
        displayVolume.x - 2*displaySideMountWidth,
        circuitHeight,
        wallThickness + 2*epsilon
    ];
    
    backCutoutOffset = hadamard([.5,.5,0], frameDims) - hadamard([.5,.5,0], backCutoutDims);
    
    intersection() {
        difference() {
            beveled_box(frameDims, bevelRadius, true);
            
            translate(displayOffset)
            cube(displayVolume);
            
            translate(backCutoutOffset)
            translate([0,0,-epsilon])
                cube(backCutoutDims);
            
            translate(displayOffset)
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
        + [1,1,0]*2*bezelWidth;
    
    displayOffset = [bezelWidth, bezelWidth, frameDims.z];
    
    circuitCutoutDims = [ 
        frameDims.x - 2*wallThickness,
        circuitHeight,
        circuitDepth + epsilon
    ];
    
    offsetToCircuitCutout = [
        wallThickness,
        .5*frameDims.y - .5*circuitCutoutDims.y,
        wallThickness
    ];
    
    portCutoutDimsRotated = [wallThickness, portCutoutDims.x, portCutoutDims.y];
    offsetToPortCutout = [
        portCutoutInset ? portCutoutInsetDepth : 0,
        (frameDims.y - portCutoutDimsRotated.y)/2,
        wallThickness + portCutoutHeightFromBase
    ];
    
    screwBackCutoutDims = [
        frameDims.x - 2*wallThickness - 2*bevelRadius,
        screwCutoutWidth,
        frameDims.z - wallThickness
    ];
    
    offsetToScrewBackCutout1 = [
        wallThickness + bevelRadius,
        bezelWidth,
        0
    ];
    
    offsetToScrewBackCutout2 = [
        offsetToScrewBackCutout1.x,
        frameDims.y - offsetToScrewBackCutout1.y - screwCutoutWidth,
        offsetToScrewBackCutout1.z
    ];
    
    offsetToControllerStandoff = [
        ((portCutout && portCutoutInset) ? portCutoutInsetDepth : wallThickness),
        .5*frameDims.y - .5*controllerHeight,
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
    
    module corner_cutout(inner) {
        cutoutOuterDims = [
            portCutoutInsetDepth + wallThickness,
            (frameDims.y - circuitHeight) / 2 + circuitHeight + wallThickness,
            controllerStandOff + portCutoutDims.y + 2*wallThickness
        ];
        
        cutoutInnerDims = [
            portCutoutInsetDepth - bevelRadius - wallThickness,
            circuitHeight - 2*wallThickness,
            controllerStandOff + portCutoutDims.y + wallThickness + epsilon
        ];
        
        cutoutDims = inner ? cutoutInnerDims : cutoutOuterDims;
        
        insetBoxRadius = inner ? bevelRadius - wallThickness : bevelRadius;
        
        cutoutOuterOffset = [0, frameDims.y - cutoutDims.y, 0];
        
        cutoutInnerOffset = [
            bevelRadius + wallThickness,
            (frameDims.y - cutoutInnerDims.y) / 2,
            -epsilon
        ];
        
        cutoutOffset = inner ? cutoutInnerOffset : cutoutOuterOffset;
        
        intersection() {
            translate(cutoutOffset)
                beveled_box(cutoutDims, insetBoxRadius, false);
            
            if(!inner) {
                translate(offsetToCircuitCutout)
                cube(circuitCutoutDims);
            }
        }
    }
    
    translate([0,0,-frameDims.z])
    intersection() {
        difference() {
            union() {
                difference() {
                    beveled_box(frameDims, bevelRadius, false);
                    
                    translate(offsetToCircuitCutout)
                        cube(circuitCutoutDims);
                    
                    translate(offsetToScrewBackCutout1)
                    translate(epsilon*[0,0,-1])
                    cube(screwBackCutoutDims + epsilon*[0,0,1]);
                   
                    translate(offsetToScrewBackCutout2)
                    translate(epsilon*[0,0,-1])
                    cube(screwBackCutoutDims + epsilon*[0,0,1]);
                    
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
                    corner_cutout(false);
                }
            }
            
            if(addControllerMount) {
                translate(offsetToControllerStandoff) {
                    if(controllerStandOff > 0)
                        controller_standoff_shell(true);
                    
                    for(screwPos = controllerScrewPositions) {
                        translate(screwPos - [0,0,epsilon])
                        cylinder(h = frameDims.z + 2*epsilon, r = controllerScrewHoleRadius, $fn = 10);
                    }
                }
            }
                    
            if(portCutout) {
                translate(offsetToPortCutout)
                translate(epsilon*[-1,0,0])
                    cube(portCutoutDimsRotated + epsilon*[2,0,1]);
                
                if(portCutoutInset) {
                    corner_cutout(true);
                }
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