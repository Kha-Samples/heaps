package h3d.impl;

import h3d.impl.Driver;
import h3d.mat.Pass;
import kha.System;

class KhaDriver extends h3d.impl.Driver {
	public function new(antiAlias: Int) {

	}

	override function resize(width:Int, height:Int)  {
		
	}

	override function begin(frame:Int) {
		
	}

	override function isDisposed() {
		return false;
	}

	override function init(onCreate:Bool->Void, forceSoftware=false) {
		System.init({title: "heaps", width: 1024, height: 768}, function () {
			onCreate(false);
		});
	}

	override function clear(?color:h3d.Vector, ?depth:Float, ?stencil:Int) {
		
	}

	override function getDriverName(details:Bool) {
		return "Kha";
	}

	override function present() {
		
	}

	override function getDefaultDepthBuffer():h3d.mat.DepthBuffer {
		return null;
	}

	override function allocVertexes(m:ManagedBuffer):VertexBuffer {
		return null;
	}

	override function allocIndexes(count:Int) : IndexBuffer {
		return null;
	}

	override function allocDepthBuffer(b:h3d.mat.DepthBuffer):DepthBuffer {
		return null;
	}

	override function disposeDepthBuffer(b:h3d.mat.DepthBuffer) @:privateAccess {
		
	}

	override function captureRenderBuffer(pixels:hxd.Pixels) {
		
	}

	override function allocTexture(t:h3d.mat.Texture):Texture {
		return null;
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
		
	}

	override function uploadIndexBytes(i:IndexBuffer, startIndice:Int, indiceCount:Int, buf:haxe.io.Bytes, bufPos:Int) {
		
	}

	override function uploadVertexBuffer(v:VertexBuffer, startVertex:Int, vertexCount:Int, buf:hxd.FloatBuffer, bufPos:Int) {
		
	}

	override function uploadVertexBytes(v:VertexBuffer, startVertex:Int, vertexCount:Int, buf:haxe.io.Bytes, bufPos:Int) {
		
	}

	override function readIndexBytes(v:IndexBuffer, startIndice:Int, indiceCount:Int, buf:haxe.io.Bytes, bufPos:Int) {
		
	}

	override function readVertexBytes(v:VertexBuffer, startVertex:Int, vertexCount:Int, buf:haxe.io.Bytes, bufPos:Int) {
		
	}

	override function capturePixels(tex:h3d.mat.Texture, face:Int, mipLevel:Int) : hxd.Pixels {
		return null;
	}

	override function uploadTextureBitmap(t:h3d.mat.Texture, bmp:hxd.BitmapData, mipLevel:Int, side:Int) {
		
	}

	override function uploadTexturePixels(t:h3d.mat.Texture, pixels:hxd.Pixels, mipLevel:Int, side:Int) {
		
	}

	override public function selectMaterial(pass:h3d.mat.Pass) {
		
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

	override function copyTexture(from:h3d.mat.Texture, to:h3d.mat.Texture) {
		return false;
	}

	override function setRenderTarget(tex:Null<h3d.mat.Texture>, face = 0, mipLevel = 0) {
		
	}

	override function setRenderTargets(textures:Array<h3d.mat.Texture>) {
		
	}

	override function setRenderZone(x:Int, y:Int, width:Int, height:Int) {
		
	}

	override function selectShader(shader:hxsl.RuntimeShader) {
		return true;
	}

	override function getShaderInputNames():Array<String> {
		return [];
	}

	override function selectBuffer(buffer:Buffer) {
		
	}

	override function selectMultiBuffers(bl:Buffer.BufferOffset) {
		
	}

	override function uploadShaderBuffers(buffers:h3d.shader.Buffers, which:h3d.shader.Buffers.BufferKind) {
		
	}

	override function draw(ibuf:IndexBuffer, startIndex:Int, ntriangles:Int) {
		
	}
}
