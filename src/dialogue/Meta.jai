#scope_file

Compiler :: #import "Compiler";
Preload :: #import "Preload";
Parser :: #import "dialogue/Parser";
String :: #import "String";
#import "Basic";

#no_reset current: Parser.Parsed;

contain :: (notes: [] *Code_Note, target: string) -> bool {
	for notes if String.compare(it.name, target) == 0 return true;
	return false;
}

#scope_export

handle_message :: (message: Compiler.Message) {
	if message.kind != .TYPECHECKED return;

	typechecked := cast(*Compiler.Message_Typechecked) message;
	for typechecked.procedure_headers handle_proc_header(*it);
	for typechecked.procedure_bodies  handle_proc_body(*it);
}

handle_proc_header :: (header: *Compiler.Typechecked(Compiler.Code_Procedure_Header)) {
	if !contain(header.expression.notes, "Dialogue") return;

	range: Preload.Source_Code_Range = ---;
	range.fully_pathed_filename = header.expression.base.localtion.enclosing_load.fully_pathed_filename;
	range.line_number_start = header.expression.base.location.l0;
	range.line_number_end   = header.expression.base.location.l1;
	range.character_number_start = header.expression.base.location.c0;
	range.character_number_end   = header.expression.base.location.c1;
	array_add(*current.dialogue_function_declarations, range);
}

handle_proc_body :: (body: *Compiler.Typechecked(Compiler.Code_Procedure_Body)) {

}

get_parsed :: ()