#scope_file

ImGui :: #import "my_imgui";
State :: #import "editor/back/State";
Meta :: #import "Meta";

#scope_export


#placeholder parsed;

Dialogue(main_window :: (state: *State.Editor) {
	ImGui.Begin("Main");
	defer ImGui.End();

	if ImGui.Button("View usage") {
		state.view_dialogue_usage = true;
	}

	for Meta.get_parsed().dialogue_function_declarations {
		ImGui.Button()
	}

	if ImGui.Button("Add widget") {

	}
})

usage_window :: (state: *State.Editor) {
	ImGui.Begin("Usage");
	defer ImGui.End();

	
}