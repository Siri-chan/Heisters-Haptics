---@meta

---@class class
---@field Init fun(self: class) Constructor function to initialize a class
---@field init fun(self: class) Constructor function to initialize a class
---@field new fun(self: class)  Constructor function to initialize a class

---@generic T
---@param base_class `T` inherit from this base class if defined
---@return T
---@overload fun(): class
---Creates a new class with defined Init function
function class(base_class) end

-------------------- SuperBLT --------------------

---@class vm
---@field dofile fun(filepath: string) SuperBLT internal version of dofile that works exactly the same
---@field loadfile fun(filepath: string) SuperBLT internal version of loadfile that works exactly the same

---@class blt
---@field vm vm
---@field load_native fun(path: string): string, table Attempts to load a SuperBLT Native Plugin. Returns an `error` string (equal to `nil` on success) and/or the loaded `plugin` (equual to `nil` on failure).
blt = nil

---@class BLT
---@field RunHookTable fun(hooks_table: table, path: string) Runs hooks in the given `hooks_table` for the source file specified in `path`
---@field hook_tables {pre: {source_file: table}, post: {source_file: table}} Contains the hooks to run before `pre` or after `post` the `source_file` was loaded by the game
BLT = nil
---@type BLT
_G.BLT = nil

---@type fun(message: string) Prints message to development console
log = nil

---@type string The path to the current mod directory, relative to the mods folder
ModPath = nil

-------------------- BeardLib --------------------

---@class ModCore: class
---Core file of the BeardLib mod
---@field init fun(self: ModCore, config_path: string, load_modules: boolean)
---@field super ModCore
---@field ModPath string The path to the current mod directory, relative to the mods folder
---@field Priority number Defaults to 1
---@field SavePath string Path that files get saved to
---@field _modules table
---@field _blt_mod boolean True if the ModPath directory contains a `main.xml` file
ModCore = nil

-- Path

---@class Path  
---@field GetDirectory fun(self: Path, path: string): string Returns the directory of `path` which may be a file or a directory. Directory is being the folder that the file/folder resides in
---@field GetFileName fun(self: Path, path: string): string Returns the file name from the provided path `path`
---@field GetFilePathNoExt fun(self: Path, path: string): string Returns the provided `path` to the file without the file extension
---@field GetFileNameWithoutExtension fun(self: Path, path: string): string Returns the file name (from the provided `path`) without the extension
---@field GetFileNameNoExt fun(self: Path, path: string): string Returns the file name (from the provided `path`) without the extension
---@field Normalize fun(self: Path, path: string): string Returns a normalized version of the `path`. Currently cleans the separators to all be '/'
---@field CombineDir fun(self: Path, start: string, ...): string Returns a normalized and combined version of the passed paths and treats the result as a directory. Starting with `start` and adding the passed `...`, `start` cannot be null! Example: `Path:CombineDir("path", "to", "dir")` returns `"path/to/dir/"`
---@field Combine fun(self: Path, start: string, ...): string Returns a normalized and combined version of the passed paths. Starting with `start` and adding the passed `...`, `start` cannot be null! Example: `Path:Combine("path", "to", "file")` returns `"path/to/file"`
Path = nil

-- MenuUI

---@class MenuUiParams
---@field name string The name of your MenuUI, can be used to identify it
---@field create_items fun(callback: function) The function will always get called when MenuUI finishes building, you don't have to use it if you're building your menu after managers.gui_data gets created but it's recommended to use it either way
---@field layer? number The layer is simply the drawing priority for the engine's GUI, if your menu is hidden by the default menus or any other menus you can increase this
---@field enabled? boolean Sets the menu enabled or disabled from the moment it's created
menu_ui_params = nil

---@class MenuUI
---@field new fun(self: MenuUI, options: MenuUiParams): MenuUI The root of your menu. This will take care of events to supply to the items such as mouse movement and keyboard input and to toggle your menu. You can create the menu almost anytime. However, if you're creating it before managers.gui_data gets initialized you'll have to use the "create_items" value callback so MenuUI can create the items when it's ready.
MenuUI = nil
