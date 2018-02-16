package h3d.impl;

import h3d.impl.Driver;
import h3d.mat.Pass;
import kha.Image;
import kha.graphics4.IndexBuffer;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;

class KhaDriver extends h3d.impl.Driver {
	public static var g: kha.graphics4.Graphics;

	public function new(antiAlias: Int) {

	}

	override function resize(width:Int, height:Int)  {
		
	}

	override function begin(frame:Int) {
		g.begin();
	}

	override function isDisposed() {
		return false;
	}

	override function init(onCreate:Bool->Void, forceSoftware=false) {
		onCreate(false);
	}

	override function clear(?color:h3d.Vector, ?depth:Float, ?stencil:Int) {
		g.clear(color != null ? kha.Color.fromFloats(color.r, color.g, color.b, color.a) : null, depth, stencil);
	}

	override function getDriverName(details:Bool) {
		return "Kha";
	}

	override function present() {
		g.end();
	}

	override function getDefaultDepthBuffer():h3d.mat.DepthBuffer {
		trace("TODO: getDefaultDepthBuffer");
		return null;
	}

	override function allocVertexes(m:ManagedBuffer):VertexBuffer {
		var structure = new kha.graphics4.VertexStructure();
		for (i in 0...m.stride) {
			structure.add("_" + i, kha.graphics4.VertexData.Float1);
		}
		return new VertexBuffer(m.size, structure, m.flags.has(Dynamic) ? Usage.DynamicUsage : Usage.StaticUsage);
	}

	override function allocIndexes(count:Int) : IndexBuffer {
		return new IndexBuffer(count, StaticUsage);
	}

	override function allocDepthBuffer(b:h3d.mat.DepthBuffer):DepthBuffer {
		throw "allocDepthBuffer";
	}

	override function disposeDepthBuffer(b:h3d.mat.DepthBuffer) @:privateAccess {
		
	}

	override function captureRenderBuffer(pixels:hxd.Pixels) {
		throw "captureRenderBuffer";
	}

	override function allocTexture(t:h3d.mat.Texture):Texture {
		return Image.create(t.width, t.height);
	}

	override function disposeTexture(t:h3d.mat.Texture) {
		
	}

	override function disposeVertexes(v:VertexBuffer) {
		
	}

	override function disposeIndexes(i:IndexBuffer) {
		
	}

	override function generateMipMaps(texture:h3d.mat.Texture) {
		
	}

	override function uploadIndexBuffer(i:IndexBuffer, startIndice:Int, indiceCount:Int, buf:hxd.IndexBuffer, bufPos:Int) {
		var indices = i.lock(startIndice, indiceCount);
		for( i in 0...indiceCount ) {
			indices.set(i, buf[bufPos + i]);
		}
		i.unlock();
	}

	override function uploadIndexBytes(i:IndexBuffer, startIndice:Int, indiceCount:Int, buf:haxe.io.Bytes, bufPos:Int) {
		throw "uploadIndexBytes";
	}

	override function uploadVertexBuffer(v:VertexBuffer, startVertex:Int, vertexCount:Int, buf:hxd.FloatBuffer, bufPos:Int) {
		var vertices = v.lock(startVertex, vertexCount);
		for( i in 0...vertexCount ) {
			vertices.set(i, buf[bufPos + i]);
		}
		v.unlock();
	}

	override function uploadVertexBytes(v:VertexBuffer, startVertex:Int, vertexCount:Int, buf:haxe.io.Bytes, bufPos:Int) {
		throw "uploadVertexBytes";
	}

	override function readIndexBytes(v:IndexBuffer, startIndice:Int, indiceCount:Int, buf:haxe.io.Bytes, bufPos:Int) {
		throw "readIndexBytes";
	}

	override function readVertexBytes(v:VertexBuffer, startVertex:Int, vertexCount:Int, buf:haxe.io.Bytes, bufPos:Int) {
		throw "readVertexBytes";
	}

	override function capturePixels(tex:h3d.mat.Texture, face:Int, mipLevel:Int):hxd.Pixels {
		trace("TODO: capturePixels");
		return new hxd.Pixels(tex.width, tex.height, haxe.io.Bytes.alloc(tex.width * tex.height * 4), hxd.PixelFormat.RGBA);
	}

	override function uploadTextureBitmap(t:h3d.mat.Texture, bmp:hxd.BitmapData, mipLevel:Int, side:Int) {
		uploadTexturePixels(t, bmp.getPixels(), mipLevel, side);
	}

	override function uploadTexturePixels(t:h3d.mat.Texture, pixels:hxd.Pixels, mipLevel:Int, side:Int) {
		var data = t.t.lock(mipLevel);
		for( i in 0...data.length ) {
			data.set(i, pixels.bytes.get(i));
		}
		t.t.unlock();
	}

	override public function selectMaterial(pass:h3d.mat.Pass) {
		trace("TODO: selectMaterial");
	}

	override function getNativeShaderCode(shader:hxsl.RuntimeShader) {
		return null;
	}

	override function hasFeature(f:Feature) {
		return switch(f) {
		case StandardDerivatives, FloatTextures, AllocDepthBuffer, HardwareAccelerated, MultipleRenderTargets:
			true;
		case Queries:
			false;
		};
	}

	override function copyTexture(from:h3d.mat.Texture, to:h3d.mat.Texture):Bool {
		throw "copyTexture";
	}

	override function setRenderTarget(tex:Null<h3d.mat.Texture>, face = 0, mipLevel = 0) {
		trace("TODO: setRenderTarget");
	}

	override function setRenderTargets(textures:Array<h3d.mat.Texture>) {
		throw "setRenderTargets";
	}

	override function setRenderZone(x:Int, y:Int, width:Int, height:Int) {
		g.scissor(x, y, width, height);
	}

	var pipelines = new Map<Int, kha.graphics4.PipelineState>();

	override function selectShader(shader:hxsl.RuntimeShader) {
		var pipeline = pipelines.get(shader.id);
		if( pipeline == null ) {
			var glout = new hxsl.GlslOut();
			glout.glES = true;

			pipeline = new kha.graphics4.PipelineState();
			pipeline.vertexShader = kha.graphics4.VertexShader.fromSource(glout.run(shader.vertex.data));
			pipeline.fragmentShader = kha.graphics4.FragmentShader.fromSource(glout.run(shader.fragment.data));

			var structure = new kha.graphics4.VertexStructure();
			for( v in shader.vertex.data.vars )
				switch( v.kind ) {
				case Input:
					var data: kha.graphics4.VertexData;
					var size = switch( v.type ) {
					case TVec(n, _):
						data = switch ( n ) {
							case 2: data = kha.graphics4.VertexData.Float2;
							case 3: data = kha.graphics4.VertexData.Float3;
							case 4: data = kha.graphics4.VertexData.Float4;
							default: throw "assert " + v.type;
						}
					case TBytes(n): throw "assert " + v.type;
					case TFloat: data = kha.graphics4.VertexData.Float1;
					default: throw "assert " + v.type;
					}
					structure.add(v.name, data);
				default:
				}
			pipeline.inputLayout = [structure];
		}
		
		g.setPipeline(pipeline);
		
		return true;
	}

	override function getShaderInputNames():Array<String> {
		throw "getShaderInputNames";
	}

	override function selectBuffer(buffer:Buffer) {
		trace("TODO: selectBuffer");
	}

	override function selectMultiBuffers(bl:Buffer.BufferOffset) {
		throw "selectMultiBuffers";
	}

	override function uploadShaderBuffers(buffers:h3d.shader.Buffers, which:h3d.shader.Buffers.BufferKind) {
		trace("TODO: uploadShaderBuffers");
	}

	override function draw(ibuf:IndexBuffer, startIndex:Int, ntriangles:Int) {
		g.drawIndexedVertices(startIndex, Std.int(ntriangles / 3));
	}
}
