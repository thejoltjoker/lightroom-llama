local LrHttp = import 'LrHttp'
local LrPathUtils = import 'LrPathUtils'
local LrFileUtils = import 'LrFileUtils'
local LrStringUtils = import 'LrStringUtils'
local LrTasks = import 'LrTasks'

local JSON = (assert(loadfile(LrPathUtils.child(_PLUGIN.path, "JSON.lua"))))()

local LlamaUtils = {}

LlamaUtils.DEFAULT_MODEL = "minicpm-v"
LlamaUtils.API_URL = "http://localhost:11434/api/generate"

LlamaUtils.SYSTEM_PROMPT_FULL_HEADER = [[You are an AI tasked with creating a JSON object containing a `title`, a `caption`, and a list of `keywords` based on a given piece of content (such as an image or video). ]]

LlamaUtils.SYSTEM_PROMPT_FULL_BODY = [[Please follow these detailed guidelines for creating excellent metadata:

1. **Title (Description):**
   - Provide a unique, descriptive title for the content.
   - The title should answer the Who, What, When, Where, and Why of the content.
   - It should be written as a sentence or phrase, similar to a news headline, capturing the key details, mood, and emotions of the scene.
   - Do not list keywords in the title. Avoid repetition of words and phrases.
   - Include helpful details such as the angle, focus, and perspective if relevant.
   - Do not include :.
   - If given, use the current title as a starting point.

2. **Caption:**
   - Provide a more detailed description or context for the content. This can be a fuller explanation of the title, including any relevant background or emotional tone that helps convey the essence of the scene.
   - If given, use the current caption as a starting point.

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

Use this structure and guidelines to generate titles, captions, and keywords that are descriptive, unique, and accurate.]]

LlamaUtils.SYSTEM_PROMPT_SIMPLE = [[You are an AI tasked with creating a JSON object containing a `title`, a `caption`, and a list of `keywords` based on a given piece of content (such as an image or video).

### JSON Format:
```json
{
  "title": "string",
  "caption": "string",
  "keywords": ["string"]
}
```
]]

local function buildSystemPrompt(useCurrentData, currentData)
    local currentBlock = ""
    if useCurrentData and currentData then
        currentBlock = [[The content currently has the following metadata which you need to implement and improve upon. It is important to keep the title and caption as close to this as possible.
Current title: "]] .. (currentData.title or "") .. [["
Current caption: "]] .. (currentData.caption or "") .. [["

]]
    end
    return LlamaUtils.SYSTEM_PROMPT_FULL_HEADER .. currentBlock .. LlamaUtils.SYSTEM_PROMPT_FULL_BODY
end

function LlamaUtils.exportThumbnail(photo, logger)
    local tempPath = LrFileUtils.chooseUniqueFileName(LrPathUtils.getStandardFilePath('temp') .. "/thumbnail.jpg")
    local done = false
    local ok = false

    photo:requestJpegThumbnail(512, 512, function(jpegData)
        if jpegData then
            local tempFile = io.open(tempPath, "wb")
            if tempFile then
                tempFile:write(jpegData)
                tempFile:close()
                ok = true
                if logger then logger:info("Thumbnail saved to " .. tempPath) end
            elseif logger then
                logger:error("Could not open temp file for writing: " .. tempPath)
            end
        elseif logger then
            logger:warn("requestJpegThumbnail returned no data")
        end
        done = true
    end)

    -- requestJpegThumbnail is async; wait for the callback before returning.
    local waited = 0
    while not done and waited < 100 do
        LrTasks.sleep(0.1)
        waited = waited + 1
    end

    if ok then
        return tempPath
    end
    if logger then logger:warn("Failed to export thumbnail") end
    return nil
end

function LlamaUtils.base64EncodeImage(imagePath, logger)
    local file = io.open(imagePath, "rb")
    if not file then
        if logger then logger:error("Could not open file: " .. tostring(imagePath)) end
        return nil
    end

    local binaryData = file:read("*all")
    file:close()

    return LrStringUtils.encodeBase64(binaryData)
end

function LlamaUtils.sendDataToApi(photo, prompt, currentData, useCurrentData, useSystemPrompt, logger, model)
    if logger then logger:info("Sending data to API") end

    local thumbnailPath = LlamaUtils.exportThumbnail(photo, logger)
    if not thumbnailPath then
        return nil, "Failed to export thumbnail"
    end

    local encodedImage = LlamaUtils.base64EncodeImage(thumbnailPath, logger)
    LrFileUtils.delete(thumbnailPath)

    if not encodedImage then
        return nil, "Failed to encode image"
    end

    local systemPrompt = nil
    if useSystemPrompt then
        systemPrompt = buildSystemPrompt(useCurrentData, currentData)
    else
        systemPrompt = LlamaUtils.SYSTEM_PROMPT_SIMPLE
    end

    local postData = {
        model = model or LlamaUtils.DEFAULT_MODEL,
        prompt = prompt,
        format = "json",
        system = systemPrompt,
        images = { encodedImage },
        stream = false
    }

    local jsonPayload = JSON:encode(postData)

    local response = LrHttp.post(LlamaUtils.API_URL, jsonPayload, {{
        field = "Content-Type",
        value = "application/json"
    }})

    if not response then
        return nil, "Failed to send data to the API"
    end

    local ok, responseData = pcall(function() return JSON:decode(response) end)
    if not ok or not responseData or not responseData.response then
        return nil, "Invalid response from API"
    end

    local ok2, responseJson = pcall(function() return JSON:decode(responseData.response) end)
    if not ok2 or not responseJson then
        return nil, "Failed to parse model JSON output"
    end

    return responseJson, nil
end

return LlamaUtils
