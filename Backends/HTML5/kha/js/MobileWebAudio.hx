package kha.js;

import js.html.audio.AudioContext;
import js.html.audio.AudioProcessingEvent;
import js.html.audio.ScriptProcessorNode;
import kha.audio2.Buffer;

@:keep
class MobileWebAudio {
	@:noCompletion public static var _context: AudioContext;
	private static var buffer: Buffer;
	private static var processingNode: ScriptProcessorNode;
	
	@:noCompletion public static function _init(): Void {
		trace("MobileWebAudio _init");
		try {
			_context = new AudioContext();
		}
		catch (e: Dynamic) {
			_context = null;
		}
		if (_context == null)
		{
			try {
				_context = untyped __js__('new webkitAudioContext();');
			}
			catch (e: Dynamic) {
				_context = null;
			}
		}
		if (_context == null)
			return;
		
		var bufferSize = 1024 * 2;
		buffer = new Buffer(bufferSize * 4, 2, Std.int(_context.sampleRate));
		
		processingNode = _context.createScriptProcessor(bufferSize, 0, 2);
		processingNode.onaudioprocess = function (e: AudioProcessingEvent) {
			var output1 = e.outputBuffer.getChannelData(0);
			var output2 = e.outputBuffer.getChannelData(1);
			if (kha.audio2.Audio.audioCallback != null) {
				kha.audio2.Audio.audioCallback(e.outputBuffer.length * 2, buffer);
				for (i in 0...e.outputBuffer.length) {
					output1[i] = buffer.data.get(buffer.readLocation);
					buffer.readLocation += 1;
					output2[i] = buffer.data.get(buffer.readLocation);
					buffer.readLocation += 1;
					if (buffer.readLocation >= buffer.size) {
						buffer.readLocation = 0;
					}
				}
			}
			else {
				for (i in 0...e.outputBuffer.length) {
					output1[i] = 0;
					output2[i] = 0;
				}
			}
		}
		processingNode.connect(_context.destination);
	}
	
	public static function play(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		var channel = new MobileWebAudioChannel(cast sound, loop);
		channel.play();
		return channel; 
	}

	public static function stream(sound: Sound, loop: Bool = false): kha.audio1.AudioChannel {
		return play(sound, loop);
	}
}
