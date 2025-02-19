' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

sub mylog(msg as string)
	if m.enableLog then print "Description.brs - " ; msg
end sub

'setting top interfaces
sub init()
	m.enableLog = false
	mylog("[init]")
	
	m.top.title			= m.top.findNode("Title")
	m.top.description	= m.top.findNode("Description")
	m.top.releaseDate	= m.top.findNode("ReleaseDate")
end sub

' Content change handler
' All fields population
sub OnContentChanged()
	mylog("[OnContentChanged]")
	
	item = m.top.content
	title = item.title.toStr()
	if title <> invalid then
		m.top.title.text = title.toStr()
	end if
	
	value = item.description
	if value <> invalid then
		if value.toStr() <> "" then
			m.top.description.text = value.toStr()
		else
			m.top.description.text = "No description"
		end if
	end if
		
	value = item.releaseDate
	if value <> invalid then
		if value <> ""
			m.top.releaseDate.text = value.toStr()
		else
			m.top.releaseDate.text = "No release date"
		end if
	end if
end sub
