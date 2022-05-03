# liminal-loader
A modified build of [liminal ranger](https://yatoimtop.itch.io/liminal-ranger) which can load .pck files as mods. Included in this repository are the files I created which add the mod loading functionality. Builds on the releases page are full rebuilds of the game with the loader patched in. If you like this game enough that you're installing mods from it, you should probably support yatoimtop by donating through the itch page linked above.

## Usage
Download liminal-loader.zip from the releases page and extract it. To add mods, place mod .pck files into the 'mods' folder.

## Explanation
This loader works by using Godot's built in support for loading .pck archive files. A custom scene (`loader.tscn`) is set as the default scene for the game rather than the main menu. This scene just contains a single node with `loader.gd` attached to it, so that the mod loading code can run before anything else. The script iterates through every .pck file in the mods folder, and does the following for each:
 - Load the mod, adding any files contained in the archive to the game's resources. Files from the mod will overwrite any files in the game with the same name.
 - Look for a .gd file in the root of the resources folder with the same name as the .pck file. This file serves as the entrypoint for the mod, and will be attached to a node which is loaded globally (e.g. stays loaded through scene changes).
## Developing Mods
### Introduction
Mods for this loader can take one of two approaches, or a mixture of both:
 - Make changes by directly modifying decompiled scripts from the game, which will overwrite the originals when the mod is loaded
 - Leave original scripts as is, make changes at runtime from the entrypoint script.


 The first approach is definitely easier, but I would recommend the second approach. The primary reason for this is that if your mod consists of modified versions of scripts from the game, then a large portion of your mod will be code you didn't write and don't have permission to distribute. It's also not very space efficient as the mod includes all that extra code which doesn't change. 
 
 
 Unfortunately some things may be impossible to do without directly modifying existing scripts due to the loader's current primitive state. In particular, the loader would need to support runtime function hooking to really open up what is possible without source code modification.

 ### Development Environment
 To develop a mod, you'll need two pieces of software:
  - [Godot Engine](https://godotengine.org/)
  - [Godot RE Tools](https://github.com/bruvzg/gdsdecomp)


  You'll also of course need the game.

  1. Open Godot Engine and create a new project. The name you give it now doesn't matter as it will be overriden soon. Once the project is set up and the editor opens, close Godot Engine.

  2. Open Godot RE Tools, and choose PCK -> Explore PCK archive. Navigate to the folder where you extracted the game and select `liminal ranger 1.2.pck`, then click open. There will then be some loading time while RE Tools reads all the files, before a new window appears. Use the '...' button next to the destination folder field to select the folder where you created your Godot project, then hit extract. When this process finishes, your project folder will contain a complete dump of the game's files.

  3. Open the project in the editor. It might give you an error about not being able to load an addon, you can ignore this. You'll be able to explore scenes in the editor and run the game in debug mode, but currently a few things won't behave quite right. In particular, source files will appear blank and changes you make to project settings will not apply.

  4. To fix project settings, delete `project.binary` from the root of your project folder.

  5. Source files appear blank because the game is using compiled versions of the files. If you want to view or edit any source files, you'll need to decompile them. In Godot RE Tools, go to GDScript -> Decompile .GDC/.GDE script files. Click Add Files and select the files you're interested in. You'll have to do this multiple times if the files you want are in different subdirectories, making sure to Clear Files between each time. Set the script bytecode version to 3.2.0 release, then set the destination folder to the same folder where your source files are located. Now click decompile. When you're done decompiling, delete the .remap files associated with all the files you decompiled. You should now be able to view these files in the godot editor, and changee you make to them will be reflected when you run the project.

  6. Create an entrypoint file in the root of your project folder called `<name of your mod>.gd`. The name you choose will also be the name which the pck you generate will need to use. You will need to include `extends Node` at the top of this file. This file will be loaded globally by the loader, but for testing your mod in the editor you'll need to do this yourself. An example way of doing this would be to add the following code to the bottom of the `_ready` function in `mainmenu.gd`:
  ```
  var entry = Node.new()
  entry.name = "myMod"
  entry.set_script(load("res://myMod.gd"))
  get_tree().root.call_deferred("add_child", entry)
  ```
  

 ### Building
 1. Copy all the files which you either created or modified for your mod into an empty folder, preserving their directory structure. If your mod includes any files which Godot 'imports', such as textures and music, then instead of copying the file itself you will need to copy the generated .import file (in the same folder as the original) and the corresponding files in the .import folder.
 
 2. In Godot RE Tools, choose 'PCK -> Create PCK archive from folder' and choose the folder where you placed the mod files.

 3. Click save and choose a location to place the pck file for your mod. Make sure you give the pck file the same name as your entrypoint gdscript file.

 ## TODO
 - Turn this project into a universal mod loader for Godot games, including a patcher to automatically make the necessary changes for a game to load mods.
 - Simplify the workflow for mod developers, by providing easy methods for setting up the environment and building the mod.
 - Write a better README