# 使用Ubuntu 22.04作为基础镜像
FROM ubuntu:22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive

# 安装必要的依赖
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    gcc \
    g++ \
    qt6-base-dev \
    qt6-quickcontrols2-dev \
    qt6-charts-dev \
    qt6-serialbus-dev \
    qt6-declarative-dev \
    libqt6qmlmodels6 \
    libqt6qml6 \
    libqt6quick6 \
    libqt6serialbus6 \
    libqt6charts6 \
    libqt6quickcontrols2-6 \
    libgl1-mesa-dev \
    libxcb-cursor0 \
    && rm -rf /var/lib/apt/lists/*

# 创建工作目录
WORKDIR /app

# 复制项目文件
COPY . .

# 创建构建目录
RUN mkdir -p build && cd build \
    && cmake .. -DCMAKE_PREFIX_PATH=/usr/lib/x86_64-linux-gnu/cmake/Qt6 -DCMAKE_BUILD_TYPE=Release \
    && make -j$(nproc)

# 设置环境变量
ENV LD_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu

# 启动命令
CMD ["/app/build/src/SCADASystem"]
