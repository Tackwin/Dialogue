#scope_file

ImGui :: #import "my_imgui";
ImGui_GL :: #import "my_imgui/imgui_impl_gl";

GUI :: #import "editor/front/Gui";
State :: #import "editor/back/State";

#import "Random";
#import "File";
#import "File_Watcher";

#import "Window_Creation";
#import "Input";
#import "GL";
#import "Basic";
#import "Math";

Editor_Ui :: struct {
	imgui: ImGui_GL.UI_State;
	window: Window_Type;

	exit := false;
}

#scope_export

#placeholder Client_Code;
#placeholder client_code;

render_imgui :: (state: *State.Editor) {
	dockspace_flags : ImGui.DockNodeFlags = .PassthruCentralNode;
	window_flags : ImGui.WindowFlags = .NoDocking;
	viewport := ImGui.GetMainViewport();
	ImGui.SetNextWindowPos(viewport.WorkPos);
	ImGui.SetNextWindowSize(viewport.WorkSize);
	ImGui.SetNextWindowViewport(viewport.ID_);
	ImGui.PushStyleVar(.WindowRounding, 0.0);
	ImGui.PushStyleVar(.WindowBorderSize, 0.0);
	window_flags |= ImGui.WindowFlags.NoTitleBar | .NoCollapse;
	window_flags |= ImGui.WindowFlags.NoResize | .NoMove;
	window_flags |= ImGui.WindowFlags.NoBringToFrontOnFocus | .NoNavFocus;
	window_flags |= ImGui.WindowFlags.NoBackground;

	ImGui.SetNextWindowBgAlpha(0);
	ImGui.PushStyleVar(.WindowPadding, .{ 0.0, 0.0 });
	ImGui.Begin("DockSpace", null, window_flags);
	defer ImGui.End();
	ImGui.PopStyleVar(3);

	dockspace_id := ImGui.GetID("MyDockSpace");
	ImGui.DockSpace(dockspace_id, .{ 0.0, 0.0 }, dockspace_flags);

	GUI.main_window(state, client_code);
}

main :: () {
	ui: Editor_Ui;
	ui.window = create_window(1200, 675, "ImGui OpenGL Test");
	setup_mousemove_hook();

	gl_create_context(ui.window, 4, 5, false, true);
	gl_load(*gl);
	gl_enable_debug_output(true);

	ImGui_GL.ImGui_Impl_CreateContext(*ui.imgui, set_default_allocators=true);
	ImGui_GL.ImGui_Impl_Init(*ui.imgui, ui.window);

	state: State.Editor;

	last_time: float64;
	wglSwapIntervalEXT(0);
	while !ui.exit {
		at := current_time_monotonic();
		current_time := to_float64_seconds(at);
		dt := cast(float64)(current_time - last_time);
		dt32 := cast(float32)(current_time - last_time);
		defer last_time = current_time;

		update_window_events();
		io := ImGui.GetIO();
		for events_this_frame {
			ImGui_GL.ImGui_Impl_ProcessEvent(*ui.imgui, it);
			if it.type == {
				case .QUIT; ui.exit = true;
				case .KEYBOARD;
					if io.WantCaptureKeyboard continue;
					if it.key_pressed == 0 continue;
					if it.key_code == .ESCAPE ui.exit = true;
			}
		}
		w, h := get_window_size(ui.window);

		ImGui_GL.ImGui_Impl_NewFrame(*ui.imgui, ui.window, w, h);
		render_imgui(*state);
		ImGui.Render();

		glViewport(0, 0, xx w, xx h);
		glClearColor(0, 0, 0, 1);
		glClear(GL_COLOR_BUFFER_BIT);

		glEnable(GL_MULTISAMPLE);
		ImGui_GL.ImGui_Impl_RenderDrawData(*ui.imgui, ImGui.GetDrawData());

		dc := GetDC(ui.window);
		SwapBuffers(dc);
		
		reset_temporary_storage();
	}
}

#scope_file
#if OS == .WINDOWS #import "Windows";

get_window_size :: (window: Window_Type) -> s32, s32 {
	#if OS == .WINDOWS {
		rect: RECT;
		GetClientRect(window, *rect);
		return rect.right, rect.bottom;
	}
}

opengl_debug :: (
	source: GLenum,
	type: GLenum,
	id: GLenum,
	severity: GLenum,
	length: GLsizei,
	msg: *GLchar,
	user: *void
) #c_call {
	debug_source_str :: (source: GLenum) -> string {
		sources :: string.[
		"API",   "Window System", "Shader Compiler", "Third Party", "Application",
		"Other", "Unknown"
		];
		str_idx := min(source - GL_DEBUG_SOURCE_API, sources.count - 1);
		return sources[str_idx];
	}

	debug_type_str :: (type: GLenum) -> string {
		types :: string.[
			"Error",       "Deprecated Behavior", "Undefined Behavior", "Portability",
			"Performance", "Other",               "Unknown"
		];

		str_idx := min(type - GL_DEBUG_TYPE_ERROR, types.count - 1);
		return types[str_idx];
	}

	debug_severity_str :: (severity: GLenum) -> string {
		severities :: string.[ "High", "Medium", "Low", "Unknown" ];

		str_idx := min(severity - GL_DEBUG_SEVERITY_HIGH, severities.count - 1);
		return severities[str_idx];
	}

	message: string;
	message.data = msg;
	message.count = length;
	format :: #string DONE
=========================
OpenGL:
Object Id: %
Severity : %
Type     : %
Source   : %
Message  : %
=========================
DONE;
	new_context: Context;
	push_context new_context {
		to_ignore :: GLenum.[
			131185
		];

		for to_ignore if id == it return;

		print(
			format,
			id,
			debug_severity_str(severity),
			debug_type_str(type),
			debug_source_str(source),
			message
		);
	}
}

#if OS == .WINDOWS {
	// Jai's stdlib lacks mouse move events. Install a Windows "Hook" and catch them.
	//
	// Hopefully in the future it will be easier to provide custom WindowProc functionality
	// through Jai's windows impl.
	HHOOK :: HANDLE;
	HOOKPROC :: #type (code: s32, wparam: WPARAM, lparam: LPARAM) -> LRESULT #c_call;
	WH_MOUSE :: 7;
	user32 :: #foreign_system_library "user32";
	kernel32 :: #foreign_system_library "kernel32";

	CallNextHookEx    :: (hhk: HHOOK, code: s32, wparam: WPARAM, lparam: LPARAM) -> LRESULT #foreign user32;
	SetWindowsHookExA :: (id_hook: s32, hook_fn: HOOKPROC, hmod: HINSTANCE, thread_id: DWORD) -> HHOOK #foreign user32;
	FreeLibrary       :: (module: HMODULE) -> BOOL #foreign kernel32;

	HookProc :: (code: s32, wparam: WPARAM, lparam: LPARAM) -> LRESULT #c_call {
		return CallNextHookEx(null, code, wparam, lparam);
	}

	hook: HHOOK;

	setup_mousemove_hook :: () {
		if SetWindowsHookExA(WH_MOUSE, HookProc, null, GetCurrentThreadId()) == null {
			print("SetWindowsHookExA error: %\n", GetLastError());
			assert(false);
		}
	}
}