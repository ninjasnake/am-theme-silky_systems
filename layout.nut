//
// Attract-Mode Front-End - SILKY v0.6.8 beta
// 2017, Oomek
//

class UserConfig {
	</ label="Snaps List", help="Enables or disables the snaps column", options="Show, Hide", order=1 /> carrier="Hide"
	</ label="Snaps Count", help="Number of snaps in the column", options="3,5,7,9", order=2 /> elements="5"
	</ label="Game List Rows", help="How many games to display on the list", options="11,13,15,17,19,21,23,25,27,29,31", order=3 /> rows="19"
	</ label="Game List Auto Hide", help="Time in seconds after which game list hides\n0 disables auto hide and flyer. Default value is 3", option="0", order=4 /> glautohide="2"
	</ label="Snaps or Videos", help="Specify what to show on the left pane.", options="Snaps,Videos,Videos Muted", order=5 /> snaps="Videos"
	</ label="Scanline filter", help="", options="On,Off", order=6 /> scanline="On"
	</ label="Background colour as R,G,B", help="( 0-255 values allowed )\nSets the colour of background elements.\nLeave blank if you want the colour from the randomized to be stored permanently.", option="0", order=7 /> bgrgb="17,72,117"
	</ label="Accent colour as R,G,B", help="( 0-255 values allowed )\nSets the colour of accent elements.\nLeave blank if you want the colour from the randomized to be stored permanently.", option="0", order=8 /> selrgb="220,98,21"
 }

 
// Check if the AM version supporting .nomargin property is running
local am_version_check = fe.add_text("", 0, 0, 0, 0)
try{ am_version_check.nomargin = true }catch(e){	while (!fe.overlay.splash_message( "You are running an older version of Attract Mode.\nPlease update to the latest nightly build.")){} return }
am_version_check.visible = false
 
 
fe.do_nut("nuts/ryb2rgb.nut")
fe.do_nut("nuts/animate.nut")
fe.do_nut("nuts/carrier.nut")
fe.do_nut("nuts/genre.nut")


function irand(max) {
	local roll = (1.0 * rand() / RAND_MAX) * (max + 1)
	return roll.tointeger()
}

local my_config = fe.get_config()
local layout_width = fe.layout.width
local layout_height = fe.layout.height
local flx = ( fe.layout.width - layout_width ) / 2
local fly = ( fe.layout.height - layout_height ) / 2
local flw = layout_width
local flh = layout_height

local glist_delay = my_config["glautohide"].tointeger() * 1000
local glr = my_config["rows"].tointeger()
local crc = my_config["elements"].tointeger()
local bth = floor( flh * 160.0 / 1080.0 )
local bbh = floor( flh * 160.0 / 1080.0 )
local bbm = ceil( bbh * 0.2 )
local lbw = floor( flh * 540.0 / 1080.0 )

local update_artwork = false
local update_counter = 0

local cr_en = false
local crw = 0
//if( my_config["carrier"] == "Show") {
//	crw = floor( ( flh / crc ) * 300.0 / 216.0 )
//	cr_en = true
//}

local bgRYB = [irand(255), irand(255), irand(255)]
local selRYB = [255 - bgRYB[0], 255 - bgRYB[1], 255 - bgRYB[2]]

local bgRGB = ryb2rgb(bgRYB)
local selRGB = ryb2rgb(selRYB)

try { bgRGB = fe.nv[0] } catch(e) {}
try { selRGB = fe.nv[1] } catch(e) {}

local error_message = false
if( my_config["bgrgb"] != "" ) {
	try { bgRGB = split(my_config["bgrgb"], ",").map(function(value) return value.tointeger()) }
	catch(e) { error_message = true}
}

if( my_config["selrgb"] != "" ) {
	try { selRGB = split(my_config["selrgb"], ",").map(function(value) return value.tointeger()) }
	catch(e) { error_message = true}
}

if ( error_message || bgRGB.len() != 3 || selRGB.len() != 3)
	while (!fe.overlay.splash_message( "Background or Accent colour has a wrong format.\nPlease check it in Layout Options")){} 

// Flyer
local flyerH = flh - bth - bbh
local flyerW = lbw
local flyer = fe.add_artwork("flyer", flw + flx - crw - flyerW, bth, flyerW, flyerH )
//flyer.trigger = Transition.EndNavigation
flyer.trigger = 0


// Game ListBox Background
local gameListBoxBackground = fe.add_text("", flx + flw - crw, bth, lbw, flh - bth - bbh )
gameListBoxBackground.set_bg_rgb( bgRGB[0] * 0.75, bgRGB[1] * 0.75, bgRGB[2] * 0.75 )
gameListBoxBackground.bg_alpha = 0


// Game ListBox
local gameListBox = fe.add_listbox( flx + flw - crw, bth, lbw, flh - bth - bbh)
gameListBox.align = Align.Left
gameListBox.rows = glr
gameListBox.charsize = floor( floor( flh - bth - bbh ) / glr * 0.7 )
gameListBox.set_sel_rgb( 240, 240, 240 )
gameListBox.set_selbg_rgb( selRGB[0], selRGB[1], selRGB[2] )
gameListBox.set_bg_rgb( 255, 0, 0 )
gameListBox.font = "BebasNeueRegular.otf"
gameListBox.style = Style.Regular
gameListBox.sel_style = Style.Regular
gameListBox.y += floor( ( gameListBox.height - ( floor( gameListBox.height / gameListBox.rows ) * gameListBox.rows ) ) / 2 )


// Game Listbox Animations
local gameListBoxAnimX = Animate( gameListBox, "x", 4, glist_delay, 0.88 )
local gameListBoxAnimA = Animate( gameListBox, "listbox_alpha", 1, glist_delay, 0.88 )
local gameListBoxBackgroundAnimX = Animate( gameListBoxBackground, "x", 4, glist_delay, 0.88 )
local gameListBoxBackgroundAnimA = Animate( gameListBoxBackground, "bg_alpha", 1, glist_delay, 0.88 )
if ( glist_delay == 0 ) {
	gameListBoxAnimX.to = flw + flx - crw - lbw
	gameListBoxBackgroundAnimX.to = flw + flx - crw - lbw
	gameListBoxAnimA.to = 255
	gameListBoxBackgroundAnimA.to = 255
}

// Snap Background
local snapBackground = fe.add_image( "images/gradientV.png", flx, bth, flw - crw - flyerW, flh - bth - bbh )
snapBackground.set_rgb( bgRGB[0] * 0.6, bgRGB[1] * 0.6, bgRGB[2] * 0.6 )


// Snap
local snapW = flw - crw - flyerW - bbm * 2
local snapH = flh - bth - bbh - bbm * 2
local snapX = flx + bbm
local snapY = bth + bbm
local snap = fe.add_artwork( "snap", snapX, snapY, snapW, snapH )

//snap.trigger = Transition.EndNavigation
snap.trigger = 0

snap.preserve_aspect_ratio = false
if ( my_config["snaps"] == "Snaps" )
	snap.video_flags = Vid.ImagesOnly
else if ( my_config["snaps"] == "Videos Muted" )
	snap.video_flags = Vid.NoAudio


// Custom Shader
local snapSourceH = 0
local shader_enabled = 0
if ( my_config["scanline"] == "On" ) shader_enabled = 1
local shader = fe.add_shader( Shader.VertexAndFragment, "crt.vert", "crt.frag" )
shader.set_param( "params", snapH, shader_enabled )
snap.shader = shader


 // Top Background
local bannerTop = fe.add_text( "", flx, 0, flw, bth)
bannerTop.set_bg_rgb( bgRGB[0], bgRGB[1], bgRGB[2] )


// Bottom Background
local bannerBottom = fe.add_text( "", flx, flh - bbh, flw, bbh)
bannerBottom.set_bg_rgb( bgRGB[0], bgRGB[1], bgRGB[2] )


// Favourite Icon
local favIconMargin = floor(bbh * 0.0625)
local favouriteIcon = fe.add_image("images/star.png", flx + favIconMargin, flh - bbh + favIconMargin, bbh - favIconMargin * 2, bbh - favIconMargin * 2)
favouriteIcon.set_rgb( selRGB[0], selRGB[1], selRGB[2] )
 
 
// Game Title
local gameTitleW = flw - crw - bbm - bbm
local gameTitleH = floor( bbh * 0.35 ) 
local gameTitle = fe.add_text( "[Title]", flx + bbm, flh - bbh + bbm, gameTitleW, gameTitleH )
gameTitle.align = Align.Left
gameTitle.style = Style.Regular
gameTitle.nomargin = true
gameTitle.charsize = floor(gameTitle.height * 1000/700)
gameTitle.font = "BebasNeueBold.otf"


// Game Year And Manufacturer
function year_formatted()
{
	local m = fe.game_info( Info.Manufacturer )
	local y = fe.game_info( Info.Year )

	if (( m.len() > 0 ) && ( y.len() > 0 ))
		return "© " + y + "  " + m

	return m
}

local gameYearW = flw - crw - bbm - floor( bbh * 2.875 )
local gameYearH = floor( bbh * 0.15 )
local gameYear = fe.add_text( "[!year_formatted]", flx + bbm, flh - bbm - gameYearH, gameYearW, gameYearH )
gameYear.align = Align.Left
gameYear.style = Style.Regular
gameYear.nomargin = true
gameYear.charsize = floor(gameYear.height * 1000/700)
gameYear.font = flh <= 600 ? "BebasNeueRegular.otf": "BebasNeueBook.otf"


// Genre
local genreImageH = bbh - bbm * 2
local genreImageW = floor( genreImageH * 1.125 )
local genreImage = fe.add_image("images/unknown.png", flx + flw - crw - genreImageW - bbm, flh - bbh + bbm, genreImageW, genreImageH )
GenreImage(genreImage)


// Players
local bgPlayersW = floor(bbh * 0.9)
local bgPlayersH = floor(bbh * 0.15)
bgPlayersH = bgPlayersH < 12 ? 12 : bgPlayersH
local playersText = fe.add_text( "[Players]  Player(s)", flx + flw - crw - genreImageW - bgPlayersW - ceil(bbm * 1.5), flh - bgPlayersH - bbm, bgPlayersW, bgPlayersH )
playersText.set_rgb( 255, 255, 255 )
playersText.set_bg_rgb( 0, 0, 0 )
playersText.align = Align.Centre
playersText.charsize = floor( playersText.height * 1000/700 * 0.6 )
playersText.font = "BebasNeueBold.otf"


// // Play Count
local bgPlayCountW = floor(bbh * 0.9)
local bgPlayCountH = floor(bbh * 0.15)
bgPlayCountH = bgPlayCountH < 12 ? 12 : bgPlayCountH
local playCountText = fe.add_text( "Played:  [PlayedCount]", flx + flw - crw - genreImageW - bgPlayersW - bgPlayCountW - ceil(bbm * 1.5), flh - bgPlayCountH - bbm, bgPlayCountW, bgPlayCountH )
playCountText.set_rgb( 255, 255, 255 )
playCountText.set_bg_rgb( selRGB[0], selRGB[1], selRGB[2] )
playCountText.align = Align.Centre
playCountText.charsize = floor(playCountText.height * 1000/700 * 0.6)
playCountText.font = "BebasNeueBold.otf"


// Category
local categoryW = floor( bth * 2.5 )
local categoryH = floor( bth * 0.25 )
local categoryX = floor(( flw - crw ) * 0.5 - categoryW * 0.5 + flx)
local categoryY = floor( bth * 0.5 ) - floor( categoryH * 0.5 )
local category = fe.add_text("[FilterName]", categoryX, categoryY, categoryW, categoryH )
category.align = Align.Centre
category.filter_offset = 0
category.style = Style.Regular
category.charsize = floor(category.height * 1000/701)
category.font = "BebasNeueBold.otf"

local categoryLeft = fe.add_text("[FilterName]", 0, categoryY, categoryW, categoryH )
categoryLeft.align = Align.Centre
categoryLeft.filter_offset = -1
categoryLeft.set_rgb(selRGB[0],selRGB[1],selRGB[2])
categoryLeft.style = Style.Regular
categoryLeft.charsize = floor(category.height * 1000/700)
categoryLeft.font = "BebasNeueBook.otf"

local categoryRight = fe.add_text("[FilterName]", 0, categoryY, categoryW, categoryH )
categoryRight.align = Align.Centre
categoryRight.filter_offset = 1
categoryRight.set_rgb(selRGB[0],selRGB[1],selRGB[2])
categoryRight.style = Style.Regular
categoryRight.charsize = floor(category.height * 1000/701)
categoryRight.font = "BebasNeueBook.otf"

local categoryLeft2 = fe.add_text("[FilterName]", 0, categoryY, categoryW, categoryH )
categoryLeft2.align = Align.Centre
categoryLeft2.filter_offset = -2
categoryLeft2.set_rgb(selRGB[0],selRGB[1],selRGB[2])
categoryLeft2.style = Style.Regular
categoryLeft2.charsize = floor(category.height * 1000/701)
categoryLeft2.alpha = 0
categoryLeft2.font = "BebasNeueBook.otf"

local categoryRight2 = fe.add_text("[FilterName]", 0, categoryY, categoryW, categoryH )
categoryRight2.align = Align.Centre
categoryRight2.filter_offset = 2
categoryRight2.set_rgb(selRGB[0],selRGB[1],selRGB[2])
categoryRight2.style = Style.Regular
categoryRight2.charsize = floor(category.height * 1000/701)
categoryRight2.alpha = 0
categoryRight2.font = "BebasNeueBook.otf"


local categoryGap = floor( bth * 0.225 )
categoryLeft.x = category.x - category.msg_width / 2 - categoryLeft.msg_width / 2 - categoryGap
categoryRight.x = category.x + category.msg_width / 2 + categoryRight.msg_width / 2 + categoryGap
categoryLeft2.x = categoryLeft.x - categoryLeft.msg_width / 2 - categoryLeft2.msg_width / 2 - categoryGap
categoryRight2.x = categoryRight.x + categoryRight.msg_width / 2  + categoryRight2.msg_width / 2 + categoryGap


// List Entry
local gameListEntryW = floor( bth * 2.5 )
local gameListEntryH = floor( bth * 0.25 )
local gameListEntryY = floor( bth / 2.0 ) - floor( gameListEntryH / 2 )
local gameListEntry = fe.add_text("[ListEntry]/[ListSize]", flx + flw - crw - gameListEntryW, gameListEntryY , gameListEntryW, gameListEntryH )
gameListEntry.align = Align.Right
gameListEntry.style = Style.Regular
gameListEntry.font = "BebasNeueLight.otf"
gameListEntry.charsize = floor(gameListEntry.height * 1000/700)


// Carrier
local carrier = null
if( cr_en ) {
	carrier = Carrier( flw + flx - crw, 0, crw, flh, crc, 2, 8, "images/selector300x216.png", "images/white.png" )
	carrier.set_background_color( bgRGB[0] * 0.6, bgRGB[1] * 0.6, bgRGB[2] * 0.6 )
	carrier.set_keep_aspect()
	carrier.set_selector_alpha( 150 )
}


// Left Black Bar
local barLeft = fe.add_text( "", 0, 0, flx, flh)
barLeft.set_bg_rgb( 0, 0, 0 )


// Right Black Bar
local barRight = fe.add_text( "", flw + flx, 0, flx, flh)
barRight.set_bg_rgb( 0, 0, 0 )


// Category Animations
local categoryOvershot = 4
local categorySmoothing = 0.9
local categoryAnimX = Animate( category, "x", categoryOvershot, 0, categorySmoothing )
local categoryLeftAnimX = Animate( categoryLeft, "x", categoryOvershot, 0, categorySmoothing )
local categoryRightAnimX = Animate( categoryRight, "x", categoryOvershot, 0, categorySmoothing )
local categoryLeft2AnimX = Animate( categoryLeft2, "x", categoryOvershot, 0, categorySmoothing )
local categoryRight2AnimX = Animate( categoryRight2, "x", categoryOvershot, 0, categorySmoothing )
local categoryLeftAnimA = Animate( categoryLeft, "alpha", categoryOvershot, 0, categorySmoothing )
local categoryRightAnimA = Animate( categoryRight, "alpha", categoryOvershot, 0, categorySmoothing )
local categoryLeft2AnimA = Animate( categoryLeft2, "alpha", categoryOvershot, 0, categorySmoothing )
local categoryRight2AnimA = Animate( categoryRight2, "alpha", categoryOvershot, 0, categorySmoothing )


// Wheel Image
local wheelScale = ( flw - crw * 2 ) < flh ? flw - crw * 2 : flh
local wheelImageW = floor( wheelScale * 0.3 )
local wheelImageH = floor( wheelScale * 0.3 )
local wheelImage = fe.add_artwork( "wheel" ,flx + bbm, bth - floor( wheelImageH / 2 ), wheelImageW, wheelImageH )
wheelImage.preserve_aspect_ratio = true

//wheelImage.trigger = Transition.EndNavigation
wheelImage.trigger = 0

local wheelImageAnimS = Animate( wheelImage, "scale", 0.01, 0, 0.9 )
local wheelImageAnimA = Animate( wheelImage, "alpha", 1, 0, 0.9 )


// Manual aspect ratio control function
function adjustSnapRatio() {
	local snapRatio = snapW.tofloat() / snapH.tofloat()
	local snapSrcRatio = snap.subimg_width.tofloat() / snap.subimg_height.tofloat()
	
	if( snapRatio > snapSrcRatio ) {
		snap.width = floor(snapW * ( snapSrcRatio / snapRatio ))
		snap.height = snapH
		snap.x = snapX + floor((snapW - snap.width ) * 0.5 )
		snap.y = snapY
	} else if( snapRatio < snapSrcRatio ) {
		snap.width = snapW
		snap.height = floor(snapH * ( snapRatio / snapSrcRatio ))
		snap.x = snapX
		snap.y = snapY + floor((snapH - snap.height ) * 0.5 )
	} else {
		snap.width = snapW
		snap.height = snapH
		snap.x = snapX
		snap.y = snapY
	}
}


// Transitions
fe.add_transition_callback( this, "on_transition" )

function on_transition( ttype, var, ttime ) {
	if( ttype == Transition.ToNewSelection) {
			gameListBoxAnimX.to = flw + flx - crw - lbw
			if ( glist_delay != 0 ) gameListBoxAnimX.hide( flw + flx - crw, fe.layout.time )
			gameListBoxAnimA.to = 255
			if ( glist_delay != 0 ) gameListBoxAnimA.hide( 0, fe.layout.time )
			gameListBoxBackgroundAnimX.to = flw + flx - crw - lbw
			if ( glist_delay != 0 ) gameListBoxBackgroundAnimX.hide( flw + flx - crw, fe.layout.time )
			gameListBoxBackgroundAnimA.to = 255
			if ( glist_delay != 0 ) gameListBoxBackgroundAnimA.hide( 0, fe.layout.time )
		}
		
	if( ttype == Transition.EndNavigation ) {

		update_artwork = true	
		update_counter = 0
	}
	
	if( ttype == Transition.ToNewList) {
		
		update_artwork = true	
		update_counter = 0

		if ( glist_delay != 0 ) gameListBoxAnimX.hide( flw + flx - crw, fe.layout.time )
		gameListBoxAnimA.from = 0
		gameListBoxAnimA.to = 255
		if ( glist_delay != 0 ) gameListBoxAnimA.hide( 0, fe.layout.time )
		if ( glist_delay != 0 ) gameListBoxBackgroundAnimX.hide( flw + flx - crw, fe.layout.time )
		gameListBoxBackgroundAnimA.from = 0
		gameListBoxBackgroundAnimA.to = 255
		if ( glist_delay != 0 ) gameListBoxBackgroundAnimA.hide( 0, fe.layout.time )
		
		if ( var < 0 ) {
			gameListBoxAnimX.from = flw + flx - crw - lbw * 2
			gameListBoxAnimX.to = flw + flx - crw - lbw
			gameListBoxBackgroundAnimX.from = flw + flx - crw - lbw * 2
			gameListBoxBackgroundAnimX.to = flw + flx - crw - lbw
			categoryAnimX.from = categoryX - category.msg_width * 0.5 - categoryRight.msg_width * 0.5 - categoryGap
			categoryAnimX.to = categoryX
			categoryLeftAnimA.from = 0
			categoryLeftAnimA.to = 255
			categoryLeft2AnimA.from = 0.01
			categoryLeft2AnimA.to = 0
			categoryRight2AnimA.from = 255
			categoryRight2AnimA.to = 0
		}
		
		if ( var > 0 ) {
			gameListBoxAnimX.from = flw + flx - crw
			gameListBoxAnimX.to = flw + flx - crw - lbw
			gameListBoxBackgroundAnimX.from = flw + flx - crw
			gameListBoxBackgroundAnimX.to = flw + flx - crw - lbw
			categoryAnimX.from = categoryX + category.msg_width * 0.5 + categoryLeft.msg_width * 0.5 + categoryGap
			categoryAnimX.to = categoryX
			categoryRightAnimA.from = 0
			categoryRightAnimA.to = 255
			categoryRight2AnimA.from = 0.01
			categoryRight2AnimA.to = 0
			categoryLeft2AnimA.from = 255
			categoryLeft2AnimA.to = 0
		}

		categoryLeftAnimX.from = categoryAnimX.from - category.msg_width / 2 - categoryLeft.msg_width / 2 - categoryGap
		categoryLeftAnimX.to = categoryAnimX.to - category.msg_width / 2 - categoryLeft.msg_width / 2 - categoryGap
		categoryRightAnimX.from = categoryAnimX.from + category.msg_width / 2 + categoryRight.msg_width / 2 + categoryGap
		categoryRightAnimX.to = categoryAnimX.to + category.msg_width / 2 + categoryRight.msg_width / 2 + categoryGap

		categoryLeft2AnimX.from = categoryLeftAnimX.from - categoryLeft.msg_width / 2 - categoryLeft2.msg_width / 2 - categoryGap
		categoryLeft2AnimX.to = categoryLeftAnimX.to - categoryLeft.msg_width / 2 - categoryLeft2.msg_width / 2 - categoryGap
		categoryRight2AnimX.from = categoryRightAnimX.from + categoryRight.msg_width / 2 + categoryRight2.msg_width / 2 + categoryGap
		categoryRight2AnimX.to = categoryRightAnimX.to + categoryRight.msg_width / 2 + categoryRight2.msg_width / 2 + categoryGap
	}
	
	if( ttype == Transition.ToNewSelection || Transition.ToNewList) {
		if (fe.game_info(Info.Favourite, var) == "1") favouriteIcon.visible = true else favouriteIcon.visible = false
	}
	return false
}
 

// Custom Overlay
local colour_overlay = false
local overlay_charsize = floor( flh * 0.051 )
local overlay_background = fe.add_image ("images/black.png", flx , flh * 0.35, flw, flh * 0.3)
overlay_background.visible = false

local overlay_listbox = fe.add_listbox( flx, flh * 0.35, flw, flh * 0.30 )
overlay_listbox.rows = 4
overlay_listbox.charsize = overlay_charsize
overlay_listbox.bg_alpha = 0
overlay_listbox.set_rgb( 200, 200, 200 )
overlay_listbox.set_bg_rgb( 200, 0, 0 )
overlay_listbox.set_sel_rgb( 200, 200, 200 )
overlay_listbox.set_selbg_rgb( selRGB[0], selRGB[1], selRGB[2] )
overlay_listbox.font = "BebasNeueBold.otf"
overlay_listbox.visible = false

local overlay_label = fe.add_text( "dummy", flx, flh * 0.37, flw, overlay_charsize )
overlay_label.charsize = overlay_charsize
overlay_label.set_rgb( 200, 200, 200 ) 
overlay_label.align = Align.Centre
overlay_label.font = "BebasNeueBold.otf"
overlay_label.visible = false

fe.overlay.set_custom_controls( overlay_label, overlay_listbox )

local overlay_backgroundAnimS = Animate( overlay_background, "scale_y", 0.05, 0, 0.75 )
overlay_backgroundAnimS.to = 0
local overlay_backgroundAnimA = Animate( overlay_background, "alpha", 1, 0, 0.75 )

fe.add_transition_callback( "overlay_transition" )
function overlay_transition( ttype, var, ttime )
{
	if ( overlay_backgroundAnimS.running && ttype == Transition.EndLayout && var == FromTo.Frontend) {
		overlay_backgroundAnimS.tick(ttime)
		overlay_backgroundAnimA.tick(ttime)
		return true
	}
	
	switch ( ttype )
	{
	case Transition.ShowOverlay:
		if (var == Overlay.Custom && !colour_overlay) {
			local m = fe.game_info(Info.Favourite, snap.index_offset)
			if (m=="1")
				overlay_label.msg = "REMOVE FROM FAVOURITES?"
			else
				overlay_label.msg = "ADD TO FAVOURITES?"
		}
		overlay_background.visible = true
		overlay_backgroundAnimS.from = 0
		overlay_backgroundAnimS.to = 1
		overlay_backgroundAnimA.from = 0
		overlay_backgroundAnimA.to = 200
		colour_overlay = false
		break
	
	case Transition.HideOverlay:
		overlay_listbox.visible = false
		overlay_label.visible = false
		overlay_backgroundAnimS.from = 1
		overlay_backgroundAnimS.to = 0
		overlay_backgroundAnimA.from = 200
		overlay_backgroundAnimA.to = 0
		break
	}
	return false
}

fe.add_ticks_callback( this, "tick" )
function tick( tick_time ) {

	if( update_artwork == true ) {
		update_counter++
		switch ( update_counter ) {
			case 1:
				wheelImageAnimS.from = 2
				wheelImageAnimS.to = 1
				wheelImageAnimA.from = 0
				wheelImageAnimA.to = 255
				break
			case 2:
				wheelImage.file_name = fe.get_art( "wheel" )
				break
			case 3:
				if ( glist_delay != 0 ) flyer.file_name = fe.get_art( "boxart" )
				break
			case 4:
				snap.file_name = fe.get_art( "snap" )
				adjustSnapRatio()
				shader.set_param( "params", snap.height, shader_enabled )
				update_artwork = false
				update_counter = 0
				break
			default:
				break
		}
	}

	if( overlay_background.visible == true ){
		if( overlay_backgroundAnimS.from == 1 ) {
			overlay_listbox.visible = true
			overlay_label.visible = true
		}
		if( overlay_backgroundAnimS.from == 0 ) {
			overlay_background.visible = false
		}
	}
}


// Colour Randomizer Overlay
fe.add_signal_handler( "on_signal" )
function on_signal( sig )
{
	switch ( sig ) {
	case "custom1":
		random_color()
		return true
	default:
		return false
	}
}

function random_color()
{
	local dialog_options = []
	dialog_options.append("Randomize Colour")
	dialog_options.append("Close")
	colour_overlay = true
	local dialog_result = fe.overlay.list_dialog(dialog_options,"Background   R: " + bgRGB[0] + "   G: " + bgRGB[1] + "   B: " + bgRGB[2] + "	  ACCENT   R: " + selRGB[0] + "   G: " + selRGB[1] + "   B: " + selRGB[2] )
	if (!dialog_result) {
		bgRYB = [irand(255) + 0, irand(255) + 0, irand(255) + 0]
		selRYB = [255 - bgRYB[0], 255 - bgRYB[1], 255 - bgRYB[2]]
		bgRGB = ryb2rgb(bgRYB)
		selRGB = ryb2rgb(selRYB)
		bgRGB = bgRGB.map( function( value ) { return floor( value / 2 ) } )
		selRGB = selRGB.map( function( value ) { return value / 1 } )
		fe.nv = [bgRGB, selRGB]
		gameListBox.set_bg_rgb( bgRGB[0] * 0.75, bgRGB[1] * 0.75, bgRGB[2] * 0.75 )
		snapBackground.set_rgb( bgRGB[0] * 0.6, bgRGB[1] * 0.6, bgRGB[2] * 0.6 )
		bannerTop.set_bg_rgb( bgRGB[0], bgRGB[1], bgRGB[2] )
		bannerBottom.set_bg_rgb( bgRGB[0], bgRGB[1], bgRGB[2] )
		if (cr_en) carrier.set_background_color( bgRGB[0] * 0.6, bgRGB[1] * 0.6, bgRGB[2] * 0.6 )
		gameListBox.set_selbg_rgb( selRGB[0], selRGB[1], selRGB[2] )
		gameListBoxBackground.set_bg_rgb( bgRGB[0] * 0.75, bgRGB[1] * 0.75, bgRGB[2] * 0.75 )
		favouriteIcon.set_rgb( selRGB[0], selRGB[1], selRGB[2] )
		playCountText.set_bg_rgb( selRGB[0], selRGB[1], selRGB[2] )
		categoryLeft.set_rgb(selRGB[0],selRGB[1],selRGB[2])
		categoryRight.set_rgb(selRGB[0],selRGB[1],selRGB[2])
		categoryLeft2.set_rgb(selRGB[0],selRGB[1],selRGB[2])
		categoryRight2.set_rgb(selRGB[0],selRGB[1],selRGB[2])
		overlay_listbox.set_selbg_rgb( selRGB[0], selRGB[1], selRGB[2] )
		random_color()
	}
}
