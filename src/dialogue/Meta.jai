#scope_file

Compiler :: #import "Compiler";
String :: #import "String";
#import "Basic";

Parsed :: struct {
	dialogue_function_declarations: [..] Source_Code_Range;
}
current: Parsed;

contain :: (notes: [] *Compiler.Code_Note, target: string) -> bool {
	for notes {
		if String.compare(it.text, target) == 0 return true;
	}
		
	return false;
}

#scope_export
Source_Code_Range :: struct {
    fully_pathed_filename:  string;
    line_number_start:      s64;
    line_number_end:        s64;
    character_number_start: s64;
    character_number_end:   s64;
}

Client_Code :: struct {
	dialoge_function_locations: [] Source_Code_Range;
}

headers: [..] *Compiler.Code_Procedure_Header;

handle_message :: (message: *Compiler.Message) {
	if message.kind != .TYPECHECKED return;

	typechecked := cast(*Compiler.Message_Typechecked) message;
	for typechecked.declarations handle_declaration(*it);
	for typechecked.procedure_headers handle_proc_header(*it);
	for typechecked.procedure_bodies  handle_proc_body(*it);
}

typechecked_sync :: () {
}

handle_declaration :: (typed_declaration: *Compiler.Typechecked(Compiler.Code_Declaration)) {
}

handle_proc_header :: (header: *Compiler.Typechecked(Compiler.Code_Procedure_Header)) {
	if !contain(header.expression.notes, "Dialogue") return;


	array_add(*headers, header.expression);

	// range: Source_Code_Range = ---;
	// range.fully_pathed_filename = header.expression.base.location.enclosing_load.fully_pathed_filename;
	// range.line_number_start = header.expression.base.location.l0;
	// range.line_number_end   = header.expression.base.location.l1;
	// range.character_number_start = header.expression.base.location.c0;
	// range.character_number_end   = header.expression.base.location.c1;
	// array_add(*current.dialogue_function_declarations, range);
}

handle_proc_body :: (typed_body: *Compiler.Typechecked(Compiler.Code_Procedure_Body)) {
	body := typed_body.expression;
	header := body.header;

	if !contain(header.notes, "Dialogue") return;

	range: Source_Code_Range = ---;
	range.fully_pathed_filename = body.block.base.location.enclosing_load.fully_pathed_filename;
	range.line_number_start = body.block.base.location.l0;
	range.line_number_end   = body.block.base.location.l1;
	range.character_number_start = body.block.base.location.c0;
	range.character_number_end   = body.block.base.location.c1;
	array_add(*current.dialogue_function_declarations, range);
}

serialize :: () -> string {
	builder: String_Builder;

	for current.dialogue_function_declarations {
		fmt := formatStruct(it, 0);
		fmt.long_form_separator_between_fields = ", ";
		print_to_builder(*builder, ".%\n", fmt);
		if it_index + 1 < current.dialogue_function_declarations.count append(*builder, ", ");
	}

	serialized_array := builder_to_string(*builder);

	print_to_builder(
		*builder,
#string DONE
__Meta :: #import "dialogue/Meta";
client_code : __Meta.Client_Code : .{
	dialoge_function_locations = .[
		%2
	],
};
DONE,	
		current.dialogue_function_declarations.count,
		serialized_array
	);

	str := builder_to_string(*builder);

	return str;
}
