CUDA_DIR="/usr/local/cuda-$1"

if ! ls "$CUDA_DIR"
then
  echo "folder $CUDA_DIR not found to switch"
fi

echo "Switching symlink to $CUDA_DIR"
mkdir -p /usr/local
rm -rf /usr/local/cuda
ln -s "$CUDA_DIR" /usr/local/cuda

export CUDA_VERSION=$(ls /usr/local/cuda/lib64/libcudart.so.*|sort|tac | head -1 | rev | cut -d"." -f -3 | rev)
export CUDNN_VERSION=$(ls /usr/local/cuda/lib64/libcudnn.so.*|sort|tac | head -1 | rev | cut -d"." -f -3 | rev)

ls -alh /usr/local/cuda

echo "CUDA_VERSION=$CUDA_VERSION"
echo "CUDNN_VERSION=$CUDNN_VERSION"
