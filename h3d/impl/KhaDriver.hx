package h3d.impl;

import h3d.impl.Driver;
import h3d.mat.Pass;
import h3d.mat.Stencil;
import kha.Framebuffer;
import kha.Image;
import kha.graphics4.BlendingFactor;
import kha.graphics4.BlendingOperation;
import kha.graphics4.CompareMode;
import kha.graphics4.ConstantLocation;
import kha.graphics4.CullMode;
import kha.graphics4.FragmentShader;
import kha.graphics4.IndexBuffer;
import kha.graphics4.PipelineState;
import kha.graphics4.StencilAction;
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

private class Pipeline {
	public var pipeline:PipelineState;
	public var vertexParameters:ShaderParameters;
	public var fragmentParameters:ShaderParameters;

	public function new(program:Program, material:Material) {
		pipeline = new PipelineState();
		
		pipeline.vertexShader = program.vertexShader;
		pipeline.fragmentShader = program.fragmentShader;
		pipeline.inputLayout = program.structures;

		pipeline.cullMode = material.cullMode;
		pipeline.depthWrite = material.depthWrite;
		pipeline.depthMode = material.depthMode;
		pipeline.stencilMode = material.stencilMode;
		pipeline.stencilBothPass = material.stencilBothPass;
		pipeline.stencilDepthFail = material.stencilDepthFail;
		pipeline.stencilFail = material.stencilFail;
		pipeline.stencilReferenceValue = material.stencilReferenceValue;
		pipeline.stencilReadMask = material.stencilReadMask;
		pipeline.stencilWriteMask = material.stencilWriteMask;
		pipeline.blendSource = material.blendSource;
		pipeline.blendDestination = material.blendDestination;
		pipeline.blendOperation = material.blendOperation;
		pipeline.alphaBlendSource = material.alphaBlendSource;
		pipeline.alphaBlendDestination = material.alphaBlendDestination;
		pipeline.alphaBlendOperation = material.alphaBlendOperation;
		pipeline.colorWriteMaskRed = material.colorWriteMaskRed;
		pipeline.colorWriteMaskGreen = material.colorWriteMaskGreen;
		pipeline.colorWriteMaskBlue = material.colorWriteMaskBlue;
		pipeline.colorWriteMaskAlpha = material.colorWriteMaskAlpha;

		pipeline.compile();

		vertexParameters = new ShaderParameters(pipeline, program.vertexShaderData, "vertex");		
		fragmentParameters = new ShaderParameters(pipeline, program.fragmentShaderData, "fragment");
	}
}

private class Program {
	public var id:Int;
	public var vertexShader:VertexShader;
	public var fragmentShader:FragmentShader;
	public var structures:Array<VertexStructure>;
	public var vertexShaderData:hxsl.RuntimeShader.RuntimeShaderData;
	public var fragmentShaderData:hxsl.RuntimeShader.RuntimeShaderData;

	public function new(shader:hxsl.RuntimeShader) {
		this.id = shader.id;

		var glout = new hxsl.GlslOut();
		glout.glES = true;

		vertexShader = VertexShader.fromSource(glout.run(shader.vertex.data));
		fragmentShader = FragmentShader.fromSource(glout.run(shader.fragment.data));

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
		this.structures = [structure];
		
		vertexShaderData = shader.vertex;
		fragmentShaderData = shader.fragment;
	}
}

private class Material {
	public function new(id:Int) {
		this.id = id;

		inputLayout = null;
		vertexShader = null;
		fragmentShader = null;

		cullMode = CullMode.None;

		depthWrite = false;
		depthMode = CompareMode.Always;

		stencilMode = CompareMode.Always;
		stencilBothPass = StencilAction.Keep;
		stencilDepthFail = StencilAction.Keep;
		stencilFail = StencilAction.Keep;
		stencilReferenceValue = 0;
		stencilReadMask = 0xff;
		stencilWriteMask = 0xff;

		blendSource = BlendingFactor.BlendOne;
		blendDestination = BlendingFactor.BlendZero;
		blendOperation = BlendingOperation.Add;
		alphaBlendSource = BlendingFactor.BlendOne;
		alphaBlendDestination = BlendingFactor.BlendZero;
		alphaBlendOperation = BlendingOperation.Add;
		
		colorWriteMaskRed = true;
		colorWriteMaskGreen = true;
		colorWriteMaskBlue = true;
		colorWriteMaskAlpha = true;
	}

	public var id:Int;

	public var inputLayout:Array<VertexStructure>;
	public var vertexShader:VertexShader;
	public var fragmentShader:FragmentShader;

	public var cullMode:CullMode;

	public var depthWrite:Bool;
	public var depthMode:CompareMode;

	public var stencilMode:CompareMode;
	public var stencilBothPass:StencilAction;
	public var stencilDepthFail:StencilAction;
	public var stencilFail:StencilAction;
	public var stencilReferenceValue:Int;
	public var stencilReadMask:Int;
	public var stencilWriteMask:Int;

	public var blendSource:BlendingFactor;
	public var blendDestination:BlendingFactor;
	public var blendOperation:BlendingOperation;
	public var alphaBlendSource:BlendingFactor;
	public var alphaBlendDestination:BlendingFactor;
	public var alphaBlendOperation:BlendingOperation;
	
	public var colorWriteMaskRed:Bool;
	public var colorWriteMaskGreen:Bool;
	public var colorWriteMaskBlue:Bool;
	public var colorWriteMaskAlpha:Bool;
}

class VertexWrapper {
	public var count:Int;
	public var stride:Int;
	public var data:haxe.ds.Vector<kha.FastFloat>;
	public var usage:Usage;
	public var vertexBuffer:VertexBuffer;
	
	public function new(count:Int, stride:Int, usage:Usage) {
		this.count = count;
		this.stride = stride;
		data = new haxe.ds.Vector<kha.FastFloat>(count * stride);
		this.usage = usage;
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
		curPipeline = null;
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

	override function allocVertexes(m:ManagedBuffer):VertexWrapper {
		return new VertexWrapper(m.size, m.stride, m.flags.has(Dynamic) ? Usage.DynamicUsage : Usage.StaticUsage);
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
		if( t.flags.has(Target) )
			return Image.createRenderTarget(t.width, t.height);
		else
			return Image.create(t.width, t.height);
	}

	override function disposeTexture(t:h3d.mat.Texture) {
		
	}

	override function disposeVertexes(v:VertexWrapper) {
		
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

	override function uploadVertexBuffer(v:VertexWrapper, startVertex:Int, vertexCount:Int, buf:hxd.FloatBuffer, bufPos:Int) {
		if( v.vertexBuffer != null ) {
			var vertices = v.vertexBuffer.lock(startVertex, vertexCount);
			for( i in 0...vertexCount * v.stride ) {
				vertices.set(i, buf[bufPos + i]);
			}
			v.vertexBuffer.unlock();
		}
		else {
			for( i in 0...vertexCount * v.stride ) {
				v.data.set(i, buf[bufPos + i]);
			}
		}
	}

	override function uploadVertexBytes(v:VertexWrapper, startVertex:Int, vertexCount:Int, buf:haxe.io.Bytes, bufPos:Int) {
		throw "uploadVertexBytes";
	}

	override function readIndexBytes(v:IndexBuffer, startIndice:Int, indiceCount:Int, buf:haxe.io.Bytes, bufPos:Int) {
		throw "readIndexBytes";
	}

	override function readVertexBytes(v:VertexWrapper, startVertex:Int, vertexCount:Int, buf:haxe.io.Bytes, bufPos:Int) {
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
		for( y in 0...t.height ) {
			for( x in 0...t.width ) {
				data.set(y * t.width * 4 + x * 4 + 0, pixels.bytes.get((t.height - y) * t.width * 4 + x * 4 + 0));
				data.set(y * t.width * 4 + x * 4 + 1, pixels.bytes.get((t.height - y) * t.width * 4 + x * 4 + 1));
				data.set(y * t.width * 4 + x * 4 + 2, pixels.bytes.get((t.height - y) * t.width * 4 + x * 4 + 2));
				data.set(y * t.width * 4 + x * 4 + 3, pixels.bytes.get((t.height - y) * t.width * 4 + x * 4 + 3));
			}
		}
		t.t.unlock();
	}

	static var CULLFACES = [
		kha.graphics4.CullMode.None,
		kha.graphics4.CullMode.CounterClockwise,
		kha.graphics4.CullMode.Clockwise,
		kha.graphics4.CullMode.None,
	];

	static var BLEND = [
		kha.graphics4.BlendingFactor.BlendOne,
		kha.graphics4.BlendingFactor.BlendZero,
		kha.graphics4.BlendingFactor.SourceAlpha,
		kha.graphics4.BlendingFactor.SourceColor,
		kha.graphics4.BlendingFactor.DestinationAlpha,
		kha.graphics4.BlendingFactor.DestinationColor,
		kha.graphics4.BlendingFactor.InverseSourceAlpha,
		kha.graphics4.BlendingFactor.InverseSourceColor,
		kha.graphics4.BlendingFactor.InverseDestinationAlpha,
		kha.graphics4.BlendingFactor.InverseDestinationColor,
		kha.graphics4.BlendingFactor.Undefined, // CONSTANT_COLOR
		kha.graphics4.BlendingFactor.Undefined, // CONSTANT_ALPHA
		kha.graphics4.BlendingFactor.Undefined, // ONE_MINUS_CONSTANT_COLOR
		kha.graphics4.BlendingFactor.Undefined, // ONE_MINUS_CONSTANT_ALPHA
		kha.graphics4.BlendingFactor.Undefined, // SRC_ALPHA_SATURATE
	];

	static var OP = [
		kha.graphics4.BlendingOperation.Add,
		kha.graphics4.BlendingOperation.Subtract,
		kha.graphics4.BlendingOperation.ReverseSubtract,
	];

	static var COMPARE = [
		kha.graphics4.CompareMode.Always,
		kha.graphics4.CompareMode.Never,
		kha.graphics4.CompareMode.Equal,
		kha.graphics4.CompareMode.NotEqual,
		kha.graphics4.CompareMode.Greater,
		kha.graphics4.CompareMode.GreaterEqual,
		kha.graphics4.CompareMode.Less,
		kha.graphics4.CompareMode.LessEqual,
	];

	static var STENCIL_OP = [
		kha.graphics4.StencilAction.Keep,
		kha.graphics4.StencilAction.Zero,
		kha.graphics4.StencilAction.Replace,
		kha.graphics4.StencilAction.Increment,
		kha.graphics4.StencilAction.IncrementWrap,
		kha.graphics4.StencilAction.Decrement,
		kha.graphics4.StencilAction.DecrementWrap,
		kha.graphics4.StencilAction.Invert,
	];

	var materials = new Map<Int, Material>();
	var curMaterial: Material;
	
	override public function selectMaterial(pass:h3d.mat.Pass) {
		if (materials.exists(@:privateAccess pass.passId)) {
			curMaterial = materials.get(@:privateAccess pass.passId);
			return;
		}

		var material = new Material(@:privateAccess pass.passId);
		var bits = @:privateAccess pass.bits;
		if( bits & Pass.culling_mask != 0 ) {
			var cull = Pass.getCulling(bits);
			if( cull == 0 )
				material.cullMode = kha.graphics4.CullMode.None;
			else {
				material.cullMode = CULLFACES[cull];
			}
		}
		if( bits & (Pass.blendSrc_mask | Pass.blendDst_mask | Pass.blendAlphaSrc_mask | Pass.blendAlphaDst_mask) != 0 ) {
			var csrc = Pass.getBlendSrc(bits);
			var cdst = Pass.getBlendDst(bits);
			var asrc = Pass.getBlendAlphaSrc(bits);
			var adst = Pass.getBlendAlphaDst(bits);
			material.blendSource = BLEND[csrc];
			material.alphaBlendSource = BLEND[asrc];
			material.blendDestination = BLEND[cdst];
			material.alphaBlendDestination = BLEND[adst];
		}
		if( bits & (Pass.blendOp_mask | Pass.blendAlphaOp_mask) != 0 ) {
			var cop = Pass.getBlendOp(bits);
			var aop = Pass.getBlendAlphaOp(bits);
			material.blendOperation = OP[cop];
			material.alphaBlendOperation = OP[aop];
		}
		if( bits & Pass.depthWrite_mask != 0 )
			material.depthWrite = true;
		if( bits & Pass.depthTest_mask != 0 ) {
			var cmp = Pass.getDepthTest(bits);
			material.depthMode = COMPARE[cmp];
		}
		if( bits & Pass.colorMask_mask != 0 ) {
			var m = Pass.getColorMask(bits);
			material.colorWriteMaskRed   = m & 1 != 0;
			material.colorWriteMaskGreen = m & 2 != 0;
			material.colorWriteMaskBlue  = m & 4 != 0;
			material.colorWriteMaskAlpha = m & 8 != 0;
		}

		// TODO: two-sided stencil
		var s = pass.stencil;
		if( s != null ) {
			var opBits = @:privateAccess s.opBits;
			var frBits = @:privateAccess s.frontRefBits;
			var brBits = @:privateAccess s.backRefBits;

			if( opBits & (Stencil.frontSTfail_mask | Stencil.frontDPfail_mask | Stencil.frontDPpass_mask) != 0 ) {
				material.stencilFail = STENCIL_OP[Stencil.getFrontSTfail(opBits)];
				material.stencilDepthFail = STENCIL_OP[Stencil.getFrontDPfail(opBits)];
				material.stencilBothPass = STENCIL_OP[Stencil.getFrontDPpass(opBits)];
			}

			if( opBits & (Stencil.backSTfail_mask | Stencil.backDPfail_mask | Stencil.backDPpass_mask) != 0 ) {
				material.stencilFail = STENCIL_OP[Stencil.getBackSTfail(opBits)];
				material.stencilDepthFail = STENCIL_OP[Stencil.getBackDPfail(opBits)];
				material.stencilBothPass = STENCIL_OP[Stencil.getBackDPpass(opBits)];
			}

			if( (opBits & Stencil.frontTest_mask) | (frBits & (Stencil.frontRef_mask | Stencil.frontReadMask_mask)) != 0 ) {
				material.stencilMode = COMPARE[Stencil.getFrontTest(opBits)];
				material.stencilReferenceValue = Stencil.getFrontRef(frBits);
				material.stencilReadMask = Stencil.getFrontReadMask(frBits);
			}

			if( (opBits & Stencil.backTest_mask) | (brBits & (Stencil.backRef_mask | Stencil.backReadMask_mask)) != 0 ) {
				material.stencilMode = COMPARE[Stencil.getBackTest(opBits)];
				material.stencilReferenceValue = Stencil.getBackRef(brBits);
				material.stencilReadMask = Stencil.getBackReadMask(brBits);
			}

			if( frBits & Stencil.frontWriteMask_mask != 0 )
				material.stencilWriteMask = Stencil.getFrontWriteMask(frBits);

			if( brBits & Stencil.backWriteMask_mask != 0 )
				material.stencilWriteMask = Stencil.getBackWriteMask(brBits);
		}

		materials.set(material.id, material);
		curMaterial = material;
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
		curProgram = program;
		return true;
	}

	override function getShaderInputNames():Array<String> {
		throw "getShaderInputNames";
	}

	override function selectBuffer(buffer:Buffer) {
		if( !buffer.flags.has(RawFormat) ) {
			throw "!RawFormat";
		}

		var wrapper = @:privateAccess buffer.buffer.vbuf;
		if( wrapper.vertexBuffer == null ) {
			wrapper.vertexBuffer = new VertexBuffer(wrapper.count, curProgram.structures[0], wrapper.usage, false);
			var vertices = wrapper.vertexBuffer.lock();
			for( i in 0...wrapper.data.length ) {
				vertices.set(i, wrapper.data[i]);
			}
			wrapper.vertexBuffer.unlock();
		}
		g.setVertexBuffer(wrapper.vertexBuffer);
	}

	override function selectMultiBuffers(bl:Buffer.BufferOffset) {
		throw "selectMultiBuffers";
	}

	var pipelines = new Map<{material: Int, program: Int}, Pipeline>();
	var curPipeline: Pipeline;

	function selectPipeline() {
		var pipeline = pipelines.get({material: curMaterial.id, program: curProgram.id});
		if( pipeline == null ) {
			pipeline = new Pipeline(curProgram, curMaterial);
			pipelines.set({material: curMaterial.id, program: curProgram.id}, pipeline);
		}
		if( pipeline != curPipeline ) {
			g.setPipeline(pipeline.pipeline);
			curPipeline = pipeline;
		}
	}

	var lastVertexGlobals:h3d.shader.Buffers.ShaderBufferData;
	var lastVertexParams:h3d.shader.Buffers.ShaderBufferData;
	var lastVertexTextures:haxe.ds.Vector<h3d.mat.Texture>;
	var lastFragmentGlobals:h3d.shader.Buffers.ShaderBufferData;
	var lastFragmentParams:h3d.shader.Buffers.ShaderBufferData;
	var lastFragmentTextures:haxe.ds.Vector<h3d.mat.Texture>;

	override function uploadShaderBuffers(buffers:h3d.shader.Buffers, which:h3d.shader.Buffers.BufferKind) {
		switch( which ) {
		case Globals:
			lastVertexGlobals = buffers.vertex.globals;
			lastFragmentGlobals = buffers.fragment.globals;
		case Params:
			lastVertexParams = buffers.vertex.params;
			lastFragmentParams = buffers.fragment.params;
		case Textures:
			lastVertexTextures = buffers.vertex.tex;
			lastFragmentTextures = buffers.fragment.tex;
		}
	}

	static var TFILTERS = [
		kha.graphics4.TextureFilter.PointFilter,
		kha.graphics4.TextureFilter.LinearFilter,
	];

	static var TMIPS = [
		kha.graphics4.MipMapFilter.NoMipFilter,
		kha.graphics4.MipMapFilter.PointMipFilter,
		kha.graphics4.MipMapFilter.LinearMipFilter,
	];

	static var TWRAP = [
		kha.graphics4.TextureAddressing.Clamp,
		kha.graphics4.TextureAddressing.Repeat,
	];

	/*function uploadBuffer(parameters:ShaderParameters, buf:h3d.shader.Buffers.ShaderBuffers, which:h3d.shader.Buffers.BufferKind) {
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
						var mip = Type.enumIndex(texture.mipMap);
						var filter = Type.enumIndex(texture.filter);
						var wrap = Type.enumIndex(texture.wrap);
						g.setTextureParameters(parameters.textures[i], TWRAP[wrap], TWRAP[wrap], TFILTERS[filter], TFILTERS[filter], TMIPS[mip]);
					}					
				}
			}
		}
	}*/

	override function draw(ibuf:IndexBuffer, startIndex:Int, ntriangles:Int) {
		g.setIndexBuffer(ibuf);
		selectPipeline();

		if ( lastVertexGlobals != null ) {
			g.setFloats(curPipeline.vertexParameters.globals, lastVertexGlobals);
			lastVertexGlobals = null;
		}
		if ( lastFragmentGlobals != null ) {
			g.setFloats(curPipeline.fragmentParameters.globals, lastFragmentGlobals);
			lastFragmentGlobals = null;
		}
		if ( lastVertexParams != null ) {
			g.setFloats(curPipeline.vertexParameters.params, lastVertexParams);
			lastVertexParams = null;
		}
		if ( lastFragmentParams != null ) {
			g.setFloats(curPipeline.fragmentParameters.params, lastFragmentParams);
			lastFragmentParams = null;
		}
		if ( lastVertexTextures != null ) {
			for( i in 0...curPipeline.vertexParameters.textures.length + curPipeline.vertexParameters.cubeTextures.length ) {
				var texture = lastVertexTextures[i];
				var isCube = i >= curPipeline.vertexParameters.textures.length;
				if( texture != null && !texture.isDisposed() ) {
					if( isCube ) {
						throw "CubeTexture";
					}
					else {
						g.setTexture(curPipeline.vertexParameters.textures[i], texture.t);
						var mip = Type.enumIndex(texture.mipMap);
						var filter = Type.enumIndex(texture.filter);
						var wrap = Type.enumIndex(texture.wrap);
						g.setTextureParameters(curPipeline.vertexParameters.textures[i], TWRAP[wrap], TWRAP[wrap], TFILTERS[filter], TFILTERS[filter], TMIPS[mip]);
					}					
				}
			}
			lastVertexTextures = null;
		}
		if ( lastFragmentTextures != null ) {
			for( i in 0...curPipeline.fragmentParameters.textures.length + curPipeline.fragmentParameters.cubeTextures.length ) {
				var texture = lastFragmentTextures[i];
				var isCube = i >= curPipeline.fragmentParameters.textures.length;
				if( texture != null && !texture.isDisposed() ) {
					if( isCube ) {
						throw "CubeTexture";
					}
					else {
						g.setTexture(curPipeline.fragmentParameters.textures[i], texture.t);
						var mip = Type.enumIndex(texture.mipMap);
						var filter = Type.enumIndex(texture.filter);
						var wrap = Type.enumIndex(texture.wrap);
						g.setTextureParameters(curPipeline.fragmentParameters.textures[i], TWRAP[wrap], TWRAP[wrap], TFILTERS[filter], TFILTERS[filter], TMIPS[mip]);
					}					
				}
			}
			lastFragmentTextures = null;
		}		

		g.drawIndexedVertices(startIndex, Std.int(ntriangles * 3));
	}
}
