#pragma once
#include <vector>

inline void renderMandelbrotCPU(
    std::vector<unsigned char>& image,
    int width,
    int height,
    int max_iter,
    double x_min,
    double x_max,
    double y_min,
    double y_max) {

    image.resize(static_cast<size_t>(width) * height * 3);

    for (int py = 0; py < height; ++py) {
        for (int px = 0; px < width; ++px) {
            double x0 = x_min + (x_max - x_min) * static_cast<double>(px) / width;
            double y0 = y_min + (y_max - y_min) * static_cast<double>(py) / height;

            double x = 0.0;
            double y = 0.0;
            int iter = 0;

            while (x * x + y * y <= 4.0 && iter < max_iter) {
                double xt = x * x - y * y + x0;
                y = 2.0 * x * y + y0;
                x = xt;
                ++iter;
            }

            unsigned char r = static_cast<unsigned char>((iter * 9) % 256);
            unsigned char g = static_cast<unsigned char>((iter * 7) % 256);
            unsigned char b = static_cast<unsigned char>((iter * 5) % 256);
            if (iter == max_iter) r = g = b = 0;

            size_t idx = static_cast<size_t>(py) * width * 3 + px * 3;
            image[idx + 0] = r;
            image[idx + 1] = g;
            image[idx + 2] = b;
        }
    }
}
