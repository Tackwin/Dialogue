#import "Compiler";
#import "Basic";
#import "dialogue/Meta";

build_editor :: () -> Workspace {
	w := compiler_create_workspace("Editor");
	import : [..] string;
	seed := get_build_options();
	opts := get_build_options(w);
	array_add(*import, ..opts.import_path);
	array_add(*import, "./src/");
	array_add(*import, "./src/Client/");
	opts.output_executable_name = "Client";
	opts.import_path = import;
	opts.text_output_flags = 0;
	opts.emit_debug_info = .CODEVIEW;
	opts.Commonly_Propagated = seed.Commonly_Propagated;
	set_build_options(opts, w);
	return w;
}

build_dll :: () -> Workspace {
	w := compiler_create_workspace("Dll");
	import : [..] string;
	seed := get_build_options();
	opts := get_build_options(w);
	array_add(*import, ..opts.import_path);
	array_add(*import, "./src/");
	array_add(*import, "./src/Client/");
	opts.output_executable_name = "ui";
	opts.output_path = "dll/";
	opts.import_path = import;
	opts.text_output_flags = 0;
	opts.output_type = .DYNAMIC_LIBRARY;
	opts.Commonly_Propagated = seed.Commonly_Propagated;
	set_build_options(opts, w);
	return w;
}

build :: () {
	editor := build_editor();

	compiler_begin_intercept(editor);
	add_build_file("src/Editor/Main.jai", editor);

	while true {
		message := compiler_wait_for_message();

		handle_message(message);

		if message.kind == {
			case .COMPLETE; break;
		}
	}

	compiler_end_intercept(editor);

	set_build_options_dc(.{ do_output=false });
}

#run build();
