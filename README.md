# Generate ptx using nvcc and llvm/clang

## Using NVCC

```bash
nvcc -keep -arch=sm_75 vecADD.cu -o vecAdd
```

## Using llvm clang

```bash
clang++-15 -c -emit-llvm vecADD.cu

llvm-dis-15 vecADD-cuda-nvptx64-nvidia-cuda-sm_35.bc

llc-15 -mcpu=sm_35 vecAdd-cuda-nvptx64-nvidia-cuda-sm_35.ll -o vecADD_clang.ptx
```
