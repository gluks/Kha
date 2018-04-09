package kha.js;

import haxe.ds.Vector;
import haxe.io.Bytes;
import haxe.io.BytesOutput;
import js.Browser;
import js.html.ArrayBuffer;
import js.html.audio.AudioBuffer;
import js.html.AudioElement;
import js.html.XMLHttpRequest;
import js.Lib;

using StringTools;

class MobileWebAudioSound extends kha.Sound {
	public var _buffer: AudioBuffer; //Dynamic;

	public function new(filename: String, done: kha.Sound -> Void) {
		super();
		var request = untyped new XMLHttpRequest();
		request.open("GET", filename, true);
		request.responseType = "arraybuffer";
		
		request.onerror = function() {
			trace("Error loading " + filename);
		};
		
		request.onload = function() {
			compressedData = Bytes.ofData(request.response);
			uncompressedData = null;
			MobileWebAudio._context.decodeAudioData(compressedData.getData(),
				function (buffer) {
					if (buffer != null)
						_buffer = cast(buffer);
					done(this);
				},
				function () {
					throw "Audio format not supported";
				}
			);
		};
		request.send(null);
	}
	
	override public function uncompress(done: Void->Void): Void {
		if (_buffer != null) {
			uncompressedData = new Vector<Float>(_buffer.getChannelData(0).length * 2);
			if (_buffer.numberOfChannels == 1) {
				for (i in 0..._buffer.getChannelData(0).length) {
					uncompressedData[i * 2 + 0] = _buffer.getChannelData(0)[i];
					uncompressedData[i * 2 + 1] = _buffer.getChannelData(0)[i];
				}
			}
			else {
				for (i in 0..._buffer.getChannelData(0).length) {
					uncompressedData[i * 2 + 0] = _buffer.getChannelData(0)[i];
					uncompressedData[i * 2 + 1] = _buffer.getChannelData(1)[i];
				}
			}
			compressedData = null;
		}
		
		done();
	}
}
