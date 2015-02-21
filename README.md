
# Setup

Install node.js

Then, from this directory, run:

    npm install


# Creating a model

Create an Adobe Illustrator document.

Put each frame on a layer, name them 'frame0', 'frame1', 'frame2', etc.

For each object that should have the same style across frames, select all of them and assign a unique color (it's doesn't matter which).

Export to SVG with "Style Elements" selection in CSS Properties and place it in this directory or a sub-directory.


# Define your model in `models.json`

For example

    "test_model" : {
      "svg"     : "test_model/model.svg",
      "css"     : "test_model/model.css",
      "classes" : {
        "st0" : "big-box",
        "st1" : "small-box"
      },
      "palettes"  : [
        "bright",
        "cool",
        "hot"
      ]
    }

### JSON Fields

  **svg** - the file containing your exported SVG.

  **css** - the file containing your CSS rules.

  **fps** - the target Frames-Per-Second of the animation.

  **classes** - (optional) contains a mapping between the Illustrator auto-generated class names "st0", "st1", "st2", etc. to your human-readable names. You'll probably have to expirement a bit to see which style ends up with which class name.

  **palettes** - (optional) class names that are added to the SVG group which allow you to create sets of color palettes.


# Running the app

    npm run build && npm start

Then navigate your browser over to:

    http://localhost:1111/

You'll have to rebuild and restart the app if you make any code changes, but you don't if you just modify the SVG, HTML or CSS files.