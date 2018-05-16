#!/bin/sh
set -x

function system {
  "$@"
  if [ $? -ne 0 ]; then
    echo "make.sh: unsuccessful command $@"
    echo "abort!"
    exit 1
  fi
}

if [ $# -eq 0 ]; then
echo 'bash make.sh slides1|slides2'
exit 1
fi

name=$1
rm -f *.tar.gz

opt="--encoding=utf-8"
# Note: Makefile examples contain constructions like ${PROG} which
# looks like Mako constructions, but they are not. Use --no_mako
# to turn off Mako processing.
opt="--no_mako"

rm -f *.aux



# Plain HTML documents

html=${name}-solarized
system doconce format html $name --pygments_html_style=perldoc --html_style=solarized3 --html_links_in_new_window --html_output=$html $opt --encoding=utf-8
system doconce split_html $html.html --method=space10 --encoding=utf-8

html=${name}
system doconce format html $name --pygments_html_style=default --html_style=bloodish --html_links_in_new_window --html_output=$html $opt --encoding=utf-8
system doconce split_html $html.html --method=space10 --encoding=utf-8

# Ordinary plain LaTeX document
rm -f *.aux  # important after beamer
system doconce format pdflatex $name --minted_latex_style=trac --latex_admon=paragraph $opt
system doconce ptex2tex $name envir=minted
# Add special packages
doconce subst "% Add user's preamble" "\g<1>\n\\usepackage{simplewick}" $name.tex
doconce replace 'section{' 'section*{' $name.tex
pdflatex -shell-escape $name
pdflatex -shell-escape $name
mv -f $name.pdf ${name}-minted.pdf
cp $name.tex ${name}-plain-minted.tex

