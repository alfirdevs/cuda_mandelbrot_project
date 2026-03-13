#include <cuda_runtime.h>
#include <filesystem>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <sstream>
#include <string>
#include <tuple>
#include <vector>
#include <chrono>

#include "cli_args.h"
#include "mandelbrot_cpu.h"
#include "mandelbrot_gpu.h"
#include "image_writer.h"

namespace fs = std::filesystem;

#define CUDA_CHECK(call) do { \
    cudaError_t err = (call); \
    if (err != cudaSuccess) { \
        std::cerr << "CUDA error: " << cudaGetErrorString(err) << " at " \
                  << __FILE__ << ":" << __LINE__ << std::endl; \
        std::exit(EXIT_FAILURE); \
    } \
} while (0)

struct ViewWindow { double x_min; double x_max; double y_min; double y_max; };

static std::vector<ViewWindow> buildViews(int n) {
    std::vector<ViewWindow> views = {
        {-2.5, 1.0, -1.5, 1.5},
        {-0.74877, -0.74872, 0.06505, 0.06510},
        {-0.74365, -0.74360, 0.13180, 0.13185},
        {-0.10115, -0.10090, 0.95620, 0.95645},
        {-1.25066, -1.25061, 0.02010, 0.02015},
        {-0.77570, -0.77545, 0.13635, 0.13660},
        {-0.74550, -0.74525, 0.11260, 0.11285},
        {0.25000, 0.50000, -0.65000, -0.40000}
    };
    while ((int)views.size() < n) views.push_back(views[views.size() % 8]);
    views.resize(n);
    return views;
}

int main(int argc, char** argv) {
    Args args;
    try { args = parseArgs(argc, argv); }
    catch (const std::exception& e) { std::cerr << e.what() << std::endl; return EXIT_FAILURE; }

    fs::create_directories(args.output_dir);
    fs::create_directories("results");

    std::ofstream csv("results/timings.csv");
    csv << "image_id,width,height,max_iter,gpu_ms,cpu_ms,output_file\n";

    std::cout << "Rendering " << args.num_images << " Mandelbrot image(s)\n";
    std::cout << "Resolution: " << args.width << " x " << args.height << "\n";
    std::cout << "Max iterations: " << args.max_iter << "\n";

    size_t bytes = static_cast<size_t>(args.width) * args.height * 3;
    unsigned char* d_image = nullptr;
    CUDA_CHECK(cudaMalloc(&d_image, bytes));
    std::vector<unsigned char> h_image(bytes);
    auto views = buildViews(args.num_images);

    dim3 block(16, 16);
    dim3 grid((args.width + block.x - 1) / block.x,
              (args.height + block.y - 1) / block.y);

    for (int i = 0; i < args.num_images; ++i) {
        const auto& v = views[i];
        cudaEvent_t start, stop;
        CUDA_CHECK(cudaEventCreate(&start));
        CUDA_CHECK(cudaEventCreate(&stop));

        CUDA_CHECK(cudaEventRecord(start));
        mandelbrotKernel<<<grid, block>>>(d_image, args.width, args.height, args.max_iter,
                                          v.x_min, v.x_max, v.y_min, v.y_max);
        CUDA_CHECK(cudaGetLastError());
        CUDA_CHECK(cudaEventRecord(stop));
        CUDA_CHECK(cudaEventSynchronize(stop));

        float gpu_ms = 0.0f;
        CUDA_CHECK(cudaEventElapsedTime(&gpu_ms, start, stop));
        CUDA_CHECK(cudaMemcpy(h_image.data(), d_image, bytes, cudaMemcpyDeviceToHost));

        std::ostringstream name;
        name << args.output_dir << "/mandelbrot_" << std::setw(2) << std::setfill('0') << i << ".ppm";
        writePPM(name.str(), args.width, args.height, h_image.data());

        double cpu_ms = -1.0;
        if (args.compare_cpu == 1 && i == 0) {
            std::vector<unsigned char> cpu_img;
            auto t0 = std::chrono::high_resolution_clock::now();
            renderMandelbrotCPU(cpu_img, args.width, args.height, args.max_iter,
                                v.x_min, v.x_max, v.y_min, v.y_max);
            auto t1 = std::chrono::high_resolution_clock::now();
            cpu_ms = std::chrono::duration<double, std::milli>(t1 - t0).count();
            writePPM(args.output_dir + "/mandelbrot_cpu_reference.ppm", args.width, args.height, cpu_img.data());
        }

        csv << i << "," << args.width << "," << args.height << "," << args.max_iter
            << "," << gpu_ms << "," << cpu_ms << "," << name.str() << "\n";

        std::cout << "Image " << i << " | GPU time: " << gpu_ms << " ms";
        if (cpu_ms > 0) std::cout << " | CPU time: " << cpu_ms << " ms | Speedup: " << (cpu_ms / gpu_ms) << "x";
        std::cout << std::endl;

        CUDA_CHECK(cudaEventDestroy(start));
        CUDA_CHECK(cudaEventDestroy(stop));
    }

    CUDA_CHECK(cudaFree(d_image));

    std::ofstream summary("results/summary.txt");
    summary << "Batch Mandelbrot render completed.\n";
    summary << "Images rendered: " << args.num_images << "\n";
    summary << "Resolution: " << args.width << "x" << args.height << "\n";
    summary << "Max iterations: " << args.max_iter << "\n";
    summary << "See results/timings.csv for detailed timings.\n";

    std::cout << "Finished.\n";
    return 0;
}
