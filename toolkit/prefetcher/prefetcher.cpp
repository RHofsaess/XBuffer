#include <XrdCl/XrdClFile.hh>
#include <cstdlib>
#include <iostream>
#include <vector>
#include <string>

const size_t blockSize = 64000; // Size of each block in bytes

// todo add offset...

void prefetchBlocks(const std::string& fileURL, const int numBlocks) {
    XrdCl::File file;
    XrdCl::XRootDStatus status;

    status = file.Open(fileURL, XrdCl::OpenFlags::Read);
    if (!status.IsOK()) {
        std::cerr << "Failed to open file: " << fileURL << std::endl;
        return;
    }

    std::vector<char> buffer(blockSize);
    for (size_t i = 0; i < numBlocks; ++i) {
        uint64_t offset = i * blockSize;
        uint32_t bytesRead;

        status = file.Read(offset, blockSize, buffer.data(), bytesRead);
        if (!status.IsOK() || bytesRead != blockSize) {
            std::cerr << "Error reading block " << i << std::endl;
            break;
        }

        // Optionally process the data in buffer
        // ...

        std::cout << "Read block " << i << std::endl;
    }

    status = file.Close();
    if (!status.IsOK()) {
        std::cerr << "Failed to close file." << std::endl;
    }
}

int main(int argc, char* argv[]) {
    if (argc != 3) {
        std::cerr << "Usage: " << argv[0] << " <fileURL> | " << "<nBlocks>" << std::endl;
        return 1;
    }

    int nBlocks = atoi(argv[2]);

    prefetchBlocks(argv[1], nBlocks);
    return 0;
}
