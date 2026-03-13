#pragma once
#include <stdexcept>
#include <string>

struct Args {
    int width = 4096;
    int height = 4096;
    int max_iter = 2000;
    int num_images = 8;
    int compare_cpu = 1;
    std::string output_dir = "data/output_images";
};

inline Args parseArgs(int argc, char** argv) {
    Args args;
    for (int i = 1; i < argc; ++i) {
        std::string key = argv[i];
        auto need = [&](const std::string& k) {
            if (i + 1 >= argc) throw std::runtime_error("Missing value for " + k);
            return std::string(argv[++i]);
        };
        if (key == "--width") args.width = std::stoi(need(key));
        else if (key == "--height") args.height = std::stoi(need(key));
        else if (key == "--max-iter") args.max_iter = std::stoi(need(key));
        else if (key == "--num-images") args.num_images = std::stoi(need(key));
        else if (key == "--compare-cpu") args.compare_cpu = std::stoi(need(key));
        else if (key == "--output-dir") args.output_dir = need(key);
        else throw std::runtime_error("Unknown argument: " + key);
    }
    return args;
}
