#include <openssl/ssl.h>
#include <openssl/err.h>
#include <iostream>
#include <string.h>
#include <unistd.h>
#include <arpa/inet.h>

class HelloIoTApp {
public:
    void run() {
        SSL_library_init();
        SSL_CTX* ctx = SSL_CTX_new(TLS_server_method());
        if (!ctx) {
            std::cerr << "Unable to create SSL context" << std::endl;
            ERR_print_errors_fp(stderr);
            return;
        }

        // Load server certificate and private key
        if (SSL_CTX_use_certificate_file(ctx, "/etc/ssl/certs/server.crt", SSL_FILETYPE_PEM) <= 0) {
            ERR_print_errors_fp(stderr);
            return;
        }

        if (SSL_CTX_use_PrivateKey_file(ctx, "/etc/ssl/private/server.key", SSL_FILETYPE_PEM) <= 0) {
            ERR_print_errors_fp(stderr);
            return;
        }

        int server_fd = socket(AF_INET, SOCK_STREAM, 0);
        struct sockaddr_in addr;
        addr.sin_family = AF_INET;
        addr.sin_port = htons(4433); // Use your preferred port
        addr.sin_addr.s_addr = inet_addr("127.0.0.1"); // Listen on localhost

        if (bind(server_fd, (struct sockaddr*)&addr, sizeof(addr)) < 0) {
            perror("Bind failed");
            return;
        }

        listen(server_fd, 1);

        std::cout << "HelloIoTApp is running on localhost... Waiting for connections..." << std::endl;

        while (true) {
            int client_fd = accept(server_fd, NULL, NULL);
            if (client_fd < 0) {
                perror("Accept failed");
                continue;
            }

            SSL* ssl = SSL_new(ctx);
            SSL_set_fd(ssl, client_fd);

            if (SSL_accept(ssl) <= 0) {
                ERR_print_errors_fp(stderr);
            } else {
                std::cout << "Secure connection established!" << std::endl;

                // Send a message to the client
                const char* msg = "Hello from the server!";
                SSL_write(ssl, msg, strlen(msg)); // Send the message to the client
                std::cout << "Message sent to client: " << msg << std::endl;
            }

            SSL_shutdown(ssl);
            SSL_free(ssl);
            close(client_fd);
        }

        SSL_CTX_free(ctx);
    }
};

int main() {
    HelloIoTApp app;
    app.run();
    return 0;
}
