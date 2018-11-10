# imageloader
This module provides cached image loading. The purpose was to have only one entry
for each file, even if we use symlinks and different paths to load images.

The solution is to use Gio::FILE_ATTRIBUTE_ID_FILE as a key to cache.

To use the module just replace gears.surface.load(...) call with imageloader.load(...).
