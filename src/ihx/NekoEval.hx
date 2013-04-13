package ihx;

import neko.Lib;
import haxe.io.Eof;
import sys.io.File;
import sys.io.Process;

class NekoEval
{
    private static var errRegex = ~/.*Program.hx:.* characters [0-9\-]+ : (.*)/;

    public static function evaluate(progStr)
    {
        File.saveContent("tmp/Program.hx", progStr);
        var proc = new Process("haxe", ["-neko", "tmp/out.n", "-cp", "tmp", "-main", "Program.hx", "-cmd", "neko tmp/out.n"]);
        var sb = new StringBuf();
        try {
            while( true )
                sb.add(proc.stdout.readLine() +"\n");
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

        if( proc.exitCode()!=0 )
            throw sb.toString();

        return sb.toString();
    }
}
