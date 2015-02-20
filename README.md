
# Setup

Install node.js

Then, from this directory, run:

    npm install


# Creating a model

Create an illustrator document.

Put each frame on a layer, name them 'frame0', 'frame1', 'frame2', etc.

For each object that should have the same style across frames, select all of them and assign a unique color (it's doesn't matter which).

Export to SVG with "Style Elements" selection in CSS Properties.

Move SVG to this directory and name it 'model.svg'


# Running the app

    npm run build && npm start

Then navigate your browser over to:

    http://localhost:1111/

You'll have to rebuild and restart the app if you make any code changes, but you don't if you just modify the SVG, HTML or CSS files.