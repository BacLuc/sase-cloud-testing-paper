#!/bin/sh
set -e

sudo chmod -R +w /workspace
sudo chmod -R +w /out

if [ "$1" = "default" ]; then
  pdflatex_path=$(which pdflatex)
  cmd="$pdflatex_path -output-format=pdf -halt-on-error"
  cmd="$cmd -interaction=nonstopmode"
  cmd="$cmd -output-directory=/out ${LATEX_MAIN_FILE}"
  exec $cmd
fi

if [ "$1" = "format" ]; then
  find . -name '*.tex' | xargs latexindent -w -s
  find . -name '*.bak*' | xargs rm -f
  find . -name '*indent.log*' | xargs rm -f
  exit 0
fi

if [ "$1" = "check-format" ]; then
  set +e
  failed=0
  for file in $(find . -name "*.tex"); do
    latexindent $file > $file.formatted
    git diff --no-index --exit-code $file $file.formatted
    exitcode=$#
    rm $file.formatted
    if [ $exitcode -gt 0 ]; then
      failed=$exitcode
    fi
  done
  find . -name '*indent.log*' | xargs rm -f
  exit $failed
fi

exec "$@"
