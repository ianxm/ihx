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

    public function new( ?useDebug=false, ?paths:Set<String>, ?libs:Set<String>, ?defines:Set<String> )
    {
        nekoEval = new NekoEval();
        program = new Program(nekoEval.tmpSuffix);
        sb = new StringBuf();
        commands = new StringMap<Void->String>();
        commands.set("dir", listVars);
        commands.set("debug", debug);
        commands.set("addpath", addPath);
        commands.set("rmpath", rmPath);
        commands.set("path", listPath);
        commands.set("addlib", addLib);
        commands.set("rmlib", rmLib);
        commands.set("libs", listLibs);
        commands.set("adddefine", addDefine);
        commands.set("rmdefine", rmDefine);
        commands.set("defines", listDefines);
        commands.set("clear", clearVars);
        commands.set("print", printProgram);
        commands.set("help", printHelp);
        commands.set("exit", function() std.Sys.exit(0));
        commands.set("quit", function() std.Sys.exit(0));

        if( useDebug ) Sys.println(this.debug());
        if( paths!=null ) for( path in paths ) {
            Sys.println( doAddPath(path) );
        }
        if( libs!=null ) for( lib in libs ) {
            Sys.println( doAddLib(lib) );
        }
        if( defines!=null ) for( def in defines ) {
            Sys.println( doAddDefine(def) );
        }
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
       toggle debug compilation mode
    **/
    private function debug() :String
    {
        nekoEval.debug = !nekoEval.debug;
        return nekoEval.debug ? "debug mode on" : "debug mode off";
    }

    /**
       command to add a dir to the classpath in the compile command
    **/
    private function addPath() :String
    {
        var name = cmdStr.split(" ")[1];
        if( name==null || name.length==0 )
            return "syntax error";
        return doAddPath(name);
    }

    /**
       implementation method to check a dir exists and add it to the classpath in the compile command
    **/
    private function doAddPath( name:String ) :String
    {
        if( ! FileSystem.exists(name) )
            return "path not found: " + name;
        var path = FileSystem.fullPath(name);
        nekoEval.classpath.add(path);
        return "added path: " + path;
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
        var removed = nekoEval.classpath.remove( path );
        return if( removed )
            "removed path: " + path;
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
        return "path: " + wordWrap(nekoEval.classpath.join(", "));
    }

    /**
       command to add a haxelib library to the compile command
    **/
    private function addLib() :String
    {
        var name = cmdStr.split(" ")[1];
        if( name==null || name.length==0 )
            return "syntax error";
        return doAddLib(name);
    }

    /**
       implementation method to check the library exists and then add it to the compile command. 
    **/
    private function doAddLib( name:String ) :String
    {
        // Check that the library exists
        var haxelibName = name.split(":")[0];
        if( 0 != new sys.io.Process("haxelib", ["path",haxelibName]).exitCode() ) 
            return 'haxelib `$haxelibName` could not be loaded';
        nekoEval.libs.add(name);
        return "added lib: " + name;
    }

    /**
       remove a haxelib library from the compile command
    **/
    private function rmLib() :String
    {
        var name = cmdStr.split(" ")[1];
        if( name == null || name.length==0 )
            return "syntax error";
        nekoEval.libs.remove(name);
        return "removed lib: " + name;
    }

    /**
       list haxelib libraries
    **/
    private function listLibs() :String
    {
        if( nekoEval.libs.length == 0 )
            return "libs: (none)";
        return "libs: " + wordWrap(nekoEval.libs.join(", "));
    }


    /**
       command to add a -D define to the compile command
    **/
    private function addDefine() :String
    {
        var name = cmdStr.split(" ")[1];
        if( name==null || name.length==0 )
            return "syntax error";
        return doAddDefine(name);
    }


    /**
       implementation method to add a -D define to the compile command
    **/
    private function doAddDefine( name:String ) :String
    {
        nekoEval.defines.add(name);
        return "added define: " + name;
    }

    /**
       remove a -D define from the compile command
    **/
    private function rmDefine() :String
    {
        var name = cmdStr.split(" ")[1];
        if( name == null || name.length==0 )
            return "syntax error";
        nekoEval.defines.remove(name);
        return "removed define: " + name;
    }

    /**
       list -D defines
    **/
    private function listDefines() :String
    {
        if( nekoEval.defines.length == 0 )
            return "defines: (none)";
        return "defines: " + wordWrap(nekoEval.defines.join(", "));
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
        var sb = new StringBuf();
        sb.add("Compilation:\n");
        sb.add("  haxe " + nekoEval.getArgs().join(" ") + "\n");
        sb.add("Program:\n");

        var lines = program.getProgram(false).split("\n");
        var lineNumber = 0;
        for( l in lines ) 
        {
            sb.add(Std.string(++lineNumber).lpad(" ",4) + ": " + l + "\n");
        }
        return sb.toString();
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

    public static function printHelp() :String
    {
        return "ihx shell commands:\n"
            + "  dir              list all currently defined variables\n"
            + "  addpath [name]   add a dir to the classpath\n"
            + "  rmpath  [name]   remove a dir from the classpath\n"
            + "  path             list the dirs in the classpath\n"
            + "  addlib [name]    add a haxelib library to the search path\n"
            + "  rmlib  [name]    remove a haxelib library from the search path\n"
            + "  libs             list haxelib libraries that have been added\n"
            + "  adddefine [name] add a '-D' define to the compilation \n"
            + "  rmdefine  [name] remove a '-D' define from the compilation \n"
            + "  defines          list all the '-D' defines that have been added\n"
            + "  debug            toggle haxe -debug mode\n"
            + "  clear            delete all variables from the current session\n"
            + "  print            dump the temp neko program to the console\n"
            + "  help             print this message\n"
            + "  exit             close this session\n"
            + "  quit             close this session";
    }
}
