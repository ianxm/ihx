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
import neko.Lib;
import haxe.io.Eof;
import sys.io.File;
import sys.io.Process;
import sys.FileSystem;
import ihx.program.Program;

class NekoEval
{
    public static var libs = new Set<String>();

    private static var errRegex = ~/.*Program.hx:.* characters [0-9\-]+ : (.*)/;
    private static var tmpDir = (Sys.systemName()=="Windows") ? Sys.getEnv("TEMP") : "/tmp";

    public static function evaluate(progStr)
    {
        File.saveContent(tmpDir+"/IhxProgram.hx", progStr);
        var args = ["-neko", tmpDir+"/ihx_out.n", "-cp", tmpDir, "-main", "IhxProgram", "-cmd", "neko "+tmpDir+"/ihx_out.n"];
        libs.iter( function(ii){ args.push("-lib"); args.push(ii); });
        var proc = new Process("haxe", args);
        var sb = new StringBuf();
        try {
            var pastOld = false;
            while( true )
            {
                var line = proc.stdout.readLine();
                if( !pastOld && line==Program.separator )
                {
                    pastOld = true;
                    continue;
                }
                if( pastOld )
                    sb.add(line+"\n");
            }
        }
        catch ( eof :Eof ) { }
        try {
            while( true )
            {
                var line = proc.stderr.readLine();
                if( errRegex.match(line) )
                    sb.add("error: "+ errRegex.matched(1) +"\n");
                else
                    sb.add("error: "+ line +"\n");
            }
        }
        catch ( eof :Eof ) { }

        if( FileSystem.exists(tmpDir+"/IhxProgram.hx") )
            FileSystem.deleteFile(tmpDir+"/IhxProgram.hx");
        if( FileSystem.exists(tmpDir+"/ihx_out.n") )
            FileSystem.deleteFile(tmpDir+"/ihx_out.n");

        var ret = sb.toString().substr(0, sb.toString().length-1);
        if( proc.exitCode()!=0 )
            throw ret;
        return ret;
   }
}
