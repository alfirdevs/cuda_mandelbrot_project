#pragma once
#include <fstream>
#include <string>

inline bool writePPM(const std::string& filename, int width, int height, const unsigned char* data) {
    std::ofstream out(filename, std::ios::binary);
    if (!out) return false;
    out << "P6\n" << width << " " << height << "\n255\n";
    out.write(reinterpret_cast<const char*>(data), static_cast<std::streamsize>(width) * height * 3);
    return static_cast<bool>(out);
}
