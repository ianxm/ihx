/*
 Copyright (c) 2009, Ian Martins (ianxm@jhu.edu)

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

import neko.Lib;
import hscript.Expr;

enum CmdError
{
  IncompleteStatement;
  InvalidStatement;
  InvalidCommand(s:String);
}

class CmdProcessor
{
  /** accumulating command fragments **/
  private var sb:StringBuf;
  
  /** hash connecting interpreter commands to the functions that implement them **/
  private var commands : Hash<Dynamic>;

  /** parses commands **/
  private var parser : hscript.Parser;

  /** interprets commands  **/
  private var interp : hscript.Interp;

  /** list of crossplatform classes **/
  private var rootClasses : List<String>;

  /** list of non-class builtin variables **/
  private var builtins : List<String>;

  public function new()
  {
    sb = new StringBuf();

    commands = new Hash<Void->String>();
    commands.set("exit", callback(neko.Sys.exit,0));
    commands.set("quit", callback(neko.Sys.exit,0));
    commands.set("dir", listVars);
    commands.set("builtins", listBuiltins);
    commands.set("clear", clearVars);
    commands.set("help", printHelp);

    parser = new hscript.Parser();
    interp = new hscript.Interp();

    builtins = Lambda.list(['null', 'true', 'false', 'trace']); 
    rootClasses = Lambda.list(['Array', /*'ArrayAccess',*/ 'Class', 'Date', 'DateTools', 'Dynamic', 'EReg', /*'Enum',*/ 'Float', 'Hash', 'Int', 'IntHash',
			       'IntIter', /*'Iterable', 'Iterator',*/ 'Lambda', 'List', 'Math', /*'Null',*/ 'Reflect', 'Std', 'String', 'StringBuf', 'StringTools',
			       'Type', /*'Void',*/ 'Xml', 'haxe_BaseCode', 'haxe_FastCell', 'haxe_FastList', 'haxe_Firebug', 
			       'haxe_Http', 'haxe_Int32', 'haxe_Log', 'haxe_Md5', /*'haxe_PosInfos',*/ 'haxe_Public', 'haxe_Resource', 'haxe_Serializer', 
			       'haxe_Stack', /*'haxe_StackItem',*/ 'haxe_Template', 'haxe_Timer', /*'haxe_TimerQueue', 'haxe_TypeResolver',*/ 'haxe_Unserializer']);

    // make all root classes available to the interpreter
    for( cc in rootClasses )
      interp.variables.set(cc,Type.resolveClass(StringTools.replace(cc,"_",".")));

    for( cc in rootClasses )
      if( interp.variables.get(cc) == null )
	trace("fail: " + cc);

    var _:DateTools;
    var _:Xml;
    var _:haxe.BaseCode;
    var _:haxe.Firebug;
    var _:haxe.Http;
    var _:haxe.Md5;
    var _:haxe.PosInfos;
    var _:haxe.Public;
    var _:haxe.Resource;
    var _:haxe.Serializer;
    var _:haxe.Stack;
    var _:haxe.Template;
    var _:haxe.Timer;
    var _:haxe.Unserializer;
  }

  /**
	process a line of user input
   **/
  public function process(cmd) : String
  {
    sb.add(cmd);
    var ret;
    try
    {
      // handle ihx commands
      if( commands.exists(sb.toString()) )
	ret = commands.get(sb.toString())();

      // execute a haxe statement
      else
      {
	var cmdStr = preprocess(sb.toString());
	ret = executeCmd(parser.parseString(cmdStr), StringTools.endsWith(cmdStr, ";"));
      }
    }
    catch (ex:Error)
    {
      if( Type.enumConstructor(ex) == "EUnexpected" && Type.enumParameters(ex)[0] == "<eof>" 
	  || Type.enumConstructor(ex) == "EUnterminatedString" || Type.enumConstructor(ex) == "EUnterminatedComment")
      {
	sb.add("\n");
	throw IncompleteStatement;
      }

      sb = new StringBuf();
      if( Type.enumConstructor(ex) == "EInvalidChar" || Type.enumConstructor(ex) == "EUnexpected")
	throw InvalidStatement;

      throw InvalidCommand(Type.enumConstructor(ex) + ": " + Type.enumParameters(ex)[0]);
    }
    catch (ex2:String)
    {
      sb = new StringBuf();
      throw InvalidStatement;
    }

    sb = new StringBuf();
    return (ret==null) ? null : Std.string(ret);
  }


  /**
	a command was parsed successfully, pass it into the interpreter, display the output
   **/
  private function executeCmd(program, suppressOutput) : String
  {
    var ret = interp.execute(program);
    return ( ret!=null && !suppressOutput ) ? ret : null;
  }

  /**
	fix the dot syntax for standard class packages and regex pattern defs
   **/
  private function preprocess(cmdStr)
  {
    cmdStr = StringTools.replace(cmdStr, "haxe.", "haxe_");

    var reRe = new EReg("~/([^/]+)/([igms]*)", "g");
    cmdStr = reRe.replace(cmdStr, "new EReg(\"$1\",\"$2\")");

    return cmdStr;
  }

  /**
	return a list of all user defined variables
   **/
  private function listVars() : String
  {
    var builtins = builtins;
    var rootClasses = rootClasses;
    var notBuiltin = function(kk) { return !Lambda.has(builtins, kk) && !Lambda.has(rootClasses, kk); }
    var keys = findVars(notBuiltin);
    var keyArray = Lambda.array(keys);
    keyArray.sort(Reflect.compare);

    if( keyArray.length>0 )
    {
      var blob = wordWrap("Current variables: " + keyArray.join(", "));
      return blob;
    }
    else
      return "There are currently no variables";
  }

  /**
	return a list of all builtin classes
   **/
  private function listBuiltins() : String
  {
    var rootClasses = rootClasses;
    var isBuiltin = function(kk) { return Lambda.has(rootClasses, kk); }
    var keys = findVars(isBuiltin);
    keys = Lambda.map(keys, function(ii) { return StringTools.replace(ii,'_','.'); });
    var keyArray = Lambda.array(keys);
    keyArray.sort(Reflect.compare);
    
    if( keyArray.length>0 )
    {
      var blob = wordWrap("Builtins: " + keyArray.join(", "));
      return blob;
    }
    else
      return "There are no builtins.  Something must have gone wrong.";
  }

  /**
	clear all user defined variables
   **/
  private function clearVars() : String
  {
    var builtins = builtins;
    var rootClasses = rootClasses;
    var notBuiltin = function(kk) { return !Lambda.has(builtins, kk) && !Lambda.has(rootClasses, kk); }
    var keys = findVars(notBuiltin);

    for( kk in keys )
      interp.variables.remove(kk);
    return null;
  }

  private function findVars(check:String->Bool)
  {
    var keys = new List<String>();
    for( kk in interp.variables.keys() )
      keys.add(kk);

    var builtins = builtins;
    var rootClasses = rootClasses;
    return keys.filter(check);
  }

  private function wordWrap(str:String) : String
  {
    if( str.length<=80 )
      return str;
    
    var words : Array<String> = str.split(" ");
    var sb = new StringBuf();
    var ii = 0; // index of current word
    var oo = 1; // index of current output line
    while( ii<words.length )
    {
      while( ii<words.length && sb.toString().length+words[ii].length+1<80*oo )
      {
	if( ii!=0 )
	  sb.add(" ");
	sb.add(words[ii]);
	ii++;
      }
      if( ii<words.length )
      {
	sb.add("\n    ");
	oo++;
      }
    }

    return sb.toString();
  }

  private function printHelp() : String
  {
    return "IHx Shell Commands:\n"
      + "  dir      list all currently defined variables\n"
      + "  builtins list all builtin classes\n"
      + "  clear    delete all variables from the current session\n"
      + "  help     print this message\n"
      + "  exit     close this session\n"
      + "  quit     close this session";
  }
}