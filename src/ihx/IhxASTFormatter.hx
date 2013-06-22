private class IhxASTFormatter {

    public static macro function __AST_Output_Formatter(output : Expr) : Expr {
        
        var counter = 0;

        function pathExtractor(buffer : StringBuf, counter : Int, type : Null<ComplexType>) {
            if (type == null) buffer.add('Unknown<$counter>');
            else {
                switch(type) {
                    case TPath(p): 
                        var parts = p.pack;
                        parts.push(p.name);
                        buffer.add(parts.join("."));
                    case _: buffer.add('Unknown<$counter>');
                }
            }
        }

        function extractFunction(f : Function) {
            var buffer = new StringBuf();
            if(f.args.length == 0) buffer.add('Void -> ');
            else {
                
                for(arg in f.args) {
                    pathExtractor(buffer, counter, arg.type);
                    buffer.add(' -> ');
                    counter++;
                }
            }

            if(f.ret == null) buffer.add('Void');
            else pathExtractor(buffer, counter, f.ret);

            return buffer.toString();
        }

        function getTypeString(expr : Expr) {
            var type:String = 
                try { 
                    var t = Context.typeof(expr);
                    var ct = Context.toComplexType(t);
                    var printer = new haxe.macro.Printer("  ");
                    printer.printComplexType(ct);
                }
                catch (err:Dynamic) {
                    switch (expr.expr) {
                        case EConst(CIdent("null")): "Null";
                        case _: 'Unknown<${counter++}>';
                    }
                }

            type = StringTools.replace(type, "StdTypes.", "");

            return type;
        }

        function printFn(f : Function) {
            var printer = new haxe.macro.Printer("  ");
            return printer.printFunction(f);
        }

        var type = getTypeString(output);
        return macro $v{type} + " : " + $output;
    }
}