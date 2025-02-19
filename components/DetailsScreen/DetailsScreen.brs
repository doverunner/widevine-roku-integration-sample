' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

'*******************************************************************************
'#
'# Copyright 2017 INKA ENTWORKS. All Rights Reserved.
'#
'*******************************************************************************

sub mylog(msg as string)
	if m.enableLog then print "DetailsScreen.brs - " ; msg
end sub

' when the user select a content
' inits details screen
' sets all observers
' configures buttons for Details screen
sub init()
	m.enableLog = true
	mylog("[init]")

	m.top.observeField("visible", "onVisibleChange")
	m.top.observeField("focusedChild", "OnFocusedChildChange")

	m.buttons		= m.top.findNode("Buttons")
	m.videoPlayer	= m.top.findNode("VideoPlayer")
	m.poster		= m.top.findNode("Poster")
	m.description	= m.top.findNode("Description")
	m.background	= m.top.findNode("Background")
	m.fadeIn		= m.top.findNode("fadeinAnimation")
	m.fadeOut		= m.top.findNode("fadeoutAnimation")
	m.MessageDialog = m.top.findNode("MessageDialog")
	
	' create buttons
	result = []
	for each button in ["Play"]', "Remove license"]
		result.push({title : button})
	end for
	m.buttons.content = ContentList2SimpleNode(result)
end sub

sub showdialog(title as string, msg as string)
	mylog("[showdialog]")

	if m.MessageDialog.visible
		'Remove previous dialog 
		m.buttons.setFocus(true)
		m.MessageDialog.setFocus(false)
		m.MessageDialog.visible = false
	end if
	
	m.MessageDialog.message = msg + chr(10) + "Press 'Back' key to close."
	m.MessageDialog.visible = true
	m.MessageDialog.setFocus(true)
	m.buttons.setFocus(true)
end sub

' set focus to buttons if Details opened and stops video playback if Details closed
sub onVisibleChange()
	mylog("[onVisibleChange]")

	if m.top.visible
		m.fadeIn.control="start"
		m.buttons.jumpToItem = 0
		m.buttons.setFocus(true)
	else
		m.fadeOut.control="start"
		m.videoPlayer.visible = false
		m.videoPlayer.control = "stop"
		m.poster.uri=""
		m.background.uri=""
	end if
end sub

' set focus to Buttons in case if return from Video PLayer
sub OnFocusedChildChange()
	mylog("[OnFocusedChildChange]")
	
	if m.top.isInFocusChain() and not m.buttons.hasFocus() and not m.videoPlayer.hasFocus() then
		m.buttons.setFocus(true)
	end if
end sub

' set focus on buttons and stops video if return from Playback to details
sub onVideoVisibleChange()
	mylog("[onVideoVisibleChange]")

	if m.videoPlayer.visible = false and m.top.visible = true
		m.buttons.setFocus(true)
		m.videoPlayer.control = "stop"
	end if
end sub

' event handler of Video player msg
sub OnVideoPlayerStateChange()
	mylog("[OnVideoPlayerStateChange]")
	
	if m.videoPlayer.state = "error"
		' error handling
		print "Error: (" ; m.videoPlayer.errorCode ") " ; m.videoPlayer.errorMsg
		m.videoPlayer.visible = false
		showdialog("Error", m.videoPlayer.errorMsg)
	else if m.videoPlayer.state = "playing"
		' playback handling
	else if m.videoPlayer.state = "finished"
		m.videoPlayer.visible = false
	end if
end sub

' on Button press handler
sub onItemSelected()
	mylog("[onItemSelected]")

	if m.top.itemSelected = 0
		' first button is Play
		mylog("'play' selected")
		
		'''' INKA DRM
		' Get custom data before playback
		if setDrmDataToPlayerIfAvailable(m.videoPlayer) < 0
			showdialog("Error", "[Internal DRM failed]" + chr(10) + "Please contact DRM provider.") 
			return
		endif
		''''
		
		m.videoPlayer.visible = true
		m.videoPlayer.setFocus(true)
		m.videoPlayer.control = "play"
		m.videoPlayer.observeField("state", "OnVideoPlayerStateChange")
	end if
end sub

' Content change handler
sub OnContentChange()
	mylog("[OnContentChange]")

	m.description.content           = m.top.content
	m.description.description.width = "1120"
	
	m.videoPlayer.content           = m.top.content
	m.poster.uri                    = m.top.content.hdposterurl
	m.background.uri                = m.top.content.hdBackgroundImageUrl
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
	
	if m.MessageDialog.visible
		if key = "back"
			mylog("closing dialog")
			m.MessageDialog.setFocus(false)
			m.MessageDialog.visible = false
			m.buttons.setFocus(true)
		end if
		return true
	end if
	
	return false
end function


'///////////////////////////////////////////'
' Helper function convert AA to Node
Function ContentList2SimpleNode(contentList as Object, nodeType = "ContentNode" as String) as Object
	mylog("[ContentList2SimpleNode]")

	result = createObject("roSGNode", nodeType)
	if result <> invalid
		for each itemAA in contentList
			item = createObject("roSGNode", nodeType)
			item.setFields(itemAA)
			result.appendChild(item)
		end for
	end if
	return result
end Function
