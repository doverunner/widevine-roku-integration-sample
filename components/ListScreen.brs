' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

'*******************************************************************************
'#
'# Copyright 2017 INKA ENTWORKS. All Rights Reserved.
'#
'*******************************************************************************

sub mylog(msg as string)
	if m.enableLog then print "ListScreen.brs - " ; msg
end sub

' Called when the ListScreen component is initialized
sub init()
	m.enableLog = false
	mylog("[init]")

	'Get references to child nodes
	m.RowList       =   m.top.findNode("RowList")
	m.background    =   m.top.findNode("Background")
	
	'For testing with ROKU sample channels and INKA sample videos
	URLs = [
		' Uncomment this line to simulate a bad request and make the dialog box appear
		' "bad request",
		"pkg:/channels/channel1.json"		
	]
	
	'Make a request for each "row" in the UI (in the order that you want content filled)
	makeRequest(URLs)
		
	'Create observer events for when content is loaded
	m.top.observeField("visible", "onVisibleChange")
	m.top.observeField("focusedChild", "OnFocusedChildChange")
end sub

' Issues a URL request to the UriHandler component
sub makeRequest(URLs as object)
	mylog("[makeRequest]")
	
	'Create a task node to fetch the UI content and populate the screen
	m.UriHandler = CreateObject("roSGNode", "UriHandler")
	m.UriHandler.observeField("content", "onContentChanged")
	m.UriHandler.numRows = URLs.count()

	for i = 0 to URLs.count() - 1
		context = createObject("roSGNode", "Node")
		uri = { uri: URLs[i] }
		if type(uri) = "roAssociativeArray"
			context.addFields({
				parameters: uri,
				num: i,
				response: {}
			})
			m.UriHandler.request = {
				context: context
				parser: "Parser"
			}
		end if
	end for
end sub

' observer function to handle when content loads
sub onContentChanged()
	mylog("[onContentChanged]")
	
	m.top.numBadRequests = m.UriHandler.numBadRequests
	m.top.content = m.UriHandler.content
end sub

' handler of focused item in RowList
sub OnItemFocused()
	mylog("[OnItemFocused]")
	
	itemFocused = m.top.itemFocused
	
	'When an item gains the key focus, set to a 2-element array,
	'where element 0 contains the index of the focused row,
	'and element 1 contains the index of the focused item in that row.
	if itemFocused.Count() = 2 then
		focusedContent            = m.top.content.getChild(itemFocused[0]).getChild(itemFocused[1])
		if focusedContent <> invalid then
			m.top.focusedContent    = focusedContent
			m.background.uri        = focusedContent.hdBackgroundImageUrl
		end if
	end if
end sub

' sets proper focus to RowList in case channel returns from Details Screen
sub onVisibleChange()
	mylog("[onVisibleChange]")
	
	if m.top.visible then m.rowList.setFocus(true)
end sub

' set proper focus to RowList in case if return from Details Screen
sub onFocusedChildChange()
	mylog("[onFocusedChildChange]")
	
	if m.top.isInFocusChain() and not m.rowList.hasFocus() then m.rowList.setFocus(true)
end sub
