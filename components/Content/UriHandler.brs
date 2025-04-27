' ********** Copyright 2016 Roku Corp.  All Rights Reserved. **********

'*******************************************************************************
'#
'# Copyright 2017 DOVERUNNER. All Rights Reserved.
'#
'*******************************************************************************

sub mylog(msg as string)
	if m.enableLog then print "UriHandler.brs - " ; msg
end sub

' A context node has a parameters and response field
' - parameters corresponds to everything related to an HTTP request
' - response corresponds to everything related to an HTTP response
' Component Variables:
'   m.port: the UriFetcher message port
'   m.jobsById: an AA containing a history of HTTP requests/responses

' init(): UriFetcher constructor
' Description: sets the execution function for the UriFetcher
' 						 and tells the UriFetcher to run
sub init()
	m.enableLog = true
	mylog("[init]")
	
	' create the message port
	m.port = createObject("roMessagePort")
	
	' fields for checking if content has been loaded
	' each row is assumed to be a different request for a rss/json feed 
	m.top.numRows = 0
	m.top.numRowsReceived = 0
	m.top.numBadRequests = 0
	m.top.contentSet = false
	
	' Stores the content if not all requests are ready
	m.top.ContentCache = createObject("roSGNode", "ContentNode")
	
	' setting callbacks for url request and response
	m.top.observeField("request", m.port)
	m.top.observeField("ContentCache", m.port)
	m.top.observeField("failToParse", m.port)
	
	' setting the task thread function
	m.top.functionName = "go"
	m.top.control = "RUN"
end sub

' go(): The "Task" function.
'   Has an event loop which calls the appropriate functions for
'   handling requests made by the ListScreen and responses when requests are finished
' variables:
'   m.jobsById: AA storing HTTP transactions where:
'			key: id of HTTP request
'  		val: an AA containing:
'       - key: context
'         val: a node containing request info
'       - key: xfer
'         val: the roUrlTransfer object
sub go()
	mylog("[go]")
	
	' Holds requests by id
	m.jobsById = {}
	
	' UriFetcher event loop
	while true
		msg = wait(0, m.port)
		mt = type(msg)
		print "    [loop] Received event type '"; mt; "'"

		if mt = "roSGNodeEvent"
			' If a request is made
			if msg.getField()="request"
				if addRequest(msg.getData()) <> true then print "Invalid request"
			else if msg.getField()="ContentCache"
				updateContent()
			else if msg.getField()="failToParse"
				updateContent()
			else
				print "Error: unrecognized field '"; msg.getField() ; "'"
			end if
		else if mt="roUrlEvent"
			' If a response is received
			processResponse(msg)
		else
			' Handle unexpected cases
			print "Error: unrecognized event type '"; mt ; "'"
		end if
	end while
end sub

' addRequest():
'   Makes the HTTP request
' parameters:
'		request: a node containing the request params/context.
' variables:
'   m.jobsById: used to store a history of HTTP requests
' return value:
'   True if request succeeds
' 	False if invalid request
function addRequest(request as Object) as Boolean
	mylog("[addRequest]")
	
	if type(request) = "roAssociativeArray"
		context = request.context
		parser = request.parser
		
		if type(parser) = "roString"
			if m.Parser = invalid
				m.Parser = createObject("roSGNode", parser)
				m.Parser.observeField("parsedContent", m.port)
			else
				print "    Parser already created"
			end if
		else
			print "Error: Incorrect type for Parser: " ; type(parser)
			return false
		end if
		
		if type(context) = "roSGNode"
			parameters = context.parameters
			if type(parameters)="roAssociativeArray"
				uri = parameters.uri
				
				if type(uri) = "roString"
					prefix = Left(uri, 4)
					
					if prefix = "http"
						print "    Requesting remote uri '" ; uri ; ";"
				
						urlXfer = createObject("roUrlTransfer")
						urlXfer.setUrl(uri)
						urlXfer.setPort(m.port)
						' should transfer more stuff from parameters to urlXfer
						idKey = stri(urlXfer.getIdentity()).trim()
						' AsyncGetToString returns false if the request couldn't be issued
						ok = urlXfer.AsyncGetToString()
						if ok then
							m.jobsById[idKey] = {
								context: request,
								xfer: urlXfer,
								num: context.num
							}
						else
							print "Error: request couldn't be issued"
						end if
						print "    Request (transfer) id: '"; idkey; "', succeeded: "; ok
					else if prefix = "pkg:"
						print "    Reading local uri: " ; uri
						uriInfo = {
							uri: uri,
							num: context.num
						}
						processResponse(uriInfo)
					else
						print "Error: unsupported uri"
						return false
					end if
					
				else
					print "Error: invalid uri: "; uri
					m.top.numBadRequests++
				end if
			else
				print "Error: parameters is the wrong type: " + type(parameters)
				return false
			end if
		else
			print "Error: context is the wrong type: " + type(context)
			return false
		end if
	else
		print "Error: request is the wrong type: " + type(request)
		return false
	end if
	return true
end function

' processResponse():
'   Processes the HTTP response.
'   Sets the node's response field with the response info.
' parameters:
' 	msg: a roUrlEvent (https://sdkdocs.roku.com/display/sdkdoc/roUrlEvent)
sub processResponse(msg as Object)
	mylog("[processResponse]")
	
	msgType = type(msg)
	
	if msgType = "roUrlEvent"
		idKey = stri(msg.GetSourceIdentity()).trim()
		job = m.jobsById[idKey]
		if job <> invalid
			context = job.context
			parameters = context.context.parameters
			uri = parameters.uri
			print "    Response for transfer '"; idkey; "' for URI '"; uri; "'"
			' could handle various error codes, retry, etc. here
			m.jobsById.delete(idKey)
			if msg.GetResponseCode() = 200
				responseMsg = msg.GetString()
				if responseMsg = invalid or Len(responseMsg) < 1
					print "Error: status code is normal, but actual response is abnormal: "
					print "Response: " ; responseMsg
					
					m.top.numBadRequests++
					m.top.numRowsReceived++
				else
					result = {
						content: responseMsg
						num:     job.num
					}
					job.context.context.response = result
					m.Parser.response = result
				end if
			else
				print "Error: status code is: " + (msg.GetResponseCode()).toStr()
				m.top.numBadRequests++
				m.top.numRowsReceived++
			end if
		else
			print "Error: event for unknown job "; idkey
		end if
	else if msgType = "roAssociativeArray"
		responseMsg = ReadAsciiFile(msg.uri)
		if responseMsg = invalid or Len(responseMsg) < 1
			print "Reading file is abnormal: "
			print "Response: " ; responseMsg
			
			m.top.numBadRequests++
			m.top.numRowsReceived++
		else
			result = {
				content: responseMsg,
				num:     msg.num
			}
			m.Parser.response = result
		end if
	else
		print "Error: unknown response type, ["; msgType ;"]"
	end if
end sub

' Callback function for when content has finished parsing
sub updateContent()
	mylog("[updateContent]")
	
	' Received another row of content
	m.top.numRowsReceived++
	
	' Return if the content is already set
	if m.top.contentSet return
		' Set the UI if all content from all streams are ready
		' Note: this technique is hindered by slowest request
		' Need to think of a better asynchronous method here!
	if m.top.numRows = m.top.numRowsReceived
		parent = createObject("roSGNode", "ContentNode")
		for i = 0 to (m.top.numRowsReceived - 1)
			oldParent = m.top.contentCache.getField(i.toStr())
			if oldParent <> invalid
				for j = 0 to (oldParent.getChildCount() - 1)
					oldParent.getChild(0).reparent(parent,true)
				end for
			end if
		end for
		print "    All content has finished loading"
		m.top.contentSet = true
		m.top.content = parent
	else
		print "    Not all content has finished loading yet"
	end if
end sub
