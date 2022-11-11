#scope_file
ImGui :: #import "my_imgui";
#import "Basic";

#scope_export

coucou1 :: () {
	if ImGui.Button("coucou !") print("Coucoued\n");
} @Component

coucou2 :: () {
	if ImGui.Button("coucou back !") print("Coucoued backed\n");
} @Component

