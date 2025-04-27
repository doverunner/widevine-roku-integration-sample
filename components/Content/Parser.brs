' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

'*******************************************************************************
'#
'# Copyright 2017 DOVERUNNER. All Rights Reserved.
'#
'*******************************************************************************

sub mylog(msg as string)
	if m.enableLog then print "Parser.brs - " ; msg
end sub

sub init()
	m.enableLog = true
	mylog("[init]")
end sub

' Parses the response string as XML
' The parsing logic will be different for different RSS feeds
sub parseResponse()
	mylog("[parseResponse]")
	
	str = m.top.response.content
	num = m.top.response.num
	
	if str = invalid return
	if Len(str) < 1 return
	
	if Left(str, 1) = "{"
		'Response will be "JSON"
		json = ParseJSON(str)
		
		if json.Videos = invalid
			if m.UriHandler = invalid then m.UriHandler = m.top.getParent()
			m.UriHandler.failToParse = {
					msg: "invalid json"
				}
			return
		end if
		
		result = []
		Videos = json.Videos
	    for each video in Videos
			item = {}
			
			'[mandatory] Content title
			item.title = video.name
			
			'[mandatory] Content url
			item.url = video.uri

			'[mandatory] Content stream format
			streamFormat = Lcase(Right(item.url, 4))
			if instr(1, streamFormat, ".") > 0 then	streamFormat = Right(streamFormat, 3)
			item.streamformat = streamFormat

			'[optional] Content description, release date
			item.description = video.description
			item.releaseDate = video.releaseDate
			
			'[optional but strongly recommended] Content thumbnail image url
			item.hdposterurl = video.thumbnail_small
			
			'[optional but recommended] background image url when content focused and selected
			item.hdbackgroundimageurl = video.thumbnail_big

			'''' Multi DRM
			'Set DRM data if it is provided
			parseMultiDrmDataFromJson(video, item)
			''''
			result.push(item)
	    end for			
		'End of JSON
	end if
	
	'Set channel name
	channelList = [ {	Title:"From Inka"
						ContentList : result } ]
	
	'Logic for creating a row
	contentAA = {}
	content = invalid
	
	'Named channels are displayed as rows and the others as grids
	'The name of grid channel will be set in createGrid
	if num < channelList.count()
		content = createRow(channelList, num)
	else
		content = createGrid(result)
	end if
	
	'Add the newly parsed content row to the cache until everything is ready
	if content <> invalid
		contentAA[num.toStr()] = content
		if m.UriHandler = invalid then m.UriHandler = m.top.getParent()
		m.UriHandler.contentCache.addFields(contentAA)
	else
		print "Error: content is invalid"
	end if
end sub

' Create a row of content
function createRow(channelList as object, num as integer)
	mylog("[createRow (" + channelList[num].Title + ")]")
	
	Parent = createObject("roSGNode", "ContentNode")
	row = createObject("roSGNode", "ContentNode")
	row.Title = channelList[num].Title
	for each itemAA in channelList[num].ContentList
		item = createObject("roSGNode","ContentNode")
		AddAndSetFields(item, itemAA)
		row.appendChild(item)
	end for
	Parent.appendChild(row)
	return Parent
end function

' Create a grid of content - simple splitting of a feed to different rows
' with the title of the row hidden.
' Set the for loop parameters to adjust how many columns there
' should be in the grid.
function createGrid(contentList as object)
	mylog("[createGrid]")
	
	Parent = createObject("roSGNode","ContentNode")
	for i = 0 to contentList.count() step 4
		row = createObject("roSGNode","ContentNode")
		if i = 0
			row.Title = "The Grid"
		end if
		for j = i to i + 3
			if contentList[j] <> invalid
				item = createObject("roSGNode","ContentNode")
				AddAndSetFields(item,contentList[j])
				row.appendChild(item)
			end if
		end for
		Parent.appendChild(row)
	end for
	return Parent
end function
