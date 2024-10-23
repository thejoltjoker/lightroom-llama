local LrHttp = import 'LrHttp'
local LrMD5 = import 'LrMD5'
local LrPathUtils = import 'LrPathUtils'
local LrLogger = import 'LrLogger'
local LrApplication = import "LrApplication"
local LrErrors = import "LrErrors"
local LrDialogs = import "LrDialogs"
local LrView = import "LrView"
local LrTasks = import "LrTasks"
local LrFunctionContext = import "LrFunctionContext"
local LrFileUtils = import 'LrFileUtils'
local LrStringUtils = import 'LrStringUtils'
local LrBinding = import "LrBinding"
local logger = LrLogger('LrLlama')
logger:enable("logfile") -- Logs to ~/Documents/LrClassicLogs | tail -f LrLlama.log
-- local log = logger:quickf('info')

logger:info("Initializing Lightroom Llama Plugin")

JSON = (assert(loadfile(LrPathUtils.child(_PLUGIN.path, "JSON.lua"))))()

local function exportThumbnail(photo)
    local tempPath = LrFileUtils.chooseUniqueFileName(LrPathUtils.getStandardFilePath('temp') .. "/thumbnail.jpg")

    local success, result = photo:requestJpegThumbnail(512, 512, function(jpegData)
        -- Save the JPEG thumbnail to the temporary file
        if jpegData then
            local tempFile = io.open(tempPath, "wb")
            tempFile:write(jpegData)
            tempFile:close()
            logger:info("Thumbnail saved to " .. tempPath)
            return true
        end
        return false
    end)

    if success then
        return tempPath
    else
        logger:warn("Failed to export thumbnail")
        return nil
    end
end

local function fetchDataFromApi()
    -- Example API endpoint (replace with your actual API)
    local url = "https://httpbin.org/get"

    -- Make a GET request
    local response, headers = LrHttp.get(url)

    -- Check the response
    if response then
        local response_json = JSON:decode(response)
        logger:info(response_json.origin)
        -- Display the response in a Lightroom dialog (for demonstration purposes)
        -- LrDialogs.message("API Response", response_json, "info")
    else
        LrDialogs.message("Error", "Failed to fetch data from the API.", "critical")
    end
end

local function base64EncodeImage(imagePath)

    -- Read the image file as binary
    local file = io.open(imagePath, "rb") -- Open the file in binary mode
    if not file then
        LrDialogs.message("Error", "Could not open file: " .. imagePath, "critical")
        return
    end

    local binaryData = file:read("*all") -- Read the entire file as binary data
    file:close() -- Close the file

    -- Encode the binary data to Base64
    local base64Data = LrStringUtils.encodeBase64(binaryData)

    return base64Data
end

local function sendDataToApi(photo, prompt)
    logger:info("Sending data to API")
    local encodedImage = base64EncodeImage(exportThumbnail(photo))
    local url = "http://localhost:11434/api/generate"

    -- Define data to be sent (as a Lua table)
    local postData = {
        model = "minicpm-v",
        prompt = prompt,
        format = "json",
        system = [[You are an AI tasked with creating a JSON object containing a `title`, a `caption`, and a list of `keywords` based on a given piece of content (such as an image or video). Please follow these detailed guidelines for creating excellent metadata:

1. **Title (Description):**
   - Provide a unique, descriptive title for the content.
   - The title should answer the Who, What, When, Where, and Why of the content.
   - It should be written as a sentence or phrase, similar to a news headline, capturing the key details, mood, and emotions of the scene.
   - Do not list keywords in the title. Avoid repetition of words and phrases.
   - Include helpful details such as the angle, focus, and perspective if relevant.
   - Do not include :.

2. **Caption:**
   - Provide a more detailed description or context for the content. This can be a fuller explanation of the title, including any relevant background or emotional tone that helps convey the essence of the scene.
   
3. **Keywords:**
   - Provide a list of 7 to 50 keywords.
   - Keywords should be specific and directly related to the content.
   - Include broader topics, feelings, concepts, or associations represented by the content.
   - Avoid using unrelated terms or repeating words or compound words.
   - Do not include links, camera information, or trademarks unless required for editorial content.

### JSON Format:
```json
{
  "title": "string",
  "caption": "string",
  "keywords": ["string"]
}
```

### Example:
```json
{
  "title": "A serene sunset over a peaceful beach with golden skies",
  "caption": "A calm evening beach scene with a golden sunset reflecting on the ocean waves, creating a peaceful and tranquil mood. The horizon is clear with soft, pastel colors blending into the blue sky.",
  "keywords": ["sunset", "beach", "calm", "ocean", "serene", "golden skies", "peaceful", "tranquil", "pastel colors", "horizon", "evening"]
}
```

Use this structure and guidelines to generate titles, captions, and keywords that are descriptive, unique, and accurate.]],
        images = {encodedImage},
        stream = false
    }

    -- Convert the Lua table to a JSON string
    local jsonPayload = JSON:encode(postData)

    -- Make a POST request
    local response, headers = LrHttp.post(url, jsonPayload, {{
        field = "Content-Type",
        value = "application/json"
    }})

    if response then
        local response_json = JSON:decode(response)
        local response_data = JSON:decode(response_json.response)
        logger:info(response_data)
        return response_data
    else
        LrDialogs.message("Error", "Failed to send data to the API.", "critical")
        return "Error: Failed to send data to the API."
    end
end

local function main()
    -- Get the active catalog
    local catalog = LrApplication.activeCatalog()

    -- Get the selected photo
    local selectedPhotos = catalog:getTargetPhotos() -- Gets all selected photos
    if #selectedPhotos == 0 then
        LrDialogs.message("No photo selected", "Please select a photo to view.", "critical")
        return
    end

    -- Get the first selected photo (if multiple, you can modify the code for more)
    local selectedPhoto = selectedPhotos[1]
    local thumbnailPath = exportThumbnail(selectedPhoto)
    logger:info("Thumbnail path: " .. thumbnailPath)

    LrFunctionContext.callWithContext("showLlamaDialog", function(context)
        local props = LrBinding.makePropertyTable(context)
        props.prompt = "Caption this photo"
        props.title = selectedPhoto:getFormattedMetadata('title')
        props.caption = selectedPhoto:getFormattedMetadata('caption')
        props.keywords = selectedPhoto:getRawMetadata('keywords') or {}
        props.response = ""
        props.useCurrentData = props.title ~= "" or props.caption ~= ""

        -- Create a view factory
        local f = LrView.osFactory()

        -- Define the dialog contents
        local c = f:column{
            bind_to_object = props,
            f:row{f:column{f:picture{
                value = thumbnailPath,
                frame_width = 2
            }}, f:spacer{
                width = 10
            }, f:column{f:column{f:static_text{
                title = "Title:"
            }, f:spacer{f:label_spacing{}}, f:edit_field{
                value = LrView.bind("title"), -- Bind to the new response property
                width = 400
            }}, f:spacer{
                height = 10
            }, f:column{f:static_text{
                title = "Caption:",
                alignment = 'left'
            }, f:spacer{f:label_spacing{}}, f:edit_field{
                value = LrView.bind("caption"), -- Bind to the new response property
                width = 400,
                height = 100
            }}, f:spacer{
                height = 10
            }, f:column{f:static_text{
                title = "Keywords:",
                alignment = 'left'
            }, f:spacer{f:label_spacing{}}, f:simple_list{
                value = LrView.bind("keywords"), -- Bind to the new response property
                width = 400,
                height = 100
            }}, f:spacer{
                height = 10
            }, f:checkbox{
                title = "Use current data in generation",
                value = LrView.bind("useCurrentData")

            }, f:spacer{
                height = 10
            }, f:push_button{
                title = "Generate",
                action = function()
                    props.response = "The llama is thinking..."
                    LrTasks.startAsyncTask(function()
                        local apiResponse = sendDataToApi(selectedPhoto, props.prompt)
                        props.response = apiResponse
                        props.title = apiResponse.title
                        props.caption = apiResponse.caption
                        props.keywords = apiResponse.keywords
                    end)
                end
            }, f:spacer{
                height = 20
            }, f:column{f:static_text{
                title = "Prompt:",
                alignment = 'left'
            }, f:spacer{f:label_spacing{}}, f:edit_field{
                value = LrView.bind("prompt"),
                width = 400,
                height = 60
            }}}}
        }

        -- Show the dialog
        local result = LrDialogs.presentModalDialog({
            title = "Lightroom Llama",
            contents = c,
            actionVerb = "Save"
        })
        logger:info(result)

        if result == "ok" then
            -- Save the metadata to the photo
            catalog:withWriteAccessDo("Save Llama metadata", function()
                selectedPhoto:setRawMetadata("title", props.title)
                selectedPhoto:setRawMetadata("caption", props.caption)
                -- selectedPhoto:setRawMetadata("keywords", props.keywords)
            end)

            LrDialogs.message("Metadata Saved", "Title, caption, and keywords have been saved to the photo.", "info")
        end
    end)
end

LrTasks.startAsyncTask(main)
