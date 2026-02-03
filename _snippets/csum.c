#include <stddef.h>
#include <stdio.h>
double c_sum(size_t n, double *X) {
    double s = 0.0;
    for (size_t i = 0; i < n; ++i) {
        s += X[i];
    }
    return s;
}

//main
int main(void) {
    double x[] = {1, 2, 3, 4, 5};
    size_t n = sizeof(x) / sizeof(x[0]);

    double result = c_sum(n, x);

    printf("C-computed Sum = %.2f\n", result);
    return 0;
}