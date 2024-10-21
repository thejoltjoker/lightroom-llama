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

    -- Return or display the Base64 string
    logger:info("Base64 encoded image: " .. base64Data)
    return base64Data
end

local function sendDataToApi(photo)
    local encodedImage = base64EncodeImage(exportThumbnail(photo))
    local url = "http://localhost:11434/api/generate"
    logger:info("Encoded image: " .. encodedImage)
    -- Define data to be sent (as a Lua table)
    local postData = {
        model = "minicpm-v",
        prompt = "Caption this photo",
        images = {encodedImage},
        stream = false,
        keep_alive = "15m"
    }

    -- Convert the Lua table to a JSON string
    local jsonPayload = JSON:encode(postData)
    logger:info(jsonPayload)
    -- Make a POST request
    local response, headers = LrHttp.post(url, jsonPayload, {{
        field = "Content-Type",
        value = "application/json"
    }})
    logger:info(response)
    -- Check the response
    -- if response then
    --     -- Display the response in a Lightroom dialog (for demonstration purposes)
    --     logger:info(response)
    --     -- LrDialogs.message("API Response", response, "info")
    -- else
    --     LrDialogs.message("Error", "Failed to send data to the API.", "critical")
    -- end
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
    sendDataToApi(selectedPhoto)

    LrFunctionContext.callWithContext("showLlamaDialog", function(context)

        -- Create a view factory
        local f = LrView.osFactory()

        -- Define the dialog contents
        local c = f:column{f:static_text{
            title = "Selected Photo Preview",
            alignment = 'center'
        }, f:row{f:picture{
            value = thumbnailPath, -- Path of the selected photo
            width = 300, -- Adjust width as needed
            height = 200 -- Adjust height as needed
        }}}

        -- Show the dialog
        LrDialogs.presentModalDialog({
            title = "Selected Photo Viewer",
            contents = c
        })
    end)
end

LrTasks.startAsyncTask(main)
