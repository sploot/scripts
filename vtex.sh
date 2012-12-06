#!/bin/bash

# script to be run from within vim.  Traverses the directory tree
# to find a .tex file that sources the current buffer.
# Stops at the home directory


while getopts "o" opt; do
   case $opt in
      o) OPEN=1;;
   esac
   shift $((OPTIND-1))
done

if [[ `echo $1 | grep -c tex$` == 1 || `echo $1|grep -c pdf$` == 1 && $OPEN == 1 ]]; then
   texfile="$1"
else
   echo "Not a latex file..."
   exit 1
fi
basedir=`echo $texfile | sed -e 's/\(.*\/\).*/\1/'`

if [[ `grep -c \documentclass $texfile` != 0 ]]; then
   cd $basedir
   noext=`echo $texfile|sed -e 's/\(.*\)\..*/\1/'`
   if [[ $OPEN == 1 ]]; then
      pdf=`echo $texfile|sed -e 's/tex/pdf/'`
      open $pdf
   else
      pdflatex -interaction nonstopmode $texfile
#      rm ${noext}.{aux,log}
   fi
   exit 0
elif [[ `echo $basedir | grep -ic /notes/` == 1 ]]; then
   wd=`echo $basedir|sed -e 's/\(.*\/\)notes.*/\1/'`
   relpath=`echo $texfile|sed -e 's/.*\(notes.*\)tex/\1/'`
   cd $wd
   if [ -f "./notes.tex" ]; then
      $0 ./notes.tex
#      if [[ $? == 0 ]]; then
#         rm notes.{aux,log}
#      fi
      exit 0
   else
      for tex in $(find . -type f -iname "*.tex" -maxdepth 1); do
         if [[ `grep -c $relpath $tex` == 1 ]]; then
            noext=`echo $tex|sed -e 's/\(.*\)\..*/\1/'`
            $0 $tex
#            if [[ $! == 0 ]]; then
#               rm ${noext}.{aux,log}
#            fi
            exit 0
         fi
      done
   fi
fi

# only get here if the others fail...
lowest=`echo $HOME|sed -e 's/\(.*\).*\//\1/'`
while [[ "$basedir" != "$HOME/" ]]; do
   cd $basedir
   relpath=`echo $texfile|sed -e 's%'$basedir'\(.*\)tex%\1%'`
   fn=`echo $texfile|sed -e 's/.*\/\(.*tex\)/\1/'`
   for tex in $(find . -type f -iname "*.tex" -maxdepth 1|grep -v $fn); do
      if [[ `grep -c $relpath $tex` == 1 ]]; then
         noext=`echo $tex|sed -e 's/\(.*\)\..*/\1/'`
         $0 $tex
#         if [[ $? == 0 ]]; then
#            rm ${noext}.{aux,log}
#         exit 0
      fi
   done
   basedir=`echo $basedir|sed -e 's/\(.*\/\).*\//\1/'`
done

# if you get here, there are no citing files
echo "There are no files in the current directory tree that cite to this file."
exit 1
