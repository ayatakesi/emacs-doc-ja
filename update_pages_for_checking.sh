#!/bin/bash

cd emacs/japanese_texis/;
texi2any --html \
	 --output=html/ \
	 --document-language=ja_JP \
	 -c DATE_IN_HEADER=1 \
	 -c PRE_BODY_CLOSE="This page has generated for branch:${TRAVIS_BRANCH}, commit:${TRAVIS_COMMIT} to check Japanese translation." emacs-ja.texi
cd -;

cd lispref/japanese_texis/;
texi2any --html \
	 --output=html/ \
	 --document-language=ja_JP \
	 -c DATE_IN_HEADER=1 \
	 -c PRE_BODY_CLOSE="This page has generated for branch:${TRAVIS_BRANCH}, commit:${TRAVIS_COMMIT} to check Japanese translation." elisp-ja.texi
cd -;

git config --global user.email "ayanokoji.takesi@gmail.com"
git config --global user.name "ayatakesi"

git clone https://github.com/ayatakesi/ayatakesi.github.io;

rm -fr ayatakesi.github.io/emacs/translation_HEAD/;
mkdir -p ayatakesi.github.io/emacs/translation_HEAD/;
cp -pr emacs/japanese_texis/html/ ayatakesi.github.io/emacs/translation_HEAD/;

rm -fr ayatakesi.github.io/lispref/translation_HEAD/;
mkdir -p ayatakesi.github.io/lispref/translation_HEAD/;
cp -pr lispref/japanese_texis/html/ ayatakesi.github.io/lispref/translation_HEAD/;


git -C ayatakesi.github.io/ add emacs/translation_HEAD/;
git -C ayatakesi.github.io/ add lispref/translation_HEAD/;
git -C ayatakesi.github.io/ commit -m "Generate pages for branch:${TRAVIS_BRANCH}, commit:${TRAVIS_COMMIT} to check Japanese translation.";
git -C ayatakesi.github.io/ push --quiet https://${AYATAKESI_PAT}@github.com/ayatakesi/ayatakesi.github.io.git;
