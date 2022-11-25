#scope_file

ImGui :: #import "my_imgui";
State :: #import "editor/back/State";
Meta :: #import "dialogue/Meta";
#import "Basic";

#scope_export

main_window :: (state: *State.Editor, client_code: *Meta.Client_Code) {
	ImGui.Begin("Main");
	defer ImGui.End();

	if ImGui.Button("View source") {
		state.view_dialogue_usage = true;
	}


	button();

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


button :: () {

} @Dialogue

