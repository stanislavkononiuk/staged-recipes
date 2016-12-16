#include <GL/glew.h>

#include <stdio.h>

int main() {
    fprintf(stdout, "Start of main()\n");
    GLenum err = glewInit();
    if (GLEW_OK != err)
    {
      fprintf(stderr, "Error: %s\n", glewGetErrorString(err));
    }
    fprintf(stdout, "Status: Using GLEW %s\n", glewGetString(GLEW_VERSION));
    return 0;
}