FROM nvidia/cuda:11.1.1-cudnn8-devel-ubuntu18.04

# Uncomment it if you are in China
RUN sed -i 's/security.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
RUN sed -i 's/archive.ubuntu.com/mirrors.ustc.edu.cn/g' /etc/apt/sources.list

# https://github.com/NVIDIA/nvidia-docker/issues/1632#issuecomment-1112667716
RUN rm /etc/apt/sources.list.d/cuda.list
RUN rm /etc/apt/sources.list.d/nvidia-ml.list

ENV DEBIAN_FRONTEND noninteractive
# Add common tools available in apt repository. We choose not to support python2
RUN apt -o Acquire::http::proxy=false update && \
    apt -o Acquire::http::proxy=false install -y apt-utils software-properties-common && \
    add-apt-repository ppa:ubuntu-toolchain-r/test -y && \
    apt update && \
    apt -o Acquire::http::proxy=false install -y aria2 man telnet tmux locales pkg-config inetutils-ping net-tools git zsh thefuck mc sed ack-grep ranger htop silversearcher-ag python3.8 python3.8-dev build-essential autoconf automake libtool make gcc-9 g++-9 curl wget tar libevent-dev libncurses-dev clang lld ccache nasm  unzip openjdk-8-jdk colordiff mlocate iftop libpulse-dev libv4l-dev python3-venv libcurl4-openssl-dev \
    libopenblas-dev gdb texinfo libreadline-dev cmake valgrind tzdata zip libstdc++-7-dev tree && \
    apt clean

RUN locale-gen "en_US.UTF-8"

RUN bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"

# RUN ["/bin/bash", "-c", "aria2c -s16 -x16 http://releases.llvm.org/8.0.0/clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz && \
# tar xf /clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz && \
# pushd /usr/bin/ && \
# ln -s /clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-16.04/bin/clangd && \
# ln -s /clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-16.04/bin/clang clang-8 && \
# ln -s /clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-16.04/bin/clang++ clang++-8 && \
# ln -s /clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-16.04/bin/clang-format && \
# ln -s /clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-16.04/bin/clang-tidy && \
# ln -s /clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-16.04/bin/git-clang-format && \
# ln -s /clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-16.04/share/clang/clang-tidy-diff.py && \
# ln -s /clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-16.04/share/clang/clang-format-diff.py && \
# popd && \
# rm /clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-16.04.tar.xz"]
# 
# Install Ninja
RUN wget https://github.com/ninja-build/ninja/releases/download/v1.9.0/ninja-linux.zip && unzip ninja-linux.zip -d ninja && cp ninja/ninja /usr/bin && rm -rf ninja

# Install pip
# RUN wget https://bootstrap.pypa.io/get-pip.py && \
	# python3 get-pip.py && \
	# rm get-pip.py

# Install cgdb
RUN apt -o Acquire::http::proxy=false update && \
    apt -o Acquire::http::proxy=false install -y flex
RUN git clone git://github.com/cgdb/cgdb.git && cd cgdb && ./autogen.sh && ./configure --prefix=/usr/local && make && make install

# RUN git clone https://github.com/MaskRay/ccls --recursive --depth=1 && \
    # mkdir ccls/build && cd ccls/build && CC=clang-8 CXX=clang++-8 cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=/clang+llvm-8.0.0-x86_64-linux-gnu-ubuntu-16.04/ -GNinja .. && \
    # cmake --build . -- -j`nproc` && \
    # ln -s `pwd`/ccls /usr/bin/ccls

# RUN echo "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial main" >> /etc/apt/sources.list.d/clang.list && \
# echo "deb-src http://apt.llvm.org/xenial/ llvm-toolchain-xenial main" >> /etc/apt/sources.list.d/clang.list && \
# echo "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-7 main" >> /etc/apt/sources.list.d/clang.list && \
# echo "deb-src http://apt.llvm.org/xenial/ llvm-toolchain-xenial-7 main" >> /etc/apt/sources.list.d/clang.list && \
# echo "deb http://apt.llvm.org/xenial/ llvm-toolchain-xenial-8 main" >> /etc/apt/sources.list.d/clang.list && \
# echo "deb-src http://apt.llvm.org/xenial/ llvm-toolchain-xenial-8 main" >> /etc/apt/sources.list.d/clang.list
#
# RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add - && apt -o Acquire::http::proxy=false update && apt install -y clang-format-8 clang-tidy-8 clang-tools-8 && cd /usr/bin && ln -s clangd-8 clangd && ln -s clang-tidy-8 clang-tidy && ln -s clang-tidy-diff-8.py clang-tidy-diff.py && ln -s clang-format-diff-8 clang-format-diff && ln -s clang-format-8 clang-format && apt clean

# RUN git config --global http.proxy xxx && git config --global https.proxy 

# RUN wget https://github.com/neovim/neovim/releases/download/stable/nvim.appimage && chmod +x nvim.appimage && ./nvim.appimage --appimage-extract && chmod 755 -R squashfs-root && rm nvim.appimage && ln -s /squashfs-root/AppRun /usr/bin/nvim

# Install tmux
# RUN ["/bin/bash", "-c", "TMUX_VERSION=3.0a &&       \
# wget https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz &&    \
# mkdir tmux-unzipped &&    \
# tar xf tmux-${TMUX_VERSION}.tar.gz -C tmux-unzipped &&     \
# rm -f tmux-${TMUX_VERSION}.tar.gz &&       \
# pushd tmux-unzipped/tmux-${TMUX_VERSION} &&        \
# ./configure &&     \
# make -j`nproc`&&        \
# make install &&       \
# popd &&        \
# rm -rf tmux-unzipped"]
# -----------

# Install gtags
# RUN ["/bin/bash", "-c", "GTAGS_VERSION=6.6.3 &&     \
# wget http://tamacom.com/global/global-$GTAGS_VERSION.tar.gz &&  \
# mkdir gtags-unzipped && \
# tar xf global-$GTAGS_VERSION.tar.gz -C gtags-unzipped && \
# pushd gtags-unzipped/global-$GTAGS_VERSION &&  \
# ./configure &&  \
# make && \
# make install && \
# popd && \
# rm -rf gtags-unzipped"]

# Install ctags
# RUN ["/bin/bash", "-c", "git clone --depth 1 https://github.com/universal-ctags/ctags.git && \
# cd ctags && \
# ./autogen.sh  && \
# ./configure && \
# make -j$(nproc) && \
# make install && \
# rm -rf ctags"]

RUN ["/bin/bash", "-c", "mkdir git-lfs && curl -L https://github.com/git-lfs/git-lfs/releases/download/v2.8.0/git-lfs-linux-amd64-v2.8.0.tar.gz | tar xzf - -C git-lfs && pushd git-lfs && ./install.sh && popd && rm -rf git-lfs"]

COPY apply-format /usr/bin/
COPY clangformat-git-hook /usr/bin/
COPY clangtidy-git-hook /usr/bin/
COPY install-clangformat-hook /usr/bin/
COPY install-clangtidy-hook /usr/bin/

# Install nodejs
RUN curl -sL https://deb.nodesource.com/setup_13.x | bash -
RUN apt-get install -y nodejs

# Set timezone
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN echo "export LC_ALL=en_US.UTF-8" >> /etc/zsh/zshenv && echo "export LANG=en_US.UTF-8" >> /etc/zsh/zshenv

ARG USER_UID=1000
RUN echo $USER_UID
# Add user "dev"
RUN useradd dev -m -u ${USER_UID} && echo "dev:dev" | chpasswd && usermod -aG sudo dev

# change shell to zsh for user dev
RUN chsh -s `which zsh` dev

USER dev
WORKDIR /home/dev/

# Install yarn
RUN curl -o- -L https://yarnpkg.com/install.sh | bash

# Install oh-my-zsh
RUN sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

# Install power10k zsh theme
RUN git clone --depth=1 https://gitee.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
RUN echo "ZSH_THEME=\"powerlevel10k/powerlevel10k\"" >> ~/.zshrc

# Install autosuggestions and syntax-highlighting
RUN git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions /home/dev/.oh-my-zsh/custom/plugins/zsh-autosuggestions
RUN git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git /home/dev/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting

# Add nvim config to share config with vim
# RUN mkdir -p /home/dev/.config/nvim/ && \
# echo "set runtimepath^=~/.vim runtimepath+=~/.vim/after" >> /home/dev/.config/nvim/init.vim && \
# echo "let &packpath=&runtimepath" >> /home/dev/.config/nvim/init.vim && \
# echo "source ~/.vimrc" >> /home/dev/.config/nvim/init.vim
# # -----------

# COPY --chown=dev:dev .gitconfig /home/dev/
# COPY --chown=dev:dev .vimrc /home/dev/
# COPY --chown=dev:dev .vimrc.local /home/dev/
# COPY --chown=dev:dev coc-settings.json /home/dev/.config/nvim/
# RUN mkdir -p /home/dev/.vim/autoload 
# COPY --chown=dev:dev plug.vim /home/dev/.vim/autoload/ 
# # RUN curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# # RUN nvim +'PlugInstall --sync' +qa
# # RUN nvim +'CocInstall coc-json coc-python coc-highlight coc-snippets coc-lists coc-git coc-yank coc-java coc-clangd coc-cmake -sync' +qa
 
RUN git clone --depth 1 https://github.com/gpakosz/.tmux.git /home/dev/.tmux/ &&    \
ln -s /home/dev/.tmux/.tmux.conf /home/dev/.tmux.conf
COPY --chown=dev:dev .tmux.conf.local /home/dev/

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
# -----------

COPY default_clang_tidy /usr/share/default_clang_tidy
COPY default_clang_format /usr/share/default_clang_format

# Install miniconda
ENV CONDA_DIR /home/dev/miniconda
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
     /bin/bash ~/miniconda.sh -b -p /home/dev/miniconda

# Put conda in path so we can use conda activate
ENV PATH=$CONDA_DIR/bin:$PATH
RUN conda init zsh

# Config conda channels
RUN conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free/ && \
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main/ && \
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge/ && \
conda config --add channels https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda/

# Update conda
# RUN conda update -n base -c defaults conda
# All python libraries

# Make RUN commands use the new environment:
# SHELL ["conda", "run", "-n", "dev_env", "/bin/zsh", "-c"]
RUN conda install pip

# Install cmake via pip, install pygments for gtags, pynvim for neovim
RUN /home/dev/miniconda/bin/python -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple cmake pygments pynvim thefuck pylint flake8 autopep8 mypy ipdb gpustat opencv-python cython yacs termcolor tabulate gdown matplotlib

# Install torch
# COPY --chown=dev:dev torch-1.9.0+cu111-cp36-cp36m-linux_x86_64.whl /home/dev/ 
# COPY --chown=dev:dev torchvision-0.10.0+cu111-cp36-cp36m-linux_x86_64.whl /home/dev/
# RUN pip install torch-1.9.0+cu111-cp36-cp36m-linux_x86_64.whl && pip install torchvision-0.10.0+cu111-cp36-cp36m-linux_x86_64.whl

CMD ["zsh"]
