/*
  Copyright (c) 2009-2013, Ian Martins (ianxm@jhu.edu)

  This program is free software; you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation; either version 2 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with this program; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
*/

package ihx;

import ihx.CmdProcessor;

class TestBuiltins extends haxe.unit.TestCase
{
    public function testArray()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=[1,3,2]");
        assertEquals("[1,3,2]", ret);
        ret = proc.process("a.length");
        assertEquals("3", ret);
        ret = proc.process("a[2]");
        assertEquals("2", ret);
        ret = proc.process("a.sort(Reflect.compare);");
        ret = proc.process("a");
        assertEquals("[1,2,3]", ret);
    }

    public function testDate()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=new Date(2008, 1, 2, 3, 4, 5)");
        assertEquals("2008-02-02 03:04:05", ret);
        ret = proc.process("a.getDate()");
        assertEquals("2", ret);
        ret = proc.process("a.getSeconds()");
        assertEquals("5", ret);
        ret = proc.process("a.toString()");
        assertEquals("2008-02-02 03:04:05", ret);
    }

    public function testDateTools()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("DateTools.days(60)");
        assertEquals("5184000000", ret);
        ret = proc.process("var a=new Date(2008, 1, 2, 3, 4, 5)");
        assertEquals("2008-02-02 03:04:05", ret);
        ret = proc.process("DateTools.delta(a, 10000)");
        assertEquals("2008-02-02 03:04:15", ret);
    }

    public function testEReg()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var re=new EReg('word(.)','');");
        ret = proc.process("re.match('word7')");
        assertEquals("true", ret);
        ret = proc.process("re.matched(1)");
        assertEquals("7", ret);
    }

    public function testERegCaseInsensitive()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var re=new EReg('word(.)','i')");
        ret = proc.process("re.match('WORD7')");
        assertEquals("true", ret);
        ret = proc.process("re.matched(1)");
        assertEquals("7", ret);
    }

    public function testERegShortcut()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var re = ~/word(.)/");
        ret = proc.process("re.match('word7')");
        assertEquals("true", ret);
        ret = proc.process("re.matched(1)");
        assertEquals("7", ret);
    }

    public function testERegShortcutCaseInsensitive()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var re = ~/word(.)/i");
        ret = proc.process("re.match('WORD7')");
        assertEquals("true", ret);
        ret = proc.process("re.matched(1)");
        assertEquals("7", ret);
    }

    public function testHash()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=new Hash()");
        assertEquals("{}", ret);

        ret = proc.process("a.set('one', 1);");
        ret = proc.process("a");
        assertEquals("{one => 1}", ret);

        ret = proc.process("a.set('two', 2);");
        ret = proc.process("a");
        assertEquals("{one => 1, two => 2}", ret);

        ret = proc.process("a.exists('one')");
        assertEquals("true", ret);

        ret = proc.process("a.get('two')");
        assertEquals("2", ret);
    }

    public function testLambda()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=[1,3,5,6,3]");
        assertEquals("[1,3,5,6,3]", ret);
        ret = proc.process("var f=function(ii) { return ii*3; }");
        ret = proc.process("var b=Lambda.map(a,f)");
        ret = proc.process("b");
        assertEquals("{3, 9, 15, 18, 9}", ret);
        ret = proc.process("Lambda.has(a,1)");
        assertEquals("true", ret);
    }

    public function testList()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=new List()");
        assertEquals("{}", ret);

        ret = proc.process("a.add(1)");
        ret = proc.process("a");
        assertEquals("{1}", ret);

        ret = proc.process("a.add(4)");
        ret = proc.process("a");
        assertEquals("{1, 4}", ret);

        ret = proc.process("a.last()");
        assertEquals("4", ret);

        ret = proc.process("a.join(',')");
        assertEquals("1,4", ret);
    }

    public function testMath()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("Math.sin(1)");
        assertEquals("0.841470984807897", ret);
        ret = proc.process("Math.abs(-2.4)");
        assertEquals("2.4", ret);
        ret = proc.process("Math.floor(4.3)");
        assertEquals("4", ret);
        ret = proc.process("Math.isFinite(21)");
        assertEquals("true", ret);
    }

    public function testReflect()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a='a string'");
        assertEquals("a string", ret);
        ret = proc.process("Reflect.fields(a)");
        assertEquals("[__s,length]", ret);
        ret = proc.process("Reflect.isObject(a)");
        assertEquals("true", ret);
    }

    public function testStd()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a='a string'");
        assertEquals("a string", ret);
        ret = proc.process("Std.is(a,String)");
        assertEquals("true", ret);
        ret = proc.process("Std.parseInt('32')");
        assertEquals("32", ret);
    }

    public function testString()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a='a string'");
        assertEquals("a string", ret);
        ret = proc.process("a.charAt(2)");
        assertEquals("s", ret);
        ret = proc.process("a.split(' ')");
        assertEquals("[a,string]", ret);
        ret = proc.process("a.toUpperCase()");
        assertEquals("A STRING", ret);
    }

    public function testStringBuf()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=new StringBuf()");
        assertEquals("", ret);
        ret = proc.process("a.add('one')");
        ret = proc.process("a");
        assertEquals("one", ret);
        ret = proc.process("a.add(' two')");
        ret = proc.process("a");
        assertEquals("one two", ret); 
    }

    public function testStringTools()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=' a string '");
        assertEquals(" a string ", ret);
        ret = proc.process("a = StringTools.trim(a)");
        assertEquals("a string", ret);
        ret = proc.process("StringTools.isSpace(a,1)");
        assertEquals("true", ret);
        ret = proc.process("StringTools.startsWith(a, 'a')");
        assertEquals("true", ret);
    }

    public function testType()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a='a string'");
        assertEquals("a string", ret);
        ret = proc.process("Type.getClassName(Type.getClass(a))");
        assertEquals("String", ret);
        ret = proc.process("Type.typeof(12.3)");
        assertEquals("TFloat", ret);
    }

    public function testXml()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=Xml.parse('<one att=\"1\">word</one>')");
        assertEquals("<one att=\"1\">word</one>", ret);
        ret = proc.process("a.firstElement().firstChild()");
        assertEquals("word", ret);
        ret = proc.process("a.firstElement().get('att')");
        assertEquals("1", ret);
    }

    public function testHaxeInt32()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=haxe.Int32.ofInt(32)");
        assertEquals("32", ret);
        ret = proc.process("var b=haxe.Int32.ofInt(33)");
        assertEquals("33", ret);
        ret = proc.process("haxe.Int32.add(a,b)");
        assertEquals("65", ret);
    }

    public function testHaxeMd5()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=haxe.Md5.encode('a string')");
        assertEquals("3a315533c0f34762e0c45e3d4e9d525c", ret);
    }

    public function testHaxeSerializer()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=haxe.Serializer.run('a string')");
        assertEquals("y10:a%20string", ret);
    }

    public function testHaxeUnserializer()
    {
        var proc = new CmdProcessor();
        var ret = proc.process("var a=haxe.Unserializer.run('y10:a%20string')");
        assertEquals("a string", ret);
    }
}
