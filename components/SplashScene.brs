' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

sub mylog(msg as string)
	if m.enableLog then print "SplashScene.brs - " ; msg
end sub

' function which called at first after launch
sub init()
	m.enableLog = false
	mylog("[init]")
	
	' ListScreen Node with RowList
	m.ListScreen = m.top.FindNode("ListScreen")

	' DetailsScreen Node with description & video player
	m.DetailsScreen = m.top.FindNode("DetailsScreen")

	' The spinning wheel node
	m.LoadingIndicator = m.top.findNode("LoadingIndicator")

	' Dialog box node. Appears if content can't be loaded
	m.WarningDialog = m.top.findNode("WarningDialog")

	' Transitions between screens
	m.FadeIn = m.top.findNode("FadeIn")
	m.FadeOut = m.top.findNode("FadeOut")
	
	' Set focus to the scene
	m.top.setFocus(true)
end sub

' grid content handler fucntion.
' If content is set, stops the loadingIndicator and focuses on ListScreen.
sub OnChangeContent()
	mylog("[OnChangeContent]")

	m.loadingIndicator.control = "stop"
	if m.top.content <> invalid
		' Display warning dialog if there is a bad request
		if m.top.numBadRequests > 0
			m.ListScreen.visible = "true"
			m.WarningDialog.visible = "true"
			m.WarningDialog.message = (m.top.numBadRequests).toStr() + " request(s) for content failed. Press '*' or OK or '<-' to continue."
		else
			m.ListScreen.visible = "true"
			m.ListScreen.setFocus(true)
		end if
	else
		m.WarningDialog.visible = "true"
	end if
end sub

' item selected handler function.
' show Details item node and hide Grid.
sub OnRowItemSelected()
	mylog("[OnRowItemSelected]")

	m.FadeIn.control = "start"
	m.ListScreen.visible = "false"
	m.DetailsScreen.content = m.ListScreen.focusedContent
	m.DetailsScreen.setFocus(true)
	m.DetailsScreen.visible = "true"
end sub

' Called when a key on the remote is pressed
' when keydown event, press is true
' when keyup event, press is false
function onKeyEvent(key as String, press as Boolean) as Boolean
	if press
		mylog("[onKeyEvent: " + key + ", true]")
	else
		mylog("[onKeyEvent: " + key + ", false]")
	end if
	
	result = false
	
	if press then
		if key = "back"
			if m.WarningDialog.visible = true
				' if WarningDialog is open
				mylog("closing dialog")
				
				m.WarningDialog.visible = "false"
				m.ListScreen.setFocus(true)
				result = true
			else if m.ListScreen.visible = false and m.DetailsScreen.videoPlayerVisible = false
				' if Details opened
				mylog("closing detail")
				
				m.FadeOut.control = "start"
				m.ListScreen.visible = "true"
				m.detailsScreen.visible = "false"
				m.ListScreen.setFocus(true)
				result = true
			else if m.ListScreen.visible = false and m.DetailsScreen.videoPlayerVisible = true
				' if video player opened
				mylog("stopping video playback")
				
				m.DetailsScreen.videoPlayerVisible = false
				result = true
			end if
		else if key = "OK"
			if m.WarningDialog.visible = true
				m.WarningDialog.visible = "false"
				m.ListScreen.setFocus(true)
			end if
		else if key = "options"
			m.WarningDialog.visible = "false"
			m.ListScreen.setFocus(true)
		end if
	end if
	return result
end function
