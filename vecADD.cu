#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <cuda.h>

typedef struct {
    size_t n;
    int k, theta;
    float pi;
}foo_t;

__attribute__((noinline)) __device__ int add(int a, int b, int i, const foo_t &foo )
{
    //random ops to avoid inlining
    if(i<=0)
        return 0;
    int val = foo.n * foo.k;
    val += int(foo.pi);
    val -= foo.theta;
    val -= (a*b);
    return val;
}

__global__ void vecAdd(int *a, int *b, int *c, const foo_t foo)
{
    // Get our global thread ID
    int id = blockIdx.x*blockDim.x+threadIdx.x;
    // Make sure we do not go out of bounds
    if (id < foo.n)
    {
        c[id] += add(a[id], b[id], id+1, foo);
    }
}

int main( int argc, char* argv[] )
{
    // Size of vectors
    const int n = 10000;

    // Host input vectors
    int *h_a;
    int *h_b;
    //Host output vector
    int *h_c;

    // Device input vectors
    int *d_a;
    int *d_b;
    //Device output vector
    int *d_c;

    // Size, in bytes, of each vector
    size_t bytes = n*sizeof(int);

    foo_t foo = {.n=bytes, .k = n, .theta = 90, .pi = 3.14};

    // Allocate memory for each vector on host
    h_a = (int*)malloc(bytes);
    h_b = (int*)malloc(bytes);
    h_c = (int*)malloc(bytes);

    // Allocate memory for each vector on GPU
    cudaMalloc(&d_a, bytes);
    cudaMalloc(&d_b, bytes);
    cudaMalloc(&d_c, bytes);

    int i;
    // Initialize vectors on host
    for( i = 0; i < n; i++ ) {
        h_a[i] = sin(i)*sin(i);
        h_b[i] = cos(i)*cos(i);
    }

    // Copy host vectors to device
    cudaMemcpy( d_a, h_a, bytes, cudaMemcpyHostToDevice);
    cudaMemcpy( d_b, h_b, bytes, cudaMemcpyHostToDevice);

    int blockSize, gridSize;

    // Number of threads in each thread block
    blockSize = 512;

    // Number of thread blocks in grid
    gridSize = (int)ceil((float)n/blockSize);

    // Execute the kernel
    vecAdd<<<gridSize, blockSize>>>(d_a, d_b, d_c, foo);

    // Copy array back to host
    cudaMemcpy( h_c, d_c, bytes, cudaMemcpyDeviceToHost );

    // Sum up vector c and print result divided by n, this should equal 1 within error
    int sum = 0;
    for(i=0; i<n; i++)
        sum += h_c[i];
    //printf("final result: %f\n", sum/n);

    // Release device memory
    cudaFree(d_a);
    cudaFree(d_b);
    cudaFree(d_c);

    // Release host memory
    free(h_a);
    free(h_b);
    free(h_c);

    return 0;
}
