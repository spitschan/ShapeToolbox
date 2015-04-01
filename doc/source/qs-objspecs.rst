
.. _qs-objspecs:

=====================================
Model specs and contents of obj-files
=====================================

Or: I didn't use sensible file names for the objects I created and I
now need to know the specs of each model object; what do I do?

Do this: Open the .obj-file in a text editor.  The first lines that
start with '#' give a summary of the modulation parameters used for
the object, along with the date and time it was created, the name of
the function used to create it, and so forth.  All the
objMake*-functions in |toolbox| write a reasonably complete summary of
the parameters in these comments of each object file.

After those commented lines come (usually quite a few) lines that
specify the vertex locations (lines starting with 'v'), texture
coordinates (starting with 'vt'), vertex normals ('vn'), and the faces
('f').
