//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// UIDetect 2.2 header file by brussell
// License: CC BY 4.0
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

/*
Description:
UIDetect can be used to automatically toggle shaders depending on the visibility of UI elements.
It's useful for games, where one wants to use effects like DOF, CA or AO, which however shouldn't
be active when certain UI elements are displayed (e.g. inventory, map, dialoque boxes, options
menu etc.). Multiple UIs can be defined, while each is characterized by a number of user-defined
pixels and their corresponding color values (RGB). Basically, the detection algorithm works this way:

IF ((UI1_Pixel1_Detected = true) AND (UI1_Pixel2_Detected = true) AND ... ) THEN {UI1_Detected = true}
IF ((UI1_Detected = true) OR (UI2_Detected = true) OR ... ) THEN {UI_Deteced = true}
IF (UI_Detected = true) THEN {EFFECTS = false}

Requirements and drawbacks:
-the UI elements that should be detected must be opaque and static, meaning moving or transparent
 UIs don't work with this shader
-changing graphical settings of the game most likely result in different UI pixel values,
 so set up your game properly before using UIDetect (especially resolution and anti-aliasing)

Getting suitable UI pixel values:
-take a screenshot without any shaders when the UI is visible
-open the screenshot in an image processing tool
-look for a static and opaque area in the UI layer that is usually out of reach for user actions
 like the mouse cursor, tooltips etc. (preferably somewhere in a corner of the screen)
-use a color picker tool and choose two, three or more pixels (the more the better), which are near
 to each other but differ greatly in color and brightness, and note the pixels coordinates and RGB
 values (thus choose pixels that  do not likely occur in non-UI game situations, so that effects
 couldn't get toggled accidently when there is no UI visible)
-write the pixels coordinates and UI number into the array "UIPixelCoord_UINr"
-write the pixels RGB values into the array "UIPixelRGB"
-set the total number of pixels used via the "PIXELNUMBER" parameter

UI RGB mask:
-instead of disabling shaders for the whole screen when UI pixels become visible, it's possible
 to use UI masks to spare only the UI area
-up to 3 UI masks, one for each color channel, can be defined in the image file "UIDetectMaskRGB.png"
-these 3 UI masks correspond with the first 3 UIs defined in "UIPixelCoord_UINr" (so 1 -> red,
 2 -> green, 3 -> blue); all following UIs, starting with 4, don't use masks and disable shaders for
 the whole screen)
-enabled via the "UIDetect_USE_MASK" preprocessor definition

Creating an UI RGB mask (with Gimp):
-create a new file with the same dimension as your game resolution
-select Color -> Components -> Decompose to get every color channel as a separate layer
-open a screenshot with the UI visible as a separate file
-there draw the UI area that should not be affected by effects, black and everything else white
 (a quick way is to first use Color -> Levels for this)
-copy and paste everything onto one of the separated RGB-channel layers of the first file and anchor
 the floating selection
-repeat the procedure with the other color channel layers or fill them black, thus masking the whole
 screen
-select Color -> Components -> Compose to combine the RGB channel again
-export the image as "UIDetectMaskRGB.png" and move it into the Textures folder

Required shader load order:
-UIDetect                               -> must be first in load order (needs unaltered backbuffer)
... shaders that affect UIs
-UIDetect_Before                        -> place before effects that shouldn't affect UI
... shaders that should not affect UIs
-UIDetect_After                         -> place after effects that shouldn't affect UI
... shaders that affect UIs

*/

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

#ifndef UIDetect_USE_RGB_MASK
    #define UIDetect_USE_RGB_MASK   0   // [0 or 1] Enable RGB UI mask (description above)
#endif

#ifndef UIDetect_INVERT
    #define UIDetect_INVERT         0   // [0 or 1] Enable Inverted Mode (only show effects
#endif                                  //          when UI is visible)

#ifndef UIDetect_LEGACYMODE
    #define UIDetect_LEGACYMODE     0   // [0 or 1] Enable this if you want to use your existing
#endif                                  //          pixel coordinates used with UIDetect prior to
                                        //          version 2.2+.

//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

//CUSTOM UNIVERSAL UI FIX 0.1.0
//EDEN VOLITION
//120
#define PIXELNUMBER 240
static const float3 UIPixelCoord_UINr[PIXELNUMBER]=
{
// ############################################## RESOLUTION 1920 X 1080 ###
// ######################################################## BRIGHTNESS 5 ###
	float3(1716,874,1),  	// MAP FIX [B5]
    float3(1718,865,1),		// WATCH
	
	float3(1696,229,2),  	// PAUSE FIX [ALL]
    float3(1695,223,2),		// CHAR
//################################################################# XBOX ###
	float3(130,1038,3),  	// STATUS MENU FIX [XBOX]
    float3(135,1038,3),		// B
	
	float3(391,1038,4),  	// SETTINGS MENU FIX [XBOX]
    float3(395,1038,4),		// B
	
	float3(130,1040,5),  	// EQUIP MENU FIX [XBOX]
    float3(134,1042,5),		// A

	float3(391,1038,6),  	// SETTINGS MENU FIX [XBOX]
    float3(394,1042,6),		// A
	
	float3(110,1010,7),  	// LEVEL UP MENU FIX [XBOX]
    float3(114,1013,7),		// A
//################################################################### PC ###
	float3(126,1038,8),  	// STATUS MENU FIX [PC]
    float3(130,1038,8),		// Q
	
	float3(386,1038,9),  	// SETTINGS MENU FIX [PC]
    float3(390,1038,9),		// Q
	
	float3(130,1040,10),  	// EQUIP MENU FIX [PC]
    float3(134,1040,10),	// E
	
	float3(390,1038,11),  	// SETTINGS MENU FIX [PC]
    float3(395,1038,11),	// E
	
	float3(112,1010,12),  	// LEVEL UP MENU FIX [PC]
    float3(114,1010,12),	// E
// ##########################################################################
// ##########################################################################


// ############################################## RESOLUTION 1920 X 1080 ###
// ######################################################## BRIGHTNESS 4 ###
	float3(1716,874,13),  	// MAP FIX [B5]
    float3(1718,865,13),	// WATCH
	
	float3(1696,229,14),  	// PAUSE FIX [ALL]
    float3(1695,223,14),	// CHAR
//################################################################# XBOX ###
	float3(130,1038,15),  	// STATUS MENU FIX [XBOX]
    float3(135,1038,15),	// B
	
	float3(391,1038,16),  	// SETTINGS MENU FIX [XBOX]
    float3(395,1038,16),	// B
	
	float3(130,1040,17),  	// EQUIP MENU FIX [XBOX]
    float3(134,1042,17),	// A

	float3(391,1038,18),  	// SETTINGS MENU FIX [XBOX]
    float3(394,1042,18),	// A
	
	float3(110,1010,19),  	// LEVEL UP MENU FIX [XBOX]
    float3(114,1013,19),	// A
//################################################################### PC ###
	float3(126,1038,20),  	// STATUS MENU FIX [PC]
    float3(130,1038,20),	// Q
	
	float3(386,1038,21),  	// SETTINGS MENU FIX [PC]
    float3(390,1038,21),	// Q
	
	float3(130,1040,22),  	// EQUIP MENU FIX [PC]
    float3(134,1040,22),	// E
	
	float3(390,1038,23),  	// SETTINGS MENU FIX [PC]
    float3(395,1038,23),	// E
	
	float3(112,1010,24),  	// LEVEL UP MENU FIX [PC]
    float3(114,1010,24),	// E
// ##########################################################################
// ##########################################################################


// ############################################## RESOLUTION 1920 X 1080 ###
// ######################################################## BRIGHTNESS 3 ###
	float3(1716,874,25),  	// MAP FIX [B5]
    float3(1718,865,25),	// WATCH
	
	float3(1696,229,26),  	// PAUSE FIX [ALL]
    float3(1695,223,26),	// CHAR
//################################################################# XBOX ###
	float3(130,1038,27),  	// STATUS MENU FIX [XBOX]
    float3(135,1038,27),	// B
	
	float3(391,1038,28),  	// SETTINGS MENU FIX [XBOX]
    float3(395,1038,28),	// B
	
	float3(130,1040,29),  	// EQUIP MENU FIX [XBOX]
    float3(134,1042,29),	// A

	float3(391,1038,30),  	// SETTINGS MENU FIX [XBOX]
    float3(394,1042,30),	// A
	
	float3(110,1010,31),  	// LEVEL UP MENU FIX [XBOX]
    float3(114,1013,31),	// A
//################################################################### PC ###
	float3(126,1038,32),  	// STATUS MENU FIX [PC]
    float3(130,1038,32),	// Q
	
	float3(386,1038,33),  	// SETTINGS MENU FIX [PC]
    float3(390,1038,33),	// Q
	
	float3(130,1040,34),  	// EQUIP MENU FIX [PC]
    float3(134,1040,34),	// E
	
	float3(390,1038,35),  	// SETTINGS MENU FIX [PC]
    float3(395,1038,35),	// E
	
	float3(112,1010,36),  	// LEVEL UP MENU FIX [PC]
    float3(114,1010,36),	// E
// ##########################################################################
// ##########################################################################


// ############################################## RESOLUTION 1920 X 1080 ###
// ######################################################## BRIGHTNESS 6 ###
	float3(1716,874,37),  	// MAP FIX [B5]
    float3(1718,865,37),	// WATCH
	
	float3(1696,229,38),  	// PAUSE FIX [ALL]
    float3(1695,223,38),	// CHAR
//################################################################# XBOX ###
	float3(130,1038,39),  	// STATUS MENU FIX [XBOX]
    float3(135,1038,39),	// B
	
	float3(391,1038,40),  	// SETTINGS MENU FIX [XBOX]
    float3(395,1038,40),	// B
	
	float3(130,1040,41),  	// EQUIP MENU FIX [XBOX]
    float3(134,1042,41),	// A

	float3(391,1038,42),  	// SETTINGS MENU FIX [XBOX]
    float3(394,1042,42),	// A
	
	float3(110,1010,43),  	// LEVEL UP MENU FIX [XBOX]
    float3(114,1013,43),	// A
//################################################################### PC ###
	float3(126,1038,44),  	// STATUS MENU FIX [PC]
    float3(130,1038,44),	// Q
	
	float3(386,1038,45),  	// SETTINGS MENU FIX [PC]
    float3(390,1038,45),	// Q
	
	float3(130,1040,46),  	// EQUIP MENU FIX [PC]
    float3(134,1040,46),	// E
	
	float3(390,1038,47),  	// SETTINGS MENU FIX [PC]
    float3(395,1038,47),	// E
	
	float3(112,1010,48),  	// LEVEL UP MENU FIX [PC]
    float3(114,1010,48),	// E
// ##########################################################################
// ##########################################################################


// ############################################## RESOLUTION 1920 X 1080 ###
// ######################################################## BRIGHTNESS 7 ###
	float3(1716,874,49),  	// MAP FIX [B5]
    float3(1718,865,49),	// WATCH
	
	float3(1696,229,50),  	// PAUSE FIX [ALL]
    float3(1695,223,50),	// CHAR
//################################################################# XBOX ###
	float3(130,1038,51),  	// STATUS MENU FIX [XBOX]
    float3(135,1038,51),	// B
	
	float3(391,1038,52),  	// SETTINGS MENU FIX [XBOX]
    float3(395,1038,52),	// B
	
	float3(130,1040,53),  	// EQUIP MENU FIX [XBOX]
    float3(134,1042,53),	// A

	float3(391,1038,54),  	// SETTINGS MENU FIX [XBOX]
    float3(394,1042,54),	// A
	
	float3(110,1010,55),  	// LEVEL UP MENU FIX [XBOX]
    float3(114,1013,55),	// A
//################################################################### PC ###
	float3(126,1038,56),  	// STATUS MENU FIX [PC]
    float3(130,1038,56),	// Q
	
	float3(386,1038,57),  	// SETTINGS MENU FIX [PC]
    float3(390,1038,57),	// Q
	
	float3(130,1040,58),  	// EQUIP MENU FIX [PC]
    float3(134,1040,58),	// E
	
	float3(390,1038,59),  	// SETTINGS MENU FIX [PC]
    float3(395,1038,59),	// E
	
	float3(112,1010,60),  	// LEVEL UP MENU FIX [PC]
    float3(114,1010,60),	// E
// ##########################################################################
// ##########################################################################

// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .

// ############################################## RESOLUTION 2560 X 1440 ###
// ######################################################## BRIGHTNESS 5 ###
	float3(2288,1165,61),  	// MAP FIX [B5]
    float3(2291,1154,61),	// WATCH
	
	float3(2261,306,62),  	// PAUSE FIX [ALL]
    float3(2262,298,62),		// CHAR
//################################################################# XBOX ###
	float3(177,1385,63),  	// STATUS MENU FIX [XBOX]
    float3(180,1385,63),		// B
	
	float3(522,1385,64),  	// SETTINGS MENU FIX [XBOX]
    float3(526,1385,64),		// B
	
	float3(173,1390,65),  	// EQUIP MENU FIX [XBOX]
    float3(179,1390,65),		// A

	float3(520,1390,66),  	// SETTINGS MENU FIX [XBOX]
    float3(525,1390,66),		// A
	
	float3(152,1351,67),  	// LEVEL UP MENU FIX [XBOX]
    float3(147,1351,67),		// A
//################################################################### PC ###
	float3(172,1394,68),  	// STATUS MENU FIX [PC]
    float3(179,1394,68),		// Q
	
	float3(519,1394,69),  	// SETTINGS MENU FIX [PC]
    float3(528,1394,69),		// Q
	
	float3(174,1385,70),  	// EQUIP MENU FIX [PC]
    float3(179,1385,70),	// E
	
	float3(520,1394,71),  	// SETTINGS MENU FIX [PC]
    float3(526,1394,71),	// E
	
	float3(147,1345,72),  	// LEVEL UP MENU FIX [PC]
    float3(153,1345,72),	// E
// ##########################################################################
// ##########################################################################

// ############################################## RESOLUTION 2560 X 1440 ###
// ######################################################## BRIGHTNESS 4 ###
	float3(2288,1165,73),  	// MAP FIX [B5]
    float3(2291,1154,73),	// WATCH
	
	float3(2261,306,74),  	// PAUSE FIX [ALL]
    float3(2262,298,74),		// CHAR
//################################################################# XBOX ###
	float3(177,1385,75),  	// STATUS MENU FIX [XBOX]
    float3(180,1385,75),		// B
	
	float3(522,1385,76),  	// SETTINGS MENU FIX [XBOX]
    float3(526,1385,76),		// B
	
	float3(173,1390,77),  	// EQUIP MENU FIX [XBOX]
    float3(179,1390,77),		// A

	float3(520,1390,78),  	// SETTINGS MENU FIX [XBOX]
    float3(525,1390,78),		// A
	
	float3(152,1351,79),  	// LEVEL UP MENU FIX [XBOX]
    float3(147,1351,79),		// A
//################################################################### PC ###
	float3(172,1394,80),  	// STATUS MENU FIX [PC]
    float3(179,1394,80),		// Q
	
	float3(519,1394,81),  	// SETTINGS MENU FIX [PC]
    float3(528,1394,81),		// Q
	
	float3(174,1385,82),  	// EQUIP MENU FIX [PC]
    float3(179,1385,82),	// E
	
	float3(520,1394,83),  	// SETTINGS MENU FIX [PC]
    float3(526,1394,83),	// E
	
	float3(147,1345,84),  	// LEVEL UP MENU FIX [PC]
    float3(153,1345,84),	// E
// ##########################################################################
// ##########################################################################

// ############################################## RESOLUTION 2560 X 1440 ###
// ######################################################## BRIGHTNESS 3 ###
	float3(2288,1165,85),  	// MAP FIX [B5]
    float3(2291,1154,85),	// WATCH
	
	float3(2261,306,86),  	// PAUSE FIX [ALL]
    float3(2262,298,86),		// CHAR
//################################################################# XBOX ###
	float3(177,1385,87),  	// STATUS MENU FIX [XBOX]
    float3(180,1385,87),		// B
	
	float3(522,1385,88),  	// SETTINGS MENU FIX [XBOX]
    float3(526,1385,88),		// B
	
	float3(173,1390,89),  	// EQUIP MENU FIX [XBOX]
    float3(179,1390,89),		// A

	float3(520,1390,90),  	// SETTINGS MENU FIX [XBOX]
    float3(525,1390,90),		// A
	
	float3(152,1351,91),  	// LEVEL UP MENU FIX [XBOX]
    float3(147,1351,91),		// A
//################################################################### PC ###
	float3(172,1394,92),  	// STATUS MENU FIX [PC]
    float3(179,1394,92),		// Q
	
	float3(519,1394,93),  	// SETTINGS MENU FIX [PC]
    float3(528,1394,93),		// Q
	
	float3(174,1385,94),  	// EQUIP MENU FIX [PC]
    float3(179,1385,94),	// E
	
	float3(520,1394,95),  	// SETTINGS MENU FIX [PC]
    float3(526,1394,95),	// E
	
	float3(147,1345,96),  	// LEVEL UP MENU FIX [PC]
    float3(153,1345,96),	// E
// ##########################################################################
// ##########################################################################

// ############################################## RESOLUTION 2560 X 1440 ###
// ######################################################## BRIGHTNESS 6 ###
	float3(2288,1165,97),  	// MAP FIX [B5]
    float3(2291,1154,97),	// WATCH
	
	float3(2261,306,98),  	// PAUSE FIX [ALL]
    float3(2262,298,98),		// CHAR
//################################################################# XBOX ###
	float3(177,1385,99),  	// STATUS MENU FIX [XBOX]
    float3(180,1385,99),		// B
	
	float3(522,1385,100),  	// SETTINGS MENU FIX [XBOX]
    float3(526,1385,100),		// B
	
	float3(173,1390,101),  	// EQUIP MENU FIX [XBOX]
    float3(179,1390,101),		// A

	float3(520,1390,102),  	// SETTINGS MENU FIX [XBOX]
    float3(525,1390,102),		// A
	
	float3(152,1351,103),  	// LEVEL UP MENU FIX [XBOX]
    float3(147,1351,103),		// A
//################################################################### PC ###
	float3(172,1394,104),  	// STATUS MENU FIX [PC]
    float3(179,1394,104),		// Q
	
	float3(519,1394,105),  	// SETTINGS MENU FIX [PC]
    float3(528,1394,105),		// Q
	
	float3(174,1385,106),  	// EQUIP MENU FIX [PC]
    float3(179,1385,106),	// E
	
	float3(520,1394,107),  	// SETTINGS MENU FIX [PC]
    float3(526,1394,107),	// E
	
	float3(147,1345,108),  	// LEVEL UP MENU FIX [PC]
    float3(153,1345,108),	// E
// ##########################################################################
// ##########################################################################

// ############################################## RESOLUTION 2560 X 1440 ###
// ######################################################## BRIGHTNESS 7 ###
	float3(2288,1165,109),  	// MAP FIX [B5]
    float3(2291,1154,109),	// WATCH
	
	float3(2261,306,110),  	// PAUSE FIX [ALL]
    float3(2262,298,110),		// CHAR
//################################################################# XBOX ###
	float3(177,1385,111),  	// STATUS MENU FIX [XBOX]
    float3(180,1385,111),		// B
	
	float3(522,1385,112),  	// SETTINGS MENU FIX [XBOX]
    float3(526,1385,112),		// B
	
	float3(173,1390,113),  	// EQUIP MENU FIX [XBOX]
    float3(179,1390,113),		// A

	float3(520,1390,114),  	// SETTINGS MENU FIX [XBOX]
    float3(525,1390,114),		// A
	
	float3(152,1351,115),  	// LEVEL UP MENU FIX [XBOX]
    float3(147,1351,115),		// A
//################################################################### PC ###
	float3(172,1394,116),  	// STATUS MENU FIX [PC]
    float3(179,1394,116),		// Q
	
	float3(519,1394,117),  	// SETTINGS MENU FIX [PC]
    float3(528,1394,117),		// Q
	
	float3(174,1385,118),  	// EQUIP MENU FIX [PC]
    float3(179,1385,118),	// E
	
	float3(520,1394,119),  	// SETTINGS MENU FIX [PC]
    float3(526,1394,119),	// E
	
	float3(147,1345,120),  	// LEVEL UP MENU FIX [PC]
    float3(153,1345,120),	// E
// ##########################################################################
// ##########################################################################


};











static const float3 UIPixelRGB[PIXELNUMBER]=
{
// ############################################## RESOLUTION 1920 X 1080 ###
// ######################################################## BRIGHTNESS 5 ###
	float3(1,1,1), 			// MAP FIX [B5]
    float3(174,170,151),	// WATCH
	
	float3(204,188,158),	// PAUSE FIX [ALL]
	float3(87,71,38),		// CHAR
//################################################################# XBOX ###
	float3(11,7,1),  		// STATUS MENU FIX [XBOX]
    float3(159,120,126),	// B
	
	float3(11,7,1),  		// SETTINGS MENU FIX [XBOX]
    float3(159,120,126),	// B
	
	float3(11,7,1),  		// EQUIP MENU FIX [XBOX]
    float3(131,159,129),	// A
	
	float3(11,7,1),  		// SETTINGS MENU FIX [XBOX]
    float3(131,159,129),	// A
	
	float3(11,7,1),  		// LEVEL UP MENU FIX [XBOX]
    float3(131,159,129),	// A
//################################################################### PC ###
	float3(27,23,22),  		// STATUS MENU FIX [PC]
    float3(215,215,215),	// Q
	
	float3(27,23,22),  		// SETTINGS MENU FIX [PC]
    float3(215,215,215),	// Q
	
	float3(27,23,22),  		// EQUIP MENU FIX [PC]
    float3(215,215,215),	// E
	
	float3(27,23,22),  		// SETTINGS MENU FIX [PC]
    float3(215,215,215),	// E
	
	float3(27,23,22),  		// LEVEL UP MENU FIX [PC]
    float3(215,215,215),	// E
// ##########################################################################
// ##########################################################################


// ############################################## RESOLUTION 1920 X 1080 ###
// ######################################################## BRIGHTNESS 4 ###
	float3(1,1,1), 			// MAP FIX [B5]
    float3(171,167,148),	// WATCH
	
	float3(202,186,155),	// PAUSE FIX [ALL]
	float3(83,68,35),		// CHAR
//################################################################# XBOX ###
	float3(10,6,1),  		// STATUS MENU FIX [XBOX]
    float3(156,117,123),	// B
	
	float3(10,6,1),  		// SETTINGS MENU FIX [XBOX]
    float3(156,117,123),	// B
	
	float3(10,6,1),  		// EQUIP MENU FIX [XBOX]
    float3(128,156,126),	// A
	
	float3(10,6,1),  		// SETTINGS MENU FIX [XBOX]
    float3(128,156,126),	// A
	
	float3(10,6,1),  		// LEVEL UP MENU FIX [XBOX]
    float3(128,156,126),	// A
//################################################################### PC ###
	
	float3(25,21,20),  		// STATUS MENU FIX [PC]
    float3(214,214,214),	// Q
	
	float3(25,21,20),  		// SETTINGS MENU FIX [PC]
    float3(214,214,214),	// Q
	
	float3(25,21,20),  		// EQUIP MENU FIX [PC]
    float3(214,214,214),	// E
	
	float3(25,21,20),  		// SETTINGS MENU FIX [PC]
    float3(214,214,214),	// E
	
	float3(25,21,20),  		// LEVEL UP MENU FIX [PC]
    float3(214,214,214),	// E
// ##########################################################################
// ##########################################################################

// ############################################## RESOLUTION 1920 X 1080 ###
// ######################################################## BRIGHTNESS 3 ###
	float3(1,1,1), 			// MAP FIX [B5]
    float3(169,165,145),	// WATCH
	
	float3(200,184,152),	// PAUSE FIX [ALL]
	float3(80,64,33),		// CHAR
//################################################################# XBOX ###
	float3(9,5,1),  		// STATUS MENU FIX [XBOX]
    float3(153,113,119),	// B
	
	float3(9,5,1),  		// SETTINGS MENU FIX [XBOX]
    float3(153,113,119),	// B
	
	float3(9,5,1),  		// EQUIP MENU FIX [XBOX]
    float3(124,153,122),	// A
	
	float3(9,5,1),  		// SETTINGS MENU FIX [XBOX]
    float3(124,153,122),	// A
	
	float3(9,5,1),  		// LEVEL UP MENU FIX [XBOX]
    float3(124,153,122),	// A
//################################################################### PC ###
	
	float3(23,29,28),  		// STATUS MENU FIX [PC]
    float3(212,212,212),	// Q
	
	float3(23,29,28),  		// SETTINGS MENU FIX [PC]
    float3(212,212,212),	// Q
	
	float3(23,29,28),  		// EQUIP MENU FIX [PC]
    float3(212,212,212),	// E
	
	float3(23,29,28),  		// SETTINGS MENU FIX [PC]
    float3(212,212,212),	// E
	
	float3(23,29,28),  		// LEVEL UP MENU FIX [PC]
    float3(212,212,212),	// E
// ##########################################################################
// ##########################################################################


// ############################################## RESOLUTION 1920 X 1080 ###
// ######################################################## BRIGHTNESS 6 ###
	float3(1,1,1), 			// MAP FIX [B5]
    float3(176,172,154),	// WATCH
	
	float3(206,190,161),	// PAUSE FIX [ALL]
	float3(90,74,41),		// CHAR
//################################################################# XBOX ###
	float3(12,8,1),  		// STATUS MENU FIX [XBOX]
    float3(162,123,129),	// B
	
	float3(12,8,1),  		// SETTINGS MENU FIX [XBOX]
    float3(162,123,129),	// B
	
	float3(12,8,1),  		// EQUIP MENU FIX [XBOX]
    float3(134,162,132),	// A
	
	float3(12,8,1),  		// SETTINGS MENU FIX [XBOX]
    float3(134,162,132),	// A
	
	float3(12,8,1),  		// LEVEL UP MENU FIX [XBOX]
    float3(134,162,132),	// A
//################################################################### PC ###
	float3(29,25,24),  		// STATUS MENU FIX [PC]
    float3(216,216,216),	// Q
	
	float3(29,25,24),  		// SETTINGS MENU FIX [PC]
    float3(216,216,216),	// Q
	
	float3(29,25,24),  		// EQUIP MENU FIX [PC]
    float3(216,216,216),	// E
	
	float3(29,25,24),  		// SETTINGS MENU FIX [PC]
    float3(216,216,216),	// E
	
	float3(29,25,24),  		// LEVEL UP MENU FIX [PC]
    float3(216,216,216),	// E
// ##########################################################################
// ##########################################################################


// ############################################## RESOLUTION 1920 X 1080 ###
// ######################################################## BRIGHTNESS 7 ###
	float3(1,1,1), 			// MAP FIX [B5]
    float3(179,175,156),	// WATCH
	
	float3(207,192,163),	// PAUSE FIX [ALL]
	float3(94,77,43),		// CHAR
//################################################################# XBOX ###
	float3(14,9,1),  		// STATUS MENU FIX [XBOX]
    float3(164,126,132),	// B
	
	float3(14,9,1),  		// SETTINGS MENU FIX [XBOX]
    float3(164,126,132),	// B
	
	float3(14,9,1),  		// EQUIP MENU FIX [XBOX]
    float3(137,164,135),	// A
	
	float3(14,9,1),  		// SETTINGS MENU FIX [XBOX]
    float3(137,164,135),	// A
	
	float3(14,9,1),  		// LEVEL UP MENU FIX [XBOX]
    float3(137,164,135),	// A
//################################################################### PC ###
	float3(31,27,26),  		// STATUS MENU FIX [PC]
    float3(217,217,217),	// Q
	
	float3(31,27,26),  		// SETTINGS MENU FIX [PC]
    float3(217,217,217),	// Q
	
	float3(31,27,26),  		// EQUIP MENU FIX [PC]
    float3(217,217,217),	// E
	
	float3(31,27,26),  		// SETTINGS MENU FIX [PC]
    float3(217,217,217),	// E
	
	float3(31,27,26),  		// LEVEL UP MENU FIX [PC]
    float3(217,217,217),	// E
// ##########################################################################
// ##########################################################################

// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .
// .

// ############################################## RESOLUTION 2560 X 1440 ###
// ######################################################## BRIGHTNESS 5 ###
	float3(1,1,1), 			// MAP FIX [B5]
    float3(172,170,150),	// WATCH
	
	float3(203,187,157),	// PAUSE FIX [ALL]
	float3(80,64,33),		// CHAR
//################################################################# XBOX ###
	float3(11,7,1),  		// STATUS MENU FIX [XBOX]
    float3(159,120,126),	// B
	
	float3(11,7,1),  		// SETTINGS MENU FIX [XBOX]
    float3(159,120,126),	// B
	
	float3(11,7,1),  		// EQUIP MENU FIX [XBOX]
    float3(130,158,128),	// A
	
	float3(11,7,1),  		// SETTINGS MENU FIX [XBOX]
    float3(130,158,128),	// A
	
	float3(11,7,1),  		// LEVEL UP MENU FIX [XBOX]
    float3(131,159,129),	// A
//################################################################### PC ###
	float3(27,23,22),  		// STATUS MENU FIX [PC]
    float3(215,215,215),	// Q
	
	float3(27,23,22),  		// SETTINGS MENU FIX [PC]
    float3(215,215,215),	// Q
	
	float3(27,23,22),  		// EQUIP MENU FIX [PC]
    float3(215,215,215),	// E
	
	float3(27,23,22),  		// SETTINGS MENU FIX [PC]
    float3(215,215,215),	// E
	
	float3(27,23,22),  		// LEVEL UP MENU FIX [PC]
    float3(215,215,215),	// E
// ##########################################################################
// ##########################################################################

// ############################################## RESOLUTION 2560 X 1440 ###
// ######################################################## BRIGHTNESS 4 ###
	float3(1,1,1), 			// MAP FIX [B5]
    float3(169,167,147),	// WATCH
	
	float3(201,185,154),	// PAUSE FIX [ALL]
	float3(77,61,31),		// CHAR
//################################################################# XBOX ###
	float3(10,6,1),  		// STATUS MENU FIX [XBOX]
    float3(156,117,123),	// B
	
	float3(10,6,1),  		// SETTINGS MENU FIX [XBOX]
    float3(156,117,123),	// B
	
	float3(10,6,1),  		// EQUIP MENU FIX [XBOX]
    float3(127,155,125),	// A
	
	float3(10,6,1),  		// SETTINGS MENU FIX [XBOX]
    float3(127,155,125),	// A
	
	float3(10,6,1),  		// LEVEL UP MENU FIX [XBOX]
    float3(128,156,126),	// A
//################################################################### PC ###
	
	float3(25,21,20),  		// STATUS MENU FIX [PC]
    float3(214,214,214),	// Q
	
	float3(25,21,20),  		// SETTINGS MENU FIX [PC]
    float3(214,214,214),	// Q
	
	float3(25,21,20),  		// EQUIP MENU FIX [PC]
    float3(214,214,214),	// E
	
	float3(25,21,20),  		// SETTINGS MENU FIX [PC]
    float3(214,214,214),	// E
	
	float3(25,21,20),  		// LEVEL UP MENU FIX [PC]
    float3(214,214,214),	// E
// ##########################################################################
// ##########################################################################

// ############################################## RESOLUTION 2560 X 1440 ###
// ######################################################## BRIGHTNESS 3 ###
	float3(1,1,1), 			// MAP FIX [B5]
    float3(167,165,144),	// WATCH
	
	float3(199,182,151),	// PAUSE FIX [ALL]
	float3(73,57,28),		// CHAR
//################################################################# XBOX ###
	float3(9,5,1),  		// STATUS MENU FIX [XBOX]
    float3(153,113,119),	// B
	
	float3(9,5,1),  		// SETTINGS MENU FIX [XBOX]
    float3(153,113,119),	// B
	
	float3(9,5,1),  		// EQUIP MENU FIX [XBOX]
    float3(123,152,121),	// A
	
	float3(9,5,1),  		// SETTINGS MENU FIX [XBOX]
    float3(123,152,121),	// A
	
	float3(9,5,1),  		// LEVEL UP MENU FIX [XBOX]
    float3(124,153,122),	// A
//################################################################### PC ###
	
	float3(23,29,28),  		// STATUS MENU FIX [PC]
    float3(212,212,212),	// Q
	
	float3(23,29,28),  		// SETTINGS MENU FIX [PC]
    float3(212,212,212),	// Q
	
	float3(23,29,28),  		// EQUIP MENU FIX [PC]
    float3(212,212,212),	// E
	
	float3(23,29,28),  		// SETTINGS MENU FIX [PC]
    float3(212,212,212),	// E
	
	float3(23,29,28),  		// LEVEL UP MENU FIX [PC]
    float3(212,212,212),	// E
// ##########################################################################
// ##########################################################################

// ############################################## RESOLUTION 2560 X 1440 ###
// ######################################################## BRIGHTNESS 6 ###
	float3(1,1,1), 			// MAP FIX [B5]
    float3(174,172,153),	// WATCH
	
	float3(205,189,160),	// PAUSE FIX [ALL]
	float3(83,67,35),		// CHAR
//################################################################# XBOX ###
	float3(12,8,1),  		// STATUS MENU FIX [XBOX]
    float3(162,123,129),	// B
	
	float3(12,8,1),  		// SETTINGS MENU FIX [XBOX]
    float3(162,123,129),	// B
	
	float3(12,8,1),  		// EQUIP MENU FIX [XBOX]
    float3(132,161,131),	// A
	
	float3(12,8,1),  		// SETTINGS MENU FIX [XBOX]
    float3(133,161,131),	// A
	
	float3(12,8,1),  		// LEVEL UP MENU FIX [XBOX]
    float3(134,162,132),	// A
//################################################################### PC ###
	float3(29,25,24),  		// STATUS MENU FIX [PC]
    float3(216,216,216),	// Q
	
	float3(29,25,24),  		// SETTINGS MENU FIX [PC]
    float3(216,216,216),	// Q
	
	float3(29,25,24),  		// EQUIP MENU FIX [PC]
    float3(216,216,216),	// E
	
	float3(29,25,24),  		// SETTINGS MENU FIX [PC]
    float3(216,216,216),	// E
	
	float3(29,25,24),  		// LEVEL UP MENU FIX [PC]
    float3(216,216,216),	// E
// ##########################################################################
// ##########################################################################

// ############################################## RESOLUTION 2560 X 1440 ###
// ######################################################## BRIGHTNESS 7 ###
	float3(1,1,1), 			// MAP FIX [B5]
    float3(177,175,155),	// WATCH
	
	float3(206,191,162),	// PAUSE FIX [ALL]
	float3(87,70,38),		// CHAR
//################################################################# XBOX ###
	float3(14,9,1),  		// STATUS MENU FIX [XBOX]
    float3(164,126,132),	// B
	
	float3(14,9,1),  		// SETTINGS MENU FIX [XBOX]
    float3(164,126,132),	// B
	
	float3(14,9,1),  		// EQUIP MENU FIX [XBOX]
    float3(136,163,134),	// A
	
	float3(14,9,1),  		// SETTINGS MENU FIX [XBOX]
    float3(136,163,134),	// A
	
	float3(14,9,1),  		// LEVEL UP MENU FIX [XBOX]
    float3(137,164,135),	// A
//################################################################### PC ###
	float3(31,27,26),  		// STATUS MENU FIX [PC]
    float3(217,217,217),	// Q
	
	float3(31,27,26),  		// SETTINGS MENU FIX [PC]
    float3(217,217,217),	// Q
	
	float3(31,27,26),  		// EQUIP MENU FIX [PC]
    float3(217,217,217),	// E
	
	float3(31,27,26),  		// SETTINGS MENU FIX [PC]
    float3(217,217,217),	// E
	
	float3(31,27,26),  		// LEVEL UP MENU FIX [PC]
    float3(217,217,217),	// E
// ##########################################################################
// ##########################################################################

};
