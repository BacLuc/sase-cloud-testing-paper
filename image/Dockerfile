FROM sharelatex/sharelatex-base:3.5.0@sha256:08c277485c77a58f22900ecf893f2c60b0cf9a848c57735ca80881470d1112d6  AS tex-container

ENV DEBIAN_FRONTEND=noninteractive

ARG USERNAME=tex
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN <<HEREDOC
    set -e
    groupadd --gid $USER_GID $USERNAME
    useradd --uid $USER_UID --gid $USER_GID -m $USERNAME
    apt update
    apt install -y sudo
    rm -rf /var/lib/{apt,dpkg,cache,log}/
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME
    chmod 0440 /etc/sudoers.d/$USERNAME
HEREDOC

RUN <<HEREDOC
  set -e
  apt update
  apt install -y git texlive-fonts-recommended texlive-fonts-extra
HEREDOC

ENV TEXLIVE_VERSION=2022
RUN <<HEREDOC
  set -e
  tlmgr option repository http://ftp.math.utah.edu/pub/tex/historic/systems/texlive/${TEXLIVE_VERSION}/tlnet-final
HEREDOC

# cache big packages
RUN <<HEREDOC
    set -e
    tlmgr install libertine
    texhash
    rm -rf /usr/local/texlive/${TEXLIVE_VERSION}/texmf-var/web2c/*.log && \
    rm -rf /usr/local/texlive/${TEXLIVE_VERSION}/tlpkg/texlive.tlpdb.main.*
HEREDOC

RUN <<HEREDOC
    set -e
    (echo y;echo o conf prerequisites_policy follow;echo o conf commit)|cpan
    cpan YAML::Tiny File::HomeDir Unicode::GCString
HEREDOC

RUN <<HEREDOC
    set -e
    packages=""
    packages="$packages ieeetran"
    packages="$packages ieeeconf"
    packages="$packages times"
    packages="$packages cite"
    packages="$packages xcolor"
    packages="$packages csquotes"

    packages="$packages latexindent"
    tlmgr install $packages
    texhash
    rm -rf /usr/local/texlive/${TEXLIVE_VERSION}/texmf-var/web2c/*.log
    rm -rf /usr/local/texlive/${TEXLIVE_VERSION}/tlpkg/texlive.tlpdb.main.*
HEREDOC

ENV PATH ${PATH}:\
/usr/local/texlive/${TEXLIVE_VERSION}/bin/x86_64-linux:\
/usr/local/texlive/${TEXLIVE_VERSION}/bin/aarch64-linux

RUN <<HEREDOC
  dirs="/out /workspace /var/lib/sharelatex/"
  mkdir -p $dirs
  chown -R $USER_UID:$USER_GID $dirs
HEREDOC

ENV LATEX_MAIN_FILE="main.tex"

COPY entrypoint.sh /usr/local/bin/entrypoint
RUN chmod +x /usr/local/bin/entrypoint

USER $USERNAME
WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/entrypoint"]

CMD ["default"]
