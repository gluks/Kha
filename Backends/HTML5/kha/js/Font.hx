package kha.js;

import js.Browser;
import js.html.ImageElement;
import kha.Color;
import kha.FontStyle;
import kha.Kravur;

class Font implements kha.Font {
	public var kravur: Kravur;
	private var images: Map<Int, Map<Int, ImageElement>> = new Map();
	
	public function new(kravur: Kravur) {
		this.kravur = kravur;
	}
	
	public function height(fontSize: Int): Float {
		return kravur._get(fontSize).getHeight();
	}
	
	public function width(fontSize: Int, str: String, glyphs: Array<Int> = null): Float {
		var result : Float = kravur._get(fontSize, glyphs).stringWidth(str);
		if (result == 0 && str.length > 0)
			result = kravur._get(fontSize, glyphs).charactersWidth([48],0,1) * str.length;
		return result;
	}
	
	public function widthOfCharacters(fontSize: Int, characters: Array<Int>, start: Int, length: Int, glyphs: Array<Int> = null): Float {
		return kravur._get(fontSize, glyphs).charactersWidth(characters, start, length);
	}

	public function baseline(fontSize: Int): Float {
		return kravur._get(fontSize).getBaselinePosition();
	}
	
	public function getImage(fontSize: Int, color: Color, glyphs: Array<Int> = null): ImageElement {
		var imageIndex = glyphs == null ? fontSize : fontSize * 10000 + glyphs.length;
		if (!images.exists(imageIndex)) {
			images[imageIndex] = new Map();
		}
		if (!images[imageIndex].exists(color.value)) {
			var kravur = this.kravur._get(fontSize, glyphs);
			var canvas: Dynamic = Browser.document.createElement("canvas");
			canvas.width = kravur.width;
			canvas.height = kravur.height;
			var ctx = canvas.getContext("2d");
			ctx.fillStyle = "black";
			ctx.fillRect(0, 0, kravur.width, kravur.height);
		
			var imageData = ctx.getImageData(0, 0, kravur.width, kravur.height);
			var bytes = cast(kravur.getTexture(), CanvasImage).bytes;
			for (i in 0...bytes.length) {
				imageData.data[i * 4 + 0] = color.Rb;
				imageData.data[i * 4 + 1] = color.Gb;
				imageData.data[i * 4 + 2] = color.Bb;
				imageData.data[i * 4 + 3] = bytes.get(i);
			}
			ctx.putImageData(imageData, 0, 0);
		
			var img: ImageElement = cast Browser.document.createElement("img");
			img.src = canvas.toDataURL("image/png");
			images[imageIndex][color.value] = img;
			return img;
		}
		return images[imageIndex][color.value];
	}
	
	public function unload(): Void {
		kravur = null;
		images = null;
	}
}
