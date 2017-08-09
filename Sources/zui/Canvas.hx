package zui;

@:access(zui.Zui)
class Canvas {

	public static var assetMap = new Map<Int, kha.Image>();
	static var events:Array<String> = [];

	public static function draw(ui: Zui, canvas: TCanvas, g: kha.graphics2.Graphics):Array<String> {
		events = [];

		ui.begin(g);
		ui.g = g;

		for (elem in canvas.elements) drawElement(ui, canvas, elem);

		ui.end();
		return events;
	}

	static function drawElement(ui: Zui, canvas: TCanvas, element: TElement) {

		ui._x = canvas.x + element.x;
		ui._y = canvas.y + element.y;
		ui._w = element.width;

		switch (element.type) {
		case Text:
			var size = ui.fontSmallSize;
			ui.fontSmallSize = element.height;
			ui.text(element.text);
			ui.fontSmallSize = size;
		case Button:
			if (ui.button(element.text)) {
				var e = element.event;
				if (e != null && e != "") events.push(e);
			}
		case Image:
			var image = getAsset(canvas, element.asset);
			if (image != null) {
				ui.imageScrollAlign = false;
				var tint = element.color != null ? element.color : 0xffffffff;
				if (ui.image(image, tint, element.height) == zui.Zui.State.Released) {
					var e = element.event;
					if (e != null && e != "") events.push(e);
				}
				ui.imageScrollAlign = true;
			}
		}

		if (element.children != null) for (c in element.children) drawElement(ui, canvas, c);
	}

	public static function getAsset(canvas: TCanvas, asset: String): kha.Image {
		for (a in canvas.assets) if (a.name == asset) return assetMap.get(a.id);
		return null;
	}

	static var elemId = -1;
	public static function getElementId(canvas: TCanvas): Int {
		if (elemId == -1) for (e in canvas.elements) if (elemId < e.id) elemId = e.id;
		return ++elemId;
	}

	static var assetId = -1;
	public static function getAssetId(canvas: TCanvas): Int {
		if (assetId == -1) for (a in canvas.assets) if (assetId < a.id) assetId = a.id;
		return ++assetId;
	}
}

typedef TCanvas = {
	var name: String;
	var x: Float;
	var y: Float;
	var width: Int;
	var height: Int;
	var elements: Array<TElement>;
	@:optional var assets: Array<TAsset>;
}

typedef TElement = {
	var id: Int;
	var type: ElementType;
	var name: String;
	var x: Float;
	var y: Float;
	var width: Int;
	var height: Int;
	@:optional var text: String;
	@:optional var event: String;
	@:optional var color: Int;
	@:optional var anchor: Int;
	@:optional var children: Array<TElement>;
	@:optional var asset: String;
}

typedef TAsset = {
	var id: Int;
	var name:String;
	var file:String;
}

@:enum abstract ElementType(Int) from Int {
	var Text = 0;
	var Image = 1;
	var Button = 2;
}

@:enum abstract AnchorType(Int) from Int {
	var None = 0;
	var TopLeft = 1;
	var Top = 2;
	var TopRight = 3;
	var Left = 4;
	var Center = 5;
	var Right = 6;
	var BottomLeft = 7;
	var Bottom = 8;
	var BottomRight = 9;
}
