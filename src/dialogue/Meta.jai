#scope_file

Compiler :: #import "Compiler";
String :: #import "String";
#import "Basic";

Parsed :: struct {
	dialogue_function_declarations: [..] Source_Code_Range;
}
current: Parsed;

contain :: (notes: [] *Compiler.Code_Note, target: string) -> bool {
	for notes if String.compare(it.text, target) == 0 return true;
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


handle_message :: (message: *Compiler.Message) {
	if message.kind != .TYPECHECKED return;

	typechecked := cast(*Compiler.Message_Typechecked) message;
	for typechecked.procedure_headers handle_proc_header(*it);
	for typechecked.procedure_bodies  handle_proc_body(*it);
}

handle_proc_header :: (header: *Compiler.Typechecked(Compiler.Code_Procedure_Header)) {
	if !contain(header.expression.notes, "Dialogue") return;

	range: Source_Code_Range = ---;
	range.fully_pathed_filename = header.expression.base.location.enclosing_load.fully_pathed_filename;
	range.line_number_start = header.expression.base.location.l0;
	range.line_number_end   = header.expression.base.location.l1;
	range.character_number_start = header.expression.base.location.c0;
	range.character_number_end   = header.expression.base.location.c1;
	array_add(*current.dialogue_function_declarations, range);
}

handle_proc_body :: (body: *Compiler.Typechecked(Compiler.Code_Procedure_Body)) {

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
Source_Code_Range :: struct {
    fully_pathed_filename:  string;
    line_number_start:      s64;
    line_number_end:        s64;
    character_number_start: s64;
    character_number_end:   s64;
}

Client_Code :: struct {
	dialoge_function_locations: [%1] Source_Code_Range;
}

client_code : Client_Code : .{
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
