package hxd;

enum Platform {
	IOS;
	Android;
	WebGL;
	PC;
	Console;
	FlashPlayer;
}

enum SystemValue {
	IsTouch;
	IsWindowed;
	IsMobile;
}

class SystemKha {

	public static var width(get,never) : Int;
	public static var height(get, never) : Int;
	public static var lang(get, never) : String;
	public static var platform(get, never) : Platform;
	public static var screenDPI(get,never) : Float;
	public static var setCursor = setNativeCursor;

	/**
		Can be used to temporarly disable infinite loop check
	**/
	public static var allowTimeout(get, set) : Bool;

	/**
		If you have a time consuming calculus that might trigger a timeout, you can either disable timeouts with [allowTimeout] or call timeoutTick() frequently.
	**/
	public static function timeoutTick() : Void {
	}

	static var loopFunc : Void -> Void;

	public static function getCurrentLoop() : Void -> Void {
		return loopFunc;
	}

	public static function setLoop( f : Void -> Void ) : Void {
		loopFunc = f;
	}

	public static function start( callb : Void -> Void ) : Void {
		kha.System.init({title: "heaps", width: 1024, height: 768}, function () {
			kha.System.notifyOnRender(function (framebuffer: kha.Framebuffer) {
				h3d.impl.KhaDriver.g = framebuffer.g4;
				if (loopFunc != null) {
					loopFunc();
				}
				h3d.impl.KhaDriver.g = null;
			});
			callb();
		});
	}

	public static function setNativeCursor( c : Cursor ) : Void {
	}

	public static function getDeviceName() : String {
		return "Unknown";
	}

	public static function getDefaultFrameRate() : Float {
		return 60.;
	}

	public static function getValue( s : SystemValue ) : Bool {
		return false;
	}

	public static function exit() : Void {
	}

	// getters

	static function get_width() : Int return 0;
	static function get_height() : Int return 0;
	static function get_lang() : String return "en";
	static function get_platform() : Platform return PC;
	static function get_screenDPI() : Int return 72;
	static function get_allowTimeout() return false;
	static function set_allowTimeout(b) return false;

}
