package h3d.impl;

import h3d.impl.Driver;
import h3d.mat.Pass;
import kha.Framebuffer;
import kha.Image;
import kha.graphics4.ConstantLocation;
import kha.graphics4.FragmentShader;
import kha.graphics4.IndexBuffer;
import kha.graphics4.PipelineState;
import kha.graphics4.TextureUnit;
import kha.graphics4.Usage;
import kha.graphics4.VertexBuffer;
import kha.graphics4.VertexData;
import kha.graphics4.VertexShader;
import kha.graphics4.VertexStructure;

private class ShaderParameters {
	public var globals:ConstantLocation;
	public var params:ConstantLocation;
	public var textures:Array<TextureUnit> = [];
	public var cubeTextures:Array<TextureUnit> = [];

	public function new(pipeline:PipelineState, data:hxsl.RuntimeShader.RuntimeShaderData, prefix:String) {
		globals = pipeline.getConstantLocation(prefix + "Globals");
		params = pipeline.getConstantLocation(prefix + "Params");
		textures = [for( i in 0...data.textures2DCount ) pipeline.getTextureUnit(prefix + "Textures[" + i + "]")];
		cubeTextures = [for( i in 0...data.texturesCubeCount ) pipeline.getTextureUnit(prefix + "TexturesCube[" + i + "]")];
	}
}

private class Program {
	public var pipeline:PipelineState;

	public var vertexParameters:ShaderParameters;
	public var fragmentParameters:ShaderParameters;

	public function new(shader:hxsl.RuntimeShader) {
		var glout = new hxsl.GlslOut();
		glout.glES = true;

		pipeline = new PipelineState();
		pipeline.vertexShader = VertexShader.fromSource(glout.run(shader.vertex.data));
		pipeline.fragmentShader = FragmentShader.fromSource(glout.run(shader.fragment.data));

		// trace("Vertex shader:\n" + glout.run(shader.vertex.data));
		// trace("Fragment shader:\n" + glout.run(shader.fragment.data));

		var structure = new VertexStructure();
		for( v in shader.vertex.data.vars )
			switch( v.kind ) {
			case Input:
				var data: VertexData;
				switch( v.type ) {
				case TVec(n, _):
					data = switch ( n ) {
						case 2: data = VertexData.Float2;
						case 3: data = VertexData.Float3;
						case 4: data = VertexData.Float4;
						default: throw "assert " + v.type;
					}
				case TBytes(n): throw "assert " + v.type;
				case TFloat: data = VertexData.Float1;
				default: throw "assert " + v.type;
				}
				structure.add(v.name, data);
			default:
			}
		pipeline.inputLayout = [structure];
		pipeline.compile();

		vertexParameters = new ShaderParameters(pipeline, shader.vertex, "vertex");		
		fragmentParameters = new ShaderParameters(pipeline, shader.fragment, "fragment");
	}
}

class KhaDriver extends h3d.impl.Driver {
	public static var framebuffer: Framebuffer;
	public static var g: kha.graphics4.Graphics;
	var programs = new Map<Int, Program>();
	var curProgram: Program = null;

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

	static var firstgetDefaultDepthBuffer = true;
	override function getDefaultDepthBuffer():h3d.mat.DepthBuffer {
		if ( firstgetDefaultDepthBuffer ) {
			trace("TODO: getDefaultDepthBuffer");
			firstgetDefaultDepthBuffer = false;
		}
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
		if (t.flags.has(Target))
			return Image.createRenderTarget(t.width, t.height);
		else
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
		for( i in 0...pixels.bytes.length ) {
			data.set(i, pixels.bytes.get(i));
		}
		t.t.unlock();
	}

	static var firstSelectMaterial = true;
	override public function selectMaterial(pass:h3d.mat.Pass) {
		if ( firstSelectMaterial ) {
			trace("TODO: selectMaterial");
			firstSelectMaterial = false;
		}
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
		if( tex == null ) {
			g.end();
			g = framebuffer.g4;
			g.begin();
		}
		else {
			g.end();
			g = tex.t.g4;
			g.begin();
		}
	}

	override function setRenderTargets(textures:Array<h3d.mat.Texture>) {
		throw "setRenderTargets";
	}

	override function setRenderZone(x:Int, y:Int, width:Int, height:Int) {
		if( x == 0 && y == 0 && width < 0 && height < 0 )
			g.disableScissor()
		else
			g.scissor(x, y, width, height);
	}

	override function selectShader(shader:hxsl.RuntimeShader) {
		var program = programs.get(shader.id);
		if( program == null ) {
			program = new Program(shader);
			programs.set(shader.id, program);
		}
		g.setPipeline(program.pipeline);
		curProgram = program;
		return true;
	}

	override function getShaderInputNames():Array<String> {
		throw "getShaderInputNames";
	}

	override function selectBuffer(buffer:Buffer) {
		g.setVertexBuffer(@:privateAccess buffer.buffer.vbuf);
	}

	override function selectMultiBuffers(bl:Buffer.BufferOffset) {
		throw "selectMultiBuffers";
	}

	override function uploadShaderBuffers(buffers:h3d.shader.Buffers, which:h3d.shader.Buffers.BufferKind) {
		uploadBuffer(curProgram.vertexParameters, buffers.vertex, which);
		uploadBuffer(curProgram.fragmentParameters, buffers.fragment, which);
	}

	function uploadBuffer(parameters:ShaderParameters, buf:h3d.shader.Buffers.ShaderBuffers, which:h3d.shader.Buffers.BufferKind) {
		switch( which ) {
		case Globals:
			g.setFloats(parameters.globals, buf.globals);
		case Params:
			g.setFloats(parameters.params, buf.params);
		case Textures:
			for( i in 0...parameters.textures.length + parameters.cubeTextures.length ) {
				var texture = buf.tex[i];
				var isCube = i >= parameters.textures.length;
				if( texture != null && !texture.isDisposed() ) {
					if( isCube ) {
						throw "CubeTexture";
					}
					else {
						g.setTexture(parameters.textures[i], texture.t);
					}
				}
			}
		}
	}

	override function draw(ibuf:IndexBuffer, startIndex:Int, ntriangles:Int) {
		g.setIndexBuffer(ibuf);
		g.drawIndexedVertices(startIndex, Std.int(ntriangles * 3));
	}
}
