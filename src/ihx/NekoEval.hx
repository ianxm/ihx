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
import neko.Lib;
import haxe.io.Eof;
import sys.io.File;
import sys.io.Process;
import sys.FileSystem;
import ihx.program.Program;
import ihx.Set;

class NekoEval
{
    public var debug :Bool;
    public var classpath(default,null) :Set<String>;
    public var libs(default,null) :Set<String>;
    public var defines(default,null) :Set<String>;
    public var tmpSuffix(default,null) :String;
    private var errRegex :EReg;
    private var tmpDir :String;
    private var tmpHxFname :String;
    private var tmpHxPath :String;
    private var tmpNekoPath :String;

    public function new()
    {
        debug = false;
        classpath = [];
        libs = [];
        defines = [];
        errRegex = ~/.*IhxProgram_[0-9]*.hx:.* characters [0-9\-]+ : (.*)/;
        tmpDir = (Sys.systemName()=="Windows") ? Sys.getEnv("TEMP") : "/tmp";
        tmpSuffix = StringTools.lpad(Std.string(Std.random(9999)), "0", 4);
        tmpHxFname = "IhxProgram_"+ tmpSuffix +".hx";
        tmpHxPath = tmpDir +"/" + tmpHxFname;
        tmpNekoPath = tmpDir +"/ihx_out_"+ tmpSuffix +".n";
    }

    public function getArgs()
    {
        var args = ["-neko", tmpNekoPath, "-cp", tmpDir, "-main", tmpHxFname, "-cmd", "neko "+tmpNekoPath];
        
        if(debug) args.push('-debug');
        for(i in libs) 
        {
            args.push('-lib');
            args.push(i); 
        }
        for(i in classpath) 
        {
            args.push('-cp');
            args.push(i); 
        }
        for(i in defines) 
        {
            args.push('-D');
            args.push(i); 
        }
        return args;
    }

    public function evaluate(progStr)
    {
        var ret = "";
        File.saveContent(tmpHxPath, progStr);
        
        var proc = new Process("haxe", getArgs());
        var sb = new StringBuf();
		var isWindows = Sys.systemName() == "Windows";
        try {
            var pastOld = false;
            while( true )
            {
                var line = proc.stdout.readLine();
				if (isWindows && line.charCodeAt(line.length-1) == 13) line = line.substring(0, line.length - 1);
                if( !pastOld && line==Program.separator )
                {
                    pastOld = true;
                    continue;
                }
                if( pastOld )
                    sb.add(line+"\n");
                ret = sb.toString().substr(0, sb.toString().length - 1);
            }
        }
        catch ( eof :Eof ) { }
        try {
            while( true )
            {
                var line = proc.stderr.readLine();
				if (isWindows && line.charCodeAt(line.length-1) == 13) line = line.substring(0, line.length - 1);
                if( errRegex.match(line) )
                    sb.add("error: "+ errRegex.matched(1) +"\n");
                else
                    sb.add("error: "+ line +"\n");
                ret = sb.toString();
            }
        }
        catch ( eof :Eof ) { }

        if( FileSystem.exists(tmpHxPath) )
            FileSystem.deleteFile(tmpHxPath);
        if( FileSystem.exists(tmpNekoPath) )
            FileSystem.deleteFile(tmpNekoPath);

        if( proc.exitCode()!=0 )
            throw ret;
        return ret;
   }
}
