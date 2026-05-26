// This function will generate links to every file in the same folder as this one
// use <%tp.user.folder_links(tp.file.path(), tp.file.title)%> to generate the list.

// credit to ngraham20/folder_links.js for the original code
// https://gist.github.com/ngraham20/bb1528357bb692baacffc5fb3943c0a0

// The main use of this is if the notes are organized "Wiki style", with a file in
// each folder that matches the folder name, i.e.

// notes/
// ├─ notes.md
// ├─ stickynotes/
// │  ├─ stickynotes.md
// │  ├─ dec-21-2020.md
// ├─ school/
// │  ├─ school.md
// │  ├─ chemistry/
// │  │  ├─ chemistry.md

function folder_links(fullpath, title) {
    fullpath = fullpath.replaceAll(/\//ig, '\\');
    fullpath = fullpath.substring(0, fullpath.lastIndexOf("\\"));
    var fs = require('fs');
    var files = fs.readdirSync(fullpath);
    var outfiles = [];
    for (let f in files) {
        let filetitle = files[f].replace(/\.[^/.]+$/, "");
        if (filetitle != title) {
            outfiles.push(filetitle);
        }
    }
    return "Links: [[" + outfiles.join("]], [[") + "]]";
}

module.exports = folder_links