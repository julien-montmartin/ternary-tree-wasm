#!/bin/sh

withOpt=true
withGz=false


root=${HOME}/Dépôts/ternary-tree-wasm

if [ ! -d "${root}" ] ; then

   root=${PWD}
fi

echo "Working in ${root}"


pkg_root=${root}/pkg
pkg_name="ternary-tree-wasm"
pkg_wasm=${pkg_root}/ternary_tree_wasm_bg.wasm
tmp_wasm=/tmp/ternary_tree_wasm_bg.wasm
pkg_wasm_gz=${pkg_root}/ternary_tree_wasm_bg.wasm.gz
docs=${root}/docs
version=$(grep "version" "${root}"/Cargo.toml | grep -o "[[:digit:]]\.[[:digit:]]\.[[:digit:]]")
pkg_archive="${root}/${pkg_name}-${version}.tgz"


#Clean

rm -Rf "${pkg_root}"


#Build a "no loader" release package

wasm-pack build --target web --release "${root}"


if ${withOpt} ; then

	#Try to optimize generated wasm with wasm-opt. This is unexpected, but
	#optimizing for speed also produce the smaller wasm file...
	# - 61K ternary_tree_wasm_bg.wasm
	# - 51K ternary_tree_wasm_bg.wasm.O2
	# - 50K ternary_tree_wasm_bg.wasm.O4
	# - 50K ternary_tree_wasm_bg.wasm.Os
	# - 50K ternary_tree_wasm_bg.wasm.Oz

	mv "${pkg_wasm}" "${tmp_wasm}"
	wasm-opt -O4 -o "${pkg_wasm}" "${tmp_wasm}"

fi


#Patch npm package.json to have keywords
#diff -u ./pkg/package.json.org ./pkg/package.json

patch -l -d "${root}" -p0 --forward <<EOF
--- ./pkg/package.json.org	2020-01-18 08:22:21.658157959 +0100
+++ ./pkg/package.json	2020-01-18 08:24:50.082224935 +0100
@@ -1,5 +1,6 @@
 {
   "name": "ternary-tree-wasm",
+  "keywords": ["tst", "ternary", "search", "tree", "wasm", "rust", "trie"],
   "collaborators": [
     "Julien Montmartin <julien.montmartin@fastmail.fm>"
   ],
@@ -18,4 +19,4 @@
   "module": "ternary_tree_wasm.js",
   "types": "ternary_tree_wasm.d.ts",
   "sideEffects": "false"
-}
\ Pas de fin de ligne à la fin du fichier
+}
EOF


if ${withGz} ; then

	#Compress optimized output with gzip
	# - 19K ternary_tree_wasm_bg.wasm.gz

	gzip --best "${pkg_wasm}"
	ls -lh "${pkg_wasm_gz}"


	#Patch ternary_tree_wasm.js to import ternary_tree_wasm_bg.wasm.gz
	#diff -u ./pkg/ternary_tree_wasm.js.org ./pkg/ternary_tree_wasm.js

	patch -l -d "${root}" -p0 --forward <<EOF
--- ./pkg/ternary_tree_wasm.js.org	2020-01-04 11:00:07.251082289 +0100
+++ ./pkg/ternary_tree_wasm.js	2020-01-04 11:01:31.689181374 +0100
@@ -1,4 +1,4 @@
-import * as wasm from './ternary_tree_wasm_bg.wasm';
+import * as wasm from './ternary_tree_wasm_bg.wasm.gz';

 const heap = new Array(32);

@@ -292,4 +292,3 @@
 export const __wbindgen_throw = function(arg0, arg1) {
     throw new Error(getStringFromWasm0(arg0, arg1));
 };
-
EOF


	#Patch package.json to reference ternary_tree_wasm_bg.wasm.gz
	#diff -u ./pkg/package.json.org ./pkg/package.json

	patch -l -d "${root}" -p0 --forward <<EOF
--- ./pkg/package.json.org	2020-01-04 11:00:18.554828858 +0100
+++ ./pkg/package.json	2020-01-04 11:00:44.418247759 +0100
@@ -11,11 +11,11 @@
     "url": "https://github.com/julien-montmartin/ternary-tree-wasm"
   },
   "files": [
-    "ternary_tree_wasm_bg.wasm",
+    "ternary_tree_wasm_bg.wasm.gz",
     "ternary_tree_wasm.js",
     "ternary_tree_wasm.d.ts"
   ],
   "module": "ternary_tree_wasm.js",
   "types": "ternary_tree_wasm.d.ts",
   "sideEffects": "false"
-}
\ Pas de fin de ligne à la fin du fichier
+}
EOF

fi


#Prepare docs for GitHub page

#cp -R "${pkg_root}" "${docs}"
#find "${docs}" -iname .gitignore -exec rm {} \;

emacs --batch -l "${HOME}"/.emacs "${docs}"/doc.org -f org-html-export-to-html


#Make an archive

tar -czf "${pkg_archive}" "${pkg_root}"


#Show files

echo "------------------------------------------------------------"
ls -lh "${pkg_archive}"
tree -h "${pkg_root}"
tree -h "${docs}"


echo "### wasm-pack publish ./pkg/"
echo "### cargo publish"
