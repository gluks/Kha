package kha;

class LoaderImpl {
	static var loadingImages: Map<Int, Image->Void> = new Map();
	static var imageId = -1;
	static var loadingSounds: Map<Int, Sound->Void> = new Map();
	static var soundId = -1;
	static var loadingVideos: Map<Int, Video->Void> = new Map();
	static var videoId = -1;
	static var loadingBlobs: Map<Int, Blob->Void> = new Map();
	static var blobId = -1;
	
	public static function getImageFormats(): Array<String> {
		return ["png", "jpg", "hdr"];
	}
	
	public static function loadImageFromDescription(desc: Dynamic, done: kha.Image -> Void) {
		++imageId;
		loadingImages[imageId] = done;
		Worker.postMessage({ command: 'loadImage', file: desc.files[0], id: imageId });
	}
	
	public static function _loadedImage(value: Dynamic) {
		var image = new Image(value.id, value.width, value.height, value.realWidth, value.realHeight);
		loadingImages[value.id](image);
		loadingImages.remove(value.id);
	}
	
	public static function getSoundFormats(): Array<String> {
		return ["mp4"];
	}
	
	public static function loadSoundFromDescription(desc: Dynamic, done: kha.Sound -> Void) {
		++soundId;
		loadingSounds[soundId] = done;
		Worker.postMessage({ command: 'loadSound', file: desc.files[0], id: soundId });
	}
	
	public static function getVideoFormats(): Array<String> {
		return ["mp4"];
	}

	public static function loadVideoFromDescription(desc: Dynamic, done: kha.Video -> Void): Void {
		++videoId;
		loadingVideos[videoId] = done;
		Worker.postMessage({ command: 'loadVideo', file: desc.files[0], id: videoId });
	}
    
	public static function loadBlobFromDescription(desc: Dynamic, done: Blob -> Void) {
		++blobId;
		loadingBlobs[blobId] = done;
		Worker.postMessage({ command: 'loadBlob', file: desc.files[0], id: blobId });
	}
	
	public static function loadFontFromDescription(desc: Dynamic, done: Font -> Void): Void {
		loadBlobFromDescription(desc, function (blob: Blob) {
			done(new Kravur(blob));
		});
	}
}
