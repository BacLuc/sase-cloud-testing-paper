#!/bin/sh
set -e

if [ "$1" = "default" ]; then
  bibtex_path=$(which bibtex)
  cp -a /workspace/* /out
  cd /out
  latex_file_without_tex=$(echo ${LATEX_MAIN_FILE} | sed 's|.tex||')
  pdflatex_path=$(which pdflatex)
  cmd="$pdflatex_path -output-format=pdf -halt-on-error"
  cmd="$cmd -interaction=nonstopmode"
  cmd="$cmd ${LATEX_MAIN_FILE}"
  $cmd
  $bibtex_path ${latex_file_without_tex}
  $cmd
  $cmd
  exit 0
fi

if [ "$1" = "format" ]; then
  set -x
  find . -name '*.tex' -print0 | xargs --null latexindent -w -s
  find . -name '*.bak*' -print0 | xargs --null rm -f
  find . -name '*indent.log*' -print0 | xargs --null rm -f
  exit 0
fi

if [ "$1" = "check-format" ]; then
  set +e
  set -x
  failed=0
  # shellcheck disable=SC2044
  for file in $(find . -name "*.tex" -print0 | xargs --null echo); do
    latexindent $file > $file.formatted
    git diff --no-index --exit-code $file $file.formatted
    exitcode=$?
    rm $file.formatted
    if [ $exitcode -gt 0 ]; then
      failed=$exitcode
    fi
  done
  find . -name '*indent.log*' -print0 | xargs --null rm -f
  exit $failed
fi

exec "$@"
