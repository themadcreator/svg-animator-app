
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

    npm run && npm build