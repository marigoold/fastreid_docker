# FROM nvidia/cuda:11.7.1-cudnn8-devel-ubuntu20.04
FROM pytorch/pytorch:2.0.1-cuda11.7-cudnn8-devel

# Uncomment it if you are in China
RUN sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
RUN sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
ENV DEBIAN_FRONTEND noninteractive

# Add common tools available in apt repository. We choose not to support python2
RUN apt -o Acquire::http::proxy=false update
RUN apt -o Acquire::http::proxy=false install -y apt-utils software-properties-common
RUN apt -o Acquire::http::proxy=false update
RUN apt -o Acquire::http::proxy=false install -y \
    vim aria2 man telnet tmux locales pkg-config inetutils-ping net-tools git zsh \
    thefuck mc sed ack-grep ranger htop silversearcher-ag python3.9 python3.9-dev \
    ipython3 build-essential autoconf automake libtool make gcc-9 g++-9 curl wget \
    tar libevent-dev libncurses-dev clang lld ccache nasm  unzip openjdk-8-jdk \
    colordiff mlocate iftop libpulse-dev libv4l-dev python3-venv libcurl4-openssl-dev \
    libopenblas-dev gdb texinfo libreadline-dev valgrind tzdata zip libstdc++-7-dev \
    libc++-dev libomp-dev cuda-nsight-systems-11-7 fd-find tree sudo clangd \
    python3-pip binutils-dev libunwind8-dev
RUN apt -o Acquire::http::proxy=false clean


RUN locale-gen "en_US.UTF-8"

RUN ["/bin/bash", "-c", "mkdir git-lfs && wget -O - https://github.com/git-lfs/git-lfs/releases/download/v2.8.0/git-lfs-linux-amd64-v2.8.0.tar.gz  | tar xzf - -C git-lfs && pushd git-lfs && ./install.sh && popd && rm -rf git-lfs"]

COPY apply-format /usr/bin/
COPY clangformat-git-hook /usr/bin/
COPY clangtidy-git-hook /usr/bin/
COPY install-clangformat-hook /usr/bin/
COPY install-clangtidy-hook /usr/bin/

# Set timezone
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 49 && update-alternatives --install /usr/bin/python python /usr/bin/python3.9 49
RUN echo "export LC_ALL=en_US.UTF-8" >> /etc/zsh/zshenv && echo "export LANG=en_US.UTF-8" >> /etc/zsh/zshenv
ARG USER_UID=1013
RUN echo $USER_UID

# Add user "dev"
RUN useradd dev -m -u ${USER_UID} && echo "dev:dev" | chpasswd && usermod -aG sudo dev | echo "dev ALL=(ALL:ALL) ALL" >> /etc/sudoers && echo "dev ALL=(ALL) NOPASSWD: NOPASSWD: ALL" >> /etc/sudoers

# change shell to zsh for user dev
RUN chsh -s `which zsh` dev
USER dev
WORKDIR /home/dev/

# Install oh-my-zsh
RUN git config --global http.proxy $HTTP_PROXY
RUN sh -c "$(wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

# Install power10k zsh theme
RUN git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k && echo "ZSH_THEME=\"powerlevel10k/powerlevel10k\"" >> ~/.zshrc

# Install autosuggestions and syntax-highlighting
RUN git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions /home/dev/.oh-my-zsh/custom/plugins/zsh-autosuggestions
RUN git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git /home/dev/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

COPY --chown=dev:dev .tmux.conf.local /home/dev/.tmux/.tmux.conf
COPY --chown=dev:dev .tmux.conf.local /home/dev/.tmux.conf

# Set PyPI mirror
RUN mkdir -p /home/dev/.config/pip && \
echo "[global]" >> /home/dev/.config/pip/pip.conf && \
echo "index-url = https://mirrors.ustc.edu.cn/pypi/web/simple" >> /home/dev/.config/pip/pip.conf && \
echo "format = columns" >> /home/dev/.config/pip/pip.conf
# -----------

# Copy .zshrc
COPY --chown=dev:dev .zshrc /home/dev/.zshrc
# Install fzf last so that the modified .zsrc will not be overwritted
RUN git clone --depth 1 https://github.com/junegunn/fzf.git /home/dev/.fzf && /home/dev/.fzf/install --key-bindings --completion --update-rc

COPY default_clang_tidy /usr/share/default_clang_tidy
COPY default_clang_format /usr/share/default_clang_format

# Python packages
RUN python3 -m pip install \
    cmake pygments pynvim thefuck pylint flake8 autopep8 mypy ipdb gpustat \
    opencv-python cython yacs termcolor tabulate gdown matplotlib black pandas ipdb

# Unset proxy
RUN git config --global --unset http.proxy
RUN unset HTTP_PROXY HTTPS_PROXY http_proxy https_proxy
CMD ["zsh"]