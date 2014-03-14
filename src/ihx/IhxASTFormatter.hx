private class IhxASTFormatter {

    public static macro function format(output : Expr) : Expr {
        
        var counter = 0;

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
