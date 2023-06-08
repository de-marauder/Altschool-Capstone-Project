 // Register the plugin
 FilePond.registerPlugin(FilePondPluginImageResize);

 FilePond.registerPlugin(FilePondPluginImagePreview);

 FilePond.registerPlugin(FilePondPluginFileEncode);

 FilePond.setOptions({
    stylePanelAspectRatio: 150 / 100, //set the file input section aspect ratio
    imageResizeTargetHeight: 150, // resize the height of files 
    imageResizeTargetWidth: 100  // // resize the width of files 
    
 })

 FilePond.parse(document.body)