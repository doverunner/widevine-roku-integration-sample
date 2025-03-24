## **DoveRunner Widevine DRM Integration Sample for Roku**



### **Requirements**

- Roku OS 8.1 or later



### **Note**

- This sample has been tested on [Roku<sup>&reg;</sup> Streaming Stick+<sup>&reg;</sup>](https://www.roku.com/products/streaming-stick-plus) and Roku OS 14.0.0
- For more information about the Roku TV development environment, check [Roku Developers](https://developer.roku.com/en-gb/docs/developer-program/getting-started/roku-dev-prog.md).



### **Quick Start**

You can apply the DoveRunner Widevine Integration Sample for Roku<sup>&reg;</sup> to your development project by following these steps:

1. Extract `PallyconRoku.zip` file.

2. Copy `PallyCon.brs` file in `components/PallyCon` folder to `components` folder in your project.

3. Call `parsePallyConDrmDataFromJson()` function at building [Content Meta-Data](https://developer.roku.com/en-gb/docs/developer-program/getting-started/architecture/content-metadata.md) part in your project.
   * You may modify implementation of `parsePallyConDrmDataFromJson()`.
   * Please refer to API Guide at the bottom of this document for detail information.

4. Call `setDrmDataToPlayerIfAvailable()` function before playing the content.

6. Add the below code in XML file which call functions of DoveRunner Widevine Sample for Roku.
   ```xml
   <script type="text/brightscript" uri="pkg:/components/PallyCon.brs"/>
   ```



### **DoveRunner Widevine Roku Integration Guide** ###

#### parsePallyConDrmDataFromJson

- Adds DoveRunner Multi-DRM data parsed from JSON data to [Content Meta-Data](https://developer.roku.com/en-gb/docs/developer-program/getting-started/architecture/content-metadata.md).

  ```BrightScript
  ' Parse JSON data which contains DRM data and set DRM data to content meta data
  ' If you changed the JSON structure for your app, Please modify correspond code in this function
  ' @param jsonData json data which contains DRM data
  ' @param contentMetadata an object which contents meta data
  ' @see <a href="https://sdkdocs.roku.com/display/sdkdoc/Content+Meta-Data">Content Meta Data</a>
  ' @return none
  
  parsePallyConDrmDataFromJson(jsonData as object, contentMetadata as object) as void
  ```



- DoveRunner Multi-DRM data is the value used to request Widevine license through DoveRunner Multi-DRM service.

  * drmSchemeUuid : DRM type name. This sample supports "widevine" only.

  * drmLicenseUrl : License acquisition URL

  * cid: Unique ID of content

  * token: pri-built license token


- `channel1.json` file in this sample includes the sample data of DoveRunner Multi-DRM. You must modify this function if you use XML data instead of JSON or your own JSON format.
- If the drmSchemeUuid is not "widevine", this function outputs internal log message and returns.



##### Parameters:

- jsonData - JSON data which includes DoveRunner Multi-DRM data

- contentMetadata - [Content Meta-Data](https://developer.roku.com/en-gb/docs/developer-program/getting-started/architecture/content-metadata.md) object which will be set DoveRunner Multi-DRM data.



##### Returns:

- None.



#### setDrmDataToPlayerIfAvailable

- Sets the values for license acquistion to [Video Node](https://developer.roku.com/en-gb/docs/references/scenegraph/media-playback-nodes/video.md) object.

  ```BrightScript
  ' Set DRM custom data to videoPlayer
  ' @param video video node. It must contain content node and the content node must contain DRM data calling {@link .parsePallyDrmDataFromJson parsePallyDrmDataFromJson()}
  ' @return 0 if succeed, otherwise non-zero error code
  ' @see <a href="https://sdkdocs.roku.com/display/sdkdoc/Video">Video node</a>
  ' @see "Error code"
  ' @see "   0 if successful"
  ' @see "   1 if content node in video node does not have DRM data. It may be non-drm content."
  ' @see "   -1 if video node does not have content node"
  ' @see "   -2 An internal error to get custom data"
  
  setDrmDataToPlayerIfAvailable(videoNode as object) as integer
  ```

  

- The [Video Node](https://developer.roku.com/en-gb/docs/references/scenegraph/media-playback-nodes/video.md) object must contain [Content Meta-Data](https://developer.roku.com/en-gb/docs/developer-program/getting-started/architecture/content-metadata.md) which contains DoveRunner Multi-DRM data. In other words, 'content' field of [Video Node](https://developer.roku.com/en-gb/docs/references/scenegraph/media-playback-nodes/video.md) must be set and the value of 'content' must contain DoveRunner Multi-DRM data.

- Please refer to [parsePallyConDrmDataFromJson()](#parsePallyConDrmDataFromJson) for how to add DoveRunner Multi-DRM data to [Content Meta-Data](https://developer.roku.com/en-gb/docs/developer-program/getting-started/architecture/content-metadata.md).



##### Parameters:

- videoNode - [Video Node](https://developer.roku.com/en-gb/docs/references/scenegraph/media-playback-nodes/video.md) object which contains [Content Meta-Data](https://developer.roku.com/en-gb/docs/developer-program/getting-started/architecture/content-metadata.md) and will be set the values for license acquistion



##### Returns:

- Error code

  ```
  1: The vidoeNode did not contain DoveRunner Multi-DRM data. One of the following cases:
     * The content is Non-DRM.
     * The content is DRM enable but the application did not call parsePallyConDrmDataFromJson().
  0: Successful.
  -1: The vidoeNode did not contain Content Meta-Data.
  -2: Failure to set the values for license acquisition.
  ```

  

### **Read more**
[Roku Developers - DRM & content protection](https://developer.roku.com/en-gb/docs/specs/media/content-protection.md)

[Roku Developers - Roku OS support for DASH-IF](https://developer.roku.com/en-gb/docs/specs/media/dash-if.md)
