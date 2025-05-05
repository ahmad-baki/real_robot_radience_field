FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu22.04
ENV DEBIAN_FRONTEND=noninteractive

COPY hello.sh /

ENV PIP_ROOT_USER_ACTION=ignore



# Nerfstudio requirements  https://github.com/nerfstudio-project/nerfstudio -->

# Installing Mamba with miniforge https://github.com/conda-forge/miniforge?tab=readme-ov-file#as-part-of-a-ci-pipeline
RUN apt-get update && apt-get install -y --no-install-recommends wget && rm -rf /var/lib/apt/lists/* && \
    wget -O Miniforge3.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh" && \
   bash Miniforge3.sh -b -p "${HOME}/conda"
ENV PATH="$PATH:/root/conda/bin"

# installing git and updating apt
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E1DD270288B4E6030699E45FA1715D88E1DF1F24 && \
    su -c "echo 'deb http://ppa.launchpad.net/git-core/ppa/ubuntu trusty main' > /etc/apt/sources.list.d/git.list" && \
    apt-get update &&\
    apt-get install git -y
ENV PATH="$PATH:/root/git/bin"

 # First approach
#RUN mamba create --name nerfstudio -y python=3.8 &&\
#    mamba run -n nerfstudio pip install --upgrade pip &&\
#    mamba run -n nerfstudio pip uninstall torch torchvision functorch tinycudann  &&\
#    mamba run -n nerfstudio pip install torch==2.1.2++cu118 --extra-index-url https://download.pytorch.org/whl/cu118
    
#RUN mamba run -n nerfstudio pip install torchvision==0.16.2+cu118 --extra-index-url https://download.pytorch.org/whl/cu118 &&\
#    mamba install -n nerfstudio -c "nvidia/label/cuda-11.8.0" cuda-toolkit  &&\
#    mamba run -n nerfstudio pip install ninja git+https://github.com/NVlabs/tiny-cuda-nn/#subdirectory=bindings/torch && \
#    mamba run -n nerfstudio pip install nerfstudio
    
# Second approach:
#RUN apt-get install curl -y &&\
#    curl -fsSL https://pixi.sh/install.sh | bash &&\
#    git clone https://github.com/nerfstudio-project/nerfstudio.git &&\
#    cd nerfstudio &&\
#    ls /

#ENV PATH="$PATH:/root/.pixi/bin"

#WORKDIR /nerfstudio
#RUN pixi run post-install 

# Third approach
SHELL ["/bin/bash", "-l", "-c"]  
RUN mamba create --name nerfstudio -y python=3.8
ENV PATH="/root/conda/envs/nerfstudio/bin:${PATH}"
ENV CONDA_DEFAULT_ENV=nerfstudio
RUN pip install --upgrade pip &&\
    pip uninstall torch torchvision functorch tinycudann  &&\
    pip install torch==2.1.2+cu118 torchvision==0.16.2+cu118 --extra-index-url https://download.pytorch.org/whl/cu118 &&\
    mamba install -n nerfstudio -c "nvidia/label/cuda-11.8.0" cuda-toolkit -y &&\
    pip install ninja git+https://github.com/NVlabs/tiny-cuda-nn/#subdirectory=bindings/torch -y && \
    pip install nerfstudio -y



# Nerfstudio requirements <--

# Installing ROS1 https://wiki.ros.org/rosdep
RUN apt-get install python3-rosdep && \ 
    rosdep init && \ 
    rosdep update && \
# Installing catkin (maybe)
    apt install catkin -y

# Hello World
RUN chmod +x /hello.sh
CMD ["/hello.sh"]