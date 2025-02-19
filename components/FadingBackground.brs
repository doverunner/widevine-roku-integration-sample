' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

sub mylog(msg as string)
	if m.enableLog then print "FadingBackground.brs - " ; msg
end sub

sub init()
	m.enableLog = false
	mylog("[init]")
	
	' setting top interfaces
	m.backgroundColor = m.top.findNode("backgroundColor")
	m.oldBackground = m.top.findNode("oldBackground")
	m.background = m.top.findNode("background")
	m.shade = m.top.findNode("shade")
	m.fadeoutAnimation = m.top.findNode("fadeoutAnimation")
	m.oldbackgroundInterpolator = m.top.findNode("oldbackgroundInterpolator")
	m.fadeinAnimation = m.top.findNode("fadeinAnimation")

	' setting observers
	m.background.observeField("bitmapWidth", "OnBackgroundLoaded")
	m.top.observeField("width", "OnSizeChange")
	m.top.observeField("height", "OnSizeChange")
end sub

' If background changes, start animation and populate fields
sub OnBackgroundUriChange()
	mylog("[OnBackgroundUriChange]")

	oldUrl = m.background.uri
	m.background.uri = m.top.uri
	if oldUrl <> "" then
		m.oldBackground.uri = oldUrl
		m.oldbackgroundInterpolator = [m.background.opacity, 0]
		m.fadeoutAnimation.control = "start"
	end if
end sub

' If Size changed, change parameters to childrens'
sub OnSizeChange()
	mylog("[OnSizeChange]")
	
	size = m.top.size

	m.background.width = m.top.width
	m.oldBackground.width = m.top.width
	m.shade.width = m.top.width
	m.backgroundColor.width = m.top.width

	m.oldBackground.height = m.top.height
	m.background.height = m.top.height
	m.shade.height = m.top.height
	m.backgroundColor.height = m.top.height
end sub

' When Background image loaded, start animation
sub OnBackgroundLoaded()
	mylog("[OnBackgroundLoaded]")
	
	m.fadeinAnimation.control = "start"
end sub
