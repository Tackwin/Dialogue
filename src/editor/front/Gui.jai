#scope_file

// #module_parameters()($Client_GUI: string);

ImGui :: #import "my_imgui";
State :: #import "editor/back/State";
Meta :: #import "dialogue/Meta";
#import "Basic";
// #insert #run tprint("_Client_GUI :: #import \"%\";", Client_GUI);

// #run {
// 	print("% %\n", _Client_GUI, type_of(_Client_GUI));
// }

// #run {
// 	compiler_create_workspace();

// 	compiler_begin_intercept()
// 	add_build_string(tprint("#import \"%\"\n", Client_GUI));

// 	while true {
// 		...
// 	}

// 	compiler_end_intercept();
// }

// #run print("%\n", type_of(#import "Basic"))

#scope_export

components : [..] #type ();

coucou1_ := false;
coucou2_ := false;

#placeholder Client_Code;
#placeholder client_code;

main_window :: (state: *State.Editor, $client_code: $T) {
	ImGui.Begin("Main");
	defer ImGui.End();

	if ImGui.Button("View source") {
		state.view_dialogue_usage = true;
	}

	ImGui.Separator();

	for client_code.dialoge_function_locations {
		ImGui.Indent();
		defer ImGui.Unindent();
		if ImGui.Button("Add button in function") {
			
		}

		ImGui.Text(it.fully_pathed_filename.data);
		ImGui.Text(tprint("From L% to L%", it.line_number_start, it.line_number_end).data);
	}

} @Dialogue

coucou :: () {
	if ImGui.Button("coucou !") print("Coucoued\n");
} @Dialogue

coucou2 :: () {
	if ImGui.Button("coucou back !") print("Coucoued backed\n");
} @Dialogue





coucou3 :: () {
	if ImGui.Button("coucou back !") print("Coucoued backed\n");
} @Dialogue

