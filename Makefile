TARGET = mandelbrot_batch
NVCC = nvcc
CXXFLAGS = -O3 -std=c++17
SRC = src/main.cu

all: $(TARGET)

$(TARGET): $(SRC)
	$(NVCC) $(CXXFLAGS) $(SRC) -o $(TARGET)

clean:
	rm -f $(TARGET)
	rm -f data/output_images/* results/* proof/*
