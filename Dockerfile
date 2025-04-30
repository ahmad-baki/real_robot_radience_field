FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu20.04
ENV DEBIAN_FRONTEND=noninteractive

COPY hello.sh /

# Installing Mamba with miniforge https://github.com/conda-forge/miniforge?tab=readme-ov-file#as-part-of-a-ci-pipeline
RUN apt-get update && apt-get install -y --no-install-recommends wget && rm -rf /var/lib/apt/lists/* && \
    wget -O Miniforge3.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" && \
    bash Miniforge3.sh -b -p "${HOME}/conda"
ENV PATH="$PATH:/root/conda/bin"

# Installing git
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E1DD270288B4E6030699E45FA1715D88E1DF1F24 && \
    su -c "echo 'deb http://ppa.launchpad.net/git-core/ppa/ubuntu trusty main' > /etc/apt/sources.list.d/git.list" && \
    apt-get update && \ 
    apt-get install git -y
ENV PATH="$PATH:/root/git/bin"


# Nerfstudio requirements  https://github.com/nerfstudio-project/nerfstudio -->
RUN mamba create --name nerfstudio -y python=3.8 &&\
    # mamba activate nerfstudio &&\
    pip install --upgrade pip &&\
    mamba install -n nerfstudio pytorch==2.1.2 torchvision==0.16.2 torchaudio==2.1.2 pytorch-cuda=11.8 -c pytorch -c nvidia -y &&\
    mamba install -n nerfstudio -c "nvidia/label/cuda-11.8.0" cuda-toolkit -y &&\
    mamba install -n nerfstudio ninja git+https://github.com/NVlabs/tiny-cuda-nn/#subdirectory=bindings/torch -y && \
    mamba install -n nerfstudio nerfstudio -y
# Nerfstudio requirements <--

# Installing ROS1
RUN apt-get install python3-rosdep && \ 
    rosdep init && \ 
    rosdep update && \
# Installing catkin (maybe)
    apt install catkin -y

# Hello World
RUN chmod +x /hello.sh
CMD ["/hello.sh"]