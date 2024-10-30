return {
    VERSION = {
        major = 0,
        minor = 1,
        revision = 1
    },
    LrPluginName = "Lightroom Llama",
    LrPluginDescription = "Generate metadata for your photos with ollama, directly in Lightroom",
    LrToolkitIdentifier = "com.thejoltjoker.lightroom.llama",
    LrPluginInfoUrl = "https://github.com/thejoltjoker/lightroom-llama",
    LrPluginInfoUrlProvider = "http://www.thejoltjoker.com",
    LrSdkVersion = 10.0,
    LrSdkMinimumVersion = 5.0,
    LrLibraryMenuItems = {{
        title = "Lightroom Llama...",
        file = "LrLlama.lua"
    }}
}
