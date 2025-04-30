FROM nvidia/cuda:11.8.0-cudnn8-runtime-ubuntu20.04

COPY src ./

# Installing Mamba with miniforge
RUN wget -O Miniforge3.sh "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"
RUN bash Miniforge3.sh -b -p "${HOME}/conda"
RUN source "${HOME}/conda/etc/profile.d/conda.sh"
RUN source "${HOME}/conda/etc/profile.d/mamba.sh"
RUN conda activate

# Nerfstudio requirements  -->
RUN conda create --name nerfstudio -y python=3.8
RUN conda activate nerfstudio
RUN python -m pip install --upgrade pip


# uninstalling prev. pytorch installation maybe not necassary
RUN pip uninstall torch torchvision functorch tinycudann

RUN pip install torch==2.1.2+cu118 torchvision==0.16.2+cu118 --extra-index-url https://download.pytorch.org/whl/cu118
RUN conda install -c "nvidia/label/cuda-11.8.0" cuda-toolkit
RUN pip install ninja git+https://github.com/NVlabs/tiny-cuda-nn/#subdirectory=bindings/torch
# Nerfstudio requirements <--

# Installing Nerfstudio
RUN pip install nerfstudio

# Installing ROS1
RUN sudo apt-get install python3-rosdep
RUN sudo rosdep init
RUN rosdep update

# Installing catkin (maybe)
RUN sudo apt install catkin