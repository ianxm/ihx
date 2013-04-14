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
                    sb.add(line +"\n");
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

        if( proc.exitCode()!=0 )
            throw sb.toString();

        return sb.toString();
    }
}
