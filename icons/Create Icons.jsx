// Photoshop Script to Create iPhone Icons from iTunesArtwork
//
// WARNING!!! In the rare case that there are name collisions, this script will
// overwrite (delete perminently) files in the same folder in which the selected
// iTunesArtwork file is located. Therefore, to be safe, before running the
// script, it's best to make sure the selected iTuensArtwork file is the only
// file in its containing folder.
//
// Copyright (c) 2010 Matt Di Pasquale
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// Prerequisite:
// First, create a 512x512 px PNG file named iTunesArtwork, according to:
// http://developer.apple.com/library/ios/#documentation/iphone/conceptual/iphoneosprogrammingguide/BuildTimeConfiguration/BuildTimeConfiguration.html
//
// Install - Save Create Icons.jsx to:
//   Win: C:\Program Files\Adobe\Adobe Utilities\ExtendScript Toolkit CS5\SDK
//   Mac: /Applications/Utilities/Adobe Utilities/ExtendScript Toolkit CS5/SDK
// * Restart Photoshop
//
// Update:
// * Just modify & save, no need to resart Photoshop once it's installed.
//
// Run:
// * With Photoshop open, select File > Scripts > Create Icons
// * When prompted select the prepared iTunesArtwork file for your app.
// * The different version of the icons will get saved to the same folder that
//   the iTunesArtwork file is in.
//
// Adobe Photoshop JavaScript Reference
// http://www.adobe.com/devnet/photoshop/scripting.html


// Turn debugger on. 0 is off.
// $.level = 1;

// Prompt user to select iTunesArtwork file.
var iTunesArtwork = File.openDialog("Select the iTunesArtwork file.");
if (iTunesArtwork !== null) { // clicking "Cancel" returns null
  var doc = open(iTunesArtwork, OpenDocumentType.PNG);
  var startState = doc.activeHistoryState;       // save for undo
  var initialPrefs = app.preferences.rulerUnits; // will restore at end
  app.preferences.rulerUnits = Units.PIXELS;     // use pixels

  // Save icons in PNG using Save for Web.
  var sfw = new ExportOptionsSaveForWeb();
  sfw.format = SaveDocumentType.PNG;
  sfw.PNG8 = false; // use PNG-24
  sfw.transparency = false;
  doc.info = null;  // delete metadata

  var icons = [
    {"name": "Icon",          "size":57},
    {"name": "Icon@2x",       "size":114},
    {"name": "Icon-72",       "size":72},
    {"name": "Icon-Small",    "size":29},
    {"name": "Icon-Small@2x", "size":58},
    {"name": "Icon-Small-50", "size":50}
  ];

  var icon;
  for (i = 0; i < icons.length; i++) {
    icon = icons[i];
    doc.resizeImage(icon.size, icon.size, // width, height
                    null, ResampleMethod.BICUBICSHARPER);
    doc.exportDocument(new File(doc.path + "/" + icon.name + ".png"), ExportType.SAVEFORWEB, sfw);
    // doc.saveAs(new File(doc.path + "/" + icon.name + ".png"), new PNGSaveOptions());
    doc.activeHistoryState = startState; // undo resize
  }

  doc.close(SaveOptions.DONOTSAVECHANGES);

  app.preferences.rulerUnits = initialPrefs; // restore prefs
}
