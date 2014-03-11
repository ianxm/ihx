/* ************************************************************************ */
/*                                                                          */
/*  Copyright (c) 2009-2013 Ian Martins (ianxm@jhu.edu)                     */
/*                                                                          */
/* This library is free software; you can redistribute it and/or            */
/* modify it under the terms of the GNU Lesser General Public               */
/* License as published by the Free Software Foundation; either             */
/* version 3.0 of the License, or (at your option) any later version.       */
/*                                                                          */
/* This library is distributed in the hope that it will be useful,          */
/* but WITHOUT ANY WARRANTY; without even the implied warranty of           */
/* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU        */
/* Lesser General Public License or the LICENSE file for more details.      */
/*                                                                          */
/* ************************************************************************ */

package ihx;

import ihx.CmdProcessor;

class TestBuiltins extends haxe.unit.TestCase
{
    public function testImport()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("import haxe.crypto.Md5");
        ret = proc.process("Md5.encode('hello')");
        assertEquals("String : 5d41402abc4b2a76b9719d911017c592", ret);
    }

    public function testWildcardImport()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("import haxe.ds.*");
        ret = proc.process("new IntMap<String>()");
        assertEquals("haxe.ds.IntMap<String> : {}", ret);
        ret = proc.process("new StringMap<String>()");
        assertEquals("haxe.ds.StringMap<String> : {}", ret);
    }

    public function testImportStatic()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("import haxe.crypto.Md5.*");
        ret = proc.process("encode('hello')");
        assertEquals("String : 5d41402abc4b2a76b9719d911017c592", ret);
    }

    public function testArray()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=[1,3,2]");
        assertEquals("Array<Int> : [1,3,2]", ret);
        ret = proc.process("a.length");
        assertEquals("Int : 3", ret);
        ret = proc.process("a[2]");
        assertEquals("Int : 2", ret);
        ret = proc.process("a.sort(Reflect.compare);");
        ret = proc.process("a");
        assertEquals("Array<Int> : [1,2,3]", ret);
    }

    public function testArrayComprehension()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=[ for(i in 0...10) if (i%2 == 0) i ]");
        assertEquals("Array<Int> : [0,2,4,6,8]", ret);
        ret = proc.process("a.length");
        assertEquals("Int : 5", ret);
    }

    public function testDate()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=new Date(2008, 1, 2, 3, 4, 5)");
        assertEquals("Date : 2008-02-02 03:04:05", ret);
        ret = proc.process("a.getDate()");
        assertEquals("Int : 2", ret);
        ret = proc.process("a.getSeconds()");
        assertEquals("Int : 5", ret);
        ret = proc.process("a.toString()");
        assertEquals("String : 2008-02-02 03:04:05", ret);
    }

    public function testDateTools()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("DateTools.days(60)");
        assertEquals("Float : 5184000000", ret);
        ret = proc.process("var a=new Date(2008, 1, 2, 3, 4, 5)");
        assertEquals("Date : 2008-02-02 03:04:05", ret);
        ret = proc.process("DateTools.delta(a, 10000)");
        assertEquals("Date : 2008-02-02 03:04:15", ret);
    }

    public function testEReg()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var re=new EReg('word(.)','');");
        ret = proc.process("re.match('word7')");
        assertEquals("Bool : true", ret);
        ret = proc.process("re.matched(1)");
        assertEquals("String : 7", ret);
    }

    public function testERegCaseInsensitive()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var re=new EReg('word(.)','i')");
        ret = proc.process("re.match('WORD7')");
        assertEquals("Bool : true", ret);
        ret = proc.process("re.matched(1)");
        assertEquals("String : 7", ret);
    }

    public function testERegShortcut()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var re = ~/word(.)/");
        ret = proc.process("re.match('word7')");
        assertEquals("Bool : true", ret);
        ret = proc.process("re.matched(1)");
        assertEquals("String : 7", ret);
    }

    public function testERegShortcutCaseInsensitive()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var re = ~/word(.)/i");
        ret = proc.process("re.match('WORD7')");
        assertEquals("Bool : true", ret);
        ret = proc.process("re.matched(1)");
        assertEquals("String : 7", ret);
    }

    public function testMap()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=new Map<String,Int>()");
        assertEquals("Map<String, Int> : {}", ret);

        ret = proc.process("a.set('one', 1);");
        ret = proc.process("a");
        assertEquals("Map<String, Int> : {one => 1}", ret);

        ret = proc.process("a.set('two', 2);");
        ret = proc.process("a");
        assertEquals("Map<String, Int> : {one => 1, two => 2}", ret);

        ret = proc.process("a.exists('one')");
        assertEquals("Bool : true",ret);

        ret = proc.process("a.get('two')");
        assertEquals("Null<Int> : 2", ret);
    }

    public function testMapSyntaxSugar()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=[ 'one'=>1, 'two'=>2 ]");
        assertEquals("Map<String, Int> : {one => 1, two => 2}", ret);

        ret = proc.process("a['two']");
        assertEquals("Null<Int> : 2", ret);
    }

    public function testStringMap()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("import haxe.ds.StringMap");
        ret = proc.process("var a=new StringMap()");
        assertEquals("Unknown<0> : {}", ret);

        ret = proc.process("a.set('one', 1);");
        ret = proc.process("a");
        assertEquals("haxe.ds.StringMap<Int> : {one => 1}", ret);

        ret = proc.process("a.set('two', 2);");
        ret = proc.process("a");
        assertEquals("haxe.ds.StringMap<Int> : {one => 1, two => 2}", ret);

        ret = proc.process("a.exists('one')");
        assertEquals("Bool : true", ret);

        ret = proc.process("a.get('two')");
        assertEquals("Null<Int> : 2", ret);
    }

    public function testLambda()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=[1,3,5,6,3]");
        assertEquals("Array<Int> : [1,3,5,6,3]", ret);
        ret = proc.process("var f=function(ii) { return ii*3; }");
        ret = proc.process("var b=Lambda.map(a,f)");
        ret = proc.process("b");
        assertEquals("List<Int> : {3, 9, 15, 18, 9}", ret);
        ret = proc.process("Lambda.has(a,1)");
        assertEquals("Bool : true", ret);
    }

    public function testList()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=new List()");
        assertEquals("Unknown<0> : {}", ret);

        ret = proc.process("a.add(1)");
        ret = proc.process("a");
        assertEquals("List<Int> : {1}", ret);

        ret = proc.process("a.add(4)");
        ret = proc.process("a");
        assertEquals("List<Int> : {1, 4}", ret);

        ret = proc.process("a.last()");
        assertEquals("Null<Int> : 4", ret);

        ret = proc.process("a.join(',')");
        assertEquals("String : 1,4", ret);
    }

    public function testMath()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("Math.sin(1)");
        assertEquals("Float : 0.841470984807897", ret);
        ret = proc.process("Math.abs(-2.4)");
        assertEquals("Float : 2.4", ret);
        ret = proc.process("Math.floor(4.3)");
        assertEquals("Int : 4", ret);
        ret = proc.process("Math.isFinite(21)");
        assertEquals("Bool : true", ret);
    }

    public function testReflect()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a='a string'");
        assertEquals("String : a string", ret);
        ret = proc.process("Reflect.fields(a)");
        assertEquals("Array<String> : [__s,length]", ret);
        ret = proc.process("Reflect.isObject(a)");
        assertEquals("Bool : true", ret);
    }

    public function testStd()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a='a string'");
        assertEquals("String : a string", ret);
        ret = proc.process("Std.is(a,String)");
        assertEquals("Bool : true", ret);
        ret = proc.process("Std.parseInt('32')");
        assertEquals("Null<Int> : 32", ret);
    }

    public function testString()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a='a string'");
        assertEquals("String : a string", ret);
        ret = proc.process("a.charAt(2)");
        assertEquals("String : s", ret);
        ret = proc.process("a.split(' ')");
        assertEquals("Array<String> : [a,string]", ret);
        ret = proc.process("a.toUpperCase()");
        assertEquals("String : A STRING", ret);
    }

    public function testStringBuf()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=new StringBuf()");
        assertEquals("StringBuf : ", ret);
        ret = proc.process("a.add('one')");
        ret = proc.process("a");
        assertEquals("StringBuf : one", ret);
        ret = proc.process("a.add(' two')");
        ret = proc.process("a");
        assertEquals("StringBuf : one two", ret); 
    }

    public function testStringTools()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=' a string '");
        assertEquals("String :  a string ", ret);
        ret = proc.process("a = StringTools.trim(a)");
        assertEquals("String : a string", ret);
        ret = proc.process("StringTools.isSpace(a,1)");
        assertEquals("Bool : true", ret);
        ret = proc.process("StringTools.startsWith(a, 'a')");
        assertEquals("Bool : true", ret);
    }

    public function testType()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a='a string'");
        assertEquals("String : a string", ret);
        ret = proc.process("Type.getClassName(Type.getClass(a))");
        assertEquals("String : String", ret);
        ret = proc.process("Type.typeof(12.3)");
        assertEquals("Type.ValueType : TFloat", ret);
    }

    public function testXml()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=Xml.parse('<one att=\"1\">word</one>')");
        assertEquals("Xml : <one att=\"1\">word</one>", ret);
        ret = proc.process("a.firstElement().firstChild()");
        assertEquals("Xml : word", ret);
        ret = proc.process("a.firstElement().get('att')");
        assertEquals("String : 1", ret);
    }

    public function testHaxeMd5()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=haxe.crypto.Md5.encode('a string')");
        assertEquals("String : 3a315533c0f34762e0c45e3d4e9d525c", ret);
    }

    public function testHaxeSerializer()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=haxe.Serializer.run('a string')");
        assertEquals("String : y10:a%20string", ret);
    }

    public function testHaxeUnserializer()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=haxe.Unserializer.run('y10:a%20string')");
        assertEquals("Unknown<0> : a string", ret);
    }
}
