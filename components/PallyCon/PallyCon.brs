'*******************************************************************************
'#
'# Copyright 2017 INKA ENTWORKS. All Rights Reserved.
'#
'*******************************************************************************

' Parse JSON data which contains DRM data and set DRM data to content meta data
' If you changed the JSON structure for your app, Please modify correspond code in this function
' @param jsonData json data which contains DRM data
' @param contentMetadata an object which contents meta data
' @see <a href="https://sdkdocs.roku.com/display/sdkdoc/Content+Meta-Data">Content Meta Data</a>
sub parsePallyConDrmDataFromJson(jsonData as object, contentMetadata as object)
	drmData = {}

	'Check that the JSON data contains DRM data
	drmType = jsonData.drmSchemeUuid
	if drmType <> invalid
		drmType = LCase(drmType)
		
		'PallyCon SDK for ROKU only supports Widevine DRM
		if drmType = "widevine"
			isDrm = true
		else
			isDrm = false
			print "Error: unsupported DRM type: " ; drmType
		end if
		
		if isDrm
			drmData.drmType = drmType

			'[mandatory for DRM] License acquisition url
			drmData.licenseUrl = jsonData.drmLicenseUrl
					
			'[optional] Content id
			if jsonData.cid = invalid
				drmData.drmContentId = ""
			else
				drmData.drmContentId = jsonData.cid
			end if
					
			'[optional] Token
			if jsonData.token = invalid
				drmData.drmToken = ""
			else
				drmData.drmToken = jsonData.token
			end if
			
			'Set DRM data
			contentMetadata.drmData = drmData
		end if
	end if
end sub

' Set DRM custom data to videoPlayer
' @param video video node. It must contain content node and the content node must contain DRM data calling {@link .parsePallyDrmDataFromJson parsePallyDrmDataFromJson()}
' @return 0 if succeed, otherwise non-zero error code
' @see <a href="https://sdkdocs.roku.com/display/sdkdoc/Video">Video node</a>
' @see "Error code"
' @see "   0 if successful"
' @see "   1 if content node in video node does not have DRM data. It may be non-drm content."
' @see "   -1 if video node does not have content node"
' @see "   -2 An internal error to get custom data"
function setDrmDataToPlayerIfAvailable(videoNode as object) as integer
	if videoNode.content = invalid
		'No content at the player
		'The content must be set at the player
		return -1
	end if
	
	drmData = videoNode.content.drmData
	if drmData = invalid
		'No DRM data. The content may be non-drm or the App missed parsing DRM data from channel information
		return 1
	end if
	
	if Len(drmData.drmToken) > 1
		if drmData.drmType = "widevine"
			drmParams = {
				keySystem: drmData.drmType
				licenseServerURL: drmData.licenseUrl + "?pallycon-customdata-v2=" + drmData.drmToken
			}
			videoNode.content.drmParams = drmParams
		end if
		return 0
	else
		'Fail to get custom data
		return -2
	end if

	'Unreachable
	return -3
end function
