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

using Lambda;
using StringTools;
import sys.FileSystem;
import haxe.ds.StringMap;
import neko.Lib;
import ihx.program.Program;

enum CmdError
{
    IncompleteStatement;
    InvalidStatement(msg :String);
}

class CmdProcessor
{
    /** accumulating command fragments */
    private var sb :StringBuf;
  
    /** hash connecting interpreter commands to the functions that implement them */
    private var commands : StringMap<Dynamic>;

    /** runs haxe compiler and neko vm */
    private var nekoEval :NekoEval;

    /** controls temp program text */
    private var program :Program;

    /** name of new lib to include in build */
    private var cmdStr :String;

    public function new()
    {
        nekoEval = new NekoEval();
        program = new Program(nekoEval.tmpSuffix);
        sb = new StringBuf();
        commands = new StringMap<Void->String>();
        commands.set("dir", listVars);
        commands.set("addpath", addPath);
        commands.set("rmpath", rmPath);
        commands.set("path", listPath);
        commands.set("addlib", addLib);
        commands.set("rmlib", rmLib);
        commands.set("libs", listLibs);
        commands.set("clear", clearVars);
        commands.set("print", printProgram);
        commands.set("help", printHelp);
        commands.set("exit", function() std.Sys.exit(0));
        commands.set("quit", function() std.Sys.exit(0));
    }

    /**
       process a line of user input
    **/
    public function process(cmd :String) :String
    {
        if( cmd.endsWith("\\") )
        {
            sb.add(cmd.substr(0, cmd.length-1));
            throw IncompleteStatement;
        }

        sb.add(cmd);
        var ret;
        try
        {
            cmdStr = sb.toString();
            var cmd = firstWord(cmdStr);
            if( commands.exists(cmd) )                      // handle ihx commands
                ret = commands.get(cmd)();
            else                                            // execute a haxe statement
            {
                program.addStatement(cmdStr);
                ret = nekoEval.evaluate(program.getProgram());
                program.acceptLastCmd(true);
            }
        }
        catch (ex :String)
        {
            program.acceptLastCmd(false);
            sb = new StringBuf();
            throw InvalidStatement(ex);
        }

        sb = new StringBuf();
        return (ret==null) ? null : Std.string(ret);
    }

    private function firstWord(str :String) :String
    {
        var space = str.indexOf(" ");
        if( space == -1 )
            return str;
        return str.substr(0, space);
    }
                
    /**
       return a list of all user defined variables
    **/
    private function listVars() :String
    {
        var vars = program.getVars();
        if( vars.isEmpty() )
            return "vars: (none)";
        return wordWrap("vars: "+ vars.join(", "));
    }

    /**
       add a dir to the classpath in the compile command
    **/
    private function addPath() :String
    {
        var name = cmdStr.substr(cmdStr.indexOf(" ")+1);
        if( name==null || name.length==0 )
            return "syntax error";
        if( ! FileSystem.exists(name) )
            return "path not found: " + name;
        var path = FileSystem.fullPath(name);
        nekoEval.classpath.add(path);
        return "added: " + path;
    }

    /**
       remove a dir from the classpath in the compile command
    **/
    private function rmPath() :String
    {
        var name = cmdStr.substr(cmdStr.indexOf(" ")+1);
        if( name == null || name.length==0 )
            return "syntax error";
        if( ! FileSystem.exists(name) )
            return "path not found: " + name;
        var path = FileSystem.fullPath(name);
        var count = nekoEval.classpath.remove( function(ii) return ii==path );
        return if( count > 0 )
            "removed: " + path;
        else
            "path not found: " + path;
    }

    /**
       list the dirs in the classpath
    **/
    private function listPath() :String
    {
        if( nekoEval.classpath.length == 0 )
            return "path: (empty)";
        return "path: " + wordWrap(Lambda.list(nekoEval.classpath).join(", "));
    }

    /**
       add a haxelib library to the compile command
    **/
    private function addLib() :String
    {
        var name = cmdStr.split(" ")[1];
        if( name==null || name.length==0 )
            return "syntax error";
        nekoEval.libs.push(name);
        return "added: " + name;
    }

    /**
       remove a haxelib library from the compile command
    **/
    private function rmLib() :String
    {
        var name = cmdStr.split(" ")[1];
        if( name == null || name.length==0 )
            return "syntax error";
        var index = nekoEval.libs.indexOf(name);
        if (index >= 0) nekoEval.libs.splice(0, index);
        return "removed: " + name;
    }

    /**
       list haxelib libraries
    **/
    private function listLibs() :String
    {
        if( nekoEval.libs.length == 0 )
            return "libs: (none)";
        return "libs: " + wordWrap(Lambda.list(nekoEval.libs).join(", "));
    }

    /**
       reset workspace
    **/
    private function clearVars() :String
    {
        program = new Program(nekoEval.tmpSuffix);
        return "cleared";
    }

    /**
       print temp program
    **/
    private function printProgram() :String
    {
        return program.getProgram();
    }

    private function wordWrap(str :String) :String
    {
        if( str.length<=80 )
            return str;
    
        var words :Array<String> = str.split(" ");
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

    private function printHelp() :String
    {
        return "ihx shell commands:\n"
            + "  dir            list all currently defined variables\n"
            + "  addpath [name] add a dir to the classpath\n"
            + "  rmpath  [name] remove a dir from the classpath\n"
            + "  path           list the dirs in the classpath\n"
            + "  addlib [name]  add a haxelib library to the search path\n"
            + "  rmlib  [name]  remove a haxelib library from the search path\n"
            + "  libs           list haxelib libraries that have been added\n"
            + "  clear          delete all variables from the current session\n"
            + "  print          dump the temp neko program to the console\n"
            + "  help           print this message\n"
            + "  exit           close this session\n"
            + "  quit           close this session";
    }
}
