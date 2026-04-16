local LrPathUtils = import 'LrPathUtils'
local LrLogger = import 'LrLogger'
local LrApplication = import "LrApplication"
local LrDialogs = import "LrDialogs"
local LrView = import "LrView"
local LrTasks = import "LrTasks"
local LrFunctionContext = import "LrFunctionContext"
local LrBinding = import "LrBinding"
local LrColor = import "LrColor"
local LrProgressScope = import "LrProgressScope"

local LlamaUtils = (assert(loadfile(LrPathUtils.child(_PLUGIN.path, "LlamaUtils.lua"))))()

local logger = LrLogger('BatchLrLlama')
logger:enable("logfile")

local model = LlamaUtils.DEFAULT_MODEL

logger:info("Initializing Lightroom Llama Batch Processing Plugin")

local function sendDataToApi(photo, prompt, currentData, useCurrentData, useSystemPrompt)
    local userPrompt = prompt
    if useCurrentData then
        userPrompt = "Title: " .. (currentData.title or "") .. " Caption: " .. (currentData.caption or "") .. " " .. prompt
    end
    return LlamaUtils.sendDataToApi(photo, userPrompt, currentData, useCurrentData, useSystemPrompt, logger, model)
end

local function addKeywordsWithParent(catalog, photo, keywords)
    if not keywords or type(keywords) ~= "table" then
        return
    end

    local llmKeyword = catalog:createKeyword("llm", nil, true, nil, true)
    if not llmKeyword then
        error("Failed to create or get 'llm' parent keyword")
    end

    for _, keyword in ipairs(keywords) do
        if keyword and keyword ~= "" then
            local childKeyword = catalog:createKeyword(keyword, nil, true, llmKeyword, true)
            if childKeyword then
                photo:addKeyword(childKeyword)
            else
                logger:warn("Failed to create keyword: " .. tostring(keyword))
            end
        end
    end
end

local function getLlmKeywordsFromPhoto(photo)
    local llmKeywords = {}

    local success, result = pcall(function()
        local allKeywords = photo:getRawMetadata("keywords")

        if allKeywords then
            for _, keyword in ipairs(allKeywords) do
                local parent = keyword:getParent()
                if parent and parent:getName() == "llm" then
                    table.insert(llmKeywords, keyword:getName())
                end
            end
        end
    end)

    if not success then
        logger:warn("Error getting LLM keywords: " .. tostring(result))
        return {}
    end

    return llmKeywords
end

local function showBatchResults(results)
    local successful = 0
    local failed = 0
    local skipped = 0

    for _, result in ipairs(results) do
        if result.success then
            if result.error and string.find(result.error, "Skipped") then
                skipped = skipped + 1
            else
                successful = successful + 1
            end
        else
            failed = failed + 1
        end
    end

    if failed > 0 then
        local message = string.format(
            "Batch processing complete!\n\nSuccessful: %d\nSkipped: %d\nFailed: %d\n\nTotal processed: %d photos",
            successful, skipped, failed, #results
        )

        local failedPhotos = {}
        for _, result in ipairs(results) do
            if not result.success then
                local photoName = result.photo:getFormattedMetadata('fileName') or "Unknown"
                table.insert(failedPhotos, photoName .. ": " .. (result.error or "Unknown error"))
            end
        end

        message = message .. "\n\nFailed photos:\n" .. table.concat(failedPhotos, "\n")

        LrDialogs.message("Batch Processing Results", message, "info")
    end
end

local function showBatchDialog(selectedPhotos)
    LrFunctionContext.callWithContext("showBatchDialog", function(context)
        local props = LrBinding.makePropertyTable(context)
        props.prompt = "Caption this photo"
        props.useCurrentData = false
        props.useSystemPrompt = true
        props.skipExisting = true

        local f = LrView.osFactory()

        local c = f:view{
            bind_to_object = props,
            f:column{
                f:static_text{
                    title = string.format("Batch process %d selected photos with Llama", #selectedPhotos),
                    font = "<system/bold>"
                },
                f:spacer{height = 20},

                f:static_text{
                    title = "Prompt:"
                },
                f:spacer{f:label_spacing{}},
                f:edit_field{
                    value = LrView.bind("prompt"),
                    width = 400,
                    height = 60
                },
                f:spacer{height = 15},

                f:checkbox{
                    title = "Use current title and caption data",
                    value = LrView.bind("useCurrentData")
                },
                f:spacer{height = 10},

                f:checkbox{
                    title = "Use system prompt (recommended)",
                    value = LrView.bind("useSystemPrompt")
                },
                f:spacer{height = 10},

                f:checkbox{
                    title = "Skip photos that already have LLM keywords",
                    value = LrView.bind("skipExisting")
                },
                f:spacer{height = 20},

                f:separator{width = 400},
                f:spacer{height = 10},

                f:static_text{
                    title = "Model: " .. model,
                    font = "<system>"
                },
                f:spacer{height = 10},

                f:static_text{
                    title = "Note: This process may take several minutes depending on the number of photos.",
                    font = "<system>",
                    text_color = LrColor(0.6, 0.6, 0.6)
                }
            }
        }

        local result = LrDialogs.presentModalDialog({
            title = "Batch Process with Llama",
            contents = c,
            actionVerb = "Start Processing"
        })

        if result == "ok" then
            local settings = {
                prompt = props.prompt,
                useCurrentData = props.useCurrentData,
                useSystemPrompt = props.useSystemPrompt,
                skipExisting = props.skipExisting
            }

            local results = {}
            local catalog = LrApplication.activeCatalog()

            LrFunctionContext.callWithContext("batchProcessing", function(context)
                local progressScope = LrProgressScope({
                    title = "Processing photos with Llama",
                    functionContext = context
                })

                progressScope:setPortionComplete(0, #selectedPhotos)

                for i, photo in ipairs(selectedPhotos) do
                    if progressScope:isCanceled() then
                        break
                    end

                    local photoName = photo:getFormattedMetadata('fileName') or "Photo " .. i
                    progressScope:setCaption("Processing: " .. photoName)

                    local result = {
                        photo = photo,
                        success = false,
                        error = nil,
                        metadata = nil
                    }

                    local shouldSkip = false
                    if settings.skipExisting then
                        local existingKeywords = getLlmKeywordsFromPhoto(photo)
                        if #existingKeywords > 0 then
                            result.success = true
                            result.error = "Skipped - already has LLM keywords"
                            shouldSkip = true
                        end
                    end

                    if not shouldSkip then
                        local currentData = {
                            title = photo:getFormattedMetadata('title') or "",
                            caption = photo:getFormattedMetadata('caption') or ""
                        }

                        local apiResponse, apiError = sendDataToApi(photo, settings.prompt, currentData, settings.useCurrentData, settings.useSystemPrompt)

                        if apiResponse then
                            result.success = true
                            result.metadata = apiResponse
                        else
                            result.error = apiError or "Unknown API error"
                        end
                    end

                    table.insert(results, result)
                    progressScope:setPortionComplete(i, #selectedPhotos)
                end

                progressScope:done()
            end)

            catalog:withWriteAccessDo("Save Llama batch metadata", function()
                for _, result in ipairs(results) do
                    if result.success and result.metadata then
                        local apiResponse = result.metadata
                        local photo = result.photo

                        if apiResponse.title then
                            photo:setRawMetadata("title", apiResponse.title)
                        end
                        if apiResponse.caption then
                            photo:setRawMetadata("caption", apiResponse.caption)
                        end
                        if apiResponse.keywords then
                            addKeywordsWithParent(catalog, photo, apiResponse.keywords)
                        end
                    end
                end
            end)

            showBatchResults(results)
        end
    end)
end

local function main()
    local catalog = LrApplication.activeCatalog()
    local selectedPhotos = catalog:getTargetPhotos()

    if #selectedPhotos == 0 then
        LrDialogs.message("No photos selected", "Please select one or more photos to process.", "critical")
        return
    end

    if #selectedPhotos == 1 then
        local result = LrDialogs.confirm("Single photo selected",
            "You have selected only one photo. Would you like to use the regular Lightroom Llama dialog instead?",
            "Use Regular Dialog", "Continue with Batch", "Cancel")

        if result == "ok" then
            LrDialogs.message("Suggestion", "Please use the 'Lightroom Llama...' menu item for single photos.", "info")
            return
        elseif result == "cancel" then
            return
        end
    end

    showBatchDialog(selectedPhotos)
end

LrTasks.startAsyncTask(main)
