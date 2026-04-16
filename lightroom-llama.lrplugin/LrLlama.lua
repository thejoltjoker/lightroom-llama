local LrPathUtils = import 'LrPathUtils'
local LrLogger = import 'LrLogger'
local LrApplication = import "LrApplication"
local LrDialogs = import "LrDialogs"
local LrView = import "LrView"
local LrTasks = import "LrTasks"
local LrFunctionContext = import "LrFunctionContext"
local LrBinding = import "LrBinding"
local LrColor = import "LrColor"

local LlamaUtils = (assert(loadfile(LrPathUtils.child(_PLUGIN.path, "LlamaUtils.lua"))))()

local logger = LrLogger('LrLlama')
logger:enable("logfile")

local model = LlamaUtils.DEFAULT_MODEL

logger:info("Initializing Lightroom Llama Plugin")

local function sendDataToApi(photo, prompt, currentData, useCurrentData, useSystemPrompt)
    local response, err = LlamaUtils.sendDataToApi(photo, prompt, currentData, useCurrentData, useSystemPrompt, logger, model)
    if not response then
        LrDialogs.message("Error", err or "Failed to send data to the API.", "critical")
        return nil
    end
    return response
end

local function main()
    local catalog = LrApplication.activeCatalog()

    local selectedPhotos = catalog:getTargetPhotos()
    if #selectedPhotos == 0 then
        LrDialogs.message("No photo selected", "Please select a photo to view.", "critical")
        return
    end

    local selectedPhoto = selectedPhotos[1]
    local thumbnailPath = LlamaUtils.exportThumbnail(selectedPhoto, logger)

    LrFunctionContext.callWithContext("showLlamaDialog", function(context)
        local props = LrBinding.makePropertyTable(context)
        props.status = "Ready"
        props.statusColor = LrColor(0.149, 0.616, 0.412)
        props.prompt = "Caption this photo"
        props.title = selectedPhoto:getFormattedMetadata('title')
        props.caption = selectedPhoto:getFormattedMetadata('caption')
        props.response = ""
        props.useCurrentData = props.title ~= "" or props.caption ~= ""
        props.useSystemPrompt = true

        local f = LrView.osFactory()

        local c = f:view{
            bind_to_object = props,
            f:row{f:column{
                f:picture{
                    value = thumbnailPath,
                    frame_width = 2,
                    width = 400,
                    height = 400
                },
                width = 400
            }, f:spacer{
                width = 10
            }, f:column{
                f:column{f:static_text{
                    title = "Title:"
                }, f:spacer{f:label_spacing{}}, f:edit_field{
                    value = LrView.bind("title"),
                    width = 400
                }},
                f:spacer{
                    height = 10
                },
                f:static_text{
                    title = "Caption:",
                    alignment = 'left'
                },
                f:spacer{f:label_spacing{}},
                f:edit_field{
                    value = LrView.bind("caption"),
                    width = 400,
                    height = 100
                },
                f:spacer{
                    height = 10
                },
                f:separator{
                    width = 400
                },
                f:spacer{
                    height = 10
                },
                f:static_text{
                    title = "Prompt:",
                    alignment = 'left'
                },
                f:spacer{f:label_spacing{}},
                f:edit_field{
                    value = LrView.bind("prompt"),
                    width = 400,
                    height = 60
                },
                f:spacer{
                    height = 10
                },
                f:checkbox{
                    title = "Use current title and caption",
                    value = LrView.bind("useCurrentData")
                },
                f:spacer{
                    height = 10
                },
                f:checkbox{
                    title = "Use system prompt",
                    value = LrView.bind("useSystemPrompt")
                },
                f:spacer{
                    height = 10
                },
                f:separator{
                    width = 400
                },
                f:spacer{
                    height = 10
                },
                f:row{f:static_text{
                    title = "Model: " .. model,
                    fill_horizontal = 1
                }, f:static_text{
                    alignment = 'right',
                    title = LrView.bind("status"),
                    width = 200,
                    font = "<system/bold>",
                    text_color = LrView.bind("statusColor")
                }},
                f:spacer{
                    height = 10
                },
                f:row{f:push_button{
                    title = "Generate",
                    action = function()
                        props.status = "The llama is thinking..."
                        props.statusColor = LrColor(0.439, 0.345, 0.745)

                        LrTasks.startAsyncTask(function()
                            local apiResponse = sendDataToApi(selectedPhoto, props.prompt, {
                                title = props.title,
                                caption = props.caption,
                            }, props.useCurrentData, props.useSystemPrompt)
                            if apiResponse then
                                props.response = apiResponse
                                props.title = apiResponse.title
                                props.caption = apiResponse.caption
                                props.keywords = apiResponse.keywords
                            end
                            props.status = "Ready"
                            props.statusColor = LrColor(0.149, 0.616, 0.412)
                        end)
                    end
                }},
                f:spacer{
                    height = 20
                },
                width = 400
            }}
        }

        local result = LrDialogs.presentModalDialog({
            title = "Lightroom Llama",
            contents = c,
            actionVerb = "Save"
        })


        if result == "ok" then
            catalog:withWriteAccessDo("Save Llama metadata", function()
                selectedPhoto:setRawMetadata("title", props.title)
                selectedPhoto:setRawMetadata("caption", props.caption)
            end)

            LrDialogs.message("Metadata Saved", "Title and caption have been saved to the photo.", "info")
        end
    end)
end

LrTasks.startAsyncTask(main)
